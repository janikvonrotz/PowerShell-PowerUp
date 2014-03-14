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
	Url = "https://my.vmware.com/group/vmware/details?downloadGroup=PCLI550&productId=352"
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
                
                Write-Warning "Installer is not available for public download. Download it on your own from the official VMware website."
                Start-Process -FilePath "$($_.Url)" 			

                #--------------------------------------------------#
                # installation
                #--------------------------------------------------#
				                		
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
            
            Get-MSI | where{$_.ProductName -eq "VMware vSphere PowerCLI"} | ForEach-Object{
                 Start-Process -FilePath "msiexec" -ArgumentList "/uninstall $($_.LocalPackage) /qn" -Wait 
            }
                
            $_.Result = "AppUninstalled";$_
        }

    #--------------------------------------------------#
    # catch error
    #--------------------------------------------------#

    }catch{

        $Config.Result = "Error";$Config
    }
}