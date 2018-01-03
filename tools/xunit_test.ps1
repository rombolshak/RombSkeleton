$sciptDirectory = Split-Path $MyInvocation.MyCommand.Path
$tests = gci -Path "$sciptDirectory\..\src" -Filter "*Tests.csproj" -Recurse |% { $_.FullName }
Write-Host These projects contains tests: $tests
# & "$env:xunit20\xunit.console" $tests -xml $sciptDirectory\..\TestResult.xml -appveyor
dotnet test $tests --no-build -l "trx;LogFileName=$sciptDirectory\..\tests.trx"