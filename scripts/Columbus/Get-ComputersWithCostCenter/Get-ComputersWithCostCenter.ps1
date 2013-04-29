$Metadata = @{
	Title = "Get Computers with Cost Center"
	Filename = "Get-ComputerWithCostCenter"
	Description = "powershell, script, columbus, activedirectory, report"
	Tags = ""
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "www.janikvonrotz.ch"
	CreateDate = "2013-04-29"
	LastEditDate = "2013-04-29"
	Version = "1.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}

Import-Module Quest.ActiveRoles.ArsPowerShellSnapIn

$Report = @()

$ADUsers = Get-QADUser -DontUseDefaultIncludedProperties -IncludedProperties "SamAccountName","extensionAttribute2" -SearchRoot "OU=vblusers2,DC=vbl,DC=ch"

$ColumbComputers = Import-Csv -Path DataAllDevices.csv -delimiter ";"

foreach($ColumbComputer in ($ColumbComputers | where {$_.Objectname -ne "" -and ($_.HardwareType -like "Notebook" -or $_.HardwareType -like "Desktop")})){
    $CostCenter = ""
    $ADusers | where {$_.SamAccountName -like $ColumbComputer."Last User"} |  foreach{$CostCenter = $_.extensionAttribute2}
    Write-Output  $ColumbComputer.Objectname $CostCenter
    $ReportObject = New-Object -TypeName PSObject –Prop (@{
        'ComputerName'= $ColumbComputer.Objectname;
        'UserName' = $ColumbComputer."Last User";
        'CostCenter'=$CostCenter
    })
    $Report += $ReportObject
}

$Report | Out-GridView

Write-Host "`nFinished" -BackgroundColor Black -ForegroundColor Green

Read-Host "`nPress Enter to exit"