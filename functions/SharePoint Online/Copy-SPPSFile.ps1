<#
$Metadata = @{
	Title = "Copy-SPPSFile"
	Filename = "Copy-SPPSFile.ps1"
	Description = ""
	Tags = "powershell, sharepoint, online"
	Project = ""
	Author = "Jeffrey Paarhuis"
	AuthorContact = "http://jeffreypaarhuis.com/"
	CreateDate = "2013-02-2"
	LastEditDate = "2014-02-2"
	Url = ""
	Version = "0.1.2"
	License = @'
The MIT License (MIT)
Copyright (c) 2014 Jeffrey Paarhuis
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
'@
}
#>

function Copy-SPPSFile
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory=$true, Position=1)]
		[System.IO.FileSystemInfo]$file, 
		
		[Parameter(Mandatory=$true, Position=2)]
		[string]$targetPath, 
		
		[Parameter(Mandatory=$true, Position=3)]
		[bool]$checkoutNecessary
	)

    if ($file.PsIsContainer)
    {
        Add-SPPSFolder $targetPath
    }
    else
    {
        $filePath = $file.FullName
        
		Write-Host "Copying file $filePath to $targetPath" -foregroundcolor black -backgroundcolor yellow
		
        
        if ($checkoutNecessary)
        {
            # Set the error action to silent to try to check out the file if it exists
            $ErrorActionPreference = "SilentlyContinue"
            Submit-SPPSCheckOut $targetPath
            $ErrorActionPreference = "Stop"
        }
        
		$arrExtensions = ".html", ".js", ".master", ".txt", ".css", ".aspx"
		
		if ($arrExtensions -contains $file.Extension)
		{
			$tempFile = Convert-SPPSFileVariablesToValues -file $file
	        Save-SPPSFile $targetPath $tempFile
			Remove-Item $tempFile
		} 
		else
		{
			Save-SPPSFile $targetPath $file
		}
        
        if ($checkoutNecessary)
        {
            Submit-SPPSCheckOut $targetPath
            Submit-SPPSCheckIn $targetPath
        }
    }
}
