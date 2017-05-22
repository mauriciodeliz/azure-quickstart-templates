workflow Send-BillEstimate
{

    param (
        [Parameter(Mandatory=$true)]
        [string] 
        $enrollmentNo = "100",

        [Parameter(Mandatory=$true)]
        [string] 
        $accesskey = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6IlE5WVpaUnA1UVRpMGVPMmNoV19aYmh1QlBpWSJ9.eyJFbnJvbGxtZW50TnVtYmVyIjoiMTAwIiwiSWQiOiIxY2Q4Mzg5YS01Mzc4LTQzZGQtYjUxOC0xNDM3MDkwYjA4MmEiLCJSZXBvcnRWaWV3IjoiU3lzdGVtIiwiUGFydG5lcklkIjoiIiwiRGVwYXJ0bWVudElkIjoiIiwiQWNjb3VudElkIjoiIiwiaXNzIjoiZWEubWljcm9zb2Z0YXp1cmUuY29tIiwiYXVkIjoiY2xpZW50LmVhLm1pY3Jvc29mdGF6dXJlLmNvbSIsImV4cCI6MTQ5MTk1MTE2MywibmJmIjoxNDc2MjI2MzYzfQ.EjDkRGFhWt9BVL0Vpl8OG2t2aJ6V-J78s8FdWkju2eq-YGf6QNINS_1jXQHkEV7O5uhcnzGXfHziiXPPPF2gdSooCwN8TjXmtQBJWMVX2wD6nnL6kQ0J7mx7k-A2DHd1Ds9AePS7174GYIIqC-uP94h2c_a96mwGdfganlXQHDTA0MCB2KHF0ZgLnoNB-enAbX6VnJAuOLLQSatm4M0VPdbifvqquNggkQb9g1BoGwfPjzpSjo7bdsC1a3b-4ajXzQnFFXdlArhorTrypImJle4nnR7yraO4PV-eyDMibpTSLDc6RvcjR7IjNyEun-YXCtyJawrEeFmluS-pkHqI0w",

        [Parameter(Mandatory=$true)]
        [string] 
        $mailfrom="envio.asp@totvs.com.br",

        [Parameter(Mandatory=$true)]
        [string]
        $mailto="mauricio.liz@totvs.com.br",

        [Parameter(Mandatory=$true)]
        [string]
        $smtpServer = "mail.totvs.com.br"
        
    )
$Username ="envio.asp"
$Password = ConvertTo-SecureString "progress@9" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential $Username, $Password
    
    $baseurl = "https://ea.azure.com/rest/"
    $authHeaders = @{"authorization"="bearer $accesskey";"api-version"="1.0"}

    Write-Verbose "Getting billing summary"
    $url= $baseurl + $enrollmentNo + "/usage-reports"
    Write-Verbose $url
    $sResponse = InlineScript {Invoke-WebRequest $using:url -Headers $using:authHeaders -UseBasicParsing}
    Write-Verbose $sResponse.StatusCode
    $sContent = $sResponse.Content | ConvertFrom-Json 

    $month=$sContent.AvailableMonths[-1].Month
    $url= $baseurl + $enrollmentNo + "/usage-report?month=$month&type=detail"
    Write-Verbose $url
    $mResponse = InlineScript {Invoke-WebRequest $using:url -Headers $using:authHeaders -UseBasicParsing}
    Write-Verbose $mResponse.StatusCode

    Write-Verbose "Split the response up into an array from a string"
    $mContent = ($mResponse.Content -split '[\r\n]')
    
    Write-Verbose "Convert from CSV to object"
    $monthBill = $mContent | Where-Object -FilterScript { [regex]::matches($_,",").count -gt 28} | ConvertFrom-Csv
    
    Write-Verbose "Get the last day of data available"
    $filterDay =$monthBill[-1].Date #
    $aday = $monthBill | Where-Object -FilterScript {$_.date -eq $filterDay}
    
    Write-Verbose "Calculate day cost"
    $adayCost = [math]::round($($aday | Select-Object -ExpandProperty ExtendedCost | Measure-Object -Sum).sum,2)
    
    Write-Output "Day Cost for $filterDay : $adayCost"
    
    if([int]$adayCost -gt 0) {
        Write-Verbose "Sending email"
    
        $body = "<HTML><HEAD><META http-equiv=""Content-Type"" content=""text/html; charset=iso-8859-1"" /><TITLE></TITLE></HEAD>"
        $body += "<BODY bgcolor=""#FFFFFF"" style=""font-size: Small; font-family: TAHOMA; color: #000000""><P>"
        $body += "If every day were like today, your annual Azure bill would be...<br />"
        $body += "<b>" + ($adayCost*365) + "</b><br>"
        $body += "Based on usage for " + ([datetime]$filterDay).tostring("dd MMM yyyy") + " ($adayCost)"
        
        Send-MailMessage -SmtpServer $smtpServer -Port 587 -Credential $credential -BodyAsHtml -From $mailfrom -UseSsl -To $mailto -Subject 'Azure Billing Notification' -Body $body

        Write-Output "Sent email"
    }  
}