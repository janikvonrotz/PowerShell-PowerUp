$global:hostname = $null

function prompt 
{ 
	if($global:hostname -eq $null) {$global:hostname = $(hostname)}
	$cwd = (get-location).Path
	
	$host.UI.RawUI.WindowTitle = "ActiveRoles Management Shell [$global:hostname]"
	$host.UI.Write("Yellow", $host.UI.RawUI.BackGroundColor, "[PS]")
	" $cwd>" 
}

function OpenURL([string] $url)
{
	$ie = new-object -comobject "InternetExplorer.Application"
	$ie.visible = $true
	$ie.navigate($url)
}

## only returns Active Roles commands 
function get-qcommand
{
	if ($args[0] -eq $null)
	{
		get-command -pssnapin Quest.ActiveRoles*
	}
	else
	{
		get-command $args[0] | where { $_.psSnapin -ilike 'Quest.ActiveRoles*' }
	}
}

function Get-QARSProductInfo
{
	OpenURL('http://www.quest.com/activeroles-server/')
}

function Get-QARSCommunity
{
	OpenURL('http://activeroles.inside.quest.com/forum.jspa?forumID=262')
}

function prepare-host
{
	$ui = (get-host).UI.RawUI

	$bufferSize = $ui.BufferSize
	$bufferSize.Width = 120
	$bufferSize.Height = 3000

	$windowSize = $ui.WindowSize
	$windowSize.Width = 120
	$windowSize.Height = 50

	$ui.BufferSize = $bufferSize
	$ui.WindowSize = $windowSize
	$ui.BackgroundColor = 'DarkBlue'
	$ui.ForegroundColor = 'White'

	clear
}

function get-questBanner
{
	prepare-host

	write-host "`n         Welcome to ActiveRoles Management Shell 1.5.1, a part of Quest ActiveRoles Server 6.7`n"
	
	write-host " View ActiveRoles Server product page:     " -no
	write-host -fore Yellow "Get-QARSProductInfo"
	
	write-host " Visit ActiveRoles Server community site:  " -no
	write-host -fore Yellow "Get-QARSCommunity"

	write-host " List all cmdlets:                         " -no 
	write-host -fore Yellow "Get-Command"

	write-host " List only Management Shell cmdlets:       " -no
	write-host -fore Yellow "Get-QCommand"	

	write-host " View help:                                " -no
	write-host -fore Yellow "Get-Help"

	write-host " View help about a cmdlet:                 " -no
	write-host -fore Yellow "Get-Help <cmdlet-name> or <cmdlet-name> -?"		

	write-host " View full output for a cmd:               " -no
	write-host -fore Yellow "<cmd> | Format-List`n"
}

get-questBanner
# SIG # Begin signature block
# MIIVNAYJKoZIhvcNAQcCoIIVJTCCFSECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUxtEfBsDYs9gGkMTZ5VYRwHmL
# 0YugghE3MIIDejCCAmKgAwIBAgIQOCXX+vhhr570kOcmtdZa1TANBgkqhkiG9w0B
# AQUFADBTMQswCQYDVQQGEwJVUzEXMBUGA1UEChMOVmVyaVNpZ24sIEluYy4xKzAp
# BgNVBAMTIlZlcmlTaWduIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0EwHhcNMDcw
# NjE1MDAwMDAwWhcNMTIwNjE0MjM1OTU5WjBcMQswCQYDVQQGEwJVUzEXMBUGA1UE
# ChMOVmVyaVNpZ24sIEluYy4xNDAyBgNVBAMTK1ZlcmlTaWduIFRpbWUgU3RhbXBp
# bmcgU2VydmljZXMgU2lnbmVyIC0gRzIwgZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJ
# AoGBAMS18lIVvIiGYCkWSlsvS5Frh5HzNVRYNerRNl5iTVJRNHHCe2YdicjdKsRq
# CvY32Zh0kfaSrrC1dpbxqUpjRUcuawuSTksrjO5YSovUB+QaLPiCqljZzULzLcB1
# 3o2rx44dmmxMCJUe3tvvZ+FywknCnmA84eK+FqNjeGkUe60tAgMBAAGjgcQwgcEw
# NAYIKwYBBQUHAQEEKDAmMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC52ZXJpc2ln
# bi5jb20wDAYDVR0TAQH/BAIwADAzBgNVHR8ELDAqMCigJqAkhiJodHRwOi8vY3Js
# LnZlcmlzaWduLmNvbS90c3MtY2EuY3JsMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMI
# MA4GA1UdDwEB/wQEAwIGwDAeBgNVHREEFzAVpBMwETEPMA0GA1UEAxMGVFNBMS0y
# MA0GCSqGSIb3DQEBBQUAA4IBAQBQxUvIJIDf5A0kwt4asaECoaaCLQyDFYE3CoIO
# LLBaF2G12AX+iNvxkZGzVhpApuuSvjg5sHU2dDqYT+Q3upmJypVCHbC5x6CNV+D6
# 1WQEQjVOAdEzohfITaonx/LhhkwCOE2DeMb8U+Dr4AaH3aSWnl4MmOKlvr+ChcNg
# 4d+tKNjHpUtk2scbW72sOQjVOCKhM4sviprrvAchP0RBCQe1ZRwkvEjTRIDroc/J
# ArQUz1THFqOAXPl5Pl1yfYgXnixDospTzn099io6uE+UAKVtCoNd+V5T9BizVw9w
# w/v1rZWgDhfexBaAYMkPK26GBPHr9Hgn0QXF7jRbXrlJMvIzMIIDxDCCAy2gAwIB
# AgIQR78Zld+NUkZD99ttSA0xpDANBgkqhkiG9w0BAQUFADCBizELMAkGA1UEBhMC
# WkExFTATBgNVBAgTDFdlc3Rlcm4gQ2FwZTEUMBIGA1UEBxMLRHVyYmFudmlsbGUx
# DzANBgNVBAoTBlRoYXd0ZTEdMBsGA1UECxMUVGhhd3RlIENlcnRpZmljYXRpb24x
# HzAdBgNVBAMTFlRoYXd0ZSBUaW1lc3RhbXBpbmcgQ0EwHhcNMDMxMjA0MDAwMDAw
# WhcNMTMxMjAzMjM1OTU5WjBTMQswCQYDVQQGEwJVUzEXMBUGA1UEChMOVmVyaVNp
# Z24sIEluYy4xKzApBgNVBAMTIlZlcmlTaWduIFRpbWUgU3RhbXBpbmcgU2Vydmlj
# ZXMgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCpyrKkzM0grwp9
# iayHdfC0TvHfwQ+/Z2G9o2Qc2rv5yjOrhDCJWH6M22vdNp4Pv9HsePJ3pn5vPL+T
# rw26aPRslMq9Ui2rSD31ttVdXxsCn/ovax6k96OaphrIAuF/TFLjDmDsQBx+uQ3e
# P8e034e9X3pqMS4DmYETqEcgzjFzDVctzXg0M5USmRK53mgvqubjwoqMKsOLIYdm
# vYNYV291vzyqJoddyhAVPJ+E6lTBCm7E/sVK3bkHEZcifNs+J9EeeOyfMcnx5iIZ
# 28SzR0OaGl+gHpDkXvXufPF9q2IBj/VNC97QIlaolc2uiHau7roN8+RN2aD7aKCu
# FDuzh8G7AgMBAAGjgdswgdgwNAYIKwYBBQUHAQEEKDAmMCQGCCsGAQUFBzABhhho
# dHRwOi8vb2NzcC52ZXJpc2lnbi5jb20wEgYDVR0TAQH/BAgwBgEB/wIBADBBBgNV
# HR8EOjA4MDagNKAyhjBodHRwOi8vY3JsLnZlcmlzaWduLmNvbS9UaGF3dGVUaW1l
# c3RhbXBpbmdDQS5jcmwwEwYDVR0lBAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQD
# AgEGMCQGA1UdEQQdMBukGTAXMRUwEwYDVQQDEwxUU0EyMDQ4LTEtNTMwDQYJKoZI
# hvcNAQEFBQADgYEASmv56ljCRBwxiXmZK5a/gqwB1hxMzbCKWG7fCCmjXsjKkxPn
# BFIN70cnLwA4sOTJk06a1CJiFfc/NyFPcDGA8Ys4h7Po6JcA/s9Vlk4k0qknTnqu
# t2FB8yrO58nZXt27K4U+tZ212eFX/760xX71zwye8Jf+K9M7UhsbOCf3P0owggTt
# MIID1aADAgECAhA65JxsDPgqoirBAJLfbBLWMA0GCSqGSIb3DQEBBQUAMIG2MQsw
# CQYDVQQGEwJVUzEXMBUGA1UEChMOVmVyaVNpZ24sIEluYy4xHzAdBgNVBAsTFlZl
# cmlTaWduIFRydXN0IE5ldHdvcmsxOzA5BgNVBAsTMlRlcm1zIG9mIHVzZSBhdCBo
# dHRwczovL3d3dy52ZXJpc2lnbi5jb20vcnBhIChjKTA5MTAwLgYDVQQDEydWZXJp
# U2lnbiBDbGFzcyAzIENvZGUgU2lnbmluZyAyMDA5LTIgQ0EwHhcNMDkxMTE2MDAw
# MDAwWhcNMTIxMTE1MjM1OTU5WjCBqjELMAkGA1UEBhMCVVMxEzARBgNVBAgTCkNh
# bGlmb3JuaWExFDASBgNVBAcTC0FsaXNvIFZpZWpvMRcwFQYDVQQKFA5RdWVzdCBT
# b2Z0d2FyZTE+MDwGA1UECxM1RGlnaXRhbCBJRCBDbGFzcyAzIC0gTWljcm9zb2Z0
# IFNvZnR3YXJlIFZhbGlkYXRpb24gdjIxFzAVBgNVBAMUDlF1ZXN0IFNvZnR3YXJl
# MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC+gwL9BVL4s92Oy2toaKvI9LBZ
# aWR7r6yKNBlatVw93ikzcR7ot1n5fm3dJ03fRTuG3D+MszLO0pBoWgYB26+VB9TB
# DUCb3eioLahxFWUEhHkiXc6qT39CpePHbjfXUF1PRITbQ4pdQzo0ZM8d1NRCugqU
# Bvv/ZqdvbJE+GKil/QIDAQABo4IBgzCCAX8wCQYDVR0TBAIwADAOBgNVHQ8BAf8E
# BAMCB4AwRAYDVR0fBD0wOzA5oDegNYYzaHR0cDovL2NzYzMtMjAwOS0yLWNybC52
# ZXJpc2lnbi5jb20vQ1NDMy0yMDA5LTIuY3JsMEQGA1UdIAQ9MDswOQYLYIZIAYb4
# RQEHFwMwKjAoBggrBgEFBQcCARYcaHR0cHM6Ly93d3cudmVyaXNpZ24uY29tL3Jw
# YTATBgNVHSUEDDAKBggrBgEFBQcDAzB1BggrBgEFBQcBAQRpMGcwJAYIKwYBBQUH
# MAGGGGh0dHA6Ly9vY3NwLnZlcmlzaWduLmNvbTA/BggrBgEFBQcwAoYzaHR0cDov
# L2NzYzMtMjAwOS0yLWFpYS52ZXJpc2lnbi5jb20vQ1NDMy0yMDA5LTIuY2VyMB8G
# A1UdIwQYMBaAFJfQa6gmcMihP5QfCC3ENZukoR7yMBEGCWCGSAGG+EIBAQQEAwIE
# EDAWBgorBgEEAYI3AgEbBAgwBgEBAAEB/zANBgkqhkiG9w0BAQUFAAOCAQEAqqU1
# alGdsFnJgeW063ghGu35+K9P3XBG5kOHSJWSQOGkVRRz01Me8XTAjTqhLHhdJeVy
# CiwYQu5FkoJ9Mn3b39xccSbBqip227+IkKEjckaMzm9nfxgh0AC8u8mQVq/De12s
# BTxM1++4vgt4ueAP62s6inTfd/lWDfXNPa6u9ktL1gIzYq3L8k1qK1SGcF+VyC1A
# mjbRuszm7MQn+iDuUaEZi+kiXqmhH8LZGPjVj00mWO3qoc+P8QDPl8whY9/uvt3X
# 2FMrnF4zvn2TjDerzBLevayomniCSvT7eskl28veneIlkdsiBwBcv83lPPXghiax
# 1p49Hpe5JJ0wnnWnvDCCBPwwggRloAMCAQICEGVSJuGyLhjhWQ8phawi51wwDQYJ
# KoZIhvcNAQEFBQAwXzELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDlZlcmlTaWduLCBJ
# bmMuMTcwNQYDVQQLEy5DbGFzcyAzIFB1YmxpYyBQcmltYXJ5IENlcnRpZmljYXRp
# b24gQXV0aG9yaXR5MB4XDTA5MDUyMTAwMDAwMFoXDTE5MDUyMDIzNTk1OVowgbYx
# CzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5WZXJpU2lnbiwgSW5jLjEfMB0GA1UECxMW
# VmVyaVNpZ24gVHJ1c3QgTmV0d29yazE7MDkGA1UECxMyVGVybXMgb2YgdXNlIGF0
# IGh0dHBzOi8vd3d3LnZlcmlzaWduLmNvbS9ycGEgKGMpMDkxMDAuBgNVBAMTJ1Zl
# cmlTaWduIENsYXNzIDMgQ29kZSBTaWduaW5nIDIwMDktMiBDQTCCASIwDQYJKoZI
# hvcNAQEBBQADggEPADCCAQoCggEBAL5nHbRgqhBJb1YXfGbJXoYN1fGsp3GDjouJ
# +IgEiRUGui2EIZXk0ZxQTPvSIr3a8rI1Ox6Pwwn7/BMuWr+JfD07JR7281h7nPQB
# tcYKuIDOvid0YWcnTWrl7IFhWHmj4BcQEhUnsOFNNH8rRyBEud5mJGaKzU+6H8U4
# yFSQ4XL2GWZ1arlJaM84eQ2qMKjbLGBInteqFAGpg9c4kTA5E5YDOnxAVLat4C8b
# g9yoEVI+ArPXK/0htqdcow8LqaYQUA40Lk2nzsleJdSMvPNufCm8AV38MYda1YyF
# Z1iIGaC/NfDqK6Mh55D2g+Wo7WB4Xntgg/1XC11BDWNUYNZDIe8CAwEAAaOCAdsw
# ggHXMBIGA1UdEwEB/wQIMAYBAf8CAQAwcAYDVR0gBGkwZzBlBgtghkgBhvhFAQcX
# AzBWMCgGCCsGAQUFBwIBFhxodHRwczovL3d3dy52ZXJpc2lnbi5jb20vY3BzMCoG
# CCsGAQUFBwICMB4aHGh0dHBzOi8vd3d3LnZlcmlzaWduLmNvbS9ycGEwDgYDVR0P
# AQH/BAQDAgEGMG0GCCsGAQUFBwEMBGEwX6FdoFswWTBXMFUWCWltYWdlL2dpZjAh
# MB8wBwYFKw4DAhoEFI/l0xqGrI2Oa8PPgGrUSBgsexkuMCUWI2h0dHA6Ly9sb2dv
# LnZlcmlzaWduLmNvbS92c2xvZ28uZ2lmMB0GA1UdJQQWMBQGCCsGAQUFBwMCBggr
# BgEFBQcDAzA0BggrBgEFBQcBAQQoMCYwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3Nw
# LnZlcmlzaWduLmNvbTAxBgNVHR8EKjAoMCagJKAihiBodHRwOi8vY3JsLnZlcmlz
# aWduLmNvbS9wY2EzLmNybDApBgNVHREEIjAgpB4wHDEaMBgGA1UEAxMRQ2xhc3Mz
# Q0EyMDQ4LTEtNTUwHQYDVR0OBBYEFJfQa6gmcMihP5QfCC3ENZukoR7yMA0GCSqG
# SIb3DQEBBQUAA4GBAIsDwN2U2EGiYWmwFah4xzDGkDx+QvcktuSDcxcEfwQQnKHi
# +oEv68DKROdy4FC2VRAgg26WkuSaUWq0NzHcpS3rjADHHU/nTTK6hfhOvvpnVWXw
# ar56ymQ4GhAQeEV2MfOGegMPYMKzXZ32i2Z2ghtZ4YPlvUmlOFbl3kF3DlgPMYID
# ZzCCA2MCAQEwgcswgbYxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5WZXJpU2lnbiwg
# SW5jLjEfMB0GA1UECxMWVmVyaVNpZ24gVHJ1c3QgTmV0d29yazE7MDkGA1UECxMy
# VGVybXMgb2YgdXNlIGF0IGh0dHBzOi8vd3d3LnZlcmlzaWduLmNvbS9ycGEgKGMp
# MDkxMDAuBgNVBAMTJ1ZlcmlTaWduIENsYXNzIDMgQ29kZSBTaWduaW5nIDIwMDkt
# MiBDQQIQOuScbAz4KqIqwQCS32wS1jAJBgUrDgMCGgUAoHAwEAYKKwYBBAGCNwIB
# DDECMAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFIBGrFEQsIq9X7qsKAyXXN62
# BvqZMA0GCSqGSIb3DQEBAQUABIGAKKV5UvM2vja4DpMSqsKwdi3oLRbnrTvQC2qN
# VRYXOAUTtAjLweeMlWX/s09zrJmAiV93zU31mS7eExBT7S6Va4qfAIAvvtJPvOfK
# tNsgW5qd2Z+C1VkmwdynJ33Qv0KUPx+ouySImn0HpMbMtItq8EfLqtZKSV9j8ep7
# hMG7XRChggF/MIIBewYJKoZIhvcNAQkGMYIBbDCCAWgCAQEwZzBTMQswCQYDVQQG
# EwJVUzEXMBUGA1UEChMOVmVyaVNpZ24sIEluYy4xKzApBgNVBAMTIlZlcmlTaWdu
# IFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0ECEDgl1/r4Ya+e9JDnJrXWWtUwCQYF
# Kw4DAhoFAKBdMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkF
# MQ8XDTExMDQyNjA4MjM0OVowIwYJKoZIhvcNAQkEMRYEFLgZNUCMrE0KC6zkjdVP
# 97ddgsywMA0GCSqGSIb3DQEBAQUABIGAM7uAe0X0GuebjBYhra8xiwrEPK7gQe09
# JRji47kfxzf71XOEBYQdw9BDVB5B6wrqsBzfBRlsIX+VXwr3XjSYylcqV3fmwPHk
# Whktl9UCSgNBOdEq77xAl1hIJDKr3E2ckbITXnoZ8ta9qm0geAJe1iqmxCMHu+2f
# 3WCT7wgZhY8=
# SIG # End signature block
