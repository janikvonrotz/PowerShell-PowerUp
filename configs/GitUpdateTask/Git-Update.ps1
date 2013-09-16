if(!(Get-Command "git")){

    cinst git -force
}

if(!(Test-Path -Path (Join-Path -Path $PSProfilePath -ChildPath ".git"))){
    
    cd $PSProfilePath

    # initialise git repository
    git init
    git add remote origin "git://github.com/janikvonrotz/Powershell-Profile.git"
    git fetch origin
    git reset --hard origin/master


    Pop-Location -StackName "WorkingPath"

}else{

    git fetch origin
    git reset --hard origin/master

}