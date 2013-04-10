##
##    PowerShell module to output hello worlds!
##

#requires -Version 2.0
function ConvertFrom-Json {
[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$true, Position=0)]    
    $JSON
)     
    Add-Type -Path $PSScriptRoot\JsonParser.Net35.dll
    [JsonParser.JsonParser]::FromJson($JSON)
<#
.Synopsis
    Converts input JSON string to powershell objects
	
.Example
    [TBD]

#>
}
function ConvertTo-Json {
[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$true, Position=0)]    
    $InputObject
)
    Add-Type -Path $PSScriptRoot\JsonParser.Net35.dll    
        
    function ToDictionary($inp){
            
        $outp = new-object "System.Collections.Generic.Dictionary``2[[System.String],[System.Object]]"
    
        foreach($key in $inp.Keys){
            $item = $inp[$key]
            if ($item -is [Collections.Hashtable]){
                $item = ToDictionary($item)
            }
            $outp.Add($key, $item)		
    	}
        
        $outp
    }
    
    $DataToConvert = ToDictionary($InputObject)    
	[JsonParser.JsonParser]::ToJson($DataToConvert)
<#
.Synopsis
    Converts input dictionary to JSON object
	
.Example    
    ConvertTo-JSON @{"foo" = "bar"}

    Description
    -----------
    Converts hastable to JSON string
    
.Example    
    
    ConvertTo-JSON @{"foo" = "bar"; "child" = @{"coo" = "roo" }}

    Description
    -----------
    Converts hastable with child objects to JSON string
#>
}

function Format-Json {
[CmdletBinding()]
Param(
    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$true, Position=0)]    
    [String]$Input
)

    function PrintJson($Obj, $Ident = ""){
        $Ident = $Ident + "  "
                    
        foreach($key in $Obj.Keys){
            $val = $Obj.$key

            if ($val -eq $Null){
                continue
            }

            Write-Host $Ident -NoNewLine
            if ($val.Keys -ne $NULL){
                Write-Host $key -ForegroundColor White -NoNewLine
                Write-Host " : " -ForegroundColor Gray -NoNewLine
                Write-Host "{" -ForegroundColor Yellow
                PrintJson $val $Ident
                Write-Host "$Ident}" -ForegroundColor Yellow       
            }
            elseif ($val -is [System.Collections.ICollection]) {            
                Write-Host $key -ForegroundColor White -NoNewLine
                Write-Host " : " -ForegroundColor Gray -NoNewLine
                Write-Host "[" -ForegroundColor Yellow  -NoNewLine
                foreach($child in $val){
                    if ($child -ne ""){
                        Write-Host "{" -ForegroundColor Yellow
                        PrintJson $child $Ident
                        Write-Host "$Ident}," -ForegroundColor Yellow  -NoNewLine
                    }
                }
                Write-Host "]" -ForegroundColor Yellow
            }
            else {
                Write-Host $key -ForegroundColor White -NoNewLine
                Write-Host " : " -ForegroundColor Gray -NoNewLine
                Write-Host $val -ForegroundColor White -NoNewLine 
                Write-Host "," -ForegroundColor Gray
            }
        }    
    }

    Add-Type -Path PsJson\JsonParser.Net35.dll
    $Obj = [JsonParser.JsonParser]::FromJson($Input)    

    Write-Host "{" -ForegroundColor Yellow
    PrintJson $Obj
    Write-Host "}" -ForegroundColor Yellow       
}