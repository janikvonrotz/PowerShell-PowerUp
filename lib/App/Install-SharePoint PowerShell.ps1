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
	Url = "http://download-codeplex.sec.s-msft.com/Download/Release?ProjectName=sharepointpowershell&DownloadId=804498&FileTime=130375715187500000&Build=20865"
	Path = "$((Get-Location).Path)\" # $Path
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
                    Get-File -Url $_ -Path (Join-Path $Config.Path "SharePointPowerShell.zip")
                }       			

                #--------------------------------------------------#
                # installation
                #--------------------------------------------------#

                $_.Downloads | ForEach-Object{
                    & 7za x $(Join-Path $_.Path $_.Filename) -y
                }
                		
                #--------------------------------------------------#
                # configuration
                #--------------------------------------------------#	
                
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