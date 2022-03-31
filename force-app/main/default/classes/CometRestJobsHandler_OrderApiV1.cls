/*
AUTHOR         : PRADEEP KUMAR
Version        : 03
Date           : 10/12/2018
Description    : 1.this is used for submitting Inprocess orders to comet whenever orders are updated to inprocess.
2.whose suborders are submitted to comet,the ordered quantity of items of those suborders are deducted from inprocess inventory.
3.Seasonal Orders are going to be submitted using this handler.
What's New :
1.holding items for Bogle is now implemented.so it is going to send third level (order destination items) orders to Comet for Bogle.
*/

//Author : NK,SN,TP,VB Date: July 6th 2020
//Aim:To submit inventory order items and seasonal order items to the warehouse
public class CometRestJobsHandler_OrderApiV1
{
    
    public static string failedToSubmit='This order failed to submit';
    public static String itemFailedToSubmit='This wave order failed to submit';
    public static string open='Open';
    public static string inProcess='In Process';
    public static string sendToComet='Send to Comet';
    public static string needsApproval = 'Needs Approval';
    public static string orderProcessed = 'This order has been processed';
    public static String orderItemProcessed = 'This wave order has been processed';
    public static String orderItemNotProcessed = 'This Item has not been processed';
    public static string orderPartiallyProcessed = 'This order has been partially submitted';
    public static String orderPartiallyFailed='This order has been partially failed';
    public static String orderFullyProcessed='This order has been submitted to warehouse';
    public static string orderSentToComet = 'This order has been submitted to Comet';
    public static string itemorderSentToComet = 'This wave order has been submitted to Comet';
    public static String sendingToWarehouse='Sending to Warehouse';
    
    /**
        Method: afterUpdate(invoked by InprocessOrdersToComet Trigger)
        Purpose:1.This method is used to send inprocess suborders to Comet.
        2.this method is used to add ordered quantity to inprocess inventory.it happens only when all approvals are done.
        3.this method is used to deduct ordered quantity from inprocess inventory when the suborder is submitted to comet correctly.
        Parameters: orderdest oldmap,newmap
        Returns: nothing
        */
    
    //Author : NK,SN,TP,VB Date: July 6th 2020
    //Aim:To invoke methods responsible to send inventory and seasonal order items to the warehouse with respective conditions										
    public static void submitOrderToComet(Map<Id,OrderDestination__c> previousCometOrderMap,Map<Id,OrderDestination__c> currentCometOrderMap)
    {
        System.debug('previousCometOrderMap--->' +previousCometOrderMap);
        System.debug('currentCometOrderMap--->' +currentCometOrderMap);
        //---------------------Inventory Orders--------------------------        
        Set<Id> sendToCometInventoryOrdIdsForDFV =new Set<Id> ();
        Set<Id> sendToCometInventoryOrdIdsForJFW = new  Set<Id>();
        /**Authors: Thanvi & Vanditha Date: 07/01/2021 
		* To hold the comet order ids for wilson Daniel */
        Set<Id> sendToCometInventoryOrdIdsForWilsonDaniel = new  Set<Id>();
        /**Authors: Thanvi & Vanditha Date: 07/01/2021 
		* To hold the comet order ids for Infinium Spirits*/
        Set<Id> sendToCometInventoryOrdIdsForInfiniumSpirits = new  Set<Id>();
        //---------------------Seasonal Orders---------------------------
        //Declare a variable sendToCometSeasonalOrdIdsForDFV of type set which holds the unique set of  comet order ids																		
        Set<Id> sendToCometSeasonalOrdIdsForDFV =new Set<Id> ();
        //Declare a variable sendToCometSeasonalOrdIdsForInfiniumSpirits of type set which holds the unique set of  comet order ids																		
        Set<Id> sendToCometSeasonalOrdIdsForInfiniumSpirits =new Set<Id> ();
        Order__c emergeOrder ;
        //Select Id, Program from Order__c 
        //Is_Comet_Rest_Api__c,Account Name from Account in Order__c
        // for the Order Ids present in currentCometOrderMap  and store it in a variable emergeOrders of type Map<Id,Order__c>	
        
        Map<Id,Order__c> emergeOrders=new Map<Id,Order__c> ([SELECT Id,Account__r.Is_Comet_Rest_Api__c,Account__r.Name,Program__c FROM Order__c WHERE Id IN (SELECT Order__c FROM OrderDestination__c WHERE Id IN :currentCometOrderMap.keySet())]);
        /** For every value(Order Destination) in the variable currentCometOrderMap  check the following conditions :						
        i.The incoming comet order must have Comet_Order_Status__c equal to  sendToComet 						
        ii.The incoming Order destination's order must have Account.Is_Comet_Rest_Api__c set as true						
        iii.The incoming Order destination's order must have Account name as DFV						
        iv.The incoming Order destination's order must have a Program and should not be equal to null						
        v. Seasonal_Order_Trigger_Flag__c must be set true in Send_To_Comet_Order_Specifications__c	**/					
        for(OrderDestination__c cometOrder: currentCometOrderMap.values())
        {
            
            /********************************************************************Inventory Orders**********************************************************************************************************************************************************************************************************************************************************/
            /******************************************************************************************Inventory Orders************************************************************************************************************************************************************************************************************************************/
            /********************************************************************************************************************************Inventory Orders*******************************************************************************************************************************************************************************************/
            /********************************************************Inventory Orders**********************************************************************************************************************************************************************************************************************************************************************/
            
            if(currentCometOrderMap.get(cometOrder.Id).Comet_Order_Status__c== sendToComet && emergeOrders.get(cometOrder.Order__c).Account__r.Is_Comet_Rest_Api__c==true && emergeOrders.get(cometOrder.Order__c).Account__r.Name==Send_To_Comet_Order_Specifications__c.getInstance('DFV').Account_Name__c && emergeOrders.get(cometOrder.Order__c).Program__c==null &&Send_To_Comet_Order_Specifications__c.getInstance('DFV').Inventory_Order_Trigger_Flag__c==true) // DFV inventory orders are processed here..
                sendToCometInventoryOrdIdsForDFV.add(cometOrder.Id) ;
            
            if(currentCometOrderMap.get(cometOrder.Id).Comet_Order_Status__c == sendToComet && emergeOrders.get(cometOrder.Order__c).Account__r.Is_Comet_Rest_Api__c==true && emergeOrders.get(cometOrder.Order__c).Account__r.Name==Send_To_Comet_Order_Specifications__c.getInstance('JFW').Account_Name__c && emergeOrders.get(cometOrder.Order__c).Program__c==null &&Send_To_Comet_Order_Specifications__c.getInstance('JFW').Inventory_Order_Trigger_Flag__c==true) // JFW inventory orders are processed here..
                sendToCometInventoryOrdIdsForJFW.add(cometOrder.Id) ;
            /**Authors: Thanvi & Vanditha Date: 07/01/2021 
			* To hold thecomet order ids for wilson Daniel */
            if(currentCometOrderMap.get(cometOrder.Id).Comet_Order_Status__c == sendToComet && emergeOrders.get(cometOrder.Order__c).Account__r.Is_Comet_Rest_Api__c==true && emergeOrders.get(cometOrder.Order__c).Account__r.Name==Send_To_Comet_Order_Specifications__c.getInstance('Wilson Daniels').Account_Name__c && emergeOrders.get(cometOrder.Order__c).Program__c==null &&Send_To_Comet_Order_Specifications__c.getInstance('Wilson Daniels').Inventory_Order_Trigger_Flag__c==true) // WILSONDANIEL inventory orders are processed here..
                sendToCometInventoryOrdIdsForWilsonDaniel.add(cometOrder.Id) ;
            System.debug('sendToCometInventoryOrdIdsForWilsonDaniel-->' +sendToCometInventoryOrdIdsForWilsonDaniel); 
            /**Authors: Thanvi,Hemanth, Chandan Date: 10/Jan/2022
			* To hold thecomet order ids for Infinium Spirits */
            System.debug(currentCometOrderMap.get(cometOrder.Id).Comet_Order_Status__c);
            System.debug(emergeOrders.get(cometOrder.Order__c).Account__r.Is_Comet_Rest_Api__c);
            System.debug(emergeOrders.get(cometOrder.Order__c).Account__r.Name);
            System.debug(Send_To_Comet_Order_Specifications__c.getInstance('Infinium Spirits').Inventory_Order_Trigger_Flag__c);
            System.debug(emergeOrders.get(cometOrder.Order__c).Program__c);
            System.debug(Send_To_Comet_Order_Specifications__c.getInstance('Infinium Spirits').Inventory_Order_Trigger_Flag__c);
            if(currentCometOrderMap.get(cometOrder.Id).Comet_Order_Status__c == sendToComet && emergeOrders.get(cometOrder.Order__c).Account__r.Is_Comet_Rest_Api__c==true && emergeOrders.get(cometOrder.Order__c).Account__r.Name==Send_To_Comet_Order_Specifications__c.getInstance('Infinium Spirits').Account_Name__c && emergeOrders.get(cometOrder.Order__c).Program__c==null &&Send_To_Comet_Order_Specifications__c.getInstance('Infinium Spirits').Inventory_Order_Trigger_Flag__c==true) // INFINIUM SPIRITS inventory orders are processed here..
                sendToCometInventoryOrdIdsForInfiniumSpirits.add(cometOrder.Id) ;
            System.debug('sendToCometInventoryOrdIdsForInfiniumSpirits-->' +sendToCometInventoryOrdIdsForInfiniumSpirits); 
            /********************************************************************Seasonal Orders**********************************************************************************************************************************************************************************************************************************************************/
            /******************************************************************************************Seasonal Orders************************************************************************************************************************************************************************************************************************************/
            /********************************************************************************************************************************Seasonal Orders*******************************************************************************************************************************************************************************************/
            /********************************************************Seasonal Orders**********************************************************************************************************************************************************************************************************************************************************************/
            //If the above conditions are met , add the incoming comet order Id to the variable sendToCometSeasonalOrdIdsForDFV  						
            if(currentCometOrderMap.get(cometOrder.Id).Comet_Order_Status__c== sendToComet && emergeOrders.get(cometOrder.Order__c).Account__r.Is_Comet_Rest_Api__c==true && emergeOrders.get(cometOrder.Order__c).Account__r.Name==Send_To_Comet_Order_Specifications__c.getInstance('DFV').Account_Name__c && emergeOrders.get(cometOrder.Order__c).Program__c!=null &&Send_To_Comet_Order_Specifications__c.getInstance('DFV').Seasonal_Order_Trigger_Flag__c==true) // DFV Seasonal orders are processed here..
                sendToCometSeasonalOrdIdsForDFV.add(cometOrder.Id) ;
            /**Authors: Thanvi,Hemanth, Chandan Date: 10/Jan/2022
			* To hold thecomet order ids for Infinium Spirits */
            if(currentCometOrderMap.get(cometOrder.Id).Comet_Order_Status__c== sendToComet && emergeOrders.get(cometOrder.Order__c).Account__r.Is_Comet_Rest_Api__c==true && emergeOrders.get(cometOrder.Order__c).Account__r.Name==Send_To_Comet_Order_Specifications__c.getInstance('Infinium Spirits').Account_Name__c && emergeOrders.get(cometOrder.Order__c).Program__c!=null &&Send_To_Comet_Order_Specifications__c.getInstance('Infinium Spirits').Seasonal_Order_Trigger_Flag__c==true) // Infinium Spirits Seasonal orders are processed here..
                sendToCometSeasonalOrdIdsForInfiniumSpirits.add(cometOrder.Id) ;
        }
        
        /************** Inventory Orders **************/
        if(!sendToCometInventoryOrdIdsForDFV.isEmpty())
            submitInventoryOrderToComet(sendToCometInventoryOrdIdsForDFV);
        //Check if the sendToCometInventoryOrdIdsForJFW has value
        if(!sendToCometInventoryOrdIdsForJFW.isEmpty())
            //If yes ,Invoke a method submitInventoryOrderToComet along with the data sendToCometInventoryOrdIdsForJFW 
            submitInventoryOrderToComet(sendToCometInventoryOrdIdsForJFW);
        /**Authors: Thanvi & Vanditha Date: 07/01/2021 
			* If the comet order ids for wilson daniel is not empty */
        if(!sendToCometInventoryOrdIdsForWilsonDaniel.isEmpty())
            //If yes ,Invoke a method submitInventoryOrderToComet along with the data sendToCometInventoryOrdIdsForWilsonDaniel 
            submitInventoryOrderToComet(sendToCometInventoryOrdIdsForWilsonDaniel);
        /**Authors: Thanvi,Hemanth, Chandan Date: 10/Jan/2022
		* If the comet order ids for Infinium Spirits is not empty */
        if(!sendToCometInventoryOrdIdsForInfiniumSpirits.isEmpty())
            //If yes ,Invoke a method submitInventoryOrderToComet along with the data sendToCometInventoryOrdIdsForInfiniumSpirits 
            submitInventoryOrderToComet(sendToCometInventoryOrdIdsForInfiniumSpirits);
        /************** Seasonal Orders  *********/   
        //Check if the variable sendToCometSeasonalOrdIdsForDFV  has any value , If yes invoke submitSeasonalOrderToComet(sendToCometSeasonalOrdIdsForDFV) method for the further processing.						
        if(!sendToCometSeasonalOrdIdsForDFV.isEmpty())
            submitSeasonalOrderToComet(sendToCometSeasonalOrdIdsForDFV); 
        /**Authors: Thanvi,Hemanth, Chandan Date: 10/Jan/2022
		* If the comet order ids for Infinium Spirits is not empty */
        //Check if the variable sendToCometSeasonalOrdIdsForInfiniumSpirits  has any value , If yes invoke submitSeasonalOrderToComet(sendToCometSeasonalOrdIdsForInfiniumSpirits) method for the further processing.						
        if(!sendToCometSeasonalOrdIdsForInfiniumSpirits.isEmpty())
            submitSeasonalOrderToComet(sendToCometSeasonalOrdIdsForInfiniumSpirits); 
    }
    
    @future(callout=true)
    public static void submitInventoryOrderToComet(Set<Id> sendToCometOrdIds)
    {     
        System.debug('sendToCometOrdIds--->' +sendToCometOrdIds);      
        Map<Id,cometResponse> resultantCometResponse=new Map<Id,cometResponse> ();
        /**Authors:TP,VM Date: 02-NOV-2020 CR Number : JFW-02-NOV-2 
The below line is commented to add the Freight_Code__c to the obtained data
Map<Id,OrderDestination__c> sendToCometOrdersWithItems=new Map<Id,OrderDestination__c> ([SELECT OrderName__c,SelectedShippingMethod__r.Shipping_Method_Name__c,Shipping_Method__r.Shipping_Method_Name__c,Order__r.Order_Confirmation_Date__c,Order__r.Order_Submission_Date__c,AddressBook__r.ShipToFirstName__c,AddressBook__r.ShipToLastName__c,
AddressBook__r.Shipto_Company__c,AddressBook__r.Email__c,AddressBook__r.Address_Details__c,AddressBook__r.City__c,AddressBook__r.Country__r.Country_Code__c,AddressBook__r.State__r.State_Code__c,AddressBook__r.State__r.Country__r.Country_Code__c,AddressBook__r.Zip__c,AddressBook__r.Phone__c,
(SELECT OrderName__c,POS_Item__r.Item_Name__c,OrderDestination__r.SelectedShippingMethod__r.Shipping_Method_Name__c,OrderDestination__r.Order__r.Order_Confirmation_Date__c,
OrderDestination__r.Order__r.Order_Submission_Date__c,OrderDestination__r.AddressBook__r.ShipToFirstName__c,OrderDestination__r.AddressBook__r.ShipToLastName__c,OrderDestination__r.AddressBook__r.Shipto_Company__c,OrderDestination__r.AddressBook__r.Email__c,
OrderDestination__r.AddressBook__r.Address_Details__c,OrderDestination__r.AddressBook__r.City__c,OrderDestination__r.AddressBook__r.Country__r.Country_Code__c,OrderDestination__r.AddressBook__r.State__r.State_Code__c,OrderDestination__r.AddressBook__r.Zip__c,OrderDestination__r.AddressBook__r.Phone__c,
POS_Item__r.Item_No__c,Quantity__c,Quantity_in_Eaches__c FROM OrderDestinationItems__r WHERE Quantity__c >0),Order__r.Account__r.Comet_API_Key__c
FROM OrderDestination__c WHERE Id IN : sendToCometOrdIds]); **/ 
        //Authors:TP,VM Date: 02-NOV-2020 CR Number :JFW-02-NOV-2 
        //The Freight_Code__c is added
        Map<Id,OrderDestination__c> sendToCometOrdersWithItems=new Map<Id,OrderDestination__c> ([SELECT OrderName__c,Freight_Code__c,SelectedShippingMethod__r.Shipping_Method_Name__c,Shipping_Method__r.Shipping_Method_Name__c,Order__r.Order_Confirmation_Date__c,Order__r.Order_Submission_Date__c,AddressBook__r.ShipToFirstName__c,AddressBook__r.ShipToLastName__c,
                                                                                                 AddressBook__r.Shipto_Company__c,AddressBook__r.Email__c,AddressBook__r.Address_Details__c,AddressBook__r.City__c,AddressBook__r.Country__r.Country_Code__c,AddressBook__r.State__r.State_Code__c,AddressBook__r.State__r.Country__r.Country_Code__c,AddressBook__r.Zip__c,AddressBook__r.Phone__c,
                                                                                                 (SELECT OrderName__c,POS_Item__r.Item_Name__c,OrderDestination__r.SelectedShippingMethod__r.Shipping_Method_Name__c,OrderDestination__r.Order__r.Order_Confirmation_Date__c,
                                                                                                  OrderDestination__r.Order__r.Order_Submission_Date__c,OrderDestination__r.AddressBook__r.ShipToFirstName__c,OrderDestination__r.AddressBook__r.ShipToLastName__c,OrderDestination__r.AddressBook__r.Shipto_Company__c,OrderDestination__r.AddressBook__r.Email__c,
                                                                                                  OrderDestination__r.AddressBook__r.Address_Details__c,OrderDestination__r.AddressBook__r.City__c,OrderDestination__r.AddressBook__r.Country__r.Country_Code__c,OrderDestination__r.AddressBook__r.State__r.State_Code__c,OrderDestination__r.AddressBook__r.Zip__c,OrderDestination__r.AddressBook__r.Phone__c,
                                                                                                  POS_Item__r.Item_No__c,Quantity__c,Quantity_in_Eaches__c FROM OrderDestinationItems__r WHERE Quantity__c >0),Order__r.Account__r.Comet_API_Key__c
                                                                                                 FROM OrderDestination__c WHERE Id IN : sendToCometOrdIds]);
        
        System.debug('sendToCometOrdersWithItems' +sendToCometOrdersWithItems);                                            
        
        for(OrderDestination__c cometOrder: sendToCometOrdersWithItems.values())
        {    
            if(cometOrder.OrderDestinationItems__r.size()!=0)
            {           
                CometResponse cometResponseByOrder;    
                cometResponseByOrder=setApiConnectionAndGetResponse(cometOrder.OrderName__c,cometOrder,cometOrder.OrderDestinationItems__r);
                resultantCometResponse.put(cometOrder.Id,cometResponseByOrder);
                System.debug('resultantCometResponse--->' +resultantCometResponse);
            }
        }
        
        //----------- Updating Comet Order status And WareHouse Trans.No here ------//    
        
        
        for(OrderDestination__c cometOrder:sendToCometOrdersWithItems.values())
        {
            if(resultantCometResponse.containsKey(cometOrder.Id))
            {
                cometOrder.Comet_Order_Dest_Status__c=resultantCometResponse.get(cometOrder.Id).statusDescription;
                cometOrder.Comet_Status_Code__c=resultantCometResponse.get(cometOrder.Id).statusCode;
                if(resultantCometResponse.get(cometOrder.Id).statusCode!=201)// error
                {
                    cometOrder.Comet_Order_Status__c=failedToSubmit;//we need to resolve this issue,and submit via scheduler
                }else{
                    CometTransactionResponse comet=(CometTransactionResponse)System.JSON.deserialize(resultantCometResponse.get(cometOrder.Id).statusDescription,CometTransactionResponse.class);
                    cometOrder.Comet_Order_Status__c=orderSentToComet;
                    cometOrder.WarehouseTransactionNo__c=comet.OrderNumber;
                }
                
                System.debug('sendToCometOrdersWithItems--->' +sendToCometOrdersWithItems); 
            }               
        }
        
        if(!sendToCometOrdersWithItems.values().isEmpty()){
            Database.update(sendToCometOrdersWithItems.values(),false) ;
        } 
    }
    
    //Author : NK,SN,TP,VB Date: July 6th 2020
    //Aim:To send seasonal order items to the comet through REST API.			
    @future(callout=true)
    public static void submitSeasonalOrderToComet(Set<Id> sendToCometOrdIds)
    { 
        //Declare a variable resultantCometResponse of type Map holding the Id and List of instance of wrapper class cometResponse								
        Map<Id,List<cometResponse>> resultantCometResponse=new Map<Id,List<cometResponse>> (); 
        //Declare a variable waveOrderNumberWithCometOrderItems of type Map holding the String and List of sObject OrderDestinationItem__c			
        Map<String,List<OrderDestinationItem__c>> waveOrderNumberWithCometOrderItems=new Map<String,List<OrderDestinationItem__c>>();
        //Declare a variable updatingCometOrderItems of type List holding the elements of sObject OrderDestinationItem__c								
        List<OrderDestinationItem__c> updatingCometOrderItems=new List<OrderDestinationItem__c> ();
        //Declare a variable sendToCometOrdersWithItems of type Map holding Id and elements of sObject OrderDestination__c and load it with the following details of OrderDestinationItem__c and OrderDestination__c **/ 								
        //Authors:TP,VM Date: 02-NOV-2020 CR Number :JFW-02-NOV-2 
        //The Freight_Code__c is expected in the rest api call
        /**  Map<Id,OrderDestination__c> sendToCometOrdersWithItems=new Map<Id,OrderDestination__c> ([SELECT Wave_Order_Details__c,OrderName__c,SelectedShippingMethod__r.Shipping_Method_Name__c,Shipping_Method__r.Shipping_Method_Name__c,Order__r.Order_Confirmation_Date__c,Order__r.Order_Submission_Date__c,AddressBook__r.ShipToFirstName__c,AddressBook__r.ShipToLastName__c,
AddressBook__r.Shipto_Company__c,AddressBook__r.Email__c,AddressBook__r.Address_Details__c,AddressBook__r.City__c,AddressBook__r.Country__r.Country_Code__c,AddressBook__r.State__r.State_Code__c,AddressBook__r.State__r.Country__r.Country_Code__c,AddressBook__r.Zip__c,AddressBook__r.Phone__c,
(SELECT OrderName__c,POS_Item__r.Item_Name__c,OrderDestination__r.SelectedShippingMethod__r.Shipping_Method_Name__c,OrderDestination__r.Order__r.Order_Confirmation_Date__c,
OrderDestination__r.Order__r.Order_Submission_Date__c,OrderDestination__r.AddressBook__r.ShipToFirstName__c,OrderDestination__r.AddressBook__r.ShipToLastName__c,OrderDestination__r.AddressBook__r.Shipto_Company__c,OrderDestination__r.AddressBook__r.Email__c,
OrderDestination__r.AddressBook__r.Address_Details__c,OrderDestination__r.AddressBook__r.City__c,OrderDestination__r.AddressBook__r.Country__r.Country_Code__c,OrderDestination__r.AddressBook__r.State__r.State_Code__c,OrderDestination__r.AddressBook__r.Zip__c,OrderDestination__r.AddressBook__r.Phone__c,
POS_Item__r.Item_No__c,Quantity__c,Quantity_in_Eaches__c,Wave_Order_Number__c FROM OrderDestinationItems__r WHERE Quantity__c >0 AND On_Hold__c=false AND Sent_To_Warehouse__c=false AND Ready_To_Be_Sent__c=true AND Order_Destination_Item_Status__c=:sendingToWarehouse AND Wave_Order_Number__c !=null AND Wave_Order_Number__c !='' AND Warehouse_Transaction_Number__c=NULL),Order__r.Account__r.Comet_API_Key__c
FROM OrderDestination__c WHERE Id IN : sendToCometOrdIds]);**/ 
        Map<Id,OrderDestination__c> sendToCometOrdersWithItems=new Map<Id,OrderDestination__c> ([SELECT Wave_Order_Details__c,Freight_Code__c,OrderName__c,SelectedShippingMethod__r.Shipping_Method_Name__c,Shipping_Method__r.Shipping_Method_Name__c,Order__r.Order_Confirmation_Date__c,Order__r.Order_Submission_Date__c,AddressBook__r.ShipToFirstName__c,AddressBook__r.ShipToLastName__c,
                                                                                                 AddressBook__r.Shipto_Company__c,AddressBook__r.Email__c,AddressBook__r.Address_Details__c,AddressBook__r.City__c,AddressBook__r.Country__r.Country_Code__c,AddressBook__r.State__r.State_Code__c,AddressBook__r.State__r.Country__r.Country_Code__c,AddressBook__r.Zip__c,AddressBook__r.Phone__c,
                                                                                                 (SELECT OrderName__c,POS_Item__r.Item_Name__c,OrderDestination__r.SelectedShippingMethod__r.Shipping_Method_Name__c,OrderDestination__r.Order__r.Order_Confirmation_Date__c,
                                                                                                  OrderDestination__r.Order__r.Order_Submission_Date__c,OrderDestination__r.AddressBook__r.ShipToFirstName__c,OrderDestination__r.AddressBook__r.ShipToLastName__c,OrderDestination__r.AddressBook__r.Shipto_Company__c,OrderDestination__r.AddressBook__r.Email__c,
                                                                                                  OrderDestination__r.AddressBook__r.Address_Details__c,OrderDestination__r.AddressBook__r.City__c,OrderDestination__r.AddressBook__r.Country__r.Country_Code__c,OrderDestination__r.AddressBook__r.State__r.State_Code__c,OrderDestination__r.AddressBook__r.Zip__c,OrderDestination__r.AddressBook__r.Phone__c,
                                                                                                  POS_Item__r.Item_No__c,Quantity__c,Quantity_in_Eaches__c,Wave_Order_Number__c FROM OrderDestinationItems__r WHERE Quantity__c >0 AND On_Hold__c=false AND Sent_To_Warehouse__c=false AND Ready_To_Be_Sent__c=true AND Order_Destination_Item_Status__c=:sendingToWarehouse AND Wave_Order_Number__c !=null AND Wave_Order_Number__c !='' AND Warehouse_Transaction_Number__c=NULL),Order__r.Account__r.Comet_API_Key__c
                                                                                                 FROM OrderDestination__c WHERE Id IN : sendToCometOrdIds]);
        // Declare a variable waveOrderNumberWithCometOrderItems of type Map holding the String and List of sObject OrderDestinationItem__c		
        List<String> waveOrderTransactionNumbersList=new List<String> ();
        //Declare a variable waveOrderNumbersList of type List<String>				
        List<String> waveOrderNumbersList=new List<String> ();
        
        /**For every order destination in sendToCometOrdersWithItems ,
declare a variable waveOrderNumbersAndItems_Map of type Map<String,List<OrderDestinationItem__c>>  and for every for order destination Items which is present in the incoming Order destination  
Check if the variable waveOrderNumbersAndItems_Map does not contain the wave order number , 
If yes ,put the wave order number and the incoming order destination item to the variable waveOrderNumbersAndItems_Map 
If not ,declare a variable cometOrderItems of type List<OrderDestinationItem__c> ,  assign the wave order number to the variable cometOrderItems,  add the incoming order destination item to the list  cometOrderItems  and put the wave order number and the cometOrderItems  to the map waveOrderNumbersAndItems_Map . **/                                                                            				
        for(OrderDestination__c cometOrder: sendToCometOrdersWithItems.values())
        {  
            //Getting wave order numbers from third level (Order Destination Item)  
            Map<String,List<OrderDestinationItem__c>> waveOrderNumbersAndItems_Map=new Map<String,List<OrderDestinationItem__c>> ();
            for(OrderDestinationItem__c cometOrderItem : cometOrder.OrderDestinationItems__r)
            {
                if(!waveOrderNumbersAndItems_Map.containsKey(cometOrderItem.Wave_Order_Number__c))
                    waveOrderNumbersAndItems_Map.put(cometOrderItem.Wave_Order_Number__c,new List<OrderDestinationItem__c> {cometOrderItem}); 
                else
                {
                    List<OrderDestinationItem__c> cometOrderItems=new List<OrderDestinationItem__c> ();
                    cometOrderItems=waveOrderNumbersAndItems_Map.get(cometOrderItem.Wave_Order_Number__c);
                    cometOrderItems.add(cometOrderItem);
                    waveOrderNumbersAndItems_Map.put(cometOrderItem.Wave_Order_Number__c,cometOrderItems);
                }          
            } 
            //Declare a variable cometResponsesListof type List holding the elements of wrapper class CometResponse							
            List<CometResponse> cometResponsesList=new List<CometResponse> ();
            //From the waveOrderNumbersAndItems_Map get the Wave Order Numer and for each orderNumber							
            for(String orderNumber : waveOrderNumbersAndItems_Map.keySet())
            {   
                //check if the orderNumber is Not Null, if yes then			             
                if(waveOrderNumbersAndItems_Map.get(orderNumber)!=null)
                {
                    //Add the waveOrderNumber and the ordered Items belonging to the order to waveOrderNumberWithCometOrderItems						
                    waveOrderNumberWithCometOrderItems.put(orderNumber,waveOrderNumbersAndItems_Map.get(orderNumber));
                    /**Invoke the method setApiConnectionAndGetResponse with parametres 				
1: orderNumber	---> String		
2: cometOrder	--->Order_Destination__c		
3:orderedItems	----> List<Order_destination_Item__c>	
and store response in the variable cometResponseByEachWaveOrder of type CometResponse **/						  
                    CometResponse cometResponseByEachWaveOrder=setApiConnectionAndGetResponse(orderNumber,cometOrder,waveOrderNumbersAndItems_Map.get(orderNumber));  
                    //Add each cometResponseByEachWaveOrder to a list call cometResponseList					  
                    cometResponsesList.add(cometResponseByEachWaveOrder);
                }
            }
            //Store the entire list of cometResponseList in the variable resultantCometResponse as id, cometResponseList 						
            resultantCometResponse.put(cometOrder.Id,cometResponsesList);
        }
        
        //For each Comet Order check if the resultantCometResponse variable contains the same cometOrderId, if yes the						
        for(OrderDestination__c cometOrder:sendToCometOrdersWithItems.values())
        {
            if(resultantCometResponse.containsKey(cometOrder.Id))
            {   
                //Check if Wave_Order_Details__c field under the cometOrder is equal to null, if yes then 					
                //set the Wave_Order_Details__c to blank string				             
                if(cometOrder.Wave_Order_Details__c==null)
                    cometOrder.Wave_Order_Details__c='';
                //Declare a variable waveOrderDetails of type String.                                               				
                String waveOrderDetails='';
                //Declare a variable itemDetails of type String.
                String itemDetails='';
                //Declare a variable itemIndexNumber of type Number.     
                Integer itemIndexNumber=0;
                //Declare a variable totalwaveOrderDetails of type String.
                String totalwaveOrderDetails='';
                
                
                //Declare a variable waveOrderWithCometResponse of type Map<String,CometResponse> 	
                Map<String,CometResponse> waveOrderWithCometResponse=new Map<String,CometResponse> ();
                //For the resultantCometResponse get the OrderId and for each cometResponseByEachWaveOrder  								
                for(CometResponse cometResponseByEachWaveOrder : resultantCometResponse.get(cometOrder.Id))     
                {  //Check if the order number in cometResponseByEachWaveOrder is not Blank, of yes then
                    if(String.isNotBlank(cometResponseByEachWaveOrder.orderNumber))
                        // Add the orderNumber with its complete response detsila to the variable waveOrderWithCometResponse
                        waveOrderWithCometResponse.put(cometResponseByEachWaveOrder.orderNumber,cometResponseByEachWaveOrder );
                }
                //For every Order Destination Item in the incoming comet order id 				
                //processing order destination Items here.... 
                for(OrderDestinationItem__c cometOrderItem : cometOrder.OrderDestinationItems__r) 
                {   //Increment the value in the variable itemIndexNumber.			
                    itemIndexNumber++;
                    //Assign the  logged in user Id to the  field Wave_Order_Sent_By__c  in comet order items                                                                                   							
                    cometOrderItem.Wave_Order_Sent_By__c=UserInfo.getUserId();
                    
                    //Assign the current time and date to Wave_Order_Date_Time__c                                                                                                   			
                    cometOrderItem.Wave_Order_Date_Time__c=System.now();
                    //Check if the waveOrderWithCometResponse contains the wave order number ,If yes,					
                    //If yes , add the order number and the order destination to the variable waveOrderWithCometResponse 						
                    if(waveOrderWithCometResponse.containsKey(cometOrderItem.Wave_Order_Number__c))
                    {
                        //a.Set the Comet_Response_Status_Code__c of comet order item  with status code present in waveOrderWithCometResponse 							
                        //b.Set the Comet_Response__cof comet order item  with status description present in waveOrderWithCometResponse                                                         							
                        cometOrderItem.Comet_Response_Status_Code__c=waveOrderWithCometResponse.get(cometOrderItem.Wave_Order_Number__c).statusCode;
                        cometOrderItem.Comet_Response__c=waveOrderWithCometResponse.get(cometOrderItem.Wave_Order_Number__c).statusDescription;
                        
                        //Check if the statusCode of waveOrderWithCometResponse is 201 , if yes,
                        /**a. Deserialize the statusDescription of waveOrderWithCometResponse for the incoming comet order id and convert the response to the type CometTransactionResponse and store it in a variable named comet.													
b.Set Order_Destination_Item_Status__c of comet order item with the variable itemorderSentToComet of type string which holds the status 'This wave order has been submitted to Comet'.													
c.Set Warehouse_Transaction_Number__c comet Order Item with the OrderNumber in comet variable													
d.Set the Sent_To_Warehouse__c field of cometOrderItem to true													
e.Add the order number in comet variable to the variable  waveOrderTransactionNumbersList of type string.**/
                        
                        if(waveOrderWithCometResponse.get(cometOrderItem.Wave_Order_Number__c).statusCode==201)
                        {
                            CometTransactionResponse comet=(CometTransactionResponse)System.JSON.deserialize(waveOrderWithCometResponse.get(cometOrderItem.Wave_Order_Number__c).statusDescription,CometTransactionResponse.class);
                            cometOrderItem.Order_Destination_Item_Status__c=itemorderSentToComet ;
                            cometOrderItem.Warehouse_Transaction_Number__c=comet.OrderNumber;                             
                            cometOrderItem.Sent_To_Warehouse__c=true;
                            waveOrderTransactionNumbersList.add(comet.OrderNumber);
                        }
                        /**If not ,														
a.Set Order_Destination_Item_Status__c of comet order item to a variable of type string itemFailedToSubmit which holds the status 'This wave order failed to submit'.													
b.Add the wave order numbers of the comet order item that are failed to be sent to warehouse to a variable waveOrderNumbersList of type List<String>**/													
                        else
                        {
                            cometOrderItem.Order_Destination_Item_Status__c=itemFailedToSubmit;
                            waveOrderNumbersList.add(cometOrderItem.Wave_Order_Number__c); 
                        }                         
                    }
                    
                    /** If the wave order number of an incoming order destination item is not present,														
a.Set Comet_Response_Status_Code__c of cometOrderItem to 500;													
b.Set cometOrderItem.Comet_Response__c to 'Emerge Submission failed..';													
c.Set cometOrderItem.Order_Destination_Item_Status__c to itemFailedToSubmit;													
d.Add the wave order numbers of those comet order items which failed to be sent to warehouse to waveOrderNumbersList **/													
                    else
                    {    
                        cometOrderItem.Comet_Response_Status_Code__c=500;
                        cometOrderItem.Comet_Response__c='Emerge Submission failed..';
                        cometOrderItem.Order_Destination_Item_Status__c=itemFailedToSubmit;
                        waveOrderNumbersList.add(cometOrderItem.Wave_Order_Number__c);
                    }
                    
                    //Set the variable waveOrderDetails of type string with the following data and format:
                    waveOrderDetails='Wave Order Number -- > '+cometOrderItem.Wave_Order_Number__c+' Wave Order Status --> '+cometOrderItem.Order_Destination_Item_Status__c+' Wave Order Sent Date --> '+cometOrderItem.Wave_Order_Date_Time__c+' Wave Order Sent By --> '+cometOrderItem.Wave_Order_Sent_By__c;
                    itemDetails=itemDetails+'Item '+String.valueOf(itemIndexNumber)+' -- Item Name -- '+cometOrderItem.Pos_Item__r.Item_Name__c+' -- Item No -- '+cometOrderItem.Pos_Item__r.Item_No__c+' -- Quantity --> '+cometOrderItem.Quantity__c+' \n';
                    //Add the comet order item which has the wave order number and which are sucessfully sent to warehouse to the variable updatingCometOrderItems of type List<OrderDestinationItem__c>								
                    updatingCometOrderItems.add(cometOrderItem);
                } 
                // Set the variable totalwaveOrderDetails with the following data :   
                //Wave_Order_Details__c of an incoming comet order+waveOrderDetails+' +itemDetails"							
                totalwaveOrderDetails=cometOrder.Wave_Order_Details__c+waveOrderDetails+' \n'+itemDetails+' \n'; 
                //Check If the string length of totalwaveOrderDetails is less than 131072) ,If yes,
                //Set Wave_Order_Details__c of the incoming comet order to totalwaveOrderDetails.
                //If no ,  Set Comet_Order_Status__c of the incoming comet order to the variable failedToSubmit which has the status 'This order failed to submit'.             							
                Integer stringLength=totalwaveOrderDetails.length();
                if(stringLength<131072)
                    cometOrder.Wave_Order_Details__c=totalwaveOrderDetails;                 
            } 
            else
            {
                cometOrder.Comet_Order_Status__c=failedToSubmit;
            }                         
        }
        
        //Check if the updatingCometOrderItems is not empty , If yes , update the  updatingCometOrderItems to the database.        						
        // updating comet order items ---          
        if(!updatingCometOrderItems.isEmpty())
            update updatingCometOrderItems;
        //Invoke sendNotificationForFailedToSubmitWaveOrdersmethod(waveOrderNumbersList) of the class EmailNotificationForOrders  to send the list of failed comet order items.							 
        // sending notifications to users
        //Invoke sendNotificationForSubmittedWaveOrders (waveOrderTransactionNumbersList) of the class EmailNotificationForOrders  to send the list of  comet order items which are sucessfully sent to the warehouse.							
        EmailNotificationForOrders.sendNotificationForSubmittedWaveOrders(waveOrderTransactionNumbersList);  
        EmailNotificationForOrders.sendNotificationForFailedToSubmitWaveOrders(waveOrderNumbersList); 
        
        //--checking all comet orders which are submitted or not if not updating the status of comet order.
        //Declare a variable cometOrderWithCometOrderItemsStatus of type Map<Id,String> 					
        Map<Id,String> cometOrderWithCometOrderItemsStatus=new Map<Id,String> ();
        //Get the list of OrderDestination items for the ids that matches with  IN:sendToCometOrdersWithItems id , and store it in a variable cometOrderDestailsList 						
        for(OrderDestination__c cometOrder : [SELECT Id,(SELECT Id,On_Hold__c,Ready_To_Be_Sent__c,Wave_Order_Number__c,Warehouse_Transaction_Number__c,Sent_To_Warehouse__c,Order_Destination_Item_Status__c FROM OrderDestinationItems__r WHERE Quantity__c>0) FROM OrderDestination__c WHERE Id IN:sendToCometOrdersWithItems.keySet()])
        {
            //Declare a variable submittedValue of type Integer, to count the submitted O				
            Integer submittedValue=0;
            //Declare a variable failedValue of type Integer, to count the failed Order                                        				
            Integer failedValue=0;
            //From each comet order get the orderDestinationItem, for each destination item  				
            for(OrderDestinationItem__c cometOrderItem : cometOrder.OrderDestinationItems__r)
            {
                //check if the Order_Destination_Item_Status__c status is 'This wave order has been submitted to Comet', if yes 				
                if(cometOrderItem.Order_Destination_Item_Status__c ==itemorderSentToComet)
                    //incremenet the count of submittedValue		
                    submittedValue++;
                //check if the Order_Destination_Item_Status__c status is 'This wave order failed to submit', if yes 				
                if(cometOrderItem.Order_Destination_Item_Status__c ==itemFailedToSubmit)
                    //incremenet the count of failedValue		
                    failedValue++;                 
            }
            //Check if the size of the size of destination item for each comet order is greater than 0, if yes					
            if(cometOrder.OrderDestinationItems__r.size()>0)
            {
                //check if the destination size is  to the (submittedValue andsubmittedValue is gretaer than 0 and failedValue is equal to 0), if yes then						
                if(cometOrder.OrderDestinationItems__r.size()==submittedValue && submittedValue>0 && failedValue==0)
                    //then add the comet order id and the message 'This order has been submitted to warehouse' to the variable cometOrderWithCometOrderItemsStatus 								
                    cometOrderWithCometOrderItemsStatus.put(cometOrder.Id,orderFullyProcessed); // This order has been submitted to warehouse
                //check if  the failedValue and submitted value is greater than 0, if yes then						
                if(failedValue>0 && submittedValue>0)
                    //then add the comet order id and the message 'This order has been partially failed' to the variable cometOrderWithCometOrderItemsStatus 								
                    cometOrderWithCometOrderItemsStatus.put(cometOrder.Id,orderPartiallyFailed);
                //check if  the failedValue  value is greater than 0 and submitted value is equal to 0 if yes then						
                if(failedValue>0 && submittedValue==0 )
                    //then add the comet order id and the message 'This order failed to Submit' to the variable cometOrderWithCometOrderItemsStatus 								
                    cometOrderWithCometOrderItemsStatus.put(cometOrder.Id,failedToSubmit);
                //check if  the failedValue  value is equal to 0 and submitted value is greater than 0 and also destinationsize is not equal to submitted value, if yes then						
                if(failedValue==0 && submittedValue>0 && cometOrder.OrderDestinationItems__r.size()!=submittedValue)
                    //then add the comet order id and the message 'This order has been partially submitted' to the variable cometOrderWithCometOrderItemsStatus 								
                    cometOrderWithCometOrderItemsStatus.put(cometOrder.Id,orderPartiallyProcessed);
            }
        }
        
        
        //updating statuses ---from above map -- 
        //Check if this sendToCometOrdersWithItems size is not empty then 					
        if(!sendToCometOrdersWithItems.values().isEmpty())
        {
            //From the sendToCometOrderwithItems get the order destination and for each cometOrder 					
            for(OrderDestination__c cometOrder : sendToCometOrdersWithItems.values())
                //check if the cometOrderWithCometOrderItemsStaus contains orderDestination Id, if yes then								
                if(cometOrderWithCometOrderItemsStatus.containsKey(cometOrder.Id))
                cometOrder.Comet_Order_Status__c=cometOrderWithCometOrderItemsStatus.get(cometOrder.Id);
            //set the Comet_Order_Status__c  and update the Database with the values	
            Database.update(sendToCometOrdersWithItems.values(),false) ;             
        } 
        
    } 
    //Author: NK,SN,TP,VB
    //Aim: To hold data members such as  ResourceLink of type ResourceLink ,OrderNumber of type String ,Message of type String.
    public class CometTransactionResponse
    {
        public ResourceLink ResourceLink;
        public String OrderNumber;
        public String Message;
    }
    
    //Author: NK,SN,TP,VB
    //Aim: To hold data members such as  Rel,Name,Url of type String.
    public class ResourceLink
    {
        public String Rel;
        public String Name;
        public String Url;
    }
    
    //Author: NK,SN,TP,VB
    //Aim: To hold data members such as  status,statusDescription,orderNumber,cometOrderId of type String and statusCodeof type Integer.
    public class cometResponse
    {
        public String status;
        public Integer statusCode;
        public String statusDescription;
        public String orderNumber;
        public String cometOrderId;
        public cometResponse(String cometOrderId,String status,Integer statusCode,String statusDescription,String orderNumber){
            this.status=status;
            this.statusCode=statusCode;
            this.statusDescription=statusDescription;
            this.orderNumber=orderNumber;
            this.cometOrderId=cometOrderId;
        }
        public cometResponse()
        {
        }
    }    
    public static cometResponse setApiConnectionAndGetResponse(String orderNumber,OrderDestination__c cometOrder,List<OrderDestinationItem__c> cometOrderItems)
    {
        cometResponse resultantCometResponse;
        String body='';
        Boolean isBodyContainsItems=false;
        System.debug(cometOrder);                       
        Http http=new Http();
        HttpRequest request=new HttpRequest();
        HttpResponse response=new HttpResponse();
        request.setEndPoint('https://api.complemar.com/v1/orders');
        request.setHeader('Authorization','Bearer '+cometOrder.Order__r.Account__r.Comet_API_Key__c);
        request.setHeader('Content-Type','application/json');
        request.setTimeOut(120000);
        request.setMethod('POST');
        String Name=(orderNumber==null ? '' :orderNumber);                     
        String DeliveryOption=(cometOrder.Shipping_Method__r.Shipping_Method_Name__c== null ? '':cometOrder.Shipping_Method__r.Shipping_Method_Name__c); 
        String ArriveByDate=String.valueOf(System.now()); //if now time is the arrival time.
        String FirstName=(cometOrder.AddressBook__r.ShipToFirstName__c==null ? cometOrder.AddressBook__r.ShipToLastName__c:cometOrder.AddressBook__r.ShipToFirstName__c);
        String LastName=(cometOrder.AddressBook__r.ShipToLastName__c==null ? cometOrder.AddressBook__r.ShipToFirstName__c:cometOrder.AddressBook__r.ShipToLastName__c);
        String Company=(cometOrder.AddressBook__r.Shipto_Company__c==null ? '': cometOrder.AddressBook__r.Shipto_Company__c);
        String Email=(cometOrder.AddressBook__r.Email__c==null ? '':cometOrder.AddressBook__r.Email__c);
        String Address1=(cometOrder.AddressBook__r.Address_Details__c==null? '' : cometOrder.AddressBook__r.Address_Details__c);
        String City=(cometOrder.AddressBook__r.City__c==null ? '':cometOrder.AddressBook__r.City__c);
        String State=(cometOrder.AddressBook__r.State__r.State_Code__c==null ? '':cometOrder.AddressBook__r.State__r.State_Code__c);
        String ZipCode=(cometOrder.AddressBook__r.Zip__c==null ? '': cometOrder.AddressBook__r.Zip__c);
        String Country=(cometOrder.AddressBook__r.State__r.Country__r.Country_Code__c==null ? '':cometOrder.AddressBook__r.State__r.Country__r.Country_Code__c);
        String Phone=(cometOrder.AddressBook__r.Phone__c==null ? '':cometOrder.AddressBook__r.Phone__c);
        //Authors:TP,VM Date: 02-NOV-2020 CR Number :JFW-02-NOV-2
        //To hold the FreightCode value from the comet order
        String FreightCode =(cometOrder.Freight_Code__c==null ? '':cometOrder.Freight_Code__c);				
        
        body='{  "Name": "'+Name+'",  "DeliveryOption": "'+DeliveryOption+'",  "ShipmentNote": "'+''+'",  "ArriveByDate": "'+ArriveByDate+'",  "Recipient": {    "FirstName": "'+FirstName+'",    "LastName": "'+LastName+'",    "CustomerNumber": "String",    "Company": "'+Company+'",    "Email": "'+Email+'",    "Address1": "'+Address1+'",    "Address2": "'+''+'",    "City": "'+City+'",    "State": "'+State+'",    "ZipCode": "'+ZipCode+'",    "Country": "'+Country+'",    "Phone": "'+Phone+'"  },  "Items": [ ';
        System.debug('body--->' +body);        
        for(OrderDestinationItem__c cometOrdItem:cometOrderItems)
        {
            String StockNumber=(cometOrdItem.POS_Item__r.Item_No__c==null ? '':cometOrdItem.POS_Item__r.Item_No__c);
            Integer Quantity=(cometOrdItem.Quantity_in_Eaches__c ==null ? 0: Integer.valueOf(cometOrdItem.Quantity_in_Eaches__c) );            
            body+=' {      "StockNumber": "'+StockNumber+'",      "Quantity": '+String.valueOf(Quantity)+'   },';
            isBodyContainsItems=true;
        }      
        //Authors:TP,VM Date: 02-NOV-2020 CR Number :JFW-02-NOV-2
        //The below 2 line is commented as the freight code needs to be sent
        //body=body.substringBeforeLast('');
        // body+=' ]}';
        
        //Authors:TP,VM Date: 02-NOV-2020 CR Number :JFW-02-NOV-2
        //To hold the FreightCode value from the comet order
        body+=' ],';
        body+='"ShipReference1": "'+FreightCode+'"';
        body+=' }';
        system.debug('XML body'+body);
        request.setBody(body);
        if(isBodyContainsItems)
        {           
            try
            {
                response=http.send(request);
                System.debug('response--->' +response);  
                resultantCometResponse=new CometResponse(cometOrder.Id,response.getStatus(),response.getStatusCode(),response.getBody(),orderNumber);
            }catch(exception e)
            {
                resultantCometResponse=new cometResponse(cometOrder.Id,'Not Submitted',400,e.getMessage(),orderNumber);
            }
        }
        else
            resultantCometResponse=new cometResponse(cometOrder.Id,'Not Submitted',400,'This Order doesn\'t have items.',orderNumber);
        
        if(resultantCometResponse==null)
            resultantCometResponse=new cometResponse();
        
        System.debug('resultantCometResponseresultantCometResponse--->' +resultantCometResponse);
        return resultantCometResponse;
    }
}