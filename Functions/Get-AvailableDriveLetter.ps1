#--------------------------------------------------#
#  Title: Get Available Drive Letter
#--------------------------------------------------#
#  File name: Get-AvailableDriveLetter.ps1
#  Description: [Description]
#  Tags: powershell, functions
#  Project: [Projectname]
#
#  Author: Janik von Rotz
#  Author E-Mail: contact@janikvonrotz.ch
#
#  Create Date: 11.02.2013
#  Last Edit Date: 11.02.2013
#  Version: 1.0.0
#
#  License:
#  This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
#  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
#  send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
#--------------------------------------------------#

Function Get-AvailableDriveLetter {

	param(
		[parameter(Mandatory=$False)]
		[Switch]
		$ReturnFirstLetterOnly
	)
	 
    $TempDriveLetters = [char[]]'CDEFGHIJKLMNOPQRSTUVWXYZ' | ? { (Get-PSDrive $_ -ErrorAction 'SilentlyContinue') -eq $null }

	if ($ReturnFirstLetterOnly -eq $true)
	{
		$TempDriveLetters[0]
	}
	else
	{
		$TempDriveLetters
	}
	
}