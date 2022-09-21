# Learning Azure Event Hubs

A learning project for Azure Event Hubs.

The components of this project include:

* Message producer.
* Message consumer.
* Azure Event Hubs event hubs.
* Azure Storage blob container (for event hub processor checkpointing).

Controllable parameters:

* Run time.
* Message count.
* Message rate (per second). Can be fractional.
* Message size. Constant or variable. 1, 2, 4, 8, or 16 KB.
* Batch size (messages per batch).
