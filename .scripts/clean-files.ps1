# Uncomment to delete .txt files
# Get-ChildItem -Path C:\work\2019\test-generator\tmp\cleanoutputs -Filter *.txt -Recurse | ForEach-Object { Remove-Item -Path $_.FullName }

$parentfolder =  "C:\work\2019\test-generator\tmp\outputs"

# patterns for CSHARP
$csmatches = "(apiversion)"
$csmatches += "|(\/\/\/.*) "
$csmatches += "|( API )"
$csmatches += "|( API\. )"
$csmatches += "|(    {)"
$csmatches += "|(    })"
$csmatches += "|( ApiExport)"

# # patterns for TS
# $tsmatches = "(apiversion)";
# $tsmatches += "|( constructor\(subscriptionId: string, options)"
# $tsmatches += "|( super\(subscriptionId, options\); )"
# $tsmatches += "|( isConstant: true,)"
# $tsmatches += "|( defaultValue: )"
# $tsmatches += "|(    })"
# $tsmatches += "|(\/\*\*)"
# $tsmatches += "|(\* \')"
# $tsmatches += "|(\*\/)"
# $tsmatches += "|(Parameters\.filter)"

# # patterns for JAVA
# $javamatches = "(apiversion)";
# $javamatches += "|(    })"
# $javamatches += "|(    IOException)"

# # patterns for PYTHON
# $pymatches = "(api_version)";

$fileTypeInfo = @(
    @{ extension = "*.cs"; pattern = $csmatches}
    # ,
    # @{ extension = "*.ts"; pattern = $tsmatches},
    # @{ extension = "*.java"; pattern = $javamatches},
    # @{ extension = "*.py"; pattern = $pymatches}
)

# delete txt files
$files =  Get-ChildItem -Path $parentfolder -Filter "*.txt" -Recurse 
$files | ForEach-Object {
    $file = $_.FullName
    Remove-Item $file
} 

for ($i=0; $i -lt $fileTypeInfo.Length; $i++) {
    $files =  Get-ChildItem -Path $parentfolder -Filter $fileTypeInfo[$i].extension -Recurse 
    $files | ForEach-Object {
        $file = $_.FullName
        Get-Content $file | Where-Object {$_ -notmatch $fileTypeInfo[$i].pattern } | Set-Content "$($_.FullName).new"
        Remove-Item $file
        Write-Host "Completed: $file"
    } 
}
