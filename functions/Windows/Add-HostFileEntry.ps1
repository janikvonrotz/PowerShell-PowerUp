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
	LastEditDate = "2013-07-10"
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
    $LastLine = ($ContentFile | select -Last 1)
    
    if($IP -match [regex]"(([2]([0-4][0-9]|[5][0-5])|[0-1]?[0-9]?[0-9])[.]){3}(([2]([0-4][0-9]|[5][0-5])|[0-1]?[0-9]?[0-9]))"){    
    
        Write-Host "Add entry to hosts file: "$(if($IP){$IP + " "}else{})$(if($DNS){$DNS})        
        if($LastLine -ne "" -and  $LastLine -ne '\s+' -and $LastLine -ne $Null){Add-Content -Path $HostFile -Value "" -Encoding "Ascii"}        
        Add-Content -Path $HostFile -Value ($IP + "       " + $DNS) -Encoding "Ascii"
    }
}