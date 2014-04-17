<#
$Metadata = @{
	Title = "Test Privilege"
	Filename = "Test-Privilege.ps1"
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

function Test-Privilege
{
    <#
    .SYNOPSIS
    Tests if an identity has a given privilege.
    
    .DESCRIPTION
    Returns `true` if an identity has a privilege.  `False` otherwise.
    
    .EXAMPLE
    Test-Privilege -Identity Forrester -Privilege SeServiceLogonRight
    
    Tests if `Forrester` has the `SeServiceLogonRight` privilege.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The identity whose privileges to check.
        $Identity,
        
        [Parameter(Mandatory=$true)]
        [string]
        # The privilege to check.
        $Privilege
    )
    
    $matchingPrivilege = Get-Privilege -Identity $Identity |
                            Where-Object { $_ -eq $Privilege }
    return ($matchingPrivilege -ne $null)
}
