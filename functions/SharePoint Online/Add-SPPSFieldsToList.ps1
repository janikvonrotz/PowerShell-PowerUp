<#
$Metadata = @{
	Title = "Add-SPPSFieldsToList"
	Filename = "Add-SPPSFieldsToList.ps1"
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

function Add-SPPSFieldsToList
{
	<#
	.SYNOPSIS
		Adds custom fields to the list
	.DESCRIPTION
		Fill the $fields property using an array of array (<fieldname>,<fieldtype>,<optional>)
		where fieldtypes are:
			Text
            Note
            DateTime
            Currency
            Number
            Choice (add choices comma-seperated to optional field)
            Person or Group
            Calculated (add expression to optional field)
	.PARAMETER fields
		Use an array of array (<fieldname>,<fieldtype>,<optional>)
		where fieldtypes are:
			Text
            Note
            DateTime
            Currency
            Number
            Choice (add choices comma-seperated to optional field)
            Person or Group
            Calculated (add expression to optional field)
	.PARAMETER listTitle
		Title of the list
	.EXAMPLE
		[string[][]]$fields = ("MyChoices","Choice","Left;Right"),
                              ("MyNumber","Number","")
	#>
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory=$true, Position=1)]
		[string[][]]$fields,
		
		[Parameter(Mandatory=$true, Position=2)]
		[string]$listTitle
	)
	
    foreach($field in $fields)
    {
        $fieldName = $field[0]
        $fieldType = $field[1]
        $fieldValue = $field[2]
        
        switch ($fieldType)
        {
            "Text"
            {
                Add-SPPSTextFieldtoList $listTitle $fieldName
            }
            "Note"
            {
                Add-SPPSNoteFieldtoList $listTitle $fieldName
            }
            "DateTime"
            {
                Add-SPPSDateTimeFieldtoList $listTitle $fieldName
            }
            "Currency"
            {
                Add-SPPSCurrencyFieldtoList $listTitle $fieldName
            }
            "Number"
            {
                Add-SPPSCurrencyFieldtoList $listTitle $fieldName
            }
            "Choice"
            {
                Add-SPPSChoiceFieldtoList $listTitle $fieldName $fieldValue
            }
            "Person or Group"
            {
                Add-SPPSUserFieldtoList $listTitle $fieldName
            }
            "Calculated"
            {
                Add-SPPSCalculatedFieldtoList $listTitle $fieldName $fieldValue
            }
        }
    }
}
