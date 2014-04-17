<#
$Metadata = @{
	Title = "Uninstall IisWebsite"
	Filename = "Uninstall-IisWebsite.ps1"
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

function Uninstall-IisWebsite
{
    <#
    .SYNOPSIS
    Removes a website

    .DESCRIPTION
    Pretty simple: removes the website named `Name`.  If no website with that name exists, nothing happens.

    .LINK
    Get-IisWebsite
    
    .LINK
    Install-IisWebsite
    
    .EXAMPLE
    Uninstall-IisWebsite -Name 'MyWebsite'
    
    Removes MyWebsite.

    .EXAMPLE
    Uninstall-IisWebsite 1

    Removes the website whose ID is 1.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]
        # The name or ID of the website to remove.
        $Name
    )
    
    if( Test-IisWebsite -Name $Name )
    {
        Invoke-AppCmd delete site `"$Name`"
    }
}

Set-Alias -Name 'Remove-IisWebsite' -Value 'Uninstall-IisWebsite'
