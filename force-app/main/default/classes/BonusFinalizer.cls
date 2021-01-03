public class BonusFinalizer implements Finalizer {

    // Simple way to capture messages during execution
    public List<String> messages = new List<String>();

    public void execute(FinalizerContext ctx) {

        // How did the work complete?
        System.ParentJobResult result = ctx.getResult();
        switch on result {
            when SUCCESS {
                messages.add('Work done successfully');
            } when UNHANDLED_EXCEPTION {
                messages.add('Work failed');
                messages.add(ctx.getException().getMessage());
            }
        }

        // Send logged messages via a custom notifcation (max 750 chars)
        CustomNotificationType notificationType = [select Id, DeveloperName from CustomNotificationType where DeveloperName='SayHello'];
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle('Demo of Transaction Finalizer');
        notification.setBody(String.join(messages, ' - '));
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(UserInfo.getUserId());
        notification.send(new Set<String> { UserInfo.getUserId()} );            

        // You can also of course choose to log to a custom object (per docs)
        //  or even logging system via http callouts
        // ...
    }
}
