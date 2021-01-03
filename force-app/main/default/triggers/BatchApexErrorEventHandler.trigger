/**
 .----------------. 
| .--------------. |
| |   _______    | |
| |  |  _____|   | |
| |  | |____     | |
| |  '_.____''.  | |
| |  | \____) |  | |
| |   \______.'  | |
| |              | |
| '--------------' |
 '----------------' 
 */

/**
 * Firing Platform Events from Batch Apex
 * https://developer.salesforce.com/docs/atlas.en-us.228.0.apexcode.meta/apexcode/apex_batch_platformevents.htm
 * BatchApexErrorEvent
 * https://developer.salesforce.com/docs/atlas.en-us.platform_events.meta/platform_events/sforce_api_objects_batchapexerrorevent.htm
 * Building a Batch Retry Framework With BatchApexErrorEvent
 * https://developer.salesforce.com/blogs/2019/01/building-a-batch-retry-framework-with-batchapexerrorevent.html 
 */

trigger BatchApexErrorEventHandler on BatchApexErrorEvent (after insert) {

    // Determine which job raises these errors
    Set<Id> asyncApexJobIds = new Set<Id>();
    for(BatchApexErrorEvent evt:Trigger.new){
        asyncApexJobIds.add(evt.AsyncApexJobId);
    }    
    Map<Id,AsyncApexJob> jobs = new Map<Id,AsyncApexJob>(
        [select id, ApexClass.Name from AsyncApexJob where Id in :asyncApexJobIds]);
    
    // Record errors on the associated source object records
    List<Order> records = new List<Order>();
    for(BatchApexErrorEvent evt:Trigger.new){
        if(jobs.get(evt.AsyncApexJobId).ApexClass.Name == 'Five'){
            for (String item : evt.JobScope.split(',')) {
                Order a = new Order(
                    Id = (Id)item,
                    JobExceptionType__c = evt.ExceptionType,
                    JobExceptionMessage__c = evt.Message
                );
                records.add(a);
            }
        }
    }
    update records;
}