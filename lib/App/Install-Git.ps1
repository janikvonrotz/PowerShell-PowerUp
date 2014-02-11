param(
	[string]$Version,
	[string]$Path,
	[switch]$Force,
	[switch]$Update,
	[switch]$Uninstall
)

#--------------------------------------------------#
# settings
#--------------------------------------------------#

$Configs = @{
	Url = "https://msysgit.googlecode.com/files/Git-1.8.5.2-preview20131230.exe"
	Path = "$(Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)\"
	ConditionExclusion = "Get-Command `"git`" -ErrorAction SilentlyContinue"
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
                    Start-Process -FilePath $(Join-Path $_.Path $_.Filename) -ArgumentList "/Silent" -Wait -NoNewWindow
                }
                		
                #--------------------------------------------------#
                # configuration
                #--------------------------------------------------#	

                Set-EnvironmentVariableValue -Name "Path" -Value "C:\Program Files\Example\bin" -Target "Machine" -Add
                
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
            
            $_.Result = "AppUninstalled";$_
        }

    #--------------------------------------------------#
    # catch error
    #--------------------------------------------------#

    }catch{

        $Config.Result = "Error";$Config
    }
}