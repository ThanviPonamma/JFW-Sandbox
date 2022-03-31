@isTest
private class DFVPOSItemListCmpControllerTest {
    @isTest
    private static void testController ()
    {
        Account acct = new Account(Name='DFV');
        insert acct ;
        DFV_Email_Notifications__c DFVCustomSetting=new DFV_Email_Notifications__c(Name='DFV',Cc_Addresses_List__c='Pradeep@uxltechnologies.net');
        insert DFVCustomSetting;
        
        Brand__c brand = new Brand__c (Brand_Name__c='BrandNameSelect',Active__c=true,Account__c=acct.Id);
        insert brand;
        
        Item_Type__c itemType= new Item_Type__c(Item_Type__c='itemTypeSelect',Active__c=true,Account__c=acct.Id);
        insert itemType;
        
        POS_Item__c posItem= new POS_Item__c (Item_No__c='Test-No-01',Item_Name__c='testPosItemName',Available_Stock__c=0,Account__c=acct.Id,Brand__c=brand.Id,Type_of_Item__c=itemType.Id);
        insert posItem;
        
        Test.startTest();
        
        DFVPOSItemListCmpController.addPOSItem(new POS_Item__c(Item_Name__c='itemName', Item_No__c='itemNumber' , Brand__c=brand.Id , Type_of_Item__c=itemType.Id , Account__c=acct.Id , Available_Stock__c=1 ),'','','','','','',1);
        DFVPOSItemListCmpController.getPOSItemList(1); 
        DFVPOSItemListCmpController.getBrandAndItemTypeOptions(DFVPOSItemListCmpController.getPOSItemList(1).posItemList[0]);
        DFVPOSItemListCmpController.getBrandList();
        DFVPOSItemListCmpController.getItemTypeList();
        DFVPOSItemListCmpController.deactivateSelectedItem( DFVPOSItemListCmpController.getPOSItemList(1).posItemList[0] , '','','',1);
       // DFVPOSItemListCmpController.activateSelectedItem(DFVPOSItemListCmpController.getPOSItemList().posItemList[0] , '','','');
        DFVPOSItemListCmpController.searchPOSItem(DFVPOSItemListCmpController.getPOSItemList(1).posItemList[0].Item_Name__c , brand.Id , itemType.Id,1);
        //Exception cases
        DFVPOSItemListCmpController.addPOSItem(DFVPOSItemListCmpController.getPOSItemList(1).posItemList[0] ,'sanjana','','','','','',1);
        DFVPOSItemListCmpController.deactivateSelectedItem(new POS_Item__c(Item_Name__c='itemName', Item_No__c='itemNumber' , Brand__c=brand.Id , Type_of_Item__c=itemType.Id , Account__c=acct.Id , Available_Stock__c=1),'','','',1);
        //DFVPOSItemListCmpController.activateSelectedItem(new POS_Item__c(Brand__c=brand.Id , Type_of_Item__c=itemType.Id , Account__c=acct.Id , Available_Stock__c=1) , '','','');
        
        Test.stopTest();
        
    }
}