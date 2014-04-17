<#
$Metadata = @{
	Title = "Get IisWebsite"
	Filename = "Get-IisWebsite.ps1"
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

function Get-IisWebsite
{
    <#
    .SYNOPSIS
    Returns all the websites installed on the local computer, or a specific website.
    
    .DESCRIPTION
    Returns a Microsoft.Web.Administration.Site object.

    Each object will have a `CommitChanges` script method added which will allow you to commit/persist any changes to the website's configuration.
     
    .OUTPUTS
    Microsoft.Web.Administration.Site.
    
    .LINK
    http://msdn.microsoft.com/en-us/library/microsoft.web.administration.site.aspx

    .EXAMPLE
    Get-IisWebsite

    Returns all installed websites.
     
    .EXAMPLE
    Get-IisWebsite -SiteName 'WebsiteName'
     
    Returns the details for the site named `WebsiteName`.
    #>
    [CmdletBinding()]
    param(
        [string]
        [Alias('SiteName')]
        # The name of the site to get.
        $Name
    )
    
    if( $Name -and -not (Test-IisWebsite -Name $Name) )
    {
        return $null
    }
    
    $mgr = New-Object 'Microsoft.Web.Administration.ServerManager'
    $mgr.Sites | 
        Where-Object {
            if( $Name )
            {
                $_.Name -eq $Name
            }
            else
            {
                $true
            }
        } | Add-IisServerManagerMember -ServerManager $mgr -PassThru |
        Add-Member -MemberType ScriptProperty -Name PhysicalPath -Value {
            $this.Applications |
                Where-Object { $_.Path -eq '/' } |
                Select-Object -ExpandProperty VirtualDirectories |
                Where-Object { $_.Path -eq '/' } |
                Select-Object -ExpandProperty PhysicalPath
        } -PassThru
}
