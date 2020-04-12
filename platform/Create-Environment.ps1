# Requirements:
# * PowerShell 5.1 or newer.
# * Azure PowerShell module - https://docs.microsoft.com/en-us/powershell/azure

# Log in to Azure
#Connect-AzAccount

# Resource Group
# Name:                learning-azure-storage
# Location:            westus2 (West US 2)
#New-AzResourceGroup –Name learning-azure-storage –Location westus2

# Event Hub Namespace
# Name:                learning-azure-storage
# Tier:                Basic
# Location:            westus2 (West US 2)
# TU:                  1
#New-AzEventHubNamespace -ResourceGroupName learning-azure-storage -NamespaceName learning-azure-storage -Location westus2 -SkuName Basic -SkuCapacity 1

# Event Hub
# Name:                hub-1
# Partitions:          4 (2 is default, minimum)
#New-AzEventHub -ResourceGroupName learning-azure-storage -NamespaceName learning-azure-storage -EventHubName hub-1 -PartitionCount 4 -MessageRetentionInDays 1

# Blob Storage Account
# Name:                learningeventhubs (learningazurestorage was taken)
# Location:            westus2 (West US 2)
# Performance:         Standard
# Kind:                StorageV2
# Replication:         LRS
# Tier:                Hot

# Blob Storage Container (Event Hub Processor Checkpointing)
# Name:                event-hubs-checkpoints
# Access:              Private
