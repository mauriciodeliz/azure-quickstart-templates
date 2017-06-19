# Nome de conexão com o Azure
$connectionName = "AzureRunAsConnection" # Connection padrão criada na conta de automação
$connectionName2 = "RunAsConnectionInfraBase" # Connection criada manualmente para a assinatura da InfraBase
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection = Get-AutomationConnection -Name $connectionName         

    Write-Output "Logging in to Azure dentro da assinatura do Services Datasul..."
    $Account = Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint `
        -Verbose `
        -ErrorAction Stop

    Write-Output "***** LOGGED IN ($((Get-AzureRmContext).Subscription.SubscriptionName)). *******"
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } 
    else
    {
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

Write-Output "Current subscription using Get-AzureRmSubscription:"
 Get-AzureRmSubscription
 Write-Output "==============================================================="
# Get VM em Services Datasul
Get-AzureRmVM | FT

Write-Output " Alterado os recursos para a aassinatura Infra-Base:"
Write-Output  "Selecionando a assinatura da Infra-Base:"

Select-AzureRmSubscription -SubscriptionId "e0550e8e-0d18-43e3-9618-3e297362e08e"

# Get VM em Infra-Base
# Get-AzureRmVM | FT



