@isTest
private class CopperManagePosItems_ApexTest {
    @isTest
    private static void testController ()
    {
        Account acct = new Account(Name='Copper Cane');
        insert acct ;
        Copper_Cane_Email_Notifications__c CopperCaneCustomSetting=new Copper_Cane_Email_Notifications__c(Name='CopperCane',Cc_Addresses_List__c='thanvi@uxltechnologies.net');
        insert CopperCaneCustomSetting;
        
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
        
        CopperManagePosItems_Apex.addOrEditPOSItem_Apex(new POS_Item__c(Item_Name__c='itemName', Item_No__c='itemNumber' , Brand__c=brand.Id , Type_of_Item__c=itemType.Id , Account__c=acct.Id , Available_Stock__c=1 ),'','','',new List<String> {state.Id});
        CopperManagePosItems_Apex.searchPOSItem_Apex('test',brand.Id,itemType.Id);

        CopperManagePosItems_Apex.getBrandList_Apex();
        CopperManagePosItems_Apex.getItemTypeList_Apex();
        CopperManagePosItems_Apex.getAllState();
        CopperManagePosItems_Apex.getAllAndSelectedStates(posItem.Id);
        
        CopperManagePosItems_Apex.PosItemListWithNames posItems=CopperManagePosItems_Apex.searchPOSItem_Apex('','','');
        CopperManagePosItems_Apex.deactivateSelectedItem(posItems.posItemList[0].posItemList);
        //Exception
        CopperManagePosItems_Apex.deactivateSelectedItem(new POS_Item__c(Item_Name__c='itemName', Item_No__c='itemNumber' , Brand__c=brand.Id , Type_of_Item__c=itemType.Id, Available_Stock__c=1,Account__c=null));  
        Test.stopTest();
        
    }
}