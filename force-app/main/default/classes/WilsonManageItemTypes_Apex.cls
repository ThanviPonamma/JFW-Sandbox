/**Authors : TP,VM
* Date: 05/01/2021
*  Aim : To get all the item types, deactivating the selected item type and add/update an item type.*/

public class WilsonManageItemTypes_Apex {
    
    public static Account objAccount;
    //To fetch account details of Wilson Daniels
    public static Account getAccount() {
        
        if(Test.isRunningTest())
        {
            objAccount=[SELECT Id, Name FROM Account
                        WHERE Name LIKE '%Wilson Daniels%' LIMIT 1];
        }
        else
        {
            objAccount=[SELECT Id, Name, Lightning_Community_Id__c FROM Account
                        WHERE Lightning_Community_Id__c=:Network.getNetworkId() LIMIT 1];
			String query = ('SELECT Id,TrackingNos__c,(SELECT Id,Field,CreatedDate,NewValue,OldValue FROM Histories WHERE Field=\'Comet_Order_Status__c\') FROM OrderDestination__c WHERE (NOT Shipping_Method__r.Shipping_Method_Name__c LIKE "%Overnight%") AND OrdStatus__c!=\'Shipped\' AND OrdStatus__c!=\'Open\' AND OrdStatus__c!=\'\' AND Order__r.Program__c=null AND WarehouseTransactionNo__c!=\'\' AND OrdStatus__c!=\'Closed\' AND OrdStatus__c!=\'Cancelled\' AND CreatedDate > 2021-01-01T00:00:00Z AND Alert_User_For_Not_Shipped_Orders__c=false LIMIT 10' );
             List<OrderDestination__c> cometOrders=Database.query(query);
            System.debug(cometOrders);
        }
        return objAccount;
    }
    
    //To get the list of item types.
    @AuraEnabled(cacheable = true)
    public static ItemTypeListWithNames_Wrapper getItemTypeList() {
        // to hold the account details for Wilson Daniels
        objAccount=getAccount();
        //To hold the list of item type that belongs to Wilson Daniels
        List<Item_Type__c> itemTypeList = new List<Item_Type__c>();
        //to hold the  item name for validations
        List<String> itemTypeNamesForValidation=new List<String> ();
        //to get each item type and validate the item type name
        for(Item_Type__c itemType :[SELECT Id, Item_Type__c, Account__c, Active__c FROM Item_Type__c
                                    WHERE Account__c=:objAccount.Id ORDER BY Item_Type__c])
        {
            itemTypeNamesForValidation.add(itemType.Item_Type__c.remove(' ').trim().toUppercase());
            itemTypeList.add(itemType);
        }
        // to return the item type and item type names validations
        System.debug('itemTypeList-->'+itemTypeList);
        System.debug('itemTypeNamesForValidation-->'+itemTypeNamesForValidation);
        return new ItemTypeListWithNames_Wrapper(itemTypeList,itemTypeNamesForValidation);
        
    }
    
    //To deactivate the selected brand by the user.
    @AuraEnabled
    public static String deactivateItemType(Item_Type__c selectedItemType) {
        //the selected item type to be deactivated
        try{
            System.debug('selectedItemType-->'+selectedItemType);
            selectedItemType.Active__c=false;
            update selectedItemType;
            System.debug('done');
            return 'done';
        }
        //in case of exception an email is sent to the system admin
        catch(exception ex){
            WilsonEmailNotifications.sendNotification('Deactivating a Item Type',ex.getMessage()+'\n'+'Inputs are -- selectedItemType-- '+JSON.serialize(selectedItemType)
                                                      +'\n'+'Class Name - WilsonManageItemTypes_Apex '+'-- Line number --'+ex.getLineNumber());
            System.debug('not done');
            return 'not done';
        }
        
        
    }
    
    //To hold the item type list along with the validations for the item name in the item type list.
    public class ItemTypeListWithNames_Wrapper
    {
        @AuraEnabled
        public List<Item_Type__c> itemTypeList;//to hold the item type list
        @AuraEnabled
        public List<String> itemTypeNamesForValidation;//to hold the item name validation
        public ItemTypeListWithNames_Wrapper(List<Item_Type__c> itemTypeList,List<String> itemTypeNamesForValidation)
        {
            this.itemTypeList=itemTypeList;
            this.itemTypeNamesForValidation=itemTypeNamesForValidation;
        }
    }
    
    //To add or edit the item type.
    @AuraEnabled
    public static String addOrEditItemType(Item_Type__c selectedItemType) {
        //to add/edit the value send from the front end.
        try{
            
            objAccount=getAccount();
            selectedItemType.Account__c= objAccount.Id;
            Item_Type__c itemType = selectedItemType;
            upsert itemType;
            System.debug('done');
            return 'done';
            
        }
        //in case of exception an email is sent to the system admin
        catch(exception ex){
            WilsonEmailNotifications.sendNotification('Inserting a Item Type',ex.getMessage()+'\n'+'Inputs are -- selectedItemType-- '+JSON.serialize(selectedItemType)
                                                      +'\n'+'Class Name - WilsonManageItemTypes_Apex '+'-- Line number --'+ex.getLineNumber());
            System.debug('not done');
            return 'not done';                                       
        }
    }
    
}