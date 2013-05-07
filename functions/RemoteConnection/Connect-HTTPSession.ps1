function Connect-HTTPSession{
    <#
	    .SYNOPSIS
		    Remote management open http session

	    .DESCRIPTION
		    Starts a http session with the parameters from the Remote config file.

	    .PARAMETER  Names
		    Server names from the remote config file

	    .EXAMPLE
		    Connect-HTTPSession -Names firewall

    #>

	#--------------------------------------------------#
	# Parameter
	#--------------------------------------------------#
	param (
        [parameter(Mandatory=$true)][string[]]
		$Names
	)

	$Metadata = @{
		Title = "Connect HTTP Session"
		Filename = "Connect-HTTPSession.ps1"
		Description = ""
		Tags = "powershell, remote, session, http"
		Project = ""
		Author = "Janik von Rotz"
		AuthorContact = "www.janikvonrotz.ch"
		CreateDate = "2013-05-07"
		LastEditDate = "2013-05-07"
		Version = "1.0.0"
		License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}


    #--------------------------------------------------#
    # main
    #--------------------------------------------------#

    # Load Configurations
	$Config = Get-RemoteConnections -Names $Names

    foreach($Server in $Config){
		
        # default settings
        $HttpPort = 80
        $HttpsPort = 443
                
        #Set Protocol
        $Server.Protocols | foreach{
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
            "http" {Start-Process -FilePath ($Protocol + "://" + $Server.Server + ":" + $HttpPort)}
            "https" {Start-Process -FilePath ($Protocol + "://" + $Server.Server + ":" + $HttpsPort)}
        }
    }
}