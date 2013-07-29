<#
$Metadata = @{
	Title = "PowerShell Object SharePoint List Item Size"
	Filename = "Object-SPListItemSize.ps1"
	Description = ""
	Tags = "powershell, function, sharepoint, object"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "www.janikvonrotz.ch"
	CreateDate = "2013-07-29"
	LastEditDate = "2013-07-29"
	Version = "1.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function New-SPListItemSize{
	param(
		$Website,
		$WebsiteUrl,
		$List,
		$ListUrl,
        $Item,
        $ItemUrl,
        $FileExtension,
        $FileSize
	)
	New-Object PSObject -Property @{
		Website = $Website
		WebsiteUrl = $WebsiteUrl
		List = $List
		ListUrl = $ListUrl
        Item = $Item
        ItemUrl = $ItemUrl
        FileExtension = $FileExtension
        FileSize  = $FileSize
	}
}