Import-Module ActiveDirectory

$SharePointDataFile = "SPReportData.csv"
$SPResourcePermissions = @()

#Get-SPObjectPermissions -Identity http://sharepoint.domain.com/SitePages/Homepage.aspx -Recursive | Export-Csv $SharePointDataFile -Delimiter ";" -Encoding "UTF8"

if(Test-Path $SharePointDataFile){
    $SPPermissions = Import-Csv $SharePointDataFile -Delimiter ";"
}else{
    throw "Couldn't find: " + $SharePointDataFile + ". Please create an csv-export with Get-SPOjbectPermissions"
}

foreach($SPPermission in $SPPermissions){
    
    Write-Progress -Activity "Build Report" -status $SPPermission.Member -percentComplete ([int]([array]::IndexOf($SPPermissions, $SPPermission)/$SPPermissions.Count*100))
    
    if($SPPermission.MemberType -eq "ADGroup"){
        $ADUsers = Get-ADGroupMember -Identity $SPPermission.Member -Recursive
    }elseif($SPPermission.MemberType -eq "ADUser"){
        $ADUsers = Get-ADUser -Identity $SPPermission.Member
    }else{
        $ADUsers = $Null
    }
    
    if($ADUsers){
    foreach($ADUser in $ADUsers){
        
        # reset item         
        $SPPermissionItem = $SPPermission.PsObject.Copy()
    
        $SPPermissionItem | Add-Member -MemberType NoteProperty -Name "UserName" -Value $ADUser.Name -Force
        $SPPermissionItem | Add-Member -MemberType NoteProperty -Name "UserDN" -Value $ADUser.DistinguishedName -Force
        $SPPermissionItem | Add-Member -MemberType NoteProperty -Name "UserSamAccountName" -Value $ADUser.SamAccountName -Force
        
        $SPResourcePermissions += $SPPermissionItem
    }}
}

$SPResourcePermissions | Export-Csv $SharePointDataFile -Delimiter ";" -Encoding "UTF8"