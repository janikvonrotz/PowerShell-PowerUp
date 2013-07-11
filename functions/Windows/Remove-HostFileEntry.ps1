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
	LastEditDate = "2013-07-10"
	Version = "1.0.0"
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
		[String]
		$IP,
        
		[String]
		$DNS
	)

    #--------------------------------------------------#
    # main
    #--------------------------------------------------#
    $HostFile = "$env:windir\System32\drivers\etc\hosts"
    $HostFileContent = get-content $HostFile
    $HostFileContentNew = @()
    $Modification = $false
    
    foreach($Line in $HostFilecontent){
        if($Line.StartsWith("#") -or $Line -eq ""){
        
            $HostFileContentNew += $Line			
        }else{                    

            $HostIP = ([regex]"(([2]([0-4][0-9]|[5][0-5])|[0-1]?[0-9]?[0-9])[.]){3}(([2]([0-4][0-9]|[5][0-5])|[0-1]?[0-9]?[0-9]))").match($Line).value
            $HostDNS = ($Line -replace $HostIP, "") -replace '\s+',""
            
            if($HostIP -eq $IP -or $HostDNS -eq $DNS){
			
                Write-Host "Remove host file entry: "$(if($IP){$IP + " "}else{})$(if($DNS){$DNS})
                $Modification = $true				
            }else{
                $HostFileContentNew += $Line
            }
        }    
    }
	
    if($Modification){
	
        Set-Content -Path $HostFile -Value $HostFileContentNew
    }else{
        throw "Couldn't find entry to remove in hosts file."
    }
}