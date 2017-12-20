param([Parameter(Mandatory=$true)] $pathToFilteredXml)

[xml]$codeAnalyseOutput = Get-Content $pathToFilteredXml
        
if ($codeAnalyseOutput.SelectNodes("/Report/Issues/Project/Issue")  -ne $null)
{
    $problems = $codeAnalyseOutput.SelectNodes("/Report/Issues/Project/Issue")
         
    foreach ($problem in $problems)
    {
        $errorString = "Problem: " + $problem.Message +", in file: " + $problem.File + ", problem string: " + $problem.Line
        write-error $errorString
    }
    
    throw "ReSharper rules have been broken!"
	exit 1
}