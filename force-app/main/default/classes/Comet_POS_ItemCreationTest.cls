@isTest
private class Comet_POS_ItemCreationTest
{
   @isTest
   private static void triggerHandlerTest()
   {
       Account acct = new Account(Name='DFV',Comet_API_Key__c='1234',Is_Comet_Rest_Api__c=true,Warehouse_Code__c='SPA');
       insert acct ;
       List <selectOption> brandList;
       List <selectOption> itemTypeList;
       List <selectOption> prgOptionsList;
       Daily_Inventory_Creation__c customSetting=new Daily_Inventory_Creation__c(Trigger_Active_Flag__c=false,Name='Trigger flag');
       insert customSetting;
       Brand__c brand = new Brand__c(Brand_Name__c='testBrand', Active__c = true, Account__c = acct.id);
       insert brand;
       Item_Type__c itemtype = new Item_Type__c(Item_Type__c='testItemType', Active__c = true, Account__c = acct.id);
       insert itemtype;
       POS_Item__c posItem = new  POS_Item__c(Item_No__c='itm1', item_Name__c= 'Name1', Active__c = true, Brand__c = brand.Id, Type_of_Item__c = itemtype.id, Account__c = acct.id, Available_Stock__c = 20);
       insert posItem ;
       System.assertEquals('itm1', posItem.Item_No__c);
       posItem = new  POS_Item__c(Item_No__c='itm2',Height__c=2, item_Name__c= 'Name2', Active__c = true, Brand__c = brand.Id, Type_of_Item__c = itemtype.id, Account__c = acct.id, Available_Stock__c = 10);
       insert posItem ;
       POS_Item__c posItem2 = new  POS_Item__c(Item_No__c='itm3',Height__c=0,Weight__c=0,width__c=0,Length__c=0, item_Name__c= 'Name2', Active__c = true, Brand__c = brand.Id, Type_of_Item__c = itemtype.id, Account__c = acct.id, Available_Stock__c = 10);
       insert posItem2 ;
       System.assertEquals('itm3', posItem2.Item_No__c);
       Attachment attach=new Attachment();
       attach.Name='Unit Test Attachment';
       Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
       attach.body=bodyBlob;
       attach.parentId=posItem.id;
       insert attach;
       // start the test execution context
       Test.startTest();
       Test.setMock(HttpCalloutMock.class, new Comet_POS_ItemCreation_ResponseTest ());
       List<POS_Item__c> posItemList = new List<POS_Item__c>();
       posItemList = [SELECT ID, Name, Available_Stock__c FROM POS_Item__c];
       for(integer i=0; i<posItemList.size(); i++)
       {
           posItemList[i].Available_Stock__c = posItemList[i].Available_Stock__c+1;
       }
       update posItemList;
       for(integer i=0; i<posItemList.size(); i++)
       {
           posItemList[i].Available_Stock__c = posItemList[i].Available_Stock__c+2;
       }
       update posItemList;
       posItem.Attachment_Id__c=null;
       update posItem;
       // stop the test
       Test.stopTest();
   }
}