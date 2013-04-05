function Get-LogStamp {
	$Metadata = @{
		Title = "Get Logstamp"
		Filename = "Get-LogStamp.ps1"
		Description = ""
		Tags = "powershell, functions"
		Project = ""
		Author = "Janik von Rotz"
		AuthorContact = "www.janikvonrotz.ch"
		CreateDate = "2013-01-02"
		LastEditDate = "2013-03-25"
		Version = "1.0.1"
		License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
	return $(Get-Date -Format "yyyy-MM-dd HH-mm-ss")
}