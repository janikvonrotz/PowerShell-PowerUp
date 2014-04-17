<#
$Metadata = @{
	Title = "Enable FirewallStatefulFtp"
	Filename = "Enable-FirewallStatefulFtp.ps1"
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

function Enable-FirewallStatefulFtp
{
    <#
    .SYNOPSIS
    Enables the `StatefulFtp` Windows firewall setting.

    .DESCRIPTION
    Uses the `netsh` command to enable the `StatefulFtp` Windows firewall setting.

    If the firewall isn't configurable, writes an error and returns without making any changes.

    .LINK
    Assert-FirewallConfigurable

    .EXAMPLE
    Enable-FirewallStatefulFtp
    
    Enables the `StatefulFtp` Windows firewall setting.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param()
    
    if( -not (Assert-FirewallConfigurable) )
    {
        return
    }
    
    if( $pscmdlet.ShouldProcess( 'firewall', 'enable stateful FTP' ) )
    {
        Write-Host "Enabling stateful FTP in the firewall."
        netsh advfirewall set global StatefulFtp enable
    }
}
