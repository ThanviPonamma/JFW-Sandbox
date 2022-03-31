//Authors:Sanjana    Date:11-11-2021
//Aim :1.To remove the selected comet order by updating the OrderDestinationItem__c with the custom field Is_Selected__c with false
     //2.To add the selected comet order by updating the OrderDestinationItem__c with the custom field Is_Selected__c with true
 
     public class InfiniumSendWaveAddOrRemoveOrders{
        //Authors:Sanjana    Date:11-11-2021
        //Aim : To add the selected comet order by updating the OrderDestinationItem__c with the custom field Is_Selected__c with true
        @AuraEnabled
        public static String addAvailableOrder(String selectedCometOrderId , String selectedProgramId , String selectedUserId){
            
                   //Declare a variable selectedCometOrders of type List<OrderDestination__c> 				
                   List<OrderDestination__c> selectedCometOrders  =new List<OrderDestination__c> ();						
                   //Declare a variable cometOrderToBeAdded  of type OrderDestination__c						
                   OrderDestination__c cometOrderToBeAdded  =new OrderDestination__c ();
                  //Declare a variable selectedCometOrderList of type List<OrderDestination__c>        				
                   List<OrderDestination__c> selectedCometOrderList = new List<OrderDestination__c>();	
                  //Declare an empty variable waveOrderRangeMessage of type string				
                   String waveOrderRangeMessage = '' ;	
                  //Check if the selectedCometOrderId has the value , if yes , fetch the ID from OrderDestination_c sObject where the Order Destination Id is same as the parameter selectedCometOrderId and store it in selectedCometOrders.									
            if(!String.isBlank(selectedCometOrderId )){
                selectedCometOrders=[SELECT Id,Comet_Order_Status__c 
                                        FROM OrderDestination__c
                                        WHERE Id=:selectedCometOrderId];
             }		
            
            
                  
            
                 //Invoke loadSelectedCometOrders method of InfiniumSendWaveOrders_Apex class and store the return value in a variable selectedCometOrderList .								
                   selectedCometOrderList = InfiniumSendWaveOrders_Apex.loadSelectedCometOrders(selectedProgramId , selectedUserId);
                   //Check if the size of selectedCometOrderList is greater than 59 , If yes , notify user with the message saying 'Order limit Exceeded - Maximum of only 60 orders can be submitted per wave'  which will be stored in a variable waveOrderRangeMessage  of type String.														
                   if(selectedCometOrderList.size()>59)						
                       {	
                           
                          waveOrderRangeMessage = 'Order limit Exceeded - Maximum of only 60 orders can be submitted per wave';						
                       }						
                   else						
                       { //If no, check if the selectedCometOrders list has any value , If yes,						
                          if(!selectedCometOrders.isEmpty())						
                               {	//Assign the first element of the list selectedCometOrders to the variable cometOrderToBeAdded  										
                                   cometOrderToBeAdded=selectedCometOrders[0];	
                                   //Assign Is_Selected__c field of cometOrderToBeAdded to true			
                                   cometOrderToBeAdded.Is_Selected__c=true;
                                   //Update the values of cometOrderToBeAdded in the database.			
                                   update cometOrderToBeAdded;	
                                   //Set the value  'Success' to the variable waveOrderRangeMessage 				
                                   waveOrderRangeMessage = 'Success';						
                               }						
                   }
            
              //Return waveOrderRangeMessage to the frontend.
              system.debug('cometOrderToBeAdded---->'+cometOrderToBeAdded);			     
              return waveOrderRangeMessage;						
            
        }
         
         //Authors : NK,SN, TP, VB ; Date: 01-07-2020
         //Aim : To remove the selected comet order and update the OrderDestinationItem__c with the custom field Is_Selected__c with false 
         @AuraEnabled
         public static void removeAvailableOrder(String selectedCometOrderId){						
                   //Declare a variable unselectedCometOrders of type List<OrderDestination__c> 								
                   List<OrderDestination__c> unselectedCometOrders = new List<OrderDestination__c> ();						
                   //Declare a variable cometOrderToBeRemoved of type OrderDestination__c					                        
                   OrderDestination__c cometOrderToBeRemoved =new OrderDestination__c ();						
                   //Check if the selectedCometOrderId has the value , if yes , fetch the ID from OrderDestination_c sObject where the Order Destination Id is same as the parameter selectedCometOrderId and store it in unselectedCometOrders .									
                   if(!String.isBlank(selectedCometOrderId )){
                     
                           unselectedCometOrders =[SELECT Id,Comet_Order_Status__c 
                                                   FROM OrderDestination__c 
                                                   WHERE Id=:selectedCometOrderId ];	
                   }						
                   //Check if the unselectedCometOrders  has value , if yes,			                    
                   if(!unselectedCometOrders.isEmpty()){						
                           //Assign the first element of the list unselectedCometOrdersto the variable cometOrderToBeRemoved								
                           cometOrderToBeRemoved  = unselectedCometOrders[0];	
                           //Assign Is_Selected__c field of cometOrderToBeRemoved to false			
                           cometOrderToBeRemoved.Is_Selected__c = false;
                           //Update the values of cometOrderToBeRemoved in the database.			
                           update cometOrderToBeRemoved ;						
                   }
             
                          system.debug('cometOrderToBeRemoved---->'+cometOrderToBeRemoved);
             
          }						
       
      }