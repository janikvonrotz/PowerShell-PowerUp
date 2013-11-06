function Load-SQLServerManagementObjects{
#
# Loads the SQL Server Management Objects (SMO)
# http://msdn.microsoft.com/en-us/library/hh245202.aspx

$ErrorActionPreference = "Stop"

$sqlpsreg="HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.SqlServer.Management.PowerShell.sqlps"

if (Get-ChildItem $sqlpsreg -ErrorAction "SilentlyContinue")
{
    throw "SQL Server Provider for Windows PowerShell is not installed."
}
else
{
    $item = Get-ItemProperty $sqlpsreg
    $sqlpsPath = [System.IO.Path]::GetDirectoryName($item.Path)
}


$assemblylist = 
"Microsoft.SqlServer.Management.Common",
"Microsoft.SqlServer.Smo",
"Microsoft.SqlServer.Dmf ",
"Microsoft.SqlServer.Instapi ",
"Microsoft.SqlServer.SqlWmiManagement ",
"Microsoft.SqlServer.ConnectionInfo ",
"Microsoft.SqlServer.SmoExtended ",
"Microsoft.SqlServer.SqlTDiagM ",
"Microsoft.SqlServer.SString ",
"Microsoft.SqlServer.Management.RegisteredServers ",
"Microsoft.SqlServer.Management.Sdk.Sfc ",
"Microsoft.SqlServer.SqlEnum ",
"Microsoft.SqlServer.RegSvrEnum ",
"Microsoft.SqlServer.WmiEnum ",
"Microsoft.SqlServer.ServiceBrokerEnum ",
"Microsoft.SqlServer.ConnectionInfoExtended ",
"Microsoft.SqlServer.Management.Collector ",
"Microsoft.SqlServer.Management.CollectorEnum",
"Microsoft.SqlServer.Management.Dac",
"Microsoft.SqlServer.Management.DacEnum",
"Microsoft.SqlServer.Management.Utility"


foreach ($asm in $assemblylist)
{
    $asm = [Reflection.Assembly]::LoadWithPartialName($asm)
}

Push-Location
cd $sqlpsPath
update-FormatData -prependpath SQLProvider.Format.ps1xml 
Pop-Location
}