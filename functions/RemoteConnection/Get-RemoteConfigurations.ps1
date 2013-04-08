function Get-RemoteConfigurations{

	#--------------------------------------------------#
	# Parameter
	#--------------------------------------------------#
	param(
        [parameter(Mandatory=$false)]
        [string[]] 
        $Names,
        [parameter(Mandatory=$false)]
        [Switch]
        $ListAvailable
	)

	$Metadata = @{
		Title = "Get Powershell Remote Configurations"
		Filename = "Get-RemoteConfigurations.ps1"
		Description = ""
		Tags = "powershell, function, remote"
		Project = ""
		Author = "Janik von Rotz"
		AuthorContact = "www.janikvonrotz.ch"
		CreateDate = "2013-04-08"
		LastEditDate = "2013-04-08"
		Version = "1.0.0"
		License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
	#--------------------------------------------------#
	# Settings
	#--------------------------------------------------#
	$ProfilePath = Split-Path $profile -parent
	$RDPDefaultFile = Join-Path -Path $ProfilePath -ChildPath "Default.rdp"
	$XmlConfigFile = "*.remote.config.xml"
	$JsonConfigFile = "*.remote.config.json.ps1"
	$Config = @()
	
	#--------------------------------------------------#
	# Main
	#--------------------------------------------------#
	
	#Check if there are JSON config files and load them
	if(test-path ($ProfilePath + "\" + $JsonConfigFile)){
	
		$ConfigFiles = Get-Childitem ($ProfilePath + "\" + $JsonConfigFile)
		
		foreach($ConfigFile in $ConfigFiles ){		
            $Content = Invoke-Expression $ConfigFile
            $Content = $Content | ConvertFrom-Json
            $Config += $Content.Servers
        }
		
	#Otherwise check if there are XML config files and load them
	}elseif(test-path($ProfilePath + "\" + $XmlConfigFile)){
	
        $ConfigFiles = Get-Childitem ($ProfilePath + "\" + $XmlConfigFile)
		
		foreach($ConfigFile in $ConfigFiles ){
		    $Content = [xml]$(get-content ($ConfigFile))
		    $Config += $Content.Content.Servers
        }

	}else{
		Write-Host "`nNo configuration file found" -ForegroundColor Red
		Write-Host "`nPlease create a config file under $ProfilePath" -BackgroundColor Yellow -ForegroundColor Black
		Write-Host "If you'll use Powershell verison 2.0 name it $XmlConfigFile" -BackgroundColor Yellow -ForegroundColor Black
		Write-Host "If you'll use Powershell version 3.0 name it $JsonConfigFile" -BackgroundColor Yellow -ForegroundColor Black
		Write-Host "You'll find the templates for the config files on https://gist.github.com/janikvonrotz/103d7bfc7cfa2a5d21ed" -BackgroundColor Yellow -ForegroundColor Black
	    break
    }
    
    if($ListAvailable -and $Names -eq $null){
        $Config | Format-Table
    }else{
        if($Names -ne $null){

            foreach($Server in $Config){
                if(($Names).contains($Server.Name)){
                    $Server
                }
            }
        }else{
            throw "Enter values ​​for the following parameters: Names[]"            
        }
    }
}