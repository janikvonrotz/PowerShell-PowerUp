function Get-ConfigurationFilesContent{

	#--------------------------------------------------#
	# Parameter
	#--------------------------------------------------#
	param(
        #Search Expression for the configuration files
        [parameter(Mandatory=$true)]
        [string[]] 
        $SearchExpression,
        #Path to the folder with the configuration files
        [parameter(Mandatory=$true)]
        [string[]] 
        $Path
        <#
        [Switch]
        $OutPutToGridView,
        [Switch]
        $MergeContent
        #>
	)

	$Metadata = @{
		Title = "Get Configuration files content"
		Filename = "Get-ConfigurationFilesContent.ps1"
		Description = ""
		Tags = "powershell, function, configuration"
		Project = ""
		Author = "Janik von Rotz"
		AuthorContact = "www.janikvonrotz.ch"
		CreateDate = "2013-04-11"
		LastEditDate = "2013-04-11"
		Version = "1.0.0"
		License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}

	#--------------------------------------------------#
	# Functions
	#--------------------------------------------------#

    function Merge-Object{
        param(
            [parameter(Mandatory=$true)]
            $Base,
            [parameter(Mandatory=$true)]
            $Additional
        )

        foreach ($Property in $($Additional | Get-Member -Type Property, NoteProperty)){
            $Base | Add-Member -MemberType NoteProperty -Name $Property.Name -Value $Additional.$($Property.Name) -ErrorAction SilentlyContinue
        }

        Return $Base
    }

	#--------------------------------------------------#
	# Include
	#--------------------------------------------------#
    Import-Module PsJson

	#--------------------------------------------------#
	# Main
	#--------------------------------------------------#

    $ConfigurationFiles = @()    
    $ConfigurationFilesFolders = @()
    $ConfigurationFilesFolders += $Path
    $ConfigurationFilesFolders += get-childitem ($Path) -Recurse | where{$_.PSIsContainer} | foreach {$_.Fullname}
    foreach ($ConfigurationFilesFolder in $ConfigurationFilesFolders){
	    get-childitem ($ConfigurationFilesFolder + "\" + $SearchExpression) | where{ ! $_.PSIsContainer} | select Fullname,Extension | foreach {$ConfigurationFiles += $_}
    }

    if($ConfigurationFiles -ne $null){
        $Content = @()
        foreach($ConfigurationFile in $ConfigurationFiles){
            switch($ConfigurationFile.Extension){
                ".xml"{
                    $Content += [xml]$(get-content ($ConfigurationFile.FullName))
                }
                ".json"{
                    $JsonContent = $(get-content ($ConfigurationFile.FullName))
                    $Content += ConvertFrom-Json -JSON $Content
                }
                default{throw "file type of this configuration file: ($ConfigurationFile.Extension) is not supported"}
            }
	    }

        if($MergeContent){
            $Configuration = $Content[0]
            foreach($Item in ($Content | Select -Skip 1)){
                $Configuration = Merge-Object -Base $Configuration -Additional $Content
            }
        }else{
            $Configuration = $Content
        }

	}else{
		Write-Error "`nNo configuration file found"
		Write-Error "`nPlease create a config file under $Path" 
		Write-warning "You'll find the templates for the config files on https://gist.github.com/janikvonrotz/103d7bfc7cfa2a5d21ed"
	    break
    }
    

    return $Configuration

}