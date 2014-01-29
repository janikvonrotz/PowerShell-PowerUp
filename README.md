PowerShell-PowerUp
==================

	    _/_/_/    _/_/_/        _/
	   _/    _/  _/    _/      _/
	  _/_/_/    _/_/_/    _/_/_/_/_/
	 _/        _/            _/
	_/        _/            _/    

PowerShell PowerUp is a Server Management Framework.
Checkout the [wiki page](https://github.com/janikvonrotz/PowerShell-PowerUp/wiki) for more information.

# References

> Holy fucking creeper shit, this is the best PowerShell Server Management Framework I've used!

-- You in a few seconds

#How to install

Download the latest release:

![GitHub Download ZIP](https://raw.github.com/janikvonrotz/PowerShell-PowerUp/master/doc/GitHub%20Download%20ZIP.png)

and unzip it in the directory of your choice OR use git to clone the whole repository:

	git clone git://github.com/janikvonrotz/PowerShell-PowerUp.git

Now add a profile configuration file to the config folder:

	COPY    \templates\Profile\Example.profile.config.xml    TO    \config\... 
	
And
	
	RENAME    Example.profile.config.xml    TO    [Something].profile.config.xml

Now take your time to edit your new PowerShell PowerUp profile config file.
Checkout the [wiki page](https://github.com/janikvonrotz/PowerShell-PowerUp/wiki#custom-features) for more information.

	EDIT    [Something].profile.config.xml

	SAVE    [Something].profile.config.xml
	
Open your Powershell commandline and enter:

	PS C:\PowerShell-PowerUp> Set-ExecutionPolicy remotesigned
	
Or depending on your windows security restrictions:
	
	PS C:\PowerShell-PowerUp> Set-ExecutionPolicy unrestricted

At last execute the install script from the PowerShell commad line:

	PS C:\PowerShell-PowerUp> .\Microsoft.PowerShell_profile.install.ps1
