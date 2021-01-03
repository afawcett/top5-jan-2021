/**
 .----------------. 
| .--------------. |
| |    _____     | |
| |   / ___ `.   | |
| |  |_/___) |   | |
| |   .'____.'   | |
| |  / /____     | |
| |  |_______|   | |
| |              | |
| '--------------' |
 '----------------' 
 */

/**
 * Manage Your Notifications with Notification Builder
 * https://help.salesforce.com/articleView?id=notif_builder.htm&type=5
 * CustomNotification Class
 * https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_class_Messaging_CustomNotification.htm
 * Getting your users attention with Custom Notifications
 * https://andyinthecloud.com/2019/06/30/getting-your-users-attention-with-custom-notifications/
 */
public with sharing class Two {

    // Two.demo();
    public static void demo() {

        // Create an Order
        Account newAccount = new Account();
        newAccount.Name = 'New Account';
        insert newAccount;
        Order newOrder = new Order();
        newOrder.AccountId = newAccount.Id;
        newOrder.Status = 'Draft';
        newOrder.EffectiveDate = System.today().addDays(3);
        insert newOrder;
        newOrder = [select OrderNumber from Order where Id = :newOrder.Id ];

        // Get the Id for our custom notification type
        CustomNotificationType notificationType = 
            [SELECT Id, DeveloperName 
             FROM CustomNotificationType 
             WHERE DeveloperName='SayHello'];
        
        // Create a new custom notification
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle('Amazing new order ' + newOrder.OrderNumber);
        notification.setBody('Check out this new order that has just come in!');
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(newOrder.Id);
        notification.send(new Set<String> { UserInfo.getUserId()} );
    }
}
