@isTest
public class CopperPosItemToCart_ApexTest {
@isTest
    private static void testController ()
    {
        Account acct = new Account(Name='Copper Cane');
        insert acct ;
        Contact contact=new Contact(LastName='SystemAdmin',AccountId=acct.Id);
        insert contact;
        Profile profile=[SELECT Name FROM Profile WHERE Name='Customer Community Plus User' LIMIT 1];
        Schema.User communityUser = new Schema.User(Alias = 'standt', Email='standarduser@testorg.com', 
                                                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                                    LocaleSidKey='en_US', ProfileId = profile.Id, 
                                                    TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com',ContactId=contact.Id);
        
        insert communityUser;
        Copper_Cane_Email_Notifications__c CopperCustomSetting=new Copper_Cane_Email_Notifications__c(Name='CopperCane',Cc_Addresses_List__c='thanvi@uxltechnologies.net');
        insert CopperCustomSetting;
        Brand__c brand = new Brand__c(Brand_Name__c = 'Bota box',Account__c =acct.Id,Active__c = true); 
        insert brand;
        
        Brand__c brand1 = new Brand__c(Brand_Name__c = 'BlackStalion',Account__c =acct.Id,Active__c = true); 
        insert brand1;
        
        Item_Type__c itemType= new Item_Type__c(Item_Type__c='itemTypeSelect',Active__c=true,Account__c=acct.Id);
        insert itemType;
        
        POS_Item__c posItem = new POS_Item__c (Item_No__c='Test-No-01',Item_Name__c='testPosItemName',Pack_Of__c = 2, Price__c = 25,Account__c=acct.Id,Brand__c=brand.Id,Type_of_Item__c=itemType.Id);
        insert posItem;
        
        Organiztaion_Chart__c orgChart=new Organiztaion_Chart__c (Account__c=acct.Id,Checkbox__c=true,Effective_End_Date_of_Org_Chart__c=System.today().addDays(+100),Effective_Start_Date_of_Org_Chart__c=System.today().addDays(-100),Organization_Chart_Name__c='Infinium');
        insert orgChart;   
        
        Program__c program=new Program__c (Name__c='Testing',Account__c=acct.Id,Start_Date__c=System.today().addDays(-10),
                                           Closing_Date__c=System.today().addDays(+10),
                                           In_Market_Date__c=System.today().addDays(+20));
        insert program;
        
        Chair__c chair=new Chair__c (Account__c=acct.Id,Chair_Name__c='Test',Level__c='1',User__c=UserInfo.getUserId(),Active__c=true);
        insert chair;
        
        Chair_Budget__c chairBudget=new Chair_Budget__c (Allocated_Budget__c=1000,Shared_Budget__c=200,
                                                         Chair__c=chair.Id,Program__c=program.Id);
        insert chairBudget;
        
        Country__c country=new Country__c(Active__c=true , Country_Code__c='countryCode' , Country_Name__c='countryName');
        insert country;
        
        State__c state = new State__c(State_Name__c='testState', Active__c = true, Country__c=country.id ,State_Code__c='stateCode');
        insert state ;
        
        AddressBook__c addressBook = new AddressBook__c(Account__c=acct.Id , Destination_Name__c='destinationName', 
                                                        Shipto_Company__c='shipToCompany', State__c=state.Id);
        insert addressBook;
        
        Test.startTest();
        List<Brand__c> brands=CopperPosItemToCart_Apex.getBrands_Apex();
        List<Item_Type__c> itemTypes=CopperPosItemToCart_Apex.getItemTypes_Apex();
        CopperPosItemToCart_Apex.PosItem_DetailsListWrapper getPosItems = CopperPosItemToCart_Apex.getPosItems_Apex('','','','',program.Id,0);
        ShoppingCart__c shoppingCart=CopperPosItemToCart_Apex.createSeasonalShoppingCart_Apex(program.Id);
        CopperPosItemToCart_Apex.addPosItemToCart_Apex(program.Id,posItem.Id);
        CopperPosItemToCart_Apex.removePosItemFromCart_Apex(program.Id,posItem.Id);
        CopperPosItemToCart_Apex.getPosItems_Apex('Test',brands[0].Id,itemTypes[0].Id,'RECENT_ADDED_CARTITEMS',program.Id,0);
        CopperPosItemToCart_Apex.getPosItems_Apex('Test',brands[0].Id,itemTypes[0].Id,'LAST_N_DAYS',program.Id,0);
        CopperPosItemToCart_Apex.addAllPosItemsToCart_Apex('','','',shoppingCart.Id,'',program.Id);
        CopperPosItemToCart_Apex.addAllPosItemsToCart_Apex('Test','','',shoppingCart.Id,'',program.Id);
        CopperPosItemToCart_Apex.addAllPosItemsToCart_Apex('','Test1','',shoppingCart.Id,'',program.Id);
        CopperPosItemToCart_Apex.addAllPosItemsToCart_Apex('Test','Test1','',shoppingCart.Id,'',program.Id);
        Test.stopTest();


    }
}