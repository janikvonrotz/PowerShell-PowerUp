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
	Url = "http://c758482.r82.cf2.rackcdn.com/Sublime%20Text%202.0.2%20Setup.exe"
    Path = "$(Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)\"
    Executable = "C:\Program Files (x86)\Sublime Text 2\sublime_text.exe"
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
				
                $_.Downloads | ForEach-Object{
                    Start-Process -FilePath $(Join-Path $_.Path $_.Filename) -ArgumentList "/VERYSILENT /NORESTART" -Wait -NoNewWindow
                }
                		
                #--------------------------------------------------#
                # configuration
                #--------------------------------------------------#	
                
                if(Test-Path $_.Executable){Set-Content -Path (Join-Path $PSbin.Path "sublime_text.bat") -Value "@echo off`nstart `"`" `"$($_.Executable)`" %*"}
                                        
                Set-Content -Path (Join-Path $_.Path "Sublime Text 2 Context Add.bat") -Value @"
rem add it for all file types
reg add "HKEY_CLASSES_ROOT\*\shell\Open with Sublime Text 2" /t REG_SZ /v "" /d "Open with Sublime Text 2" /f
reg add "HKEY_CLASSES_ROOT\*\shell\Open with Sublime Text 2" /t REG_EXPAND_SZ /v "Icon" /d "$($_.Executable),0" /f
reg add "HKEY_CLASSES_ROOT\*\shell\Open with Sublime Text 2\command" /t REG_SZ /v "" /d "$($_.Executable) \"%%1\"" /f

rem add it for folders
reg add "HKEY_CLASSES_ROOT\Folder\shell\Open with Sublime Text 2" /t REG_SZ /v "" /d "Open with Sublime Text 2"   /f
reg add "HKEY_CLASSES_ROOT\Folder\shell\Open with Sublime Text 2" /t REG_EXPAND_SZ /v "Icon" /d "$($_.Executable),0" /f
reg add "HKEY_CLASSES_ROOT\Folder\shell\Open with Sublime Text 2\command" /t REG_SZ /v "" /d "$($_.Executable) \"%%1\"" /f
"@
                & (Join-Path $_.Path "Sublime Text 2 Context Add.bat") | out-null
                          
                #--------------------------------------------------# 
                # cleanup
                #--------------------------------------------------#

                $_.Downloads | ForEach-Object{
                    Remove-Item (Join-Path $_.Path $_.Filename) -Force
                }
                Remove-Item (Join-Path $_.Path "Sublime Text 2 Context Add.bat") -Force
                		
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
		
            if(Test-Path (Join-Path $PSbin.Path "sublime_text.bat")){Remove-Item (Join-Path $PSbin.Path "sublime_text.bat")}
            
            $Executable = "C:\Program Files (x86)\Sublime Text 2\unins000.exe"; if(Test-Path $Executable){Start-Process -FilePath $Executable -ArgumentList "/VERYSILENT /NORESTART" -Wait -NoNewWindow}
			
            Set-Content -Path (Join-Path $_.Path "Sublime Text 2 Context Remove.bat") -Value @"
rem remove for all file types
reg delete "HKEY_CLASSES_ROOT\*\shell\Open with Sublime Text 2" /f

rem remove for folders
reg delete "HKEY_CLASSES_ROOT\Folder\shell\Open with Sublime Text 2" /f
"@
            & (Join-Path $_.Path "Sublime Text 2 Context Remove.bat") | out-null
            
            Remove-Item (Join-Path $_.Path "Sublime Text 2 Context Remove.bat") -Force
            
            $_.Result = "AppUninstalled";$_
        }

    #--------------------------------------------------#
    # catch error
    #--------------------------------------------------#

    }catch{

        $Config.Result = "Error";$Config
    }
}