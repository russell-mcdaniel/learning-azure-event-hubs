# Learning Azure Storage

A learning project for Azure Storage.

This project is intended to:

* Evaluate Azure Blob Storage.
* Evaluate Azure Event Hubs (for Kafka)
* Demonstrate reliable message processing.

The components of this project include:

* Message producer.
* Message topic.
* Message consumer.
* Message store.

The producer will create messages and write them to the message topic.

The consumer will read the messages and write them to the store in a reliable manner. Determining the design required to accomplish this is a key objective of this project.