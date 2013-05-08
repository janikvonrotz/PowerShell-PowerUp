function Get-UnlinkedGPO {

<#
.SYNOPSIS
	Get all unlinkend GPOs
 
.EXAMPLE
	PS C:\> Get-UnlinkedGPO
#>

$Metadata = @{
	Title = "Get unlinked GPOs"
	Filename = "Get-UnlinkedGPO.ps1"
	Description = ""
	Tags = "powershell, function, activedirectory"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "www.janikvonrotz.ch"
	CreateDate = "2013-05-06"
	LastEditDate = "2013-05-08"
	Version = "1.0.1"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}

	#--------------------------------------------------#
	# modules
	#--------------------------------------------------#
    Import-module grouppolicy 
    
	#--------------------------------------------------#
	# helper and functions
	#--------------------------------------------------#
    function IsNotLinked($xmldata){ 
        If ($xmldata.GPO.LinksTo -eq $null) { 
            Return $true 
        } 
         
        Return $false 
    } 
    
	#--------------------------------------------------#
	# main
	#--------------------------------------------------#
    
    $Report = @() 
    $GPOs = Get-GPO -All
    foreach($GPO in $GPOs) { 

		Write-Progress -Activity "Change GPO Settings" -status ("Change GPO: "+$GPO.DisplayName) -percentComplete ([int]([array]::IndexOf($GPOs, $GPO)/$GPOs.Count*100))
        
        $GPOReport = $GPO | Get-GPOReport -ReportType xml 
        
        If(IsNotLinked([xml]$GPOReport)){$Report += $GPO}
    }
     
    If ($Report.Count -eq 0) { 
        Wirte-Warning "No unlinked GPO's found" 
    }else{ 
        return $Report
    }
}