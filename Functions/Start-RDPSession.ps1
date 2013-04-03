function Start-RDPSession{
    <#
	    .SYNOPSIS
		    Starts a remote desktop session

	    .DESCRIPTION
		    Starts a remote desktop session with the parameters from the Remote config file and a RDP file.

	    .PARAMETER  Names
		    Server names from the remote config file

	    .EXAMPLE
		    Start-RDPSession -Names sharepoint
            Start-RDPSession -Names sharepoint,dns

    #>

	#--------------------------------------------------#
	# Parameter
	#--------------------------------------------------#
	param (
        [parameter(Mandatory=$true)][string[]]
		$Names
	)

	$Metadata = @{
		Title = "Start a Remote Desktop Session"
		Filename = "Start-RDPSession.ps1"
		Description = ""
		Tags = "powershell, remote, session, rdp"
		Project = ""
		Author = "Janik von Rotz"
		AuthorEMail = "contact@janikvonrotz.ch"
		CreateDate = "2013-04-03"
		LastEditDate = "2013-04-03"
		Version = "1.0.0"
		License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
    
    if ((Get-Command "cmdkey.exe") -and (Get-Command "mstsc.exe")) 
    { 

        #--------------------------------------------------#
	    # Settings
	    #--------------------------------------------------#
        $ProfilePath = Split-Path $profile -parent
        $RDPDefaultFile = Join-Path -Path $ProfilePath -ChildPath "Default.rdp"
	    $XmlConfigFile = "Remote.config.xml"
	    $JsonConfigFile = "Remote.config.json.ps1"

        #--------------------------------------------------#
        # Main
        #--------------------------------------------------#

        # Load Configurations from config file

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
		    if(($Names).contains($Server.Name)){
		        
                $Servername = $Server.Server
                $Username = $Server.ADCredential

                # Delete existing user credentials
                $Null = Invoke-Expression "cmdkey /delete:'$Servername'"

                # Add user credentials
                $Null = Invoke-Expression "cmdkey /generic:'$Servername' /user:'$Username'"


                # Open remote session
                Invoke-Expression "mstsc.exe '$RDPDefaultFile' /v:$Servername"
		    }
	    }
    }
}