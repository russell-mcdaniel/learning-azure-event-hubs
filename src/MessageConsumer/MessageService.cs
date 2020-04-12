using System;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Azure.Messaging.EventHubs;
using Azure.Messaging.EventHubs.Consumer;
using Azure.Messaging.EventHubs.Processor;
using Azure.Storage.Blobs;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace MessageConsumer
{
    public class MessageService : BackgroundService
    {
        private readonly IConfiguration Configuration;

        private readonly ILogger Logger;

        private readonly long EventsProcessedCheckpointInterval;

        private long EventsProcessed;

        public MessageService(IConfiguration configuration, ILogger<MessageService> logger) : base()
        {
            Configuration = configuration;
            Logger = logger;

            EventsProcessedCheckpointInterval = long.Parse(Configuration["EventHubs:EventsProcessedCheckpointInterval"]);
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            var storageConnectionString = Configuration["Storage:ConnectionString"];
            var storageContainer = Configuration["Storage:Container"];

            var storageClient = new BlobContainerClient(storageConnectionString, storageContainer);

            var eventHubConnectionString = Configuration["EventHubs:ConnectionString"];
            var eventHubName = Configuration["EventHubs:EventHub"];
            var eventHubConsumerGroupName = EventHubConsumerClient.DefaultConsumerGroupName; // Configuration["EventHubs:ConsumerGroup"];

            var processor = new EventProcessorClient(storageClient, eventHubConsumerGroupName, eventHubConnectionString, eventHubName);

            processor.ProcessEventAsync += ProcessEventHandler;
            processor.ProcessErrorAsync += ProcessErrorHandler;

            EventsProcessed = 0;

            await processor.StartProcessingAsync();

            try
            {
                while (!stoppingToken.IsCancellationRequested)
                {
                    await Task.Delay(1000);
                }

                await processor.StopProcessingAsync();
            }
            finally
            {
                processor.ProcessEventAsync -= ProcessEventHandler;
                processor.ProcessErrorAsync -= ProcessErrorHandler;
            }
        }

        private async Task ProcessEventHandler(ProcessEventArgs e)
        {
            var partitionId = e.Partition.PartitionId;
            var sequenceNumber = e.Data.SequenceNumber;
            var offset = e.Data.Offset;
            var message = Encoding.UTF8.GetString(e.Data.Body.ToArray());

            Logger.LogDebug($"Received message on partition {partitionId} at offset {offset} (sequence {sequenceNumber}):\n\t{message}");

            EventsProcessed++;

            if (EventsProcessed % EventsProcessedCheckpointInterval == 0)
            {
                await e.UpdateCheckpointAsync();

                EventsProcessed = 0;

                Logger.LogDebug($"Checkpoint.");
            }
        }

        private Task ProcessErrorHandler(ProcessErrorEventArgs e)
        {
            var partitionId = e.PartitionId;
            var operation = e.Operation;

            Logger.LogError(e.Exception, $"Encountered an error during operation {operation} on partition {partitionId}.");

            return Task.CompletedTask;
        }
    }
}
