@isTest
private class WilsonManagePosItems_ApexTest {
    @isTest
    private static void testController ()
    {
        Account acct = new Account(Name='Wilson Daniels');
        insert acct ;
        Wilson_Daniel_Email_Notifications__c WilsonDanielCustomSetting=new Wilson_Daniel_Email_Notifications__c(Name='WILSON',Cc_Addresses_List__c='thanvi@uxltechnologies.net');
        insert WilsonDanielCustomSetting;
        
        Brand__c brand = new Brand__c (Brand_Name__c='BrandNameSelect',Active__c=true,Account__c=acct.Id);
        insert brand;
        
        Item_Type__c itemType= new Item_Type__c(Item_Type__c='itemTypeSelect',Active__c=true,Account__c=acct.Id);
        insert itemType;
        
        POS_Item__c posItem= new POS_Item__c (Item_No__c='Test-No-01',Item_Name__c='testPosItemName',Available_Stock__c=0,Account__c=acct.Id,Brand__c=brand.Id,Type_of_Item__c=itemType.Id);
        insert posItem;
        Country__c country=new Country__c(Active__c=true , Country_Code__c='countryCode' , Country_Name__c='countryName');
        insert country;
        State__c state = new State__c(State_Name__c='testState', Active__c = true, Country__c=country.id ,State_Code__c='stateCode');
        insert state ;
        Test.startTest();
        
        WilsonManagePosItems_Apex.addOrEditPOSItem(new POS_Item__c(Item_Name__c='itemName', Item_No__c='itemNumber' , Brand__c=brand.Id , Type_of_Item__c=itemType.Id , Account__c=acct.Id , Available_Stock__c=1 ),'','','',new List<String> {state.Id});
        WilsonManagePosItems_Apex.searchPOSItem('test',brand.Id,itemType.Id);

        WilsonManagePosItems_Apex.getBrandList();
        WilsonManagePosItems_Apex.getItemTypeList();
        WilsonManagePosItems_Apex.getAllState();
        WilsonManagePosItems_Apex.getAllAndSelectedStates(posItem.Id);
        
        WilsonManagePosItems_Apex.PosItemListWithNames posItems=WilsonManagePosItems_Apex.searchPOSItem('','','');
        WilsonManagePosItems_Apex.deactivateSelectedItem(posItems.posItemList[0].posItemList);
        //Exception
        WilsonManagePosItems_Apex.deactivateSelectedItem(new POS_Item__c(Item_Name__c='itemName', Item_No__c='itemNumber' , Brand__c=brand.Id , Type_of_Item__c=itemType.Id, Available_Stock__c=1,Account__c=null));  
        Test.stopTest();
        
    }
}