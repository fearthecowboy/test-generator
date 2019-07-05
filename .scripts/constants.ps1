## ===========================================================================
# constants
$restSpecsRepoUri = "https://github.com/azure/azure-rest-api-specs"

## ===========================================================================
# locations
$root = resolvepath $PSScriptRoot/..
$tmp = resolvepath $root/tmp ; mkdir -ea 0  $tmp
$restSpecs = resolvepath $tmp/azure-rest-api-specs
$outputs = resolvepath $tmp/outputs

$out_original = resolvepath $outputs/original
$out_new = resolvepath $outputs/new
$expected_files_dir = resolvepath $tmp/expected

## make sure the output folders are created
mkdir -ea 0 $out_original
mkdir -ea 0 $out_new

