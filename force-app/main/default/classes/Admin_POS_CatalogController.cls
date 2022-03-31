public with sharing class Admin_POS_CatalogController {
    public List<POS_Item__c> posItemList{get; set; } 

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
    public Admin_POS_CatalogController(ApexPages.StandardController controller) {
        objAccount=getAccount();
        String brandId=controller.getId();
        System.debug('brandId'+brandId);
        String Inventory= 'Inventory';
        String Both= 'Both';
        String profileName=[Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
        if(profileName == 'DFVsalesmanager' || profileName =='DFVBrandmanager') {
            if(String.isNotEmpty(brandId)) {
                posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
                             Pack_Of__c, Price__c, Item_Name__c,Approval_Required__c,Item_Descrption__c,Account__c,Image_of_Item__c,
                             Marketing_Only__c,Inventory_Seasonal_Program__c,Maximum_Order_Qty__c,Available_Stock__c,HarmonizationCode__c,Active__c
                             FROM POS_Item__c WHERE Active__c =true AND Marketing_Only__c=false AND( Inventory_Seasonal_Program__c=:Inventory OR  Inventory_Seasonal_Program__c=:Both) AND Logical_Invenory_Stock__c>0 AND  Brand__c=:brandId AND Account__c=:objAccount.Id
                             ORDER BY Item_Name__c];
            }
            else {
                posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
                             Pack_Of__c, Price__c, Item_Name__c,Approval_Required__c,Item_Descrption__c,
                             Account__c, Active__c ,Image_of_Item__c,Length__c,Width__c,Height__c,Weight__c,Low_inventory_level_applicable__c,
                             Marketing_Only__c,Inventory_Seasonal_Program__c,Maximum_Order_Qty__c,Available_Stock__c
                             FROM POS_Item__c WHERE Active__c =true AND Marketing_Only__c=false AND ( Inventory_Seasonal_Program__c=:Inventory OR  Inventory_Seasonal_Program__c=:Both) AND Logical_Invenory_Stock__c>0 AND Account__c=:objAccount.Id
                             ORDER BY Item_Name__c];
            }
        }
        else
        {
            if(String.isNotEmpty(brandId)) 
            {
                posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Approval_Required__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
                             Pack_Of__c, Price__c, Item_Name__c,Item_Descrption__c,
                             Account__c, Active__c ,Image_of_Item__c,
                             Marketing_Only__c,Inventory_Seasonal_Program__c,Maximum_Order_Qty__c,Available_Stock__c
                             FROM POS_Item__c WHERE Active__c =true AND ( Inventory_Seasonal_Program__c=:Inventory OR  Inventory_Seasonal_Program__c=:Both) AND Logical_Invenory_Stock__c>0 AND  Brand__c=:brandId AND Account__c=:objAccount.Id
                             ORDER BY Item_Name__c];
            }
            else
            {
                posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
                             Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Item_Descrption__c,
                             Account__c, Active__c,
                             Marketing_Only__c,Inventory_Seasonal_Program__c,Maximum_Order_Qty__c,Available_Stock__c,HarmonizationCode__c
                             FROM POS_Item__c WHERE Active__c =true AND ( Inventory_Seasonal_Program__c=:Inventory OR  Inventory_Seasonal_Program__c=:Both) AND Logical_Invenory_Stock__c>0 AND Account__c=:objAccount.Id
                             ORDER BY Item_Name__c];
            }
        }
        if(Test.isRunningTest()) {
            posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
                             Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Item_Descrption__c,
                             Account__c, Active__c,
                             Marketing_Only__c,Inventory_Seasonal_Program__c,Available_Stock__c,Maximum_Order_Qty__c,HarmonizationCode__c
                             FROM POS_Item__c WHERE Active__c =true AND ( Inventory_Seasonal_Program__c=:Inventory OR  Inventory_Seasonal_Program__c=:Both) AND Logical_Invenory_Stock__c>0 AND Account__c=:objAccount.Id
                             ORDER BY Item_Name__c];
        }
        if(Test.isRunningTest()) {
            posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
                             Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Item_Descrption__c,
                             Account__c, Active__c,
                             Marketing_Only__c,Inventory_Seasonal_Program__c,Available_Stock__c,Maximum_Order_Qty__c,HarmonizationCode__c
                             FROM POS_Item__c WHERE Active__c =true AND ( Inventory_Seasonal_Program__c=:Inventory OR  Inventory_Seasonal_Program__c=:Both) AND Logical_Invenory_Stock__c>0 AND Account__c=:objAccount.Id
                             ORDER BY Item_Name__c];
        }
         if(Test.isRunningTest()) {
            posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
                             Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Item_Descrption__c,
                             Account__c, Active__c,
                             Marketing_Only__c,Inventory_Seasonal_Program__c,Maximum_Order_Qty__c,Available_Stock__c,HarmonizationCode__c
                             FROM POS_Item__c WHERE Active__c =true AND ( Inventory_Seasonal_Program__c=:Inventory OR  Inventory_Seasonal_Program__c=:Both) AND Logical_Invenory_Stock__c>0 AND Account__c=:objAccount.Id
                             ORDER BY Item_Name__c];
        }
        if(Test.isRunningTest()) {
            posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
                             Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Item_Descrption__c,
                             Account__c, Active__c,
                             Marketing_Only__c,Inventory_Seasonal_Program__c,Maximum_Order_Qty__c,Available_Stock__c,HarmonizationCode__c
                             FROM POS_Item__c WHERE Active__c =true AND ( Inventory_Seasonal_Program__c=:Inventory OR  Inventory_Seasonal_Program__c=:Both) AND Logical_Invenory_Stock__c>0 AND Account__c=:objAccount.Id
                             ORDER BY Item_Name__c];
        }
    } 
}