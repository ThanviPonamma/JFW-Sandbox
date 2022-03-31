@isTest
public class InfiniumEditOrder_ApexTest {
    
    @isTest
    private static void testMethodController()
    {
        List<Account> testAccts = new List<Account>();
        Account acct = new Account(Name='Infinium Spirits');
        insert acct ;
        Contact contact=new Contact(LastName='SystemAdmin',AccountId=acct.Id);
        insert contact;
        Profile profile=[SELECT Name FROM Profile WHERE Name='Customer Community Plus User' LIMIT 1];
        Schema.User communityUser = new Schema.User(Alias = 'standt', Email='standarduser@testorg.com', 
                                                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                                    LocaleSidKey='en_US', ProfileId = profile.Id, 
                                                    TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com',ContactId=contact.Id);
        
        insert communityUser;
        
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
        
        Order__c order = new Order__c(Account__c = acct.Id, Order_Date__c = system.today(),Order_Status__c = 'Open',Program__c = program.Id );
        insert order;
        
        OrderDestination__c orderDestination = new OrderDestination__c(Order__c = order.Id, AddressBook__c =addressBook.Id, OrderDest_Status__c='Open',Comet_Order_Status__c='Open',Order_Amount__c=0.0);
        insert orderDestination;
        
        OrderDestinationItem__c orderDestinationItems = new OrderDestinationItem__c(OrderDestination__c =orderDestination.Id, POS_Item__c = posItem.Id, Quantity__c = 1,SelectedQuantity__c=1);
        insert orderDestinationItems;
        
        OrderDestinationItem__c orderDestinationItems1 = new OrderDestinationItem__c(OrderDestination__c =orderDestination.Id, POS_Item__c = posItem.Id, Quantity__c = 1,SelectedQuantity__c=1);
        insert orderDestinationItems1;
        
        Test.startTest();
        List<Program__c> programList=InfiniumEditOrder_Apex.getAllProgramList_Apex();
         List<InfiniumEditOrder_Apex.CometOrder_ChairBudget> cometOrder=InfiniumEditOrder_Apex.loadOrdersForSelectedProgramAndUser_Apex('admin',program.Id);
        List<InfiniumEditOrder_Apex.CometOrder_ChairBudget> cometOrders=InfiniumEditOrder_Apex.loadOrdersForSelectedProgramAndUser_Apex('',program.Id);
		InfiniumEditOrder_Apex.saveEditedOrder_Apex(cometOrders.isEmpty()?'[]':JSON.serialize(cometOrders[0].orderedItems), 100,
                                                             cometOrders.isEmpty()?'':cometOrders[0].cometOrder.Id,cometOrders[0].chairBudget); 
        Test.stopTest();
    }
    
}