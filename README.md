PowerShell-PowerUp
==================

	    _/_/_/    _/_/_/        _/
	   _/    _/  _/    _/      _/
	  _/_/_/    _/_/_/    _/_/_/_/_/
	 _/        _/            _/
	_/        _/            _/    

PowerShell PowerUp is a Server Management Framework.

* This PowerShell project is compatible with PowerShell v2 and higher.
* PowerShell PowerUp extends your existing command line with tons of new cmdlets and modules.
* It's 100% customizable and works without dependencies.

# References

> Holy fucking creeper shit, this is the best PowerShell Server Management Framework I've used!

-- You in a few seconds

# How to install

Download the latest release:

![GitHub Download ZIP](https://raw.github.com/janikvonrotz/PowerShell-PowerUp/master/doc/GitHub%20Download%20ZIP.png)

and unzip it in the directory of your choice OR use git to clone the whole repository:

	git clone git://github.com/janikvonrotz/PowerShell-PowerUp.git

Now add a profile configuration file to the config folder:

	COPY    \templates\Profile\Example.profile.config.xml    TO    \config\... 
	
And
	
	RENAME    Example.profile.config.xml    TO    [Something].profile.config.xml

Now take your time to edit your new PowerShell PowerUp profile config file.
Checkout the documentation below for more information.

	EDIT    [Something].profile.config.xml

	SAVE    [Something].profile.config.xml
	
Open your Powershell commandline and enter:

	PS C:\PowerShell-PowerUp> Set-ExecutionPolicy remotesigned
	
Or depending on your windows security restrictions:
	
	PS C:\PowerShell-PowerUp> Set-ExecutionPolicy unrestricted

At last execute the install script from the PowerShell commad line:

	PS C:\PowerShell-PowerUp> .\Microsoft.PowerShell_profile.install.ps1
	
# Default Features

By default the install script installs these features:

### Add ISE Profile Script

The PowerShell ISE uses a different profile script. With this feature enabled the installation script creates a second profile script for the PowerShell ISE with the same features as the normal profile script.

### Autoinclude Functions

To use PowerShell function like a library in other programming languages just install this feature and add your functions scripts to the functions folder `$PSfunctions.Path`.

### Transcript Logging

This features logs the PowerShell prompt output for every session into the log folder `$PSlogs.Path`.
The path to the session log file is stored in `$PSlogs.SessionFile`.

# Customizable Features

Based on the PowerShell PowerUp config files definitions you can add these features:

### Add System Variables

Would you like to use git from your PowerShell command line or another executable. The first and last thing you'll need is a system variable entry of the executable path.

**Installation**

To enable this feature add this code to the profile installaton config file:

    <SystemVariable Value="%ProgramFiles(x86)%\Git\bin" Name="Path" Target="Machine"></SystemVariable>

Or

	<SystemVariable Value="$home" Name="Path" Target="Machine"></SystemVariable>	

Or

	<SystemVariable Value="\apps\Git\cmd" Name="Path" Target="Machine"></SystemVariable>

### Custom PowerShell Profile script

Adds a section to the profile script to customize your PowerShell Profile script.

**Installation**

To enable this feature update the status attribute to `Enabled`

	<Feature Name="Custom PowerShell Profile script" Status="Enabled"></Feature>
    
### Custom PowerShell Profile ISE script

Adds a section to the profile script to customize your PowerShell Profile ISE script.
Requires the feature:

* Add ISE Profile Script

**Installation**

To enable this feature update the status attribute to `Enabled`

	<Feature Name="Custom PowerShell Profile ISE script" Status="Enabled"></Feature>

### Enable Open Powershell here

![Enable Open Powershell here picture](https://raw.github.com/janikvonrotz/Powershell-Profile/master/doc/Enable%20Open%20Powershell%20here.png)

**Installation**

To enable this feature update the status attribute to `Enabled`

	<Feature Name="Enable Open Powershell here" Status="Enabled"></Feature>

### Get Quote Of The Day

Every time you start a new prompt a nice quote will be shown.

**Installation**

To enable this feature update the status attribute to `Enabled`

	<Feature Name="Get Quote Of The Day" Status="Enabled"></Feature>

### Git Update

This feature will add a sheduled windows task and if required the latest git client. In a daily schedule the repository will be updated from the github repository.

![Git Update Task picture](https://raw.github.com/janikvonrotz/Powershell-Profile/master/doc/Git%20Update%20Task.png)

Also possible from the command line `Update-PowerShellProfile`.

**Installation**

To enable this feature update the status attribute to `Enabled`

	<Feature Name="Git Update" Status="Enabled"></Feature>	

### Log File Retention

Clean up the log folder by a daily task or everytime a PowerShell prompt opens.
Also possible from the command line `Delete-ObsoleteLogFiles`.

**Installation**

To enable this feature update the status attribute to `Enabled`

	<Feature Name="Log File Retention" Days="x" MaxFilesToKeep="x" Run="asDailyJob,withProfileScript" Status="Enabled"></Feature>

**Options**

Every option can be combined or stand alone.

* **Days**: Older log files than x Days will be deleted.
* **MaxFilesToKeep**: Older log files than x Days will be deleted.
* **Run**: Add `asDailyJob` to run the clean up as windows job and/or add `withProfileScript` to run the clean up every time a PowerShell prompt starts.

### Powershell Remoting

In case you don't know there's a possibility to manage your windows server with PowerShell. Checkout the Multi Remote Management feature for more inforamtion.
Anyway to enable for other clients to connection you host with PowerShell Remoting you'll have to add this feature. 

**Installation**

To enable this feature update the status attribute to `Enabled`

	<Feature Name="Powershell Remoting" Status="Enabled"></Feature>

# New Cmdlets

You'll get a bunch of new functions to manage your service installation.
Some of this are from the backers of PowerShell PowerUp and others are included from other projects.

### PowerShell PowerUp

PowerShell PowerUp can mange these services:

* Multi Remote Management
* Package Manager
* PowerShell PowerUp
* Scripts and Shortcuts
* SharePoint
* SQL Sever
* TrueCrypt
* Windows Event Log
* Windows features/components
* Windows Scheduled Task

### SharePoint Online

These functions are part of [Jeffrey Paarhuis](http://jeffreypaarhuis.com/) project: [Client-side SharePoint PowerShell](https://sharepointpowershell.codeplex.com/).
I've imported the functions of this project and updated the naming concept and metadata.

In order to use these commands you have to install the Managed .NET Client-Side Object Model (CSOM) of SharePoint 2013. Run the command `Install-PPApp "SharePoint Server 2013 Client Components SDK"` to install this app.

### Carbon

These functions are part of [Aaron Jensen](http://pshdo.com/) project: [Carbon](http://get-carbon.org/).

Carbon is a DevOps PowerShell module for automating the configuration of Windows 2008, Windows 2008 R2, and 7 computers. Carbon can configure and manage:

* Local users and groups
* IIS websites, virtual directories, and applications
* Certificates
* .NET connection strings and app settings
* Junctions
* File system permissions
* Hosts file
* INI files
* Performance counters
* Services
* Shares
* Windows features/components


### List of all new Cmdlets

This index has been made with this script: [https://gist.github.com/10965567](https://gist.github.com/10965567)

<h1 id="index">Index</h1>
<a href="#A"> a </a>|
<a href="#B"> b </a>|
<a href="#C"> c </a>|
<a href="#D"> d </a>|
<a href="#E"> e </a>|
<a href="#F"> f </a>|
<a href="#G"> g </a>|
<a href="#H"> h </a>|
<a href="#I"> i </a>|
<a href="#J"> j </a>|
<a href="#K"> k </a>|
<a href="#L"> l </a>|
<a href="#M"> m </a>|
<a href="#N"> n </a>|
<a href="#O"> o </a>|
<a href="#P"> p </a>|
<a href="#Q"> q </a>|
<a href="#R"> r </a>|
<a href="#S"> s </a>|
<a href="#T"> t </a>|
<a href="#U"> u </a>|
<a href="#V"> v </a>|
<a href="#W"> w </a>|
<a href="#X"> x </a>|
<a href="#Y"> y </a>|
<a href="#Z"> z </a>
</p>
<h1 id="A"><a href="#index">A</a></h1>
<p>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Security/Protect-Acl.ps1'>Protect-Acl</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/ActiveDirectory/Get-ActiveDirectoryUserGroups.ps1'>Get-ActiveDirectoryUserGroups</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/ActiveDirectory/Get-ADDomainController.ps1'>Get-ADDomainController</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/ActiveDirectory/Sync-ADGroupMember.ps1'>Sync-ADGroupMember</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Security/Assert-AdminPrivilege.ps1'>Assert-AdminPrivilege</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Security/Test-AdminPrivilege.ps1'>Test-AdminPrivilege</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/ActiveDirectory/Get-ADPrincipalGroupMembershipRescurse.ps1'>Get-ADPrincipalGroupMembershipRescurse</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/ActiveDirectory/Format-ADSearchFilterValue.ps1'>Format-ADSearchFilterValue</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/ActiveDirectory/Find-ADUser.ps1'>Find-ADUser</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint/Backup/Backup-AllSPLists.ps1'>Backup-AllSPLists</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint/Backup/Backup-AllSPSites.ps1'>Backup-AllSPSites</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint/Backup/Backup-AllSPWebs.ps1'>Backup-AllSPWebs</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SQLServer/Backup-AllSQLDBs.ps1'>Backup-AllSQLDBs</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/IIS/Invoke-AppCmd.ps1'>Invoke-AppCmd</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Windows/Get-AvailableDriveLetter.ps1'>Get-AvailableDriveLetter</a></p>
<h1 id="B"><a href="#index">B</a></h1>
<p>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Text/ConvertFrom-Base64.ps1'>ConvertFrom-Base64</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Text/ConvertTo-Base64.ps1'>ConvertTo-Base64</a></p>
<h1 id="C"><a href="#index">C</a></h1>
<p>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Certificates/Get-Certificate.ps1'>Get-Certificate</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Certificates/Install-Certificate.ps1'>Install-Certificate</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Certificates/Uninstall-Certificate.ps1'>Uninstall-Certificate</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Certificates/Get-CertificateStore.ps1'>Get-CertificateStore</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Windows/Get-ChildItemRecurse.ps1'>Get-ChildItemRecurse</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Obsolete/Get-CleanSPUrl.ps1'>Get-CleanSPUrl</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/COM/Get-ComPermission.ps1'>Get-ComPermission</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/COM/Grant-ComPermission.ps1'>Grant-ComPermission</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/COM/Revoke-ComPermission.ps1'>Revoke-ComPermission</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/COM/Get-ComSecurityDescriptor.ps1'>Get-ComSecurityDescriptor</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Security/New-Credential.ps1'>New-Credential</a></p>
<h1 id="D"><a href="#index">D</a></h1>
<p>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Windows/Mount-Dir.ps1'>Mount-Dir</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/ActiveDirectory/Add-DomainUserToLocalGroup.ps1'>Add-DomainUserToLocalGroup</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/DotNet/Test-DotNet.ps1'>Test-DotNet</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/DotNet/Set-DotNetAppSetting.ps1'>Set-DotNetAppSetting</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/DotNet/Set-DotNetConnectionString.ps1'>Set-DotNetConnectionString</a></p>
<h1 id="E"><a href="#index">E</a></h1>
<p>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Computer/Remove-EnvironmentVariable.ps1'>Remove-EnvironmentVariable</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Computer/Set-EnvironmentVariable.ps1'>Set-EnvironmentVariable</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Windows/Remove-EnvironmentVariableValue.ps1'>Remove-EnvironmentVariableValue</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Windows/Set-EnvironmentVariableValue.ps1'>Set-EnvironmentVariableValue</a></p>
<h1 id="F"><a href="#index">F</a></h1>
<p>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Package Manager/Get-File.ps1'>Get-File</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Windows/Get-FileEncoding.ps1'>Get-FileEncoding</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/PowerShell/Format-FileSize.ps1'>Format-FileSize</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Windows/Report-FileSystemPermissions.ps1'>Report-FileSystemPermissions</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Firewall/Assert-FirewallConfigurable.ps1'>Assert-FirewallConfigurable</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Firewall/Get-FirewallRule.ps1'>Get-FirewallRule</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Firewall/Disable-FirewallStatefulFtp.ps1'>Disable-FirewallStatefulFtp</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Firewall/Enable-FirewallStatefulFtp.ps1'>Enable-FirewallStatefulFtp</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Firewall/Test-FirewallStatefulFtp.ps1'>Test-FirewallStatefulFtp</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Multi Remote Management/Connect-FTP.ps1'>Connect-FTP</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Path/Resolve-FullPath.ps1'>Resolve-FullPath</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint/SPO-Functions.ps1'>SPO-Functions</a></p>
<h1 id="G"><a href="#index">G</a></h1>
<p>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/UsersAndGroups/Install-Group.ps1'>Install-Group</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/UsersAndGroups/Add-GroupMember.ps1'>Add-GroupMember</a></p>
<h1 id="H"><a href="#index">H</a></h1>
<p>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Windows/Get-HostFileEntries.ps1'>Get-HostFileEntries</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Windows/Add-HostFileEntry.ps1'>Add-HostFileEntry</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Windows/Remove-HostFileEntry.ps1'>Remove-HostFileEntry</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/HostsFile/Remove-HostsEntry.ps1'>Remove-HostsEntry</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/HostsFile/Set-HostsEntry.ps1'>Set-HostsEntry</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/HostsFile/Reset-HostsFile.ps1'>Reset-HostsFile</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Multi Remote Management/Connect-HTTP.ps1'>Connect-HTTP</a></p>
<h1 id="I"><a href="#index">I</a></h1>
<p>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/UsersAndGroups/Test-Identity.ps1'>Test-Identity</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/UsersAndGroups/Resolve-IdentityName.ps1'>Resolve-IdentityName</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/InternetExplorer/Enable-IEActivationPermission.ps1'>Enable-IEActivationPermission</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/InternetExplorer/Disable-IEEnhancedSecurityConfiguration.ps1'>Disable-IEEnhancedSecurityConfiguration</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/IIS/Get-IisApplication.ps1'>Get-IisApplication</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/IIS/Install-IisApplication.ps1'>Install-IisApplication</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/IIS/Get-IisAppPool.ps1'>Get-IisAppPool</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/IIS/Install-IisAppPool.ps1'>Install-IisAppPool</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/IIS/Test-IisAppPool.ps1'>Test-IisAppPool</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/IIS/Uninstall-IisAppPool.ps1'>Uninstall-IisAppPool</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/IIS/Get-IisConfigurationSection.ps1'>Get-IisConfigurationSection</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/IIS/Lock-IisConfigurationSection.ps1'>Lock-IisConfigurationSection</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/IIS/Test-IisConfigurationSection.ps1'>Test-IisConfigurationSection</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/IIS/Unlock-IisConfigurationSection.ps1'>Unlock-IisConfigurationSection</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/IIS/Add-IisDefaultDocument.ps1'>Add-IisDefaultDocument</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/IIS/Enable-IisDirectoryBrowsing.ps1'>Enable-IisDirectoryBrowsing</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/IIS/Get-IisHttpHeader.ps1'>Get-IisHttpHeader</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/IIS/Set-IisHttpHeader.ps1'>Set-IisHttpHeader</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/IIS/Get-IisHttpRedirect.ps1'>Get-IisHttpRedirect</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/IIS/Set-IisHttpRedirect.ps1'>Set-IisHttpRedirect</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/IIS/Get-IisMimeMap.ps1'>Get-IisMimeMap</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/IIS/Remove-IisMimeMap.ps1'>Remove-IisMimeMap</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/IIS/Set-IisMimeMap.ps1'>Set-IisMimeMap</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/IIS/Disable-IisSecurityAuthentication.ps1'>Disable-IisSecurityAuthentication</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/IIS/Enable-IisSecurityAuthentication.ps1'>Enable-IisSecurityAuthentication</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/IIS/Get-IisSecurityAuthentication.ps1'>Get-IisSecurityAuthentication</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/IIS/Test-IisSecurityAuthentication.ps1'>Test-IisSecurityAuthentication</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/IIS/Add-IisServerManagerMember.ps1'>Add-IisServerManagerMember</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/IIS/Enable-IisSsl.ps1'>Enable-IisSsl</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/IIS/Get-IisVersion.ps1'>Get-IisVersion</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/IIS/Install-IisVirtualDirectory.ps1'>Install-IisVirtualDirectory</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/IIS/Join-IisVirtualPath.ps1'>Join-IisVirtualPath</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/IIS/Get-IisWebsite.ps1'>Get-IisWebsite</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/IIS/Install-IisWebsite.ps1'>Install-IisWebsite</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/IIS/Test-IisWebsite.ps1'>Test-IisWebsite</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/IIS/Uninstall-IisWebsite.ps1'>Uninstall-IisWebsite</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/IIS/Set-IisWebsiteID.ps1'>Set-IisWebsiteID</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/IIS/Set-IisWebsiteSslCertificate.ps1'>Set-IisWebsiteSslCertificate</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/IIS/Set-IisWindowsAuthentication.ps1'>Set-IisWindowsAuthentication</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Security/ConvertTo-InheritanceFlag.ps1'>ConvertTo-InheritanceFlag</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/INI/Split-Ini.ps1'>Split-Ini</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/INI/Remove-IniEntry.ps1'>Remove-IniEntry</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/INI/Set-IniEntry.ps1'>Set-IniEntry</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Windows Server/Disable-InternetExplorerEnhancedSecurityConfiguration.ps1'>Disable-InternetExplorerEnhancedSecurityConfiguration</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Windows Server/Enable-InternetExplorerEnhancedSecurityConfiguration.ps1'>Enable-InternetExplorerEnhancedSecurityConfiguration</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Network/Get-IPAddress.ps1'>Get-IPAddress</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Network/Test-IPAddress.ps1'>Test-IPAddress</a></p>
<h1 id="J"><a href="#index">J</a></h1>
<p>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/PowerShell/Complete-Job.ps1'>Complete-Job</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/FileSystem/Install-Junction.ps1'>Install-Junction</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/FileSystem/New-Junction.ps1'>New-Junction</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/FileSystem/Remove-Junction.ps1'>Remove-Junction</a></p>
<h1 id="K"><a href="#index">K</a></h1>
<p>-</p>
<h1 id="L"><a href="#index">L</a></h1>
<p>-</p>
<h1 id="M"><a href="#index">M</a></h1>
<p>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Windows/Get-MSI.ps1'>Get-MSI</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/MSMQ/Install-Msmq.ps1'>Install-Msmq</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/MSMQ/Get-MsmqMessageQueue.ps1'>Get-MsmqMessageQueue</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/MSMQ/Install-MsmqMessageQueue.ps1'>Install-MsmqMessageQueue</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/MSMQ/Test-MsmqMessageQueue.ps1'>Test-MsmqMessageQueue</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/MSMQ/Uninstall-MsmqMessageQueue.ps1'>Uninstall-MsmqMessageQueue</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/MSMQ/Get-MsmqMessageQueuePath.ps1'>Get-MsmqMessageQueuePath</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/MSMQ/Grant-MsmqMessageQueuePermission.ps1'>Grant-MsmqMessageQueuePermission</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/MSMQ/Reset-MsmqQueueManagerID.ps1'>Reset-MsmqQueueManagerID</a></p>
<h1 id="N"><a href="#index">N</a></h1>
<p>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Computer/Resolve-NetPath.ps1'>Resolve-NetPath</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Windows/Mount-NetworkDirectories.ps1'>Mount-NetworkDirectories</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/FileSystem/Disable-NtfsCompression.ps1'>Disable-NtfsCompression</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/FileSystem/Enable-NtfsCompression.ps1'>Enable-NtfsCompression</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/FileSystem/Test-NtfsCompression.ps1'>Test-NtfsCompression</a></p>
<h1 id="O"><a href="#index">O</a></h1>
<p>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/PowerShell PowerUp/Delete-ObsoleteLogFiles.ps1'>Delete-ObsoleteLogFiles</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Computer/Test-OSIs32Bit.ps1'>Test-OSIs32Bit</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Computer/Test-OSIs64Bit.ps1'>Test-OSIs64Bit</a></p>
<h1 id="P"><a href="#index">P</a></h1>
<p>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Windows/Get-Path.ps1'>Get-Path</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Windows/Get-PathAndFilename.ps1'>Get-PathAndFilename</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Path/Resolve-PathCase.ps1'>Resolve-PathCase</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/FileSystem/Test-PathIsJunction.ps1'>Test-PathIsJunction</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Path/Get-PathProvider.ps1'>Get-PathProvider</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/HostsFile/Get-PathToHostsFile.ps1'>Get-PathToHostsFile</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/PerformanceCounters/Get-PerformanceCounter.ps1'>Get-PerformanceCounter</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/PerformanceCounters/Install-PerformanceCounter.ps1'>Install-PerformanceCounter</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/PerformanceCounters/Test-PerformanceCounter.ps1'>Test-PerformanceCounter</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/PerformanceCounters/Test-PerformanceCounterCategory.ps1'>Test-PerformanceCounterCategory</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/PerformanceCounters/Uninstall-PerformanceCounterCategory.ps1'>Uninstall-PerformanceCounterCategory</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Security/Get-Permission.ps1'>Get-Permission</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Security/Grant-Permission.ps1'>Grant-Permission</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Security/Test-Permission.ps1'>Test-Permission</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/PowerShell/Invoke-PowerShell.ps1'>Invoke-PowerShell</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/PowerShell/Test-PowerShellIs32Bit.ps1'>Test-PowerShellIs32Bit</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/PowerShell/Test-PowerShellIs64Bit.ps1'>Test-PowerShellIs64Bit</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/PowerShell/Get-PowershellPath.ps1'>Get-PowershellPath</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/PowerShell PowerUp/Install-PowerShellPowerUp.ps1'>Install-PowerShellPowerUp</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/PowerShell PowerUp/Update-PowerShellPowerUp.ps1'>Update-PowerShellPowerUp</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Package Manager/Get-PPApp.ps1'>Get-PPApp</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Package Manager/Install-PPApp.ps1'>Install-PPApp</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/PowerShell PowerUp/Get-PPConfiguration.ps1'>Get-PPConfiguration</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/PowerShell PowerUp/Copy-PPConfigurationFile.ps1'>Copy-PPConfigurationFile</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Windows Event Log/Write-PPErrorEventLog.ps1'>Write-PPErrorEventLog</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Mail Reporting/Send-PPErrorReport.ps1'>Send-PPErrorReport</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Windows Event Log/Update-PPEventLog.ps1'>Update-PPEventLog</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Windows Event Log/Write-PPEventLog.ps1'>Write-PPEventLog</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Script/Get-PPScript.ps1'>Get-PPScript</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Script/Start-PPScript.ps1'>Start-PPScript</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/ScriptShortcut/Add-PPScriptShortcut.ps1'>Add-PPScriptShortcut</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/ScriptShortcut/Remove-PPScriptShortcut.ps1'>Remove-PPScriptShortcut</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint/Web/Export-PPSPWeb.ps1'>Export-PPSPWeb</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint/Web/Import-PPSPWeb.ps1'>Import-PPSPWeb</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Privileges/Get-Privilege.ps1'>Get-Privilege</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Privileges/Grant-Privilege.ps1'>Grant-Privilege</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Privileges/Revoke-Privilege.ps1'>Revoke-Privilege</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Privileges/Test-Privilege.ps1'>Test-Privilege</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Security/ConvertTo-PropagationFlag.ps1'>ConvertTo-PropagationFlag</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Security/ConvertTo-ProviderAccessControlRights.ps1'>ConvertTo-ProviderAccessControlRights</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/PowerShell/Export-PSCredential.ps1'>Export-PSCredential</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/PowerShell/Import-PSCredential.ps1'>Import-PSCredential</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Multi Remote Management/Connect-PSS.ps1'>Connect-PSS</a></p>
<h1 id="Q"><a href="#index">Q</a></h1>
<p></p>
<h1 id="R"><a href="#index">R</a></h1>
<p>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Multi Remote Management/Connect-RDP.ps1'>Connect-RDP</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Registry/Install-RegistryKey.ps1'>Install-RegistryKey</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Registry/Get-RegistryKeyValue.ps1'>Get-RegistryKeyValue</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Registry/Remove-RegistryKeyValue.ps1'>Remove-RegistryKeyValue</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Registry/Set-RegistryKeyValue.ps1'>Set-RegistryKeyValue</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Registry/Test-RegistryKeyValue.ps1'>Test-RegistryKeyValue</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Path/Resolve-RelativePath.ps1'>Resolve-RelativePath</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Multi Remote Management/Get-RemoteConnection.ps1'>Get-RemoteConnection</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Service/Restart-RemoteService.ps1'>Restart-RemoteService</a></p>
<h1 id="S"><a href="#index">S</a></h1>
<p>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Windows Scheduled Task/Update-ScheduledTask.ps1'>Update-ScheduledTask</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Multi Remote Management/Connect-SCP.ps1'>Connect-SCP</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Security/Convert-SecureStringToString.ps1'>Convert-SecureStringToString</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Service/Assert-Service.ps1'>Assert-Service</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Service/Install-Service.ps1'>Install-Service</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Service/Test-Service.ps1'>Test-Service</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Service/Uninstall-Service.ps1'>Uninstall-Service</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Service/Get-ServiceAcl.ps1'>Get-ServiceAcl</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Service/Set-ServiceAcl.ps1'>Set-ServiceAcl</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Service/Grant-ServiceControlPermission.ps1'>Grant-ServiceControlPermission</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Service/Get-ServicePermission.ps1'>Get-ServicePermission</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Service/Grant-ServicePermission.ps1'>Grant-ServicePermission</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Service/Revoke-ServicePermission.ps1'>Revoke-ServicePermission</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Service/Get-ServiceSecurityDescriptor.ps1'>Get-ServiceSecurityDescriptor</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Shares/Install-SmbShare.ps1'>Install-SmbShare</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint/Set-SPADGroupPermission.ps1'>Set-SPADGroupPermission</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint/Disable-SPBlobCache.ps1'>Disable-SPBlobCache</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint/Enable-SPBlobCache.ps1'>Enable-SPBlobCache</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint/List/Export-SPList.ps1'>Export-SPList</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint/List/Get-SPList.ps1'>Get-SPList</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint/List/Import-SPList.ps1'>Import-SPList</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint/List/Move-SPList.ps1'>Move-SPList</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint/List/Get-SPListFiles.ps1'>Get-SPListFiles</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Obsolete/Get-SPListItems.ps1'>Get-SPListItems</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Obsolete/Export-SPLists.ps1'>Export-SPLists</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Obsolete/Get-SPLists.ps1'>Get-SPLists</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint/Get-SPManagedMetadataServiceTerms.ps1'>Get-SPManagedMetadataServiceTerms</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Connect-SPO.ps1'>Connect-SPO</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint/Get-SPObjectPermissions.ps1'>Get-SPObjectPermissions</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Add-SPOCalculatedFieldtoList.ps1'>Add-SPOCalculatedFieldtoList</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Submit-SPOCheckIn.ps1'>Submit-SPOCheckIn</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Submit-SPOCheckOut.ps1'>Submit-SPOCheckOut</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Add-SPOChoiceFieldtoList.ps1'>Add-SPOChoiceFieldtoList</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Add-SPOChoicesToField.ps1'>Add-SPOChoicesToField</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Add-SPOCurrencyFieldtoList.ps1'>Add-SPOCurrencyFieldtoList</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Set-SPOCustomMasterPage.ps1'>Set-SPOCustomMasterPage</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Add-SPODateTimeFieldtoList.ps1'>Add-SPODateTimeFieldtoList</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Add-SPODocumentLibrary.ps1'>Add-SPODocumentLibrary</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Set-SPODocumentPermissions.ps1'>Set-SPODocumentPermissions</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Switch-SPOEnableDisableSolution.ps1'>Switch-SPOEnableDisableSolution</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Enable-SPOFeature.ps1'>Enable-SPOFeature</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Add-SPOField.ps1'>Add-SPOField</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Test-SPOField.ps1'>Test-SPOField</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Find-SPOFieldName.ps1'>Find-SPOFieldName</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Add-SPOFieldsToList.ps1'>Add-SPOFieldsToList</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Copy-SPOFile.ps1'>Copy-SPOFile</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Save-SPOFile.ps1'>Save-SPOFile</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Convert-SPOFileVariablesToValues.ps1'>Convert-SPOFileVariablesToValues</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Add-SPOFolder.ps1'>Add-SPOFolder</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Copy-SPOFolder.ps1'>Copy-SPOFolder</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Add-SPOGroup.ps1'>Add-SPOGroup</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Get-SPOGroup.ps1'>Get-SPOGroup</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Add-SPOList.ps1'>Add-SPOList</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Add-SPOListItems.ps1'>Add-SPOListItems</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Set-SPOListPermissions.ps1'>Set-SPOListPermissions</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Set-SPOMasterPage.ps1'>Set-SPOMasterPage</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Add-SPONoteFieldtoList.ps1'>Add-SPONoteFieldtoList</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Add-SPONumberFieldtoList.ps1'>Add-SPONumberFieldtoList</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Join-SPOParts.ps1'>Join-SPOParts</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Add-SPOPictureLibrary.ps1'>Add-SPOPictureLibrary</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Get-SPOPrincipal.ps1'>Get-SPOPrincipal</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Add-SPOPrincipalToGroup.ps1'>Add-SPOPrincipalToGroup</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Get-SPORole.ps1'>Get-SPORole</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Open-SPORootsite.ps1'>Open-SPORootsite</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Open-SPOSite.ps1'>Open-SPOSite</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Add-SPOSolution.ps1'>Add-SPOSolution</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Install-SPOSolution.ps1'>Install-SPOSolution</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Uninstall-SPOSolution.ps1'>Uninstall-SPOSolution</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Get-SPOSolutionId.ps1'>Get-SPOSolutionId</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Convert-SPOStringVariablesToValues.ps1'>Convert-SPOStringVariablesToValues</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Add-SPOSubsite.ps1'>Add-SPOSubsite</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Open-SPOSubsite.ps1'>Open-SPOSubsite</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Add-SPOTextFieldtoList.ps1'>Add-SPOTextFieldtoList</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Add-SPOUserFieldtoList.ps1'>Add-SPOUserFieldtoList</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Add-SPOWebpart.ps1'>Add-SPOWebpart</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Set-SPOWebPermissions.ps1'>Set-SPOWebPermissions</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint Online/Request-SPOYesOrNo.ps1'>Request-SPOYesOrNo</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint/Get-SPUrl.ps1'>Get-SPUrl</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SharePoint/Web/Move-SPWeb.ps1'>Move-SPWeb</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Obsolete/Get-SPWebs.ps1'>Get-SPWebs</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SQLServer/Run-SQLServerAgentJob.ps1'>Run-SQLServerAgentJob</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/SQLServer/Load-SQLServerManagementObjects.ps1'>Load-SQLServerManagementObjects</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Multi Remote Management/Connect-SSH.ps1'>Connect-SSH</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Certificates/Get-SslCertificateBinding.ps1'>Get-SslCertificateBinding</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Certificates/Remove-SslCertificateBinding.ps1'>Remove-SslCertificateBinding</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Certificates/Set-SslCertificateBinding.ps1'>Set-SslCertificateBinding</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Certificates/Test-SslCertificateBinding.ps1'>Test-SslCertificateBinding</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Cryptography/Protect-String.ps1'>Protect-String</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Cryptography/Unprotect-String.ps1'>Unprotect-String</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/PowerShell/Convert-StringToScriptBlock.ps1'>Convert-StringToScriptBlock</a></p>
<h1 id="T"><a href="#index">T</a></h1>
<p>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/FileSystem/New-TempDir.ps1'>New-TempDir</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/PowerShell/New-TreeObjectArray.ps1'>New-TreeObjectArray</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/PowerShell/Get-TreeObjectArrayAsList.ps1'>Get-TreeObjectArrayAsList</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/TrueCrypt/Dismount-TrueCryptContainer.ps1'>Dismount-TrueCryptContainer</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/TrueCrypt/Mount-TrueCryptContainer.ps1'>Mount-TrueCryptContainer</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/TrueCrypt/Get-TrueCyptContainer.ps1'>Get-TrueCyptContainer</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/PowerShell/Add-TrustedHost.ps1'>Add-TrustedHost</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/PowerShell/Clear-TrustedHost.ps1'>Clear-TrustedHost</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/PowerShell/Get-TrustedHost.ps1'>Get-TrustedHost</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/PowerShell/Set-TrustedHost.ps1'>Set-TrustedHost</a></p>
<h1 id="U"><a href="#index">U</a></h1>
<p>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/Path/Test-UncPath.ps1'>Test-UncPath</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/UsersAndGroups/Install-User.ps1'>Install-User</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/UsersAndGroups/Test-User.ps1'>Test-User</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/UsersAndGroups/Uninstall-User.ps1'>Uninstall-User</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Windows Server/Disable-UserAccessControl.ps1'>Disable-UserAccessControl</a></p>
<h1 id="V"><a href="#index">V</a></h1>
<p>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Multi Remote Management/Connect-VM.ps1'>Connect-VM</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Multi Remote Management/Connect-VSphere.ps1'>Connect-VSphere</a></p>
<h1 id="W"><a href="#index">W</a></h1>
<p>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/WindowsFeatures/Get-WindowsFeature.ps1'>Get-WindowsFeature</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/WindowsFeatures/Install-WindowsFeature.ps1'>Install-WindowsFeature</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/WindowsFeatures/Test-WindowsFeature.ps1'>Test-WindowsFeature</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/WindowsFeatures/Uninstall-WindowsFeature.ps1'>Uninstall-WindowsFeature</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/WindowsFeatures/Assert-WindowsFeatureFunctionsSupported.ps1'>Assert-WindowsFeatureFunctionsSupported</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/WindowsFeatures/Resolve-WindowsFeatureName.ps1'>Resolve-WindowsFeatureName</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/MSI/Invoke-WindowsInstaller.ps1'>Invoke-WindowsInstaller</a> <br/>
<a href='https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Carbon/UsersAndGroups/Get-WmiLocalUserAccount.ps1'>Get-WmiLocalUserAccount</a></p>
<h1 id="X"><a href="#index">X</a></h1>
<p>-</p>
<h1 id="Y"><a href="#index">Y</a></h1>
<p>-</p>
<h1 id="Z"><a href="#index">Z</a></h1>
<p>-</p>

# Built-in Modules

By adding scripts and [configuration files](wiki/configuration-files) to the config folder you can make use of this features:

### Multi Remote Management

Use your PowerShell installation as an remote management software.

Supported protocols:

* rdp = Remote Deskopt Protocol (Microsoft Remote Desktop Connections)
* rps = Remote Powershell Session (PowerShell Remoting)
* http = Hypertext Transfer Protocol (default browser)
* https = Secure Hypertext Transfer Protocol (default browser)
* ssh = Secure Shell (Putty)
* scp = Secure Copy (WinSCP)
* ftp = File Transfer Protocol (WinSCP)
* sftp = Secutre File Transfer Protocol (WinSCP)
* vmware = custom WMware protocols (VMware PowerCLI)

**Installation**

Add remote configuration file to the config folder `$PSconfigs.Path`:

Run `Copy-Item $(Get-Childitem -Filter $PSconfigs.Remote.Filter $PStemplates.Path -Recurse).Fullname $PSconfigs.Path`

Rename `EXAMPLE.remote.config.xml` to `[SOMETHING].remote.config.xml`

Edit `[SOMETHING].remote.config.xml`

**Options**

* Key: A short and unique name to identify the remote device
* Name: IP or Hostname
* User (optional): [Domain]\\[Username] or [Username]@[Domain]
* Description (optional): Add comments or a short description for the device
* Protocol (optional): Use this modification if the [default port](http://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers) doesn't match.
	* Name: Protocolname
	* Port: Set new port number 
* SnapIns (optional): will be loaded when connecting with rps
* PrivatKey (optional): Path to your private key file (PowerShell variables allowed)

**Commands**

* `Get-RemoteConnection` alias: grc
* `Connect-PSS` alias: crps
* `Connect-RDP` alias: crdp
* `Connect-Http` alias: chttp
* `Connect-SSH` alias: cssh
* `Connect-SCP` alias: cscp
* `Connect-FTP` alias: cftp
* `Connect-VSphere` alias: cvs
* `Connect-VM` alias: cvm

### Connect HTTPSession

[`Connect-Http`](https://github.com/janikvonrotz/Powershell-Profile/blob/master/functions/Multi%20Remote%20Management/Connect-HTTP.ps1) alias: chttp

To force a connection with https instead with the default http, add this code to the selected servers in the remote configuration file:

`<Protocol Name="https" Port=""></Protocol>`

If the server isn't configured in the configuration file, add the parameter [-Secure]:

`Connect-HTTPSession 192.168.90.2 -Secure`

### Package Manager

Package Manger allows you to integrate custom application installers in order to distribute them on you server.

Compared to other package managers this one doesn't depend on a online web service. The install definitions are stored in the lib hub.

**Commands**

* [`Get-File`](https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Package%20Manager/Get-File.ps1)
* [`Get-PPApp`](https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Package%20Manager/Get-PPApp.ps1)
* [`Install-PPApp`](https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Package%20Manager/Install-PPApp.ps1)

### Windows Scheduled Task

Add task config files from the template folder to the config folder and run the update command.
The defined task will be automatically added to the windows task scheduler.

**Commands**

* [`Update-ScheduledTask`](https://github.com/janikvonrotz/PowerShell-Profile/blob/master/functions/Windows%20Scheduled%20Task/Update-ScheduledTask.ps1)

### Windows Event Log

* Report to the windows event log.
* Create and update a custom event log.

**Installation**

Copy and alter an eventlog config file from the template folder to the config folder.
The update command will create or update your custom eventlog based on the configuration files in the config folder.

**Commands

* [`Update-PPEventLog`](https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Windows%20Event%20Log/Update-PPEventLog.ps1)
* [`Write-PPErrorEventLog`](https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Windows%20Event%20Log/Write-PPErrorEventLog.ps1)
* [`Write-PPEventLog`](https://github.com/janikvonrotz/PowerShell-PowerUp/blob/master/functions/Windows%20Event%20Log/Write-PPEventLog.ps1)

# Installation and Configuration

The installation and the installed profile script using the project folders and the related PowerShell global variables from the [`Microsoft.PowerShell_profile.config.ps1`](https://github.com/janikvonrotz/Powershell-PowerUp/blob/master/Microsoft.PowerShell_profile.config.ps1) file.

### Configuration files

You can merge multiple configuration types in one configuration file as long they're not part of standalone configuration files or distribute the the configurations into multiple files in multiple directoryies.

To load configurations you have several possibilities:

Load the configuration files with predefined filters:
`Get-ChildItem -Path $PSconfigs.Path -Filter $PSconfigs.Mail.Filter -Recurse | %{[xml]$(get-content $_.FullName)}`

Load the configuration type from several configuration files
`Get-ChildItem -Path $PSconfigs.Path -Filter $PSconfigs.File.Filter -Recurse | %{[xml]$(get-content $_.FullName)} | %{$_.Content.Feature}`

Load the app configurations from the lib folder:
`Get-ChildItem -Path $PSlib.Path -Filter $PSconfigs.App.Filter -Recurse | %{[xml]$(get-content $_.FullName)}`

Or use the [`Get-PPConfiguration`](https://github.com/janikvonrotz/Powershell-Profile/blob/master/functions/PowerShell%20Profile/Get-PPConfiguration.ps1) function

### Configuration Files and Types

The configuration files for the different configuration types are stored in the template folder. Each folder represent a configuration file type.

**File**
This is the root configuration file type.  
Filename: `$PSconfigs.File.Filter`  
XMLNameSpace1: Content

**App**
This configuration type is stored in the lib folder.  
Filename: `$PSconfigs.App.Filter`  
Datafile: `$PSconfigs.App.Datafile`  
XMLNameSpace1: Content.App  
XMLNameSpace2: Content.PackageManager  

**EventLog**
Filename: `$PSconfigs.EventLog.Filter`  
XMLNameSpace1: Content.Eventlog  

**Mail**
Filename: `$PSconfigs.Mail.Filter`   
XMLNameSpace1: Content.Mail   

**Profile**
Filename: `$PSconfigs.Profile.Filter`  
XMLNameSpace1: Content.Feature   
XMLNameSpace2: Content.SystemVariable  

**Script**
Filename: `$PSconfigs.Script.Filter`  
XMLNameSpace1: Content.Script

**Server**
Filename: `$PSconfigs.Server.Filter`  
XMLNameSpace1: Content.Server

**TrueCryptContainer**
Filename: `$PSconfigs.TrueCryptContainer.Filter`   
XMLNameSpace1: Content.TrueCryptContainer

**User**
Filename: `$PSconfigs.User.Filter`  
XMLNameSpace1: Content.User

### Standalone Configuration Files

These files aren't merge able with other configuratio files, also they were created by an function or a third party pogramm. 

**Credential**
Filename: `$PSconfigs.credential.Filter`     
Use the [`Export-PSCredential`](https://github.com/janikvonrotz/Powershell-Profile/blob/master/functions/PowerShell/Export-PSCredential.ps1) command to create this configuration file.

**Task**
Filename: `$PSconfigs.Task.Filter`  
Use the export function from the windows job console or copy a template from the template folder.  
The PowerShell Profile task configuration files are extended with an additional description field to store the job name of the task.

### Data Files

These fils are used to save configurations for PowerShell PowerUp modules

**Package Manager**
Filename: `$PSconfigs.App.DataFile`

### Temporary Data Files

These files are temporary data files used by the PowerShell PowerUp modules.

**Script Shortcut**
Filename: `$PSconfigs.ScriptShortcut.DataFile`

**TrueCryptContainer**
Filename: `$PSconfigs.TrueCryptContainer.DataFile`   

## Hubs

The heart of PowerShell PowerUp are the following folders, based on these folders you'll find a global variable containing the path to the folder and further useful stuff.

* Variable: `$PSapps`
    * Application variables used by PowerShell PowerUp
	
* Variable: `$PSconfigs` and folder: configs
    * Add the PowerShell PowerUp config files to this folder.
    * There aren't any definitions for the folder structure.
	
* Variable: `$PSfunctions` and folder: functions
    * Add the PowerShell function scripts to this folder
    * There aren't any definitions for the folder structure.
	
* Variable: `$PSlogs` and folder: logs
    * If transcription is enabled, logs will be stored in this folder.

* Variable: `$PSbin` and folder: bin
    * This folder will be added to the system path environment variable.
    * This folder contains links to binaries mostly used by the package installer.

* Variable: `$PSlib` and folder: lib
    * This folder contains dlls and modules used by PowerShell PowerUp.
    * This is  the repository for the PowerShell PowerUp Package Manager.

* Variable: `$PSscripts` and folder: scripts
    * Store your scripts here.
	
* templates `$PStemplates`
    * This folder contains the templates for the PowerShell PowerUp config files.
