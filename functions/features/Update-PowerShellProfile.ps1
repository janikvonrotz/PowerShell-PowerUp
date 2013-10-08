function Update-PowerShellProfile{

	if(!(Get-Command "git" -ErrorAction SilentlyContinue)){

		cinst git -force
	}

	cd $PSProfile.Path
	
	if(!(Test-Path -Path (Join-Path -Path $PSProfile.Path -ChildPath ".git"))){

		# initialise git repository
		git init
		git remote add origin "git://github.com/janikvonrotz/Powershell-Profile.git"
		git fetch origin
		git reset --hard origin/master
		
	}else{

		git fetch origin
		git reset --hard origin/master

	}
	
	Pop-Location -StackName "WorkingPath"
}