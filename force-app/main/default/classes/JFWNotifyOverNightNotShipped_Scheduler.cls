//Authors: Thanvi Ponamma, Sanjana Nadig
//Date: 8/3/2021

//To notify the warehouse about the orders that are not shipped for more than 12 which needs to be shipped over night
global class JFWNotifyOverNightNotShipped_Scheduler implements Schedulable {
    global void execute(SchedulableContext c)
    {
        JFWNotifyForNotShippedOrders_Apex jfwNotifyForNotShippedOrders_Apex = new JFWNotifyForNotShippedOrders_Apex();
        //to invoke the apex class to set Alert_User_For_Not_Shipped_Orders__c to true/fasle based on the conditions. 
        jfwNotifyForNotShippedOrders_Apex.getCometOrdersForOverNightShipmentNotification(); // to get the comet orders whose shipping method needs to shipped overnight.
        
    }
}