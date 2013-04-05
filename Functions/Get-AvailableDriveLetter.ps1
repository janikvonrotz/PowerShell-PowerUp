function Get-AvailableDriveLetter {

	param(
		[parameter(Mandatory=$False)]
		[Switch]
		$ReturnFirstLetterOnly,
		[parameter(Mandatory=$False)]
		$FavoriteDriveLetter
	)

	$Metadata = @{
		Title = "Get Available Drive Letter"
		Filename = "Get-AvailableDriveLetter.ps1"
		Description = ""
		Tags = "powershell, functions"
		Project = ""
		Author = "Janik von Rotz"
		AuthorContact = "www.janikvonrotz.ch"
		CreateDate = "2013-03-11"
		LastEditDate = "2013-06-12"
		Version = "1.0.2"
		License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}

	if($ReturnFirstLetterOnly -eq $true -and $FavoriteDriveLetter -ne $null){
		throw "Only one parameter is possible for this function"
		exit
	}	
	
	# Removed letters A, B, C and D for possible free drive letters	
    $TempDriveLetters = [char[]]'EFGHIJKLMNOPQRSTUVWXYZ' | ? { (Get-PSDrive $_ -ErrorAction 'SilentlyContinue') -eq $null }


	if ($ReturnFirstLetterOnly -eq $true)
	{
		$TempDriveLetters[0]
	}
	elseif($TempDriveLetters.contains($FavoriteDriveLetter)){
	    $FavoriteDriveLetter
    }elseif($FavoriteDriveLetter -ne $null){
		$TempDriveLetters[0]
    }else{
	    $TempDriveLetters
    }		
}