function Backup-Databases{

<#
.SYNOPSIS
	Creates a backup for every database on a sql server

.DESCRIPTION
	Creates a backup for every database on a remote of localsql server

.PARAMETER  Server
	Servername, default is localhost

.PARAMETER  Path
	Path for the database backups, default is the SQLServer backup directory

.EXAMPLE
	PS C:\> Backup-Databases -Server SQLServer1 -Path D:\SQLServer\Backup

.LINK
	Source: http://social.technet.microsoft.com/wiki/contents/articles/900.how-to-sql-server-databases-backup-with-powershell.aspx

#>
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$false)]
		[SString]
		$Server = "(local)",
		
		[Parameter(Mandatory=$false)]
		[SString]
		$Path
	)

	#--------------------------------------------------#
	# modules
	#--------------------------------------------------#
	[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.ConnectionInfo');            
	[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.Management.Sdk.Sfc');            
	[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO');            
	# Requiered for SQL Server 2008 (SMO 10.0).            
	[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMOExtended');   

	#--------------------------------------------------#
	# main
	#--------------------------------------------------#
	           
	$SQLServer = New-Object Microsoft.SqlServer.Management.Smo.Server $Server;            
	# If missing set default backup directory.            
	If ($Path -eq ""){ 
		$Path = $SQLServer.Settings.BackupDirectory + "\" 
	}
	
	# Full-backup for every database            
	foreach ($Database in $SQLServer.Databases)            
	{            
		If($Database.Name -ne "tempdb"){            
			$timestamp = Get-Date -format yyyy-MM-dd-HH-mm-ss;            
			$backup = New-Object ("Microsoft.SqlServer.Management.Smo.Backup");            
			$backup.Action = "Database";            
			$backup.Database = $db.Name;            
			$backup.Devices.AddDevice($Dest + $db.Name + "_full_" + $timestamp + ".bak", "File");            
			$backup.BackupSetDescription = "Full backup of " + $db.Name + " " + $timestamp;            
			$backup.Incremental = 0;            
			# Starting full backup process.            
			$backup.SqlBackup($srv);     
			# For db with recovery mode <> simple: Log backup.            
			If ($db.RecoveryModel -ne 3){            
				$timestamp = Get-Date -format yyyy-MM-dd-HH-mm-ss;            
				$backup = New-Object ("Microsoft.SqlServer.Management.Smo.Backup");            
				$backup.Action = "Log";            
				$backup.Database = $db.Name;            
				$backup.Devices.AddDevice($Dest + $db.Name + "_log_" + $timestamp + ".trn", "File");            
				$backup.BackupSetDescription = "Log backup of " + $db.Name + " " + $timestamp;            
				#Specify that the log must be truncated after the backup is complete.            
				$backup.LogTruncation = "Truncate";
				# Starting log backup process            
				$backup.SqlBackup($srv);            
			}           
		}           
	}         


}