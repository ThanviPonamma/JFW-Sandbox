//Authors : SN, TP, VB, JP; Date: 29-06-2020
//Aim :
//1. To add Pos item  in Available Items table to Withheld Items Table if the remaining orders size is greater than 0
//2. To remove the Pos item  in Withheld Items table and put it back to Available Items Table
public class DFVWaveOrdersAddOrRemovePosItems_Apex {
    
//Authors : SN, TP, VB, JP; Date: 29-06-2020
//Aim: Declaring a variable objAccount of type sObject Account
    public static Account objAccount;
    
//Authors : SN, TP, VB, JP; Date: 29-06-2020
//Aim: The method getAccount() is responsible to fetch the Id, Name and Lightning_Community_URL__c of the account
    @AuraEnabled(cacheable=true)
    public static Account getAccount() { 
        
        //For the test class to identify the account
        if(Test.isRunningTest())
        {
            objAccount=[SELECT Id, Name,Lightning_Community_URL__c FROM Account
                        WHERE Name LIKE '%DFV%' LIMIT 1];
        }
        else
        {
            //To fetch the Id, Name and Lightning_Community_URL__c of the account through the network Id.
            objAccount=[SELECT Id, Name,Lightning_Community_URL__c FROM Account
                        WHERE Lightning_Community_Id__c=:Network.getNetworkId() LIMIT 1];
             
        }
        return objAccount;
    }
    
//Authors : SN, TP, VB, JP; Date: 29-06-2020
//Aim: The method addItemToWithheldItems() is responsible to update the field value On_Hold__c in the sObjects OrderDestinationItem__c and Program_Item__c to true 
    @AuraEnabled
	public static String addItemToWithheldItems (String selectedProgramId,String selectedPosItemId)													
    {
        //to fetch the account details from getAccount()
        objAccount=getAccount();
        //Declare a variable orderDestinationItemsList which is of the datatype List that holds the elements of sObject OrderDestinationItem__c							
        List<OrderDestinationItem__c> orderDestinationItemsList;
        
        //Declare a variable programItems which is of the datatype List that holds the elements of sObject Program_Item__c								
        List<Program_Item__c> programItems;	
        
        //To fetch the fields Id and On_Hold__c  from OrderDestinationItem__c whose program matches the selected program id and pos item id by the user 
        //and the below conditions and storing it in variable orderDestinationItemsList 												
        orderDestinationItemsList=[SELECT Id,On_Hold__c 
                                   FROM OrderDestinationItem__c 
                                   WHERE OrderDestination__r.Order__r.Program__c=:selectedProgramId 
                                   AND Pos_Item__c=:selectedPosItemId 
                                   AND OrderDestination__r.Order__r.Account__c=:objAccount.Id													
        						   AND Order_Destination_Item_Status__c='Open' 
                                   AND On_Hold__c=false 
                                   AND Sent_To_Warehouse__c=false 
                                   AND Ready_To_Be_Sent__c=false 
                                   AND Wave_Order_Number__c=null 
                                   AND Warehouse_Transaction_Number__c=null];	
        system.debug('orderDestinationItemsList--->'+orderDestinationItemsList);
        //To fetch the fields Id and On_Hold__c  from Program_Item__c whose program matches the selected program id and pos item id by the user 
        //and On_Hold__c value is false and store it in the variable programItems 											
        programItems=[SELECT Id,On_Hold__c 
                      FROM Program_Item__c 
                      WHERE Program__c=:selectedProgramId 
                      AND Pos_Item__c=:selectedPosItemId 
                      AND On_Hold__c=false]; 
        system.debug('programItems--->'+programItems);
        //For all the orderDestinationItemsList held by the variable orderDestinationItem of datatype OrderDestinationItem__c , 
        //set the custom field value On_Hold__c to true									
        for(OrderDestinationItem__c orderDestinationItem : orderDestinationItemsList){

            orderDestinationItem.On_Hold__c =true;	
        }													
        
        //For all the programItems held by the variable programItem of datatype Program_Item__c , 
        //set the custom field value On_Hold__c to true									
        for(Program_Item__c programItem:programItems){

            programItem.On_Hold__c =true;													
        }													
    	
        //check if the orderDestinationItemsList has data. If so, update orderDestinationItemsList
        if(orderDestinationItemsList!=null)													
        update orderDestinationItemsList;	
        
        system.debug('orderDestinationItemsList--->'+orderDestinationItemsList);
        
        //check if the programItems has data. If so, update programItems
        if(programItems!=null)													
        update programItems;
        
        system.debug('programItems--->'+programItems);
        
        //return the message Done
        return 'Done';													
    }
    
//Authors : SN, TP, VB, JP; Date: 29-06-2020
//Aim: The method addItemToWithheldItems() is responsible to update the field value On_Hold__c in the sObjects OrderDestinationItem__c and Program_Item__c to false 
    @AuraEnabled
	public static String removeItemFromWithheldItems (String selectedProgramId,String selectedPosItemId)													
    {
        //to fetch the account details from getAccount()
        objAccount=getAccount();
        //Declare a variable orderDestinationItemsList which is of the datatype List that holds the elements of sObject OrderDestinationItem__c							
        List<OrderDestinationItem__c> orderDestinationItemsList;
        
        //Declare a variable programItems which is of the datatype List that holds the elements of sObject Program_Item__c								
        List<Program_Item__c> programItems;	
        
        //To fetch the fields Id and On_Hold__c  from OrderDestinationItem__c whose program matches the selected program id and pos item id by the user 
        //and the below conditions and storing it in variable orderDestinationItemsList 												
        orderDestinationItemsList=[SELECT Id,On_Hold__c 
                                   FROM OrderDestinationItem__c 
                                   WHERE OrderDestination__r.Order__r.Program__c=:selectedProgramId 
                                   AND Pos_Item__c=:selectedPosItemId 
                                   AND OrderDestination__r.Order__r.Account__c=:objAccount.Id													
        						   AND Order_Destination_Item_Status__c='Open' 
                                   AND On_Hold__c=true 
                                   AND Sent_To_Warehouse__c=false 
                                   AND Ready_To_Be_Sent__c=false 
                                   AND Wave_Order_Number__c=null 
                                   AND Warehouse_Transaction_Number__c=null];	
        system.debug('orderDestinationItemsList--->'+orderDestinationItemsList);
        //To fetch the fields Id and On_Hold__c  from Program_Item__c whose program matches the selected program id and pos item id by the user 
        //and On_Hold__c value is true and store it in the variable programItems 											
        programItems=[SELECT Id,On_Hold__c 
                      FROM Program_Item__c 
                      WHERE Program__c=:selectedProgramId 
                      AND Pos_Item__c=:selectedPosItemId 
                      AND On_Hold__c=true]; 
        system.debug('programItems--->'+programItems);
        //For all the orderDestinationItemsList held by the variable orderDestinationItem of datatype OrderDestinationItem__c , 
        //set the custom field value On_Hold__c to false									
        for(OrderDestinationItem__c orderDestinationItem : orderDestinationItemsList){

            orderDestinationItem.On_Hold__c =false;	
        }													
        
        //For all the programItems held by the variable programItem of datatype Program_Item__c , 
        //set the custom field value On_Hold__c to false									
        for(Program_Item__c programItem:programItems){

            programItem.On_Hold__c =false;													
        }													
    	
        //check if the orderDestinationItemsList has data. If so, update orderDestinationItemsList
        if(orderDestinationItemsList!=null)													
        update orderDestinationItemsList;	
        
        system.debug('orderDestinationItemsList--->'+orderDestinationItemsList);
        
        //check if the programItems has data. If so, update programItems
        if(programItems!=null)													
        update programItems;
        
        system.debug('programItems--->'+programItems);
        
        //return the message Done
        return 'Done';													
    }
    
																								
}