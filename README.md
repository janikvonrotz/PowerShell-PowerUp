Powershell-Profile
==================

It's more than just a PowerShell profile script, follow the install guide and you'll get a PowerShell scripting IDE with the most advanced configurations for your client and server environment.
Checkout the wiki page for more information.

##How to install##

Download Portable Git for Windows from:

	https://code.google.com/p/msysgit/downloads/list
	
Unzip in a directory of your choice.

Execute the:

	git-cmd.bat 
	
and clone the Powershell Profile Project in a directory of your choice:

	git clone git://github.com/janikvonrotz/Powershell-Profile.git

In case of an error like this:

	0 [main] us 0 init_cheap: VirtualAlloc pointer is null, Win32 error 487
	AllocationBase 0x0, BaseAddress 0x71110000, RegionSize 0x350000, State 0x10000
	\msys\bin\make.exe: *** Couldn't reserve space for cygwin's heap, Win32 error 0

Checkout this [link](http://support.code-red-tech.com/CodeRedWiki/VirtualAllocPointerNull)

When the download finished successfully...

	COPY    \Powershell-Profile\templates\EXAMPLE.profile.config.xml
	
	TO    \Powershell-Profile\config\... 
	
And 
	
	RENAME    EXAMPLE.profile.config.xml    TO    >SOMETHING<.profile.config.xml

Now take your time to edit your new PowerShell Profile config file.
Checkout the wiki page for more information.

	EDIT    [SOMETHING].profile.config.xml
	
Open your Powershell commandline and enter:

	PS C:\Powershell-Profile> Set-ExecutionPolicy unrestricted
	
Or depending on your windows security restrictions:
	
	PS C:\Powershell-Profile> Set-ExecutionPolicy bypass

At last execture the install script from commad line:

	PS C:\Powershell-Profile> .\ProfileInstallation.ps1

And the magic is done <3


	
