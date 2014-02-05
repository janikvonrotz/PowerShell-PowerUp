function Update-PowerShellPowerUp{

	if(!(Get-Command "git" -ErrorAction SilentlyContinue)){

		Install-PPApp Git
	}

	cd $PSProfile.Path
	
	if(!(Test-Path -Path (Join-Path -Path $PSProfile.Path -ChildPath ".git"))){

		git init
		git remote add origin $PSProfile.GitSource

		
	}elseif($(git config --get remote.origin.url) -ne $PSProfile.GitSource){

        git remote set-url origin $PSProfile.GitSource
    }

	git fetch origin
	git reset --hard origin/master
	
	Set-Location $WorkingPath
}