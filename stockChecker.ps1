function Get-Yahoo-Stock-API{
<#
.SYNOPSIS
Set up and execute an API call against the Yahoo StockExchange API

.DESCRIPTION
Queries basic data on a certain stock, queried on the symbol the company uses to trade on the market.
The API returns a JSON object, but the keyword 'Symbol' is used twice (symbol/Symbol) so I manually rename the second
instance to 'StockSymbol' to prevent 'ConvertFomr-Json' from crashing.

.PARAMETER category
$company_symbol 

Should be a letter or a a short string of letters that is used to represent a company on the 
stock market. The example used is 'c', which is the the symbol Citigroup uses. 

For more info please see the Example Section

.EXAMPLE
Regular use:
Get-Yahoo-Stock-API C
Get-Yahoo-Stock-API TSLA

Pipe:
C    | Get-Yahoo-Stock-API
TSLA | Get-Yahoo-Stock-API

Multiple Symbols might be supported later but currently I will focus on just one stock at a time.

#>
    [CmdletBinding()]

    param (
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   HelpMessage = 'The symbol a company uses at the Stock Market (String of Letters)')]
        [string[]]$company_symbol 
    )

    BEGIN {
        Write-Debug "Making API Call..."
    }

    PROCESS {
        
        $url="https://query.yahooapis.com/v1/public/yql?q="
        $url = $url + 'select * from yahoo.finance.quotes where symbol in ("' + $company_symbol + '")&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback='
        
        <#
        ### Prompt for API credentials
        $Credential=get-credential -Credential $null
        $ApiUser=$Credential.GetNetworkCredential().username
        $ApiPassword=$Credential.GetNetworkCredential().password

        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
        $wc=new-object System.net.WebClient
        $wc.Credentials = new-object System.Net.NetworkCredential -ArgumentList ($ApiUser, $ApiPassword)
        #>
        
        $wc=new-object System.net.WebClient
        $wc.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
        

        $json_response = $wc.downloadstring("$url")

        $json_response = $json_response -replace 'Symbol','StockSymbol'

        $json_format = ConvertFrom-Json -InputObject $json_response 

        <#
            $json_format.query.count
            $json_format.query.created
            $json_format.query.lang
            $json_format.query.results.quote.Name
            $json_format.query.results.quote.AverageDailyVolume
            $json_format.query.results.quote.Bid
            $json_format.query.results.quote.BokkValue
            $json_format.query.results.quote.Change_PercentChange
            $json_format.query.results.quote.Currency
            $json_format.query.results.quote.DividentShare
            $json_format.query.results.quote.DaysLow
            $json_format.query.results.quote.DaysHigh
            $json_format.query.results.quote.YearLow
            $json_format.query.results.quote.YearHigh
            $json_format.query.results.quote.MarketCapitalization
            $json_format.query.results.quote.DividentPayDate
            $json_format.query.results.quote.Volume
            $json_format.query.results.quote.StockExchange
        #>

        $json_format
    }

    END {
        Write-Debug "API Calls complete!"
    }
}

$user_input = Read-Host -Prompt 'Company Symbol'

$json_object = Get-Yahoo-Stock-API $user_input

### Create Excel Object and fill in report with collected data 

Write-Host "Creating Report..."

### Creates Excel application
$excel = New-Object -ComObject excel.application

### Makes Excel Visable
$excel.Application.Visible = $true
$excel.DisplayAlerts = $false

### Creates Excel workBook
$book = $excel.Workbooks.Add()

### Gets the work sheet and Names it
$sheet = $book.Worksheets.Item(1)
$sheet.name = $user_input

### Select a worksheet
$sheet.Activate() | Out-Null

### Create a row and set it to Row 1
$row = 1
### Create a column Variable and set it to column 1
$column = 1

### Add the word Information and change the Font of the word
$sheet.Cells.Item($row,$column) = "Stock Watcher"
$sheet.Cells.Item($row,$column).Font.Size = 14
$sheet.Cells.Item($row,$column).Interior.ColorIndex = 4
$sheet.Cells.Item($row,$column).Font.Bold = $true

$row++
$sheet.Cells.Item($row,$column) = "Date"
$sheet.Cells.Item($row,$column).Font.Bold = $true

$column++

$sheet.Cells.Item($row,$column) = $(Get-Date).ToString("MM-dd-yyyy")

$sheet.Cells.Item(4,2) = "Current Ask Price"
$sheet.Cells.Item(5,2) = "Current Bid Price"
$sheet.Cells.Item(6,2) = "Days Low"
$sheet.Cells.Item(7,2) = "Days High"

### Fits cells to size
$UsedRange = $sheet.UsedRange
$UsedRange.EntireColumn.autofit() | Out-Null



### Adding the Chart
$bidaskChart = $sheet.Shapes.AddChart().Chart

### Set it true if want to have chart Title
$bidaskChart.HasTitle = $true

### Providing the Title for the chart
$bidaskChart.ChartTitle.Text = "Current Price"

while($true){
    $json_object = Get-Yahoo-Stock-API $user_input
    
    $sheet.Cells.Item(4,3) = $json_object.query.results.quote.Ask
    $sheet.Cells.Item(5,3) = $json_object.query.results.quote.Bid
    $sheet.Cells.Item(6,3) = $json_object.query.results.quote.DaysLow
    $sheet.Cells.Item(7,3) = $json_object.query.results.quote.DaysHigh

    $sheet.Cells.Item(2,3) = $json_object.query.results.quote.Name
    $sheet.Cells.Item(2,4) = $(Get-Date).ToString("hh:mm:ss")

    ### Fits cells to size
    $UsedRange = $sheet.UsedRange
    $UsedRange.EntireColumn.autofit() | Out-Null 

    $Range_tmp = 'C4:C5'
    $DataforChart = $sheet.Range($Range_tmp).CurrentRegion
    $bidaskChart.SetSourceData($DataforChart)


    $sheet.shapes.item("Chart 1").top = 150
    $sheet.shapes.item("Chart 1").left = 350






    Start-Sleep  -s 5
}







