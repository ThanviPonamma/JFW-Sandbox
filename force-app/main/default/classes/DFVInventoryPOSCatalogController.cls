public class DFVInventoryPOSCatalogController
{
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
        
    /*Authors: TP,VB date:12-02-2021 cr no: DFV-12-Feb-28 
	*the below lines are commenetd to meet the requirements of the CR
	
    @AuraEnabled
    public static List<POS_Item__c> getPOSItemList_Apex()
    {
        List<POS_Item__c> posItemList = new List<POS_Item__c> ();
        String Inventory= 'Inventory';
        String Both= 'Both';
        String profileName=[Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
        if(profileName == 'DFVsalesmanager' || profileName =='DFVBrandmanager') {
            posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
                         Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Expiration_Date__c,ExpirationDateRequired__c,Item_Descrption__c,
                         LotNumberRequired__c, Account__c, Active__c ,Image_of_Item__c,Length__c,Width__c,Height__c,Weight__c,Low_inventory_level_applicable__c,
                         Low_Inventory_Level__c,Maximum_order_quantity_applicable__c,Maximum_Order_Qty__c,Marketing_Only__c,Inventory_Seasonal_Program__c,Available_Stock__c,HarmonizationCode__c
                         FROM POS_Item__c WHERE Active__c =true
                         AND ( Inventory_Seasonal_Program__c=:Inventory OR  Inventory_Seasonal_Program__c=:Both) AND Logical_Invenory_Stock__c>0 AND Marketing_Only__c=false
                         ORDER BY Item_Name__c];
        }
        else {
            posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
                         Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Expiration_Date__c,ExpirationDateRequired__c,Item_Descrption__c,
                         LotNumberRequired__c, Account__c, Active__c ,Image_of_Item__c,Length__c,Width__c,Height__c,Weight__c,Low_inventory_level_applicable__c,
                         Low_Inventory_Level__c,Maximum_order_quantity_applicable__c,Maximum_Order_Qty__c,Marketing_Only__c,Inventory_Seasonal_Program__c,Available_Stock__c,HarmonizationCode__c
                         FROM POS_Item__c WHERE Active__c =true AND ( Inventory_Seasonal_Program__c=:Inventory OR  Inventory_Seasonal_Program__c=:Both) AND Logical_Invenory_Stock__c>0
                         ORDER BY Item_Name__c];
        }
        return posItemList;
        
    }*/
        /*Authors: TP,VB date:12-02-2021 cr no: DFV-12-Feb-28 
	*the below lines are commenetd to meet the requirements of the CR */
    @AuraEnabled
    public static List<POS_Item__c> getPOSItemList_Apex()
    {
        //To hold the account details
        objAccount=getAccount();
        //to hold pos item list
        List<POS_Item__c> posItemList = new List<POS_Item__c> ();
        String Inventory= 'Inventory';
        String Both= 'Both';
        //to hold profile name 
        String profileName=[Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
        if(profileName == 'DFVsalesmanager' || profileName =='DFVBrandmanager') {
            posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
                         Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Expiration_Date__c,ExpirationDateRequired__c,Item_Descrption__c,
                         LotNumberRequired__c, Account__c, Active__c ,Image_of_Item__c,Length__c,Width__c,Height__c,Weight__c,Low_inventory_level_applicable__c,
                         Low_Inventory_Level__c,Maximum_order_quantity_applicable__c,Maximum_Order_Qty__c,Marketing_Only__c,Inventory_Seasonal_Program__c,Available_Stock__c,HarmonizationCode__c
                         FROM POS_Item__c WHERE Active__c =true AND Account__c=:objAccount.Id
                         AND ( Inventory_Seasonal_Program__c=:Inventory OR  Inventory_Seasonal_Program__c=:Both) AND Logical_Invenory_Stock__c>0 AND Marketing_Only__c=false
                         ORDER BY Item_Name__c];
        }
        else {
            posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
                         Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Expiration_Date__c,ExpirationDateRequired__c,Item_Descrption__c,
                         LotNumberRequired__c, Account__c, Active__c ,Image_of_Item__c,Length__c,Width__c,Height__c,Weight__c,Low_inventory_level_applicable__c,
                         Low_Inventory_Level__c,Maximum_order_quantity_applicable__c,Maximum_Order_Qty__c,Marketing_Only__c,Inventory_Seasonal_Program__c,Available_Stock__c,HarmonizationCode__c
                         FROM POS_Item__c WHERE Active__c =true AND ( Inventory_Seasonal_Program__c=:Inventory OR  Inventory_Seasonal_Program__c=:Both) AND Logical_Invenory_Stock__c>0 AND Account__c=:objAccount.Id
                         ORDER BY Item_Name__c];
        }
        return posItemList;
        
    }
    @AuraEnabled 
    public static List<Brand__c> getBrandList_Apex() {
        objAccount=getAccount();
        List<Brand__c> brandList = new List<Brand__c>();
        brandList = [SELECT Id, Brand_Name__c, Account__c, Active__c FROM Brand__c
                     WHERE Account__c=:objAccount.Id ORDER BY Brand_Name__c];
        
        return brandList; 
    }
    
    @AuraEnabled
    public static List<POS_Item__c> searchPOSItem_Apex(String searchText,String selBrand) {
        objAccount=getAccount();
        
        String profileName=[Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
        
        List<POS_Item__c> posItemList = New List<POS_Item__c>();
        String completeQry = '';
        String selectList = '';
        String whereClauseText = '';
        String whereClausedropDown ='';
        String whereClauseTenant ='';
        String accountId = '';
        String Inventory= 'Inventory';
        String Both= 'Both';
        if( objAccount  != null)
        {
            accountId = objAccount.ID;
            whereClauseTenant = whereClauseTenant+' (Account__c =\''+accountId+'\' ) ';
        }
        if(String.isNotBlank(selBrand))
            whereClausedropDown = whereClausedropDown+' AND (Brand__c= \''+selBrand+'\') ';
        String tempSearchText = '%'+searchText+'%';
        selectList = 'SELECT Id,Item_No__c,Coupon_Attachment_Id__c,Attachment_Id__c,Logical_Invenory_Stock__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id, ';
        selectList=selectList+' Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Expiration_Date__c,ExpirationDateRequired__c,Item_Descrption__c, ';
        selectList=selectList+' LotNumberRequired__c, Account__c, Active__c ,Image_of_Item__c,Length__c,Width__c,Height__c,Weight__c,Low_inventory_level_applicable__c, ';
        selectList=selectList+' Low_Inventory_Level__c,Maximum_order_quantity_applicable__c,Maximum_Order_Qty__c,Marketing_Only__c,Inventory_Seasonal_Program__c,Available_Stock__c,HarmonizationCode__c FROM POS_Item__c ';
        
        
        if(String.isNotBlank(searchText))
            whereClauseText = ' AND ((Item_Name__c LIKE \''+tempSearchText+'\') OR (Item_No__c LIKE \''+tempSearchText+'\') OR (Brand__r.Brand_Name__c LIKE \''+tempSearchText+'\'))';
        if(profileName == 'DFVsalesmanager' || profileName =='DFVBrandmanager') {
            completeQry = selectList+' WHERE ('+whereClauseTenant+' '+whereClauseText+' '+whereClausedropDown + ') AND Active__c=true AND Marketing_Only__c =false AND ( Inventory_Seasonal_Program__c=\''+Inventory+'\' OR  Inventory_Seasonal_Program__c=\''+Both+'\') AND Logical_Invenory_Stock__c>0 ORDER BY Item_Name__c ';     
            posItemList = Database.query(completeQry);
        }
        else {
            completeQry = selectList+' WHERE ('+whereClauseTenant+' '+whereClauseText+' '+whereClausedropDown + ') AND Active__c=true AND ( Inventory_Seasonal_Program__c=\''+Inventory+'\' OR  Inventory_Seasonal_Program__c=\''+Both+'\') AND Logical_Invenory_Stock__c>0 ORDER BY Item_Name__c ';
            posItemList = Database.query(completeQry);
        }
        
        
        return posItemList;
    } 
    
}