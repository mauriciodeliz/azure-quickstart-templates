# Conexão com o Azure
$cred = "AzureRunAsConnection"
	try
{
		# Get the connection "AzureRunAsConnection "
		$servicePrincipalConnection=Get-AutomationConnection -Name $cred

	"Logging in to Azure..."
	Add-AzureRmAccount `
	-ServicePrincipal `
	-TenantId $servicePrincipalConnection.TenantId `
	-ApplicationId $servicePrincipalConnection.ApplicationId `
	-CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}


	catch 
{
		if (!$servicePrincipalConnection)
		    {
			$ErrorMessage = "Connection $cred not found."
			throw $ErrorMessage
		    } 
		
		else
		    {
			Write-Error -Message $_.Exception
			throw $_.Exception
		    }
		
}


      #Browse all Subscripitions
      $Subs = Get-AzureRmSubscription -TenantId $TenantID
      Write-Output "Subs: $Subs"
 
      foreach ($SubItem in $Subs)
{

       Write-Output "Selected Sub: $SubItem"
       Get-AzureRmSubscription -TenantId $TenantID
       
       # Seleciona a assinatura Services Datasul
       Write-Output " Select Subscription Services-Datasul"
	   Select-AzureRmSubscription -SubscriptionId "d11b8b10-986b-441c-a02d-7c27dc2ed8d1"
       
      

}

        ################# Variaveis Globais ################
        $ResourceGroupName_IB = "RG-IB-NTW-BS-001"
        $ResourceGroupName_SC = "RG-SC-NTW-BS-001"
        $ResourceGroupName_DS = "RG-DS-NTW-BS-001"
        $Firewall = "10.210.0.92"
        # Tabela de Rotas Services Datasul
        $RT_DS_APP_TableName = "RT-DS-APP-BS"
        $RT_DS_DB_TableName = "RT-DS-DB-BS"
        $RT_DS_DMZ_TableName = "RT-DS-DMZ-BS"
        # Tabela de Rotas Infra - Base
        $RT_IB_APP_TableName = "RT-IB-APP-BS"
        $RT_IB_BKP_TableName = "RT-IB-BKP-BS"
        $RT_IB_DB_TableName = "RT-IB-DB-BS"
        # Tabela de Rotas Shared Client
        $RT_SC_APP_TableName = "RT-SC-APP-BS"
        $RT_SC_DB_TableName = "RT-SC-DB-BS"
        # Rotas para UDRs
        $RT_Internet = "Internet"
        $RT_AddressPrefix_Internet = "0.0.0.0/0"
        $RT_TRAFFIC_TO_IB_APP = "Traffic-To-IB-APP"
        $RT_PREFIX_TRAFFIC_TO_IB_APP = "10.210.0.0/27"
        $RT_TRAFFIC_TO_DS_APP = "Traffic-to-DS-APP"
        $RT_PREFIX_TRAFFIC_TO_DS_APP = "10.210.0.128/27"
        $RT_TRAFFIC_TO_DS_DB = "Traffic-to-DS-DB"
        $RT_PREFIX_TRAFFIC_TO_DS_DB = "10.210.0.160/28"
        $RT_TRAFFIC_TO_DS_DMZ = "Traffic-To-DS-DMZ"
        $RT_PREFIX_TRAFFIC_TO_DS_DMZ = "10.210.0.192/27"
        $RT_TRAFFIC_TO_IB_DB = "Traffic-To-IB-DB"
        $RT_PREFIX_TRAFFIC_TO_IB_DB = "10.210.0.64/28"
        $RT_TRAFFIC_TO_SC_APP = "Traffic-To-SC-APP"
        $RT_PREFIX_TRAFFIC_TO_SC_APP = "10.210.1.0/25"
        $RT_TRAFFIC_TO_SC_DB = "Traffic-To-SC-DB"
        $RT_PREFIX_TRAFFIC_TO_SC_DB = "10.210.1.128/25"

      
       
        # Tabela de Rotas SERVICES DATASUL
        $RT_DS_APP_BS = Get-azurermroutetable -ResourceGroupName "$ResourceGroupName_DS" -Name $RT_DS_APP_TableName
        $RT_DS_DB_BS = Get-azurermroutetable -ResourceGroupName "$ResourceGroupName_DS" -Name $RT_DS_DB_TableName
        $RT_DS_DMZ_BS = Get-azurermroutetable -ResourceGroupName "RG-DS-SEC-BS-001" -Name $RT_DS_DMZ_TableName
        
        # Alteração de Rotas na RT-DS-APP-BS
        Set-AzureRmRouteConfig -RouteTable $RT_DS_APP_BS -Name $RT_Internet -AddressPrefix $RT_AddressPrefix_Internet -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        Set-AzureRmRouteConfig -RouteTable $RT_DS_APP_BS -Name $RT_TRAFFIC_TO_DS_DB -AddressPrefix $RT_PREFIX_TRAFFIC_TO_DS_DB -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        Set-AzureRmRouteConfig -RouteTable $RT_DS_APP_BS -Name $RT_TRAFFIC_TO_DS_DMZ -AddressPrefix $RT_PREFIX_TRAFFIC_TO_DS_DMZ -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        Set-AzureRmRouteConfig -RouteTable $RT_DS_APP_BS -Name $RT_TRAFFIC_TO_IB_DB -AddressPrefix $RT_PREFIX_TRAFFIC_TO_IB_DB -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        Set-AzureRmRouteConfig -RouteTable $RT_DS_APP_BS -Name $RT_TRAFFIC_TO_IB_APP -AddressPrefix $RT_PREFIX_TRAFFIC_TO_IB_APP -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        Set-AzureRmRouteConfig -RouteTable $RT_DS_APP_BS -Name $RT_TRAFFIC_TO_SC_APP -AddressPrefix $RT_PREFIX_TRAFFIC_TO_DS_APP -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        Set-AzureRmRouteConfig -RouteTable $RT_DS_APP_BS -Name $RT_TRAFFIC_TO_SC_DB -AddressPrefix $RT_PREFIX_TRAFFIC_TO_SC_DB -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        # Alteração de Rotas na RT-DS-DB-BS
        Set-AzureRmRouteConfig -RouteTable $RT_DS_DB_BS -Name $RT_Internet -AddressPrefix $RT_AddressPrefix_Internet -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        Set-AzureRmRouteConfig -RouteTable $RT_DS_DB_BS -Name $RT_TRAFFIC_TO_DS_APP -AddressPrefix $RT_PREFIX_TRAFFIC_TO_DS_APP -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        Set-AzureRmRouteConfig -RouteTable $RT_DS_DB_BS -Name $RT_TRAFFIC_TO_DS_DMZ -AddressPrefix $RT_PREFIX_TRAFFIC_TO_DS_DMZ -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        Set-AzureRmRouteConfig -RouteTable $RT_DS_DB_BS -Name $RT_TRAFFIC_TO_IB_APP -AddressPrefix $RT_PREFIX_TRAFFIC_TO_IB_APP -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        Set-AzureRmRouteConfig -RouteTable $RT_DS_DB_BS -Name $RT_TRAFFIC_TO_IB_DB -AddressPrefix $RT_PREFIX_TRAFFIC_TO_IB_DB -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        Set-AzureRmRouteConfig -RouteTable $RT_DS_DB_BS -Name $RT_TRAFFIC_TO_SC_APP -AddressPrefix $RT_PREFIX_TRAFFIC_TO_SC_APP -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        Set-AzureRmRouteConfig -RouteTable $RT_DS_DB_BS -Name $RT_TRAFFIC_TO_SC_DB -AddressPrefix $RT_PREFIX_TRAFFIC_TO_SC_DB -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        #
        # Alteração de Rotas na RT-DS-DMZ-BS
        Set-AzureRmRouteConfig -RouteTable $RT_DS_DMZ_BS -Name $RT_Internet -AddressPrefix $RT_AddressPrefix_Internet -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        Set-AzureRmRouteConfig -RouteTable $RT_DS_DMZ_BS -Name $RT_TRAFFIC_TO_DS_APP -AddressPrefix $RT_PREFIX_TRAFFIC_TO_DS_APP -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        Set-AzureRmRouteConfig -RouteTable $RT_DS_DMZ_BS -Name $RT_TRAFFIC_TO_DS_DB -AddressPrefix $RT_PREFIX_TRAFFIC_TO_DS_DB -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        Set-AzureRmRouteConfig -RouteTable $RT_DS_DMZ_BS -Name $RT_TRAFFIC_TO_IB_APP -AddressPrefix $RT_PREFIX_TRAFFIC_TO_IB_APP -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        Set-AzureRmRouteConfig -RouteTable $RT_DS_DMZ_BS -Name $RT_TRAFFIC_TO_IB_DB -AddressPrefix $RT_PREFIX_TRAFFIC_TO_IB_DB -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        Set-AzureRmRouteConfig -RouteTable $RT_DS_DMZ_BS -Name $RT_TRAFFIC_TO_SC_APP -AddressPrefix $RT_PREFIX_TRAFFIC_TO_SC_APP -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        Set-AzureRmRouteConfig -RouteTable $RT_DS_DMZ_BS -Name $RT_TRAFFIC_TO_SC_DB -AddressPrefix $RT_PREFIX_TRAFFIC_TO_SC_DB -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable

        # Seleciona a assinatura Infra-Base
      $Subs = Get-AzureRmSubscription -TenantId $TenantID
      Write-Output "Subs: $Subs"
 
      foreach ($SubItem in $Subs)
{

       Write-Output "Selected Sub: $SubItem"
       Get-AzureRmSubscription -TenantId $TenantID
       
       # Seleciona a assinatura Infra Base
       Write-Output " Select Subscription Infra Base"
	   Select-AzureRmSubscription -SubscriptionId "e0550e8e-0d18-43e3-9618-3e297362e08e"
       
      

}
        
             
        # Tabela de Rotas SERVICES-INFRA-BASE
        $RT_IB_APP_BS = Get-azurermroutetable -ResourceGroupName "$ResourceGroupName_IB" -Name $RT_IB_APP_TableName
        $RT_IB_BKP_BS = Get-azurermroutetable -ResourceGroupName "$ResourceGroupName_IB" -Name $RT_IB_BKP_TableName
        $RT_IB_DB_BS = Get-azurermroutetable -ResourceGroupName "$ResourceGroupName_IB" -Name $RT_IB_DB_TableName
        #
        # Alteração de Rotas na RT-IB-APP-BS
        Set-AzureRmRouteConfig -RouteTable $RT_IB_APP_BS -Name $RT_Internet -AddressPrefix $RT_AddressPrefix_Internet -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable 
        Set-AzureRmRouteConfig -RouteTable $RT_IB_APP_BS -Name $RT_TRAFFIC_TO_DS_APP -AddressPrefix $RT_PREFIX_TRAFFIC_TO_DS_APP -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        Set-AzureRmRouteConfig -RouteTable $RT_IB_APP_BS -Name $RT_TRAFFIC_TO_DS_DB -AddressPrefix $RT_PREFIX_TRAFFIC_TO_DS_DB -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        Set-AzureRmRouteConfig -RouteTable $RT_IB_APP_BS -Name $RT_TRAFFIC_TO_DS_DMZ -AddressPrefix $RT_PREFIX_TRAFFIC_TO_DS_DMZ -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        Set-AzureRmRouteConfig -RouteTable $RT_IB_APP_BS -Name $RT_TRAFFIC_TO_IB_DB -AddressPrefix $RT_PREFIX_TRAFFIC_TO_IB_DB -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        Set-AzureRmRouteConfig -RouteTable $RT_IB_APP_BS -Name $RT_TRAFFIC_TO_SC_APP -AddressPrefix $RT_PREFIX_TRAFFIC_TO_SC_APP -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        Set-AzureRmRouteConfig -RouteTable $RT_IB_APP_BS -Name $RT_TRAFFIC_TO_SC_DB -AddressPrefix $RT_PREFIX_TRAFFIC_TO_SC_DB -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        #
        # Alteração de ROTAS na RT-IB-BKP-BS 
        Set-AzureRmRouteConfig -RouteTable $RT_IB_BKP_BS -Name $RT_Internet -AddressPrefix $RT_AddressPrefix_Internet -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        #
        # Alteração de Rotas na RT-IB-DB-BS
        Set-AzureRmRouteConfig -RouteTable $RT_IB_DB_BS -Name $RT_Internet -AddressPrefix $RT_AddressPrefix_Internet -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        Set-AzureRmRouteConfig -RouteTable $RT_IB_DB_BS -Name $RT_TRAFFIC_TO_DS_APP -AddressPrefix $RT_PREFIX_TRAFFIC_TO_DS_APP -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        Set-AzureRmRouteConfig -RouteTable $RT_IB_DB_BS -Name $RT_TRAFFIC_TO_DS_DB -AddressPrefix $RT_PREFIX_TRAFFIC_TO_DS_DB -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        Set-AzureRmRouteConfig -RouteTable $RT_IB_DB_BS -Name $RT_TRAFFIC_TO_DS_DMZ -AddressPrefix $RT_PREFIX_TRAFFIC_TO_DS_DMZ -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        Set-AzureRmRouteConfig -RouteTable $RT_IB_DB_BS -Name $RT_TRAFFIC_TO_IB_APP -AddressPrefix $RT_PREFIX_TRAFFIC_TO_IB_APP -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        Set-AzureRmRouteConfig -RouteTable $RT_IB_DB_BS -Name $RT_TRAFFIC_TO_SC_APP -AddressPrefix $RT_PREFIX_TRAFFIC_TO_SC_APP -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        Set-AzureRmRouteConfig -RouteTable $RT_IB_DB_BS -Name $RT_TRAFFIC_TO_SC_DB -AddressPrefix $RT_PREFIX_TRAFFIC_TO_SC_DB -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable -Verbose
        ########################################################################################################################
        ########################################################################################################################
        #

        # Seleciona a assinatura Infra Base
        Write-Output " Select Subscription Infra Base"
	    Select-AzureRmSubscription -SubscriptionId "982e5b48-49c6-465a-a551-bf8726c7e5af"

        # Tabela de Rotas SHARED CLIENT
        $RT_SC_APP_BS = Get-azurermroutetable -ResourceGroupName "$ResourceGroupName_SC" -Name $RT_SC_APP_TableName
        $RT_SC_DB_BS = Get-azurermroutetable -ResourceGroupName "$ResourceGroupName_SC" -Name $RT_SC_DB_TableName
        #
        # Alteração de Rotas na RT-SC-APP-BS
        Set-AzureRmRouteConfig -RouteTable $RT_SC_APP_BS -Name $RT_Internet -AddressPrefix $RT_AddressPrefix_Internet -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        Set-AzureRmRouteConfig -RouteTable $RT_SC_APP_BS -Name $RT_TRAFFIC_TO_DS_APP -AddressPrefix $RT_PREFIX_TRAFFIC_TO_DS_APP -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        Set-AzureRmRouteConfig -RouteTable $RT_SC_APP_BS -Name $RT_TRAFFIC_TO_DS_DB -AddressPrefix $RT_PREFIX_TRAFFIC_TO_DS_DB -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        Set-AzureRmRouteConfig -RouteTable $RT_SC_APP_BS -Name $RT_TRAFFIC_TO_DS_DMZ -AddressPrefix $RT_PREFIX_TRAFFIC_TO_DS_DMZ -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        Set-AzureRmRouteConfig -RouteTable $RT_SC_APP_BS -Name $RT_TRAFFIC_TO_IB_DB -AddressPrefix $RT_PREFIX_TRAFFIC_TO_IB_DB -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        Set-AzureRmRouteConfig -RouteTable $RT_SC_APP_BS -Name $RT_TRAFFIC_TO_IB_APP -AddressPrefix $RT_PREFIX_TRAFFIC_TO_IB_APP -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        Set-AzureRmRouteConfig -RouteTable $RT_SC_APP_BS -Name $RT_TRAFFIC_TO_SC_DB -AddressPrefix $RT_PREFIX_TRAFFIC_TO_SC_DB -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        #
        # Alteração de Rotas na RT-SC-DB-BS
        Set-AzureRmRouteConfig -RouteTable $RT_SC_DB_BS -Name $RT_Internet -AddressPrefix $RT_AddressPrefix_Internet -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        Set-AzureRmRouteConfig -RouteTable $RT_SC_DB_BS -Name $RT_TRAFFIC_TO_DS_APP -AddressPrefix $RT_PREFIX_TRAFFIC_TO_DS_APP -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        Set-AzureRmRouteConfig -RouteTable $RT_SC_DB_BS -Name $RT_TRAFFIC_TO_DS_DB -AddressPrefix $RT_PREFIX_TRAFFIC_TO_DS_DB -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        Set-AzureRmRouteConfig -RouteTable $RT_SC_DB_BS -Name $RT_TRAFFIC_TO_DS_DMZ -AddressPrefix $RT_PREFIX_TRAFFIC_TO_DS_DMZ -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        Set-AzureRmRouteConfig -RouteTable $RT_SC_DB_BS -Name $RT_TRAFFIC_TO_IB_APP -AddressPrefix $RT_PREFIX_TRAFFIC_TO_IB_APP -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        Set-AzureRmRouteConfig -RouteTable $RT_SC_DB_BS -Name $RT_TRAFFIC_TO_IB_DB -AddressPrefix $RT_PREFIX_TRAFFIC_TO_IB_DB -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        Set-AzureRmRouteConfig -RouteTable $RT_SC_DB_BS -Name $RT_TRAFFIC_TO_SC_APP -AddressPrefix $RT_PREFIX_TRAFFIC_TO_SC_APP -NextHopType VirtualAppliance -NextHopIpAddress $Firewall | Set-AzureRmRouteTable
        #########################################################################################################################
        #########################################################################################################################
        #

