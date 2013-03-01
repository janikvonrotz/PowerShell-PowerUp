#--------------------------------------------------#
#  Title: New Link
#--------------------------------------------------#
#  File name: New-Link.ps1
#  Description: [Description]
#  Tags: powershell, functions
#  Project: [Projectname]
#
#  Author: Janik von Rotz
#  Author E-Mail: contact@janikvonrotz.ch
#
#  Create Date: 02.01.2012
#  Last Edit Date: 08.01.2013
#  Version: 1.0.1
#
#  License:
#  This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
#  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
#  send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
#
#  Url: https://gist.github.com/2891103
#--------------------------------------------------#

  #  Create a Symlink
function New-Symlink {
    <#
    .SYNOPSIS
        Creates a symbolic link.
    #>
    param (
        [Parameter(Position=0, Mandatory=$true)]
        [string] $Link,
        [Parameter(Position=1, Mandatory=$true)]
        [string] $Target
    )
 
    Invoke-MKLINK -Link $Link -Target $Target -Symlink
}

  #  Create a Hardlink
function New-Hardlink {
    <#
    .SYNOPSIS
        Creates a hard link.
    #>
    param (
        [Parameter(Position=0, Mandatory=$true)]
        [string] $Link,
        [Parameter(Position=1, Mandatory=$true)]
        [string] $Target
    )
 
    Invoke-MKLINK -Link $Link -Target $Target -HardLink
}

  #  Create a Junction
function New-Junction {
    <#
    .SYNOPSIS
        Creates a directory junction.
    #>
    param (
        [Parameter(Position=0, Mandatory=$true)]
        [string] $Link,
        [Parameter(Position=1, Mandatory=$true)]
        [string] $Target
    )
 
    Invoke-MKLINK -Link $Link -Target $Target -Junction
}

  #  Create a Link with Option
function Invoke-MKLINK {
    <#
    .SYNOPSIS
        Creates a symbolic link, hard link, or directory junction.
    #>
    [CmdletBinding(DefaultParameterSetName = "Symlink")]
    param (
        [Parameter(Position=0, Mandatory=$true)]
        [string] $Link,
        [Parameter(Position=1, Mandatory=$true)]
        [string] $Target,
 
        [Parameter(ParameterSetName = "Symlink")]
        [switch] $Symlink = $true,
        [Parameter(ParameterSetName = "HardLink")]
        [switch] $HardLink,
        [Parameter(ParameterSetName = "Junction")]
        [switch] $Junction
    )
 
    #  Ensure target exists.
    if (-not(Test-Path $Target)) {
        throw "Target does not exist.`nTarget: $Target"
    }
 
    #  Ensure link does not exist.
    if (Test-Path $Link) {
        throw "A file or directory already exists at the link path.`nLink: $Link"
    }
 
    $isDirectory = (Get-Item $Target).PSIsContainer
    $mklinkArg = ""
 
    if ($Symlink -and $isDirectory) {
        $mkLinkArg = "/D"
    }
 
    if ($Junction) {
        #  Ensure we are linking a directory. (Junctions don't work for files.)
        if (-not($isDirectory)) {
            throw "The target is a file. Junctions cannot be created for files.`nTarget: $Target"
        }
 
        $mklinkArg = "/J"
    }
 
    if ($HardLink) {
        #  Ensure we are linking a file. (Hard links don't work for directories.)
        if ($isDirectory) {
            throw "The target is a directory. Hard links cannot be created for directories.`nTarget: $Target"
        }
 
        $mkLinkArg = "/H"
    }
 
 	#  Capture the MKLINK output so we can return it properly.
    #  Includes a redirect of STDERR to STDOUT so we can capture it as well.
	    $output = cmd /c mklink $mkLinkArg "$Link" "$Target" 2>&1
 
    if ($lastExitCode -ne 0) {
        throw "MKLINK failed. Exit code: $lastExitCode`n$output"
    }
    else {
        Write-Output $output
    }
}

