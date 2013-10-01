<#
$Metadata = @{
  Title = "Remove Host File Entry"
	Filename = "Remove-HostFileEntry.ps1"
	Description = ""
	Tags = "powershell, function, host, file, manipulation"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-07-10"
	LastEditDate = "2013-09-30"
	Version = "1.1.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Remove-HostFileEntry{

<#
.SYNOPSIS
    Add an new entry to the hosts file

.DESCRIPTION
	Add an new entry the hosts file.

.PARAMETER  IP
	IP address

.PARAMETER  DNS
	DNS address

.EXAMPLE
	PS C:\> Get-HostFileEntry -IP "192.168.50.4" -DNS "local.wordpress.dev"
#>

    [CmdletBinding()]
	param(
		[Parameter(Mandatory=$false)]
		[String]
		$IP,
        
        [Parameter(Mandatory=$false)]
		[String]
		$DNS
	)

    #--------------------------------------------------#
    # main
    #--------------------------------------------------#
    $HostFile = "$env:windir\System32\drivers\etc\hosts"
    
    get-content $HostFile | %{
        if($_.StartsWith("#") -or $_ -eq ""){
        
            $Content += $_ + "`n"
            			
        }else{                    

            $HostIP = ([regex]"(([2]([0-4][0-9]|[5][0-5])|[0-1]?[0-9]?[0-9])[.]){3}(([2]([0-4][0-9]|[5][0-5])|[0-1]?[0-9]?[0-9]))").match($_).value
            $HostDNS = ($_ -replace $HostIP, "") -replace '\s+',""
            
            if($HostIP -eq $IP -or $HostDNS -eq $DNS){
			
                Write-Host "Remove host file entry: "$(if($IP){$IP + " "}else{})$(if($DNS){$DNS})
                				
            }else{
            
                $Content += $_ + "`n"
            }
        }    
    }	
    
    Set-Content -Path $HostFile -Value $Content
    # reformat hostfile
    Set-Content -Path $HostFile -Value (Get-Content -Path $HostFile | %{if($_.StartsWith("#") -or $_ -ne ""){$_}})   
}
