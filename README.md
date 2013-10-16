Powershell-Profile
==================

It's more than just a PowerShell profile script, follow the install guide and you'll get a PowerShell scripting IDE with the most advanced configurations for your client and server environment.
Checkout the [wiki page](https://github.com/janikvonrotz/Powershell-Profile/wiki) for more information.

##How to install##

Download the latest release:

![GitHub Download ZIP](https://raw.github.com/janikvonrotz/Powershell-Profile/master/doc/GitHub%20Download%20ZIP.png)

and unzip it in the directory of your choice OR use git to clone the whole repository:

	git clone git://github.com/janikvonrotz/Powershell-Profile.git

Now add a profile configuration file to the config folder:

	COPY    \templates\EXAMPLE.profile.config.xml    TO    \config\... 
	
And
	
	RENAME    EXAMPLE.profile.config.xml    TO    [SOMETHING].profile.config.xml

Now take your time to edit your new PowerShell Profile config file.
Checkout the [wiki page](https://github.com/janikvonrotz/Powershell-Profile/wiki) for more information.

	EDIT    [SOMETHING].profile.config.xml

	SAVE    [SOMETHING].profile.config.xml
	
Open your Powershell commandline and enter:

	PS C:\Powershell-Profile> Set-ExecutionPolicy remotesigned
	
Or depending on your windows security restrictions:
	
	PS C:\Powershell-Profile> Set-ExecutionPolicy unrestricted

At last execute the install script from the PowerShell commad line:

	PS C:\Powershell-Profile> .\Microsoft.PowerShell_profile.install.ps1
