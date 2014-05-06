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
	Url = "http://sourceforge.net/projects/cpuminer/files/pooler-cpuminer-2.3.3-win64.zip"
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
				
				$Directory = "C:\Program Files\cpuminer\"; if(-not (Test-Path -Path $Directory)){New-Item -Path $Directory -Type directory}

				$_.Downloads | ForEach-Object{
                    Unzip-File -File $(Join-Path $_.Path $_.Filename) -Destination $Directory
                }
                		
                #--------------------------------------------------#
                # configuration
                #--------------------------------------------------#	

                $Executable = "C:\Program Files\cpuminer\minerd.exe";if(Test-Path $Executable){Set-Content -Path (Join-Path $PSbin.Path "minerd.bat") -Value "@echo off`nstart `"`" `"$Executable`" %*"}
				
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
		
            if(Test-Path (Join-Path $PSbin.Path "minerd.bat")){Remove-Item (Join-Path $PSbin.Path "minerd.bat")}
            
			$Directory = "C:\Program Files\cpuminer\"; if(Test-Path $Directory){Remove-Item -Path $Directory -Force -Recurse}
                            
            $_.Result = "AppUninstalled";$_
        }

    #--------------------------------------------------#
    # catch error
    #--------------------------------------------------#

    }catch{

        $Config.Result = "Error";$Config
    }
}