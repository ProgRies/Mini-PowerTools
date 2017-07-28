function Get-EPO-API{
<#
.SYNOPSIS
Set up and execute an API call against the ePO API

.DESCRIPTION
Get-EPO-API uses a report ID and uses it to execute an API query.
The output is then displayed, and can be stored in objects.
Currently this is JSON output :)
To get the data in human readable format, set the -json_switch boolean
Operator. Otherwise just enter the Report ID as parameter.

.PARAMETER query_id
One or more query id that represent the report id that we are trying to run through
the API interface. The ID can be obtained from the URL in the GUI

.EXAMPLE
Regular use:
Get-EPO-API 295

Pipe:
1073 | Get-EPO-API

Multiple Report ID's can be entered as well, but credentials need to be
provided for each query (unless you want to hardcode your 
username and password in plain text:

Get-EPO-API 295, 1073, 798




#>
    [CmdletBinding()]

    param (
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   HelpMessage = 'One or more Report IDs')]
        [int[]]$query_id,
        [switch] $json_switch 
    )

    BEGIN {
        Write-Output "Making API Call..."
    }

    PROCESS {

        foreach($query in $query_id){

            $Credential=get-credential -Credential $null

            ### Prompt for API credentials
            $epoUser=$Credential.GetNetworkCredential().username
            $epoPassword=$Credential.GetNetworkCredential().password

            [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
            $wc=new-object System.net.WebClient
            $wc.Credentials = new-object System.Net.NetworkCredential -ArgumentList ($epoUser, $epoPassword)

            if($json_switch){
                $url="https://  <---  PATH TO YOUR ePO APPLICATION (hostname/ip + Port) --->        /remote/core.executeQuery?queryId=" + $query
            }
            else{
                $url="https://  <---  PATH TO YOUR ePO APPLICATION (hostname/ip + Port) --->        /remote/core.executeQuery?:output=json&queryId=" + $query
            }

            $wc.downloadstring("$url")
        }
    }

    END {
        Write-Debug "API Calls complete!"
    }
}
