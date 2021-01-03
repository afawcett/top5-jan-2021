/**
 .----------------. 
| .--------------. |
| |   _    _     | |
| |  | |  | |    | |
| |  | |__| |_   | |
| |  |____   _|  | |
| |      _| |_   | |
| |     |_____|  | |
| |              | |
| '--------------' |
 '----------------' 
 */

/**
 * Request Class
 * https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_class_System_Request.htm 
 * Event Logs - Apex Execution Event Types
 * https://developer.salesforce.com/docs/atlas.en-us.object_reference.meta/object_reference/sforce_api_objects_eventlogfile_apexexecution.htm 
 * Apex Logs - RequestIdentifier 
 * https://developer.salesforce.com/docs/atlas.en-us.object_reference.meta/object_reference/sforce_api_objects_apexlog.htm 
 */
public with sharing class Four {

    public static void demo() {
        Request reqInfo = Request.getCurrent();
        String currentRequestId = reqInfo.getRequestId();
        System.debug('Request Id is ' + currentRequestId);        
    }

    @AuraEnabled
    public static String addCustomMetadataRecord() {

        // Submit async request to add custom metadata record
        Metadata.DeployContainer container = new Metadata.DeployContainer();
        Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
        customMetadata.fullName = 'MetadataTypeName.MetadataRecordName';
        Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
        customField.field = 'customField__c';
        customField.value = 'New value';
        customMetadata.values.add(customField);
        container.addMetadata(customMetadata);
        SaveResultCallback callback = new SaveResultCallback();
        callback.correlationId = Request.getCurrent().getRequestId();
        Metadata.Operations.enqueueDeployment(container, callback);

        // Client can use this id to monitor for results
        return callback.correlationId;
    }

    public class SaveResultCallback implements Metadata.DeployCallback         
    {
        public String correlationId {get; private set;}
        
        public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {            
            // Leverage the correlationId to store resuls or send platform event
            // insert new CallbackResult__c(CorrelationId__c = correlationId);            
            // EventBus.publish(new CallbackEvent__c(CorrelationId__c = correlationId);
        }
    }    
}
