$pathToScriptsFolder = Split-Path $MyInvocation.MyCommand.Path
$pathToOutputXml=$pathToScriptsFolder + "\ListOfIssues.xml"
$pathToFilteredXml=$pathToScriptsFolder + "\FilteredListOfIssues.xml"
$pathToExcludedItemsXml = $pathToScriptsFolder + "\ListOfExcludedItems.xml"

[xml]$codeAnalyseOutput = Get-Content $pathToOutputXml
[xml]$listOfExcludedItems = Get-Content $pathToExcludedItemsXml


$pathToNodes = "/Report/Issues/Project/Issue"

function DeleteIssuesByTemlatePathAndSpecificMessage
{
    $listOfSpecificMessages = $listOfExcludedItems.SelectNodes("/Lists/ListOfPathsTemplatesForSpecificMessages/SpecificMessage")
    
    foreach ($message in $listOfSpecificMessages)
    {
        foreach ($path in $message.Path)
        {
            $nodesInOriginalFile = $codeAnalyseOutput.SelectNodes($pathToNodes) | where  { $_.File -like $path.Template -and $_.Message -like $message.Message } 
      
            if ($nodesInOriginalFile -ne $null)
            {
                foreach ($node in $nodesInOriginalFile)
                {
                    $node.ParentNode.RemoveChild($node)
                }
            } 
        }
    }
}

function DeleteIssuesInExcludedAreas()
{
    $listOfExcludedPaths = $listOfExcludedItems.SelectNodes("/Lists/ListOfExcludedPaths/Issue")

    foreach ($path in $listOfExcludedPaths)
    {            
        $nodesInOriginalFile = $codeAnalyseOutput.SelectNodes($pathToNodes) | where  { $_.File -like $path.ExcludedPaths } 
      
        if ($nodesInOriginalFile -ne $null)
        {
            foreach ($node in $nodesInOriginalFile)
            {
                $node.ParentNode.RemoveChild($node)
            }
        }  
    }   
    
}

function DeleteIssuesWithErrorSeverity()
{
    $nodes = $codeAnalyseOutput.SelectNodes("/Report/IssueTypes/IssueType") | where  { ($_.Severity -like 'ERROR') -or  ($_.Severity -like 'SUGGESTION') }

    foreach ($node in $nodes)
    {
        $errors = $codeAnalyseOutput.SelectNodes($pathToNodes) | where  { $_.TypeId -like $node.Id }
    
        if ($errors -ne $null)
        {
            foreach ($item in $errors)
            {
                ExcludeFilesWithErrors $item.ParentNode $item.File
            }
         }
    }
}


function DeleteIssuesWithExcludedMessages()
{
    $listOfExcludedMessages = $listOfExcludedItems.SelectNodes("/Lists/ListOfExcludedMessages/Issue")

    foreach ($message in $listOfExcludedMessages)
    {
        $nodesInOriginalFile = $codeAnalyseOutput.SelectNodes($pathToNodes) | where {$_.Message -like $message.Message}    
      
        if ($nodesInOriginalFile -ne $null)
        {
            foreach ($node in $nodesInOriginalFile)
            {
                $node.ParentNode.RemoveChild($node)
            }
        }  
    }
}

function ExcludeFilesWithErrors([System.Xml.XmlLinkedNode]$parentNode, [string]$file)
{
    $itemsInErrorFile = $parentNode.ChildNodes | where {$_.File -like $file}
    
    foreach($item in $itemsInErrorFile)    
    {   
        if ($item -ne $null) 
        {
            $parentNode.RemoveChild($item)
        }       
    }    
}


function RemoveRedundantElements()
{
    $projects = $codeAnalyseOutput.SelectNodes("/Report/Issues/Project")

    foreach ($project in $projects)
    {
        if ($project.Issue -eq $null)
        {
            $project.ParentNode.RemoveChild($project)
        }
    }
    
    $issueTypes = $codeAnalyseOutput.SelectNodes("/Report/IssueTypes/IssueType")
    
    foreach ($issueType in $issueTypes)
    {
        $nodesWithIssue = $codeAnalyseOutput.SelectNodes($pathToNodes) | where {$_.TypeId -like $issueType.Id}
        
        if($nodesWithIssue -eq $null)
        {
            $issueType.ParentNode.RemoveChild($issueType)
        }  
    }      
    
}

DeleteIssuesInExcludedAreas
DeleteIssuesWithErrorSeverity
DeleteIssuesWithExcludedMessages
DeleteIssuesByTemlatePathAndSpecificMessage
RemoveRedundantElements

$codeAnalyseOutput.Save($pathToFilteredXml)







