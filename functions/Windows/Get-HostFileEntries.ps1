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
	LastEditDate = "2013-09-30"
	Version = "1.1.0"
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
    
.PARAMETER  IP
	Filter IP or DNS.

.EXAMPLE
	PS C:\> Get-HostFileEntries
    
.EXAMPLE
	PS C:\> Get-HostFileEntries -Filter "domain"
#>


    [CmdletBinding()]
	param(
		[Parameter(Mandatory=$false)]
		[String]
		$Filter
	)


    #--------------------------------------------------#
    # main
    #--------------------------------------------------#

    $Entries = $(get-content "$env:windir\System32\drivers\etc\hosts") | %{
    
        if(!$_.StartsWith("#") -and $_ -ne ""){

            $IP = ([regex]"(([2]([0-4][0-9]|[5][0-5])|[0-1]?[0-9]?[0-9])[.]){3}(([2]([0-4][0-9]|[5][0-5])|[0-1]?[0-9]?[0-9]))").match($_).value
            $DNS = ($_ -replace $IP, "") -replace  '\s+',""
            
            if($Filter -and (($IP -match $Filter) -or ($DNS -match $Filter))){
                
                New-ObjectHostFileEntry -IP $IP -DNS $DNS
                
            }elseif($Filter -eq ""){
            
                New-ObjectHostFileEntry -IP $IP -DNS $DNS
            }
        }  
    } 
    
    if($Entries -ne $Null){                
        $Entries      
    }else{
        Write-Error "No entries found in host file"
    }
}