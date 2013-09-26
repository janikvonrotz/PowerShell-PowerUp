<#
$Metadata = @{
    Title = "Get Remote Connections"
    Filename = "Get-RemoteConnections.ps1"
    Description = ""
    Tags = "powershell, function, remote"
    Project = ""
    Author = "Janik von Rotz"
    AuthorContact = "www.janikvonrotz.ch"
    CreateDate = "2013-04-08"
    LastEditDate = "2013-09-26"
    Version = "3.1.0"
    License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Get-RemoteConnections{

	#--------------------------------------------------#
	# Parameter
	#--------------------------------------------------#
	param(
        [parameter(Mandatory=$false)]
        [string[]] 
        $Name,
        
        [Switch]
        $ListAvailable
	)
	
	#--------------------------------------------------#
	# main
	#--------------------------------------------------#
        
    # load configurations
    $ServerConfigs = Get-ChildItem -Path $PSconfigs.Path -Filter $PSconfigs.Remote.Filter -Recurse | %{
            [xml]$(get-content $_.FullName)} | %{
                $_.Content.Server}
    
        
    # check ListAvailable-parameter
    if($ListAvailable -and $Names -eq $null){
    
        $ServerConfigs | Sort Key
        
    }elseif($Name -ne $null){

        $Matches = $ServerConfigs | 
            %{$Server = $_; $Name | 
                %{if(($Server.Key -contains $_) -or ($Server.Name -contains $_)){$Server}}}
        
        if($Matches -eq $Null){
        
            $Name | %{New-ObjectRemoteConnection -Name $_}
            
        }else{
            
            $Matches
        } 
               
    }else{
    
        throw "Enter values for the following parameters: Name[]"  
    }
}