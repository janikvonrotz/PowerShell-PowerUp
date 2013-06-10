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

	param(
		[Parameter(Mandatory=$false)]
		[String]
		$Server = "localhost",
		
		[Parameter(Mandatory=$false)]
		[String]
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
       
		$TimeStamp = Get-LogStamp          
		$BackupJob = New-Object ("Microsoft.SqlServer.Management.Smo.Backup");            
		$BackupJob.Action = "Database";            
		$BackupJob.Database = $Database.Name;            
		$BackupJob.Devices.AddDevice($Path + "\" + $Database.Name + " Full " + $TimeStamp + ".bak", "File");            
		$BackupJob.BackupSetDescription = "Full backup of " + $Database.Name;            
		$BackupJob.Incremental = 0;  
          
		# Starting full backup process          
		$BackupJob.SqlBackup($SQLServer); 
    
		# For db with recovery mode <> simple: Log backup.           
		If ($Database.RecoveryModel -ne 3){     
       
			$TimeStamp = Get-LogStamp      
			$BackupJob = New-Object ("Microsoft.SqlServer.Management.Smo.Backup");            
			$BackupJob.Action = "Log";            
			$BackupJob.Database = $Database.Name;            
			$BackupJob.Devices.AddDevice($Path + $Database.Name + " Log " + $TimeStamp + ".trn", "File");            
			$BackupJob.BackupSetDescription = "Log backup of " + $db.Name; 
      
			#Specify that the log must be truncated after the backup is complete           
			$BackupJob.LogTruncation = "Truncate";

			# Starting log backup process            
			$BackupJob.SqlBackup($SQLServer);
            
		}               
	}         
}