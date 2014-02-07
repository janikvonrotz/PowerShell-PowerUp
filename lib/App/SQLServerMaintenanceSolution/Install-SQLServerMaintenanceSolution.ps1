param(
	[string]$Version,
	[string]$Path,
	[switch]$Force,
	[switch]$Update,
	[switch]$Uninstall
)

$Appname = "SQL Server Maintenance Solution"
$Url = "http://ola.hallengren.com/scripts/MaintenanceSolution.sql",
"http://ola.hallengren.com/scripts/DatabaseBackup.sql",
"http://ola.hallengren.com/scripts/DatabaseIntegrityCheck.sql",
"http://ola.hallengren.com/scripts/IndexOptimize.sql",
"http://ola.hallengren.com/scripts/CommandExecute.sql",
"http://ola.hallengren.com/scripts/CommandLog.sql"

$Url | %{

    Get-File -Url $_ -Path $Path    
} | Out-Null