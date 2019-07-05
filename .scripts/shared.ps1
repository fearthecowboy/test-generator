
## functions
$autorest_new           = "C:\work\2019\autorest_new\autorest\src\autorest\dist\app"
$autorest_new_version   = "C:\work\2019\autorest_new\autorest\src\autorest-core"

$autorest_orig          = "C:\work\2019\autorest_orig\autorest\src\autorest\dist\app"
$autorest_orig_version  = "C:\work\2019\autorest_orig\autorest\src\autorest-core"

function ResolvePath {
  param (
      [string] $FileName
  )

  $FileName = Resolve-Path $FileName -ErrorAction SilentlyContinue `
                                     -ErrorVariable _frperror
  if (-not($FileName)) {
      $FileName = $_frperror[0].TargetObject
  }

  return $FileName
}

function In($location, $scriptblock) {
  pushd $location
  try {
    & $scriptblock
  } finally {
    popd 
  }
}

function write-hostcolor { Param ( $color,  [parameter(ValueFromRemainingArguments=$true)] $content ) write-host -fore $color $content }
function comment { Param ( [parameter(ValueFromRemainingArguments=$true)] $content ) write-host -fore darkgray $content }
function action { Param ( [parameter(ValueFromRemainingArguments=$true)] $content ) write-host -fore green $content }
function warn { Param ( [parameter(ValueFromRemainingArguments=$true)] $content ) write-host -fore yellow $content }

function err { Param ( [parameter(ValueFromRemainingArguments=$true)] $content ) write-host -fore red $content }

function get-cpu {
  return  powershell '( Get-WmiObject win32_processor | select LoadPercentage ).LoadPercentage'
}
function autorest-orig {Param($folder,[parameter(ValueFromRemainingArguments=$true)] $rgs ) 
  while ((get-cpu) -gt 90 ) { // -nonewline .; sleep 1 }
  // autorest-orig $rgs
  $shh = mkdir -ea 0  $folder 
  echo "autorest $rgs"  
  #cmd.exe /c start /min cmd.exe /c node.exe $autorest_orig $rgs '^>' "$folder\stdout.txt"
  cmd.exe /c start /min cmd.exe /c node.exe $autorest_orig $rgs '^>' "$folder\stdout.txt"
}
function autorest-new {Param($folder, [parameter(ValueFromRemainingArguments=$true)] $rgs ) 
  while ((get-cpu) -gt 90 ) { // -nonewline .  ; sleep 1 }
  // autorest-new $rgs
  $shh = mkdir -ea 0  $folder 
  echo "autorest $rgs" 
  #cmd.exe /c start /min cmd.exe /c node.exe $autorest_new $rgs '^>' "$folder\stdout.txt"
  cmd.exe /c start /min cmd.exe /c node.exe $autorest_new $rgs '^>' "$folder\stdout.txt"
}

function get-tags {Param($file)
  return (select-string -Path $file -Pattern "\(tag\).*'(.*)'" |% { $_.Matches } | % { $_.groups[1].value } | Group-Object).Name
}

if( -not (get-alias -ea 0 // )) {

new-alias '//'  comment
new-alias '/#'  comment
new-alias '=>' action
new-alias '/$' warn
new-alias '/!' err

new-alias '==>' write-hostcolor

}