<#
$Metadata = @{
	Title = "Connect SSH Session"
	Filename = "Connect-SSH.ps1"
	Description = ""
	Tags = "powershell, remote, session, ssh"
	Project = ""
	Author = "Janik von Rotz"
    AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-05-17"
    LastEditDate = "2014-03-06"
	Version = "3.1.2"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Connect-SSH{

<#
.SYNOPSIS
    Remote management for ssh sessions.

.DESCRIPTION
    Starts a ssh session with the parameters from the remote config file.

.PARAMETER  Name
    Server names from the remote config file.

.PARAMETER  User
    Username (overwrites remote config file parameter).

.PARAMETER  Port
    Port (overwrites remote config file parameter).
  
.PARAMETER  PrivatKey
    PrivatKey (overwrites remote config file parameter).
    
.EXAMPLE
    Connect-SSH -Name firewall
#>

	#--------------------------------------------------#
	# Parameter
	#--------------------------------------------------#
	param (
        [parameter(Mandatory=$true)]
        [string[]]$Name,
        
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
    if (Get-Command "putty"){ 
    
        # Load Configurations
		$Servers = Get-RemoteConnection -Name $Name        
        
        if(!(Get-ChildItem -Path $PSconfigs.Path -Filter $PStemplates.WinSCP.Name -Recurse)){
        
            Write-Host "Copy $($PStemplates.WinSCP.Name) file to the config folder"        
    		Copy-Item -Path $PStemplates.WinSCP.FullName -Destination (Join-Path -Path $PSconfigs.Path -ChildPath $PStemplates.WinSCP.Name)
    	} 
    
        $IniFile = $(Get-ChildItem -Path $PSconfigs.Path -Filter $PStemplates.WinSCP.Name -Recurse).FullName

        $Servers | %{
    		
            # get port from Protocol
            if(!$Port){
                $Server.Protocol | %{if($_.Name -eq "ssh" -and $_.Port -ne ""){$Port = $_.Port}}
            }
            if(!$Port -or $Port -eq 0){
                $Port = 22
            }

            # set servername
            $Servername = $_.Name
            
            # set username
            if(!$User){$User = $_.User}
             
            # set privatkey
            if(!$PrivatKey){$PrivatKey = Invoke-Expression ($Command = '"' + $_.PrivatKey + '"')}
                        
            if($PrivatKey -eq ""){
                Invoke-Expression "putty $User@$Servername -P $Port -ssh" 
            }else{
                Invoke-Expression "putty $User@$Servername -P $Port -ssh -i '$PrivatKey'" 
            }
        }
    }
}