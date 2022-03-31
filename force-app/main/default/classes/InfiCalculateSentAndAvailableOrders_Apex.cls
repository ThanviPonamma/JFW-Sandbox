// <!-- Authors:Sanjana    Date:09-11-2021-->
//Aim: To calculate the count of sent and remaining orders of the available pos items given by the actor InfiniumWaveOrders_Apex.loadAvailableItems() 
//and give the availablePosItems, sentPosItemOrders and remainingPosItemOrders values to the wrapper class InfiniumItemsWithCometOrderCount_Wrapper
public class InfiCalculateSentAndAvailableOrders_Apex 
{
    
    //Aim:To calculate the size of sent and remaining orders for the available pos items and send the values to the  available pos items 
    //and send the values to the InfiniumAvailableItesmWithCometOrderCount_Wrapper class.
    @AuraEnabled(cacheable=true)
    public static List<InfiniumItemsWithCometOrderCount_Wrapper> calculateSentAndRemainingOrdersForPosItem(List<POS_Item__c> availablePosItems, String selectedProgramId)
    {
        
        system.debug('selectedProgramId'+selectedProgramId);
        system.debug('availablePosItems'+availablePosItems);
        
        //Declaration of list of wrapper class to hold the list of Avaliable items with its Sent order and remaining order Count
        List<InfiniumItemsWithCometOrderCount_Wrapper> InfiniumAvailableItemsWithCometOrderCountList = new List<InfiniumItemsWithCometOrderCount_Wrapper>();
        
        //For each available items , do the below steps mentioned
        for(POS_Item__c availablePosItem : availablePosItems)
        {
             //Declaration Of variable to hold Sent and Remaining Order Destination Items and declaration of the wrapper class
             list<OrderDestinationItem__c> sentOrderList = new list<OrderDestinationItem__c>();
             list<OrderDestinationItem__c> remainingOrderList = new list<OrderDestinationItem__c>();
             InfiniumItemsWithCometOrderCount_Wrapper InfiniumAvailableItemWithCometOrderCount = new InfiniumItemsWithCometOrderCount_Wrapper();
            

            //Step 1: To Get the list of Order Destination items for the program(Program_1) and for the available item and stored in Variable3(programOrderDestinationItems).
        
            //list of Order Destination items include (Sent_To_Warehouse__c, Wave_Order_Number__c, Quantity__c, Ready_To_Be_Sent__c,
            //Warehouse_Transaction_Number__c, On_Hold__c,Order_Destination_Item_Status__c)
            //OBJECT NAME: OrderDestinationItem__c
            //CONDITION:
            //1. For the PosItem in availablePosItems
            //2. For the incoming  Program id
            List<OrderDestinationItem__c> programOrderDestinationItems = [SELECT Sent_To_Warehouse__c, 
                                                                                 Wave_Order_Number__c, 
                                                                                 Quantity__c,
                                                                                 Ready_To_Be_Sent__c,
                                                                                 Warehouse_Transaction_Number__c,
                                                                                 On_Hold__c,
                                                                                 Order_Destination_Item_Status__c
                                                                           FROM  OrderDestinationItem__c
                                                                           WHERE (POS_Item__c =:availablePosItem.Id AND
                                                                                 OrderDestination__r.Order__r.Program__c =:selectedProgramId) ];
            
            system.debug('programOrderDestinationItems'+ programOrderDestinationItems.size());
            
            //Step 2: For each order destination items in programOrderDestinationItems,
            //Check the step 2.1 and 2.2 condition
             for(OrderDestinationItem__c orderDestinationItem : programOrderDestinationItems )
             {
                 //Step 2.1: Aim:To check if the following condition is satisfied,
                 //If yes, add the order destination item to Variable4(sentOrderItemsList)
                 //If no, go to next step 2.2
                 //CONDITIONS:
                 //1.ordered items should have wave order number					
                 //2.Sent_To_Warehouse__c should be true					
                 //3.Quantity__c must be greater than 0					
                 //4.Ready_To_Be_Sent__c should be true this value is assigned on the send wave orders page where we send wave orders.					
                 //5.It should have Warehouse_Transaction_Number__c (given by comet and it is stored in ordered item)					
                 //6.On_Hold__c must be false because this ordered item is already sent to the warehouse.					
                 if((orderDestinationItem.Sent_To_Warehouse__c == true)&&(orderDestinationItem.Wave_Order_Number__c != null)&&(orderDestinationItem.Quantity__c > 0)&&
                    (orderDestinationItem.Ready_To_Be_Sent__c == true)&&(orderDestinationItem.Warehouse_Transaction_Number__c != null)&&(orderDestinationItem.On_Hold__c == false))
                 {
                     //Add the order destination item to the sent order list if all the above conditions are satisfied.
                     sentOrderList.add(orderDestinationItem);
                 }
                 
                 system.debug('sentOrderList'+ sentOrderList.size());
                 			
                 //Step 2.2: Aim:To check if the following condition is satisfied,
                 //If yes, add the order destination item to Variable5(remaningOrderItemList)
                 //If no, move to next step
                 //CONDITIONS:
                 //1.ordered items should not have wave order number				
                 //2.Sent_To_Warehouse__c should be false				
                 //3.Quantity__c must be greater than 0				
                 //4.Ready_To_Be_Sent__c should be false, this value is assigned on the send wave orders page where we send wave orders.				
                 //5.It should not have Warehouse_Transaction_Number__c (given by comet and it is stored in ordered item)				
                 //6.On_Hold__c must be false because this ordered item is not on hold.				
                 //7.Order_Destination_Item_Status__c should be 'Open' status	
                 if((orderDestinationItem.Sent_To_Warehouse__c == false)&&(orderDestinationItem.Wave_Order_Number__c == null)&&(orderDestinationItem.Quantity__c > 0)&&
                    (orderDestinationItem.Ready_To_Be_Sent__c == false)&&(orderDestinationItem.Warehouse_Transaction_Number__c == null)&&
                    (orderDestinationItem.On_Hold__c == false)&&(orderDestinationItem.Order_Destination_Item_Status__c== 'Open') )
                 {
                      //Add the order destination item to the remaining order list if all the above conditions are satisfied.
                     remainingOrderList.add(orderDestinationItem);
                 }
                 system.debug('remainingList-->'+ remainingOrderList.size());
             }
            
            //Step 3: Aim:  To store the particular Item's details (Pos item name , number , price , pack of, brand)sent order and remaining order count in the variable InfiniumAvailableItemsWithCometOrderCount
            // which is of datatype List which is holding the elements of the wrapper class InfiniumAvailableItesmWithCometOrderCount_Wrapper
            InfiniumAvailableItemWithCometOrderCount.posItem = availablePosItem;
            InfiniumAvailableItemWithCometOrderCount.sentOrdersItemSize = sentOrderList.size();
            InfiniumAvailableItemWithCometOrderCount.remainingOrdersItemSize = remainingOrderList.size();
            //Add the incoming pos item in availablePosItem list to the list 'InfiniumAvailableItemsWithCometOrderCountList'of type InfiniumItemsWithCometOrderCount_Wrapper. 
            InfiniumAvailableItemsWithCometOrderCountList.add(InfiniumAvailableItemWithCometOrderCount);
            
       }
        
        system.debug('InfiniumAvailableItemsWithCometOrderCountList'+InfiniumAvailableItemsWithCometOrderCountList);

        //Return the result stored in the variable InfiniumAvailableItemsWithCometOrderCountList
        //which is of datatype List holding the elements of the wrapper class InfiniumAvailableItesmWithCometOrderCount_Wrapper
        return InfiniumAvailableItemsWithCometOrderCountList;
        
        
    }
    
    

}