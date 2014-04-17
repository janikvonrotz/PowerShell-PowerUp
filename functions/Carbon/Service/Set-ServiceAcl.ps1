<#
$Metadata = @{
	Title = "Set ServiceAcl"
	Filename = "Set-ServiceAcl.ps1"
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

function Set-ServiceAcl
{
    <#
    .SYNOPSIS
    Sets a service's discretionary access control list (i.e. DACL).
    
    .DESCRIPTION
    The existing DACL is replaced with the new DACL.  No previous permissions are preserved.  That's your job.  You're warned!
    
    You probably want `Grant-ServicePermission` or `Revoke-ServicePermission` instead.
    
    .LINK
    Get-ServicePermission
    
    .LINK
    Grant-ServicePermission
    
    .LINK
    Revoke-ServicePermission
    
    .EXAMPLE
    Set-ServiceDacl -Name 'Hyperdrive' -Dacl $dacl
    
    Replaces the DACL on the `Hyperdrive` service.  Yikes!  Sounds like something the Empire would do, though. 
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The service whose DACL to replace.
        $Name,
        
        [Parameter(Mandatory=$true)]
        [Security.AccessControl.DiscretionaryAcl]
        # The service's new DACL.
        $Dacl
    )
    
    $rawSD = Get-ServiceSecurityDescriptor -Name $Name
    $daclBytes = New-Object byte[] $Dacl.BinaryLength 
    $Dacl.GetBinaryForm($daclBytes, 0);
    $rawSD.DiscretionaryAcl = New-Object Security.AccessControl.RawAcl $daclBytes,0
    $sdBytes = New-Object byte[] $rawSD.BinaryLength   
    $rawSD.GetBinaryForm($sdBytes, 0);
    
    if( $pscmdlet.ShouldProcess( ("{0} service DACL" -f $Name), "set" ) )
    {
        [Carbon.AdvApi32]::SetServiceSecurityDescriptor( $Name, $sdBytes )
    }
}
