<#
$Metadata = @{
	Title = "PowerShell Object Remote Connection"
	Filename = "Object-RemoteConnection.ps1"
	Description = ""
	Tags = "powershell, function, object"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "www.janikvonrotz.ch"
	CreateDate = "2013-06-11"
	LastEditDate = "2013-06-11"
	Version = "1.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function New-ObjectRemoteConnection{
    param(
        [string]$Name,
        [string]$Server,
        [string]$User,
        [string]$Description,
        [string]$SnapIns,
		[string]$PrivatKey
    )
    New-Object PSObject -Property @{
        Name = $Name
        Server = $Server
        User = $User
        Description = $Description
        SnapIns = $SnapIns
		PrivatKey = $PrivatKey
    }
}