function New-LocalUser{

	param(
		$computer="localhost", 
		$user,
		$password
	)

	if(!$user -or !$password){
		throw "A value for $user and $password is required"
	}


		 

	$objOu = [ADSI]"WinNT://$computer"
	$objUser = $objOU.Create("User", $user)
	$objUser.setpassword($password)
	$objUser.SetInfo()
	$objUser.description = "Test user"
	$objUser.SetInfo()

}