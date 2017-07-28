# Number is amount of days you want to check against
# 365 as parameter will return all files that are older than 1 year.

$time = (Get-Date).AddDays(-1825)

# Here you can change the path to the highest level of the directory you want to start and scan at.
# Setting it to C:\ will scan your entire C: drive.

$stuff = Get-ChildItem "C:\" -Recurse | Where-Object {$_.LastWriteTime -lt $time}

# This will export the results to a csv file. 
# To see a console output would take too much time, there are so many files that it's just faster
# to wait for this process to finish and look at the csv, it will have plenty of data.

$stuff | Export-Csv  outdatedFilesForSecurityDrive.csv