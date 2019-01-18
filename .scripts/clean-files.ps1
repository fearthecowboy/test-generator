# Uncomment to delete .txt files
# Get-ChildItem -Path C:\work\2019\test-generator\tmp\cleanoutputs -Filter *.txt -Recurse | ForEach-Object { Remove-Item -Path $_.FullName }

$parentfolder =  "C:\work\2019\test-generator\tmp\outputs"

# patterns for CSHARP
$csmatches = "(apiversion)";
$csmatches += "|( API )"
$csmatches += "|( API\. )"
$csmatches += "|(    {)"
$csmatches += "|(    })"
$csmatches += "|(\/\/\/ <exception)"
$csmatches += "|(\/\/\/ <\/exception>)"
$csmatches += "|(\/\/\/ <\/exception>)"
$csmatches += "|(\/\/\/ Thrown when a required parameter is null)"

# patterns for TS
$tsmatches = "(apiversion)";
$tsmatches += "|( constructor\(subscriptionId: string, options)"
$tsmatches += "|( super\(subscriptionId, options\); )"
$tsmatches += "|( isConstant: true,)"
$tsmatches += "|( defaultValue: )"
$tsmatches += "|(    })"
$tsmatches += "|(\/\*\*)"
$tsmatches += "|(\* \')"
$tsmatches += "|(\*\/)"
$tsmatches += "|(Parameters\.filter)"

# patterns for JAVA
$javamatches = "(apiversion)";
$javamatches += "|(    })"
$javamatches += "|(    IOException)"

# patterns for PYTHON
$pymatches = "(api_version)";

$fileTypeInfo = @(
    @{ extension = "*.cs"; pattern = $csmatches},
    @{ extension = "*.ts"; pattern = $tsmatches},
    @{ extension = "*.java"; pattern = $javamatches},
    @{ extension = "*.py"; pattern = $pymatches}
)

for ($i=0; $i -lt $fileTypeInfo.Length; $i++) {
    $files =  Get-ChildItem -Path $parentfolder -Filter $fileTypeInfo[$i].extension -Recurse 
    $files | ForEach-Object {
        $file = $_.FullName
        Get-Content $file | Where-Object {$_ -notmatch $fileTypeInfo[$i].pattern } | Set-Content "$($_.FullName).new"
        Write-Output "Completed: $file"
    } 
}
