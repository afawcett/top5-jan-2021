/**
 .----------------. 
| .--------------. |
| |    ______    | |
| |   / ____ `.  | |
| |   `'  __) |  | |
| |   _  |__ '.  | |
| |  | \____) |  | |
| |   \______.'  | |
| |              | |
| '--------------' |
 '----------------' 
 */

/**
 * Request Class
 * https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_class_System_Request.htm 
 **/
public with sharing class Three {

    // Three.demo();
    public static void demo() {
        Request reqInfo = Request.getCurrent();
        System.Quiddity quiddity = reqInfo.getQuiddity();
        System.debug('Quiddity is ' + quiddity);
    }

    /**
     * Lets assume this is called from an Apex Trigger after insert ...
     */
    public static void processNewOrders(List<Order> orders) {
        // Set various field defaults
        OrderProcessor.setFieldDefaults(orders);
        // Update external order management system
        OrderProcessor.updateExternalOrderManagement(orders);
        // Generate invoices for applicable orders
        OrderProcessor.generateInvoices(orders);
    }

    /**
     * Defines key order processing logic and enables customization
     */
    public abstract class OrderProcessing 
    {
        public abstract void setFieldDefaults(List<Order> orders);
        public abstract void generateInvoices(List<Order> orders);
        public abstract void updateExternalOrderManagement(List<Order> orders);
    }

    /**
     * Base processing with option to override if needed
     */
    public virtual class BaseOrderProcessing extends OrderProcessing
    {
        public virtual override void setFieldDefaults(List<Order> orders) {
            for(Order order : orders) {
                order.EffectiveDate = System.today();
                order.EndDate = System.today().addMonths(2);
            }
        }

        public virtual override void generateInvoices(List<Order> orders) {
            List<Invoice__c> invoices = new List<Invoice__c>();
            for(Order order : orders) {
                Invoice__c invoice = new Invoice__c();
                invoice.DueDate__c = System.today().addDays(30);
                invoice.Paid__c = false;
                invoice.Order__c = order.Id;
                invoice.Amount__c = order.TotalAmount;
                invoices.add(invoice);
                order.Invoiced__c = true;
            }
            insert invoices;    
        }

        public virtual override void updateExternalOrderManagement(List<Order> orders) {
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:oms/updateOrdersWithSFID');
            req.setMethod('POST');
            req.setBody(JSON.serialize(orders));
            HttpResponse res = h.send(req);
            String response = res.getBody();
        }
    }

    /**
     * To processing lean in Bulk API operations records are marked for post processing
     */
    public class BulkAPIOrderProcessing extends BaseOrderProcessing
    {
        public override void generateInvoices(List<Order> orders) {
            for(Order order : orders) {
                order.PostProcess__c = true;
            }
        }
        public override void updateExternalOrderManagement(List<Order> orders) { 
            for(Order order : orders) {
                order.PostProcess__c = true;
            }
        }
    }

    /**
     * Orders are filtered for post processing and callouts are made via async
     */
    public class TriggerOrderProcessing extends BaseOrderProcessing
    {
        public override void generateInvoices(List<Order> orders) {
            List<Order> ordersToProcess = new List<Order>();
            for(Order order : orders) {
                if(order.IsReductionOrder) {
                    order.PostProcess__c = true;                                        
                } else {
                    ordersToProcess.add(order);
                }
            }
            super.generateInvoices(ordersToProcess);
        }

        public override void updateExternalOrderManagement(List<Order> orders) {
            UpdateExternalOMSJob job = new UpdateExternalOMSJob();
            job.orders = orders;
            System.enqueueJob(job);
        }
    }

    @TestVisible
    private static System.Quiddity Context;
    private static OrderProcessing RequestOrderProcessor;
    private static final OrderProcessing OrderProcessor { 
        get { 
            if(Context==null) {
                Context = Request.getCurrent().getQuiddity();
            }
            if(RequestOrderProcessor==null) {
                switch on Context  {
                    when SYNCHRONOUS {
                        RequestOrderProcessor = new TriggerOrderProcessing();
                    } when BULK_API {
                        RequestOrderProcessor = new BulkAPIOrderProcessing();    
                    } when else {
                        RequestOrderProcessor = new BaseOrderProcessing();
                    }
                }        
            }
            return RequestOrderProcessor;
        }
    }

    public class UpdateExternalOMSJob implements Queueable {
        public List<Order> orders;
        public void execute(QueueableContext context) {
            new BaseOrderProcessing().updateExternalOrderManagement(orders);
        }
    }
}
