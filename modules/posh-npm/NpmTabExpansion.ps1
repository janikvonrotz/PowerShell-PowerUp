#**********************************************************************
# Copyright (c) Microsoft Open Technologies, Inc.  All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0.
#
# THIS CODE IS PROVIDED ON AN *AS IS* BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT
# LIMITATION ANY IMPLIED WARRANTIES OR CONDITIONS OF TITLE, FITNESS FOR
# A PARTICULAR PURPOSE, MERCHANTABLITY OR NON-INFRINGEMENT.
#
# See the Apache License, Version 2.0 for specific language governing
# permissions and limitations under the License.
#
#**********************************************************************
# search results cache lifetime in minutes
$script:searchCacheLife = 5

# cached list of npm packages from Repository
$script:npmRepositoryList = @()
$script:npmRepositoryListState = 'empty'
$script:npmJobGetRepoPkgState = 'idle'

# location for search results cache file
$appfold = [Environment]::GetFolderPath("ApplicationData")
$script:CacheDir = Join-Path -Path $appfold -ChildPath "npmtabexpansion"
if ((Test-Path $CacheDir -PathType container) -ne $True) {
    New-Item -Path $appfold -Name "npmtabexpansion" -Type directory | out-null
}
$script:CacheFile = Join-Path -Path $CacheDir -ChildPath "searchcache.txt"


# hash lookp of npm commands to get properties of command syntax
$script:npmCmdProps = @{
    'adduser' =         @{ 'typeparm' = 'none'; };
    'add-user' =        @{ 'alias' = 'adduser'; };
    'author' =          @{ 'alias' = 'owner'; };
    'bin' =             @{ 'typeparm' = 'globflag'; };
    'bugs' =            @{ 'typeparm' = 'rmtpkg'; };
    'c' =               @{ 'alias' = 'config'; };
    'cache' =           @{ 'typeparm' = 'subcmd'; };
    'cache add' =       @{ 'typeparm' = 'anypkg'; 'spos' = 3; };
    'cache ls' =        @{ 'typeparm' = 'localpkg'; 'spos' = 3; };
    'cache clean' =     @{ 'typeparm' = 'localpkg'; 'spos' = 3; };
    'config' =          @{ 'typeparm' = 'subcmd'; };
    'config delete' =   @{ 'typeparm' = 'config'; 'spos' = 3; };
    'config edit' =     @{ 'typeparm' = 'none'; 'spos' = 3; };
    'config get' =      @{ 'typeparm' = 'config'; 'spos' = 3; };
    'config list' =     @{ 'typeparm' = 'none'; 'spos' = 3; };
    'config set' =      @{ 'typeparm' = 'config'; 'spos' = 3; };
    'deprecate' =       @{ 'typeparm' = 'rmtpkg'; };
    'docs' =            @{ 'typeparm' = 'rmtpkg'; };
    'edit' =            @{ 'typeparm' = 'rmtpkg'; };
    'explore' =         @{ 'typeparm' = 'rmtpkg'; };
    'faq' =             @{ 'typeparm' = 'none'; };
    'find' =            @{ 'typeparm' = 'none'; };
    'get' =             @{ 'typeparm' = 'config'; };
    'help' =            @{ 'typeparm' = 'none'; };
    'help-search' =     @{ 'typeparm' = 'none'; };
    'home' =            @{ 'alias' = 'docs'; };
    'i' =               @{ 'alias' = 'install'; };
    'init' =            @{ 'typeparm' = 'localpkg'; };
    'info' =            @{ 'typeparm' = 'rmtpkg'; };
    'install' =         @{ 'typeparm' = 'anypkg_mult'; };
    'link' =            @{ 'typeparm' = 'none'; };
    'list' =            @{ 'typeparm' = 'none'; };
    'la' =              @{ 'alias' = 'list'; };
    'll' =              @{ 'alias' = 'list'; };
    'ln' =              @{ 'alias' = 'link'; };
    'login' =           @{ 'alias' = 'adduser'; };
    'ls' =              @{ 'alias' = 'list'; };
    'outdated' =        @{ 'typeparm' = 'localpkg_mult'; };
    'owner' =           @{ 'typeparm' = 'subcmd'; };
    'owner add' =       @{ 'typeparm' = 'user_rmtpkg'; 'spos' = 3; };
    'owner ls' =        @{ 'typeparm' = 'rmtpkg'; 'spos' = 3; };
    'owner rm' =        @{ 'typeparm' = 'user_rmtpkg'; 'spos' = 3; };
    'pack' =            @{ 'typeparm' = 'anypkg_mult'; };
    'prefix' =          @{ 'typeparm' = 'globflag'; };
    'prune' =           @{ 'typeparm' = 'none'; };
    'publish' =         @{ 'typeparm' = 'tar_fold'; };
    'r' =               @{ 'alias' = 'uninstall'; };
    'rb' =              @{ 'alias' = 'rebuild'; };
    'rebuild' =         @{ 'typeparm' = 'localpkg_mult'; };
    'remove' =          @{ 'alias' = 'uninstall'; };
    'restart' =         @{ 'typeparm' = 'script'; };
    'rm' =              @{ 'alias' = 'uninstall'; };
    'root' =            @{ 'typeparm' = 'globflag'; };
    'run-script' =      @{ 'typeparm' = 'script'; };
    's' =               @{ 'alias' = 'search'; };
    'se' =              @{ 'alias' = 'search'; };
    'search' =          @{ 'typeparm' = 'none'; };
    'set' =             @{ 'typeparm' = 'config'; };
    'show' =            @{ 'alias' = 'view'; };
    'shrinkwrap' =      @{ 'typeparm' = 'none'; };
    'star' =            @{ 'typeparm' = 'rmtpkg'; };
    'start' =           @{ 'typeparm' = 'script'; };
    'stop' =            @{ 'typeparm' = 'script'; };
    'submodule' =       @{ 'typeparm' = 'rmtpkg'; };
    'tag' =             @{ 'typeparm' = 'rmtpkg'; };
    'test' =            @{ 'typeparm' = 'script'; };
    'un' =              @{ 'alias' = 'uninstall'; };
    'uninstall' =       @{ 'typeparm' = 'localpkg_mult'; };
    'unlink' =          @{ 'alias' = 'uninstall'; };
    'unpublish' =       @{ 'typeparm' = 'rmtpkg'; };
    'unstar' =          @{ 'typeparm' = 'rmtpkg'; };
    'up' =              @{ 'alias' = 'update'; };
    'update' =          @{ 'typeparm' = 'localpkg'; };
    'version' =         @{ 'typeparm' = 'vermsg'; };
    'view' =            @{ 'typeparm' = 'rmtpkg'; };
    'whoami' =          @{ 'typeparm' = 'none'; };
    '--version' =       @{ 'typeparm' = 'none'; };
    '-l' =              @{ 'typeparm' = 'none'; };
}

$script:npmSubcommands = @{
    'author' = @('add', 'rm', 'ls');
    'c' = @('set', 'get', 'delete', 'list', 'edit');
    'cache' = @('add', 'ls', 'clean');
    'config' = @('set', 'get', 'delete', 'list', 'edit');
    'owner' = @('add', 'rm', 'ls');
}

# config values documented in npm
# can use as '--' parameters, or in config comand
$script:npmConfigParms = @( 'always-auth', 'bin-publish', 'bindist', 'browser', 'ca'
                            'cache', 'cache-max', 'cache-min', 'ca', 'depth', 'description',
                            'dev', 'editor', 'force', 'git', 'global', 'globalconfig',
                            'globalignorefile', 'group', 'https-proxy',
                            'user-agent', 'ignore', 'init.version', 'init.author.name',
                            'init.author.email','init.author.url', 'json', 'logfd',
                            'loglevel', 'logprefix', 'long', 'message', 'node-version',
                            'outfd','parseable', 'prefix', 'production', 'proprietary-attribs',
                            'proxy', 'rebuild-bundle', 'registry', 'rollback', 'save',
                            'save-dev', 'save-optional', 'searchopts', 'searchexclude',
                            'searchsort', 'shell', 'strict-ssl', 'tag', 'tmp', 'unicode',
                            'unsafe-perm', 'usage', 'user', 'username', 'userconfig',
                            'userignorefile', 'umask', 'viewer', 'yes')

if (Test-Path Function:\TabExpansion) {
    Rename-Item Function:\TabExpansion TabExpansionBackup
}

# return list of local installed package names
function script:npmLocalPackages() {
    # use npm directly
    $listOut = npm list --parseable --depth 1 2> $null
    $lines = $listOut -split '`n'
    $children = New-Object string[] ($lines.Count)
    $index = 0
    $lines | foreach {
        $pos = $_.ToString().IndexOf('node_modules')
        if ($pos -gt 0) {
            $pos += 'node_modules\'.Length
            $children[$index] = $_.ToString().SubString($pos)
            $index += 1
        }
    }
    return $children | sort
}

# return list of scripts
# for now just return local packages
function script:npmScripts() {
    return npmLocalPackages
}

# return list of tarballs (*.tgz | *.tar.gz) and folders (*\package.json)
function script:npmTarsFolders() {
    $cw = (Get-Location).Path
    $cwrep = $cw + '\'
    $t1 = Get-ChildItem -Include *.tgz -Recurse | foreach { $_.FullName }
    $t2 = Get-ChildItem -Include *.tar.gz -Recurse | foreach { $_.FullName }
    $f1 = Get-ChildItem -Include package.json -Recurse | foreach { $_.DirectoryName }

    $children = New-Object string[] ($t1.Count + $t2.Count + $f1.Count)
    $index = 0
    $t1 | foreach {
            if ($_) {
                $children[$index] = $_.ToString().Replace( $cwrep, '')
                $index += 1
            }
        }
    $t2 | foreach {
            if ($_) {
                $children[$index] = $_.ToString().Replace( $cwrep, '')
                $index += 1
            }
        }
    $f1 | foreach {
            if ($_ -and ($_ -ne $cw)) {
                $children[$index] = $_.ToString().Replace( $cwrep, '')
                $index += 1
            }
        }
    return $children
}

# return list of installable items - names, tarballs, folders
function script:npmAnyPackages() {
    $local = npmLocalPackages
    $tars = npmTarsFolders
    $children = New-Object string[] ($local.Count + $tars.Count)
    $index = 0
    $local | foreach {
            if ($_) {
                $children[$index] = $_
                $index += 1
            }
        }
    $tars | foreach {
            if ($_) {
                $children[$index] = $_
                $index += 1
            }
        }
    return $children
}

# parse search data to get package names
function script:npmParseSearch($searchOut) {
    $lines = $searchOut -split '`n'
    $children = New-Object string[] ($lines.Count)
    $index = -1
    $lines | foreach { 
        if ($index -ge 0) {
            $pos = $_.ToString().IndexOf(' ')
            $children[$index] = $_.ToString().Substring(0, $pos)
        }
        $index += 1
    }
    return $children | sort
}

# get search results if cache more than $script:searchCacheLife minutes old
function script:npmFetchSearchData() {
    $needsearch = 1

    # if job was run, test if complete
    if ($script:npmJobGetRepoPkgState -eq 'active') {
        $running = Get-Process $script:npmJobGetRepoPkg.Id -ErrorAction SilentlyContinue
        if ($running -and $running.Id -eq $script:npmJobGetRepoPkg.Id) {
            Wait-Process -Id $script:npmJobGetRepoPkg.Id -Timeout 1 -ErrorAction SilentlyContinue
            $running = Get-Process $script:npmJobGetRepoPkg.Id -ErrorAction SilentlyContinue
        }
        if (!($running)) {
            $script:npmJobGetRepoPkgState = 'idle'
            $script:npmRepositoryListState = 'old'
        }
        $needsearch = 0
    } else {
        # test if file exists and is recent
        if ((Test-Path $script:CacheFile -PathType leaf) -eq $True) {
            if ((Get-Item $script:CacheFile).LastWriteTime.AddMinutes($script:searchCacheLife) -gt (Get-Date)) {
                $needsearch = 0
            }
        }
    }

    if ($needsearch -eq 1) {
        $script:npmJobGetRepoPkg = start-process 'npm' -ArgumentList 'search --description false' -NoNewWindow -RedirectStandardOutput $CacheFile -RedirectStandardError 'nul' -PassThru
        $script:npmJobGetRepoPkgState = 'active'
    }
}

# return list of remote package names if available
# otherwise return empty list
function script:npmRemotePackages() {
    # if local cache data is empty or old, load it
    if ($script:npmRepositoryListState -ne 'full') {
        $searchout = Get-Content $script:CacheFile -ErrorAction SilentlyContinue
        if ($searchout) {
            $script:npmRepositoryList = script:npmParseSearch $searchout
            $script:npmRepositoryListState = 'full'
        }
    }

    # start getting repository data if necessary
    script:npmFetchSearchData

    if ($script:npmRepositoryListState -ne 'empty') {
        return $script:npmRepositoryList
    } else {
        return New-Object string[] 1
    }
}


# helper to determine position of parameter
function script:npmParmPosition($words, $start) {
    $ppos = 0
    while ($start -lt $words.length) {
        if ($words[$start] -notlike '-*') {
            $ppos += 1
        }
        $start += 1
    }

    return $ppos
}

# tab expansion entry point
function TabExpansion($line, $lastWord) {
    $words = $line.ToString().Split(' ')
    if ($words[0] -eq "npm") {
        if ($words.length -eq 1) {
            return $script:npmCmdProps.GetEnumerator() | 
                    Where-Object { $_.Value['alias'] -isnot 'String' } |
                    foreach { $_.Name } | sort
        }
        if ($words.length -eq 2) {
            # handle npm command value
            if ($lastWord -eq '') {
                $match = $script:npmCmdProps.GetEnumerator() |
                            Where-Object { $_.Value['alias'] -isnot 'String' -and ($_.Value['spos'] -isnot 'Int' -or $_.Value['spos'] -eq 2) -and $_.Name -like "$lastWord*" } |
                            foreach { $_.Name } | sort
            } else {
                $match = $script:npmCmdProps.GetEnumerator() |
                            Where-Object { ($_.Value['spos'] -isnot 'Int' -or $_.Value['spos'] -eq 2) -and $_.Name -like "$lastWord*" } |
                            foreach { $_.Name } | sort
            }
            if ($match) {
                return $match
            }
        }
        if ($words.length -gt 2) {
            # handle word after npm command
            $cmd = $words[1]
            $found = $script:npmCmdProps[$cmd]
            $match = $null
            $pstart = 2

            if ($found) {
                #handle alias
                if ($found['alias'] -is 'String') {
                    $cmd = $found['alias']
                    $found = $script:npmCmdProps[$cmd]
                }

                $typeparm = $found['typeparm']
                if ($found['spos'] -is 'Int') { 
                    $pstart = $found['spos']
                    Write-Host('found spos')
                }

                #handle two word commands
                if (($typeparm -eq 'subcmd') -and ($words.length -gt 3)) {
                    $newcmd = $cmd + " " + $words[2]
                    $subfound = $script:npmCmdProps[$newcmd]
                    if ($subfound) {
                        $found = $subfound
                        $typeparm = $found['typeparm']
                        if ($found['spos'] -is 'Int') { 
                            $pstart = $found['spos']
                        }
                    }
                }

                # check for last word starting with '-'
                if ($lastWord.StartsWith('-')) {
                    $match = $script:npmConfigParms | foreach {'--' +  $_.ToString() }
                    return $match | Where-Object { $_.ToString() -like "$lastWord*" }
                }

                switch ($typeparm) {
                    { $_ -eq 'subcmd' } {
                        $nxtcmd = $script:npmSubcommands[$cmd]
                        if ($nxtcmd) {
                            $match = $nxtcmd
                        }
                        break;
                    }

                    { $_ -eq 'config' } {
                        # if previous word has config name, don't do completion
                        $prevword = $words[-2]
                        if ($script:npmConfigParms -contains $prevword) {
                            $match = $null
                        } else {
                            $match = $script:npmConfigParms
                        }
                        break;
                    }

                    { $_ -eq 'none' } {
                        $match = $null
                        break;
                    }

                    { $_ -eq 'user_rmtpkg' } {
                        $parmpos = npmParmPosition $words $pstart
                        if ($parmpos -eq 1) {
                            # need user name - no tab completion
                            $match = $null
                        } else {
                            $match = npmRemotePackages
                        }
                        break;
                    }

                    { $_ -eq 'anypkg_mult' } {
                        $match = npmAnyPackages
                        break;
                    }

                    { $_ -eq 'anypkg' } {
                        $parmpos = npmParmPosition $words $pstart
                        if ($parmpos -eq 1) {
                            $match = npmAnyPackages
                        } else {
                            $match = $null
                        }
                        break;
                    }

                    { $_ -eq 'rmtpkg' } {
                        $match = npmRemotePackages
                        break;
                    }

                    { $_ -eq 'localpkg_mult' } {
                        $match = npmLocalPackages
                        break;
                    }

                    { $_ -eq 'localpkg' } {
                        $parmpos = npmParmPosition $words $pstart
                        if ($parmpos -eq 1) {
                            $match = npmLocalPackages
                        } else {
                            $match = $null
                        }
                        break;
                    }

                    { $_ -eq 'tar_fold' } {
                        $match = npmTarsFolders
                        break;
                    }

                    { $_ -eq 'script' } {
                        $match = npmScripts
                        break;
                    }

                    { $_ -eq 'vermsg' } {
                        $parmpos = npmParmPosition $words $pstart
                        if ($parmpos -eq 2) {
                            $match = @('--message')
                        } else {
                            $match = $null
                        }
                        break;
                    }

                    { $_ -eq 'globflag' } {
                        $match = @('-g')
                        break;
                    }
                }
            }
            if ($match) {
                return $match | Where-Object { $_.ToString() -like "$lastWord*" }
            }
        }
        return New-Object string[] 1
    } else {
         if (Test-Path Function:\TabExpansionBackup) { TabExpansionBackup $line $lastWord }
    }
}

