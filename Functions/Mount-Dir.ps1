function Mount-Dir{
    #--------------------------------------------------#
    # Parameter
    #--------------------------------------------------#
    param(
        [parameter(Mandatory=$true)]
        [string[]] 
        $Paths
    )
	$Metadata = @{
		Title = "Mount Directory"
		Filename = "Mount-Dir.ps1"
		Description = ""
		Tags = "powershell, function, mount, subst"
		Project = ""
		Author = "Janik von Rotz"
		AuthorContact = "www.janikvonrotz.ch"
		CreateDate = "2013-03-12"
		LastEditDate = "2013-03-12"
		Version = "1.0.0"
		License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}

<#
#--------------------------------------------------#
# Example
#--------------------------------------------------#

Mount-Dir -Path "C:\FolderXY"
Mount-Dir -Path @("C:\FolderXY", "D:\")

#>

    #--------------------------------------------------#
    # Main
    #--------------------------------------------------#
    if (Get-Command "subst.exe"){
        $DriveLetters = Get-AvailableDriveLetter
        foreach($Path in $Paths){
            $Index =  [array]::IndexOf($Paths, $Path)
            $DriveLetter = $DriveLetters[$Index] + ":"
            Try{
                & subst $DriveLetter $Path
            }Catch{
            }Finally{
                Write-Host "Path " -nonewline; Write-Host $Path  -BackgroundColor Yellow -ForegroundColor Black -nonewline; Write-Host " mounted to " -nonewline; Write-Host $DriveLetter  -BackgroundColor Yellow -ForegroundColor Black
            }
        }

        Read-Host "To dismount press Enter"
    
        foreach($Path in $Paths){
            $Index =  [array]::IndexOf($Paths, $Path)
            $DriveLetter = $DriveLetters[$Index] + ":"
            Try{
                & subst /D $DriveLetter
            }Catch{
            }Finally{
                Write-Host "Dismounted drive " -nonewline; Write-Host $DriveLetter  -BackgroundColor Yellow -ForegroundColor Black
            }
        }
    }else{
        throw "Subst command is not available"
    }
        
}