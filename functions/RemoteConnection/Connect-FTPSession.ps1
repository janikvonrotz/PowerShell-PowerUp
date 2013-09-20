<#
$Metadata = @{
	Title = "Connect FTP Session"
	Filename = "Connect-FTPSession"
	Description = ""
	Tags = "powershell, remote, session, ftp, sftp"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "www.janikvonrotz.ch"
	CreateDate = "2013-05-17"
		LastEditDate = "2013-09-20"
	Version = "1.1.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

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

.PARAMETER  Secure
	Use sftp instead of ftp
	
.PARAMETER  PrivatKey
	PrivatKey (overwrites remote config file parameter)

.EXAMPLE
   Connect-FTPSession -Names firewall
#>

	param (
        [parameter(Mandatory=$true)][string]
		$Name,
		
        [parameter(Mandatory=$false)][string]
		$User,
		
        [parameter(Mandatory=$false)][int]
		$Port,
		
        [switch]
		$Secure,
				
        [parameter(Mandatory=$false)][string]
		$PrivatKey
	)


	#--------------------------------------------------#
	# main
	#--------------------------------------------------#
    
	if (Get-Command "winscp"){ 
    
    	# Load Configurations
		$Server = Get-RemoteConnections -Names $Name -FirstEntry
        $IniFile = $(Get-ChildItem -Path $PSconfigs.Path -Filter $PStemplates.WinSCP.Name -Recurse).FullName
        
        # default settings
        $SftpPort = 22
        $FtpPort = 21		
		
        # set port and protocol from config file
        if(!$Port){
            
            # cycle thour protoc configs
    		$Server.Protocol | %{
            
                # settings for ftp
    			if($_.Name -eq "ftp"){
                                        
    				$Protocol = "ftp"
                    
    				if($_.Port -ne ""){
                    
    					$Port = $_.Port
    				}else{
                        $Port = $FtpPort
                    }
                    
                # settings for sftp
    			}elseif($_.Name -eq "sftp"){
                
					$Protocol = "sftp"
                    
					if($_.Port -ne ""){
						$Port = $_.Port
                    }else{
                        $Port = $SftpPort
                    }              
               }
           }        
        }
        
        # if there is no configuration from config file
        if(!$Port -or $Port -eq 0){
            if($Secure){
                $Port = $SftpPort
            }else{
                $Port = $FtpPort
            }
        }
       
        # settings for secure parameter
        if(!$Protocol){
            if($Secure){
                $Protocol = "sftp"
            }else{
                $Protocol = "ftp"
            }
        }

		# set servername
		$Servername = $Server.Name
				
		# set username
		if(!$User){$User = $Server.User}
		
        # set privatkey
        if(!$PrivatKey){$PrivatKey = Invoke-Expression ($Command = '"' + $Server.PrivatKey + '"')}
        
        if($PrivatKey){
            Invoke-Expression ("WinSCP $Protocol"+"://$User@$Servername"+":$Port"+" /privatekey='$PrivatKey'" + " /ini=$IniFile")
        }else{
            Invoke-Expression ("WinSCP $Protocol"+"://$User@$Servername"+":$Port" + " /ini=$IniFile")
        }
    }
}