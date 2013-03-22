Powershell-Profile
==================

One of the most advanced Powershell profile configurations for Administrators.

##How to install:##

Download Portable Git for Windows from

	https://code.google.com/p/msysgit/downloads/list
	
Unzip it wherever you want

Execute the git-cmd.bat and clone the Powershell Profile Project

	git clone git://github.com/janikvonrotz/Powershell-Profile.git
	
Now copy the Git Portable Content into the following folder

	.\Powershell-Profile\Apps\Git\
	
It should look now like this

	\Powershell-Profile\Apps\Git\
	|
	|-bin\
	|-cmd\
	\-...\

Edit the config.xml file and head for the feature section. Now decide wether you would like to enable the auto update feature and save the config.xml file.
	
	Edit config.xml
	
Open your Powershell commandline and enter:

	PS C:\Powershell-Profile> Set-ExecutionPolicy bypass

Confirm every prompt

Excute the install script

	PS C:\Powershell-Profile> .\ProfileInstallation.ps1

	
