package com.function;

import com.microsoft.azure.functions.annotation.*;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.microsoft.azure.functions.*;

import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;

/**
 * Azure Functions with Azure Storage Queue trigger.
 */
public class QueueTriggerJava1 {
    private static final Logger logger = LoggerFactory.getLogger(QueueTriggerJava1.class);
    private static final ObjectMapper objectMapper = new ObjectMapper();

    private static final DependencyFactory dependencyFactory = new DependencyFactory();
    private int counter = 0;
    private final UUID instanceId = UUID.randomUUID(); // Unique ID for each instance


    /*public QueueTriggerJava1(DependencyFactory dependencyFactory) {
        this.dependencyFactory = dependencyFactory;
    }*/

    /**
     * This function will be invoked when a new message is received at the specified path. The message contents are provided as input to this function.
     */
    @FunctionName("QueueTriggerJava1")
    public void run(
        @QueueTrigger(name = "message", queueName = "egtestqueue", connection = "AzureWebJobsStorage") MessageBody message,
        final ExecutionContext context
    ) {
        context.getLogger().info("Message received");
        context.getLogger().info("Default Logger - Java Queue trigger function processed a message: " + message.getTopic());

        // Log counter
        context.getLogger().warning("Instance Id:  " + instanceId + " Counter: " + ++counter);

        // Use DependencyFactory to enrich function properties
        String enrichedProperties = DependencyFactory.enrichFunctionProperties();
        context.getLogger().warning(enrichedProperties);

        try {
            // Set MDC values
            MDC.put("Event Type", message.getEventType());
            MDC.put("Data API", message.getData().getApi());
            MDC.put("Storage Diagnostics Batch ID", message.getData().getStorageDiagnostics().getBatchId());

            // Create a JSON object for the log message
            ObjectNode logMessage = objectMapper.createObjectNode();
            logMessage.put("message", "JSON log - Java Queue trigger function processed a message");
            logMessage.put("topic", message.getTopic());
            logMessage.put("invocationId", context.getInvocationId());
            logMessage.put("parent_Id", context.getTraceContext().getTraceparent());
            logMessage.put("eventType", message.getEventType());
            logMessage.put("dataApi", message.getData().getApi());
            logMessage.put("storageDiagnosticsBatchId", message.getData().getStorageDiagnostics().getBatchId());
            // Add additional context information
            logMessage.put("operationName", context.getFunctionName());
            logMessage.put("logLevel", context.getLogger().getLevel().toString());

            // Log the JSON-formatted message
            logger.info(logMessage.toString());

            logger.info("Java Queue trigger function processed a message: " + message.getTopic());
            logger.atInfo()
                .setMessage("Event Details")
                .addKeyValue("Event Type", message.getEventType())
                .addKeyValue("Data API", message.getData().getApi())
                .addKeyValue("Storage Diagnostics Batch ID", message.getData().getStorageDiagnostics().getBatchId())
                .log();
        } catch (Exception e) {
            logger.error("An error occurred");
            context.getLogger().severe("An error occurred while processing the message: " + e.getMessage());
        } finally {
            MDC.clear();
            context.getLogger().info("Message processed successfully");
        }
    }
}