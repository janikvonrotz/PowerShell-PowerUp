<#
$Metadata = @{
    Title = "Get Remote Connection"
    Filename = "Get-RemoteConnection.ps1"
    Description = ""
    Tags = "powershell, function, remote"
    Project = ""
    Author = "Janik von Rotz"
    AuthorContact = "http://janikvonrotz.ch"
    CreateDate = "2013-04-08"
    LastEditDate = "2013-10-02"
	Version = "3.0.0"
    License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Get-RemoteConnection{

	param(
        [parameter(Mandatory=$false)]
        [string[]] 
        $Name,
        
        [Switch]
        $ListAvailable
	)
    
    #--------------------------------------------------#
	# functions
	#--------------------------------------------------#
	function New-ObjectRemoteConnection{
        param(
            [string]$Name,
            [string]$Server,
            [string]$User,
            [string]$Description,
            [string]$SnapIns,
    		[string]$PrivatKey
        )
        New-Object PSObject -Property @{
            Name = $Name
            Server = $Server
            User = $User
            Description = $Description
            SnapIns = $SnapIns
    		PrivatKey = $PrivatKey
        }
    }
    
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