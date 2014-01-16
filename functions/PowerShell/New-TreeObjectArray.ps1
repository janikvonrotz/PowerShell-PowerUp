<#
$Metadata = @{
	Title = "New Tree Object Array"
	Filename = "New-TreeObjectArray.ps1"
	Description = ""
	Tags = ""
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2014-01-16"
	LastEditDate = "2014-01-16"
	Url = ""
	Version = "0.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function New-TreeObjectArray{

<#
.SYNOPSIS
    Expands array objects that references them self.

.DESCRIPTION
	Expands array objects that references them self based on attribute and a filter attribute.

.PARAMETER Array
	Array holding the objects.

.PARAMETER Objects
	Selected Objects to expand.

.PARAMETER Attribute
	Name of the Object attribute holding the foreign keys.
	
.PARAMETER Filter
	Name of the Object attribute holding the ID referenced by the foreign keys.
	
.PARAMETER Level
	Levels to check the MaxLoops parameter.
	
.PARAMETER MaxLoops
	Maximal loops for infinite iterations.
	
.EXAMPLE
	PS C:\> New-TreeObjectArray -Array $ArrayOfObjects -Objects $ObjectsToExpand -Attribute $NameofTheAttributeContainingTheForeignKey -Filter $NameOfTheIDReferencedByForeignKey
#>

    param(    
        $Array,
        $Objects,     
        $Attribute,        
        $Filter,
        $Level = 0,
        $MaxLoops = 10
    )
    
    # copy objects, pointers are not allowed
    $Objects = $Objects.psobject.Copy()

    if( -not ($Level -eq $MaxLoops)){
                
        $Level++        

        $Objects | %{

            if(iex "`$_.$Attribute"){

                iex "`$_.$Attribute = `$_.$Attribute | %{`$FilterValue = `$_;`$Array | where{`$_.$Filter -eq `$FilterValue}}"

                iex "`$_.$Attribute = `$_.$Attribute | %{`$_ | %{ New-TreeObjectArray -Array `$Array -Objects `$_ -Attribute `$Attribute -Filter `$Filter -Level `$Level -MaxLoops `$MaxLoops}}"
             
                $_

            }else{

                $_
            }
        }
    }else{

        $null    }
}




