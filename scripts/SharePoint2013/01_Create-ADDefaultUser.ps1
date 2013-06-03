<#
.SYNOPSIS
	Create Active Directory Default User

.DESCRIPTION
	Initial deployment administrative and service accounts in SharePoint 2013

.LINK
	Technet article: http://technet.microsoft.com/en-us/library/ee662513.aspx
#>

$Metadata = @{
	Title = "Create Active Directory Default User"
	Filename = "Create-ADDefaultUser.ps1"
	Description = "Initial deployment administrative and service accounts in SharePoint 2013"
	Tags = "powershell, sharepoint, 2013, installation"
	Project = "SharePoint 2013 Install"
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-05-22"
	LastEditDate = "2013-05-22"
	Version = "1.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}

#--------------------------------------------------#
# settings
#--------------------------------------------------#
$PathToXmlFile = Get-ChildItem -Path $PSconfigs.Path -Filter '*.install.config.xml' -Recurse
[xml]$Config = get-content $PathToXmlFile.FullName

#--------------------------------------------------#
# modules
#--------------------------------------------------#
Import-Module Quest.ActiveRoles.ArsPowerShellSnapIn -ErrorAction SilentlyContinue

#--------------------------------------------------#
# main
#--------------------------------------------------#
$ADDefaultUser = $Config.Content.ADDefaultUser
$Global = $Config.Content.Global

# connect to domain controller
#$Username = $ADDefaultUser.ADService.ConnectionAccount
#$Password = read-host "Enter password for $Username" -AsSecureString
#connect-QADService -service 'localhost' -proxy -ConnectionAccount 'company\administrator' -ConnectionPassword $Password 


foreach($Account in $ADDefaultUser.Account){

    $samAccountName = $Global.Project.Prefix + "-" + $Account.samAccountName
    
    Write-Host "Adding new user: $Username"
        
	New-QADUser -name $samAccountName -ParentContainer $ADDefaultUser.ParentContainer -samAccountName $samAccountName -UserPassword  $Account.UserPassword
    
	Enable-QADUser $samAccountName
	
    Set-QADUser $samAccountName -PasswordNeverExpires $true
    
    #Set-QADUser $samAccountName -PasswordNeverExpires 0 -objectAttributes @{AccountIsDisabled=$false}
}




# Import-Module ActiveDirectory
# $csvpath = "c:\scripts\Newusers.csv"
# $OU =  "OU=UsersOU,DC=domain,DC=com"

 # Import-Csv $csvpath |  ForEach-Object {

# $sam = $_.Username

# Try   { $exists = Get-ADUser -LDAPFilter "(sAMAccountName=$sam)" }

# Catch { }

# If(!$exists)

# {

# $Password = $_.Password

# New-ADUser $sam -GivenName $_.GivenName -Initials $_.Initials -Surname $_.SN -DisplayName $_.DisplayName -EmailAddress $_.EmailAddress  -passthru |

# ForEach-Object {

# $_ | Set-ADAccountPassword -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $Password -Force)

# $_ | Enable-ADAccount }


# # Set an ExtensionAttribute

# $dn  = (Get-ADUser $sam).DistinguishedName

# $ext = [ADSI]"LDAP://$dn"

# $ext.SetInfo()

# Move-ADObject -Identity $dn -TargetPath $OU

# $newdn = (Get-ADUser $sam).DistinguishedName

# Rename-ADObject -Identity $newdn -NewName $_.DisplayName



# }

# Else

# {

# "SKIPPED - ALREADY EXISTS OR ERROR: " + $_.CN 

# }

