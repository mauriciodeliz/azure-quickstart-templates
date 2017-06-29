$myCredential = Get-AutomationPSCredential -Name 'Credential'
$userName = $myCredential.UserName
$securePassword = $myCredential.Password
$password = $myCredential.GetNetworkCredential().Password


 
