function Set-JsonConfig {
	#--------------------------------------------------#
	# Parameter
	#--------------------------------------------------#
	param (
		[parameter(Mandatory=$true)]
		$Path,
		[parameter(Mandatory=$true)]
		$Configuration
	)
	
	$Metadata = @{
		Title = "Set Json Configuration"
		Filename = "Set-JsonConfig.ps1"
		Description = ""
		Tags = "powershell, functions"
		Project = ""
		Author = "Janik von Rotz"
		AuthorEMail = "contact@janikvonrotz.ch"
		CreateDate = "2013-03-12"
		LastEditDate = "2013-03-28"
		Version = "1.0.0"
		License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
	}
	
	#--------------------------------------------------#
	# Main
	#--------------------------------------------------#
	$z = "`n"
	$Content = $Configuration | ConvertTo-Json
	$Content = ('$Content = @"' + $z + $Content + $z + '"@')
	$Content > $Path
	
}