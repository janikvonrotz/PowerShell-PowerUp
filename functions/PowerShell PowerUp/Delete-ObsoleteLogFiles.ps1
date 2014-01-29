<#
$Metadata = @{
    Title = "Delete Obsolete Log Files"
    Filename = "Delete-ObsoleteLogFiles.ps1"
    Description = ""
    Tags = "powershell, delete, obsolete, log , files"
    Project = ""
    Author = "Janik von Rotz"
    AuthorContact = "http://janikvonrotz.ch"
    CreateDate = "2013-08-27"
    LastEditDate = "2014-01-29"
    Url = ""
    Version = "1.0.1"
    License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Delete-ObsoleteLogFiles{
	#--------------------------------------------------#
	# main
	#--------------------------------------------------#

	# declaration
	$Features = @()

	# load feature configuration from config files
	Get-ChildItem -Path $PSconfigs.Path -Filter $PSconfigs.Profile.Filter -Recurse | 
		%{
			[xml]$(Get-Content $_.fullname) | 
			%{
				$Features += $_.Content.Feature | where{$_.Name -eq "Log File Retention"}
			}
		}

	# get max values
	$Features | %{$Days += $_.Days};$Days = ($Days | Measure-Object -Maximum).Maximum
	$Features | %{$MaxFilesToKeep += $_.MaxFilesToKeep};$MaxFilesToKeep = ($MaxFilesToKeep | Measure-Object -Maximum).Maximum

	if($Days){        
		Get-Childitem $PSlogs.Path | where{-not $_.PsIsContainer} | sort CreationTime -Descending | where{$_.Name.EndsWith("txt")} | where{$_.LastWriteTime -le $(Get-Date).AddDays(-$Days)} | Remove-Item -Force
	}

	if($MaxFilesToKeep){
		Get-Childitem $PSlogs.Path | where{-not $_.PsIsContainer} | sort CreationTime -Descending | where{$_.Name.EndsWith("txt")} | select -Skip $MaxFilesToKeep | Remove-Item -Force
	}
}