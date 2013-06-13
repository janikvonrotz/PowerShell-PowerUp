<#
$Metadata = @{
  Title = "Backup All SQL Databases"
	Filename = "Backp-AllSQLDbs.ps1"
	Description = ""
	Tags = "powershell, sql, backup"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-06-13"
	LastEditDate = "2013-06-13"
	Version = "1.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Backup-AllSQLDBs{

<#
.SYNOPSIS
	Creates a backup for every database on a sql server

.DESCRIPTION
	Creates a backup for every database in an sql server instance. 
    Every database backup is seperated into a subfolder.

.PARAMETER  Server
	Servername, default is local computer name

.PARAMETER  Instance
	Name of the instance which holds the databases

.PARAMETER  Path
	Path for the database backup directory

.EXAMPLE
	PS C:\> Backup-Databases -Server SQLServer1 -Instance SQLExpress -Path D:\SQLServer\Backup
#>

	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$false)]
		[String]
		$Server = $env:COMPUTERNAME,
		
		[Parameter(Mandatory=$true)]
		[String]
		$Instance,

		[Parameter(Mandatory=$true)]
		[String]
		$Path
	)

	#--------------------------------------------------#
	# modules
	#--------------------------------------------------#
    # load Snapins
    Add-PSSnapin SqlServerCmdletSnapin100
    Add-PSSnapin SqlServerProviderSnapin100

	#--------------------------------------------------#
	# main
	#--------------------------------------------------#
    Push-Location	

    $SQLInstance = "SQLServer:\SQL\$Server\$Instance\Databases"
    set-Location $SQLInstance
    Get-ChildItem $SQLInstance | select name | %{
        $BackupPath = $Path + "\" + $_.Name
        if(! (Test-Path $BackupPath)){
            mkdir $BackupPath
        }
    }


$SQLQuery = @"
DECLARE @Name VARCHAR(250)
DECLARE @Path VARCHAR(250)
DECLARE @FileName VARCHAR(250)
DECLARE @TimeStamp VARCHAR(30)

SET @Path = '$Path'

SELECT @TimeStamp = REPLACE(CONVERT(VARCHAR(26),getdate(),120),':','-')

DECLARE db_cursor CURSOR FOR
SELECT name
FROM master.dbo.sysdatabases
WHERE name NOT IN ('master','model','msdb','tempdb')

OPEN db_cursor
FETCH NEXT FROM db_cursor INTO @Name

WHILE @@FETCH_STATUS = 0
BEGIN
       
       SET @FileName = @Path + '\' + @Name + '\' + @Name + '#' + @TimeStamp + '.BAK'

       PRINT @FileName

       BACKUP DATABASE @Name TO DISK = @FileName

       FETCH NEXT FROM db_cursor INTO @Name
END

CLOSE db_cursor
DEALLOCATE db_cursor
"@

    # execute sql query
    Invoke-Sqlcmd -Query $SQLQuery -QueryTimeout 1000

    Pop-Location
}