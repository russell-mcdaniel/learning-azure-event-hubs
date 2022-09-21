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
$EventHubsSkuName = "Basic" # Basic | Standard
$EventHubsSkuCapacity = 1
$EventHubPartitionCount = 4
$EventHubMessageRetentionInDays = 1
$EventHubs = @(
    "event-hub-01",
    "event-hub-02",
    "event-hub-03"
)
$ConsumerGroups = @(
    "eh-01-group-a",
    "eh-01-group-b",
    "eh-02-group-a",
    "eh-02-group-b",
    "eh-03-group-a",
    "eh-03-group-b"
)

$StorageAccountName = "learningeventhubs"
$StorageContainerName = "checkpoints"

$AppServicePlanName = "learning-azure-event-hubs"
$WebApps = @(
    "laeh-producer-01",
    "laeh-producer-02",
    "laeh-producer-03",

    "laeh-consumer-01-a1",
    "laeh-consumer-01-a2",
    "laeh-consumer-01-b1",
    "laeh-consumer-01-b2",
    
    "laeh-consumer-02-a1",
    "laeh-consumer-02-a2",
    "laeh-consumer-02-b1",
    "laeh-consumer-02-b2",

    "laeh-consumer-03-a1",
    "laeh-consumer-03-a2",
    "laeh-consumer-03-b1",
    "laeh-consumer-03-b2"
)

# Log in to Azure
Connect-AzAccount -Subscription "$SubscriptionId"

# Resource Group
New-AzResourceGroup -ResourceGroupName "$ResourceGroupName" -Location "$ResourceLocation"

# Event Hubs Namespace
New-AzEventHubNamespace -ResourceGroupName "$ResourceGroupName" -NamespaceName "$EventHubsNamespaceName" -Location "$ResourceLocation" -SkuName "$EventHubsSkuName" -SkuCapacity $EventHubsSkuCapacity

# Event Hubs / Event Hub Consumer Groups
# Partitions:          4 (2 is default, minimum)
# Retention:           1 (maximum for basic tier)
Foreach ($EventHub in $EventHubs)
{
    New-AzEventHub -ResourceGroupName "$ResourceGroupName" -NamespaceName "$EventHubsNamespaceName" -EventHubName "$EventHub" -PartitionCount $EventHubPartitionCount -MessageRetentionInDays $EventHubMessageRetentionInDays

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
