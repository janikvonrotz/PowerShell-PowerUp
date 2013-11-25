param([string]$Version)

Set-Location (Split-Path $MyInvocation.InvocationName -Parent)

$Url = "http://ola.hallengren.com/scripts/MaintenanceSolution.sql",
"http://ola.hallengren.com/scripts/DatabaseBackup.sql",
"http://ola.hallengren.com/scripts/DatabaseIntegrityCheck.sql",
"http://ola.hallengren.com/scripts/IndexOptimize.sql",
"http://ola.hallengren.com/scripts/CommandExecute.sql",
"http://ola.hallengren.com/scripts/CommandLog.sql"

$Url | %{

    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile($_, $(Join-Path (Get-Location).Path (Split-Path ([uri]$_).LocalPath -Leaf)))
}