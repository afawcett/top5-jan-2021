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

@IsTest
private class ThreeTest {

    @IsTest
    private static void givenBulkdAPIContextThenConfirmMarkedAsPostProcess() {
        // Given 
        Three.Context = System.Quiddity.BULK_API;
        Order order = new Order();
        List<Order> orders = new List<Order>();
        orders.add(order);
        // When
        Three.processNewOrders(orders); 
        // Then        
        System.assert(true, order.PostProcess__c);
    }
}
