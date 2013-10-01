<#
$Metadata = @{
  Title = "Add Host File Entry"
	Filename = "Add-HostFileEntry.ps1"
	Description = ""
	Tags = "powershell, function, host, file, manipulation"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-07-10"
	LastEditDate = "2013-09-30"
	Version = "1.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Add-HostFileEntry{

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
		[Parameter(Mandatory=$true)]
		[String]
		$IP,
        
        [Parameter(Mandatory=$true)]
		[String]
		$DNS
	)

    #--------------------------------------------------#
    # main
    #--------------------------------------------------#
    $HostFile = "$env:windir\System32\drivers\etc\hosts"    
    
    [string]$LastLine = Get-Content $HostFile | select -Last 1
    
    if($IP -match [regex]"(([2]([0-4][0-9]|[5][0-5])|[0-1]?[0-9]?[0-9])[.]){3}(([2]([0-4][0-9]|[5][0-5])|[0-1]?[0-9]?[0-9]))"){    
    
        if(!(Get-HostFileEntries | where{$_.DNS -eq $DNS})){      
            
            if($LastLine -ne ""){
                Add-Content -Path $HostFile -Value "`n"
            }
                                             
            Write-Host "Add entry to hosts file: $IP`t$DNS"            
            Add-Content -Path $HostFile -Value "$IP    $DNS"
            
            # reformat hostfile
            Set-Content -Path $HostFile -Value (Get-Content -Path $HostFile | %{if($_.StartsWith("#") -or $_ -ne ""){$_}})                  

        }else{
            
            Write-Error "$DNS is already in use!"        
        }
            
    }else{
    
        Write-Error "IP address is not valid!"
    }
}