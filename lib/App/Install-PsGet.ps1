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
	Url = "http://psget.net/GetPsGet.ps1"
    ConditionExclusion = "(Get-Module -ListAvailable | where{`$_.Name -eq `"PsGet`"})"
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

                #--------------------------------------------------#
                # installation
                #--------------------------------------------------#

                $_.Url | ForEach-Object{
                    Invoke-Expression (new-object Net.WebClient).DownloadString($_)
                }
                		
                #--------------------------------------------------#
                # configuration
                #--------------------------------------------------#	
                
                #--------------------------------------------------#
                # cleanup
                #--------------------------------------------------#
				
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