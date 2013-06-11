<#
$Metadata = @{
	Title = "PowerShell Object SharePoint Report Item"
	Filename = "Object-SPReportItem.ps1"
	Description = ""
	Tags = "powershell, function, sharepoint, object"
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

function New-ObjectSPReportItem {
    param(
        $Name,
        $Url,
        $Member,
        $Permission,
        $Type
    )
    New-Object PSObject -Property @{
        Name = $Name
        Url = $Url
        Member = $Member
        Permission = $Permission
        Type = $Type
    }
}