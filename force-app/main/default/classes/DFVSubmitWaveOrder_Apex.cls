//Authors : NK,SN, TP, VB ; Date: 02-07-2020
//Aim:Responsible to send the selected seasonal orders to the warehouse 

public class DFVSubmitWaveOrder_Apex {
    //Authors : NK,SN, TP, VB ; Date: 02-07-2020
    //Aim :1:To check if the order limit is exceeding . i..e if the number of order is exceeding 60 
         //2: To invoke the method DFVSendWaveOrders_apex.loadSelectedCometOrders(selectedProgramId : String, selectedUserId : String)
         //3:To invoke DFVSubmitWaveOrder_Apex.updateProgramAndOrderDestinationItem(cometOrdersToBeSent)"	
 @AuraEnabled					  
    public static String submitSelectedOrdersToComet(String selectedProgramId ,String selectedUserId){	
        //Declare a variable cometOrdersToBeSent of type List<OrderDestination__c>
        List<OrderDestination__c> cometOrdersToBeSent =new List<OrderDestination__c>();
        //Declare an empty variable messageToDisplay		
        String messageToDisplay = '';	
        //Invoke the method DFVSendWaveOrders_apex.loadSelectedCometOrders(selectedProgramId : String, selectedUserId : String) and save it in the variable cometOrdersToBeSent of type List<OrderDestination__c>																						
        cometOrdersToBeSent = DFVSendWaveOrders_Apex.loadSelectedCometOrders(selectedProgramId,selectedUserId);
        //To check cometOrdersToBeSent  variable ,if the orders in the variable is  exceeding the limit i.e if the number of order is exceeding 60 , 
        //If yes , alert the user with the warning message that the order limit is exceeded which is stored in messageToDisplay variable.			
        if(cometOrdersToBeSent.size()>60)					
            {					
               messageToDisplay = 'Order limit Exceeded - Maximum of only 60 orders can be submitted per wave'; 					
            }
        //If no ,call the method updateProgramAndOrderDestinationItem(cometOrdersToBeSent) for the further processing send 'Done' message to the user which is stored in messageToDisplay.									
        else					
            {	
                system.debug('cometOrdersToBeSent--->'+cometOrdersToBeSent);
               updateProgramAndOrderDestinationItem(cometOrdersToBeSent);					
               messageToDisplay = 'Done';					
            }
        //return the variable messageToDisplay to the front end
        return messageToDisplay;
        
        }
    
    //Authors : NK,SN, TP, VB ; Date: 02-07-2020
    //Aim :"1:To update the OrderDestinationItem__c sObject with the following values:
/**a. Ready_To_Be_Sent__c must be true
b. Order_Destination_Item_Status__c must be  sendingToWarehouse
c. Wave_Order_Number__c must be generated.
d. Wave_Order_Sent_By__c must be the logged in user Id
e. Wave_Order_Date_Time__c must be the current date and time
2: To update the OrderDestination__c sObject with the following values:
a. Comet_Order_Status__c must be sendToComet
3: To update the Program__c  sObject with the following values:
a. i) Wave_Sequence_Number__c must be 0  if Wave_Sequence_Number__c is null
    ii) Wave_Sequence_Number__c must be incremented by 1 for every selected Order Destinations."**/	
     @AuraEnabled
    public static String updateProgramAndOrderDestinationItem(List<OrderDestination__c> cometOrdersToBeSent){											
			
			//Declare an empty string messageToDisplay.					
            String messageToDisplay = '';
            //Declare a variable sendingToWarehouse of type string holding 'Sending to Warehouse'					
			String sendingToWarehouse = 'Sending to Warehouse';
           //Declare a variable SendToComet of type string holding 'Send to Comet'	
            String sendToComet = 'Send to Comet';
           //Declare a variable cometOrderItemsToBeSent of type List<OrderDestinationItem__c> 
            List<OrderDestinationItem__c> cometOrderItemsToBeSent=new List<OrderDestinationItem__c> ();	
           //Declare a variable programIdsAndWaveSeqNumbers_Map of type Map<Id, Integer>					
            Map<Id,Integer> programIdsAndWaveSeqNumbers_Map=new Map<Id,Integer> ();	
           //Declare a variable currentProgramsByChosenOrders of type Program__c				
            Program__c currentProgramsByChosenOrders=new Program__c();	
           //For every Order destination check if the list order destination items is not empty, If yes ,					
            for(OrderDestination__c cometOrder : cometOrdersToBeSent)											   
                {											
                if(!cometOrder.OrderDestinationItems__r.isEmpty())											
                  {		/** For every order destination Items in the order destination update the following field values:
                              a: Ready_To_Be_Sent__c must be true
                              b. Order_Destination_Item_Status__c must be  sendingToWarehouse
                              c. Wave_Order_Number__c must be generated.
                              d. Wave_Order_Sent_By__c must be the logged in user Id
                              e. Wave_Order_Date_Time__c must be the current date and time"
                              Add the incoming comet order to the list cometOrderItemsToBeSent  **/													
                        for(OrderDestinationItem__c cometOrderItem : cometOrder.OrderDestinationItems__r)											
                        {											
                        cometOrderItem.Ready_To_Be_Sent__c=true;											
                        cometOrderItem.Order_Destination_Item_Status__c = sendingToWarehouse; 											
                                                                    
                        cometOrderItem.Wave_Order_Number__c=cometOrder.OrderName__c+'_W'+String.valueOf((cometOrder.Order__r.Program__r.Wave_Sequence_Number__c==null?0:cometOrder.Order__r.Program__r.Wave_Sequence_Number__c)+1); 											
                        cometOrderItem.Wave_Order_Sent_By__c=UserInfo.getUserId();											
                        cometOrderItem.Wave_Order_Date_Time__c=System.now();											
                        cometOrderItemsToBeSent.add(cometOrderItem);											
                        }
                      system.debug('cometOrderItemsToBeSent--->'+cometOrderItemsToBeSent);
                      /** For the incoming order destination update the following values of the field in OrderDestination__c:
                           a:Comet_Order_Status__c must be sendToComet
                           b:update the Program__c  sObject with the following values:.
                            i) Wave_Sequence_Number__c must be 0  if Wave_Sequence_Number__c is null
                            ii) Wave_Sequence_Number__c must be incremented by 1 for every selected Order Destinations
                               and put into a variable programIdsAndWaveSeqNumbers_Map ."**/					
                      
                    programIdsAndWaveSeqNumbers_Map.put(cometOrder.Order__r.Program__c,Integer.valueOf((cometOrder.Order__r.Program__r.Wave_Sequence_Number__c==null?0:cometOrder.Order__r.Program__r.Wave_Sequence_Number__c)+1));											
                    cometOrder.Comet_Order_Status__c = sendToComet;
                      
                  }
                    
               }
        
            //10: Select Id and Wave Order Sequence Number from Program where the Id are in the variable programIdsAndWaveSeqNumbers_Map and
            // store it in the variable currentProgramsByChosenOrders of type List<Program__c>					
            currentProgramsByChosenOrders=[SELECT Id,Wave_Sequence_Number__c FROM Program__c WHERE Id IN : programIdsAndWaveSeqNumbers_Map.keySet()];	
        
        /**"For every programId in currentProgramsByChosenOrders update the following values of the fields in program:
                i)Wave_Sequence_Number__c must be 0  if Wave_Sequence_Number__c is null
                ii) Wave_Sequence_Number__c must be incremented by 1 for every selected Order Destinations.**/
       					
											
                    if(currentProgramsByChosenOrders.Wave_Sequence_Number__c==null)											
                    currentProgramsByChosenOrders.Wave_Sequence_Number__c=0;											
                    if(Integer.valueOf(currentProgramsByChosenOrders.Wave_Sequence_Number__c+1)==programIdsAndWaveSeqNumbers_Map.get(currentProgramsByChosenOrders.Id))											
                    currentProgramsByChosenOrders.Wave_Sequence_Number__c=programIdsAndWaveSeqNumbers_Map.get(currentProgramsByChosenOrders.Id);											
                
        
        //Check if the variables cometOrderItemsToBeSent , cometOrdersToBeSent and currentProgramsByChosenOrders  is not empty, If yes ,							
         if(!cometOrderItemsToBeSent.isEmpty() && !cometOrdersToBeSent.isEmpty() && currentProgramsByChosenOrders!=null)											
            {		
                /**update the following variables :
                  i:cometOrderItemsToBeSent                                                                                       
                  ii:currentProgramsByChosenOrders                                                                                       
                  iii:cometOrdersToBeSent in the database and send Done  which will be stored in messageToDisplay variable of type String  to the called method.**/                                                                                  							
                update cometOrderItemsToBeSent;											
                update currentProgramsByChosenOrders;											
                update cometOrdersToBeSent;											
                messageToDisplay = 'Done';											
            }											
            else											
            {	//If the any of the above mentioned variables are empty , send the error message to the user which is stored in messageToDisplay variable.																	
                messageToDisplay = 'The Wave Order cannot be sent ,Please contact System Administrator or helpdesk.';											
            }
            //Return the variable messageToDisplay to the front end.				
            return messageToDisplay ;											
   }
    
    
}