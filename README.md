Powershell-Profile
==================

One of the most advanced Powershell profile configurations for Administrators.

##What you'll get##

* Powershell profile installation with some advanced features:
    * Install the profile in the folder of your choice
    * Add default registry keys
    * Create System Path Variables
    * Add the context menu feature "Open Powershell here"
    * Register your profile for further updates through the GitHub repo
    * Enable Powershell Remoting
* Powershell profile configurations:
    * Auto logger for every powershell session
    * Default Settings for the console
    * Auto loader for custom functions (function folder)
    * Easy integration of new Powershell modules (Just add them to the modules folder or download them with PsGet)
* Powershell IDE:
    * Manage your remote configurations (Enter Get-RemoteConfigurations -ListAvailable to start)
    * Get some powerfull and sophisticated Powershell scripts (scripts folder)

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

##[Roadmap](http://roadma.ps/2NR "Roadmap")###


	
