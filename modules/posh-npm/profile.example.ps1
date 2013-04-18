Push-Location (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)

# Load posh-npm module from current directory
Import-Module .\posh-npm

# If module is installed in a default location ($env:PSModulePath),
# use this instead (see about_Modules for more information):
# Import-Module posh-npm

Pop-Location
