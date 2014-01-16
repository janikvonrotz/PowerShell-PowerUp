<#
$Metadata = @{
	Title = "Get-TreeObjectArrayAsList"
	Filename = "Get-TreeObjectArrayAsList.ps1"
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

function Get-TreeObjectArrayAsList{

<#
.SYNOPSIS
    Displays the levels for a tree object array.

.DESCRIPTION
	Displays the levels for a tree object array by iterating their child objects.

.PARAMETER Array
	Array holding the objects.

.PARAMETER Attribute
	Name of the objects attribute to expand.

.PARAMETER Level
	Counter of levels, default is 0.
		
.EXAMPLE
	PS C:\> Get-TreeObjectArrayAsList -Array $ArrayOfObjects -Attribute $AttributeToExpand -Level 1
#>

    param(    
        $Array,        
        $Attribute,        
        $Level = 0
    )

    # copy objects, pointers are not allowed
    $Array = $Array.psobject.Copy()

    $Array | %{
        
        # check the child attribute containing the same type of objects
        $Childs = iex "`$_.$Attribute"
    
        # output this item
        $_ | select *, @{L="Level";E={$Level}}
    
        # output the child items of this object
        if($Childs){
        
            # loop trough the same function
            $Childs | %{Get-TreeObjectArrayAsList -Array $_ -Attribute $Attribute -Level ($Level + 1)}
        }
    }
}