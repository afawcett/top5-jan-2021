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
public with sharing class Bonus {

    // Bonus.demo();
    public static void demo() {
        // Will complete
        BonusJob job1 = new BonusJob(); 
        job1.workLoad = 10;
        System.enqueueJob(job1);
        // Will fail
        BonusJob job2 = new BonusJob(); 
        job2.workLoad = 201;
        System.enqueueJob(job2);
    }
}
