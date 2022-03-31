public class DFVItemTypeListCmpController {
    public static Account objAccount;
    public static Account getAccount() {
        
        if(Test.isRunningTest())
        {
            objAccount=[SELECT Id, Name FROM Account
                        WHERE Name LIKE '%DFV%' LIMIT 1];
        }
        else
        {
            objAccount=[SELECT Id, Name FROM Account
                        WHERE Lightning_Community_Id__c=:Network.getNetworkId() LIMIT 1];
        }
        return objAccount;
    }
    @AuraEnabled
    public static ItemTypeListWithNames getItemTypeList() {
        objAccount=getAccount();
        List<Item_Type__c> itemTypeList = new List<Item_Type__c>();
        List<String> itemTypeNamesForValidation=new List<String> ();
        for(Item_Type__c itemType :[SELECT Id, Item_Type__c, Account__c, Active__c FROM Item_Type__c
                                    WHERE Account__c=:objAccount.Id ORDER BY Item_Type__c])
        {
            itemTypeNamesForValidation.add(itemType.Item_Type__c.remove(' ').trim().toUppercase());
            itemTypeList.add(itemType);
        }
        return new ItemTypeListWithNames(itemTypeList,itemTypeNamesForValidation);
        
    }
    @AuraEnabled
    public static ItemTypeListWithNames addItemType(Item_Type__c selectedItemType) {
        try{
            objAccount=getAccount();
            selectedItemType.Account__c= objAccount.Id;
            upsert selectedItemType;
            
        }
        catch(exception ex){
            DFVEmailNotifications.sendNotification('Inserting a Item Type',ex.getMessage()+'\n'+'Inputs are -- selectedItemType-- '+JSON.serialize(selectedItemType)
                                                   +'\n'+'Class Name - DFVItemTypeListCmpController '+'-- Line number --'+ex.getLineNumber());
        }
        return getItemTypeList();       
    }
    @AuraEnabled
    public static ItemTypeListWithNames deactivateItemTypeApex(Item_Type__c selectedItemType) {
        try{
            selectedItemType.Active__c=false;
            update selectedItemType;
        }
        catch(exception ex){
            DFVEmailNotifications.sendNotification('Deactivating a Item Type',ex.getMessage()+'\n'+'Inputs are -- selectedItemType-- '+JSON.serialize(selectedItemType)
                                                   +'\n'+'Class Name - DFVItemTypeListCmpController '+'-- Line number --'+ex.getLineNumber());
        }
        
        return getItemTypeList();        
    }
    public class ItemTypeListWithNames
    {
        @AuraEnabled
        public List<Item_Type__c> itemTypeList;
        @AuraEnabled
        public List<String> itemTypeNamesForValidation;
        public ItemTypeListWithNames(List<Item_Type__c> itemTypeList,List<String> itemTypeNamesForValidation)
        {
            this.itemTypeList=itemTypeList;
            this.itemTypeNamesForValidation=itemTypeNamesForValidation;
        }
    }
    
}