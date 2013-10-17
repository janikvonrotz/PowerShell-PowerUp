<#
$Metadata = @{
	Title = "Connect SCP Session"
	Filename = "Connect-SCP.ps1"
	Description = ""
	Tags = "powershell, remote, session, scp"
	Project = ""
	Author = "Janik von Rotz"
    AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-05-17"
    LastEditDate = "2013-10-02"
	Version = "3.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Connect-SCP{

<#
.SYNOPSIS
    Remote management for scp sessions.

.DESCRIPTION
    Starts a scp session with the parameters from the remote config file.

.PARAMETER  Name
    Servername (Key or Name from the remote config file for preconfiguration).

.PARAMETER  User
    Username (overwrites remote config file parameter).

.PARAMETER  Port
    Port (overwrites remote config file parameter).
  
.PARAMETER  PrivatKey
    PrivatKey (overwrites remote config file parameter).

.EXAMPLE
    Connect-SCP -Name firewall
#>

	#--------------------------------------------------#
	# Parameter
	#--------------------------------------------------#
	param (
        [parameter(Mandatory=$true)]
        [string[]]
        $Name,
        
        [parameter(Mandatory=$false)]
        [string]$User,
        
        [parameter(Mandatory=$false)]
        [int]$Port,
        
        [parameter(Mandatory=$false)]
        [string]$PrivatKey
	)

    #--------------------------------------------------#
    # main
    #--------------------------------------------------#
    
    if (Get-Command "winscp"){ 

        # Load Configurations
    	$Servers = Get-RemoteConnection -Name $Name
        $IniFile = $(Get-ChildItem -Path $PSconfigs.Path -Filter $PStemplates.WinSCP.Name -Recurse).FullName
    	
        foreach($Server in $Servers){
        
            # get port from Protocol
            if(!$Port){
                $Server.Protocol | %{
                    if ($_.Name -eq "scp" -and $_.Port -ne ""){
                        $Port = $_.Port
                    }
                }
            }
            if(!$Port -or $Port -eq 0){
                $Port = 22
            }

            # set servername
            $Servername = $Server.Name
            
            # set username
            if(!$User){$User = $Server.User}
             
            # set privatkey
            if(!$PrivatKey){$PrivatKey = Invoke-Expression ($Command = '"' + $Server.PrivatKey + '"')}
                            
    		#Set Protocol
            if($PrivatKey -eq ""){
                Invoke-Expression ("WinSCP scp://$User@$Servername" + ":$Port" + " /ini=$IniFile")
            }else{
                Invoke-Expression ("WinSCP scp://$User@$Servername :$SCPPort" + ":$Port /privatekey='$PrivatKey'" + " /ini=$IniFile")
            }    
        }
    }    
}