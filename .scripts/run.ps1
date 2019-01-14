
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
$allreadmes = get-childitem $restSpecs\readme.md -recurse  | Where-Object { $_.FullName -match "resource.manager" }

$x =0 

// get directory names of new generated files that already were correctly generated
$allpassed = (get-childitem -path $expected_files_dir).Name
# wrap in a list if there is just one element
if ($allpassed -is [String]) {
  $allpassed = @($allpassed)
}

// Files that were correctly generated in a previous run: 
$allpassed

$allreadmes | ForEach-Object {
  if( $x -lt 200) {
    $file = $_

    # always generate the new files
    autorest-new $out_2/$x/cs $file --csharp.output-folder:$out_2/$x/cs
    autorest-new $out_2/$x/py $file --python.output-folder:$out_2/$x/py
    autorest-new $out_2/$x/ts $file --typescript.output-folder:$out_2/$x/ts
    autorest-new $out_2/$x/java $file --java.output-folder:$out_2/$x/java
    autorest-new $out_2/$x/ars $file --azureresourceschema.output-folder:$out_2/$x/ars

    $tests = @(
      @{testName = "cs"; fileExtension = "*.cs" },
      @{testName = "py"; fileExtension = "*.py" },
      @{testName = "ts"; fileExtension = "*.ts" },
      @{testName = "java"; fileExtension = "*.java" }
    )

    if ($allpassed.Contains($x.ToString())) {
      $tests | ForEach-Object {
        $test = $_
        $testName = $test.testName
        // test name: $testName

        $fileExtension = $test.fileExtension
        // file extension: $fileExtension
        
        # actual data
        $actualFilesPath = "$out_2\$x\$testName"
        $actualFiles = Get-ChildItem –Path $actualFilesPath -Filter $fileExtension -Recurse
        $actualHashes = $actualFiles | ForEach-Object {Get-FileHash –Path $_.FullName}

        # expected data
        $expectedFilesPath = "$expected_files_dir\$x\$testName"
        $expectedFiles = Get-ChildItem –Path $expectedFilesPath -Filter $fileExtension -Recurse
        $expectedHashes =  $expectedFiles | ForEach-Object {Get-FileHash –Path $_.FullName}

        try
        {
          $failedPaths =  (Compare-Object -ReferenceObject  $actualHashes -DifferenceObject $expectedHashes  -Property hash -PassThru).Path
        } catch{
          /! there was a terminating error. one of the file sets was null
          $failedPaths = @()
        }
       
        if ($failedPaths) {
          /! --> "Failed: Different $testName files for test '$x'"
        } else {
          // --> "$testName tests for test '$x' passed "
        }
      }
     
    } else {
      autorest-orig $out_1/$x/cs $file --csharp.output-folder:$out_1/$x/cs  
      autorest-orig $out_1/$x/py $file --python.output-folder:$out_1/$x/py
      autorest-orig $out_1/$x/ts $file --typescript.output-folder:$out_1/$x/ts
      autorest-orig $out_1/$x/java $file --java.output-folder:$out_1/$x/java
      autorest-orig $out_1/$x/ars $file --azureresourceschema.output-folder:$out_1/$x/ars
    }
    
    $x = $x + 1  
  }


  return;
}