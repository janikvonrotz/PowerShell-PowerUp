posh-npm
========

A set of PowerShell scripts which provide npm/PowerShell integration

### Tab completion
   Provides tab completion for commands when using npm.  
   E.g. `npm ins<tab>` --> `npm install`
   
Usage
-----

See `profile.example.ps1` as to how you can integrate the tab completion into your own profile.

If you have [psget](https://github.com/psget/) installed, you can install posh-npm like using the following command:

`install-module posh-npm`

Installing
----------

0. Verify you have PowerShell 2.0 or better with $PSVersionTable.PSVersion

1. Verify execution of scripts is allowed with `Get-ExecutionPolicy` (should be `RemoteSigned` or `Unrestricted`). If scripts are not enabled, run PowerShell as Administrator and call `Set-ExecutionPolicy RemoteSigned -Confirm`.

2. Verify that `npm` can be run from PowerShell. If the command is not found, you will need to install nodejs.

3. Clone the posh-npm repository to your local machine.

4. From the posh-npm repository directory, run `powershell ./install.ps1`. If you are in powershell, run `./install.ps1` and then `. $PROFILE`.

Acknowledgements
----------------
The powershell integration and installation is based on posh-git. https://github.com/dahlbyk/posh-git

