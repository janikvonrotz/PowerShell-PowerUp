<#
$Metadata = @{
    Title = "Connect Powershell Remote Session"
    Filename = "Create-PSS.ps1"
    Description = ""
    Tags = "powershell, remote, session"
    Project = ""
    Author = "Janik von Rotz"
    AuthorContact = "http://janikvonrotz.ch"
    CreateDate = "2013-03-12"
    LastEditDate = "2013-10-02"
	Version = "3.0.0"
    License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Connect-PSS{

	param (
        [parameter(Mandatory=$true)]
		[string[]]$Name,
        
        [parameter(Mandatory=$false)]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
	)
	
	#--------------------------------------------------#
	# main
	#--------------------------------------------------#
        
    # Load Configurations
	$Servers = Get-RemoteConnection -Name $Name
	
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

