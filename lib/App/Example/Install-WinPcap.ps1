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
	Url = "http://www.winpcap.org/install/bin/WinPcap_4_1_3.exe"
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
                    Start-Process -FilePath $(Join-Path $_.Path $_.Filename) -ArgumentList "" -Wait -NoNewWindow
                }						
	
                #--------------------------------------------------#
                # configuration
                #--------------------------------------------------#	

                #--------------------------------------------------#
                # cleanup
                #--------------------------------------------------#

                $_.Downloads | ForEach-Object{
                    Remove-Item (Join-Path $_.Path $_.Filename) -Force
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
            
            $Executable = "C:\Program Files (x86)\WinPcap\Uninstall.exe"; if(Test-Path $Executable){Start-Process -FilePath $Executable -ArgumentList "" -Wait -NoNewWindow}
            
            $_.Result = "AppUninstalled";$_
        }

    #--------------------------------------------------#
    # catch error
    #--------------------------------------------------#

    }catch{

        $Config.Result = "Error";$Config
    }
}