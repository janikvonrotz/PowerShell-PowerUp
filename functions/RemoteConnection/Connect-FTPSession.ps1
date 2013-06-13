function Connect-FTPSession{
<#
	.SYNOPSIS
		Remote management for ftp sessions

	.DESCRIPTION
		Starts a ftp session with the parameters from the remote config file.

	.PARAMETER Name
		Servername (Key or Name from the remote config file for preconfiguration)
		
	.PARAMETER User
		Username (overwrites remote config file parameter)
		
	.PARAMETER Port
		Port (overwrites remote config file parameter)

	.EXAMPLE
	   Connect-FTPSession -Names firewall

#>

	#--------------------------------------------------#
	# Parameter
	#--------------------------------------------------#
	param (
        [parameter(Mandatory=$true)][string]
		$Name,
        [parameter(Mandatory=$false)][string]
		$User,
        [parameter(Mandatory=$false)][int]
		$Port
	)

	$Metadata = @{
		Title = "Connect FTP Session"
		Filename = "Connect-FTPSession"
		Description = ""
		Tags = "powershell, remote, session, ftp"
		Project = ""
		Author = "Janik von Rotz"
		AuthorContact = "www.janikvonrotz.ch"
		CreateDate = "2013-05-17"
		LastEditDate = "2013-06-13"
		Version = "1.0.0"
		License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}


	#--------------------------------------------------#
	# main
	#--------------------------------------------------#
	if (Get-Command "winscp.exe"){ 

		# Load Configurations
		$Server = Get-RemoteConnections -Names $Name -FirstEntry

		# set port
		# get port from Protocol
		if(!$Port){
			$Server.Protocol | %{
				if ($_.Name -eq "scp" -and $_.Port -ne ""){
					$Port = $_.Port
				}
			}
		}
		if(!$Port -or $Port -eq 0){
			$Port = 21
		}

		# set servername
		$Servername = $Server.Name

		# set username
		if(!$User){$User = $Server.User}

        Invoke-Expression ("WinSCP.exe ftp://$User@$Servername" + ":$Port")
        
    }
}