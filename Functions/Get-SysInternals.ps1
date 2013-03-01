#--------------------------------------------------#
#  Title: Get SysInternals
#--------------------------------------------------#
#  File name: Get-SysInternals.ps1
#  Description: [Description]
#  Tags: powershell, functions
#  Project: [Projectname]
#
#  Author: Janik von Rotz
#  Author E-Mail: contact@janikvonrotz.ch
#
#  Create Date: 13.02.2013
#  Last Edit Date: 15.02.2013
#  Version: 1.0.1
#
#  License:
#  This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
#  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
#  send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
#--------------------------------------------------#

function Get-SysInternals {

	 # Settings
	param(
		[parameter(Mandatory=$false)]
		$Path = [string]$(Get-Location) + "\SysInternals\"
	)
	
	dir \\live.sysinternals.com\tools | foreach { 

		$localFile = join-path $Path $_.Name                  
		$exist = test-path $localFile

		$msgNew = "new utility found: $_.Name , downloading..."
		$msgUpdate = "file : $_.Name  is newer, updating..."
		$msgNoChange = "nothing changed for: $_.Name"			

		if($exist){

			if($_.lastWriteTime -gt (Get-Item $localFile).lastWriteTime)
			{
				Copy-Item $_.Fullname $Path -force
				Write-Host $msgUpdate -back yellow
			} 
			else 
			{
				Write-Host $msgNoChange
			}	
		}
		else
		{
			if($_.extension -eq ".exe")
			{
				Write-Host $msgNew -back green
			} 

			Copy-Item $_.Fullname $Path -force 
		}
	}
}