# Requirements
# * PowerShell 5.1 or newer.
# * Azure PowerShell module - https://docs.microsoft.com/en-us/powershell/azure
param (
    [Parameter(Mandatory = $true)]
    [guid]$SubscriptionId
)

# Environment Configuration
$ResourceGroupName = "learning-azure-event-hubs"
$ResourceLocation = "West US 2"

$EventHubsNamespaceName = "learning-azure-event-hubs"
$PartitionCount = 4
$EventHubs = @(
    "eventhub-01",
    "eventhub-02",
    "eventhub-03"
)
$ConsumerGroups = @(
    "consumergroup-01",
    "consumergroup-02",
    "consumergroup-03"
)

$StorageAccountName = "learningeventhubs"
$StorageContainerName = "checkpoints"

$AppServicePlanName = "learning-azure-event-hubs"
$WebApps = @(
    "laeh-producer-01",
    "laeh-producer-02",
    "laeh-producer-03",

    "laeh-consumer-01",
    "laeh-consumer-02",
    "laeh-consumer-03"
)

# Log in to Azure
Connect-AzAccount -Subscription "$SubscriptionId"

# Resource Group
New-AzResourceGroup -ResourceGroupName "$ResourceGroupName" -Location "$ResourceLocation"

# Event Hubs Namespace
# Tier:                Standard
# TU:                  1
New-AzEventHubNamespace -ResourceGroupName "$ResourceGroupName" -NamespaceName "$EventHubsNamespaceName" -Location "$ResourceLocation" -SkuName "Standard" -SkuCapacity 1

# Event Hubs / Event Hub Consumer Groups
# Partitions:          4 (2 is default, minimum)
# Retention:           1 (maximum for basic tier)
Foreach ($EventHub in $EventHubs)
{
    New-AzEventHub -ResourceGroupName "$ResourceGroupName" -NamespaceName "$EventHubsNamespaceName" -EventHubName "$EventHub" -PartitionCount $PartitionCount -MessageRetentionInDays 1

    Foreach ($ConsumerGroup in $ConsumerGroups)
    {
        New-AzEventHubConsumerGroup -ResourceGroupName "$ResourceGroupName" -NamespaceName "$EventHubsNamespaceName" -EventHubName "$EventHub" -ConsumerGroupName "$ConsumerGroup"
    }
}

# Storage Account
# SKU:                 Standard_LRS (includes performance tier and replication scope)
# Kind:                StorageV2
# Replication:         LRS
# Tier:                Hot
$storageAccount = New-AzStorageAccount -ResourceGroupName "$ResourceGroupName" -StorageAccountName "$StorageAccountName" -SkuName "Standard_LRS" -Location "$ResourceLocation" -Kind "StorageV2" -AccessTier "Hot" -EnableHttpsTrafficOnly $true

# Blob Storage Container (Event Hub Processor Checkpointing)
# Access:              Private
New-AzStorageContainer -Container "$StorageContainerName" -PublicAccess "Off" -Context $storageAccount.Context

# App Service Plan
New-AzAppServicePlan -ResourceGroupName "$ResourceGroupName" -Name "$AppServicePlanName" -Location "$ResourceLocation" -Tier "Free"

# Web Apps
Foreach ($WebApp in $WebApps)
{
    New-AzWebApp -ResourceGroupName "$ResourceGroupName" -Name "$WebApp" -Location "$ResourceLocation" -AppServicePlan "$AppServicePlanName"
}
