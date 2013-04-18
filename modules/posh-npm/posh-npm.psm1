if (Get-Module posh-npm) { return }

Push-Location $psScriptRoot
. ./NpmTabExpansion.ps1
Pop-Location

Export-ModuleMember -Function @(
        'TabExpansion')

