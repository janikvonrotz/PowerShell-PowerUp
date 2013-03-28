function Create-PSSession{
	#--------------------------------------------------#
	# Parameter
	#--------------------------------------------------#
	param (
        [parameter(Mandatory=$true)]
		$Name
	)
	$Metadata = @{
		Title = "Create Powershell Remote Session"
		Filename = "Create-PSSession.ps1"
		Description = ""
		Tags = "powershell, remote, session"
		Project = ""
		Author = "Janik von Rotz"
		AuthorEMail = "contact@janikvonrotz.ch"
		CreateDate = "2013-03-12"
		LastEditDate = "2013-03-28"
		Version = "2.1.0"
		License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
	#--------------------------------------------------#
	# Settings
	#--------------------------------------------------#
	$XmlConfigFile = "Create-PSSession.config.xml"
	$JsonConfigFile = "Create-PSSession.config.json.ps1"
	
	#--------------------------------------------------#
	# Main
	#--------------------------------------------------#
	$ProfilePath = Split-Path $profile -parent
	if(test-path ($ProfilePath + "\" + $JsonConfigFile)){
		$Config = Get-JsonConfig -Path ($ProfilePath + "\" + $JsonConfigFile)
	}elseif(test-path($ProfilePath + "\" + $XmlConfigFile)){
		$Config = [xml]$(get-content ($ProfilePath + "\" + $XmlConfigFile))
        $Config = $Config.Content
	}else{
        Write-Host "`nNo configuration file found" -ForegroundColor Red
        Write-Host "`nPlease create a config file under $ProfilePath" -BackgroundColor Yellow -ForegroundColor Black
        Write-Host "If you'll use Powershell verison 2.0 name it $XmlConfigFile" -BackgroundColor Yellow -ForegroundColor Black
        Write-Host "If you'll use Powershell version 3.0 name it $JsonConfigFile" -BackgroundColor Yellow -ForegroundColor Black
        Write-Host "You'll find the templates for the config files on https://gist.github.com/janikvonrotz/103d7bfc7cfa2a5d21ed" -BackgroundColor Yellow -ForegroundColor Black
	}
	
	foreach($Server in $Config.Servers){
		if($Server.Name -eq $Name){
		
			# Delete Session if already opened
			Remove-PSSession -ComputerName $Server.Server -ErrorAction SilentlyContinue
			
			$Username = $Server.ADCredential
			$Password = Read-Host -Prompt "`nEnter password for $Username" -AsSecureString
			$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $Username, $Password
			
			# Open Session
			$s = New-PSSession -ComputerName $Server.Server -Credential $Credentials
			
			# Load SnapIns
			foreach($SnapIn in $Server.SnapIns){
				Invoke-Command -Session $s -ScriptBlock {param ($Name) Add-PSSnapin -Name $Name} -ArgumentList $SnapIn
			}
            return $s
		}
	}
}