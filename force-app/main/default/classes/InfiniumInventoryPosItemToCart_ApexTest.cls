@isTest
public class InfiniumInventoryPosItemToCart_ApexTest {
    
    @isTest
    private static void addToCartFunctionalityTestMethod ()
    {
        Account testAccount=[SELECT Id FROM Account LIMIT 1];
        Brand__c testBrand=[SELECT Id FROM Brand__c LIMIT 1];
        Item_Type__c testItemtype=[SELECT Id FROM Item_Type__c LIMIT 1];
        List<POS_Item__c> testPosItems=[SELECT Id FROM POS_Item__c];
        
        Test.startTest();
        InfiniumInventoryPosItemToCart_Apex.createInventoryShoppingCart();
        List<Brand__c> brandList= InfiniumInventoryPosItemToCart_Apex.getBrandList();
        List<Item_Type__c> itemTypeList=InfiniumInventoryPosItemToCart_Apex.getItemTypeList();
        InfiniumInventoryPosItemToCart_Apex.PosItem_DetailsListWrapper posItemsWithCartSearch1=InfiniumInventoryPosItemToCart_Apex.getInventoryPosItemList('Test-No-01','','','LAST_N_DAYS',0);
        InfiniumInventoryPosItemToCart_Apex.PosItem_DetailsListWrapper posItemsWithCartSearch2=InfiniumInventoryPosItemToCart_Apex.getInventoryPosItemList('Test-No-02','','Brand__r.Brand_Name__c','',1);
        InfiniumInventoryPosItemToCart_Apex.addInventoryPosItemToCart(testPosItems[0].Id);
        InfiniumInventoryPosItemToCart_Apex.addInventoryPosItemToCart(testPosItems[1].Id);
        InfiniumInventoryPosItemToCart_Apex.createInventoryShoppingCart();
        InfiniumInventoryPosItemToCart_Apex.PosItem_DetailsListWrapper posItemsWithCartSearch3=InfiniumInventoryPosItemToCart_Apex.getInventoryPosItemList('Test-No-04','testBrand.Id','testItemtype.Id','RECENT_ADDED_CARTITEMS',5);
        InfiniumInventoryPosItemToCart_Apex.PosItem_DetailsListWrapper posItemsWithCartSearch4=InfiniumInventoryPosItemToCart_Apex.getInventoryPosItemList('Test-No-04','testBrand.Id','testItemtype.Id','',5);
        InfiniumInventoryPosItemToCart_Apex.removeInventoryPosItemFromCart(testPosItems[0].Id);
        //expection
        InfiniumInventoryPosItemToCart_Apex.addInventoryPosItemToCart(null);
        InfiniumInventoryPosItemToCart_Apex.removeInventoryPosItemFromCart(NULL);
        Test.stopTest();
    }
    @testSetup static void setupData() {
        List<Account> testAccts = new List<Account>();
        Account acct = new Account(Name='Infinium Spirits');
        insert acct ;
        Contact contact=new Contact(LastName='Testing',AccountId=acct.Id);
        insert contact;
        Daily_Inventory_Creation__c customSetting=new Daily_Inventory_Creation__c(Trigger_Active_Flag__c=false,Name='Trigger flag');
        insert customSetting;
        Profile profile=[SELECT Name FROM Profile WHERE Name='Customer Community Plus User' LIMIT 1];
        
        User communityUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                      LocaleSidKey='en_US', ProfileId = profile.Id, 
                                      TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com',ContactId=contact.Id);
        
        insert communityUser;
        
        Infinium_Spirits_Email_Notifications__c InfiniumSpiritsCustomSetting=new Infinium_Spirits_Email_Notifications__c(Name='Infinium Spirits',Cc_Addresses_List__c='thanvi@uxltechnologies.net');
        insert InfiniumSpiritsCustomSetting;
        Brand__c brand = new Brand__c (Brand_Name__c='BrandNameSelect',Active__c=true,Account__c=acct.Id);
        insert brand;
        
        Item_Type__c itemType= new Item_Type__c(Item_Type__c='itemTypeSelect',Active__c=true,Account__c=acct.Id);
        insert itemType;
        POS_Item__c posItem= new POS_Item__c (Item_No__c='Test-No-01',Item_Name__c='testPosItemName',Available_Stock__c=10,
                                              Account__c=acct.Id,Brand__c=brand.Id,Type_of_Item__c=itemType.Id,Active__c=true);
        insert posItem;
        
        POS_Item__c posItem2= new POS_Item__c (Item_No__c='Test-No-02',Item_Name__c='testPosItemName',Available_Stock__c=10,
                                               Account__c=acct.Id,Brand__c=brand.Id,Type_of_Item__c=itemType.Id,Active__c=true);
        insert posItem2;
    }
}