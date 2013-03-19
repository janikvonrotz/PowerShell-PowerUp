<#
.ForwardHelpTargetName Get-ChildItem
.ForwardHelpCategory Cmdlet
#>
function Get-ChildItem
{
    [CmdletBinding(DefaultParameterSetName='Items', SupportsTransactions=$true)]
    param(
        [Parameter(ParameterSetName='Items', Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [System.String[]]
        ${Path},

        [Parameter(ParameterSetName='LiteralItems', Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
        [Alias('PSPath')]
        [System.String[]]
        ${LiteralPath},

        [Parameter(Position=1)]
        [System.String]
        ${Filter},

        [System.String[]]
        ${Include},

        [System.String[]]
        ${Exclude},

        [Switch]
        ${Recurse},

        [Switch]
        ${Force},

        [Switch]
        ${Name},

        [Switch]
        ${ContainerOnly},
        
        [Switch]
        ${LeafOnly}
    )
    
    DynamicParam
    {
        if ($path -match ".*CERT.*:")
        {
            $attributes = new-object System.Management.Automation.ParameterAttribute
            $attributes.ParameterSetName = "__AllParameterSets"
            $attributes.Mandatory = $false
            $attributeCollection = new-object -Type System.Collections.ObjectModel.Collection[System.Attribute]
            $attributeCollection.Add($attributes)
            $dynParam = new-object -Type System.Management.Automation.RuntimeDefinedParameter("CodeSigningCert", [switch], $attributeCollection)
            $paramDictionary = new-object -Type System.Management.Automation.RuntimeDefinedParameterDictionary
            $paramDictionary.Add("CodeSigningCert", $dynParam)
            return $paramDictionary
        }
    }

    begin
    {
        try 
        {
            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Management\Get-ChildItem', [System.Management.Automation.CommandTypes]::Cmdlet)

            $outBuffer = $null
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
            {
                $PSBoundParameters['OutBuffer'] = 1
            }
            
            if ($ContainerOnly -and $LeafOnly)
            {
                throw "The parameters ContainerOnly and LeafOnly are mutually exclusive"
            }
            elseif ($ContainerOnly)
            {
                [void]$PSBoundParameters.Remove("ContainerOnly")
                $scriptCmd = {& $wrappedCmd @PSBoundParameters | Where-Object {$_.PSIsContainer}}                    
            }
            elseif ($LeafOnly)
            {
                [void]$PSBoundParameters.Remove("LeafOnly")
                $scriptCmd = {& $wrappedCmd @PSBoundParameters | Where-Object {!$_.PSIsContainer}}        
            }
            else
            {
                $scriptCmd = {& $wrappedCmd @PSBoundParameters }
            }      
            
            $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
            $steppablePipeline.Begin($PSCmdlet)
        } 
        catch 
        {
            throw
        }
    }

    process
    {
        try 
        {
            $steppablePipeline.Process($_)
        } 
        catch 
        {
            throw
        }
    }

    end
    {
        try 
        {
            $steppablePipeline.End()
        } 
        catch 
        {
            throw
        }
    }
}
# SIG # Begin signature block
# MIIfVQYJKoZIhvcNAQcCoIIfRjCCH0ICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUDPfikFtY7pUCrYD81LdkrTRi
# Kx+gghqHMIIGbzCCBVegAwIBAgIQA4uW8HDZ4h5VpUJnkuHIOjANBgkqhkiG9w0B
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
# MBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRk
# 9fNnIdbVNFNrKnNx8YqYeluWTTANBgkqhkiG9w0BAQEFAASCAQAQuiCdrMa4lUyT
# jynpTGW3J+fp0VXbcs6kWemagUNayN/gupZH2mxeoHqOYx64C+BDPCftGNoe9Nsc
# P7uAsLUTnN2+s+XGpL+uGFzLQjDtrXgMbdTtnhC9vh0fIjSRo1AcqqlVj+cgpPlx
# C+NdI8WupaZPgw1bq858mkdjPDD35+t0qvk5tdgu7VCovpat/j+Sr/1iMi6mHyYL
# RXEQ3aW3gT4yZG5fDxJdaruTs4bqpueObvfq/k2BV1wpwu12hghBPc72rZBEUO0e
# SpQGnDp07t/DcAjtMNbgNZnY5Bb3NqHBI/bPMkJEeW2o7r3eYwJ5EmCuX6UCxO2H
# wBsb5Qr6oYICDzCCAgsGCSqGSIb3DQEJBjGCAfwwggH4AgEBMHYwYjELMAkGA1UE
# BhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2lj
# ZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgQXNzdXJlZCBJRCBDQS0xAhADi5bw
# cNniHlWlQmeS4cg6MAkGBSsOAwIaBQCgXTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcN
# AQcBMBwGCSqGSIb3DQEJBTEPFw0xMjEyMTcwMTUxMTJaMCMGCSqGSIb3DQEJBDEW
# BBTxu+m4t7Qs0/RYINOq70lOR0iV0TANBgkqhkiG9w0BAQEFAASCAQCQlESvElR0
# Kv8thdfkCCahq3cm2Y09JtwCPrvid6ai4JGExAqp2a7ltsm3kDpa6Bs38L/D8CpN
# x2hSbDmqlDDHh0vDYWObtA3bVw8+G9N91emM3XUXxVVJeLznIAqKwFE6hRxxtNC8
# jbcngifrlttP1uKcnoGh7Blh+tmj3LVSwY+jAJDhso0K7s0bn2X0s6U65nL2kfDa
# 8+8J+cIT3ufcx55zjNXytJoH2pB/yobjX7Fs96bLJ1wYaw9yqqWnWwcNmd6QQvAp
# l/A91rsjhvvMYNHsNVQx19EuClOqJPb0HTaGXWmlWHi9K9LtAiCs+OJd9RqbjlAp
# odwn4ny64ba+
# SIG # End signature block
