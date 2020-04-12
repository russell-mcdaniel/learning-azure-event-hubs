# Requirements
# * PowerShell 5.1 or newer.
# * Azure PowerShell module - https://docs.microsoft.com/en-us/powershell/azure

# Log in to Azure
#Connect-AzAccount

$resourceGroupName = "learning-azure-event-hubs"
$resourceLocation = "West US 2"
$eventHubsNamespaceName = "learning-azure-event-hubs"
$storageAccountName = "learningeventhubs"
$storageContainerName = "event-hubs-checkpoints"

# Resource Group
New-AzResourceGroup -ResourceGroupName $resourceGroupName –Location $resourceLocation

# Event Hub Namespace
# Tier:                Basic
# TU:                  1
New-AzEventHubNamespace -ResourceGroupName $resourceGroupName -NamespaceName $eventHubsNamespaceName -Location $resourceLocation -SkuName Basic -SkuCapacity 1

# Event Hub
# Partitions:          4 (2 is default, minimum)
# Retention:           1 (maximum for basic tier)
New-AzEventHub -ResourceGroupName $resourceGroupName -NamespaceName $eventHubsNamespaceName -EventHubName hub-1 -PartitionCount 4 -MessageRetentionInDays 1

# Storage Account
# SKU:                 Standard_LRS (includes performance tier and replication scope)
# Kind:                StorageV2
# Replication:         LRS
# Tier:                Hot
$storageAccount = New-AzStorageAccount -ResourceGroupName $resourceGroupName -StorageAccountName $storageAccountName -SkuName Standard_LRS -Location $resourceLocation -Kind StorageV2 -AccessTier Hot -EnableHttpsTrafficOnly $true
$storageContext = $storageAccount.Context

# Blob Storage Container (Event Hub Processor Checkpointing)
# Access:              Private
New-AzStorageContainer -Container $storageContainerName -PublicAccess Off -Context $storageContext
