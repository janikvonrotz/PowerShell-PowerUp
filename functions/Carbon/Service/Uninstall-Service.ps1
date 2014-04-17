<#
$Metadata = @{
	Title = "Uninstall Service"
	Filename = "Uninstall-Service.ps1"
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

function Uninstall-Service
{
    <#
    .SYNOPSIS
    Removes/deletes a service.

    .DESCRIPTION
    Removes an existing Windows service.  If the service doesn't exist, nothing happens.  The service is stopped before being deleted, so that the computer doesn't need to be restarted for the removal to complete.  Even then, sometimes it won't go away until a reboot.  I don't get it either.

    .EXAMPLE
    Uninstall-Service -Name DeathStar

    Removes the Death Star Windows service.  It is destro..., er, stopped first, then destro..., er, deleted.  If only the rebels weren't using Linux!
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The service name to delete.
        $Name
    )
    
    $service = Get-Service | Where-Object { $_.Name -eq $Name }
    
    if( $service )
    {
        if( $pscmdlet.ShouldProcess( "service '$Name'", "remove" ) )
        {
            Stop-Service $Name
            & C:\Windows\system32\sc.exe delete $Name
        }
    }
}

Set-Alias -Name 'Remove-Service' -Value 'Uninstall-Service'
