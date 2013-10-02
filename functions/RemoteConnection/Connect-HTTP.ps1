<#
$Metadata = @{
    Title = "Connect HTTP Session"
    Filename = "Connect-HTTP.ps1"
    Description = ""
    Tags = "powershell, remote, session, http"
    Project = ""
    Author = "Janik von Rotz"
    AuthorContact = "http://janikvonrotz.ch"
    CreateDate = "2013-05-07"
    LastEditDate = "2013-10-02"
	Version = "3.0.0"
    License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Connect-HTTP{

<#
.SYNOPSIS
	Remote management open http session.

.DESCRIPTION
	Starts a http session with the parameters from the Remote config file.

.PARAMETER  Name
	Servername (Key or Name from the remote config file for preconfiguration).

.PARAMETER  Secure
	Use https instead of http.

.EXAMPLE
	Connect-HTTP -Name firewall

#>

	#--------------------------------------------------#
	# Parameter
	#--------------------------------------------------#
	param (
        [parameter(Mandatory=$true)]
        [string[]]$Name,
        
        [switch]$Secure
	)

    #--------------------------------------------------#
    # main
    #--------------------------------------------------#

    # Load Configurations 
	$Servers = grc -Name $Name

	# default settings
	$HttpPort = 80
	$HttpsPort = 443
    
    foreach($Server in $Servers){
    
    	#Set Protocol if there is no configuration
    	if($Server.Protocol -eq $null){
    		
    		# use https if the parameter is given
    		if($Secure){
            
    			$Protocol = "https"
                
    		}else{
            
    			$Protocol = "http"
    		}
    	}  
        
        $Server.Protocol | foreach{

            if($_.Name -eq "https"){

                $Protocol = "https"

                if($_.Port -ne ""){

                    $HttpsPort = $_.Port
                }
            }elseif($_.Name -eq "http"){

                $Protocol = "http"

                if($_.Port -ne ""){

                    $HttpPort = $_.Port
                }
            }
        }

        switch($Protocol){
            "http" {Start-Process -FilePath ($Protocol + "://" + $Server.Name + ":" + $HttpPort)}
            "https" {Start-Process -FilePath ($Protocol + "://" + $Server.Name + ":" + $HttpsPort)}
        }
    }
}