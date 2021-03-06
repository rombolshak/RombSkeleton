$pathToScriptsFolder = Split-Path $MyInvocation.MyCommand.Path
$pathToOutputXml=$pathToScriptsFolder + "\ListOfIssues.xml"
$pathToFilteredXml=$pathToScriptsFolder + "\FilteredListOfIssues.xml"
$pathToExcludedItemsXml = $pathToScriptsFolder + "\ListOfExcludedItems.xml"

[xml]$codeAnalyseOutput = Get-Content $pathToOutputXml
[xml]$listOfExcludedItems = Get-Content $pathToExcludedItemsXml

$pathToIssues = "/Report/Issues/Project/Issue"

function RemoveNodesFromParent($nodes, $reason="")
{
	if($reason)
	{
		Write-Host "$reason"
	}
	
	if ($nodes -ne $null)
	{
		foreach ($node in $nodes)
		{
			if($node.ParentNode -ne $null)
			{
				$node.ParentNode.RemoveChild($node)
			}
			else
			{
				Write-Host "There is no parent node for $node node."
			}
		}
	} 
}

function RemoveIssuesByTypeId
{
	$issueTypes = $listOfExcludedItems.SelectNodes("/AnalysisExclusions/ExcludedIssueTypes/IssueType")
	
	foreach ($issueType in $issueTypes)
	{
		$issues = $codeAnalyseOutput.SelectNodes($pathToIssues) | where { $_.TypeId -eq $issueType.Id }
		RemoveNodesFromParent $issues "Excluded by issue type id"

		$redundatIssueType = $codeAnalyseOutput.SelectNodes("/Report/IssueTypes/IssueType") | where { $_.Id -eq $issueType.Id}
	}
}

function RemoveIssuesByProjectName
{
	$projects = $listOfExcludedItems.SelectNodes("/AnalysisExclusions/ExcludedProjects/Project")
	
	foreach ($project in $projects)
	{
		$redundatProject = $codeAnalyseOutput.SelectNodes("/Report/Issues/Project") | where { $_.Name -eq $project.Name}
		if($redundatProject -ne $null -and $redundatProject.ParentNode -ne $null)
		{
			$redundatProject.ParentNode.RemoveChild($redundatProject)
		}
		else
		{
			Write-Host "There is no parent node for $redundatProject node"
		}
		
	}
}

function RemoveIssuesByTemlatePathAndSpecificMessage
{
	$listOfSpecificMessages = $listOfExcludedItems.SelectNodes("/AnalysisExclusions/PathsTemplatesForSpecificMessages/SpecificMessage")
	
	foreach ($message in $listOfSpecificMessages)
	{
		foreach ($path in $message.Path)
		{
			$nodesInOriginalFile = $codeAnalyseOutput.SelectNodes($pathToIssues) | where  { $_.File -like $path.Template -and $_.Message -like $message.Message } 
			RemoveNodesFromParent $nodesInOriginalFile "Excluded by template and specific messge"
		}
	}
}

function RemoveSuggestions()
{
	$redundatIssueTypes = $codeAnalyseOutput.SelectNodes("/Report/IssueTypes/IssueType") | where { $_.Severity -eq 'SUGGESTION' }
	
	foreach ($redundatIssueType in $redundatIssueTypes)
	{
		$redundatIssues = $codeAnalyseOutput.SelectNodes($pathToIssues) | where { $_.TypeId -eq $redundatIssueType.Id }
		RemoveNodesFromParent $redundatIssues "Suggestions excluding"
	}
}

function RemoveProjectsWithNoIssuesLeft
{
	$projects = $codeAnalyseOutput.SelectNodes("/Report/Issues/Project")
	foreach ($project in $projects)
	{
		if(!$project.HasChildNodes)
		{
			$project.ParentNode.RemoveChild($project);
			Write-Host "Removed node for a project $($project.Name) because project has no any problems."
		}
	}
}

function RemoveIssuesInExcludedAreas()
{
	$listOfExcludedPaths = $listOfExcludedItems.SelectNodes("/AnalysisExclusions/ExcludedPaths/Issue")

	foreach ($path in $listOfExcludedPaths)
	{            
		$nodesInOriginalFile = $codeAnalyseOutput.SelectNodes($pathToIssues) | where  { $_.File -like $path.ExcludedPaths } 
		RemoveNodesFromParent $nodesInOriginalFile "Excluded by issue path"
	}   
}

function RemoveIssuesWithExcludedMessages()
{
	$listOfExcludedMessages = $listOfExcludedItems.SelectNodes("/AnalysisExclusions/ExcludedMessages/Issue")

	foreach ($message in $listOfExcludedMessages)
	{
		$nodesInOriginalFile = $codeAnalyseOutput.SelectNodes($pathToIssues) | where { $_.Message -like $message.Message }    
	  
		if ($nodesInOriginalFile -ne $null)
		{
			foreach ($node in $nodesInOriginalFile)
			{
				$node.ParentNode.RemoveChild($node)
			}
		}  
	}
}

function RemoveIssueTypesWithNoAssociatedIssues()
{
	$usedIssueTypeIds = $codeAnalyseOutput.SelectNodes("/Report/Issues/Project/Issue") | select TypeId -Unique
	$allIssueTypes = $codeAnalyseOutput.SelectNodes("/Report/IssueTypes/IssueType")

	foreach ($issueType in $allIssueTypes)
	{
		$matchedIssueType = $usedIssueTypeIds | where { $_.TypeId -eq $issueType.Id }
		if($matchedIssueType -eq $null)
		{
			$issueType.ParentNode.RemoveChild($issueType)
		}
	}
}

RemoveIssuesByTemlatePathAndSpecificMessage
RemoveSuggestions
RemoveIssuesByTypeId
RemoveIssuesByProjectName

RemoveProjectsWithNoIssuesLeft
RemoveIssueTypesWithNoAssociatedIssues

$codeAnalyseOutput.Save($pathToFilteredXml)
