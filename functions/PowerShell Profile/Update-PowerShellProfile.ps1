function Update-PowerShellProfile{

	if(!(Get-Command "git" -ErrorAction SilentlyContinue)){

		cinst git -force
	}

	cd $PSProfile.Path
	
	if(!(Test-Path -Path (Join-Path -Path $PSProfile.Path -ChildPath ".git"))){

		# initialise git repository
		git init
		git remote add origin $PSProfile.GitSource
		git fetch origin
		git reset --hard origin/master
		
	}else{

		git fetch origin
		git reset --hard origin/master

	}
	
	Set-Location $WorkingPath
}