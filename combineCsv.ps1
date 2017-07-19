#$files = Get-ChildItem "C:\Users\cries\Documents\Reports\Nessus Reports\*.csv" 
#Get-Content $files | Set-Content "C:\Users\cries\Documents\Reports\Nessus Reports\mergedReport.csv"


$CSVFINDir = "Path to final csv file"
$CSVTMPDir = "path to dir that holds multiple csv's"
$CurFinCSV = "$CSVFINDir + \name of final csv file"
$CSVTemp = (GCI -Path $CSVTMPDir -Recurse | where {$_.Attributes -ne "Directory"}).fullname

if (!(Test-Path "$CurFinCSV")){
('1' | ?{$_ -ne '1'}) | Select-Object @{Name='Value';Expression={$_}} |
    Export-Csv -Path "$CurFinCSV" -NoTypeInformation
}
ForEach($CSV in $CSVTemp){Import-CSV "$CSV" | Export-csv "$CurFinCSV" -Append -NoType}


