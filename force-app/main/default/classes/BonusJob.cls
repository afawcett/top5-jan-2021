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
