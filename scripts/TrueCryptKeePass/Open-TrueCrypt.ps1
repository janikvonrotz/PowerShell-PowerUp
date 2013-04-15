Param(
    # Open the KeePass Password safe in addition
    [switch]$OpenKeePass
)

$Metadata = @{
	Title = "Open TrueCrypt"
	Filename = "Open-TrueCrypt.ps1"
	Description = ""
	Tags = "powershell, truecrypt, keepass"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "www.janikvonrotz.ch"
	CreateDate = "2012-12-20"
	LastEditDate = "2013-04-10"
	Version = "3.0.1"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}

#--------------------------------------------------#
# Settings
#--------------------------------------------------#
$TrueCryptPath="C:\Program Files\TrueCrypt\TrueCrypt.exe"
$KeePassPath="C:\Program Files (x86)\KeePass Password Safe 2\KeePass.exe" 
$TrueCryptDataFile="\SkyDrive\Shared\Data\truecrypt\enc_cont"
$KeePassDataFile="\SkyDrive\Shared\Data\keepass\KeepassData.kdbx"
$KeePassKeyFile="\KeePass\keepass_data.key"
$d = Get-AvailableDriveLetter -FavoriteDriveLetter T

#--------------------------------------------------#
# Main
#--------------------------------------------------#

# Get the static path to the SkyDrive directory
$StaticPaht = [string]$(Get-Location) -replace "\\SkyDrive.*", ""

# Open the TrueCrypt file
& $TrueCryptPath /quit /auto /letter $d /volume ($StaticPaht + $TrueCryptDataFile)

# Open KeePass
if($OpenKeePass){
	$KeePassKeyFile = $d + ":" + $KeePassKeyFile
	& ($KeePassPath) ($StaticPaht + $KeePassDataFile) -preselect:$KeePassKeyFile
}

# Dismount the TrueCrypt file
Read-Host "`nPress any key to dismount the TrueCrypt drive"
& $TrueCryptPath /quit /dismount $d

# Wait a few second until the file is dismounted
Start-Sleep -s 3

# Change Timestamp of the TrueCrypt Container for SkyDrive Sync 
(dir ($StaticPaht + $TrueCryptDataFile)).lastwritetime = Get-Date
