/**
 * 
  ____                        
 |  _ \                       
 | |_) | ___  _ __  _   _ ___ 
 |  _ < / _ \| '_ \| | | / __|
 | |_) | (_) | | | | |_| \__ \
 |____/ \___/|_| |_|\__,_|___/                                                        
 */

/**
 * Transaction Finalizers Pilot
 * https://developer.salesforce.com/docs/atlas.en-us.228.0.apexcode.meta/apexcode/apex_transaction_finalizers.htm
 * Implementing Promises with Transaction Finalizers
 * https://developer.salesforce.com/blogs/2020/01/learn-moar-in-spring-20-implementing-promises-with-transaction-finalizers.html
 */
public class BonusJob implements Queueable {

    // Simple way to increase work for done by this Queueable demo
    public Integer workLoad;

    public void execute(QueueableContext ctx) {
        // Attach a finalizer
        BonusFinalizer f = new BonusFinalizer(); 
        System.attachFinalizer(f);
        // Simple log capture will be emitted by finalizer
        f.messages.add('Started some work');
        // Do some work (not bulkified to demo handling limit exceptions)
        f.messages.add('Querying orders');
        for(Integer idx=0; idx<workLoad; idx++) {
            List<Order> orders = [select Id from Order limit 1];
        }
    }    
}
