param(
	[string]$Version,
	[string]$Path,
	[switch]$Force,
	$Update,
	[switch]$Uninstall
)

#--------------------------------------------------#
# settings
#--------------------------------------------------#

$Configs = @{
	Url = "http://skylink.dl.sourceforge.net/project/sevenzip/7-Zip/9.20/7z920.exe","http://downloads.sourceforge.net/sevenzip/7za920.zip"
    Path = "$(Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)\"
}
$Configs | ForEach-Object{

    try{

        $_.Result = $null
        if(-not $_.Path){$_.Path = $Path}
        $Config = $_

        #--------------------------------------------------#
        # add app
        #--------------------------------------------------#

        if(-not $Uninstall){

            #--------------------------------------------------#
            # check condition
            #--------------------------------------------------#

            if($_.ConditionExclusion){            
                $_.ConditionExclusionResult = $(Invoke-Expression $Config.ConditionExclusion -ErrorAction SilentlyContinue)        
            }    
            if(($_.ConditionExclusionResult -eq $null) -or $Force){
                    	
                #--------------------------------------------------#
                # download
                #--------------------------------------------------#

                $_.Downloads = $_.Url | ForEach-Object{
                    Get-File -Url $_ -Path $Config.Path
                }       			

                #--------------------------------------------------#
                # installation
                #--------------------------------------------------#

                $_.Downloads | where{$_.Filename -eq "7z920.exe"} | ForEach-Object{
                    Start-Process -FilePath $(Join-Path $_.Path $_.Filename) -ArgumentList "/S" -Wait -NoNewWindow
                }
                		
                #--------------------------------------------------#
                # configuration
                #--------------------------------------------------#	

                # extract command line tool and create bat
                $WorkingPath = (Get-Location).Path
                Set-Location "C:\Program Files (x86)\7-Zip\"
                $_.Downloads | where{$_.Filename -eq "7za920.zip"} | ForEach-Object{
                    Start-Process -FilePath "C:\Program Files (x86)\7-Zip\7z.exe" -ArgumentList "e $(Join-Path $_.Path $_.Filename) -y" -Wait -NoNewWindow
                }
                Set-EnvironmentVariableValue -Name "Path" -Value ";C:\Program Files (x86)\7-Zip\" -Target "Machine" -Add                
                Set-Location $WorkingPath
                      
                #--------------------------------------------------#
                # cleanup
                #--------------------------------------------------#

                $_.Downloads | ForEach-Object{
                    Remove-Item $(Join-Path $_.Path $_.Filename)
                }
                		
                #--------------------------------------------------#
                # finisher
                #--------------------------------------------------#
                		
                if($Update){$_.Result = "AppUpdated";$_
                }else{$_.Result = "AppInstalled";$_}
            		
            #--------------------------------------------------#
            # condition exclusion
            #--------------------------------------------------#
            		
            }else{
            	
                $_.Result = "ConditionExclusion";$_
            }

        #--------------------------------------------------#
        # remove app
        #--------------------------------------------------#
        	
        }else{

            if(Test-Path (Join-Path $PSbin.Path "7za.bat")){Remove-Item (Join-Path $PSbin.Path "7za.bat")}
            
            $Executable = "C:\Program Files (x86)\7-Zip\Uninstall.exe"; if(Test-Path $Executable){Start-Process -FilePath $Executable -ArgumentList "/S" -Wait -NoNewWindow}
            
            $Folder = "C:\Program Files (x86)\7-Zip\"; if(Test-Path $Folder){Remove-Item -Path $Folder -Force -Recurse}
            
            Remove-EnvironmentVariableValue -Name Path -Value ";C:\Program Files (x86)\7-Zip\" -Target Machine
            
            $_.Result = "AppUninstalled";$_
        }

    #--------------------------------------------------#
    # catch error
    #--------------------------------------------------#

    }catch{

        $Config.Result = "Error";$Config
    }
}