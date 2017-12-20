$sciptDirectory = Split-Path $MyInvocation.MyCommand.Path
$tests = gci -Path "$sciptDirectory\..\bin" -Filter "*Tests.dll" -Recurse |% { $_.FullName }
Write-Host These assemblies contains tests: $tests
& "$env:xunit20\xunit.console" $tests -xml $sciptDirectory\..\TestResult.xml