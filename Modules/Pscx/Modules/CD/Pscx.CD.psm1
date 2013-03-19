#---------------------------------------------------------------------------
# Author: Keith Hill
# Desc:   Module that replaces the regular CD function with one that handles 
#         history and backward/forward navigation using - and +.
#         as ..[.]*.
# Date:   Nov 18, 2006
# Site:   http://pscx.codeplex.com
#---------------------------------------------------------------------------
#requires -Version 2.0
Set-StrictMode -Version 2.0

$backwardStack = new-object System.Collections.ArrayList
$forewardStack = new-object System.Collections.ArrayList

# We are going to replace the PowerShell default "cd" alias with the CD function defined below.
Set-Alias cd Set-LocationEx -Force -Scope Global -Option AllScope -Description "PSCX alias"

<#
.SYNOPSIS
    CD function that tracks location history allowing easy navigation to previous locations.
.DESCRIPTION
    CD function that tracks location history allowing easy navigation to previous locations.
    CD maintains a backward and forward stack mechanism that can be navigated using "cd -" 
    to go backwards in the stack and "cd +" to go forwards in the stack.  Executing "cd" 
    without any parameters will display the current stack history. By default, the new location
    is echo'd to the host.  If you want to suppress this set the preference variable in your
    profile e.g. $Pscx:Preferences['CD/EchoNewLocation'] = $false
.PARAMETER Path
    The path to change location to.     
.PARAMETER LiteralPath
    The literal path to change location to.  This path can contain wildcard characters that
    do not need to be escaped.
.PARAMETER PassThru
    If the PassThru switch is specified the object passed into the CD function is also output
    from the function.  This allows the next pipeline stage to also operate on the object.
.PARAMETER UnboundArguments
    This parameter accumulates all the additional arguments and concatenates them to the Path
    or LiteralPath parameter using a space separator.  This allows you to cd to some paths containing
    spaces without having to quote the path e.g. 'cd c:\program files'.  Note that this doesn't always
    work.  For example, this following won't work: 'cd c:\program files (x86)'.  This fails because 
    PowerShell tries to evaluate the contents of the expression '(x86)' which isn't a valid command name.
.PARAMETER UseTransaction
    Includes the command in the active transaction. This parameter is valid only when a transaction 
    is in progress. For more information, see about_Transactions.
.EXAMPLE
    C:\PS> cd $pshome; cd -; cd +
    This example changes location to the PowerShell install dir, then back to the original
    location, than forward again to the PowerShell install dir. 
.EXAMPLE
    C:\PS> cd ....
    This example changes location up two levels from the current path.  You can use an arbitrary
    number of periods to indicate how many levels you want to go up.  A single period "." indicates
    the current location.  Two periods ".." indicate the current location's parent.  Three periods "..."
    indicates the current location's parent's parent and so on.
.EXAMPLE
    C:\PS> cd
    Executing CD without any parameters will cause it to display the current stack contents.
.EXAMPLE
    C:\PS> cd -0
    Changes location to the very first (0th index) location in the stack. Execute CD without any parameters
    to see all the paths, then execute CD -<number> to change location to that path.
.EXAMPLE
    C:\PS> $profile | cd
    This example will change location to the parent location of $profile.
.NOTES
    This is a PSCX function.
#>
function Set-LocationEx
{
    [CmdletBinding(DefaultParameterSetName='Path')]
    param(
        [Parameter(Position=0, ParameterSetName='Path', ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [string]
        $Path, 
        
        [Parameter(Position=0, ParameterSetName='LiteralPath', ValueFromPipelineByPropertyName=$true)]
        [Alias("PSPath")]
        [string]
        $LiteralPath, 
        
        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]
        $UnboundArguments,
                
        [Parameter()]
        [switch]
        $PassThru,
        
        [Parameter()]
        [switch]
        $UseTransaction        
    )
    
    Begin 
    {
		Set-StrictMode -Version 2.0
		
		# String resources
		Import-LocalizedData -BindingVariable msgTbl -FileName Messages
		              
        function SetLocationImpl($path, [switch]$IsLiteralPath)
        {
			if ($pscmdlet.ParameterSetName -eq 'LiteralPath' -or $IsLiteralPath)
			{
				Write-Debug   "Setting location to literal path: '$path'"
				Set-Location -LiteralPath $path -UseTransaction:$UseTransaction
			}
			else
			{
				Write-Debug   "Setting location to path: '$path'"
				Set-Location $path -UseTransaction:$UseTransaction
	        }
	        
            if ($PassThru)
            {
                Write-Output $ExecutionContext.SessionState.Path.CurrentLocation
            }
            else
            {
                # If not passing thru, then check for user options of other info to display.
				if ($Pscx:Preferences['CD_GetChildItem'])
				{
					Get-ChildItem
				} 
				elseif ($Pscx:Preferences['CD_EchoNewLocation'])
				{
					Write-Host $ExecutionContext.SessionState.Path.CurrentLocation
				}
            }
        }
    }
        
    Process 
    {
		if ($pscmdlet.ParameterSetName -eq 'Path')
		{
			Write-Debug "Path parameter received: '$Path'"
			$aPath = $Path
		}
		else
		{
			Write-Debug "LiteralPath parameter received: '$LiteralPath'"
			$aPath = $LiteralPath
		}
		
		if ($UnboundArguments -and $UnboundArguments.Count -gt 0)
		{	
			$OFS=','
			Write-Debug "Appending unbound arguments to path: '$UnboundArguments'"
			$aPath = $aPath + " " + ($UnboundArguments -join ' ')
		}
				
		# If no input, dump contents of backward and foreward stacks
        if (!$aPath) 
        {
            # Command to dump the backward & foreward stacks
            ""
            "     # Directory Stack:"
            "   --- ----------------"
            if ($backwardStack.Count -ge 0) 
            {
                for ($i = 0; $i -lt $backwardStack.Count; $i++) 
                { 
                    "   {0,3} {1}" -f $i, $backwardStack[$i]
                } 
            }

            "-> {0,3} {1}" -f $i++,$ExecutionContext.SessionState.Path.CurrentLocation

            if ($forewardStack.Count -ge 0) 
            {
                $ndx = $i
                for ($i = 0; $i -lt $forewardStack.Count; $i++) 
                { 
                    "   {0,3} {1}" -f ($ndx+$i), $forewardStack[$i]
                } 
            }
            ""
            return
        }
        
		Write-Debug "Processing arg: '$aPath'"
		
        $currentPathInfo = $ExecutionContext.SessionState.Path.CurrentLocation
        
        # Expand ..[.]+ out to ..\..[\..]+
        if ($aPath -like "*...*") 
        {
            $regex = [regex]"\.\.\."
            while ($regex.IsMatch($aPath)) 
            {
                $aPath = $regex.Replace($aPath, "..\..")
            }
        }

        if ($aPath -eq "-") 
        {
            if ($backwardStack.Count -eq 0) 
            {
                Write-Warning $msgTbl.BackStackEmpty
            }
            else 
            {        
                $lastNdx = $backwardStack.Count - 1
                $prevPath = $backwardStack[$lastNdx]
				SetLocationImpl $prevPath -IsLiteralPath
                [void]$forewardStack.Insert(0, $currentPathInfo.Path)
                $backwardStack.RemoveAt($lastNdx)
            }
        }
        elseif ($aPath -eq "+") 
        {
            if ($forewardStack.Count -eq 0) 
            {
                Write-Warning $msgTbl.ForeStackEmpty
            }
            else 
            {
                $nextPath = $forewardStack[0]
				SetLocationImpl $nextPath -IsLiteralPath        
                [void]$backwardStack.Add($currentPathInfo.Path)
                $forewardStack.RemoveAt(0)
            }
        }
        elseif ($aPath -like "-[0-9]*")
        {
            [int]$num = $aPath.replace("-","")
            $backstackSize = $backwardStack.Count
            $forestackSize = $forewardStack.Count
            if ($num -eq $backstackSize) 
            {
                Write-Host "`n$($msgTbl.GoingToTheSameDir)`n"
            }
            elseif ($num -lt $backstackSize) 
            {
                $selectedPath = $backwardStack[$num]
				SetLocationImpl $selectedPath -IsLiteralPath
                [void]$forewardStack.Insert(0, $currentPathInfo.Path)
                $backwardStack.RemoveAt($num)
                
                [int]$ndx = $num
                [int]$count = $backwardStack.Count - $ndx
                if ($count -gt 0) 
                {
                    $itemsToMove = $backwardStack.GetRange($ndx, $count)
                    $forewardStack.InsertRange(0, $itemsToMove)
                    $backwardStack.RemoveRange($ndx, $count)
                }
            }
            elseif (($num -gt $backstackSize) -and ($num -lt ($backstackSize + 1 + $forestackSize))) 
            {
                [int]$ndx = $num - ($backstackSize + 1)
                $selectedPath = $forewardStack[$ndx]
				SetLocationImpl $selectedPath -IsLiteralPath
                [void]$backwardStack.Add($currentPathInfo.Path)
                $forewardStack.RemoveAt($ndx)
                
                [int]$count = $ndx
                if ($count -gt 0) 
                {
                    $itemsToMove = $forewardStack.GetRange(0, $count)
                    $backwardStack.InsertRange(($backwardStack.Count), $itemsToMove)
                    $forewardStack.RemoveRange(0, $count)
                }
            }
            else 
            {
                Write-Warning ($msgTbl.NumOutOfRangeF1 -f $num)
            }
        }
        else
        {
			$driveName = ''
            if ($ExecutionContext.SessionState.Path.IsPSAbsolute($aPath, [ref]$driveName) -and
                !(Test-Path -LiteralPath $aPath -PathType Container)) 
            {
                # File or a non-existant path - handle the case of "cd $profile" when the profile script doesn't exist
                $aPath = Split-Path $aPath -Parent
				Write-Debug "Path is not a container, attempting to set location to parent: '$aPath'"
            }

			SetLocationImpl $aPath                                  
                                   
            $forewardStack.Clear()
            
            # Don't add the same path twice in a row
            if ($backwardStack.Count -gt 0) 
            {
                $newPathInfo = $ExecutionContext.SessionState.Path.CurrentLocation
                if (($currentPathInfo.Provider     -eq $newPathInfo.Provider) -and
                    ($currentPathInfo.ProviderPath -eq $newPathInfo.ProviderPath)) 
                {
                    return
                }
            }
            [void]$backwardStack.Add($currentPathInfo.Path)
        }
    }
}

# SIG # Begin signature block
# MIIfVQYJKoZIhvcNAQcCoIIfRjCCH0ICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUlYqx8htQCj7hfc7x3SvbxbgU
# 05GgghqHMIIGbzCCBVegAwIBAgIQA4uW8HDZ4h5VpUJnkuHIOjANBgkqhkiG9w0B
# AQUFADBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBBc3N1cmVk
# IElEIENBLTEwHhcNMTIwNDA0MDAwMDAwWhcNMTMwNDE4MDAwMDAwWjBHMQswCQYD
# VQQGEwJVUzERMA8GA1UEChMIRGlnaUNlcnQxJTAjBgNVBAMTHERpZ2lDZXJ0IFRp
# bWVzdGFtcCBSZXNwb25kZXIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQDGf7tj+/F8Q0mIJnRfituiDBM1pYivqtEwyjPdo9B2gRXW1tvhNC0FIG/BofQX
# Z7dN3iETYE4Jcq1XXniQO7XMLc15uGLZTzHc0cmMCAv8teTgJ+mn7ra9Depw8wXb
# 82jr+D8RM3kkwHsqfFKdphzOZB/GcvgUnE0R2KJDQXK6DqO+r9L9eNxHlRdwbJwg
# wav5YWPmj5mAc7b+njHfTb/hvE+LgfzFqEM7GyQoZ8no89SRywWpFs++42Pf6oKh
# qIXcBBDsREA0NxnNMHF82j0Ctqh3sH2D3WQIE3ome/SXN8uxb9wuMn3Y07/HiIEP
# kUkd8WPenFhtjzUmWSnGwHTPAgMBAAGjggM6MIIDNjAOBgNVHQ8BAf8EBAMCB4Aw
# DAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDCCAcQGA1UdIASC
# AbswggG3MIIBswYJYIZIAYb9bAcBMIIBpDA6BggrBgEFBQcCARYuaHR0cDovL3d3
# dy5kaWdpY2VydC5jb20vc3NsLWNwcy1yZXBvc2l0b3J5Lmh0bTCCAWQGCCsGAQUF
# BwICMIIBVh6CAVIAQQBuAHkAIAB1AHMAZQAgAG8AZgAgAHQAaABpAHMAIABDAGUA
# cgB0AGkAZgBpAGMAYQB0AGUAIABjAG8AbgBzAHQAaQB0AHUAdABlAHMAIABhAGMA
# YwBlAHAAdABhAG4AYwBlACAAbwBmACAAdABoAGUAIABEAGkAZwBpAEMAZQByAHQA
# IABDAFAALwBDAFAAUwAgAGEAbgBkACAAdABoAGUAIABSAGUAbAB5AGkAbgBnACAA
# UABhAHIAdAB5ACAAQQBnAHIAZQBlAG0AZQBuAHQAIAB3AGgAaQBjAGgAIABsAGkA
# bQBpAHQAIABsAGkAYQBiAGkAbABpAHQAeQAgAGEAbgBkACAAYQByAGUAIABpAG4A
# YwBvAHIAcABvAHIAYQB0AGUAZAAgAGgAZQByAGUAaQBuACAAYgB5ACAAcgBlAGYA
# ZQByAGUAbgBjAGUALjAfBgNVHSMEGDAWgBQVABIrE5iymQftHt+ivlcNK2cCzTAd
# BgNVHQ4EFgQUJqoP9EMNo5gXpV8S9PiSjqnkhDQwdwYIKwYBBQUHAQEEazBpMCQG
# CCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wQQYIKwYBBQUHMAKG
# NWh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRENB
# LTEuY3J0MH0GA1UdHwR2MHQwOKA2oDSGMmh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNv
# bS9EaWdpQ2VydEFzc3VyZWRJRENBLTEuY3JsMDigNqA0hjJodHRwOi8vY3JsNC5k
# aWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURDQS0xLmNybDANBgkqhkiG9w0B
# AQUFAAOCAQEAvCT5g9lmKeYy6GdDbzfLaXlHl4tifmnDitXp13GcjqH52v4k498m
# bK/g0s0vxJ8yYdB2zERcy+WPvXhnhhPiummK15cnfj2EE1YzDr992ekBaoxuvz/P
# MZivhUgRXB+7ycJvKsrFxZUSDFM4GS+1lwp+hrOVPNxBZqWZyZVXrYq0xWzxFjOb
# vvA8rWBrH0YPdskbgkNe3R2oNWZtNV8hcTOgHArLRWmJmaX05mCs7ksBKGyRlK+/
# +fLFWOptzeUAtDnjsEWFuzG2wym3BFDg7gbFFOlvzmv8m7wkfR2H3aiObVCUNeZ8
# AB4TB5nkYujEj7p75UsZu62Y9rXC8YkgGDCCBpswggWDoAMCAQICEAoVPQh11uMo
# zhH2mVCPvBEwDQYJKoZIhvcNAQEFBQAwbzELMAkGA1UEBhMCVVMxFTATBgNVBAoT
# DERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEuMCwGA1UE
# AxMlRGlnaUNlcnQgQXNzdXJlZCBJRCBDb2RlIFNpZ25pbmcgQ0EtMTAeFw0xMjA5
# MTEwMDAwMDBaFw0xMzA5MTgxMjAwMDBaMGcxCzAJBgNVBAYTAlVTMQswCQYDVQQI
# EwJDTzEVMBMGA1UEBxMMRm9ydCBDb2xsaW5zMRkwFwYDVQQKExA2TDYgU29mdHdh
# cmUgTExDMRkwFwYDVQQDExA2TDYgU29mdHdhcmUgTExDMIIBIjANBgkqhkiG9w0B
# AQEFAAOCAQ8AMIIBCgKCAQEAvtSuQar5tMsJw1RaGhLz9ECpar95hZ4d0dHivIK2
# maFz8QQeSJbqQbouzWJWfgvncWIhfZs9wyJjCdHbW7xVSmK/GPI+mfTky66lP99W
# dfV6gY0WkBYkFvzTQ0s/P9+qS1PEfAb8CFZYx3Ti8GVSUVSS87/TZm1SS+lnCg4m
# Rlp+BM9FDaK8IA/UjUjl277qmVnfvB35ey4I81421hsl5uJsZ5ZB+C9PFvkIzhR4
# Eo7o7R13Erjiryran/aJb77YgjRueC+EZ8rCx+kDq5TsLAzYZQwfgaKXpFlvXdiF
# vdFD6Hf6j4QonmtwG1RDYS5Vp1O/d2y/aunhKW3Wr94kywIDAQABo4IDOTCCAzUw
# HwYDVR0jBBgwFoAUe2jOKarAF75JeuHlP9an90WPNTIwHQYDVR0OBBYEFPNABKbs
# Aid4soPC5f6eM7TdDs50MA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggrBgEF
# BQcDAzBzBgNVHR8EbDBqMDOgMaAvhi1odHRwOi8vY3JsMy5kaWdpY2VydC5jb20v
# YXNzdXJlZC1jcy0yMDExYS5jcmwwM6AxoC+GLWh0dHA6Ly9jcmw0LmRpZ2ljZXJ0
# LmNvbS9hc3N1cmVkLWNzLTIwMTFhLmNybDCCAcQGA1UdIASCAbswggG3MIIBswYJ
# YIZIAYb9bAMBMIIBpDA6BggrBgEFBQcCARYuaHR0cDovL3d3dy5kaWdpY2VydC5j
# b20vc3NsLWNwcy1yZXBvc2l0b3J5Lmh0bTCCAWQGCCsGAQUFBwICMIIBVh6CAVIA
# QQBuAHkAIAB1AHMAZQAgAG8AZgAgAHQAaABpAHMAIABDAGUAcgB0AGkAZgBpAGMA
# YQB0AGUAIABjAG8AbgBzAHQAaQB0AHUAdABlAHMAIABhAGMAYwBlAHAAdABhAG4A
# YwBlACAAbwBmACAAdABoAGUAIABEAGkAZwBpAEMAZQByAHQAIABDAFAALwBDAFAA
# UwAgAGEAbgBkACAAdABoAGUAIABSAGUAbAB5AGkAbgBnACAAUABhAHIAdAB5ACAA
# QQBnAHIAZQBlAG0AZQBuAHQAIAB3AGgAaQBjAGgAIABsAGkAbQBpAHQAIABsAGkA
# YQBiAGkAbABpAHQAeQAgAGEAbgBkACAAYQByAGUAIABpAG4AYwBvAHIAcABvAHIA
# YQB0AGUAZAAgAGgAZQByAGUAaQBuACAAYgB5ACAAcgBlAGYAZQByAGUAbgBjAGUA
# LjCBggYIKwYBBQUHAQEEdjB0MCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdp
# Y2VydC5jb20wTAYIKwYBBQUHMAKGQGh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNv
# bS9EaWdpQ2VydEFzc3VyZWRJRENvZGVTaWduaW5nQ0EtMS5jcnQwDAYDVR0TAQH/
# BAIwADANBgkqhkiG9w0BAQUFAAOCAQEAIK6UA1qKXKbv5fphePINxEahQyZCLaFY
# OO+Q2jcrnrXofOGqZOLz/M33cJErAOyZQvKANOKybsMlpzmkQpP8jJsNRXuDmEOl
# bilUkwssxSTHeLfKgfRbB5RMi7RhvWyzhoC+FELHI+99VDJAQzWYwokAsSHohUPj
# QsEn6sI2ITvxOKgZKurzzFTmFberEA55RoszUKRcP9E0aW6L94ysSpVmzcJxY8ZE
# ny91ACmlHCSzxjrON/nlikzFtDTRlLr//dAm/XPXNlpEA1gIqS4zqUapRyFP/VhW
# NgHsjMdwIHpRAgpLPkvobG+TMHobi2IqkzSt5SrrDVcaH7t+RpKlLTCCBqAwggWI
# oAMCAQICEAf0c2+v70CKH2ZA8mXRCsEwDQYJKoZIhvcNAQEFBQAwZTELMAkGA1UE
# BhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2lj
# ZXJ0LmNvbTEkMCIGA1UEAxMbRGlnaUNlcnQgQXNzdXJlZCBJRCBSb290IENBMB4X
# DTExMDIxMDEyMDAwMFoXDTI2MDIxMDEyMDAwMFowbzELMAkGA1UEBhMCVVMxFTAT
# BgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEu
# MCwGA1UEAxMlRGlnaUNlcnQgQXNzdXJlZCBJRCBDb2RlIFNpZ25pbmcgQ0EtMTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJx8+aCPCsqJS1OaPOwZIn8M
# y/dIRNA/Im6aT/rO38bTJJH/qFKT53L48UaGlMWrF/R4f8t6vpAmHHxTL+WD57tq
# BSjMoBcRSxgg87e98tzLuIZARR9P+TmY0zvrb2mkXAEusWbpprjcBt6ujWL+RCeC
# qQPD/uYmC5NJceU4bU7+gFxnd7XVb2ZklGu7iElo2NH0fiHB5sUeyeCWuAmV+Uue
# rswxvWpaQqfEBUd9YCvZoV29+1aT7xv8cvnfPjL93SosMkbaXmO80LjLTBA1/FBf
# rENEfP6ERFC0jCo9dAz0eotyS+BWtRO2Y+k/Tkkj5wYW8CWrAfgoQebH1GQ7XasC
# AwEAAaOCA0AwggM8MA4GA1UdDwEB/wQEAwIBBjATBgNVHSUEDDAKBggrBgEFBQcD
# AzCCAcMGA1UdIASCAbowggG2MIIBsgYIYIZIAYb9bAMwggGkMDoGCCsGAQUFBwIB
# Fi5odHRwOi8vd3d3LmRpZ2ljZXJ0LmNvbS9zc2wtY3BzLXJlcG9zaXRvcnkuaHRt
# MIIBZAYIKwYBBQUHAgIwggFWHoIBUgBBAG4AeQAgAHUAcwBlACAAbwBmACAAdABo
# AGkAcwAgAEMAZQByAHQAaQBmAGkAYwBhAHQAZQAgAGMAbwBuAHMAdABpAHQAdQB0
# AGUAcwAgAGEAYwBjAGUAcAB0AGEAbgBjAGUAIABvAGYAIAB0AGgAZQAgAEQAaQBn
# AGkAQwBlAHIAdAAgAEMAUAAvAEMAUABTACAAYQBuAGQAIAB0AGgAZQAgAFIAZQBs
# AHkAaQBuAGcAIABQAGEAcgB0AHkAIABBAGcAcgBlAGUAbQBlAG4AdAAgAHcAaABp
# AGMAaAAgAGwAaQBtAGkAdAAgAGwAaQBhAGIAaQBsAGkAdAB5ACAAYQBuAGQAIABh
# AHIAZQAgAGkAbgBjAG8AcgBwAG8AcgBhAHQAZQBkACAAaABlAHIAZQBpAG4AIABi
# AHkAIAByAGUAZgBlAHIAZQBuAGMAZQAuMA8GA1UdEwEB/wQFMAMBAf8weQYIKwYB
# BQUHAQEEbTBrMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20w
# QwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2Vy
# dEFzc3VyZWRJRFJvb3RDQS5jcnQwgYEGA1UdHwR6MHgwOqA4oDaGNGh0dHA6Ly9j
# cmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcmwwOqA4
# oDaGNGh0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJv
# b3RDQS5jcmwwHQYDVR0OBBYEFHtozimqwBe+SXrh5T/Wp/dFjzUyMB8GA1UdIwQY
# MBaAFEXroq/0ksuCMS1Ri6enIZ3zbcgPMA0GCSqGSIb3DQEBBQUAA4IBAQCPJ3L2
# XadkkG25JWDGsBetHvmd7qFQgoTHKlU1rBhCuzbY3lPwkie/M1WvSlq4OA3r9OQ4
# DY38RegRPAw1V69KXHlBV94JpA8RkxA6fG40gz3xb/l0H4sRKsqbsO/TgJJEQ9El
# yTkyITHnKYLKxEGIyAeBp/1bIRd+HbqpY2jIctHil1lyQubYp7a6sy7JZK2TwuHl
# eKm36bs9MZKa3pGJJgoLXj5Oz2HrWmxkBT57q3+mWN0elcdeW8phnTR1pOUHSPhM
# 0k88EjW7XxFljf1yueiXIKUxh77LAx/LAzlu97I7OJV9cEW4VvWAcoEETIBzoK0t
# OfUCyOSF1TskL7NsMIIGzTCCBbWgAwIBAgIQBv35A5YDreoACus/J7u6GzANBgkq
# hkiG9w0BAQUFADBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5j
# MRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBB
# c3N1cmVkIElEIFJvb3QgQ0EwHhcNMDYxMTEwMDAwMDAwWhcNMjExMTEwMDAwMDAw
# WjBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQL
# ExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBBc3N1cmVkIElE
# IENBLTEwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDogi2Z+crCQpWl
# gHNAcNKeVlRcqcTSQQaPyTP8TUWRXIGf7Syc+BZZ3561JBXCmLm0d0ncicQK2q/L
# XmvtrbBxMevPOkAMRk2T7It6NggDqww0/hhJgv7HxzFIgHweog+SDlDJxofrNj/Y
# MMP/pvf7os1vcyP+rFYFkPAyIRaJxnCI+QWXfaPHQ90C6Ds97bFBo+0/vtuVSMTu
# HrPyvAwrmdDGXRJCgeGDboJzPyZLFJCuWWYKxI2+0s4Grq2Eb0iEm09AufFM8q+Y
# +/bOQF1c9qjxL6/siSLyaxhlscFzrdfx2M8eCnRcQrhofrfVdwonVnwPYqQ/MhRg
# lf0HBKIJAgMBAAGjggN6MIIDdjAOBgNVHQ8BAf8EBAMCAYYwOwYDVR0lBDQwMgYI
# KwYBBQUHAwEGCCsGAQUFBwMCBggrBgEFBQcDAwYIKwYBBQUHAwQGCCsGAQUFBwMI
# MIIB0gYDVR0gBIIByTCCAcUwggG0BgpghkgBhv1sAAEEMIIBpDA6BggrBgEFBQcC
# ARYuaHR0cDovL3d3dy5kaWdpY2VydC5jb20vc3NsLWNwcy1yZXBvc2l0b3J5Lmh0
# bTCCAWQGCCsGAQUFBwICMIIBVh6CAVIAQQBuAHkAIAB1AHMAZQAgAG8AZgAgAHQA
# aABpAHMAIABDAGUAcgB0AGkAZgBpAGMAYQB0AGUAIABjAG8AbgBzAHQAaQB0AHUA
# dABlAHMAIABhAGMAYwBlAHAAdABhAG4AYwBlACAAbwBmACAAdABoAGUAIABEAGkA
# ZwBpAEMAZQByAHQAIABDAFAALwBDAFAAUwAgAGEAbgBkACAAdABoAGUAIABSAGUA
# bAB5AGkAbgBnACAAUABhAHIAdAB5ACAAQQBnAHIAZQBlAG0AZQBuAHQAIAB3AGgA
# aQBjAGgAIABsAGkAbQBpAHQAIABsAGkAYQBiAGkAbABpAHQAeQAgAGEAbgBkACAA
# YQByAGUAIABpAG4AYwBvAHIAcABvAHIAYQB0AGUAZAAgAGgAZQByAGUAaQBuACAA
# YgB5ACAAcgBlAGYAZQByAGUAbgBjAGUALjALBglghkgBhv1sAxUwEgYDVR0TAQH/
# BAgwBgEB/wIBADB5BggrBgEFBQcBAQRtMGswJAYIKwYBBQUHMAGGGGh0dHA6Ly9v
# Y3NwLmRpZ2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3aHR0cDovL2NhY2VydHMuZGln
# aWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNydDCBgQYDVR0fBHow
# eDA6oDigNoY0aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJl
# ZElEUm9vdENBLmNybDA6oDigNoY0aHR0cDovL2NybDQuZGlnaWNlcnQuY29tL0Rp
# Z2lDZXJ0QXNzdXJlZElEUm9vdENBLmNybDAdBgNVHQ4EFgQUFQASKxOYspkH7R7f
# or5XDStnAs0wHwYDVR0jBBgwFoAUReuir/SSy4IxLVGLp6chnfNtyA8wDQYJKoZI
# hvcNAQEFBQADggEBAEZQPsm3KCSnOB22WymvUs9S6TFHq1Zce9UNC0Gz7+x1H3Q4
# 8rJcYaKclcNQ5IK5I9G6OoZyrTh4rHVdFxc0ckeFlFbR67s2hHfMJKXzBBlVqefj
# 56tizfuLLZDCwNK1lL1eT7EF0g49GqkUW6aGMWKoqDPkmzmnxPXOHXh2lCVz5Cqr
# z5x2S+1fwksW5EtwTACJHvzFebxMElf+X+EevAJdqP77BzhPDcZdkbkPZ0XN1oPt
# 55INjbFpjE/7WeAjD9KqrgB87pxCDs+R1ye3Fu4Pw718CqDuLAhVhSK46xgaTfwq
# Ia1JMYNHlXdx3LEbS0scEJx3FMGdTy9alQgpECYxggQ4MIIENAIBATCBgzBvMQsw
# CQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cu
# ZGlnaWNlcnQuY29tMS4wLAYDVQQDEyVEaWdpQ2VydCBBc3N1cmVkIElEIENvZGUg
# U2lnbmluZyBDQS0xAhAKFT0IddbjKM4R9plQj7wRMAkGBSsOAwIaBQCgeDAYBgor
# BgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEE
# MBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQg
# 8HuHLeV0v4MbBjMwIlauDGyoxzANBgkqhkiG9w0BAQEFAASCAQBCXfQ6drVozIx/
# eNiIuUZzDGlRZCqznr/8TybcciBCtL953UaduaueIB1R6WuO7XrNyfYEIZprQZri
# rCR8fsdplBVNVv6vTZ88xpWoABTw90C1WypEUK2upT2MJI+JROtuDFx2DTXI6H5M
# VS4nVfsJqrV/77/HsMWgb61t/EVDYDrMxMw1nFQJf5+MPYPDmWwsTbfOR2eXu/0J
# 3h6Fq2Cd3SCPdeUsHLmsX5v99fvzLQe33mr8dGZtMH3d85lgHED5pj2MOOd/MUBp
# r7xJCvW6/W0zCnbnOVkltVSY/bQLlr+96ttJNlERtc5R9s1SRlejaslFUElr/3SH
# Zc64wvC6oYICDzCCAgsGCSqGSIb3DQEJBjGCAfwwggH4AgEBMHYwYjELMAkGA1UE
# BhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2lj
# ZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgQXNzdXJlZCBJRCBDQS0xAhADi5bw
# cNniHlWlQmeS4cg6MAkGBSsOAwIaBQCgXTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcN
# AQcBMBwGCSqGSIb3DQEJBTEPFw0xMjEyMTcwMTUxMTFaMCMGCSqGSIb3DQEJBDEW
# BBTG/9zr5qwxLtZe9oeTIv1lxL1ZhzANBgkqhkiG9w0BAQEFAASCAQBdvxvD5wgN
# 5sVl0TSdAC7sJk9CGrDyTEZ8V0uUqQBwXvCekkchD6/hbR1KqiHCu2hE2vpAmJMy
# VzvS0yUUQjhW6Hz06jhjoDbtjn/s/svuGS7LEln/pl+KOOfXO+D8SNewmNSrWqdX
# U4P+KWRj8zlvOpXli4hp/dcekot4RIrbi13/e2yGEvvE+Ignw21Cnp5pry2EMzzx
# luz47m6DE0jIP1rPVeIPOh9P+ws593JpHSP2pqjjrKHFO5drsckK2LWm8JgdrDbA
# 313R9ZeQgmEqoRMj0q/19V9XAYmidseCNUIBXvKI0g8aNtkLTGLOyUQIeLvp0+gZ
# iW6FV08EOxoB
# SIG # End signature block
