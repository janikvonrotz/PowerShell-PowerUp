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

function Get-Account([System.Xml.XmlElement]$accountNode){
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
    $account =  Get-SPManagedAccount -Identity $accountNode.Name -ErrorVariable err -ErrorAction SilentlyContinue
    if($account -eq $null){ 
        New-SPManagedAccount -Credential $accountCred | Out-Null 
    }       
    return $accountCred    
}
 
function Get-InstallOnCurrentServer([System.Xml.XmlElement]$node) 
{
    if ($node -eq $null -or $node.Server -eq $null) {
        return $false
    }
    $dbserver = $node.Server | where { (Get-ServerName $_).ToLower() -eq $env:ComputerName.ToLower() }
    if ($dbserver -eq $null -or $dbserver.Count -eq 0) {
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
$dbserver = $config.Farm.DatabaseServer

Trace "Configure WebApplication" {  
	foreach($item in $config.WebApplications.WebApplication){
		$webappname=$item.Name
	 	$webappport=$item.Port
        $rootsitename=$item.RootSiteName
        $webSitePfad=$item.WebSitePath + $webappname
        $webappdbname=$item.WebAppDBName
		$webappurl=$item.url
		$webappaccount=Get-Account($item.Account)
		$email = $config.email

		#New-SPManagedAccount -Credential $webappaccount
		
		if($webappport -eq "443"){
		   New-SPWebApplication -Name $webappname -SecureSocketsLayer -ApplicationPool $webappdbname -ApplicationPoolAccount (Get-SPManagedAccount $webappaccount.UserName) -Port $webappport -Url $webappurl -Path $webSitePfad  -DatabaseServer $dbserver -DatabaseName $webappdbname | Out-Null
		   New-SPSite -url $webappurl -OwnerAlias $webappaccount.UserName -Name $rootsitename -OwnerEmail $email  | Out-Null
           Write-Host -ForegroundColor Yellow "Bind the coresponding SSL Certificate to the IIS WebSite"
           Start-Process "$webappurl" -WindowStyle Minimized
		}else{
	  	   New-SPWebApplication -Name $webappname -ApplicationPool $webappdbname -ApplicationPoolAccount (Get-SPManagedAccount $webappaccount.UserName) -Port $webappport -Url $webappurl -Path $webSitePfad -DatabaseServer $dbserver -DatabaseName $webappdbname  | Out-Null
		   New-SPSite -url $webappurl -OwnerAlias $webappaccount.UserName -Name $rootsitename -OwnerEmail $email | Out-Null
           Start-Process "$webappurl" -WindowStyle Minimized
		}
   }
}

Trace "Configure UsageApplicationService" { 
	try
	{
		Write-Host -ForegroundColor Blue "- Creating WSS Usage Application..."
        #New-SPUsageApplication -Name "Usage and Health data collection Service" -DatabaseServer $dbserver -DatabaseName $config.Services.UsageApplicationService.collectioDB | Out-Null
        Set-SPUsageApplication -Identity "Erfassung von Verwendungs- und Integritätsdaten" -DatabaseName $config.Services.UsageApplicationService.collectioDB -DatabaseServer $dbserver
        Set-SPUsageService -LoggingEnabled 1 -UsageLogLocation $config.Services.UsageApplicationService.LogPfad -UsageLogMaxSpaceGB 2
	    Write-Host -ForegroundColor Blue "- Done Creating WSS Usage Application."
	}
	catch
	{	Write-Output $_
	}
}

Trace "Incoming Email disable" {
    $incommingEmail = Get-SPServiceInstance | Where {$_.TypeName -eq "Microsoft SharePoint Foundation Incoming E-Mail"} 
    If ($incommingEmail.Status -eq "Online") 
    {
    	try
    	{
    		Write-Host "- Stoping Microsoft SharePoint Foundation Incoming E-Mail..."
    		$incommingEmail | Stop-SPServiceInstance | Out-Null
    		If (-not $?) {throw}
    	}
    	catch {"- Microsoft SharePoint Foundation Incoming E-Mail"}
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
    	}
    	catch {"- An error occurred starting the Microsoft SharePoint Foundation User Code Service"}
    }
}

Trace "Creating BCS Service and Proxy" {
 	try
    	{
        $app = Get-SPServiceApplicationPool -Identity $config.ServiceAppPool.Name -ErrorVariable err -ErrorAction SilentlyContinue
        if($app.Name -eq $null){
            $appoolname=$config.ServiceAppPool.Name
		    $appooluser=Get-Account($config.ServiceAppPool.Account)
            $app = New-SPServiceApplicationPool -name $appoolname -account (Get-SPManagedAccount $appooluser.username) 
        }
		New-SPBusinessDataCatalogServiceApplication -Name $config.Services.BCS.Name -ApplicationPool $app -DatabaseServer $dbserver -DatabaseName $config.Services.BCS.DBName > $null  
		Get-SPServiceInstance | where-object {$_.TypeName -eq "Business Data Connectivity Service"} | Start-SPServiceInstance > $null 
	}
	catch
	{	Write-Output $_
	}
}


Trace "Configure State Service" { 
	try
	{
        Write-Host -ForegroundColor Blue "Creating State Service Application..."
        New-SPStateServiceDatabase -name $config.Services.StateService.DBName | Out-Null
        New-SPStateServiceApplication -Name "State Service Application" -Database $config.Services.StateService.DBName  | Out-Null
        Get-SPStateServiceDatabase | Initialize-SPStateServiceDatabase | Out-Null
        Get-SPStateServiceApplication | New-SPStateServiceApplicationProxy -Name "State Service Application Proxy"  -DefaultProxyGroup | Out-Null
	    Write-Host -ForegroundColor Blue "Done Creating State Service Application."
	}
	catch
	{	Write-Output $_
	}
}
Write-Host "Sleeping for 10 s"
Start-Sleep 10
Trace "Start Search Query and Site Settings Service" { 
	try
	{
	## Get the service instance
    $SearchQueryAndSiteSettingsService = (Get-SPServiceInstance | ?{$_.TypeName -eq "Search Query and Site Settings Service"})
    if (-not $?) { throw "- Failed to find Search Query and Site Settings service instance" }

    ## Start Service instance
    Write-Host -ForegroundColor Blue "- Starting Search Query and Site Settings Service Instance..."
    if($SearchQueryAndSiteSettingsService.Status -eq "Disabled")
	{ 
        $SearchQueryAndSiteSettingsService | Start-SPServiceInstance | Out-Null
        if (-not $?) { throw " - Failed to start Search Query and Site Settings service instance" }

        ## Wait
    	Write-Host -ForegroundColor Yellow " - Waiting for Search Query and Site Settings service to provision" -NoNewline
		While ($SearchQueryAndSiteSettingsService.Status -ne "Online") 
	    {
			Write-Host -ForegroundColor Yellow "." -NoNewline
		  	start-sleep 1
		  	$SearchQueryAndSiteSettingsService = (Get-SPServiceInstance |?{$_.TypeName -eq "Search Query and Site Settings Service"})
	    }
		Write-Host -BackgroundColor Yellow -ForegroundColor Black "Started!"
    }
    Else {Write-Host -ForegroundColor Blue "- Search Query and Site Settings Service already started, continuing..."}
	}
	catch
	{	Write-Output $_
	}
}

Trace "Configure Search Service Application" { 
	try
	{
        $SearchService = Get-SPServiceInstance | Where {$_.TypeName -eq "SharePoint Server-Suche"} 
        If ($SearchService.Status -eq "Disabled") 
        {
    	   try
    	   {
    		  Write-Host "- Starting Microsoft Search Service..."
    		  $SearchService | Start-SPServiceInstance | Out-Null
    		  If (-not $?) {throw}
    	   }
    	   catch {"- An error occurred starting the Search Service"}
        }
        
    
			Write-Host -ForegroundColor Blue "- Creating Search Application Pool"
            $app = Get-SPServiceApplicationPool -Identity $config.Services.EnterpriseSearch.AppPoolName -ErrorVariable err -ErrorAction SilentlyContinue
            if($app.Name -eq $null){
                $appoolname=$config.Services.EnterpriseSearch.AppPoolName
    		    $appooluser=Get-Account($config.Services.EnterpriseSearch.Account[0])
                $app = New-SPServiceApplicationPool -name $appoolname -account (Get-SPManagedAccount $appooluser.username) 
            }
            $searchapp = new-spenterprisesearchserviceapplication -name "Search Service Application" -ApplicationPool $app -databaseName "SP_AS_Search"
            $proxy = new-spenterprisesearchserviceapplicationproxy -name "Search Service Proxy" -Uri $searchapp.uri.absoluteURI    
            $proxy.status
            $si = get-spenterprisesearchserviceinstance –local 
            $si.status
            Start-SpEnterpriseSearchServiceInstance -identity $SI
            set-spenterprisesearchadministrationcomponent –searchapplication $searchapp  –searchserviceinstance $si
            
            
            Write-Host -ForegroundColor Blue "- Create Crawl Topology "
            $ct = $searchapp | new-spenterprisesearchcrawltopology
            Write-Host -ForegroundColor Blue "- Create a new Crawl Store"
            $csid = $SearchApp.CrawlStores | select id
            $CrawlStore = $SearchApp.CrawlStores.item($csid.id)
            Write-Host -ForegroundColor Blue "- Create a new Crawl Component"
            $hname = hostname 
            new-spenterprisesearchcrawlcomponent -crawltopology $ct -crawldatabase $Crawlstore -searchserviceinstance $hname
            Write-Host -ForegroundColor Blue "- Finally, set the new crawl topology as active."
            $ct | set-spenterprisesearchcrawltopology -active
            #Create Query Components and Activate
            $qt = $searchapp | new-spenterprisesearchquerytopology -partitions 1
            $p1 = ($qt | get-spenterprisesearchindexpartition)

            new-spenterprisesearchquerycomponent -indexpartition $p1 -querytopology $qt -searchserviceinstance $si 
            $PSID = $SearchApp.PropertyStores | Select id
            $PropDB = $SearchApp.PropertyStores.Item($PSID.id)

            $p1 | set-spenterprisesearchindexpartition -PropertyDatabase $PropDB
            Write-Host -ForegroundColor Blue "- Wait until the topology activcation is finsihed"
            sleep -s 120
            $qt | Set-SPEnterpriseSearchQueryTopology -Active

            Write-Host -ForegroundColor Blue "- Register Search Application Admin"
			Get-Account($config.Services.EnterpriseSearch.Account[1])
	}
	catch
	{	Write-Output $_
	}
}


Trace "Preconfigure Managet Metadata Service" { 
	try
{

      #App Pool     
      $ApplicationPool = Get-SPServiceApplicationPool $config.Services.ManagedMetadata.AppPoolName -ea SilentlyContinue
      if($ApplicationPool -eq $null)
	  { 
            throw "Cannot find application pool" 
      }

      #Create a Metadata Service Application
      if((Get-SPServiceApplication |?{$_.TypeName -eq "Managed Metadata Service"})-eq $null)
	  {      
			Write-Host -ForegroundColor Blue "- Creating Managed Metadata Service:"
            #Get the service instance
            $MetadataServiceInstance = (Get-SPServiceInstance |?{$_.TypeName -eq "Managed Metadata Web Service"})
            if (-not $?) { throw "- Failed to find Metadata service instance" }

             #Start Service instance
            if($MetadataserviceInstance.Status -eq "Disabled")
			{ 
                  Write-Host -ForegroundColor Blue " - Starting Metadata Service Instance..."
                  $MetadataServiceInstance | Start-SPServiceInstance | Out-Null
                  if (-not $?) { throw "- Failed to start Metadata service instance" }
            } 

            #Wait
			Write-Host -ForegroundColor Yellow " - Waiting for Metadata service to provision" -NoNewline
			While ($MetadataServiceInstance.Status -ne "Online") 
			{
				Write-Host -ForegroundColor Yellow "." -NoNewline
				sleep 1
				$MetadataServiceInstance = (Get-SPServiceInstance |?{$_.TypeName -eq "Managed Metadata Web Service"})
			}
			Write-Host -BackgroundColor Yellow -ForegroundColor Black "Started!"
#			Write-Host -ForegroundColor Blue " - Managed Metadata Web Service started."

            #Create Service App
   			Write-Host -ForegroundColor Blue " - Creating Metadata Service Application..."

            #CHECK ACCOUNTS TODO
            $MetaDataServiceApp  = New-SPMetadataServiceApplication -Name $config.Services.ManagedMetadata.Name -ApplicationPool $ApplicationPool -DatabaseName $config.Services.ManagedMetadata.DBName -HubUri $config.Services.ManagedMetadata.CTHubUrl
            if (-not $?) { throw "- Failed to create Metadata Service Application" }

            #create proxy
			Write-Host -ForegroundColor Blue " - Creating Metadata Service Application Proxy..."
            $MetaDataServiceAppProxy  = New-SPMetadataServiceApplicationProxy -Name "Metadata Service Application Proxy" -ServiceApplication $MetaDataServiceApp -DefaultProxyGroup
            if (-not $?) { throw "- Failed to create Metadata Service Application Proxy" }
            
			Write-Host -ForegroundColor Blue "- Done creating Managed Metadata Service."
      }
	  Else {Write-Host "- Managed Metadata Service already exists."}
}

 catch
 {
	Write-Output $_ 
 }
}

Trace "Predifine User Profile Service" { 
	try
    {
      $upsname = $config.Services.UserProfileService.Name
      Write-Host -ForegroundColor Blue "- Provisioning $upsname..."
      ## App Pool
	  Write-Host -ForegroundColor Blue " - Getting SharePoint Hosted Services app pool, creating if necessary..."
      $ApplicationPool = Get-SPServiceApplicationPool $config.Services.UserProfileService.AppPoolName -ea SilentlyContinue
      If ($ApplicationPool -eq $null)
	  { 
            throw "Cannot find application pool" 
      }
      ## Create a Profile Service Application
      If ((Get-SPServiceApplication |?{$_.TypeName -eq $upsname})-eq $null)
	  {      
            ## get the service instance
            $ProfileServiceInstance = (Get-SPServiceInstance |?{$_.TypeName -eq "User Profile Service"})
            If (-not $?) { throw " - Failed to find User Profile Service instance" }

            ## Start Service instance
			Write-Host -ForegroundColor Blue " - Starting User Profile Service instance..."
            If (($ProfileServiceInstance.Status -eq "Disabled") -or ($ProfileServiceInstance.Status -ne "Online"))
			{  
                $ProfileServiceInstance | Start-SPServiceInstance | Out-Null
                If (-not $?) { throw " - Failed to start User Profile Service instance" }

                ## Wait
   				Write-Host -ForegroundColor Yellow " - Waiting for User Profile Service to provision" -NoNewline
			    While ($ProfileServiceInstance.Status -ne "Online") 
			    {
					Write-Host -ForegroundColor Yellow "." -NoNewline
					sleep 1
				    $ProfileServiceInstance = (Get-SPServiceInstance |?{$_.TypeName -eq "User Profile Service"})
			    }
				Write-Host -BackgroundColor Yellow -ForegroundColor Black "Started!"
            }

			## Create Service App
			Write-Host -ForegroundColor Blue " - Creating $upsname..."
           	$ProfileServiceApp  = New-SPProfileServiceApplication -Name "$upsname" -ApplicationPool $ApplicationPool -ProfileDBName $config.Services.UserProfileService.DB.Profile -ProfileSyncDBName $config.Services.UserProfileService.DB.Sync -SocialDBName $config.Services.UserProfileService.DB.Social
           	If (-not $?) { throw " - Failed to create $upsname" }

            ## Create Proxy
			Write-Host -ForegroundColor Blue " - Creating $upsname Proxy..."
            $ProfileServiceAppProxy  = New-SPProfileServiceApplicationProxy -Name "$upsname Proxy" -ServiceApplication $ProfileServiceApp -DefaultProxyGroup
            If (-not $?) { throw " - Failed to create $upsname Proxy" }
			

			## Start Profile Synchronization Service
			# [Need to figure out how to associate the service with the User Profile Service upon starting]
			Write-Host -ForegroundColor Yellow " - You can now start `"$upsname`" from Central Admin." 
			#Write-Host -ForegroundColor Blue " - Starting User Profile Synchronization Service"
			#Start-SPServiceInstance $ProfileSyncServiceID | Out-Null			
			Write-Host -ForegroundColor Blue "- Done creating $upsname ."
      }
    }
    catch
    {
            Write-Output $_ 
    }
}