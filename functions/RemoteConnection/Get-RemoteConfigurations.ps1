function Get-RemoteConfigurations{

	#--------------------------------------------------#
	# Parameter
	#--------------------------------------------------#
	param(
        [parameter(Mandatory=$false)]
        [string[]] 
        $Names,
        [parameter(Mandatory=$false)]
        [Switch]
        $ListAvailable
	)

	$Metadata = @{
		Title = "Get Powershell Remote Configurations"
		Filename = "Get-RemoteConfigurations.ps1"
		Description = ""
		Tags = "powershell, function, remote"
		Project = ""
		Author = "Janik von Rotz"
		AuthorContact = "www.janikvonrotz.ch"
		CreateDate = "2013-04-08"
		LastEditDate = "2013-04-11"
		Version = "2.0.0"
		License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
	
	#--------------------------------------------------#
	# Main
	#--------------------------------------------------#

	$Config = @()
    $Content = Get-ConfigurationFilesContent -SearchExpression "*.remote.config.*" -Path $PSConfig.configs.Path
    
    foreach($Item in $Content){
        $Config  += $Item.Content.Servers
    }
    
    if($ListAvailable -and $Names -eq $null){
		try{
			$Config | Out-Gridview
		}catch{
			$error[0]
			$Config | format-table
		}
    }else{
        if($Names -ne $null){

            foreach($Server in $Config){
                if(($Names).contains($Server.Name)){
                    $Server
                }
            }
        }else{
            throw "Enter values for the following parameters: Names[]"  
        }
    }
}