function Connect-PSSession{
	#--------------------------------------------------#
	# Parameter
	#--------------------------------------------------#
	param (
        [parameter(Mandatory=$true)]
		$Names
	)
	
	$Metadata = @{
		Title = "Connect Powershell Remote Session"
		Filename = "Create-PSSession.ps1"
		Description = ""
		Tags = "powershell, remote, session"
		Project = ""
		Author = "Janik von Rotz"
		AuthorContact = "www.janikvonrotz.ch"
		CreateDate = "2013-03-12"
		LastEditDate = "2013-09-16"
		Version = "3.0.0"
		License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
	
	#--------------------------------------------------#
	# Main
	#--------------------------------------------------#
    # Resets
    $Sessions = @()
    
    # Load Configurations
	$Config = Get-RemoteConnections -Names $Names
	
	foreach($Server in $Config){
		
		# Delete Session if already opened
		Remove-PSSession -ComputerName $Server.Name -ErrorAction SilentlyContinue
		
		# Get connect account credentials
        if(!$Server.User.Contains("")){
            $Username = $Server.User
        }else{
            $Username = $Server.User
        }
		$Credentials = Get-Credential $Username

		# Open Session
		$s = New-PSSession -Name $Server.Name  -ComputerName $Server.Name -Credential $Credentials

		# Load SnapIns
		if ($Server.SnapIns -ne ""){
            foreach($SnapIn in $Server.SnapIns){
			    Invoke-Command -Session $s -ScriptBlock {param ($Name) Add-PSSnapin -Name $Name} -ArgumentList $SnapIn
            }
		}

        $Sessions += $s
	}
    $Sessions	
}
