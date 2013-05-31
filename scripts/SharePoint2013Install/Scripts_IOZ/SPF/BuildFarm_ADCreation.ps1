$snapin = Get-PSSnapin Microsoft.SharePoint.Powershell -ErrorVariable err -ErrorAction SilentlyContinue
if($snapin -eq $null){
Add-PSSnapin Microsoft.SharePoint.Powershell 
}

function Write-Info([string]$msg){
    Write-Host "$($global:indent)[$([System.DateTime]::Now)] $msg"
}

function Get-ConfigurationSettings() {
    Write-Info "Loading configuration file."
    [xml]$config = Get-Content ".\Configurations.xml"

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

function Set-Indent([int]$incrementLevel){
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
    
    #See if we have the account already as a managed account
    #if (([Microsoft.SharePoint.Administration.SPFarm]::Local) -ne $null) {
    #    [Microsoft.SharePoint.Administration.SPManagedAccount]$account = (Get-SPManagedAccount -Identity $accountNode.Name -ErrorVariable err -ErrorAction SilentlyContinue)
    #    
    #    if ([string]::IsNullOrEmpty($err) -eq $true) {
    #        $accountCred = New-Object System.Management.Automation.PSCredential $account.Username, $account.SecurePassword
    #        return $accountCred
    #    }
    #}
    if ($accountNode.Password.Length -gt 0) {
        $accountCred = New-Object System.Management.Automation.PSCredential $accountNode.Name, (ConvertTo-SecureString $accountNode.Password -AsPlainText -force)
    } else {
        Write-Info "Please specify the credentials for" $accountNode.Name
        $accountCred = Get-Credential $accountNode.Name
    }
    return $accountCred    
}

function Get-InstallOnCurrentServer([System.Xml.XmlElement]$node){
    if ($node -eq $null -or $node.Server -eq $null) {
        return $false
    }
    $server = $node.Server | where { (Get-ServerName $_).ToLower() -eq $env:ComputerName.ToLower() }
    if ($server -eq $null -or $server.Count -eq 0) {
        return $false
    }
    return $true
}

function Get-ServerName([System.Xml.XmlElement]$node){
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

#Variabeln festlegen
$farmAcct = Get-Account $config.Farm.Account
$configDb = $config.Farm.ConfigDB
$adminContentDb = $config.Farm.adminContentDb
$server = $config.Farm.DatabaseServer
$directory = $config.Farm.Directory 	
if ($config.Farm.Passphrase.Length -gt 0) {
    $passphrase = (ConvertTo-SecureString $config.Farm.Passphrase -AsPlainText -force)
} else {
    Write-Warning "You didn't enter a farm passphrase, using the Farm Administrator's password instead"
    $passphrase = $farmAcct.Password
}

    
Trace "Creating new farm" {
    New-SPConfigurationDatabase -DatabaseName $configDb -DatabaseServer $server -DirectoryDomain $directory.Domain -DirectoryOrganizationUnit $directory.OU -AdministrationContentDatabaseName $adminContentDb -Passphrase $passphrase -FarmCredentials $farmAcct -ErrorVariable err
    if ($err) {
    	throw $err
    }
}

Trace "Verifying farm creation" {
    $spfarm = Get-SPFarm -ErrorVariable err
    if ($spfarm -eq $null -or $err) {
        throw "Unable to verify farm creation."
    }
}

Trace "Install Help Files" {
    Install-SPHelpCollection -All -ErrorVariable err
    if ($err) {
        throw $err
    }
}

Trace "ACLing SharePoint Resources" {
    Initialize-SPResourceSecurity -ErrorVariable err     
    if ($err) {
        throw $err
    }
}

Trace "Installing Services" {
    Install-SPService -ErrorVariable err     
    if ($err) {
        throw $err
    }
}

Trace "Installing Features" {
    $Features = Install-SPFeature –AllExistingFeatures -Force -ErrorVariable err 
    if ($err) {
        throw $err
    }
}  
 
Trace "Provisioning Central Administration" {
    New-SPCentralAdministration -Port $config.CentralAdmin.Port -WindowsAuthProvider $config.CentralAdmin.AuthProvider -ErrorVariable err
    if ($err) {
        throw $err
    }
}

Trace "Installing Application Content" {
    sleep 5
	Install-SPApplicationContent -ErrorVariable err
    if ($err) {
        throw $err
    }
}

Trace "Configure Outgoing Email" {
    $email=$config.Farm.Email
    stsadm -o email -outsmtpserver $email.MailServer -fromaddress $email.FromAddress -replytoaddress $email.Reply -codepage 65001
    if ($err) {
         throw $err
    }
}

Trace "Run Configuration Wizard" {
    # Run wizard
    psconfig -cmd helpcollections -installall
    psconfig -cmd secureresources
    psconfig -cmd services -install
    psconfig -cmd installfeatures
    psconfig -cmd applicationcontent -install
    iisreset
}


Trace "Start Central Administration" {
    $cahost = hostname
    $port=$config.CentralAdmin.Port
    $caurl="http://"+ $cahost + ":" + $port 
    Start-Process "$caurl" -WindowStyle Minimized
}