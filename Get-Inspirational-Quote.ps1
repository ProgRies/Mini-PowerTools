function Get-Inspirational-Quote{
<#
.SYNOPSIS
Set up and execute an API call against the quotes.rest api

.DESCRIPTION
Get-Inspirational-Quote pulls a random quote online using the quotes.rest api

IMPORTANT:
Unless the oauth authentication ability is added to the logic of this script, 
you will be limited to a few pulls every hour. This is an open query, used by many other people. 
Unless you are willing to sign up, don't abuse it.

.PARAMETER category
This is a one word string that defines whitch category of quotes you want to randomly pull from.


.EXAMPLE
Get-Inspirational-Quote inspire
Get-Inspirational-Quote passion



#>
    [CmdletBinding()]

    param (
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   HelpMessage = 'One or more Report IDs')]
        [string[]]$category 
    )

    BEGIN {
        Write-Output "Making API Call..."
    }

    PROCESS {

        foreach($item in $category){

            $url = "http://quotes.rest/qod?category=inspire"
            $wc=new-object System.net.WebClient
            $wc.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
            $wc.downloadstring("$url")

        }
    }

    END {
        Write-Debug "API Calls complete!"
    }
}

Get-Inspirational-Quote inspire
