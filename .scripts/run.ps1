
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

if ( -not (test-path $expected_files_dir)) {
  New-Item -Path $tmp -Name "expected" -ItemType "directory"
}

$x = 0

# files passed
# 0, 1, 2, 3, 4

// get directory names of new generated files that already were correctly generated
$allpassed = (get-childitem -path $expected_files_dir).Name
# wrap in a list if there is just one element
if ($allpassed -is [String]) {
  $allpassed = @($allpassed)
}

// Files that were correctly generated in a previous run: 
$allpassed

$allreadmes | ForEach-Object {
  if( $x -lt 100) {
    $file = $_

    # always generate the new files
    autorest-new $out_new/$x/cs $file --csharp.output-folder:$out_new/$x/cs --version:$autorest_new_version --simple-tree-shake
    # autorest-new $out_new/$x/py $file --python.output-folder:$out_new/$x/py 
    # autorest-new $out_new/$x/ts $file --typescript.output-folder:$out_new/$x/ts 
    # autorest-new $out_new/$x/java $file --java.output-folder:$out_new/$x/java 
    # autorest-new $out_new/$x/ars $file --azureresourceschema.output-folder:$out_new/$x/ars 

    $tests = @(
      @{testName = "cs"; fileExtension = "*.cs" }
      # ,
      # @{testName = "py"; fileExtension = "*.py" },
      # @{testName = "ts"; fileExtension = "*.ts" },
      # @{testName = "java"; fileExtension = "*.java" }
    )

    if ((-not ((Get-ChildItem $out_original | Measure-Object).Count -eq 0)) -and ($allpassed -eq -not $null) -and $allpassed.Contains($x.ToString())) {
      $tests | ForEach-Object {
        $test = $_
        $testName = $test.testName

        $fileExtension = $test.fileExtension
        
        # actual data
        $actualFilesPath = $out_new/$x/$testName
        $actualFiles = Get-ChildItem –Path $actualFilesPath -Filter $fileExtension -Recurse
        $actualHashes = $actualFiles | ForEach-Object {Get-FileHash –Path $_.FullName}

        # expected data
        $expectedFilesPath = $expected_files_dir/$x/$testName
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

      # original just generated when no expected files are present
      # this will speed the testing process
      autorest-orig $out_original/$x/cs $file --csharp.output-folder:$out_original/$x/cs --version:$autorest_orig_version
      # autorest-orig $out_original/$x/py $file --python.output-folder:$out_original/$x/py 
      # autorest-orig $out_original/$x/ts $file --typescript.output-folder:$out_original/$x/ts 
      # autorest-orig $out_original/$x/java $file --java.output-folder:$out_original/$x/java 
      # autorest-orig $out_original/$x/ars $file --azureresourceschema.output-folder:$out_original/$x/ars 
    }
    
    $x = $x + 1  
  }


  return;
}