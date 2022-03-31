//Authors: Thanvi Ponamma, Sanjana Nadig
//Date: 8/3/2021
//To notify the warehouse about the orders that are not shipped

public class JFWNotifyForNotShippedOrders_Apex {
    
    //get all comet orders with shipping method other than "Overnight"
    public void getCometOrdersForNotification(){
        //to hold the comet orders which are in "InProcess" state
        List<OrderDestination__c> cometOrders= [SELECT Id,TrackingNos__c,Alert_User_For_Not_Shipped_Orders__c,
                                                (SELECT Id,Field,CreatedDate,NewValue,OldValue FROM Histories WHERE Field='Comet_Order_Status__c')
                                                FROM OrderDestination__c
                                                WHERE (NOT Shipping_Method__r.Shipping_Method_Name__c LIKE '%overnight%')
                                                AND Account_Name__c LIKE '%JFW%'
                                                AND OrdStatus__c!='Shipped'
                                                AND OrdStatus__c!='Open'
                                                AND OrdStatus__c!=null
                                                AND Order__r.Program__c=null
                                                AND WarehouseTransactionNo__c!=null
                                                AND OrdStatus__c!='Closed'
                                                AND OrdStatus__c!='Cancelled'
                                                AND CreatedDate > 2021-01-01T00:00:00Z
                                                AND Alert_User_For_Not_Shipped_Orders__c=false
                                                LIMIT 10];
        System.debug(cometOrders);
        //to hold the comet orders that are to be updated
        List<OrderDestination__c> cometOrdersToBeUpdated=new List<OrderDestination__c> ();
        //for each comet order
        for(OrderDestination__c cometOrder : cometOrders)
        {
            //check if the tracking number is empty. If yes,
            if(String.isBlank(cometOrder.TrackingNos__c))
                //for each comet order get the comet order history
                for(OrderDestination__History history : cometOrder.Histories)
            {
                //check if the old value in the history is "Send to comet" and the new value is "This order has been submitted to Comet". If yes,
                if(history.OldValue=='Send to Comet' && history.NewValue=='This order has been submitted to Comet')
                {   //get the date and time of the history
                    Long dt1Long = history.CreatedDate.getTime();
                    //get the current time
                    Long dt2Long = System.now().getTime();
                    //calculate the duration in milliseconds
                    Long milliseconds = dt2Long - dt1Long;
                    //calculate the duration in seconds
                    Long seconds = milliseconds / 1000;
                    //calculate the duration in minutes
                    Long minutes = seconds / 60;
                    //calculate the duration in hours
                    Long hours = minutes / 60;
                    //calculate the duration in days
                    Long days = hours / 24;
                    //check if the hours is greater than 36. If yes,
                    if(hours>36)
                        //set the field Alert_User_For_Not_Shipped_Orders__c of orderDestination as true
                        cometOrder.Alert_User_For_Not_Shipped_Orders__c=true;
                }
            }
            //if Alert_User_For_Not_Shipped_Orders__c is true,
            if(cometOrder.Alert_User_For_Not_Shipped_Orders__c)
                //add all comet orders to the list of type OrderDestination__c
                cometOrdersToBeUpdated.add(cometOrder);
        }
        //update the comet orders.
        update cometOrdersToBeUpdated;
    }
    
    //get all comet orders with shipping method "Overnight"
    public void getCometOrdersForOverNightShipmentNotification(){
         List<OrderDestination__c> cometOrders = new  List<OrderDestination__c>();
        if(Test.isRunningTest()){
            //to hold the comet orders which are in "InProcess" state
            cometOrders= [SELECT Id,TrackingNos__c,Alert_User_For_Not_Shipped_Orders__c,
                                                    (SELECT Id,Field,CreatedDate,NewValue,OldValue FROM Histories WHERE Field='Comet_Order_Status__c')
                                                    FROM OrderDestination__c
                                                    WHERE
                                                    Account_Name__c LIKE '%JFW%'
                                                    AND OrdStatus__c!='Shipped'
                                                    AND OrdStatus__c!='Open'
                                                    AND OrdStatus__c!=null
                                                    AND Order__r.Program__c=null
                                                    AND WarehouseTransactionNo__c!=null
                                                    AND OrdStatus__c!='Closed'
                                                    AND OrdStatus__c!='Cancelled'
                                                    AND CreatedDate > 2021-01-01T00:00:00Z
                                                    AND Alert_User_For_Not_Shipped_Orders__c=false
                                                    LIMIT 10];
            System.debug(cometOrders);
            //to hold the comet orders that are to be updated
            
        }
        else {
            //to hold the comet orders which are in "InProcess" state
            cometOrders= [SELECT Id,TrackingNos__c,Alert_User_For_Not_Shipped_Orders__c,
                                                    (SELECT Id,Field,CreatedDate,NewValue,OldValue FROM Histories WHERE Field='Comet_Order_Status__c')
                                                    FROM OrderDestination__c
                                                    WHERE Shipping_Method__r.Shipping_Method_Name__c LIKE '%overnight%'
                                                    AND Account_Name__c LIKE '%JFW%'
                                                    AND OrdStatus__c!='Shipped'
                                                    AND OrdStatus__c!='Open'
                                                    AND OrdStatus__c!=null
                                                    AND Order__r.Program__c=null
                                                    AND WarehouseTransactionNo__c!=null
                                                    AND OrdStatus__c!='Closed'
                                                    AND OrdStatus__c!='Cancelled'
                                                    AND CreatedDate > 2021-01-01T00:00:00Z
                                                    AND Alert_User_For_Not_Shipped_Orders__c=false
                                                    LIMIT 10];
            System.debug(cometOrders);
        }
        //to hold the comet orders that are to be updated
        List<OrderDestination__c> cometOrdersToBeUpdated=new List<OrderDestination__c> ();
        //for each comet order
        for(OrderDestination__c cometOrder : cometOrders)
        {
            //check if the tracking number is empty. If yes,
            if(String.isBlank(cometOrder.TrackingNos__c))
                //for each comet order get the comet order history
                for(OrderDestination__History history : cometOrder.Histories)
            {
                //check if the old value in the history is "Send to comet" and the new value is "This order has been submitted to Comet". If yes,
                if(history.OldValue=='Send to Comet' && history.NewValue=='This order has been submitted to Comet')
                {   //get the date and time of the history
                    Long dt1Long = history.CreatedDate.getTime();
                    //get the current time
                    Long dt2Long = System.now().getTime();
                    //calculate the duration in milliseconds
                    Long milliseconds = dt2Long - dt1Long;
                    //calculate the duration in seconds
                    Long seconds = milliseconds / 1000;
                    //calculate the duration in minutes
                    Long minutes = seconds / 60;
                    //check if the minutes is greater than 30. If yes,
                    System.debug(minutes);
                    if(minutes>30)
                        //set the field Alert_User_For_Not_Shipped_Orders__c of orderDestination as true
                        cometOrder.Alert_User_For_Not_Shipped_Orders__c=true;
                }
            }
            //if Alert_User_For_Not_Shipped_Orders__c is true,
            if(cometOrder.Alert_User_For_Not_Shipped_Orders__c)
                //add all comet orders to the list of type OrderDestination__c
                cometOrdersToBeUpdated.add(cometOrder);
        }
        //update the comet orders.
        update cometOrdersToBeUpdated;
        
        
    }
    
}