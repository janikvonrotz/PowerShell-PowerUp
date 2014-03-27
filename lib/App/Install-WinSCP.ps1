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
	Url = "http://winscp.net/download/files/201403251903506874a91aaeb8917511fc5b5e3a4342/winscp552setup.exe"
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
                    Start-Process -FilePath $(Join-Path $_.Path $_.Filename) -ArgumentList "/VERYSILENT /NORESTART" -Wait
                }
                		
                #--------------------------------------------------#
                # configuration
                #--------------------------------------------------#	

                $Executable = "C:\Program Files (x86)\WinSCP\WinSCP.exe";if(Test-Path $Executable){Set-Content -Path (Join-Path $PSbin.Path "WinSCP.bat") -Value "@echo off`nstart `"`" `"$Executable`" %*"}
                                
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

            if(Test-Path (Join-Path $PSbin.Path "WinSCP.bat")){Remove-Item (Join-Path $PSbin.Path "WinSCP.bat")}
            
            $Executable = "C:\Program Files (x86)\WinSCP\unins000.exe"; if(Test-Path $Executable){Start-Process -FilePath $Executable -ArgumentList "/VERYSILENT" -Wait}
            
            $_.Result = "AppUninstalled";$_
        }

    #--------------------------------------------------#
    # catch error
    #--------------------------------------------------#

    }catch{

        $Config.Result = "Error";$Config
    }
}