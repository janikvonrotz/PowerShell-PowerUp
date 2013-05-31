$snapin = Get-PSSnapin Microsoft.SharePoint.Powershell -ErrorVariable err -ErrorAction SilentlyContinue
if($snapin -eq $null){
Add-PSSnapin Microsoft.SharePoint.Powershell 
}

function Write-Info([string]$msg){
    Write-Host "$($global:indent)[$([System.DateTime]::Now)] $msg"
}

function Get-ConfigurationSettings() {
    Write-Info "Loading configuration file."
    [xml]$config = Get-Content .\Configurations.xml

    if ($? -eq $false) {
        Write-Info "Cannot load configuration source XML $config."
        return $null
    }
    return $config.Configurations
}

function Trace([string]$desc, $code) {
    trap {
        Write-Error $_.Exception
        if ($_.Exception.InnerException -ne $null) {
            Write-Error "Inner Exception: $($_.Exception.InnerException)"
        }
        break
    }
    $desc = $desc.TrimEnd(".")
    Write-Info "BEGIN: $desc..."
    Set-Indent 1
    &$code
    Set-Indent -1
    Write-Info "END: $desc."
}

function Set-Indent([int]$incrementLevel)
{
    if ($incrementLevel -eq 0) {$global:indent = ""; return}
    
    if ($incrementLevel -gt 0) {
        for ($i = 0; $i -lt $incrementLevel; $i++) {
            $global:indent = "$($global:indent)`t"
        }
    } else {
        if (($global:indent).Length + $incrementLevel -ge 0) {
            $global:indent = ($global:indent).Remove(($global:indent).Length + $incrementLevel, -$incrementLevel)
        } else {
            $global:indent = ""
        }
    }
}

function Get-Account([System.Xml.XmlElement]$accountNode) 
{
    while (![string]::IsNullOrEmpty($accountNode.Ref)) {
        $accountNode = $accountNode.PSBase.OwnerDocument.SelectSingleNode("//Accounts/Account[@ID='$($accountNode.Ref)']")
    }

    if ($accountNode -eq $null) {
        throw "The account specified cannot be retrieved."
    }
    if ($accountNode.Password.Length -gt 0) {
        $accountCred = New-Object System.Management.Automation.PSCredential $accountNode.Name, (ConvertTo-SecureString $accountNode.Password -AsPlainText -force)
    } else {
        Write-Info "Please specify the credentials for" $accountNode.Name
        $accountCred = Get-Credential $accountNode.Name
    }
    $account =  Get-SPManagedAccount -Identity "$accountNode.Name" -ErrorVariable err -ErrorAction SilentlyContinue
    if($account -ne $null){ 
        New-SPManagedAccount -Credential $accountCred | Out-Null 
    }       
    return $accountCred    
}

function Get-InstallOnCurrentServer([System.Xml.XmlElement]$node) 
{
    if ($node -eq $null -or $node.Server -eq $null) {
        return $false
    }
    $server = $node.Server | where { (Get-ServerName $_).ToLower() -eq $env:ComputerName.ToLower() }
    if ($server -eq $null -or $server.Count -eq 0) {
        return $false
    }
    return $true
}

function Get-ServerName([System.Xml.XmlElement]$node)
{
    while (![string]::IsNullOrEmpty($node.Ref)) {
        $node = $node.PSBase.OwnerDocument.SelectSingleNode("//Servers/Server[@ID='$($node.Ref)']")
    }
    if ($node -eq $null -or $node.Name -eq $null) { throw "Unable to locate server name!" }
    return $node.Name
}

[System.Xml.XmlElement]$config = Get-ConfigurationSettings

if ($config -eq $null) {
    return $false
}

#Variabeln
$server = $config.Farm.DatabaseServer

Trace "Configure WebApplication" {  
	foreach($item in $config.WebApplications.WebApplication){
		$webappname=$item.Name
	 	$webappport=$item.Port
		$webappdbname=$item.WebAppDBName
        $webSitePfad=$item.WebSitePath + $webappname
        $rootsitename=$item.RootSiteName
		$webappurl=$item.url
		$webappaccount=Get-Account($item.Account)
		$email = $config.email

		New-SPManagedAccount -Credential $webappaccount
		
		if($webappport -eq "443"){
		   New-SPWebApplication -Name $webappname -SecureSocketsLayer -ApplicationPool $webappdbname -ApplicationPoolAccount (Get-SPManagedAccount $webappaccount.UserName) -Port $webappport -Url $webappurl -Path $webSitePfad -DatabaseServer $server -DatabaseName $webappdbname
		   New-SPSite -url $webappurl -OwnerAlias $webappaccount.UserName -Name $rootsitename -OwnerEmail $email
           Write-Host -ForegroundColor Yellow "Bind the coresponding SSL Certificate to the IIS WebSite"
           Start-Process "$webappurl" -WindowStyle Minimized
		}else{
	  	   New-SPWebApplication -Name $webappname -ApplicationPool $webappdbname -ApplicationPoolAccount (Get-SPManagedAccount $webappaccount.UserName) -Port $webappport -Url $webappurl -Path $webSitePfad -DatabaseServer $server -DatabaseName $webappdbname
		   New-SPSite -url $webappurl -OwnerAlias $webappaccount.UserName -Name $rootsitename -OwnerEmail $email
           Start-Process "$webappurl" -WindowStyle Minimized
		}
    	if ($err) {
        		throw $err
    	}
   }
}

Trace "Configure UsageApplicationService" { 
	try
	{
		Write-Host -ForegroundColor Blue "- Creating WSS Usage Application..."
		New-SPUsageApplication -Name "Usage and Health data collection Service" -DatabaseServer $server -DatabaseName $config.UsageApplicationService.collectioDB | Out-Null
	    Write-Host -ForegroundColor Blue "- Done Creating WSS Usage Application."
	}
	catch
	{	Write-Output $_
	}
}

Trace "Microsoft SharePoint Foundation User Code Service" {
    $UserCodeService = Get-SPServiceInstance | Where {$_.TypeName -eq "Microsoft SharePoint Foundation Sandboxed Code Service"} 
    If ($UserCodeService.Status -eq "Disabled") 
    {
    	try
    	{
    		Write-Host "- Starting Microsoft SharePoint Foundation User Code Service..."
    		$UserCodeService | Start-SPServiceInstance | Out-Null
    		If (-not $?) {throw}
    		Write-Host "- Started."
    	}
    	catch {"- An error occurred starting the Microsoft SharePoint Foundation User Code Service"}
    }
}

Trace "Incoming Email disable" {
    $UserCodeService = Get-SPServiceInstance | Where {$_.TypeName -eq "Microsoft SharePoint Foundation Incoming E-Mail"} 
    If ($UserCodeService.Status -eq "Online") 
    {
    	try
    	{
    		Write-Host "- Stoping Microsoft SharePoint Foundation Incoming E-Mail..."
    		$UserCodeService | Stop-SPServiceInstance | Out-Null
    		If (-not $?) {throw}
    		Write-Host "- Started."
    	}
    	catch {"- Microsoft SharePoint Foundation Incoming E-Mail"}
    }
}


Trace "Creating BCS Service and Proxy" {
 	try
    	{ 
		$appooluser=Get-Account($config.ServiceAppPool.Account)
		New-SPManagedAccount -Credential $appooluser
		$appoolname=$config.ServiceAppPool.Name
		$app = New-SPServiceApplicationPool -name $appoolname -account (Get-SPManagedAccount $appooluser.username)  
		New-SPBusinessDataCatalogServiceApplication -Name $config.BCS.Name -ApplicationPool $app -DatabaseServer $server -DatabaseName $config.BCS.DBName > $null  
		Get-SPServiceInstance | where-object {$_.TypeName -eq "Business Data Connectivity Service"} | Start-SPServiceInstance > $null 
	}
	catch
	{	Write-Output $_
	}
}

#SharePoint Foundation Search

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


