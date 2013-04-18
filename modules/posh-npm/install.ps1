# Adapted from https://github.com/dahlbyk/posh-git

if($PSVersionTable.PSVersion.Major -lt 2) {
    Write-Warning "posh-npm requires PowerShell 2.0 or better; you have version $($Host.Version)."
    return
}

if(!(Test-Path $PROFILE)) {
    Write-Host "Creating PowerShell profile...`n$PROFILE"
    New-Item $PROFILE -Force -Type File -ErrorAction Stop > $null
}

if(!(Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Warning 'Could not find npm command. Please ensure nodejs is installed and that %ProgramFiles%\nodejs is in your PATH.'
    return
}

$installDir = Split-Path $MyInvocation.MyCommand.Path -Parent
$profilePath = Join-Path $installDir profile.example.ps1

if(!(Test-Path $profilePath)) {
    Write-Warning 'Could not find profile.example.ps1.'
    return
}

# Adapted from http://www.west-wind.com/Weblog/posts/197245.aspx
function Get-FileEncoding($Path) {
    $bytes = [byte[]](Get-Content $Path -Encoding byte -ReadCount 4 -TotalCount 4)

    if(!$bytes) { return 'utf8' }

    switch -regex ('{0:x2}{1:x2}{2:x2}{3:x2}' -f $bytes[0],$bytes[1],$bytes[2],$bytes[3]) {
        '^efbbbf'   { return 'utf8' }
        '^2b2f76'   { return 'utf7' }
        '^fffe'     { return 'unicode' }
        '^feff'     { return 'bigendianunicode' }
        '^0000feff' { return 'utf32' }
        default     { return 'ascii' }
    }
}

$profileLine = ". '$profilePath'"
if(Select-String -Path $PROFILE -Pattern $profileLine -Quiet -SimpleMatch) {
    Write-Host "It seems posh-npm is already installed..."
    return
}

Write-Host "Adding posh-npm to profile..."
@"

# Load posh-npm example profile
$profileLine

"@ | Out-File $PROFILE -Append -Encoding (Get-FileEncoding $PROFILE)

Write-Host 'posh-npm sucessfully installed!'
Write-Host 'Please reload your profile for the changes to take effect:'
Write-Host '    . $PROFILE'
