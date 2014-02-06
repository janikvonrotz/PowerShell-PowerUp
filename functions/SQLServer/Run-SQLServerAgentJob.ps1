<#
$Metadata = @{
	Title = "Run SQL Server Agent Job"
	Filename = "Run-SQLServerAgentJob.ps1"
	Description = ""
	Tags = ""
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2014-02-06"
	LastEditDate = "2014-02-06"
	Url = ""
	Version = "0.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Run-SQLServerAgentJob{

<#
.SYNOPSIS
    Run a SQL Server agent job.

.DESCRIPTION
	Run a SQL Server agent job by providing the jobname and hostname.

.PARAMETER JobName
	Name of the agent job.
    
.PARAMETER Hostname
	Optional hostname to specify SQL Server host. Default is current host.

.PARAMETER LogScriptBlock
	Script block to run when execute the agent job. Use the $Message variable to log the message. Default is Write-Host $Message.

.EXAMPLE
	PS C:\> Run-SQLServerAgentJob -JobName "Full Backup"

.EXAMPLE
	PS C:\> Run-SQLServerAgentJob -JobName "Full Backup" -Hostname "SQLServer1" -LogScriptBlock {Write-EventLog -LogName "SQL Server" -Message "$Message"}
#>

    [CmdletBinding()]
    param(

        [Parameter(Mandatory = $true)]
        [String]
        $JobName,

        [Parameter(Mandatory = $false)]
        [String]
        $Hostname = $env:COMPUTERNAME,

        [Parameter(Mandatory=$false)]
        [ScriptBlock]
		$LogScriptBlock = {Write-Host $Message}
    )
      
    #--------------------------------------------------#
    # main
    #--------------------------------------------------#
	
    # load SMO and instantiate the server object
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null

    # create sql server object
    [Microsoft.SqlServer.Management.Smo.Server]$SqlServer = New-Object Microsoft.SqlServer.Management.Smo.Server $HostName

    # check sql server object
    if(-not $SqlServer.Urn){

        throw "The hostname provided is not a valid SQL Server instance. Did you mistype the alias or forget to add the instance name?"
    }

    # match the job name (if possible) from the list of jobs (readable by the user context)
    $Job = $SqlServer.JobServer.Jobs | where{ $_.Name -eq $JobName }

    # abort if jobname is not available
    if(-not $Job){

        throw "No such job on the server.";
    }

    Write-Host "Executing job: $JobName";
    $Job.Start();
}