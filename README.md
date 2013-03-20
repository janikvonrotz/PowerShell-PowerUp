Powershell-Profile
==================

One of the most advanced Powershell profile configurations for Administrators.

##How to install:##

	PS C:\Powershell-Profile> Set-ExecutionPolicy bypass

	Ausführungsrichtlinie ändern
	Die Ausführungsrichtlinie trägt zum Schutz vor nicht vertrauenswürdigen Skripts bei. Wenn Sie die Ausführungsrichtlinie
	 ändern, sind Sie möglicherweise den im Hilfethema "about_Execution_Policies" beschriebenen Sicherheitsrisiken
	ausgesetzt. Möchten Sie die Ausführungsrichtlinie ändern?
	[J] Ja  [N] Nein  [H] Anhalten  [?] Hilfe (Standard ist "J"): J

Edit the config.xml file


	PS C:\Powershell-Profile> .\ProfileInstallation.ps1

##Configure Git:##

Download Portable Git for Windows from

	https://code.google.com/p/msysgit/downloads/list
	
Install Git for Windows to the Apps folder

	Powershell-Profile\Apps\Git\
	 |
	 |-bin
	 |-cmd
	 |-doc
	 \-...