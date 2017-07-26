#######################################################
### Get-Yahoo-Stock-API
### Author: Christian Ries 
### Date: 07/25/2017
#######################################################

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
            ### Optional logic to provide authentication

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

        $json_format.query.count
    }

    END {
        Write-Debug "API Calls complete!"
    }
}