<#
$Metadata = @{
	Title = "Install RegistryKey"
	Filename = "Install-RegistryKey.ps1"
	Description = ""
	Tags = "powershell, carbon"
	Project = "http://get-carbon.org/"
	Author = "Aaron Jensen"
	AuthorContact = "http://pshdo.com/"
	CreateDate = "2012-01-01"
	LastEditDate = "2014-04-17"
	Url = ""
	Version = "1.6.0"
	License = @'
# Copyright 2012 Aaron Jensen
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
'@
}
#>

function Install-RegistryKey
{
    <#
    .SYNOPSIS
    Creates a registry key.  If it already exists, does nothing.
    
    .DESCRIPTION
    Given the path to a registry key, creates the key and all its parents.  If the key already exists, nothing happens.
    
    .EXAMPLE
    Install-RegistryKey -Path 'hklm:\Software\Carbon\Test'
    
    Creates the `hklm:\Software\Carbon\Temp` registry key if it doesn't already exist.
    #>
    [CmdletBinding(SupportsShouldPRocess=$true)]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The path to the registry key to create.
        $Path
    )
    
    if( -not (Test-Path -Path $Path -PathType Container) )
    {
        Write-Host "Creating registry key '$Path'."
        $null = New-Item -Path $Path -ItemType RegistryKey -Force
    }
}

