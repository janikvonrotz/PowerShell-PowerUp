$Metadata = @{
	Title = "Backup Script"
	Filename = "Backup.ps1"
	Description = ""
	Tags = ""
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "www.janikvonrotz.ch"
	CreateDate = "2013-01-20"
	LastEditDate = "2013-02-15"
	Version = "1.0.1"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@

}

$AllDrive = get-PSDrive
$TargetFolder = "lwd"
$SourceFolder = "D:\"

foreach ($Drive in $AllDrive)
{
	if (Test-Path ($Drive.Root + $TargetFolder))
	{
		$TargetDrive = $Drive.Root
        Break
	}
}

$Null = Read-Host ("Copy from " + $SourceFolder + " to " + ($TargetDrive + $TargetFolder))
& Robocopy $SourceFolder ($TargetDrive + $TargetFolder) /MIR /R:1 /W:0