#--------------------------------------------------#
#  Title: Set Xml Configuration
#--------------------------------------------------#
#  File name: Set-XmlConfig.ps1
#  Description: [Description]
#  Tags: powershell, functions
#  Project: [Projectname]
#
#  Author: Janik von Rotz
#  Author E-Mail: contact@janikvonrotz.ch
#
#  Create Date: 18.02.2013
#  Last Edit Date: 18.02.2013
#  Version: 1.0.0
#
#  License:
#  This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
#  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
#  send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
#--------------------------------------------------#

function Set-XmlConfig {
	param (
		$Path
	)
	
	$xmlFile = [xml](get-content $path)
	return $xmlFile.Configuration
}