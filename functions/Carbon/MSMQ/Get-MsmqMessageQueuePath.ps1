<#
$Metadata = @{
	Title = "Get MsmqMessageQueuePath"
	Filename = "Get-MsmqMessageQueuePath.ps1"
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

function Get-MsmqMessageQueuePath
{
    <#
    .SYNOPSIS
    Gets the path to an MSMQ message queue.

    .DESCRIPTION
    The MSMQ APIs expect paths when identifying a queue.  This function converts a queue name into its path so that logic isn't spread across all your scripts.  

    Private queue paths are constructed differently.  If you need to get the path to a private MSMQ, use the `Private` switch.

    .OUTPUTS
    System.String.

    .EXAMPLE
    Get-MsmqMessageQueuePath -Name MovieQueue

    Returns the path to the `MovieQueue` queue.

    .EXAMPLE
    Get-MsmqMessageQueuePath -Name MovieQueue -Private

    Returns the path to the private `MovieQueue`.  Must be for the critics.  Early access for the win!
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The queue's name.  
        $Name,
        
        [Switch]
        # Is the queue private?
        $Private
    )
    
    $path = ".\$Name"
    if( $Private )
    {
        $path = ".\private`$\$Name"
    }
    return $path
}
