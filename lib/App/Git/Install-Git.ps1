param(
	[string]$Version,
	[string]$Path,
	[switch]$Force,
	[switch]$Update,
	[switch]$Uninstall
)

$Url = "https://msysgit.googlecode.com/files/Git-1.8.5.2-preview20131230.exe"

$Url | %{
    $WebClient = New-Object System.Net.WebClient
    $FileName = (Split-Path ([uri]$_).LocalPath -Leaf)
    $WebClient.DownloadFile($_, $(Join-Path $Path $FileName))
    
    @{    
        FileName = $FileName
        Path = $Path    
    }
} | %{

    iex "$(Join-Path $_.Path $_.FileName) /VERYSILENT"
}
