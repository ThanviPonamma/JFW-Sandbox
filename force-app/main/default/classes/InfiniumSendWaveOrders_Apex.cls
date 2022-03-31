//Authors:Sanjana    Date:11-11-2021
//Aim of the class :1: To load the list of programs and list of users for the selected program and give it to the LWC component infiniumSendWaveOrdersProgramAndUserList
//2: To load the list of available comet orders and selected seasonal orders
public class InfiniumSendWaveOrders_Apex {
    
    //Authors:Sanjana    Date:11-11-2021
//Aim: Declaring a variable objAccount of type sObject Account
    public static Account objAccount;
    
//Authors:Sanjana    Date:11-11-2021
//Aim: The method getAccount() is responsible to fetch the Id, Name and Lightning_Community_URL__c of the account
    @AuraEnabled(cacheable=true)
    public static Account getAccount() { 
        
        //For the test class to identify the account
        if(Test.isRunningTest())
        {
            objAccount=[SELECT Id, Name,Lightning_Community_URL__c FROM Account
                        WHERE Name LIKE '%Infinium Spirits%' LIMIT 1];
        }
        else
        {
            //To fetch the Id, Name and Lightning_Community_URL__c of the account through the network Id.
           objAccount=[SELECT Id, Name,Lightning_Community_URL__c FROM Account
                       WHERE Lightning_Community_Id__c=:Network.getNetworkId() LIMIT 1];
            
        }
        return objAccount;
    }
    
//Authors : NK,SN, TP, VB ; Date: 29-06-2020
//Aim: The method loadProgramList() is responsible to fetch the active and closed programs from the sObject Program__c
    @AuraEnabled(cacheable=true)
    public static List<Program__c> loadProgramList(){
        //to fetch the account details from getAccount()
        objAccount=getAccount();
        
        //declaring a variable programlist of type List that holds the elements of the sObject Program__c
        List<Program__c> programList = new List<Program__c>();
        
        //the variable programList holds the result of the SOQL query
        programList = [SELECT Id, Name__c, Active__c, Program_Status__c
                       FROM Program__c 
                       WHERE Active__c = true AND Account__c =:objAccount.id AND Program_Status__c = 'Window Closed'];
        
        System.debug('programList--->'+programList);
        
        //returning the variable programList to the front end actor
        return programList;
    }
   
//Authors : NK,SN, TP, VB ; Date: 29-06-2020
//Aim: The method loadProgramList() is responsible to fetch the list of users who has created the orders for the selected program
 @AuraEnabled(cacheable=true)
 public static List <User> loadUserList(String selectedProgramId){	
     
     //to fetch the account details from getAccount()
        objAccount=getAccount();
     
     //declaring a variable userList of type List that holds the elements of sObject User
    List<User> userList = new List<User>();
     
     //check if the selectedProgramId has value. If so,
    if(String.isNotBlank(selectedProgramId ))														
    {	
        //fetch the owner Id from OrderDestinationItem__c with the following conditions and give it to the 
        //variable orderDestinationItemUserList of type OrderDestinationItem__c
    	List <OrderDestinationItem__c> orderDestinationItemUserList = [SELECT OrderDestination__r.Order__r.OwnerId 
                                                                       FROM OrderDestinationItem__c 
                                                                       WHERE OrderDestination__r.Order__r.Program__c=:selectedProgramId 
                                                                       AND Quantity__c >0 
                                                                       AND Quantity__c !=NULL 
                                                                       AND Order_Destination_Item_Status__c='Open' 
                                                                       AND Sent_To_Warehouse__c=false 
                                                                       AND On_Hold__c=false 
                                                                       AND Ready_To_Be_Sent__c=false 
                                                                       AND Warehouse_Transaction_Number__c=null 
                                                                       AND Wave_Order_Number__c=null];	
        
        //declare a variable ownerIdsList if type Set that holds the element Id                                                  
        Set<Id> ownerIdsList=new Set<Id> ();
        
        //Loop through the each sObject OrderDestinationItem__c held by the variable cometOrderItem of type sObject OrderDestinationItem__c 
        for(OrderDestinationItem__c cometOrderItem : orderDestinationItemUserList){
            //add OwnerId to the variable ownerIdsList
            ownerIdsList.add(cometOrderItem.OrderDestination__r.Order__r.OwnerId);	
        }														
             //Loop through the each User held by the variable infinium User of type sObject User
            //userIds holds the unique list of users in ownerIdsList variable 
            userList = [SELECT Name,Id FROM User WHERE Id IN :ownerIdsList];                                         
   															
    }	
    System.debug('Length--->'+userList.size());
    //returning the variable userList
    return userList ;														
 }
    
//Authors : NK,SN, TP, VB ; Date: 30-06-2020  
//Aim: To fetch the list of available comet orders based on selectedProgramId , selectedUserId and searchkeyWord
//Authors : NK,SN, TP, VB ; Date: 30-06-2020 
//updated on 02-07-2020 with searchkeyWord
 @AuraEnabled(cacheable=true)
    public static List <OrderDestination__c> loadAvailableCometOrders(String selectedProgramId, String selectedUserId, String searchkeyWord){
       
        //to fetch the account details from getAccount()
        objAccount=getAccount();
        
       //declaring a variable availableCometOrderList which is of the type List that holds the elements of sObject OrderDestination__c
       List<OrderDestination__c> availableCometOrderList = new List<OrderDestination__c> ();																										
            /***																										
            availableCometOrderList are loaded with following rules :																										
            1.CometOrderItem must have Ordered quantity (quantity mus be greater than 0)																										
            2.statuses of Comet order items must have 'Open' means resubmission will not be taken here.																										
            3.sent to warehouse flag should be false in third level.																										
            4.On_Hold__c flag should be false .																										
            5.Ready_To_Be_Sent__c flag should be false																										
            6.Warehouse_Transaction_Number__c must be null																										
            7.Is_Selected__c must be false																										
            ***/
            //declaring a variable unselectedAvailableCometOrder which is of the type List that holds the elements of sObject OrderDestination__c
            List<OrderDestination__c> unselectedAvailableCometOrder =new List<OrderDestination__c>();																										
  			
        	//check if there is a searchKeyWord. If so,
        	if(String.isNotBlank(searchkeyWord)){
                
                searchkeyWord='%'+searchkeyWord+'%';
                //fetch the available order details based on the selectedProgramId, selectedUserId and searchkeyWord and give it to a variable unselectedAvailableCometOrder
                unselectedAvailableCometOrder =[SELECT Id,Order__r.Program__r.Wave_Sequence_Number__c,
                                                (SELECT Id,Quantity__c 
                                                 FROM OrderDestinationItems__r 
                                                 WHERE Quantity__c >0 
                                                 AND Quantity__c !=NULL 
                                                 AND Order_Destination_Item_Status__c='Open' 
                                                 AND Sent_To_Warehouse__c=false 
                                                 AND On_Hold__c=false 
                                                 AND Ready_To_Be_Sent__c=false 
                                                 AND Warehouse_Transaction_Number__c=null 
                                                 AND Wave_Order_Number__c=null),Order__r.Program__r.Name__c,OrderName__c,Order__r.Owner.Name,											
                                                 Order__r.Order_Date__c,CreatedDate,AddressBook__r.Shipto_Name__c,AddressBook__r.Shipto_Company__c,											
                                                 AddressBook__r.City__c,AddressBook__r.State__r.State_Code__c,AddressBook__r.State__r.State_Name__c,
                                                 AddressBook__r.Zip__c,AddressBook__r.Active__c,											
                                                 AddressBook__r.Address__c,Comet_Order_Status__c,AddressBook__r.Destination_Name__c,AddressBook__r.Phone__c 
                                                 FROM OrderDestination__c WHERE Order__r.Account__c=:objAccount.Id 
                                                 AND Order__r.Program__c!=null 
                                                 AND Is_Selected__c=false 
                                                 AND Order__r.OwnerId =:selectedUserId 
                                                 AND Order__r.Program__c =:selectedProgramId 
                                                 AND (AddressBook__r.City__c  
                                                     LIKE:searchkeyWord OR AddressBook__r.Shipto_Name__c  
                                                     LIKE:searchkeyWord OR AddressBook__r.Shipto_Company__c  
                                                     LIKE:searchkeyWord) 
                                                ORDER BY OrderName__c DESC];											
                
            }	
        	//else fetch the available order details based on the selectedProgramId, selectedUserId and give it to a variable unselectedAvailableCometOrder
 					
        else{
            unselectedAvailableCometOrder =[SELECT Id,Order__r.Program__r.Wave_Sequence_Number__c,
                                           (SELECT Id,Quantity__c 
                                            FROM OrderDestinationItems__r 
                                            WHERE Quantity__c >0 
                                            AND Quantity__c !=NULL 
                                            AND Order_Destination_Item_Status__c='Open' 
                                            AND Sent_To_Warehouse__c=false 
                                            AND On_Hold__c=false 
                                            AND Ready_To_Be_Sent__c=false 
                                            AND Warehouse_Transaction_Number__c=null 
                                            AND Wave_Order_Number__c=null),Order__r.Program__r.Name__c,OrderName__c,Order__r.Owner.Name,																										
                                            Order__r.Order_Date__c,CreatedDate,AddressBook__r.Shipto_Name__c,AddressBook__r.Shipto_Company__c,																										
                                            AddressBook__r.City__c,AddressBook__r.State__r.State_Code__c,AddressBook__r.State__r.State_Name__c,
                                            AddressBook__r.Zip__c,AddressBook__r.Active__c,																										AddressBook__r.Address__c,Comet_Order_Status__c,AddressBook__r.Destination_Name__c,AddressBook__r.Phone__c 
                                            FROM OrderDestination__c 
                                            WHERE Order__r.Account__c=:objAccount.Id 
                                            AND Order__r.Program__c=:selectedProgramId
                                            AND Order__r.OwnerId=:selectedUserId
                                            AND Order__r.Program__c!=null 
                                            AND Is_Selected__c=false 
                                            ORDER BY OrderName__c DESC];
        }
               
        	//Loop through each of the sObject OrderDestination__c held in the variable cometOrder. If so,
            for(OrderDestination__c cometOrder:unselectedAvailableCometOrder )																										
            {	
                //check if the size of the OrderDestinationItems is greater than 0
                if(cometOrder.OrderDestinationItems__r.size()>0)
                //add each variable cometOrder in the loop to the list availableCometOrderList
                availableCometOrderList.add(cometOrder);																										
            }																										
			system.debug('availableCometOrderList---->'+availableCometOrderList);
        	//returning the variable availableCometOrderList
            return availableCometOrderList ;																										
}	
    
 //Authors : NK,SN, TP, VB ; Date: 30-06-2020 
 //Aim: To fetch the list of selected seasonal available comet orders     
 @AuraEnabled(cacheable=true)
    public static List<OrderDestination__c> loadSelectedCometOrders(String selectedProgramId , String selectedUserId){
        
         //to fetch the account details from getAccount()
        objAccount=getAccount();
        
       //declaring a variable selectedCometOrderList  which is of the type List that holds the elements of sObject OrderDestination__c
       List<OrderDestination__c> selectedCometOrderList  = new List<OrderDestination__c> ();																										
            /***																										
            selectedCometOrderList are loaded with following rules :																										
            1.CometOrderItem must have Ordered quantity (quantity mus be greater than 0)																										
            2.statuses of Comet order items must have 'Open' means resubmission will not be taken here.																										
            3.sent to warehouse flag should be false in third level.																										
            4.On_Hold__c flag should be false .																										
            5.Ready_To_Be_Sent__c flag should be false																										
            6.Warehouse_Transaction_Number__c must be null																										
            7.Is_Selected__c must be true																										
            ***/
            //declaring a variable selectedAvailableCometOrder which is of the type List that holds the elements of sObject OrderDestination__c
            List<OrderDestination__c> selectedAvailableCometOrder =new List<OrderDestination__c>();																										
            selectedAvailableCometOrder =[SELECT Id,Order__r.Program__r.Wave_Sequence_Number__c,
                                           (SELECT Id,Quantity__c 
                                            FROM OrderDestinationItems__r 
                                            WHERE Quantity__c >0 
                                            AND Quantity__c !=NULL 
                                            AND Order_Destination_Item_Status__c='Open' 
                                            AND Sent_To_Warehouse__c=false 
                                            AND On_Hold__c=false 
                                            AND Ready_To_Be_Sent__c=false 
                                            AND Warehouse_Transaction_Number__c=null 
                                            AND Wave_Order_Number__c=null),Order__r.Program__r.Name__c,OrderName__c,Order__r.Owner.Name,																										
                                            Order__r.Order_Date__c,CreatedDate,AddressBook__r.Shipto_Name__c,AddressBook__r.Shipto_Company__c,																										
                                            AddressBook__r.City__c,AddressBook__r.State__r.State_Code__c,AddressBook__r.State__r.State_Name__c,
                                            AddressBook__r.Zip__c,AddressBook__r.Active__c,																										AddressBook__r.Address__c,Comet_Order_Status__c,AddressBook__r.Destination_Name__c,AddressBook__r.Phone__c 
                                            FROM OrderDestination__c 
                                            WHERE Order__r.Account__c=:objAccount.Id 
                                            AND Order__r.Program__c=:selectedProgramId
                                            AND Order__r.OwnerId=:selectedUserId
                                            AND Order__r.Program__c!=null 
                                            AND Is_Selected__c=true 
                                            ORDER BY OrderName__c DESC];
        
        	//Loop through each of the sObject OrderDestination__c held in the variable cometOrder. If so,
            for(OrderDestination__c cometOrder:selectedAvailableCometOrder )																										
            {	
                //check if the size of the OrderDestinationItems is greater than 0
                if(cometOrder.OrderDestinationItems__r.size()>0)
                //add each variable cometOrder in the loop to the list availableCometOrderList
                selectedCometOrderList.add(cometOrder);																										
            }																										
			
        	//returning the variable selectedCometOrderList
        	system.debug('selectedCometOrderList-->'+selectedCometOrderList);
            return selectedCometOrderList ;						
        
        
    }    
   
 //Authors : NK,SN, TP, VB ; Date: 30-06-2020 
 //Aim: To fetch the list of selected seasonal available comet orders     
 @AuraEnabled(cacheable=true)
    public static List<OrderDestinationItem__c> loadPosItemsForCometOrder(String selectedOrderDestinationId){   
        
        //to fetch the account details from getAccount()
        objAccount=getAccount();
        
         //Declaring a variable of type List to hold the details of the orderDestinationItemsList
        List<OrderDestinationItem__c> orderDestinationItemsList = new List<OrderDestinationItem__c>();
        
        //Holds the details for comet items for the selected comet order id 
        orderDestinationItemsList = [SELECT POS_Item__r.Id,							
                                     POS_Item__r.Item_No__c,							
                                     POS_Item__r.Item_Name__c,							
                                     POS_Item__r.Brand__r.Brand_Name__c,							
                                     POS_Item__r.Type_of_Item__r.Item_Type__c,							
                                     Quantity__c,							
                                     POS_Item__r.Pack_Of__c 
                                     FROM OrderDestinationItem__c							
                                     WHERE OrderDestination__c=:selectedOrderDestinationId AND							
                                     On_Hold__c = false AND	Quantity__c>0 AND 						
									 OrderDestination__r.Order__r.Account__c=:objAccount.Id							
									 ];	
        
        		// to return the list of comet ordered items
        		return orderDestinationItemsList;
							}							
    	
}