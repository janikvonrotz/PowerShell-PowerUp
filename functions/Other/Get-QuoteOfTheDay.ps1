function Get-QuoteOfTheDay{

<#
.SYNOPSIS
	Get quote of the day
#>

	$Metadata = @{
		Title = "Get quote of the Day"
		Filename = "Get-QuoteOfTheDay.ps1"
		Description = ""
		Tags = ""
		Project = ""
		Author = "Janik von Rotz"
		AuthorContact = "www.janikvonrotz.ch"
		CreateDate = "2013-05-16"
		LastEditDate = "2013-05-16"
		Version = "1.0.0"
		License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}

	#--------------------------------------------------#
	# settings
	#--------------------------------------------------#

	$RssUrl = "http://feeds.feedburner.com/brainyquote/QUOTEBR"

	#--------------------------------------------------#
	# main
	#--------------------------------------------------#
	# read rss feed
	$blog = [xml](new-object System.Net.WebClient).DownloadString($rssUrl)

	# get first quote
	$quote = $blog.rss.channel.item[0]

	#  quote output
	Write-Host $quote.description "`n`t-"$quote.title
	
}