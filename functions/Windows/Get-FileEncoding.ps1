<#
$Metadata = @{
	Title = "Get File Encoding"
	Filename = "Get-FileEncoding.ps1"
	Description = ""
	Tags = ""
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2014-01-06"
	LastEditDate = "2014-01-06"
	Url = ""
	Version = "1.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Get-FileEncoding{

<#
.SYNOPSIS
    Gets file encoding.

.DESCRIPTION
	The Get-FileEncoding function determines encoding by looking at Byte Order Mark (BOM).

.PARAMETER Path
	Path of the File

.EXAMPLE
	PS C:\> Get-FileEncoding file.ps1

.EXAMPLE
	PS C:\> Get-ChildItem *.ps1 | select FullName, @{n='Encoding';e={Get-FileEncoding $_.FullName}} | where {$_.Encoding -ne 'ASCII'} | foreach {(get-content $_.FullName) | set-content $_.FullName -Encoding ASCII}

#>

    [CmdletBinding()]
    param(

        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [string]
        $Path
        
	)
  
    [byte[]]$byte = get-content -Encoding byte -ReadCount 4 -TotalCount 4 -Path $Path

    if($byte[0] -eq 0xef -and $byte[1] -eq 0xbb -and $byte[2] -eq 0xbf){ 
        Write-Output 'UTF8'
    }elseif($byte[0] -eq 0xfe -and $byte[1] -eq 0xff){
        Write-Output 'Unicode'
    }elseif($byte[0] -eq 0 -and $byte[1] -eq 0 -and $byte[2] -eq 0xfe -and $byte[3] -eq 0xff){
        Write-Output 'UTF32'
    }elseif($byte[0] -eq 0x2b -and $byte[1] -eq 0x2f -and $byte[2] -eq 0x76){
        Write-Output 'UTF7'
    }else{
        Write-Output 'ASCII'
    }
}