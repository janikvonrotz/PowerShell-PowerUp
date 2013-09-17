<#
$Metadata = @{
    Title = "Connect Powershell Remote Session"
    Filename = "Create-PSSession.ps1"
    Description = ""
    Tags = "powershell, remote, session"
    Project = ""
    Author = "Janik von Rotz"
    AuthorContact = "www.janikvonrotz.ch"
    CreateDate = "2013-03-12"
    LastEditDate = "2013-09-17"
    Version = "3.0.0"
    License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Connect-PSSession{

	param (
        [parameter(Mandatory=$true)]
		$Names,
        
        [parameter(Mandatory=$false)]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
	)
	
	#--------------------------------------------------#
	# main
	#--------------------------------------------------#
        
    # Load Configurations
	$Servers = Get-RemoteConnections -Names $Names
	
	foreach($Server in $Servers){
		
		# Delete Session if already opened
		Remove-PSSession -ComputerName $Server.Name -ErrorAction SilentlyContinue
		
		# Get connect account credentials
        if($Credential.UserName -eq $null){
            $Credential = Get-Credential $Server.User
        }		

		# Open Session
		$s = New-PSSession -Name $Server.Name  -ComputerName $Server.Name -Credential $Credential

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

