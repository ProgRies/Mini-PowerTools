$fullList = Get-Content "Path to csv of IP's.csv"

$fullListArray = $fullList.Split(",")

$fullListArray.Count

$fullListArray = $fullListArray | select -uniq

$fullListArray.Count

$fullListArray

