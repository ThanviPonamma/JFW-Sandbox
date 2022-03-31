@isTest
private class updateASNstatuses_SchedulerTest
{
    @isTest
    private static void schedulerTest()
    {
        Account acct = new Account(Name='DFV',Comet_API_Key__c='1234',Is_Comet_Rest_Api__c=true,Warehouse_Code__c='SPA');
        insert acct ;
        Account acct2 = new Account(Name='DFV',Is_Comet_Rest_Api__c=false);
        insert acct2 ;
        List <selectOption> brandList;
        List <selectOption> itemTypeList;
        List <selectOption> prgOptionsList;
        Daily_Inventory_Creation__c customSetting=new Daily_Inventory_Creation__c(Trigger_Active_Flag__c=false,Name='Trigger flag');
        insert customSetting;
        
        Brand__c brand = new Brand__c(Brand_Name__c='testBrand', Active__c = true, Account__c = acct.id);
        insert brand;
        Brand__c brand2 = new Brand__c(Brand_Name__c='testBrand', Active__c = true, Account__c = acct2.id);
        insert brand2;
        
        Item_Type__c itemtype = new Item_Type__c(Item_Type__c='testItemType', Active__c = true, Account__c = acct.id);
        insert itemtype;
        Item_Type__c itemtype2 = new Item_Type__c(Item_Type__c='testItemType', Active__c = true, Account__c = acct2.id);
        insert itemtype2;

        POS_Item__c posItem = new  POS_Item__c(Item_No__c='itm1', item_Name__c= 'Name1', Active__c = true, Brand__c = brand.Id, Type_of_Item__c = itemtype.id, Account__c = acct.id, Available_Stock__c = 20);
        insert posItem ;
        POS_Item__c posItem2 = new  POS_Item__c(Item_No__c='itm2', item_Name__c= 'Name1', Active__c = true, Brand__c = brand2.Id, Type_of_Item__c = itemtype2.id, Account__c = acct2.id, Available_Stock__c = 20);
        insert posItem2 ;
        
        Advance_Shipment_Notice__c ASN=new Advance_Shipment_Notice__c (Expected_Date__c=System.now()+5,Account__c=acct.Id,Emerge_Status__c='Submitted',Warehouse_ASN_Id__c='1841');
        insert ASN;
        Advance_Shipment_Notice__c ASN2=new Advance_Shipment_Notice__c (Expected_Date__c=System.now()+5,Account__c=acct2.Id,Emerge_Status__c='Submitted');
        insert ASN2;
        
        ASN_POS_Item__c asn_posItem=new ASN_POS_Item__c(Advance_Shipment_Notice__c=ASN.Id,POS_Item__c=posItem.Id,Quantity__c=10);
        insert asn_posItem;
        ASN_POS_Item__c asn_posItem2=new ASN_POS_Item__c(Advance_Shipment_Notice__c=ASN2.Id,POS_Item__c=posItem2.Id,Quantity__c=0);
        insert asn_posItem2;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new Comet_POS_ItemCreation_ResponseTest ());
            System.schedule('test job','0 0 1 * * ? *',new updateASNstatuses_Scheduler ('SELECT Id,Emerge_Status__c,Account__r.Comet_API_Key__c,Warehouse_Status__c,Warehouse_ASN_Id__c,Account__r.Warehouse_Code__c FROM Advance_Shipment_Notice__c',5));
            
        Test.stopTest();
    }
}