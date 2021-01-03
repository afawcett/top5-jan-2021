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

public with sharing class Five
    implements Database.Batchable<SObject>, Database.RaisesPlatformEvents {
        
    public List<Order> start(Database.BatchableContext ctx) {
        return [select Id from Order
                where EffectiveDate = THIS_WEEK and Invoiced__c != true
                order by Name];
    }
    
    public void execute(Database.BatchableContext ctx, List<SObject> scope) {
        // Invoice generation from given orders
        List<Invoice__c> invoices = new List<Invoice__c>();
        List<Order> orders =
            [select Id, TotalAmount, Name from Order
                where Id in :scope and Invoiced__c != true];
        for(Order order : orders) {
            produceSomeExceptions(order.Name, order.EffectiveDate);
            Invoice__c invoice = new Invoice__c();
            invoice.DueDate__c = System.today().addDays(30);
            invoice.Paid__c = false;
            invoice.Order__c = order.Id;
            invoice.Amount__c = order.TotalAmount;
            invoices.add(invoice);
            order.Invoiced__c = true;
        }
        insert invoices;
        update orders;
    }
            
    public void finish(Database.BatchableContext ctx) { }

    // Produce some exceptions, some catchable, some not...
    private void produceSomeExceptions(String orderName, Date orderDate) {
        if(orderDate != System.today()) { return; } 
        switch on orderName {
           when 'Ref:100' {
               // Standard exception
               throw new InvoiceGenerationException('Order Ref:100 is invalid.');
           }
           when 'Ref:300' {
               // Divide by zero!
               Integer newAmount = 20 / 0;
           }
           when 'Ref:500' {
                // Limits exception
                for(Integer idx=0; idx<201; idx++) {
                    Order order = [select Id from Order limit 1];
                }
           }
        }
    }

    public class InvoiceGenerationException extends Exception {}     
}
