<#
$Metadata = @{
	Title = "Get ServiceSecurityDescriptor"
	Filename = "Get-ServiceSecurityDescriptor.ps1"
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

function Get-ServiceSecurityDescriptor
{
    <#
    .SYNOPSIS
    Gets the raw security descriptor for a service.
    
    .DESCRIPTION
    You probably don't want to mess with the raw security descriptor.  Try `Get-ServicePermission` instead.  Much more useful.
    
    .OUTPUTS
    System.Security.AccessControl.RawSecurityDescriptor.
    
    .LINK
    Get-ServicePermission
    
    .LINK
    Grant-ServicePermissions
    
    .LINK
    Revoke-ServicePermissions
    
    .EXAMPLE
    Get-ServiceSecurityDescriptor -Name 'Hyperdrive'
    
    Gets the hyperdrive service's raw security descriptor.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the service whose permissions to return.
        $Name
    )

    $sdBytes = [Carbon.AdvApi32]::GetServiceSecurityDescriptor($Name)
    New-Object Security.AccessControl.RawSecurityDescriptor $sdBytes,0
}
