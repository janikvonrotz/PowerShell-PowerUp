<#
$Metadata = @{
  Title = "Get Host File Entries"
	Filename = "Get-HostFileEntries.ps1"
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

function Get-HostFileEntries{

<#
.SYNOPSIS
    Get every entry from the hosts file.

.DESCRIPTION
	Extracts host entrys fromt the hosts file and shows them as a PowerShell object array.

.EXAMPLE
	PS C:\> Get-HostFileEntries
#>

<#
    [CmdletBinding()]
	param(
		[Parameter(Mandatory=$true)]
		[String]
		$Name
	)
#>

    #--------------------------------------------------#
    # main
    #--------------------------------------------------#
    $HostFileContent = get-content "$env:windir\System32\drivers\etc\hosts"
    $Entries = @()
    foreach($Line in $HostFilecontent){
        if(!$Line.StartsWith("#") -and $Line -ne ""){

            $IP = ([regex]"(([2]([0-4][0-9]|[5][0-5])|[0-1]?[0-9]?[0-9])[.]){3}(([2]([0-4][0-9]|[5][0-5])|[0-1]?[0-9]?[0-9]))").match($Line).value
            $DNS = ($Line -replace $IP, "") -replace  '\s+',""
            
            $Entry = New-ObjectHostFileEntry -IP $IP -DNS $DNS            
            $Entries += $Entry
        }    
    }
    if($Entries -ne $Null){
        $Entries
    }else{
        throw "No entries found in host file"
    }
}