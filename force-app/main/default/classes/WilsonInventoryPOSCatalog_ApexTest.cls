@isTest
public class WilsonInventoryPOSCatalog_ApexTest {
 @isTest
    private static void controllerTest()
    {
        Test.startTest();
        WilsonInventoryPOSCatalog_Apex.getPOSItemList();
        WilsonInventoryPOSCatalog_Apex.getBrandList();
        WilsonInventoryPOSCatalog_Apex.searchPOSItem('test','');
        WilsonInventoryPOSCatalog_Apex.searchPOSItem('test','BrandNameSelect');
       
        Brand__c brand =[SELECT Id FROM Brand__c];
        List<POS_Item__c> posItem = [SELECT Id FROM POS_Item__c];
        WilsonPOSCatalog_Apex controller=new WilsonPOSCatalog_Apex(new ApexPages.StandardController(brand));
        WilsonPOSCatalog_Apex controller1=new WilsonPOSCatalog_Apex(new ApexPages.StandardController(posItem[0]));
        Test.stopTest();
    }
    @testSetUp
    private static void records()
    {
        Account acct = new Account(Name='Wilson Daniels');
        insert acct ;
        Contact contact=new Contact(LastName='Testing',AccountId=acct.Id);
        insert contact;
        Profile profile=[SELECT Name FROM Profile WHERE Name='WilsonDanielsSalesManager' LIMIT 1];
        User communityUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                      LocaleSidKey='en_US', ProfileId = profile.Id, 
                                      TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com',ContactId=contact.Id);
        
        insert communityUser;
        Brand__c brand = new Brand__c (Brand_Name__c='BrandNameSelect',Active__c=true,Account__c=acct.Id);
        insert brand;
        
        Item_Type__c itemType= new Item_Type__c(Item_Type__c='itemTypeSelect',Active__c=true,Account__c=acct.Id);
        insert itemType;

        List<POS_Item__c> posItemList=new List<POS_Item__c> ();
        POS_Item__c posItem= new POS_Item__c (Item_No__c='Test-No-01',Price__c=10,Item_Name__c='testPosItemName',Inventory_Seasonal_Program__c='Both',Marketing_Only__c=true,Available_Stock__c=0,Account__c=acct.Id,Brand__c=brand.Id,Type_of_Item__c=itemType.Id);
        POS_Item__c posItem2= new POS_Item__c (Item_No__c='Test-No-02',Price__c=10,Item_Name__c='testPosItemName2',Inventory_Seasonal_Program__c='Both',Marketing_Only__c=true,Available_Stock__c=0,Account__c=acct.Id,Brand__c=brand.Id,Type_of_Item__c=itemType.Id);
        posItemList.add(posItem);
        posItemList.add(posItem2);
        insert posItemList;
        
    }
}