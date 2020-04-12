# Requirements:
# * PowerShell 5.1 or newer.
# * Azure PowerShell module - https://docs.microsoft.com/en-us/powershell/azure

# Log in to Azure
#Connect-AzAccount

# Resource Group
# Name:                learning-azure-event-hubs
# Location:            West US 2
New-AzResourceGroup –Name learning-azure-event-hubs –Location "West US 2"

# Event Hub Namespace
# NamespaceName:       learning-azure-event-hubs
# Location:            West US 2
# Tier:                Basic
# TU:                  1
New-AzEventHubNamespace -ResourceGroupName learning-azure-event-hubs -NamespaceName learning-azure-event-hubs -Location "West US 2" -SkuName Basic -SkuCapacity 1

# Event Hub
# Name:                hub-1
# NamespaceName:       learning-azure-event-hubs
# Partitions:          4 (2 is default, minimum)
# Retention:           1 (maximum for basic tier)
New-AzEventHub -ResourceGroupName learning-azure-event-hubs -NamespaceName learning-azure-event-hubs -EventHubName hub-1 -PartitionCount 4 -MessageRetentionInDays 1

# Storage Account
# Name:                learningeventhubs
# Location:            westus2 (West US 2)
# Performance:         Standard
# Kind:                StorageV2
# Replication:         LRS
# Tier:                Hot


# Blob Storage Container (Event Hub Processor Checkpointing)
# Name:                event-hubs-checkpoints
# Access:              Private
