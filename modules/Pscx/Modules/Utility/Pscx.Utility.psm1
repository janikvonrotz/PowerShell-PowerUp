Set-StrictMode -Version 2.0

Set-Alias e     Edit-File              -Description "PSCX alias"
Set-Alias ehp   Edit-HostProfile       -Description "PSCX alias"
Set-Alias ep    Edit-Profile           -Description "PSCX alias"
Set-Alias gpar  Get-Parameter          -Description "PSCX alias"
Set-Alias gpv   Get-PropertyValue      -Description "PSCX alias"
Set-Alias su    Invoke-Elevated        -Description "PSCX alias"
Set-Alias igc   Invoke-GC              -Description "PSCX alias"
Set-Alias ??    Invoke-NullCoalescing  -Description "PSCX alias"
Set-Alias call  Invoke-Method          -Description "PSCX alias"
Set-Alias ?:    Invoke-Ternary         -Description "PSCX alias"
Set-Alias nho   New-HashObject         -Description "PSCX alias"
Set-Alias ql    QuoteList              -Description "PSCX alias"
Set-Alias qs    QuoteString            -Description "PSCX alias"
Set-Alias rver  Resolve-ErrorRecord    -Description "PSCX alias"
Set-Alias rvhr  Resolve-HResult        -Description "PSCX alias"
Set-Alias rvwer Resolve-WindowsError   -Description "PSCX alias"
Set-Alias sro   Set-ReadOnly           -Description "PSCX alias"
Set-Alias swr   Set-Writable           -Description "PSCX alias"

# Alias that should be set by PowerShell but only for 2.0 since 3.0 adds this alias.
if ($PSVersionTable.PSVersion.Major -lt 3)
{
    Set-Alias sls   Select-String -Description "PSCX alias"
}

# Initialize the PSCX RegexLib object.
& {
    $RegexLib = new-object psobject
    
    function AddRegex($name, $regex) {
      Add-Member -Input $RegexLib NoteProperty $name $regex
    }

    AddRegex CDQString           '(?<CDQString>"\\.|[^\\"]*")'
    AddRegex CSQString           "(?<CSQString>'\\.|[^'\\]*')"
    AddRegex CMultilineComment   '(?<CMultilineComment>/\*[^*]*\*+(?:[^/*][^*]*\*+)*/)'
    AddRegex CppEndOfLineComment '(?<CppEndOfLineComment>//[^\n]*)'
    AddRegex CComment            "(?:$($RegexLib.CDQString)|$($RegexLib.CSQString))|(?<CComment>$($RegexLib.CMultilineComment)|$($RegexLib.CppEndOfLineComment))"

    AddRegex PSComment          '(?<PSComment>#[^\n]*)'
    AddRegex PSNonCommentedLine '(?<PSNonCommentedLine>^(?>\s*)(?!#|$))'

    AddRegex EmailAddress       '(?<EmailAddress>[A-Z0-9._%-]+@(?:[A-Z0-9-]+\.)+[A-Z]{2,4})'
    AddRegex IPv4               '(?<IPv4>)(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))'
    AddRegex RepeatedWord       '\b(?<RepeatedWord>(\w+)\s+\1)\b'
    AddRegex HexDigit           '[0-9a-fA-F]'
    AddRegex HexNumber          '(?<HexNumber>(0[xX])?[0-9a-fA-F]+)'
    AddRegex DecimalNumber      '(?<DecimalNumber>[+-]?(?:\d+\.?\d*|\d*\.?\d+))'
    AddRegex ScientificNotation '(?<ScientificNotation>[+-]?(?<Significand>\d+\.?\d*|\d*\.?\d+)[\x20]?(?<Exponent>[eE][+\-]?\d+)?)'

    $Pscx:RegexLib = $RegexLib
}

<#
.SYNOPSIS
    Creates the registry entries required to create Windows Explorer context 
    menu "Open PowerShell Here" for both Directories and Drives
.NOTES
    Author: Keith Hill
#>
function Enable-OpenPowerShellHere
{
    function New-OpenPowerShellContextMenuEntry
    {
        param($Path)

        New-Item $Path -ItemType RegistryKey -Force
        New-ItemProperty $Path -Name '(Default)' -Value 'Open PowerShell Here'
        New-Item $Path\Command -ItemType RegistryKey
        New-ItemProperty $Path\Command -Name '(Default)' `
            -Value "`"$pshome\powershell.exe`" -NoExit -Command [Environment]::CurrentDirectory=(Set-Location -LiteralPath:'%L' -PassThru).ProviderPath"
    }

    New-OpenPowerShellContextMenuEntry 'HKCU:\Software\Classes\Directory\shell\PowerShell'
    New-OpenPowerShellContextMenuEntry 'HKCU:\Software\Classes\Drive\shell\PowerShell'
}

<#
.SYNOPSIS
    Gets the specified property's value from each input object.
.DESCRIPTION
    Gets the specified property's value from each input object.
    This filter is different from the Select-Object cmdlet in that it
    doesn't create a wrapper object (PSCustomObject) around the property.
    If you just want to get the property's value to assign it to another
    variable this filter will come in handy.  If you assigned the result
    of the Select-Object operation you wouldn't get the property's value.
    You would get an object that wraps that property and its value.
.PARAMETER InputObject
    Any object from which to get the specified property
.EXAMPLE
    C:\PS> $start = Get-History -Id 143 | Get-PropertyValue StartExecutionTime
    Gets the value of the StartExecutionTime property off of each HistoryInfo object.
.NOTES
    Aliases:  gpv
    Author:   Keith Hill  
#>
filter Get-PropertyValue([string] $propertyName) {
    $_.$propertyName
}

<#
.SYNOPSIS
    Create a PSObject from a dictionary such as a hashtable.
.DESCRIPTION
    Create a PSObject from a dictionary such as a hashtable.  The keys-value 
    pairs are turned into NoteProperties.
.PARAMETER InputObject
    Any object from which to get the specified property
.EXAMPLE
    C:\PS> $ht = @{fname='John';lname='Doe';age=42}; $ht | New-HashObject
    Creates a hashtable in $ht and then converts that into a PSObject.
.NOTES
    Aliases:  nho
#>
filter New-HashObject {
    if ($_ -isnot [Collections.IDictionary]) { 
        return $_ 
    }

    $result = new-object PSObject
    $hash = $_

    $hash.Keys | %{ $result | add-member NoteProperty "$_" $hash[$_] -force }

    $result
}

<#
.SYNOPSIS
    Similar to the C# ? : operator e.g. name = (value != null) ? String.Empty : value
.DESCRIPTION
    Similar to the C# ? : operator e.g. name = (value != null) ? String.Empty : value.
    The first script block is tested. If it evaluates to $true then the second scripblock
    is evaluated and its results are returned otherwise the third scriptblock is evaluated
    and its results are returned.
.PARAMETER Condition
    The condition that determines whether the TrueBlock scriptblock is used or the FalseBlock
    is used.
.PARAMETER TrueBlock
    This block gets evaluated and its contents are returned from the function if the Conditon
    scriptblock evaluates to $true.
.PARAMETER FalseBlock
    This block gets evaluated and its contents are returned from the function if the Conditon
    scriptblock evaluates to $false.
.EXAMPLE
    C:\PS> 1..10 | ?: {$_ -gt 5} {"Greater than 5";$_} {"Less than or equal to 5";$_}
    Each input number is evaluated to see if it is > 5.  If it is then "Greater than 5" is
    displayed otherwise "Less than or equal to 5" is displayed.
.NOTES
    Aliases:  ?:
    Author:   Karl Prosser
#>
filter Invoke-Ternary {
    param([scriptblock]$Condition  = $(throw "Parameter '-condition' (position 1) is required"), 
          [scriptblock]$TrueBlock  = $(throw "Parameter '-trueBlock' (position 2) is required"), 
          [scriptblock]$FalseBlock = $(throw "Parameter '-falseBlock' (position 3) is required"))

    $module = $ExecutionContext.SessionState.Module;
    
    if (& $module.NewBoundScriptBlock($Condition)) { 
        & $module.NewBoundScriptBlock($TrueBlock)
    } 
    else { 
        & $module.NewBoundScriptBlock($FalseBlock)
    }
}

<#
.SYNOPSIS
    Similar to the C# ?? operator e.g. name = value ?? String.Empty
.DESCRIPTION
    Similar to the C# ?? operator e.g. name = value ?? String.Empty;
    where value would be a Nullable&lt;T&gt; in C#.  Even though PowerShell
    doesn't support nullables yet we can approximate this behavior.
    In the example below, $LogDir will be assigned the value of $env:LogDir
    if it exists and it's not null, otherwise it get's assigned the
    result of the second script block (C:\Windows\System32\LogFiles).
    This behavior is also analogous to Korn shell assignments of this form:
    LogDir = ${$LogDir:-$WinDir/System32/LogFiles}
.PARAMETER PrimaryExpr
    The condition that determines whether the TrueBlock scriptblock is used or the FalseBlock
    is used.
.PARAMETER AlternateExpr
    This block gets evaluated and its contents are returned from the function if the Conditon
    scriptblock evaluates to $true.
.EXAMPLE
    C:\PS> $LogDir = ?? {$env:LogDir} {"$env:windir\System32\LogFiles"}
    $LogDir is set to the value of $env:LogDir unless it doesn't exist, in which case it 
    will then default to "$env:windir\System32\LogFiles".
.NOTES
    Aliases:  ??
    Author:   Keith Hill
#>
filter Invoke-NullCoalescing {
    param([scriptblock]$PrimaryExpr   = $(throw "Parameter '-primaryExpr' (position 1) required"), 
          [scriptblock]$AlternateExpr = $(throw "Parameter '-alternateExpr' (position 2) required"))
          
    $module = $ExecutionContext.SessionState.Module;

    if ($primaryExpr -ne $null) {
        $result = & $module.NewBoundScriptBlock($primaryExpr)
        if ($result -ne $null -and "$result" -ne '') {
            $result
        }
        else {
            & $module.NewBoundScriptBlock($alternateExpr)
        }
    }
    else {
        & $module.NewBoundScriptBlock($alternateExpr)
    }
}

<#
.FORWARDHELPTARGETNAME Get-Help
.FORWARDHELPCATEGORY Cmdlet
#>
function help
{
    [CmdletBinding(DefaultParameterSetName='AllUsersView')]
    param(
        [Parameter(Position=0, ValueFromPipelineByPropertyName=$true)]
        [System.String]
        ${Name},

        [System.String]
        ${Path},

        [ValidateSet('Alias','Cmdlet','Provider','General','FAQ','Glossary','HelpFile','ScriptCommand','Function','Filter','ExternalScript','All','DefaultHelp','Workflow')]
        [System.String[]]
        ${Category},

        [System.String[]]
        ${Component},

        [System.String[]]
        ${Functionality},

        [System.String[]]
        ${Role},

        [Parameter(ParameterSetName='DetailedView', Mandatory=$true)]
        [Switch]
        ${Detailed},

        [Parameter(ParameterSetName='AllUsersView')]
        [Switch]
        ${Full},

        [Parameter(ParameterSetName='Examples', Mandatory=$true)]
        [Switch]
        ${Examples},

        [Parameter(ParameterSetName='Parameters', Mandatory=$true)]
        [System.String]
        ${Parameter},

        [switch]
        ${Online}
    )

    $outputEncoding=[System.Console]::OutputEncoding

    if ($Pscx:Preferences["PageHelpUsingLess"]) 
    {
        Get-Help @PSBoundParameters | less
    }
    else
    {
        Get-Help @PSBoundParameters | more
    }
}

<#
.SYNOPSIS
    Less provides better paging of output from cmdlets.
.DESCRIPTION
    Less provides better paging of output from cmdlets.
    By default PowerShell uses more.com for paging which is a pretty minimal paging app that doesn't support advanced
    navigation features.  This function uses Less.exe ie Less394 as the replacement for more.com.  Less can navigate
    down as well as up and can be scrolled by page or by line and responds to the Home and End keys. Less also 
    supports searching the text by pressing the "/" key followed by the term to search for then the "Enter" key.  
    One of the primary keyboard shortcuts to know with less.exe is the key to exit. Pressing the "q" key will exit 
    less.exe.  For more help on less.exe press the "h" key.  If you prefer to use more.com set the PSCX preference 
    variable PageHelpUsingLess to $false e.g. $Pscx:Preferences['PageHelpUsingLess'] = $false
.PARAMETER LiteralPath
    Specifies the path to a file to view. Unlike Path, the value of LiteralPath is used exactly as it is typed. 
    No characters are interpreted as wildcards. If the path includes escape characters, enclose it in 
    single quotation marks. Single quotation marks tell Windows PowerShell not to interpret any characters 
    as escape sequences.
.PARAMETER Path
    The path to the file to view.  Wildcards are accepted.
.EXAMPLE
    C:\PS> man about_profiles -full
    This sends the help output of the about_profiles topic to the help function which pages the output.
    Man is an alias for the "help" function. PSCX overrides the help function to page help using either 
    the built-in PowerShell "more" function or the PSCX "less" function depending on the value of the 
    PageHelpUsingLess preference variable.
.EXAMPLE
    C:\PS> less *.txt
    Opens each text file in less.exe in succession.  Pressing ':n' moves to the next file.
.NOTES
    This function is just a passthru in all other hosts except for the PowerShell.exe console host.
.LINK
    http://en.wikipedia.org/wiki/Less_(Unix)
#>
function less
{
    param([string[]]$Path, [string[]]$LiteralPath)
    
    if ($host.Name -ne 'ConsoleHost')
    {
        # The rest of this function only works well in PowerShell.exe
        $input
        return
    }
    
    $OutputEncoding = [System.Console]::OutputEncoding
        
    $resolvedPaths = $null
    if ($LiteralPath)
    {
        $resolvedPaths = $LiteralPath
    }
    elseif ($Path)
    {
        $resolvedPaths = @()
        # In the non-literal case we may need to resolve a wildcarded path
        foreach ($apath in $Path) 
        {
            if (Test-Path $apath) 
            {
                $resolvedPaths += @(Resolve-Path $apath | Foreach { $_.Path })
            }
            else
            {
                $resolvedPaths += $apath
            }
        }
    }
        
    # Tricky to get this just right.  
    # Here are three test cases to verify all works as it should:
    # less *.txt      : Should bring up named txt file in less in succession, press q to go to next file
    # man gcm -full   : Should open help topic in less, press q to quit
    # man gcm -online : Should open help topic in web browser but not open less.exe		
    if ($resolvedPaths)
    {
        & "$Pscx:Home\Apps\less.exe" $resolvedPaths
    }
    elseif ($input.MoveNext())
    {
        $input.Reset()
        $input | & "$Pscx:Home\Apps\less.exe"
    }
}

<#
.SYNOPSIS
    Opens up the specified text file in a text editor.
.DESCRIPTION
    Opens up the specified text file in the text editor specified by 
    $Pscx:Preferences['TextEditor'] variable.  If not specified or the 
    specified editor isn't found then notepad is used.
.PARAMETER LiteralPath
    Specifies the path to a file to edit. Unlike Path, the value of LiteralPath is used exactly as it is typed. 
    No characters are interpreted as wildcards. If the path includes escape characters, enclose it in 
    single quotation marks. Single quotation marks tell Windows PowerShell not to interpret any characters 
    as escape sequences.
.PARAMETER Path
    The path to the file to edit.  Wildcards are accepted.
.EXAMPLE
    C:\PS> Edit-File foo.txt
    Opens foo.txt in a text editor.
.EXAMPLE
    C:\PS> Edit-File *.txt
    Opens all .txt files in a text editor.
.EXAMPLE
    C:\PS> Get-ChildItem . -r *.cs | Edit-File
    Opens all .cs files in the current dir and all subdirs in a text editor.
.NOTES
    Aliases:  e
    Author:   Keith Hill
#>
function Edit-File 
{
    [CmdletBinding(DefaultParameterSetName="Path", SupportsShouldProcess=$true)]
    param(
        [Parameter(Position=0, 
                   ParameterSetName="Path", 
                   ValueFromPipeline=$true, 
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Path,
        
        [Alias("PSPath")]
        [Parameter(Position=0, 
                   ParameterSetName="LiteralPath", 
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $LiteralPath
    )
    
    Begin {
        $editor = 'Notepad.exe'
        $preferredEditor = $Pscx:Preferences['TextEditor']
        if ($preferredEditor) {
            Get-Command $preferredEditor 2>&1 | out-null
            if ($?) {
                $editor = $Pscx:Preferences['TextEditor']
            }
            else {
                $pscmdlet.WriteDebug("Edit-File editor preference '$preferredEditor' not found, defaulting to $editor")	
            }
        }
        
        $pscmdlet.WriteDebug("Edit-File editor is $editor")
        function EditFileImpl($path) {
            & $editor $path
        }
    }
    
    Process 
    {
        if ($psCmdlet.ParameterSetName -eq "Path")
        {
            $resolvedPaths = $null
            if ($Path)
            {
                $resolvedPaths = @()
                # In the non-literal case we may need to resolve a wildcarded path
                foreach ($apath in $Path) 
                {
                    if (Test-Path $apath) 
                    {
                        $resolvedPaths += @(Resolve-Path $apath | Foreach { $_.Path })
                    }
                    else
                    {
                        $resolvedPaths += $apath
                    }
                }
            }
        }
        else 
        {
            $resolvedPaths = $LiteralPath
        }

        if ($resolvedPaths -eq $null)
        {
            $pscmdlet.WriteVerbose("Edit-File opening <no path specified>")
            if ($pscmdlet.ShouldProcess("<no path specified>"))
            {
                EditFileImpl
            }
        }
        else
        {               
            foreach ($rpath in $resolvedPaths) 
            {
                $PathIntrinsics = $ExecutionContext.SessionState.Path
            
                if ($PathIntrinsics.IsProviderQualified($rpath))
                {
                    $rpath = $PathIntrinsics.GetUnresolvedProviderPathFromPSPath($rpath)
                }
            
                $pscmdlet.WriteVerbose("Edit-File opening $rpath")
                if ($pscmdlet.ShouldProcess("$rpath"))
                {
                    EditFileImpl $rpath
                }
            }
        }
    }
}

<#
.SYNOPSIS
    Opens the current user's "all hosts" profile in a text editor.
.DESCRIPTION
    Opens the current user's "all hosts" profile ($Profile.CurrentUserAllHosts) in a text editor.
.EXAMPLE
    C:\PS> Edit-Profile
    Opens the current user's "all hosts" profile in a text editor.
.NOTES
    Aliases:  ep
    Author:   Keith Hill
#>
function Edit-Profile {
    Edit-File $Profile.CurrentUserAllHosts
}

<#
.SYNOPSIS
    Opens the current user's profile for the current host in a text editor.
.DESCRIPTION
    Opens the current user's profile for the current host ($Profile.CurrentUserCurrentHost) in a text editor.
.EXAMPLE
    C:\PS> Edit-HostProfile
    Opens the current user's profile for the current host in a text editor.
.NOTES
    Aliases:  ehp
    Author:   Keith Hill    
#>
function Edit-HostProfile {
    Edit-File $Profile.CurrentUserCurrentHost
}

<#
.SYNOPSIS
    Runs the specified command in an elevated context.
.DESCRIPTION
    Runs the specified command in an elevated context.  This is useful on Windows Vista
    and Windows 7 when you run with a standard user token but can elevate to Admin when needed.
.EXAMPLE
    C:\PS> Invoke-Elevated
    Opens a new PowerShell instance as admin.
.EXAMPLE
    C:\PS> Invoke-Elevated Notepad C:\windows\system32\drivers\etc\hosts
    Opens notepad elevated with the hosts file so that you can save changes to the file.
.EXAMPLE
    C:\PS> Invoke-Elevated {gci c:\windows\temp | export-clixml tempdir.xml; exit}
    Executes the scriptblock in an elevated PowerShell instance.
.EXAMPLE
    C:\PS> Invoke-Elevated {gci c:\windows\temp | export-clixml tempdir.xml; exit} | %{$_.WaitForExit(5000)} | %{Import-Clixml tempdir.xml}
    Executes the scriptblock in an elevated PowerShell instance, waits for that elevated process to execute, then
    retrieves the results.
.NOTES
    Aliases:  su
    Author:   Keith Hill
#>
function Invoke-Elevated 
{
    Write-Debug "`$MyInvocation:`n$($MyInvocation | Out-String)"
 
    $startProcessArgs = @{
        FilePath     = "PowerShell.exe"
        ArgumentList = "-NoExit", "-Command", "& {Set-Location '$pwd'}"
        Verb         = "runas"
        PassThru     = $true
        WorkingDir   = $pwd
    }
 
    $OFS = " "
    if ($args.Count -eq 0)      
    {
        Write-Debug "  Starting Powershell without no supplied args"
    }
    elseif ($args[0] -is [Scriptblock]) 
    {
        $script = $args[0]
        if ($script -match '(?si)\s*param\s*\(')
        {
            $startProcessArgs['ArgumentList'] = "-NoExit", "-Command", "& {$script}"
        }
        else
        {
            $startProcessArgs['ArgumentList'] = "-NoExit", "-Command", "& {Set-Location '$pwd'; $script}"
        }
        [string[]]$cmdArgs = @()
        if ($args.Count -gt 1)
        {
            $cmdArgs = $args[1..$($args.Length-1)]
            $startProcessArgs['ArgumentList'] += $cmdArgs
        }
        Write-Debug "  Starting PowerShell with scriptblock: {$script} and args: $cmdArgs"
    }
    else
    {
        $app = Get-Command $args[0] | Select -First 1 | Where {$_.CommandType -eq 'Application'}
        [string[]]$cmdArgs = @()
        if ($args.Count -gt 1)
        {
            $cmdArgs = $args[1..$($args.Length-1)]
        }
        if ($app) {
            $startProcessArgs['FilePath'] = $app.Path
            if ($cmdArgs.Count -eq 0)
            {
                $startProcessArgs.Remove('ArgumentList')
            }
            else
            {
                $startProcessArgs['ArgumentList'] = $cmdArgs
            }
            Write-Debug "  Starting app $app with args: $cmdArgs"
        }
        else {
            $poshCmd = $args[0]
            $startProcessArgs['ArgumentList'] = "-NoExit", "-Command", "& {Set-Location '$pwd'; $poshCmd $cmdArgs}"
            Write-Debug "  Starting PowerShell command $poshCmd with args: $cmdArgs"
        }
    }
 
    Write-Debug "  Invoking Start-Process with args: $($startProcessArgs | Format-List | Out-String)" 
    Microsoft.PowerShell.Management\Start-Process @startProcessArgs
}

<#
.SYNOPSIS
    Resolves the PowerShell error code to a textual description of the error.
.DESCRIPTION
    Use when reporting an error or ask a question about a exception you
    are seeing.  This function provides all the information we have 
    about the error message making it easier to diagnose what is 
    actually going on.
.PARAMETER ErrorRecord
    The ErrorRecord to resolve into a useful error report. The default value
    is $Error[0] - the last error that occurred.
.EXAMPLE
    C:\PS> Resolve-ErrorRecord
    Resolves the most recent PowerShell error code to a textual description of the error.
.NOTES
    Aliases:  rver
#>
function Resolve-ErrorRecord
{
    param(
        [Parameter(Position=0, ValueFromPipeline=$true)]
        [ValidateNotNull()]
        [System.Management.Automation.ErrorRecord[]]
        $ErrorRecord
    )
    
    Process
    {
        if (!$ErrorRecord) 
        {
            if ($global:Error.Count -eq 0)
            {
                Write-Host "The `$Error collection is empty."
                return
            }
            else
            { 
                $ErrorRecord = @($global:Error[0])
            }
        }
        foreach ($record in $ErrorRecord)
        {
            $txt =  @($record | Format-List * -Force | Out-String -Stream)
            $txt += @($record.InvocationInfo | Format-List * | Out-String -Stream)
            $Exception = $record.Exception
            for ($i = 0; $Exception; $i++, ($Exception = $Exception.InnerException))
            {   
               $txt += "Exception at nesting level $i ---------------------------------------------------"
               $txt += @($Exception | Format-List * -Force | Out-String -Stream)
            }

            $txt | Foreach {$prevBlank=$false} {
                       if ($_.Trim().Length -gt 0) 
                       {
                           $_
                           $prevBlank = $false
                       }
                       elseif (!$prevBlank) 
                       { 
                           $_
                           $prevBlank = $true
                       }
                   }
        }
    }
}

<#
.SYNOPSIS
    Resolves the hresult error code to a textual description of the error.
.DESCRIPTION
    Resolves the hresult error code to a textual description of the error.
.PARAMETER HResult
    The hresult error code to resolve.    
.EXAMPLE
    C:\PS> Resolve-HResult -2147023293
    Fatal error during installation. (Exception from HRESULT: 0x80070643)
.NOTES
    Aliases:  rvhr
#>
function Resolve-HResult
{
    param(
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [long[]]
        $HResult
    )
    
    Process 
    {
        foreach ($hr in $HResult)
        {
            $comEx = [System.Runtime.InteropServices.Marshal]::GetExceptionForHR($hr)
            if ($comEx)
            {
                $comEx.Message
            }
            else
            {
                Write-Error "$hr doesn't correspond to a known HResult"
            }
        }
    }
}

<#
.SYNOPSIS
    Resolves a Windows error number a textual description of the error.
.DESCRIPTION
    Resolves a Windows error number a textual description of the error. The Windows
    error number is typically retrieved via the Win32 API GetLastError() but it is
    typically displayed in messages to the end user.
.PARAMETER ErrorNumber
    The Windows error code number to resolve.    
.EXAMPLE
    C:\PS> Resolve-WindowsError 5
    Access is denied
.NOTES
    Aliases:  rvwer
#>
function Resolve-WindowsError
{
    param(
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [int[]]
        $ErrorNumber
    )
    
    Process
    {
        foreach ($num in $ErrorNumber)
        {
            $win32Ex = new-object ComponentModel.Win32Exception $num
            if ($win32Ex)
            {
                $win32Ex.Message
            }
            else
            {
                Write-Error "$num does not correspond to a known Windows error code"
            }
        }
    }
}

<#
.SYNOPSIS
    Convenience function for creating an array of strings without requiring quotes or commas.
.DESCRIPTION
    Convenience function for creating an array of strings without requiring quotes or commas.
.EXAMPLE
    C:\PS> QuoteList foo bar baz 
    This is the equivalent of 'foo', 'bar', 'baz'
.EXAMPLE
    C:\PS> ql foo bar baz 
    This is the equivalent of 'foo', 'bar', 'baz'. Same example as above but using the alias
    for QuoteList.
.NOTES
    Aliases:  ql
#>
function QuoteList { $args }

<#
.SYNOPSIS
    Creates a string from each parameter by concatenating each item using $OFS as the separator.
.DESCRIPTION
    Creates a string from each parameter by concatenating each item using $OFS as the separator.
.EXAMPLE
    C:\PS> QuoteString $a $b $c 
    This is the equivalent of "$a $b $c".
.EXAMPLE
    C:\PS> qs $a $b $c 
    This is the equivalent of "$a $b $c".  Same example as above but using the alias for QuoteString.
.NOTES
    Aliases:  qs
#>
function QuoteString { "$args" }

<#
.SYNOPSIS
    Invokes the .NET garbage collector to clean up garbage objects.
.DESCRIPTION
    Invokes the .NET garbage collector to clean up garbage objects. Invoking
    a garbage collection can be useful when .NET objects haven't been disposed 
    and is causing a file system handle to not be released.
.EXAMPLE
    C:\PS> Invoke-GC 
    Invokes a garbage collection to free up resources and memory.
#>
function Invoke-GC 
{
    [System.GC]::Collect()
}

<#
.SYNOPSIS
    Invokes the specified batch file and retains any environment variable changes it makes.
.DESCRIPTION
    Invoke the specified batch file (and parameters), but also propagate any  
    environment variable changes back to the PowerShell environment that  
    called it.
.PARAMETER Path
    Path to a .bat or .cmd file.
.PARAMETER Parameters
    Parameters to pass to the batch file.
.EXAMPLE
    C:\PS> Invoke-BatchFile "$env:ProgramFiles\Microsoft Visual Studio 9.0\VC\vcvarsall.bat"
    Invokes the vcvarsall.bat file.  All environment variable changes it makes will be
    propagated to the current PowerShell session.
.NOTES
    Author: Lee Holmes    
#>
function Invoke-BatchFile
{
    param([string]$Path, [string]$Parameters)  

    $tempFile = [IO.Path]::GetTempFileName()  

    ## Store the output of cmd.exe.  We also ask cmd.exe to output   
    ## the environment table after the batch file completes  
    cmd.exe /c " `"$Path`" $Parameters && set > `"$tempFile`" " 

    ## Go through the environment variables in the temp file.  
    ## For each of them, set the variable in our local environment.  
    Get-Content $tempFile | Foreach-Object {   
        if ($_ -match "^(.*?)=(.*)$")  
        { 
            Set-Content "env:\$($matches[1])" $matches[2]  
        } 
    }  

    Remove-Item $tempFile
}

<#
.SYNOPSIS
    Gets the possible alternate views for the specified object.
.DESCRIPTION
    Gets the possible alternate views for the specified object.
.PARAMETER TypeName
    Name of the type for which to retrieve the view definitions.
.PARAMETER Path
    Path to a specific format data PS1XML file.  Wildcards are accepted.  The default
    value is an empty array which will load the default .ps1xml files and exported
    format files from modules loaded in the current session
.PARAMETER IncludeSnapInFormatting
    Include the exported format information from v1 PSSnapins.
.EXAMPLE
    C:\PS> Get-ViewDefinition
    Retrieves all view definitions from the PowerShell format files.
.EXAMPLE
    C:\PS> Get-ViewDefinition System.Diagnostics.Process
    Retrieves all view definitions for the .NET type System.Diagnostics.Process.
.EXAMPLE
    C:\PS> Get-Process | Get-ViewDefinition | ft Name,Style -groupby SelectedBy
    Retrieves all view definitions for the .NET type System.Diagnostics.Process.
.EXAMPLE
    C:\PS> Get-ViewDefinition Pscx.Commands.Net.PingHostStatistics $Pscx:Home\Modules\Net\Pscx.Net.Format.ps1xml
    Retrieves all view definitions for the .NET type Pscx.Commands.Net.PingHostStatistics.
.NOTES
    Author: Joris van Lier and Keith Hill    
#>
function Get-ViewDefinition
{
    [CmdletBinding(DefaultParameterSetName="Name")]
    param(
        [Parameter(Position=0, ParameterSetName="Name")]
        [string]
        $TypeName,
        
        [Parameter(Position=0, ParameterSetName="Object", ValueFromPipeline=$true)]
        [psobject]
        $InputObject,
        
        [Parameter(Position=1)]
        [string[]]
        $Path = @(),
        
        [Parameter(Position=2)]
        [switch]
        $IncludeSnapInFormatting
    )

    Begin
    {
        # Setup arrays to hold Format XMLDocument objects and the paths to them
        $arrFormatFiles = @()
        $arrFormatFilePaths = @()
        # If a specific Path is specified, use that, otherwise load all defaults
        # which consist of the default formatting files, and exported format files
        # from modules
        if ($Path.count -eq 0)
        {
            # Populate the arrays with the standard ps1xml format file information
            gci $PsHome *.format.ps1xml | % `
            {
                if (Test-Path $_.fullname)
                {
                    $x = New-Object xml.XmlDocument
                    $x.Load($_.fullname)
                    $arrFormatFiles += $x
                    $arrFormatFilePaths += $_.fullname
                }
            }
            # Populate the arrays with format info from loaded modules
            Get-Module | Select -ExpandProperty exportedformatfiles | % `
            {
                if (Test-Path $_)
                {
                    $x = New-Object xml.XmlDocument
                    $x.load($_)
                    $arrFormatFiles += $x
                    $arrFormatFilePaths += $_
                }
            }
            # Processing snapin formatting seems to be slow, and snapins are more or less
            # deprecated with modules in v2, so exclude them by default
            if ($IncludeSnapInFormatting)
            {
                # Populate the arrays with format info from loaded snapins
                Get-PSSnapin | ? { $_.name -notmatch "Microsoft\." } | select applicationbase,formats | % `
                {
                    foreach ($f in $_.formats)
                    {
                        $x = New-Object xml.xmlDocument
                        if ( test-path $f )
                        {
                            $x.load($f)
                            $arrFormatFiles += $x
                            $arrFormatFilePaths += $f
                        }
                        else
                        {
                            $fpath = "{0}\{1}" -f $_.ApplicationBase,$f
                            if (Test-Path $fpath)
                            {
                                $x.load($fpath)
                                $arrFormatFiles += $x
                                $arrFormatFilePaths += $fpath
                            }
                        }
                    } 
                }
            }
        }
        else
        {
            foreach ($p in $path)
            {
                $x = New-Object xml.xmldocument
                if (Test-Path $p)
                {
                    $x.load($p)
                    $arrFormatFiles += $x
                    $arrFormatFilePaths += $p
                }
            }
        }
        $TypesSeen = @{}
        
        # The functions below reference's object members that may not exist
        Set-StrictMode -Version 1.0
        
        function IsViewSelectedByTypeName($view, $typeName, $formatFile)
        {
            if ($view.ViewSelectedBy.TypeName)
            {
                foreach ($t in @($view.ViewSelectedBy.TypeName))
                {
                    if ($typeName -eq $t) { return $true }
                }
                $false
            }
            elseif ($view.ViewSelectedBy.SelectionSetName)
            {
                $typeNameNodes = $formatFile.SelectNodes('/Configuration/SelectionSets/SelectionSet/Types')
                $typeNames = $typeNameNodes | foreach {$_.TypeName}
                $typeNames -contains $typeName
            }
            else
            {
                $false
            }
        }
        
        function GenerateViewDefinition($typeName, $view, $path)
        {
            $ViewDefinition = new-object psobject
            
            Add-Member NoteProperty Name $view.Name -Input $ViewDefinition
            Add-Member NoteProperty Path $path -Input $ViewDefinition
            Add-Member NoteProperty TypeName $typeName -Input $ViewDefinition
            $selectedBy = ""
            if ($view.ViewSelectedBy.TypeName)
            {
                $selectedBy = $view.ViewSelectedBy.TypeName
            }
            elseif ($view.ViewSelectedBy.SelectionSetName)
            {
                $selectedBy = $view.ViewSelectedBy.SelectionSetName
            }
            Add-Member NoteProperty SelectedBy $selectedBy -Input $ViewDefinition
            Add-Member NoteProperty GroupBy $view.GroupBy.PropertyName -Input $ViewDefinition
            if ($view.TableControl)
            {
                Add-Member NoteProperty Style 'Table' -Input $ViewDefinition
            }
            elseif ($view.ListControl)
            {
                Add-Member NoteProperty Style 'List' -Input $ViewDefinition
            }
            elseif ($view.WideControl)
            {
                Add-Member NoteProperty Style 'Wide' -Input $ViewDefinition
            }
            elseif ($view.CustomControl)
            {
                Add-Member NoteProperty Style 'Custom' -Input $ViewDefinition
            }
            else
            {
                Add-Member NoteProperty Style 'Unknown' -Input $ViewDefinition
            }
            
            $ViewDefinition
        }
        
        function GenerateViewDefinitions($typeName, $path)
        {
            for ($i = 0 ; $i -lt $arrFormatFiles.count ; $i++)
            {
                $formatFile = $arrFormatFiles[$i]
                $path		= $arrFormatFilePaths[$i]
                foreach ($view in $formatFile.Configuration.ViewDefinitions.View)
                {
                    if ($typeName)
                    {
                        if (IsViewSelectedByTypeName $view $typeName $formatFile)
                        {
                            GenerateViewDefinition $typeName $view $path
                        }
                    }
                    else
                    {
                    GenerateViewDefinition $typeName $view $path
                    }
                }
            }
        }
    }
    
    Process
    {
        if ($pscmdlet.ParameterSetName -eq 'Name')
        {
            GenerateViewDefinitions $TypeName #$Path
        }
        elseif (!$TypesSeen[$InputObject.PSObject.TypeNames[0]])
        {
            if ($InputObject -is [string])
            {
                GenerateViewDefinitions $InputObject
            }
            else
            {
                GenerateViewDefinitions $InputObject.PSObject.TypeNames[0]
            }
            $TypesSeen[$InputObject.PSObject.TypeNames[0]] = $true
        }
    }
}

<#
.SYNOPSIS
    Outputs text as spoken words.
.DESCRIPTION
    Outputs text as spoken words.
.PARAMETER InputObject
    One or more objects to speak.
.PARAMETER Wait
    Wait for the machine to read each item (NOT asynchronous).
.PARAMETER Purge
    Purge all other speech requests before making this call.
.PARAMETER ReadFiles
    Read the contents of the text files indicated.
.PARAMETER ReadXml
    Treat input as speech XML markup.
.PARAMETER NotXml
    Do NOT parse as XML (if text starts with "<" but is not XML).
.EXAMPLE
    C:\PS> Out-Speech "Hello World"
    Speaks "hello world".
.EXAMPLE
    C:\PS> Get-Content quotes.txt | Get-Random | Out-Speech -wait
    Speaks a random quote from a file.
.EXAMPLE
    C:\PS> Out-Speech -readfiles "Hitchhiker's Guide To The Galaxy.txt"
    Speaks the entire contents of a file.
.NOTES
    Author: Joel "Jaykul" Bennett    
#>
function Out-Speech
{
    param(
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
        [psobject[]]
        $InputObject, 
        
        [switch]
        $Wait, 
        
        [switch]
        $Purge, 
        
        [switch]
        $ReadFiles, 
        
        [switch]
        $ReadXml, 
        
        [switch]
        $NotXml
    )
     
    begin 
    {  
        # To override this default, use the other flag values given below.
        $SPF_DEFAULT = 0          # Specifies that the default settings should be used.  
        ## The defaults are:
        #~ * Speak the given text string synchronously
        #~ * Not purge pending speak requests
        #~ * Parse the text as XML only if the first character is a left-angle-bracket (<)
        #~ * Not persist global XML state changes across speak calls
        #~ * Not expand punctuation characters into words.
        $SPF_ASYNC = 1            # Specifies that the Speak call should be asynchronous.
        $SPF_PURGEBEFORESPEAK = 2 # Purges all pending speak requests prior to this speak call.
        $SPF_IS_FILENAME = 4      # The string passed is a file name, and the file text should be spoken.
        $SPF_IS_XML = 8           # The input text will be parsed for XML markup. 
        $SPF_IS_NOT_XML= 16       # The input text will not be parsed for XML markup.
      
        $SPF = $SPF_DEFAULT
        if (!$wait)    { $SPF += $SPF_ASYNC }
        if ($purge)    { $SPF += $SPF_PURGEBEFORESPEAK }
        if ($readfiles){ $SPF += $SPF_IS_FILENAME }
        if ($readxml)  { $SPF += $SPF_IS_XML }
        if ($notxml)   { $SPF += $SPF_IS_NOT_XML }

        $Voice = New-Object -Com SAPI.SpVoice
    }
     
    process 
    {
        foreach ($obj in $InputObject)
        {
            $str = $obj | Out-String
            $exit = $Voice.Speak($str, $SPF)
        }
    }
}

<#
.SYNOPSIS
    Stops a process on a remote machine.
.DESCRIPTION
    Stops a process on a remote machine.
    This command uses WMI to terminate the remote process.
.PARAMETER ComputerName
    The name of the remote computer that the process is executing on.
    Type the NetBIOS name, an IP address, or a fully qualified domain name of the remote computer.
.PARAMETER Name
    The process name of the remote process to terminate.
.PARAMETER Id
    The process id of the remote process to terminate.
.PARAMETER Credential    
    Specifies a user account that has permission to perform this action. The default is the current user. 
    Type a user name, such as "User01", "Domain01\User01", or User@Contoso.com. Or, enter a PSCredential 
    object, such as an object that is returned by the Get-Credential cmdlet. When you type a user name, 
    you will be prompted for a password.    
.EXAMPLE
    C:\PS> Stop-RemoteProcess server1 notepad.exe
    Stops all processes named notepad.exe on the remote computer server1.
.EXAMPLE
    C:\PS> Stop-RemoteProcess server1 3478
    Stops the process with process id 3478 on the remote computer server1.
.EXAMPLE
    C:\PS> 3478,4005 | Stop-RemoteProcess server1
    Stops the processes with process ids 3478 and 4005 on the remote computer server1.
.NOTES
    Author: Jachym Kouba and Keith Hill
#>
function Stop-RemoteProcess
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Position=0, Mandatory=$true)]
        [string]
        $ComputerName, 
        
        [Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true, ParameterSetName="Name")]
        [string[]]
        $Name,
        
        [Parameter(Position=1, Mandatory=$true, ValueFromPipeline=$true, 
                   ValueFromPipelineByPropertyName=$true, ParameterSetName="Id")]
        [int[]]
        $Id,
        
        [System.Management.Automation.PSCredential]
        $Credential
    ) 
    
    Process
    {
        $params = @{
            Class = 'Win32_Process'
            ComputerName = $ComputerName
        }
        
        if ($Credential)
        {
            $params.Credential = $Credential
        }
        
        if ($pscmdlet.ParameterSetName -eq 'Name')
        {
            foreach ($item in $Name)
            {
                if (!$pscmdlet.ShouldProcess("process $item on computer $ComputerName"))
                {
                    continue
                }
                $params.Filter = "Name LIKE '%$item%'"
                Get-WmiObject @params | Foreach {
                    if ($_.Terminate().ReturnValue -ne 0) {
                        Write-Error "Failed to stop process $item on $ComputerName."
                    }
                }
            }
        }
        else
        {
            foreach ($item in $Id)
            {
                if (!$pscmdlet.ShouldProcess("process id $item on computer $ComputerName"))
                {
                    continue
                }
                $params.Filter = "ProcessId = $item"
                Get-WmiObject @params | Foreach {
                    if ($_.Terminate().ReturnValue -ne 0) {
                        Write-Error "Failed to stop process id $item on $ComputerName."
                    }
                }
            }
        }
    }
}

<#
.SYNOPSIS
    Generate CSS header for HTML "screen shot" of the host buffer.
.DESCRIPTION
    Generate CSS header for HTML "screen shot" of the host buffer.
.EXAMPLE
    C:\PS> $css = Get-ScreenCss
    Gets the color info of the host's screen into CSS form.
.NOTES
    Author: Jachym Kouba
#>
function Get-ScreenCss
{
    param()
    
    Process
    {
        '<style>'
        [Enum]::GetValues([ConsoleColor]) | Foreach {
            "  .F$_ { color: $_; }"
            "  .B$_ { background-color: $_; }"
        }
        '</style>'
    }
}

<#
.SYNOPSIS
    Functions to generate HTML "screen shot" of the host buffer.
.DESCRIPTION
    Functions to generate HTML "screen shot" of the host buffer.
.PARAMETER Count
    The number of lines of the host buffer to create a screen shot from.
.EXAMPLE
    C:\PS> Stop-RemoteProcess server1 notepad.exe
    Stops all processes named notepad.exe on the remote computer server1.
.EXAMPLE
    C:\PS> Get-ScreenHtml > screen.html
    Generates an HTML representation of the host's screen buffer and saves it to file.
.EXAMPLE
    C:\PS> Get-ScreenHtml 25 > screen.html
    Generates an HTML representation of the first 25 lines of the host's screen buffer and saves it to file.
.NOTES
    Author: Jachym Kouba
#>
function Get-ScreenHtml
{
    param($Count = $Host.UI.RawUI.WindowSize.Height)

    Begin
    {
        # Required by HttpUtility
        Add-Type -Assembly System.Web

        $raw = $Host.UI.RawUI
        $buffsz = $raw.BufferSize
        
        function BuildHtml($out, $buff) 
        {
            function OpenElement($out, $fore, $back) 
            {
                & { 
                    $out.Append('<span class="F').Append($fore)
                    $out.Append(' B').Append($back).Append('">')
                } | out-null
            }
            
            function CloseElement($out) {
                $out.Append('</span>') | out-null
            }

            $height = $buff.GetUpperBound(0)
            $width  = $buff.GetUpperBound(1)
            
            $prev = $null
            $whitespaceCount = 0
            
            $out.Append("<pre class=`"B$($Host.UI.RawUI.BackgroundColor)`">") | out-null
            
            for ($y = 0; $y -lt $height; $y++) 
            {
                for ($x = 0; $x -lt $width; $x++) 
                {
                    $current = $buff[$y, $x] 
                
                    if ($current.Character -eq ' ') 
                    {
                        $whitespaceCount++
                        write-debug "whitespaceCount: $whitespaceCount"
                    }
                    else 
                    {
                        if ($whitespaceCount) 
                        {
                            write-debug "appended $whitespaceCount spaces, whitespaceCount: 0"					
                            $out.Append((new-object string ' ', $whitespaceCount)) | out-null
                            $whitespaceCount = 0
                        }
            
                        if ((-not $prev) -or 
                            ($prev.ForegroundColor -ne $current.ForegroundColor) -or
                            ($prev.BackgroundColor -ne $current.BackgroundColor)) 
                        {
                            if ($prev) { CloseElement $out }
                            
                            OpenElement $out $current.ForegroundColor $current.BackgroundColor
                        } 
                                
                        $char = [System.Web.HttpUtility]::HtmlEncode($current.Character)
                        $out.Append($char) | out-null
                        $prev =	$current	
                    }
                }
                
                $out.Append("`n") | out-null
                $whitespaceCount = 0
            }
            
            if($prev) { CloseElement $out }
            
            $out.Append('</pre>') | out-null
        }
    }
    
    Process
    {
        $cursor = $raw.CursorPosition

        $rect = new-object Management.Automation.Host.Rectangle 0, ($cursor.Y - $Count), $buffsz.Width, $cursor.Y
        $buff = $raw.GetBufferContents($rect)

        $out = new-object Text.StringBuilder
        BuildHtml $out $buff
        $out.ToString()
    }
}

<#
.SYNOPSIS
    Function to call a single method on an incoming stream of piped objects.
.DESCRIPTION
    Function to call a single method on an incoming stream of piped objects. Methods can be static or instance and
    arguments may be passed as an array or individually. 
.PARAMETER InputObject
    The object to execute the named method on. Accepts pipeline input.
.PARAMETER MemberName
    The member to execute on the passed object.
.PARAMETER Arguments
    The arguments to pass to the named method, if any.
.PARAMETER Static
    The member name will be treated as a static method call on the incoming object.
.EXAMPLE
    C:\PS> 1..3 | invoke-method gettype
    Calls GetType() on each incoming integer.
.EXAMPLE
    C:\PS> dir *.txt | invoke-method moveto "c:\temp\"
    Calls the MoveTo() method on all txt files in the current directory passing in "C:\Temp" as the destFileName.
.NOTES
    Aliases:  call
#>
function Invoke-Method {
    [CmdletBinding()]
    param(        
        [parameter(valuefrompipeline=$true, mandatory=$true)]
        [allownull()]
        [allowemptystring()]
        $InputObject,
        
        [parameter(position=0, mandatory=$true)]
        [validatenotnullorempty()]
        [string]$MethodName,
        
        [parameter(valuefromremainingarguments=$true)]
        [allowemptycollection()]
        [object[]]$Arguments,

        [parameter()]
        [switch]$Static
    )
    
    Process 
    {
        if ($InputObject) 
        {
            if ($InputObject | Get-Member $methodname -static:$static) 
            {
                $flags = "ignorecase,public,invokemethod"
                
                if ($Static) {
                    $flags += ",static"
                } 
                else {
                    $flags += ",instance"
                }
                
                if ($InputObject -is [type]) {
                    $target = $InputObject
                } 
                else {
                    $target = $InputObject.gettype()
                }
                
                try {
                    $target.invokemember($methodname, $flags, $null, $InputObject, $arguments)
                } 
                catch {
                    if ($_.exception.innerexception -is [missingmethodexception]) {
                        write-warning "Method argument count (or type) mismatch."
                    }
                }
            } 
            else {
                write-warning "Method $methodname not found."
            }
        }
    }
}

<#
.SYNOPSIS
    Sets a file's read only status to false making it writable.
.DESCRIPTION
    Sets a file's read only status to false making it writable.
.PARAMETER LiteralPath
    Specifies the path to a file make writable. Unlike Path, the value of LiteralPath is used exactly as it is typed. 
    No characters are interpreted as wildcards. If the path includes escape characters, enclose it in 
    single quotation marks. Single quotation marks tell Windows PowerShell not to interpret any characters 
    as escape sequences.
.PARAMETER Path
    The path to the file make writable.  Wildcards are accepted.
.PARAMETER PassThru
    Passes the pipeline input object down the pipeline. By default, this cmdlet does not generate any output.
.EXAMPLE
    C:\PS> Set-Writable foo.txt
    Makes foo.txt writable.
.EXAMPLE
    C:\PS> Set-Writable [a-h]*.txt -passthru
    Makes any .txt file start with the letters a thru h writable and passes the filenames down the pipeline.
.EXAMPLE
    C:\PS> Get-ChildItem bar[0-9].txt | Set-Writable
    Set-Writable can accept pipeline input corresponding to files and make them all writable.
#>
function Set-Writable
{
    [CmdletBinding(DefaultParameterSetName="Path", SupportsShouldProcess=$true)]
    param(
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true, ParameterSetName="Path")]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Path,
        
        [Alias("PSPath")]
        [Parameter(Position=0, Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="LiteralPath")]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $LiteralPath,
        
        [switch]
        $PassThru
    )
    
    Process 
    {
        $resolvedPaths = @()
        if ($psCmdlet.ParameterSetName -eq "Path")
        {
            # In the non-literal case we may need to resolve a wildcarded path
            foreach ($apath in $Path) 
            {
                if (Test-Path $apath) 
                {
                    $resolvedPaths += @(Resolve-Path $apath | Foreach { $_.Path })
                }
                else
                {
                    Write-Error "File $apath does not exist"
                }
            }
        }
        else
        {
            $resolvedPaths += $LiteralPath
        }
        
        foreach ($rpath in $resolvedPaths) 
        {
            $PathIntrinsics = $ExecutionContext.SessionState.Path
            if ($PathIntrinsics.IsProviderQualified($rpath))
            {
                $rpath = $PathIntrinsics.GetUnresolvedProviderPathFromPSPath($rpath)
            }
            
            if (!(Test-Path $rpath -PathType Leaf))
            {
                Write-Error "$rpath is not a file."
                continue
            }
            
            $fileInfo = New-Object System.IO.FileInfo $rpath				
            if ($pscmdlet.ShouldProcess("$fileInfo"))
            {
                $fileInfo.IsReadOnly = $false
            }
            
            if ($PassThru)
            {
                $fileInfo
            }			
        }				
    }
}

<#
.SYNOPSIS
    Sets a file's read only status to true making it read only.
.DESCRIPTION
    Sets a file's read only status to true making it read only.
.PARAMETER LiteralPath
    Specifies the path to a file make read only. Unlike Path, the value of LiteralPath is used exactly as it is typed. 
    No characters are interpreted as wildcards. If the path includes escape characters, enclose it in 
    single quotation marks. Single quotation marks tell Windows PowerShell not to interpret any characters 
    as escape sequences.
.PARAMETER Path
    The path to the file make read only.  Wildcards are accepted.
.PARAMETER PassThru
    Passes the pipeline input object down the pipeline. By default, this cmdlet does not generate any output.
.EXAMPLE
    C:\PS> Set-ReadOnly foo.txt
    Makes foo.txt read only.
.EXAMPLE
    C:\PS> Set-ReadOnly [a-h]*.txt -passthru
    Makes any .txt file start with the letters a thru h read only and passes the filenames down the pipeline.
.EXAMPLE
    C:\PS> Get-ChildItem bar[0-9].txt | Set-ReadOnly
    Set-ReadOnly can accept pipeline input corresponding to files and make them all read only.
#>
function Set-ReadOnly
{
    [CmdletBinding(DefaultParameterSetName="Path", SupportsShouldProcess=$true)]
    param(
        [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true, ParameterSetName="Path")]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Path,
        
        [Alias("PSPath")]
        [Parameter(Position=0, Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="LiteralPath")]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $LiteralPath,
        
        [switch]
        $PassThru
    )
        
    Process 
    {
        $resolvedPaths = @()
        if ($psCmdlet.ParameterSetName -eq "Path")
        {
            # In the non-literal case we may need to resolve a wildcarded path
            foreach ($apath in $Path) 
            {
                if (Test-Path $apath) 
                {
                    $resolvedPaths += @(Resolve-Path $apath | Foreach { $_.Path })
                }
                else
                {
                    Write-Error "File $apath does not exist"
                }
            }
        }
        else
        {
            $resolvedPaths += $LiteralPath
        }
        
        foreach ($rpath in $resolvedPaths) 
        {
            $PathIntrinsics = $ExecutionContext.SessionState.Path
            if ($PathIntrinsics.IsProviderQualified($rpath))
            {
                $rpath = $PathIntrinsics.GetUnresolvedProviderPathFromPSPath($rpath)
            }
            
            if (!(Test-Path $rpath -PathType Leaf))
            {
                Write-Error "$rpath is not a file."
                continue
            }
            
            $fileInfo = New-Object System.IO.FileInfo $rpath				
            if ($pscmdlet.ShouldProcess("$fileInfo"))
            {
                $fileInfo.IsReadOnly = $true
            }
            
            if ($PassThru)
            {
                $fileInfo
            }						
        }				
    }
}

<#
.SYNOPSIS
    Shows the specified path as a tree.
.DESCRIPTION
    Shows the specified path as a tree.  This works for any type of PowerShell provider and can be used to explore providers used for configuration like the WSMan provider.
.PARAMETER Path
    The path to the root of the tree that will be shown.
.PARAMETER Depth
    Specifies how many levels of the specified path are recursed and shown.
.PARAMETER IndentSize
    The size of the indent per level. The default is 3.  Minimum value is 1.
.PARAMETER Force
    Allows the command to show items that cannot otherwise not be accessed by the user, such as hidden or system files.
    Implementation varies from provider to provider. For more information, see about_Providers. Even using the Force 
    parameter, the command cannot override security restrictions.
.PARAMETER ShowLeaf
    Shows the leaf items in each container.
.PARAMETER ShowProperty
    Shows the properties on containers and items (if -ShowLeaf is specified).
.PARAMETER ExcludeProperty
    List of properties to exclude from output.  Only used when -ShowProperty is specified.
.PARAMETER Width
    Specifies the number of characters in each line of output. Any additional characters are truncated, not wrapped.
    If you omit this parameter, the width is determined by the characteristics of the host. The default for the 
    PowerShell.exe host is 80 (characters).
.PARAMETER UseAsciiLineArt
    Displays line art using only ASCII characters.
.EXAMPLE
    C:\PS> Show-Tree C:\Users -Depth 2
    Shows the directory tree structure, recursing down two levels.
.EXAMPLE
    C:\PS> Show-Tree HKLM:\SOFTWARE\Microsoft\.NETFramework -Depth 2 -ShowProperty -ExcludeProperty 'SubKeyCount','ValueCount'
    Shows the hierarchy of registry keys and values (-ShowProperty), recursing down two levels.  Excludes the standard regkey extended properties SubKeyCount and ValueCount from the output.
.EXAMPLE
    C:\PS> Show-Tree WSMan: -ShowLeaf
    Shows all the container and leaf items in the WSMan: drive.
#>
function Show-Tree
{
    [CmdletBinding(DefaultParameterSetName="Path")]
    param(
        [Parameter(Position=0, 
                   ParameterSetName="Path", 
                   ValueFromPipeline=$true, 
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Path,
        
        [Alias("PSPath")]
        [Parameter(Position=0, 
                   ParameterSetName="LiteralPath", 
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $LiteralPath,
            
        [Parameter(Position = 1)]
        [ValidateRange(0, 2147483647)]
        [int]
        $Depth = [int]::MaxValue, 
        
        [Parameter()]
        [switch]
        $Force, 
        
        [Parameter()]
        [ValidateRange(1, 100)]
        [int]
        $IndentSize = 3, 
        
        [Parameter()]
        [switch]
        $ShowLeaf, 
        
        [Parameter()]
        [switch]
        $ShowProperty,
        
        [Parameter()]
        [string[]]
        $ExcludeProperty,
        
        [Parameter()]
        [ValidateRange(0, 2147483647)]
        [int]
        $Width,
        
        [Parameter()]
        [switch]
        $UseAsciiLineArt
    )

    Begin
    {
        Set-StrictMode -Version 2.0
        
        # Set default path if not specified
        if (!$Path -and $psCmdlet.ParameterSetName -eq "Path")
        {
            $Path = Get-Location
        }
        
        if ($Width -eq 0)
        {
            $Width = $host.UI.RawUI.BufferSize.Width
        }
        
        $asciiChars = @{
            EndCap        = '\'
            Junction      = '|'
            HorizontalBar = '-'
            VerticalBar   = '|'
        }
        
        $cp437Chars = @{
            EndCap        = '└'
            Junction      = '├'
            HorizontalBar = '─'
            VerticalBar   = '│'
        }
        
        if (($Host.CurrentCulture.TextInfo.OEMCodePage -eq 437) -and !$UseAsciiLineArt)
        {
            $lineChars = $cp437Chars
        }
        else
        {
            $lineChars = $asciiChars
        }
               
        function GetIndentString([bool[]]$IsLast)
        {
            $str = ''
            for ($i=0; $i -lt $IsLast.Count - 1; $i++)
            {
                $str += if ($IsLast[$i]) {' '} else {$lineChars.VerticalBar}
                $str += " " * ($IndentSize - 1)
            }
            $str += if ($IsLast[-1]) {$lineChars.EndCap} else {$lineChars.Junction}
            $str += $lineChars.HorizontalBar * ($IndentSize - 1)
            $str
        }
        
        function CompactString([string]$String, [int]$MaxWidth = $Width)
        {
            $updatedString = $String
            if ($String.Length -ge $MaxWidth)
            {
                $ellipsis = '...'
                $updatedString = $String.Substring(0, $MaxWidth - $ellipsis.Length - 1) + $ellipsis
            }
            $updatedString    
        }

        function ShowItemText([string]$ItemPath, [string]$ItemName, [bool[]]$IsLast)
        {
            if ($IsLast.Count -eq 0) 
            {
                $itemText = Resolve-Path -LiteralPath $ItemPath | Foreach {$_.Path}
                CompactString $itemText
            }
            else
            {
                $itemText = $ItemName                
                if (!$itemText)
                {
                    if ($ExecutionContext.SessionState.Path.IsProviderQualified($ItemPath))
                    {
                        $itemText = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($ItemPath)
                    }
                }
                CompactString "$(GetIndentString $IsLast)$itemText"
            }
        }
        
        function ShowPropertyText ([string]$Name, [string]$Value, [bool[]]$IsLast)
        {
            $cookedValue = @($Value -split "`n")[0].Trim()
            CompactString "$(GetIndentString $IsLast)Property: $Name = $cookedValue"
        }
        
        function ShowItem([string]$ItemPath, [string]$ItemName='', [bool[]]$IsLast=@())
        {        
            $isContainer = Test-Path -LiteralPath $ItemPath -Type Container
            if (!($isContainer -or $ShowLeaf))
            {
                Write-Warning "Path is not a container, use the ShowLeaf parameter to show leaf items."
                return
            }
            
            # Show current item
            ShowItemText $ItemPath $ItemName $IsLast
            
            # If the item is a container, grab its children.  This let's us know if there
            # will be items after the last property at the same level.
            $childItems = @()
            if ($isContainer -and ($IsLast.Count -lt $Depth))
            {
                $childItems = @(Get-ChildItem -LiteralPath $ItemPath -Force:$Force -ErrorAction $ErrorActionPreference | 
                                Where {$ShowLeaf -or $_.PSIsContainer} | Select PSPath, PSChildName)            
            }

            # Track parent's "last item" status to determine which level gets a vertical bar
            $IsLast += @($false)
            
            # If requested, show item properties
            if ($ShowProperty)
            {
                $excludedProviderNoteProps =  'PSIsContainer','PSChildName','PSDrive','PSParentPath','PSPath','PSProvider','Name','Property'
                $excludedProviderNoteProps += $ExcludeProperty
                $props = @()
                $itemProp = Get-ItemProperty -LiteralPath $ItemPath -ErrorAction SilentlyContinue
                if ($itemProp)
                {
                    $props = @($itemProp.psobject.properties | Sort Name | Where {$excludedProviderNoteProps -notcontains $_.Name})
                }
                else
                {
                    $item = $null
                    # Have to use try/catch here because Get-Item cert: error caught be caught with -EA
                    try { $item = Get-Item -LiteralPath $ItemPath -ErrorAction SilentlyContinue } catch {}
                    if ($item)
                    {
                        $props = @($item.psobject.properties | Sort Name | Where {$excludedProviderNoteProps -notcontains $_.Name})
                    }
                }
                
                for ($i=0; $i -lt $props.Count; $i++)
                {
                    $IsLast[-1] = ($i -eq $props.count -1) -and ($childItems.Count -eq 0)

                    $prop = $props[$i]
                    ShowPropertyText $prop.Name $prop.Value $IsLast
                }
            }
            
            # Recurse through child items
            for ($i=0; $i -lt $childItems.Count; $i++)
            {
                $childItemPath = $childItems[$i].PSPath
                $childItemName = $childItems[$i].PSChildName
                $IsLast[-1] = ($i -eq $childItems.Count - 1)
                if ($ShowLeaf -or (Test-Path -LiteralPath $childItemPath -Type Container))
                {
                    ShowItem $childItemPath $childItemName $IsLast
                }
            }
        }
    }

    Process
    {
        if ($psCmdlet.ParameterSetName -eq "Path")
        {
            # In the -Path (non-literal) resolve path in case it is wildcarded.
            $resolvedPaths = @($Path | Resolve-Path | Foreach {"$_"})
        }
        else 
        {
            # Must be -LiteralPath
            $resolvedPaths = @($LiteralPath)
        }
 
        foreach ($rpath in $resolvedPaths) 
        {
            Write-Verbose "Processing $rpath"            
            ShowItem $rpath
        }  
    }        
}

<#
.Synopsis 
  Enumerates the parameters of one or more commands.
.Description
  Lists all the parameters of a command, by ParameterSet, including their aliases, type, etc.
  By default, formats the output to tables grouped by command and parameter set.
.Parameter CommandName
  The name of the command to get parameters for.
.Parameter ParameterName
  Wilcard-enabled filter for parameter names.
.Parameter ModuleName
  The name of the module which contains the command (this is for scoping)
.Parameter Force
  Forces including the CommonParameters in the output.
.Example
  Get-Command Select-Xml | Get-Parameter
.Example
  Get-Parameter Select-Xml
.Notes
  With many thanks to Hal Rottenberg, Oisin Grehan and Shay Levy
  Version 0.80 - April 2008 - By Hal Rottenberg http://poshcode.org/186
  Version 0.81 - May 2008 - By Hal Rottenberg http://poshcode.org/255
  Version 0.90 - June 2008 - By Hal Rottenberg http://poshcode.org/445
  Version 0.91 - June 2008 - By Oisin Grehan http://poshcode.org/446
  Version 0.92 - April 2008 - By Hal Rottenberg http://poshcode.org/549
               - ADDED resolving aliases and avoided empty output
  Version 0.93 - Sept 24, 2009 - By Hal Rottenberg http://poshcode.org/1344
  Version 1.0  - Jan 19, 2010 - By Joel Bennett http://poshcode.org/1592
               - Merged Oisin and Hal's code with my own implementation
               - ADDED calculation of dynamic paramters
  Version 2.0  - July 22, 2010 - By Joel Bennett http://poshcode.org/get/2005
               - CHANGED uses FormatData so the output is objects
               - ADDED calculation of shortest names to the aliases (idea from Shay Levy http://poshcode.org/1982,
                 but with a correct implementation)
  Version 2.1  - July 22, 2010 - By Joel Bennett http://poshcode.org/2007
               - FIXED Help for SCRIPT file (script help must be separated from #Requires by an emtpy line)
               - Fleshed out and added dates to this version history after Bergle's criticism ;)
  Version 2.2  - July 29, 2010 - By Joel Bennett http://poshcode.org/2030
               - FIXED a major bug which caused Get-Parameters to delete all the parameters from the CommandInfo
  Version 2.3  - July 29, 2010 - By Joel Bennett 
               - ADDED a ToString ScriptMethod which allows queries like:
                 $parameters = Get-Parameter Get-Process; $parameters -match "Name"
  Version 2.4  - July 29, 2010 - By Joel Bennett http://poshcode.org/2032
               - CHANGED "Name" to CommandName
               - ADDED ParameterName parameter to allow filtering parameters
               - FIXED bug in 2.3 and 2.2 with dynamic parameters
  Version 2.5  - December 13, 2010 - By Jason Archer http://poshcode.org/2404
               - CHANGED format temp file to have static name, prevents bloat of random temporary files
  Version 2.6  - July 23, 2011 - By Jason Archer (This Version)
               - FIXED miscalculation of shortest unique name (aliases count as unique names),
                 this caused some parameter names to be thrown out (like "Object")
               - CHANGED code style cleanup
#>
function Get-Parameter {
    [CmdletBinding()]
    param(
        [Parameter(Position = 1, Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("Name")]
        [string[]]$CommandName,

        [Parameter(Position = 2, ValueFromPipelineByPropertyName = $true)]
        [string[]]$ParameterName = "*",

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        $ModuleName,

        [switch]
        $Force
    )

    begin {
        $PropertySet = @( "Name",
            @{n="Position";e={if($_.Position -lt 0){"Named"}else{$_.Position}}},
            "Aliases", 
            @{n="Short";e={$_.Name}},
            @{n="Type";e={$_.ParameterType.Name}}, 
            @{n="ParameterSet";e={$paramset}},
            @{n="Command";e={$command}},
            @{n="Mandatory";e={$_.IsMandatory}},
            @{n="Provider";e={$_.DynamicProvider}},
            @{n="ValueFromPipeline";e={$_.ValueFromPipeline}},
            @{n="ValueFromPipelineByPropertyName";e={$_.ValueFromPipelineByPropertyName}}
        )
        function Join-Object {
            Param(
                [Parameter(Position=0)]
                $First
                ,
                [Parameter(ValueFromPipeline=$true,Position=1)]
                $Second
            )
            begin {
                [string[]] $p1 = $First | Get-Member -MemberType Properties | Select-Object -ExpandProperty Name
            }
            process {
                $Output = $First | Select-Object $p1
                foreach ($p in $Second | Get-Member -MemberType Properties | Where-Object {$p1 -notcontains $_.Name} | Select-Object -ExpandProperty Name) {
                    Add-Member -InputObject $Output -MemberType NoteProperty -Name $p -Value $Second."$p"
                }
                $Output
            }
        }
    }

    process {
        foreach ($cmd in $CommandName) {
        if ($ModuleName) {$cmd = "$ModuleName\$cmd"}
        $commands = @(Get-Command $cmd)

        foreach ($command in $commands) {
            # resolve aliases (an alias can point to another alias)
            while ($command.CommandType -eq "Alias") {
                $command = @(Get-Command ($command.definition))[0]
            }
            if (-not $command) {continue}

            $Parameters = @{}

            foreach ($provider in Get-PSProvider) {
                $drive = "{0}\{1}::\" -f $provider.ModuleName, $provider.Name
                Write-Verbose ("Get-Command $command -Args $drive | Select -Expand Parameters")

                [Array]$MoreParameters = (Get-Command $command -Args $drive).Parameters.Values
                [Array]$Dynamic = $MoreParameters | Where-Object {$_.IsDynamic}
                foreach ($p in $MoreParameters | Where-Object{!$Parameters.ContainsKey($_.Name)}) {$Parameters.($p.Name) = $p}
                    # Write-Verbose "Drive: $Drive | Parameters: $($Parameters.Count)"
                    if ($dynamic) {
                        foreach ($d in $dynamic) {
                            if (Get-Member -InputObject $Parameters.($d.Name) -Name DynamicProvider) {
                                Write-Debug ("ADD:" + $d.Name + " " + $provider.Name)
                                $Parameters.($d.Name).DynamicProvider += $provider.Name
                            } else {
                                Write-Debug ("CREATE:" + $d.Name + " " + $provider.Name)
                                $Parameters.($d.Name) = $Parameters.($d.Name) | Add-Member NoteProperty DynamicProvider @($provider.Name) -Passthru
                            }
                        }
                    }
                }

                ## Calculate the shortest distinct parameter name -- do this BEFORE removing the common parameters or else.
                $Aliases = $Parameters.Values | Select-Object -ExpandProperty Aliases  ## Get defined aliases
                foreach ($p in $($Parameters.Keys)) {
                    $shortest = "^"
                    foreach ($char in [char[]]$p) {             
                        $shortest += $char
                        $Matches = (($Parameters.Keys + $Aliases) -match $Shortest).Count
                        Write-Debug "$($shortest.SubString(1)) $Matches"
                        if ($Matches -eq 1) {
                            $Parameters.$p = $Parameters.$p | Add-Member NoteProperty Aliases ($Parameters.$p.Aliases + @($shortest.SubString(1).ToLower($PSUICulture))) -Force -Passthru
                            break
                        }
                    }
                }

                Write-Verbose "Parameters: $($Parameters.Count)`n $($Parameters | ft | out-string)"

                foreach ($paramset in @($command.ParameterSets | Select-Object -ExpandProperty "Name")) {
                    foreach ($parameter in $Parameters.Keys | Sort-Object) {
                        Write-Verbose "Parameter: $Parameter"
                        if (!$Force -and ($Parameters.$Parameter.Aliases -match '^(vb|db|ea|wa|ev|wv|ov|ob|wi|cf)$')) {continue}
                        if ($Parameters.$Parameter.ParameterSets.ContainsKey($paramset) -or $Parameters.$Parameter.ParameterSets.ContainsKey("__AllParameterSets")) {
                            if ($Parameters.$Parameter.ParameterSets.ContainsKey($paramset)) {
                                $output = Join-Object $Parameters.$Parameter $Parameters.$Parameter.ParameterSets.$paramSet 
                            } else {
                                $output = Join-Object $Parameters.$Parameter $Parameters.$Parameter.ParameterSets.__AllParameterSets
                            }

                            Write-Output $Output | Select-Object $PropertySet | ForEach-Object {
                                    $null = $_.PSTypeNames.Insert(0,"System.Management.Automation.ParameterMetadata")
                                    $null = $_.PSTypeNames.Insert(0,"System.Management.Automation.ParameterMetadataEx")
                                    Write-Verbose "$(($_.PSTypeNames.GetEnumerator()) -join ", ")"
                                    $_
                                } |
                                Add-Member ScriptMethod ToString { $this.Name } -Force -Passthru |
                                Where-Object {$(foreach($pn in $ParameterName) {$_ -like $Pn}) -contains $true}
                        }
                    }
                }
            }
        }
    }
}

<#
.SYNOPSIS
    Imports environment variables for the specified version of Visual Studio.
.DESCRIPTION
    Imports environment variables for the specified version of Visual Studio. 
    This function requires the PowerShell Community Extensions. To find out 
    the most recent set of Visual Studio environment variables imported use 
    the cmdlet Get-EnvironmentBlock.  If you want to revert back to a previous 
    Visul Studio environment variable configuration use the cmdlet 
    Pop-EnvironmentBlock.
.PARAMETER VisualStudioVersion
    The version of Visual Studio to import environment variables for. Valid 
    values are 2008, 2010 and 2012.
.PARAMETER Architecure
    Selects the desired architecture to configure the environment for. 
	Defaults to x86 if running in 32-bit PowerShell, otherwise defaults to 
	amd64.
.EXAMPLE
    C:\PS> Import-VisualStudioVars 2010

    Sets up the environment variables to use the VS 2010 compilers. Defaults 
	to x86 if running in 32-bit PowerShell, otherwise defaults to amd64.
.EXAMPLE
    C:\PS> Import-VisualStudioVars 2012 arm

    Sets up the environment variables for the VS 2012 arm compiler.
#>
function Import-VisualStudioVars
{
    param
    (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet('2008', '2010', '2012')]
        [string]
        $VisualStudioVersion,

	[Parameter(Position = 1)]
	[string]
        $Architecture = $(if ($Pscx:Is64BitProcess) {'amd64'} else {'x86'})
    )
 
    End
    {
        switch ($VisualStudioVersion)
        {
            '2008' {
                Push-EnvironmentBlock -Description "Before importing VS 2008 $Architecture environment variables"
                Invoke-BatchFile "${env:VS90COMNTOOLS}..\..\VC\vcvarsall.bat" $Architecture
            }
      
            '2010' {
                Push-EnvironmentBlock -Description "Before importing VS 2010 $Architecture environment variables"
                Invoke-BatchFile "${env:VS100COMNTOOLS}..\..\VC\vcvarsall.bat" $Architecture
            }
 
            '2012' {
                Push-EnvironmentBlock -Description "Before importing VS 2012 $Architecture environment variables"
                Invoke-BatchFile "${env:VS110COMNTOOLS}..\..\VC\vcvarsall.bat" $Architecture
            }
 
            default {
                Write-Error "Import-VisualStudioVars doesn't recognize VisualStudioVersion: $VisualStudioVersion"
            }
        }
    }
}

<#
.SYNOPSIS
    Starts a new Windows PowerShell process.
.DESCRIPTION
    Starts a new Windows PowerShell process using PowerShell's parameter
    parsing engine to parse the parameters for the PowerShell executable.
    This command exposes a few of the Start-Process commands it uses such as
    -Wait, -Credential and -WorkingDirectory.  Note: If -NoNewWindow is
    specified, PowerShell is invoked using the call operator (&) instead of
    with the Start-Process cmdlet.
.PARAMETER PSConsoleFile
    Loads the specified Windows PowerShell console file. To create a console
    file, use Export-Console in Windows PowerShell.
.PARAMETER Version
    Starts the specified version of Windows PowerShell. 
    Enter a version number with the parameter, such as "-version 2.0".
.PARAMETER ExecutionPolicy
    Sets the default execution policy for the current session and saves it 
    in the $env:PSExecutionPolicyPreference environment variable. 
    This parameter does not change the Windows PowerShell execution policy 
    that is set in the registry.
.PARAMETER Architecture
    Starts PowerShell with the desired architecture: x86, x64 or same 
	architecture as the launching PowerShell process.
	Valid values are: x86, x64 and Same.
.PARAMETER NoLogo
    Hides the copyright banner at startup.
.PARAMETER NoExit
    Does not exit after running startup commands.
.PARAMETER Sta
    Starts the shell using a single-threaded apartment.
    Single-threaded apartment (STA) is the default.
.PARAMETER Mta
    Start the shell using a multithreaded apartment.
.PARAMETER NoProfile
    Does not load the Windows PowerShell profile.
.PARAMETER NonInteractive
    Does not present an interactive prompt to the user.
.PARAMETER InputFormat
    Describes the format of data sent to Windows PowerShell. Valid values are
    "Text" (text strings) or "XML" (serialized CLIXML format).
.PARAMETER OutputFormat
    Determines how output from Windows PowerShell is formatted. Valid values
    are "Text" (text strings) or "XML" (serialized CLIXML format).
.PARAMETER Credential
    Specifies a user account that has permission to perform this action. Type 
    a user-name, such as "User01" or "Domain01\User01", or enter a 
    PSCredential object, such as one from the Get-Credential cmdlet. By 
    default, the cmdlet uses the credentials of the current user. 
    This parameter can't be used in conjunction with the NoNewWindow parameter.
.PARAMETER WindowStyle
    Sets the window style to Normal, Minimized, Maximized or Hidden.
    This parameter can't be used in conjunction with the NoNewWindow parameter.
.PARAMETER NoNewWindow
    Uses the call invocation operator to start PowerShell instead of Start-Process.
    This parameter can't be used in conjunction with the WindowStyle parameter.
.PARAMETER WorkingDirectory
    Specifies the location of the executable file or document that runs in the 
    process.  The default is the current directory.
.PARAMETER Wait
    Waits for the specified process to complete before accepting more input. 
    This parameter suppresses the command prompt or retains the window until 
    the process completes.
.PARAMETER EncodedCommand
    Accepts a base-64-encoded string version of a command. Use this parameter 
    to submit commands to Windows PowerShell that require complex quotation 
    marks or curly braces.
.PARAMETER File
    Runs the specified script in the local scope ("dot-sourced"), so that the 
    functions and variables that the script creates are available in the 
    current session. Enter the script file path and any parameters. 
    File must be the last parameter in the command, because all characters 
    typed after the File parameter name are interpreted 
    as the script file path followed by the script parameters.
.PARAMETER Command
    Executes the specified commands (and any parameters) as though they were
    typed at the Windows PowerShell command prompt, and then exits, unless 
    NoExit is specified. The value of Command can be "-", a string. or a
    script block.

    If the value of Command is "-", the command text is read from standard
    input.

    If the value of Command is a script block, the script block must be enclosed
    in braces ({}). You can specify a script block only when running PowerShell.exe
    in Windows PowerShell. The results of the script block are returned to the
    parent shell as deserialized XML objects, not live objects.

    If the value of Command is a string, Command must be the last parameter
    in the command , because any characters typed after the command are 
    interpreted as the command arguments.

    To write a string that runs a Windows PowerShell command, use the format:
	"& {<command>}"
    where the quotation marks indicate a string and the invoke operator (&)
    causes the command to be executed.
.EXAMPLE
    C:\PS> Start-PowerShell -NoProfile -NoExit -File $pwd\foo.ps1
.EXAMPLE
    C:\PS> Start-PowerShell -NoProfile -NoLogo -Credential (Get-Credential)
.EXAMPLE
    C:\PS> Start-PowerShell -NoProfile -NoNewWindow -File $pwd\foo.ps1
.EXAMPLE
    C:\PS> Start-PowerShell -Architecture x64 -NoNewWindow -Command {[IntPtr]::Size}
.EXAMPLE
    C:\PS> Start-PowerShell -Architecture x86 -NoNewWindow -Command {[IntPtr]::Size}
#>
function Start-PowerShell
{
    param(
        [Parameter(Position = 0)]
        [ValidateSet(2.0,3.0)]
        [double]
        $Version,

        [Parameter()]
        [ValidateSet('x86','x64','Same')]
        [string]
        $Architecture,

        [Parameter()]
        $Command,

        [Parameter()]
        [PSCredential]
        $Credential,

        [Parameter()]
        [string]
        $WorkingDirectory,

        [Parameter()]
        [switch]
        $Wait,

        [Parameter()]
        [string]
        $PSConsoleFile,

        [Parameter()]
        [Microsoft.PowerShell.ExecutionPolicy]
        $ExecutionPolicy,

        [Parameter()]
        [Alias('PSPath')]
        [string]
        $File,

        [Parameter()]
        [string]
        $EncodedCommand,

        [Parameter()]
        [ValidateSet('text','xml')]
        [string]
        $InputFormat,

        [Parameter()]
        [ValidateSet('text','xml')]
        [string]
        $OutputFormat,

        [Parameter()]
        [ValidateSet('Normal','Minimized','Maximized','Hidden')]
        [string]
        $WindowStyle,

        [Parameter()]
        [Alias('NE')]
        [switch]
        $NoExit,

        [Parameter()]
        [Alias('NL')]
        [switch]
        $NoLogo,

        [Parameter()]
        [Alias('NP')]
        [switch]
        $NoProfile,

        [Parameter()]
        [switch]
        $NoNewWindow,

        [Parameter()]
        [Alias('NI')]
        [switch]
        $NonInteractive,

        [Parameter()]
        [switch]
        $Mta,

        [Parameter()]
        [switch]
        $Sta,

        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]
        $Arguments
    )

    Begin
    {
        Set-StrictMode -Version Latest

        $PowerShellPath = "$env:windir\System32\WindowsPowerShell\v1.0\powershell.exe"
        if ($pscx:IsWow64Process -and ($Architecture -eq 'x64'))
        {
            $PowerShellPath = "$env:windir\SysNative\WindowsPowerShell\v1.0\powershell.exe"
        }
        if ($pscx:Is64BitProcess -and ($Architecture -eq 'x86'))
        {
            $PowerShellPath = "$env:windir\SysWow64\WindowsPowerShell\v1.0\powershell.exe"
        }
    }

    End 
    {
        [string[]]$arglist = @()

        if ($PSConsoleFile)
        {
            $arglist += '-PSConsoleFile',$PSConsoleFile
        }

        if ($Version)
        {
            $arglist += '-Version',$Version
        }

        if ($NoLogo)
        {
            $arglist += '-NoLogo'
        }

        if ($NoExit)
        {
            $arglist += '-NoExit'
        }

        if ($Sta)
        {
            $arglist += '-Sta'
        }

        if ($Mta)
        {
            $arglist += '-Mta'
        }

        if ($NoProfile) 
        {
            $arglist += '-NoProfile'
        }

        if ($NonInteractive) 
        {
            $arglist += '-NonInteractive'
        }

        if ($WindowStyle)
        {
            $arglist += '-WindowStyle',$WindowStyle
        }

        if ($ExecutionPolicy)
        {
            $arglist += '-ExecutionPolicy',$ExecutionPolicy
        }

        if ($File)
        {
            $arglist += '-File',$File
            if ($Arguments -and $Arguments.Count -gt 0)
            {
                $arglist += $Arguments
            }
        }
        elseif ($Command)
        {
            $arglist += '-Command',$Command
            if ($Arguments -and $Arguments.Count -gt 0)
            {
                $arglist += $Arguments
            }
        }
        elseif ($EncodedCommand)
        {
            $arglist += '-EncodedCommand',$EncodedCommand
        }

        $pscmdlet.WriteDebug("Start-PowerShell: Path to PowerShell - $PowerShellPath")

        if ($NoNewWindow)
        {
            $OFS = "`n"
            $pscmdlet.WriteDebug("Start-PowerShell: Call operator arguments -`n$($arglist | Out-String)")

            # Doing a start-process -NoNewWindow on PowerShell results in a shell that doesn't want to exit on V3 at least.
            & $PowerShellPath $arglist
        }
        else
        {
            $startProcessArgs = @{}

            if ($arglist.Count -gt 0)
            {
                $startProcessArgs['ArgumentList'] = $arglist
            }

            if ($Credential)
            {
                $startProcessArgs['Credential'] = $Credential
            }

            if ($WorkingDirectory)
            {
                $startProcessArgs['WorkingDirectory'] = $WorkingDirectory
            }

            if ($Wait)
            {
                $startProcessArgs['Wait'] = $true
            }

            $pscmdlet.WriteDebug("Start-PowerShell: Arguments to Start-Process - $($startProcessArgs | Out-String)")

            Microsoft.PowerShell.Management\Start-Process $PowerShellPath @startProcessArgs
        }
    }
}

<#
.SYNOPSIS
    Gets the execution time for the specified Id of a command in the current
    session history.
.DESCRIPTION
    Gets the execution time for the specified Id of a command in the current
    session history.
.PARAMETER Id
    Specifies the Id of the command to retrieve the execution time.  If no
    Id is specified, then the execution time for all commands in the history
    is displayed.
.EXAMPLE
    C:\PS> Get-ExecutionTime 1

    Gets the execution time for id #1 in the session history.
.EXAMPLE
    C:\PS> Get-ExecutionTime

    Gets the execution time for all commands in the session history.
#>
function Get-ExecutionTime
{
    param(
        [Parameter(Position = 0)]
        [ValidateScript({$_ -ge 1})]
        [Int64]
        $Id
    )

    End
    {
        Get-History @PSBoundParameters | Foreach {
            $obj = new-object psobject -Property @{
                    Id = $_.Id
                    ExecutionTime = ($_.EndExecutionTime - $_.StartExecutionTime)
                    HistoryInfo = $_
            }
            $obj.PSTypeNames.Insert(0, 'Pscx.Commands.Modules.Utility.ExecutionTimeInfo')
            $obj
        }
    }
}

Export-ModuleMember -Alias * -Function *

# SIG # Begin signature block
# MIIfVQYJKoZIhvcNAQcCoIIfRjCCH0ICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQULJceY2W6POSeQC0DaXWgDrkx
# EcagghqHMIIGbzCCBVegAwIBAgIQA4uW8HDZ4h5VpUJnkuHIOjANBgkqhkiG9w0B
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
# MBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSI
# rpldNTUJiT7VnfXoYeFvqJlHJTANBgkqhkiG9w0BAQEFAASCAQCyClgW3rzSH5bz
# 3S3Y/SaNdI5BTszib9UdaYaBWUOdvCrbNENGag5kr8uNF+XrzYU3ZqXwxoVL2EmL
# 3OWZWUNsmMwVzJWT+szrmSbScjPvRsnVXBavA8w8y8eQzHdt6K20B080dYXdVHQM
# UyAyt1AR1wR2jEATx/8YEAGQIXOiVvXlbzS82NfKhUWCr+kTn04aznCwUrhd1d6A
# y1tvim2f4iRWjFEgYxyuWstertKu2CVCEemYU8TP6WD6KEQgLxzxr4fDa0axG0QK
# iowJ7vjaQJpaXNmxeN/eAUDBvANgxSnZHJaMLdkxK3jkiZsVog/4K/zFZotJNk2O
# 2J7HGWTWoYICDzCCAgsGCSqGSIb3DQEJBjGCAfwwggH4AgEBMHYwYjELMAkGA1UE
# BhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2lj
# ZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgQXNzdXJlZCBJRCBDQS0xAhADi5bw
# cNniHlWlQmeS4cg6MAkGBSsOAwIaBQCgXTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcN
# AQcBMBwGCSqGSIb3DQEJBTEPFw0xMjEyMTcwMTUxMTRaMCMGCSqGSIb3DQEJBDEW
# BBQ9xZlseWfM6wGK5sylmg3BWiXG8TANBgkqhkiG9w0BAQEFAASCAQCUnt4HWA3Z
# Nf40N0J475KRi/1zH0LVjdMqF08WmBZ8m2zJRqNC1xXNOshnxmpG8y8RXk8+483N
# fC/ZTwfjxfmu0FXCj7sMf5fdu3bvrHDN1r9esoRnIJuxxTHpn3xhbiYspJ+fa5OF
# IH7MW1BmX+mZ0zuVB/Rz4sKOBPHJBKdKXqbu4n17VSI0LixTUy+zeGV7My/6ICng
# kYxaWFI0HeI0tEhOYZ5b0MN1PreJ080SDAEs2WuY7ZXC8C/OOqVW0TIYsh9GPuZn
# JZLLR+vOcWCr6QA/WTJhkxP8RgtoLdk3RC0mZFJHxDDG1HjlWAbJm0+Rgx6VcSKo
# EVSsaO85QSkk
# SIG # End signature block
