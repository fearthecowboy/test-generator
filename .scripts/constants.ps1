## ===========================================================================
# constants
$restSpecsRepoUri = "https://github.com/azure/azure-rest-api-specs"

## ===========================================================================
# locations
$root = resolvepath $PSScriptRoot/..
$tmp = resolvepath $root/tmp ; mkdir -ea 0  $tmp
$restSpecs = resolvepath $tmp/azure-rest-api-specs
$outputs = resolvepath $tmp/outputs

$out_1 = resolvepath $outputs/original
$out_2 = resolvepath $outputs/new

## make sure the output folders are created
mkdir -ea 0 $out_1
mkdir -ea 0 $out_2

