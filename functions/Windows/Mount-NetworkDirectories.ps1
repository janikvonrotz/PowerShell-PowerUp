<#
$Metadata = @{
  Title = "Mount Network Directories"
	Filename = "Mount-NetworkDirectories.ps1"
	Description = ""
	Tags = "powershell, windows, function"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-07-09"
	LastEditDate = "2013-07-09"
	Version = "1.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Mount-NetworkDirectories{

<#
.SYNOPSIS
	Mount multiple network directories

.DESCRIPTION
	Mount multiple network directories f.e. a SharePoint library folder. This function is a wrapper for the net use command.

.PARAMETER  Urls
	FQDN of the network ressource.

.EXAMPLE
	PS C:\> Mount-NetworkDirectories "http://sharepoint.local.ch/Vertragsmanagement","http://sharepoint.local.ch/Projects"

#>
	

    param(
        [parameter(Mandatory=$true)]
        [string[]] 
        $Urls
    )
	
    #--------------------------------------------------#
    # main
    #--------------------------------------------------#
    if (Get-Command "net.exe"){
	
        $DriveLetters = Get-AvailableDriveLetter

        foreach($Url in $Urls){
        
            $Index =  [array]::IndexOf($Urls, $Url)

            $DriveLetter = $DriveLetters[$Index] + ":"

            Write-Host "Mount url:" $Url "to:" $DriveLetter

            & net use $DriveLetter $Url            
        }

        Read-Host "To dismount press Enter"

        foreach($Url in $Urls){

            $Index =  [array]::IndexOf($Urls, $Url)

            $DriveLetter = $DriveLetters[$Index] + ":"

            Write-Host "Dismount drive" $DriveLetter

            & net use $DriveLetter /Delete 
        }        
        
    }else{

        throw "net command is not available"

    }        
}

Mount-NetworkDirectories -Urls "http://sharepoint.vbl.ch/Vertragsmanagement/Freigegebene Dokumente/S-Pos","http://sharepoint.vbl.ch/Kommunikation/Allgemein"