package com.function;

public class Data {
    private String api;
    private String clientRequestId;
    private String requestId;
    private String eTag;
    private String contentType;
    private int contentLength;
    private String blobType;
    private String url;
    private String sequencer;
    private StorageDiagnostics storageDiagnostics;

    public String getApi() {
        return this.api;
    }

    public void setApi(String api) {
        this.api = api;
    }

    public String getClientRequestId() {
        return this.clientRequestId;
    }

    public void setClientRequestId(String clientRequestId) {
        this.clientRequestId = clientRequestId;
    }

    public String getRequestId() {
        return this.requestId;
    }

    public void setRequestId(String requestId) {
        this.requestId = requestId;
    }

    public String getETag() {
        return this.eTag;
    }

    public void setETag(String eTag) {
        this.eTag = eTag;
    }

    public String getContentType() {
        return this.contentType;
    }

    public void setContentType(String contentType) {
        this.contentType = contentType;
    }

    public int getContentLength() {
        return this.contentLength;
    }

    public void setContentLength(int contentLength) {
        this.contentLength = contentLength;
    }

    public String getBlobType() {
        return this.blobType;
    }

    public void setBlobType(String blobType) {
        this.blobType = blobType;
    }

    public String getUrl() {
        return this.url;
    }

    public void setUrl(String url) {
        this.url = url;
    }

    public String getSequencer() {
        return this.sequencer;
    }

    public void setSequencer(String sequencer) {
        this.sequencer = sequencer;
    }

    public StorageDiagnostics getStorageDiagnostics() {
        return this.storageDiagnostics;
    }

    public void setStorageDiagnostics(StorageDiagnostics storageDiagnostics) {
        this.storageDiagnostics = storageDiagnostics;
    }
}
