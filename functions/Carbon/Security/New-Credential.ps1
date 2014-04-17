<#
$Metadata = @{
	Title = "New Credential"
	Filename = "New-Credential.ps1"
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

function New-Credential
{
    <#
    .SYNOPSIS
    Creates a new `PSCredential` object from a given username and password.

    .DESCRIPTION
    Many PowerShell commands require a `PSCredential` object instead of username/password.  This function will create one for you.

    .OUTPUTS
    System.Management.Automation.PSCredential.

    .EXAMPLE
    New-Credential -User ENTERPRISE\picard -Password 'earlgrey'

    Creates a new credential object for Captain Picard.
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The username.
        $User, 

        [Parameter(Mandatory=$true)]
        [string]
        # The password.
        $Password
    )

    return New-Object Management.Automation.PsCredential $User,(ConvertTo-SecureString -AsPlainText -Force $Password)    
}
