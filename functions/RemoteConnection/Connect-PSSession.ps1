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
		LastEditDate = "2013-04-18"
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
    $Sessions = @()
    # Load Configurations
	$config = Get-RemoteConnections -Names $Names
	
	foreach($Server in $Config){
		
		# Delete Session if already opened
		Remove-PSSession -ComputerName $Server.Server -ErrorAction SilentlyContinue
			
		$Username = $Server.User
		$Password = Read-Host -Prompt "`nEnter password for $Username" -AsSecureString
		$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $Username, $Password

		# Open Session
		$s = New-PSSession -Name $Server.Name  -ComputerName $Server.Server -Credential $Credentials

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