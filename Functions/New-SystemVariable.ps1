#--------------------------------------------------#
#  Title: New System Variable
#--------------------------------------------------#
#  File name: New-SystemVariable.ps1
#  Description: [Description]
#  Tags: powershell, functions
#  Project: [Projectname]
#
#  Author: Janik von Rotz
#  Author E-Mail: contact@janikvonrotz.ch
#
#  Create Date: 13.02.2013
#  Last Edit Date: 15.02.2013
#  Version: 1.0.0
#
#  License:
#  This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
#  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
#  send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
#--------------------------------------------------#

function New-SystemVariable{
	
	param(
		[parameter(Mandatory=$true)]
		[string]$Path,
		[parameter(Mandatory=$true)]
		[string]$Name
	)
	
	switch ($Name) 
    {
		"Path" {if(!($Env:Path.contains($Path))){$Env:Path+=(";"+$Path)}}
		"PSModulePath" {if(!($Env:PSModulePath.contains($Path))){$Env:PSModulePath+=(";"+$Path)}}
		default {Write-Error -Message "Variable not supported by the function" }
	}
}
