<#
$Metadata = @{
	Title = "Join IisVirtualPath"
	Filename = "Join-IisVirtualPath.ps1"
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

function Join-IisVirtualPath
{
    <#
    .SYNOPSIS
    Combines a path and a child path for an IIS website, application, virtual directory into a single path.  

    .DESCRIPTION
    Removes extra slashes.  Converts backward slashes to forward slashes.  Relative portions are not removed.  Sorry.

    .EXAMPLE
    Join-IisVirtualPath 'SiteName' 'Virtual/Path'

    Demonstrates how to join two IIS paths together.  REturns `SiteName/Virtual/Path`.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The parent path.
        $Path,

        [Parameter(Position=1)]
        [string]
        $ChildPath
    )

    Set-StrictMode -Version 'Latest'

    if( $ChildPath )
    {
        $Path = Join-Path -Path $Path -ChildPath $ChildPath
    }
    $Path.Replace('\', '/').Trim('/')
}
