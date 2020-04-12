using System;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Azure.Messaging.EventHubs;
using Azure.Messaging.EventHubs.Producer;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace MessageProducer
{
    internal class MessageService : BackgroundService
    {
        private readonly IConfiguration Configuration;

        private readonly ILogger Logger;

        public MessageService(IConfiguration configuration, ILogger<MessageService> logger) : base()
        {
            Configuration = configuration;
            Logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            var connectionString = Configuration["EventHubs:ConnectionString"];
            var eventHubName = Configuration["EventHubs:EventHub"];
            var message = "Hello, world.";

            while (!stoppingToken.IsCancellationRequested)
            {
                await using (var client = new EventHubProducerClient(connectionString, eventHubName))
                {
                    using var batch = await client.CreateBatchAsync(stoppingToken);

                    var data = new EventData(Encoding.UTF8.GetBytes(message));

                    batch.TryAdd(data);

                    await client.SendAsync(batch, stoppingToken);

                    Logger.LogDebug($"Message sent ({batch.SizeInBytes} bytes):\n\t{message}");
                }

                await Task.Delay(1000, stoppingToken);
            }
        }
    }
}
