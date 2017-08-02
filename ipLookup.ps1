$CSV_path = "path_to.csv"

$CSV_holder = Import-Csv $CSV_path -Header "Name"

$Name_Array = @()
$IP_Array = @()

ForEach($item in $CSV_holder) {
    $Name_Array += $item.Name
}



ForEach($name in $Name_Array){
    $ServerName = $name
    $IP_Array += [System.Net.Dns]::GetHostAddresses($ServerName)[0].IPAddressToString;
}


$IP_Array
