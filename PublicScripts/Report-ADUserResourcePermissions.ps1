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


Write-Host "`nExtract Data ..."

$s1 = Create-PSSession sharepoint
$s2 = Create-PSSession data03
$Report = @()

$ReportSession1 = Invoke-Command -Session $s1 -ScriptBlock {D:\Powershell-Profile\PublicScripts\SPSecurableObjectPermissions\Report-SPSecurableObjectPermissions.ps1}
$ReportSession2 = Invoke-Command -Session $s2 -ScriptBlock {(C:\Powershell-Profile\PublicScripts\FileSystemPermissions\Report-FileSystemPermissions#NoDependencies.ps1 -Path "F:\Dat" -Levels 3)}
$ReportGroupPermission = $ReportSession1 + $ReportSession2


While(1){

	$Usernames = @()

	While(1){
		$Username = Read-Host "`nEnter a username (or . to finish)"
		if($Username -eq "."){
			break
		}else{
		$Usernames += $Username	
		}
	}

	$ReportUserGroups = Invoke-Command -Session $s1 -ScriptBlock {param([array]$Usernames) D:\Powershell-Profile\PublicScripts\ADUserGroups\Report-ActiveDirectoryUserGroups.ps1 -Usernames $Usernames} -ArgumentList (,$Usernames)
    
    foreach ($Username in $Usernames){

        foreach ($UserGroup in $ReportUserGroups){

	        $ReportElements = ($ReportGroupPermission | Where-Object {$_.Member -like $UserGroup.GroupName -and $UserGroup.SamAccountName -like $Username})
        
            foreach($ReportElement in $ReportElements){
                $ReportElement = Merge-Object -Base $ReportElement -Additional $UserGroup
                $Report += $ReportElement
            }
        }
    }

	$Report | Out-GridView

	$Choice = Read-Host "`nNew Report? (y/n)"
	if($Choice -ne "y"){break}
}

Write-Host "`nFinished" -BackgroundColor Green -ForegroundColor Black
Read-Host "`nPress Enter to exit"
