function Convert-StringToScriptBlock{
	param(
		[parameter(ValueFromPipeline=$true,Position=0)]
		[string]
		$String
)
	$ScriptBlock = [scriptblock]::Create($String)

	return $ScriptBlock
}

