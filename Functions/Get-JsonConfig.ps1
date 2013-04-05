function Get-JsonConfig {
	param (
        [parameter(Mandatory=$true)]
		$Path
	)
	
	$Metadata = @{
		Title = "Get Json Configuration"
		Filename = "Get-JsonConfig.ps1"
		Description = ""
		Tags = "powershell, functions"
		Project = ""
		Author = "Janik von Rotz"
		AuthorContact = "www.janikvonrotz.ch"
		CreateDate = "2013-02-18"
		LastEditDate = "2013-03-12"
		Version = "1.0.1"
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
		
	$Config = Get-JsonConfig -Path ".\Create-PSSession.config.json.ps1" 
	
	#>
	
	#Import
    $Content = &($Path)
	return $Configuration = ($Content | ConvertFrom-Json)
}