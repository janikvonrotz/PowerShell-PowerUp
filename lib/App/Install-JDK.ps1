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
	Url = "http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html"
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
				
				Start-Process $Config.Url
				
                #--------------------------------------------------#
                # installation
                #--------------------------------------------------#
	
                #--------------------------------------------------#
                # configuration
                #--------------------------------------------------#	
				
				[Environment]::SetEnvironmentVariable("CLASSPATH",".","Machine")
				[Environment]::SetEnvironmentVariable("JAVA_HOME","C:\Program Files\Java\jdk1.8.0_20","Machine")
				
				Set-EnvironmentVariableValue -Name "Path" -Value ";%JAVA_HOME%\bin" -Target "Machine"
				
                #--------------------------------------------------#
                # cleanup
                #--------------------------------------------------#
                		
                #--------------------------------------------------#
                # finisher
                #--------------------------------------------------#
                		
                if($Update){
                    $_.Result = "AppUpdated";$_
                }elseif($Downgrade){
                    $_.Result = "AppDowngraded";$_
                }else{
                    $_.Result = "AppInstalled";$_
                }
            		
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
			
            $Executable = ""; if(Test-Path $Executable){Start-Process -FilePath $Executable -ArgumentList "/VERYSILENT /NORESTART" -Wait}
							
            $_.Result = "AppUninstalled";$_
        }

    #--------------------------------------------------#
    # catch error
    #--------------------------------------------------#

    }catch{

        $Config.Result = "Error";$Config
    }
}