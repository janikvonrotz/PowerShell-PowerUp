#--------------------------------------------------#
#  Title: Get Logstamp
#--------------------------------------------------#
#  File name: Get-LogStamp.ps1
#  Description: [Description]
#  Tags: powershell, functions
#  Project: [Projectname]
#
#  Author: Janik von Rotz
#  Author E-Mail: contact@janikvonrotz.ch
#
#  Create Date: 02.01.2012
#  Last Edit Date: 28.02.2013
#  Version: 1.0.2
#
#  License:
#  This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
#  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
#  send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
#--------------------------------------------------#

Function Get-LogStamp {
	$now = get-Date
	$yr = $now.Year.ToString()
	$mo = $now.Month.ToString()
	$dy = $now.Day.ToString()
	$hr = $now.Hour.ToString()
	$mi = $now.Minute.ToString()
	$se = $now.Second.ToString()
	if ($mo.length -lt 2) {
		$mo  =  "0"+$mo
	}
	if ($dy.length -lt 2) {
		$dy = "0"+$dy
	}
	if ($hr.length -lt 2) {
		$hr = "0"+$hr
	}
	if ($mi.length -lt 2) {
		$mi = "0"+$mi
	}
	if ($se.length -lt 2) {
		$se = "0"+$se
	}
	write-output $yr-$mo-$dy-$hr-$mi-$se
}