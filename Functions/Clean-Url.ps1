
$Metadata = @{
	Title = "Clean Url"
	Filename = "Clean-Url.ps1"
	Description = ""
	Tags = "powershell, functions"
	Project = ""
	Author = "Janik von Rotz"
	AuthorEMail = "contact@janikvonrotz.ch"
	CreateDate = "2013-03-13"
	LastEditDate = "2013-03-13"
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
 
$CleanUrl = Clean-Url "http://sharepoint.vbl.ch/Direktion/Erweiterte%20Gesch%c3%a4ftsleitung/SitePages/Homepage.aspx"
 
#>
 
function Clean-Url{
    param(
        [parameter(Mandatory=$true)]
        [String]
	    $Url
    )
    #--------------------------------------------------#
    # Main
    #--------------------------------------------------#
    $Url = $Url.replace("%20", " ")
    $Url = $Url.replace("%C3%84", "Ä")
    $Url = $Url.replace("%c3%a4", "ä")
    $Url = $Url.replace("%C3%B6", "ö")
    $Url = $Url.replace("%C3%96", "Ö")
    $Url = $Url.replace("%C3%BC", "ü")
    $Url = $Url.replace("%C3%9C", "Ü")
    return $Url
}
Clean-Url "http://sharepoint.vbl.ch/Direktion/Erweiterte%20Gesch%c3%a4ftsleitung/SitePages/Homepage.aspx"