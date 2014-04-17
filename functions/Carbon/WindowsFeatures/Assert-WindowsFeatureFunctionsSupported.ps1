<#
$Metadata = @{
	Title = "Assert WindowsFeatureFunctionsSupported"
	Filename = "Assert-WindowsFeatureFunctionsSupported.ps1"
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

function Assert-WindowsFeatureFunctionsSupported
{
    <#
    .SYNOPSIS
    INTERNAL.  DO NOT USE.  
    
    .DESCRIPTION 
    INTERNAL.  DO NOT USE.
    
    .EXAMPLE
    Assert-WindowsFeatureFunctionsSupported
    
    Writes an error and returns `false` if support for managing functions isn't found.
    #>
    [CmdletBinding()]
    param(
    )
    
    if( $windowsFeaturesNotSupported )
    {
        Write-Warning $supportNotFoundErrorMessage
        return $false
    }
    return $true
}
