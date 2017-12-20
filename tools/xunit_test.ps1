$sciptDirectory = Split-Path $MyInvocation.MyCommand.Path
$tests = gci -Path "$sciptDirectory\..\bin" -Filter "*Tests.dll" -Recurse |% { $_.FullName }
& "$env:xunit20\xunit.console" $tests -xml=$sciptDirectory\..\TestResult.xml