package com.function;

public class MessageBody {
    private String topic;
    private String subject;
    private String eventType;
    private String id;
    private Data data;
    private String dataVersion;
    private String metadataVersion;
    private String eventTime;

    public String getTopic() {
        return this.topic;
    }

    public void setTopic(String topic) {
        this.topic = topic;
    }

    public String getSubject() {
        return this.subject;
    }

    public void setSubject(String subject) {
        this.subject = subject;
    }

    public String getEventType() {
        return this.eventType;
    }

    public void setEventType(String eventType) {
        this.eventType = eventType;
    }

    public String getId() {
        return this.id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public Data getData() {
        return this.data;
    }

    public void setData(Data data) {
        this.data = data;
    }

    public String getDataVersion() {
        return this.dataVersion;
    }

    public void setDataVersion(String dataVersion) {
        this.dataVersion = dataVersion;
    }

    public String getMetadataVersion() {
        return this.metadataVersion;
    }

    public void setMetadataVersion(String metadataVersion) {
        this.metadataVersion = metadataVersion;
    }

    public String getEventTime() {
        return this.eventTime;
    }

    public void setEventTime(String eventTime) {
        this.eventTime = eventTime;
    }
}