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
	Url = "http://the.earth.li/~sgtatham/putty/latest/x86/putty-0.63-installer.exe"
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

                $_.Downloads | ForEach-Object{
                    Start-Process -FilePath $(Join-Path $_.Path $_.Filename) -ArgumentList "/verysilent" -Wait
                }
                		
                #--------------------------------------------------#
                # configuration
                #--------------------------------------------------#	

                $Executable = "C:\Program Files (x86)\PuTTY\pageant.exe";if(Test-Path $Executable){Set-Content -Path (Join-Path $PSbin.Path "pageant.bat") -Value "@echo off`nstart `"`" `"$Executable`" %*"}
                $Executable = "C:\Program Files (x86)\PuTTY\plink.exe";if(Test-Path $Executable){Set-Content -Path (Join-Path $PSbin.Path "plink.bat") -Value "@echo off`nstart `"`" `"$Executable`" %*"}
				$Executable = "C:\Program Files (x86)\PuTTY\pscp.exe";if(Test-Path $Executable){Set-Content -Path (Join-Path $PSbin.Path "pscp.bat") -Value "@echo off`nstart `"`" `"$Executable`" %*"}
				$Executable = "C:\Program Files (x86)\PuTTY\psftp.exe";if(Test-Path $Executable){Set-Content -Path (Join-Path $PSbin.Path "psftp.bat") -Value "@echo off`nstart `"`" `"$Executable`" %*"}
				$Executable = "C:\Program Files (x86)\PuTTY\putty.exe";if(Test-Path $Executable){Set-Content -Path (Join-Path $PSbin.Path "putty.bat") -Value "@echo off`nstart `"`" `"$Executable`" %*"}
				$Executable = "C:\Program Files (x86)\PuTTY\puttygen.exe";if(Test-Path $Executable){Set-Content -Path (Join-Path $PSbin.Path "puttygen.bat") -Value "@echo off`nstart `"`" `"$Executable`" %*"}
                
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

            if(Test-Path (Join-Path $PSbin.Path "pageant.bat")){Remove-Item (Join-Path $PSbin.Path "pageant.bat")}
			if(Test-Path (Join-Path $PSbin.Path "plink.bat")){Remove-Item (Join-Path $PSbin.Path "plink.bat")}
			if(Test-Path (Join-Path $PSbin.Path "pscp.bat")){Remove-Item (Join-Path $PSbin.Path "pscp.bat")}
			if(Test-Path (Join-Path $PSbin.Path "psftp.bat")){Remove-Item (Join-Path $PSbin.Path "psftp.bat")}
			if(Test-Path (Join-Path $PSbin.Path "putty.bat")){Remove-Item (Join-Path $PSbin.Path "putty.bat")}
			if(Test-Path (Join-Path $PSbin.Path "puttygen.bat")){Remove-Item (Join-Path $PSbin.Path "puttygen.bat")}
			
            $Executable = "C:\Program Files (x86)\PuTTY\unins000.exe"; if(Test-Path $Executable){Start-Process -FilePath $Executable -ArgumentList "/verysilent" -Wait}
            
            $_.Result = "AppUninstalled";$_
        }

    #--------------------------------------------------#
    # catch error
    #--------------------------------------------------#

    }catch{

        $Config.Result = "Error";$Config
    }
}