<#
$Metadata = @{
	Title = "Copy PowerShell PowerUp Configuration"
	Filename = "Copy-PPConfigurationFile.ps1"
	Description = ""
	Tags = "powershell, profile, configuration, function"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-01-29"
	LastEditDate = "2014-01-29"
	Version = "0.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Copy-PPConfigurationFile{

<#
.SYNOPSIS
	Copies PowerShell PowerUp configuration file.

.DESCRIPTION
	Copies PowerShell PowerUp configuration file only if force parameter is not set and destination file not already exists.
    The name of the coniguration file can be in a subfolder inside the source path. PowerShell PowerUp is not aware of static paths.

.PARAMETER  Path
	Source hub of the configuration file. Default ist template folder.

.PARAMETER  Destination
	Destination hub of the configuration file.

.PARAMETER Name
    Name of the configuration file, must be unique inside the source hub. Default is configuration folder.

.PARAMETER Force
    Overwrite existin cofiguration file.

.EXAMPLE
	PS C:\> Copy-PPConfigurationFileh -Name $PStemplates.LogFileRetention.Name -Force
    
.EXAMPLE
	PS C:\> Copy-PPConfigurationFile -Path $PStemplates.Path -Destination $PSconfigs.Path -Name $PStemplates.LogFileRetention.Name -Force
#>

	param(
        [Parameter(Mandatory=$false)]
		[String]
		$Path = $PStemplates.Path,
		
		[Parameter(Mandatory=$false)]
        [String]
		$Destination = $PSconfigs.Path,
        
        [Parameter(Mandatory=$true)]
        [String]
        $Name,
        
        [Switch]
        $Force
	)
	
	#--------------------------------------------------#
	# main
	#--------------------------------------------------#
    $DestinationFilePath = Get-ChildItem -Path $Destination -Filter $Name -Recurse
    $SourceFilePath = Get-ChildItem -Path $Path -Filter $Name -Recurse
    
    if($SourceFilePath){            
        
        if($DestinationFilePath -and $Force) {
        
            Write-Host "Overwrite $Name file in the destination folder"     
            Copy-Item -Path $SourceFilePath.Fullname -Destination $DestinationFilePath.Fullname -Force
	   
        }else{
       
            Write-Host "Copy $Name file to the destination folder"
            Copy-Item -Path $SourceFilePath.Fullname -Destination $Destination.Fullname
        }   
    }else{
       
        Write-Error "Couldn't find $Name file."  
   }
}