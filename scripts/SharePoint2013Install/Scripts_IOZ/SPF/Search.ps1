#function Start-FoundationSearch([string]$settingsFile = "Configurations.xml") {
[xml]$config = Get-Content ".\Configurations.xml"
$svcConfig = $config.Configurations.Services.FoundationSearchService

#See if we want to start the svc on the current server.
$install = (($svcConfig.Servers.Server | where {$_.Name -eq $env:computername}) -ne $null)
if (!$install) { 
Write-Host "Machine not specified in Servers element, service will not be started on this server."
return
}

#Start the service instance
$svc = Get-SPServiceInstance | where {$_.TypeName -eq "SharePoint Foundation Search" -and $_.Parent.Name -eq $env:ComputerName}
if ($svc -eq $null) {
$svc = Get-SPServiceInstance | where {$_.TypeName -eq "SharePoint Foundation Help Search" -and $_.Parent.Name -eq $env:ComputerName}
}
Start-SPServiceInstance -Identity $svc

#Get the service and service instance
$searchSvc = Get-SPSearchService
$searchSvcInstance = Get-SPSearchServiceInstance -Local

$dbServer = $svcConfig.DatabaseServer
$failoverDbServer = $svcConfig.FailoverDatabaseServer

#Get the service account details
Write-Host "Provide the username and password for the search crawl account..."
$crawlAccount = Get-Credential $svcConfig.CrawlAccount.Name
Write-Host "Provide the username and password for the search service account..."
$searchSvcAccount = Get-Credential $svcConfig.SvcAccount.Name

#Get or Create a managed account for the search service account.
$searchSvcManagedAccount = (Get-SPManagedAccount -Identity $svcConfig.SvcAccount.Name -ErrorVariable err -ErrorAction SilentlyContinue)
if ($err) {
$searchSvcManagedAccount = New-SPManagedAccount -Credential $searchSvcAccount
}

#Set the account details if different than what is current.
$processIdentity = $searchSvc.ProcessIdentity
if ($processIdentity.ManagedAccount.Username -ne $searchSvcManagedAccount.Username) {
$processIdentity = $searchSvc.ProcessIdentity
$processIdentity.CurrentIdentityType = "SpecificUser"
$processIdentity.ManagedAccount = $searchSvcManagedAccount
Write-Host "Updating the service process identity..."
$processIdentity.Update()
$searchSvc.Update()
} 

#It doesn't hurt if this runs more than once so we don't bother checking before running.
Write-Host "Updating the search service properties..."
$searchSvc | Set-SPSearchService `
-CrawlAccount $crawlAccount.Username `
-CrawlPassword $crawlAccount.Password `
-AddStartAddressForNonNTZone $svcConfig.AddStartAddressForNonNTZone `
-MaxBackupDuration $svcConfig.MaxBackupDuration `
-PerformanceLevel $svcConfig.PerformanceLevel `
-ErrorVariable err `
-ErrorAction SilentlyContinue
if ($err) {
throw $err
}

#Build the connection string to the new database.
[System.Data.SqlClient.SqlConnectionStringBuilder]$builder1 = New-Object System.Data.SqlClient.SqlConnectionStringBuilder
$builder1.psbase.DataSource = $dbServer
$builder1.psbase.InitialCatalog = $svcConfig.DatabaseName
$builder1.psbase.IntegratedSecurity = $true
Write-Host "Proposed database connection: {$builder1}"

[Microsoft.SharePoint.Search.Administration.SPSearchDatabase]$searchDb = $searchSvcInstance.SearchDatabase
$dbMatch = $false
if ($searchDb -ne $null) {
#A database is already set - if it's the one we expect then keep it, otherwise we want to delete it.
[System.Data.SqlClient.SqlConnectionStringBuilder]$builder2 = New-Object System.Data.SqlClient.SqlConnectionStringBuilder($searchDb.DatabaseConnectionString)
Write-Host "Existing database connection: {$builder2}"
if ($builder2.ConnectionString.StartsWith($builder1.ConnectionString, [StringComparison]::OrdinalIgnoreCase)) {
$dbMatch = $true
}
if (!$dbMatch -and $searchDb.DatabaseConnectionString.Equals($builder1.ConnectionString, [StringComparison]::OrdinalIgnoreCase)) {
$dbMatch = $true
}
if (!$dbMatch) {
#The database does not match the configuration provided so delete it.
Write-Host "The specified database details do not match existing details. Clearing existing."
$searchSvcInstance.SearchDatabase = $null
$searchSvcInstance.Update()
Write-Host "Deleting {$($searchDb.DatabaseConnectionString)}..."
$searchDb.Delete()
Write-Host "Finished deleting search DB."
$searchDb = $null
} else {
Write-Host "Existing Database details match provided details ($($builder2))"
}
}

#If we don't have a DB go ahead and create one.
if ($searchDb -eq $null) {
$dbCreated = $false
try
{
Write-Host "Creating new search database {$builder1}..."
$searchDb = [Microsoft.SharePoint.Search.Administration.SPSearchDatabase]::Create($builder1)
Write-Host "Provisioning new search database..."
$searchDb.Provision()
Write-Host "Provisioning search database complete."
$dbCreated = $true

#Re-get the service to avoid update conflicts
$searchSvc = Get-SPSearchService
$searchSvcInstance = Get-SPSearchServiceInstance -Local

Write-Host "Associating new database with search service instance..."
$searchSvcInstance.SearchDatabase = $searchDb
Write-Host "Updating search service instance..."
$searchSvcInstance.Update()

#Re-get the service to avoid update conflicts
$searchSvc = Get-SPSearchService
$searchSvcInstance = Get-SPSearchServiceInstance -Local
}
catch
{
if ($searchDb -ne $null -and $dbCreated) {
Write-Warning "An error occurred updating the search service instance, deleting search database..."
try
{
#Clean up
$searchDb.Delete()
}
catch
{
Write-Warning "Unable to delete search database."
Write-Error $_
}
}
throw $_
} 
}

#Set the database failover server
if (![string]::IsNullOrEmpty($failoverDbServer)) {
if (($searchDb.FailoverServiceInstance -eq $null) -or `
![string]::Equals($searchDb.FailoverServiceInstance.NormalizedDataSource, $failoverDbServer, [StringComparison]::OrdinalIgnoreCase))
{
try
{
Write-Host "Adding failover database instance..."
$searchSvcInstance.SearchDatabase.AddFailoverServiceInstance($failoverDbServer)
Write-Host "Updating search service instance..."
$searchSvcInstance.Update()
}
catch
{
Write-Warning "Unable to set failover database server. $_"
}
}
}

$status = $searchSvcInstance.Status
#Provision the service instance on the current server
if ($status -ne [Microsoft.SharePoint.Administration.SPObjectStatus]::Online) {
if ([Microsoft.SharePoint.Administration.SPServer]::Local -eq $searchSvcInstance.Server) {
try
{
Write-Host "Provisioning search service instance..."
$searchSvcInstance.Provision()
}
catch
{
Write-Warning "The call to SPSearchServiceInstance.Provision (server '$($searchSvcInstance.Server.Name)') failed. Setting back to previous status '$status'. $($_.Exception)"
if ($status -ne $searchSvcInstance.Status) {
try
{
$searchSvcInstance.Status = $status
$searchSvcInstance.Update()
}
catch
{
Write-Warning "Failed to restore previous status on the SPSearchServiceInstance (server '$($searchSvcInstance.Server.Name)'). $($_.Exception)"
}
}
throw $_
}
}
}

#Re-get the service to avoid update conflicts
$searchSvc = Get-SPSearchService

#Create the timer job to update the instances for the other servers.
foreach ($serviceInstance in $searchSvc.Instances) {
if ($serviceInstance -is [Microsoft.SharePoint.Search.Administration.SPSearchServiceInstance] `
-and $serviceInstance -ne $searchSvcInstance `
-and $serviceInstance.Status -eq [Microsoft.SharePoint.Administration.SPObjectStatus]::Online) {
$definition = $serviceInstance.Farm.GetObject("job-service-instance-$($serviceInstance.Id.ToString())", $serviceInstance.Farm.TimerService.Id, [Microsoft.SharePoint.Administration.SPServiceInstanceJobDefinition])
if ($definition -ne $null) {
Write-Host "A provisioning job for the SPSearchServiceInstance on server '$($serviceInstance.Server.Name)' already exists; skipping."
} else {
Write-Host "Creating provisioning job for the SPSearchServiceInstance on server '$($serviceInstance.Server.Name)'..."
$job = New-Object Microsoft.SharePoint.Administration.SPServiceInstanceJobDefinition($serviceInstance, $true)
$job.Update($true)
}
}
}

#Set the proxy type for all the service instances.
$svcConfig.Servers.Server | ForEach-Object {
$server = $_
$instance = Get-SPSearchServiceInstance | where {$_.Server.Name -eq $server.Name}
if ($instance -ne $null `
-and $server.ProxyType.ToLowerInvariant() -ne $instance.ProxyType.ToLowerInvariant) {
Write-Host "Setting proxy type for $($instance.Server.Name) to $($server.ProxyType)..."
$instance | Set-SPSearchServiceInstance -ProxyType $server.ProxyType 
}
}


