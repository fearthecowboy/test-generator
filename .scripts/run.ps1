$ErrorActionPreference  = "stop"
. $PSScriptRoot/shared.ps1
. $PSScriptRoot/constants.ps1

# This script requires the following:
# git



## ===========================================================================
# script
  
# // cleanup schema folder first.
# in $schemas { git checkout . ; git clean -xdf .  } 

& $PSScriptRoot/get-specs-repo.ps1 

// get all readme.md files 
$allreadmes = get-childitem $restSpecs\readme.md -recurse  | where { $_.FullName -match "resource.manager" }

$x =0 

$allreadmes |% {
  if( $x -lt 20) {
    $file = $_

    
    autorest-orig $out_1/$x/cs $file --csharp.output-folder:$out_1/$x/cs  
    autorest-orig $out_1/$x/py $file --python.output-folder:$out_1/$x/py
    autorest-orig $out_1/$x/ts $file --typescript.output-folder:$out_1/$x/ts
    autorest-orig $out_1/$x/java $file --java.output-folder:$out_1/$x/java
    autorest-orig $out_1/$x/ruby $file --ruby.output-folder:$out_1/$x/ruby
    autorest-orig $out_1/$x/ars $file --azureresourceschema.output-folder:$out_1/$x/ars

    autorest-new $out_2/$x/cs $file --csharp.output-folder:$out_2/$x/cs
    autorest-new $out_2/$x/py $file --python.output-folder:$out_2/$x/py
    autorest-new $out_2/$x/ts $file --typescript.output-folder:$out_2/$x/ts
    autorest-new $out_2/$x/java $file --java.output-folder:$out_2/$x/java
    autorest-new $out_2/$x/ruby $file --ruby.output-folder:$out_2/$x/ruby
    autorest-new $out_2/$x/ars $file --azureresourceschema.output-folder:$out_2/$x/ars

  }
  $x = $x + 1  

  return;
<# run all tags 
  $tags  = get-tags $_

  $tags |% {
    $tag = $_
    autorest $file --output-folder:$schemas/$tag --azureresourceschema --tag:$tag
  }
  
#>  
}

<#

// find files changed in last commit.
$files = in $restSpecs { git diff-tree --no-commit-id --name-only -r HEAD~1 } 
$swaggers = @()

$files |% { 
  $file = "$restSpecs/$_"
  $content = get-content -raw $file
  if( $content -match '"swagger": "2.0"' ) {
    // $file is a swagger file
    $swaggers += $file 
  }
}

$cmd =  @()

$swaggers |% {
  $swagger = $_
  # $cmd = $cmd + "--input-file=$( resolve-path $swagger)"
  => autorest  --input-file=$(resolve-path $swagger)  --output-folder:$schemas --azureresourceschema
  autorest --input-file=$(resolve-path $swagger) --output-folder:$schemas --azureresourceschema --title:none

}

#=> autorest $cmd --output-folder:$schemas --azureresourceschema
#autorest $cmd --output-folder:$schemas --azureresourceschema --title:none


$newfiles = in $schemas { (git status . -uall).Trim() }
$newMarkdownFiles = $newfiles | where { $_ -match ".md" }
$newSchemaFiles = $newfiles | where { $_ -match ".json" }

in $schemas { $newMarkdownFiles |% { remove-item $_ }  }
#>

# => $allreadmes