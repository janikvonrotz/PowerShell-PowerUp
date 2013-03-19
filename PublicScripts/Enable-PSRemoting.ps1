$Metadata = @{
	Title = "Enable Powershell Remoting"
	Filename = "Enable-PSRemoting.ps1"
	Description = "[Description]"
	Tags = "powershell, remoting"
	Project = "[Projectname]"
	Author = "Janik von Rotz"
	AuthorEMail = "contact@janikvonrotz.ch"
	CreateDate = "2012-12-20"
	LastEditDate = "2013-03-18"
	Version = "1.0.1"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}

Enable-PSRemoting

Set-Item WSMan:\localhost\Client\TrustedHosts "RemoteComputer" -Force

Set-Item WSMan:\localhost\Shell\MaxMemoryPerShellMB 1024

restart-Service WinRM

Write-Host "`nFinished" -BackgroundColor Green -ForegroundColor Black
Read-Host "`nPress Enter to exit"