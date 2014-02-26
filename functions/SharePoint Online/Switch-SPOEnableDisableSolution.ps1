<#
$Metadata = @{
	Title = "Switch-SPOEnableDisableSolution"
	Filename = "Switch-SPOEnableDisableSolution.ps1"
	Description = ""
	Tags = "powershell, sharepoint, online"
	Project = "https://sharepointpowershell.codeplex.com"
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

function Switch-SPOEnableDisableSolution
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory=$true, Position=1)]
	    [string]$solutionName,
		
		[Parameter(Mandatory=$true, Position=2)]
	    [bool]$activate
	)
	
	
	$solutionId = Get-SPOSolutionId -solutionName $solutionName

    # Queries the solution's page
    $operation = ""
	if($activate) 
	{ 
		$operation = "ACT" 
	} 
	else 
	{ 
		$operation = "DEA" 
	}
	
    $solutionPageUrl = Join-SPOParts -Separator '/' -Parts $clientContext.Site.Url, "/_catalogs/solutions/forms/activate.aspx?Op=$operation&ID=$solutionId"
	
	$cookieContainer = New-Object System.Net.CookieContainer
    
	$request = $clientContext.WebRequestExecutorFactory.CreateWebRequestExecutor($clientContext, $solutionPageUrl).WebRequest
	
	if ($clientContext.Credentials -ne $null)
	{
		$authCookieValue = $clientContext.Credentials.GetAuthenticationCookie($clientContext.Url)
	    # Create fed auth Cookie
	  	$fedAuth = new-object System.Net.Cookie
		$fedAuth.Name = "FedAuth"
	  	$fedAuth.Value = $authCookieValue.TrimStart("SPOIDCRL=")
	  	$fedAuth.Path = "/"
	  	$fedAuth.Secure = $true
	  	$fedAuth.HttpOnly = $true
	  	$fedAuth.Domain = (New-Object System.Uri($clientContext.Url)).Host
	  	
		# Hookup authentication cookie to request
		$cookieContainer.Add($fedAuth)
		
		$request.CookieContainer = $cookieContainer
	}
	else
	{
		# No specific authentication required
		$request.UseDefaultCredentials = $true
	}
	
	$request.ContentLength = 0
	
	$response = $request.GetResponse()
	
		# decode response
		$strResponse = $null
		$stream = $response.GetResponseStream()
		if (-not([String]::IsNullOrEmpty($response.Headers["Content-Encoding"])))
		{
        	if ($response.Headers["Content-Encoding"].ToLower().Contains("gzip"))
			{
                $stream = New-Object System.IO.Compression.GZipStream($stream, [System.IO.Compression.CompressionMode]::Decompress)
			}
			elseif ($response.Headers["Content-Encoding"].ToLower().Contains("deflate"))
			{
                $stream = new-Object System.IO.Compression.DeflateStream($stream, [System.IO.Compression.CompressionMode]::Decompress)
			}
		}
		
		# get response string
        $sr = New-Object System.IO.StreamReader($stream)

			$strResponse = $sr.ReadToEnd()
            
		$sr.Close()
		$sr.Dispose()
        
        $stream.Close()
		
        $inputMatches = $strResponse | Select-String -AllMatches -Pattern "<input.+?\/??>" | select -Expand Matches
		
		$inputs = @{}
		
		# Look for inputs and add them to the dictionary for postback values
        foreach ($match in $inputMatches)
        {
			if (-not($match[0] -imatch "name=\""(.+?)\"""))
			{
				continue
			}
			$name = $matches[1]
			
			if(-not($match[0] -imatch "value=\""(.+?)\"""))
			{
				continue
			}
			$value = $matches[1]

            $inputs.Add($name, $value)
        }

        # Lookup for activate button's id
        $searchString = ""
		if ($activate) 
		{
			$searchString = "ActivateSolutionItem"
		}
		else
		{
			$searchString = "DeactivateSolutionItem"
		}
        
		$match = $strResponse -imatch "__doPostBack\(\&\#39\;(.*?$searchString)\&\#39\;"
		$inputs.Add("__EVENTTARGET", $Matches[1])
	
	$response.Close()
	$response.Dispose()
	
	# Format inputs as postback data string, but ignore the one that ends with iidIOGoBack
    $strPost = ""
    foreach ($inputKey in $inputs.Keys)
	{
        if (-not([String]::IsNullOrEmpty($inputKey)) -and -not($inputKey.EndsWith("iidIOGoBack")))
		{
            $strPost += [System.Uri]::EscapeDataString($inputKey) + "=" + [System.Uri]::EscapeDataString($inputs[$inputKey]) + "&"
		}
	}
	$strPost = $strPost.TrimEnd("&")
	
    $postData = [System.Text.Encoding]::UTF8.GetBytes($strPost);

    # Build postback request
    $activateRequest = $clientContext.WebRequestExecutorFactory.CreateWebRequestExecutor($clientContext, $solutionPageUrl).WebRequest
    $activateRequest.Method = "POST"
    $activateRequest.Accept = "text/html, application/xhtml+xml, */*"
    if ($clientContext.Credentials -ne $null)
	{
		$activateRequest.CookieContainer = $cookieContainer
	}
	else
	{
		# No specific authentication required
		$activateRequest.UseDefaultCredentials = $true
	}
    $activateRequest.ContentType = "application/x-www-form-urlencoded"
    $activateRequest.ContentLength = $postData.Length
    $activateRequest.UserAgent = "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)";
    $activateRequest.Headers["Cache-Control"] = "no-cache";
    $activateRequest.Headers["Accept-Encoding"] = "gzip, deflate";
    $activateRequest.Headers["Accept-Language"] = "fr-FR,en-US";

    # Add postback data to the request stream
    $stream = $activateRequest.GetRequestStream()
        $stream.Write($postData, 0, $postData.Length)
        $stream.Close();
	$stream.Dispose()
	
    # Perform the postback
    $response = $activateRequest.GetResponse()
	$response.Close()
	$response.Dispose()
	
}
