@isTest
public class WilsonInventoryOrderStatus_ApexTest {

    @isTest
    private static void testMethodController()
    {
        Test.startTest();
        OrderDestination__c orderDestination = [SELECT Id FROM OrderDestination__c LIMIT 1];
        List<WilsonInventoryOrderStatus_Apex.OrderStatus_Wrapper> orderStatus_Wrapper=WilsonInventoryOrderStatus_Apex.getAllInventoryOrders('');
        List<WilsonInventoryOrderStatus_Apex.OrderStatus_Wrapper> orderStatus_Wrapper1=WilsonInventoryOrderStatus_Apex.getAllInventoryOrders('destinationName');
        WilsonInventoryOrderStatus_Apex.getAllInventoryOrders('destinationName');
        WilsonInventoryOrderStatus_Apex.getAllInventoryOrders('destinationName2');
        WilsonInventoryOrderStatus_Apex.getOrderDetailsOfSelectedOrder('');
        List<WilsonInventoryOrderStatus_Apex.OrderStatusDetails_Wrapper> OrderStatusDetails_Wrapper=WilsonInventoryOrderStatus_Apex.getOrderDetailsOfSelectedOrder(orderDestination.Id);

        
    }

    @testSetup static void setupData() {
        List<Account> testAccts = new List<Account>();
        Account acct = new Account(Name='Wilson Daniels');
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
        
        Country__c country=new Country__c(Active__c=true , Country_Code__c='countryCode' , Country_Name__c='countryName');
        insert country;
        
        State__c state = new State__c(State_Name__c='testState', Active__c = true, Country__c=country.id ,State_Code__c='stateCode');
        insert state ;
        Territory__c territory = new Territory__c (Territory_Name__c='testTerritory',Active__c=true,Account__c=acct.Id);
        insert territory;
        States_Territory__c stateTerritory = new States_Territory__c (State__c = state.Id,Territory__c= territory.Id);
        insert stateTerritory;
        Users_Territory__c usersTerritory = new Users_Territory__c (Territory__c= territory.Id,User__c=UserInfo.getUserId());
        insert usersTerritory;
        
       
        Brand__c brand = new Brand__c (Brand_Name__c='BrandNameSelect',Active__c=true,Account__c=acct.Id);
        insert brand;
        
        Item_Type__c itemType= new Item_Type__c(Item_Type__c='itemTypeSelect',Active__c=true,Account__c=acct.Id);
        insert itemType;
        POS_Item__c posItem= new POS_Item__c (Item_No__c='Test-No-01',Item_Name__c='testPosItemName',Available_Stock__c=10,
                                              Account__c=acct.Id,Brand__c=brand.Id,Type_of_Item__c=itemType.Id,Active__c=true,Attachment_Id__c='123');
        insert posItem;
        
        POS_Item__c posItem2= new POS_Item__c (Item_No__c='Test-No-02',Item_Name__c='testPosItemName',Available_Stock__c=10,
                                               Account__c=acct.Id,Brand__c=brand.Id,Type_of_Item__c=itemType.Id,Active__c=true);
        insert posItem2;
        
        
        Shipping_Method__c shippingMethod = new Shipping_Method__c(Account__c=acct.Id , Active__c=true , Default__c=true, ApprovalRequired__c=true , Shipping_Method_Name__c='shippingMethod1');
        insert shippingMethod;
        
        Shipping_Method__c shippingMethod2 = new Shipping_Method__c(Account__c=acct.Id , Active__c=true , ApprovalRequired__c=false , Default__c=true , Shipping_Method_Name__c='shippingMethod2', DisplayOrder__c = 1);
        insert shippingMethod2;
        
        
        AddressBook__c addressBook = new AddressBook__c(Account__c=acct.Id , Destination_Name__c='destinationName' , 
                                                        Shipto_Company__c='shipToCompany', State__c=state.Id) ;
        insert addressBook;
        
        AddressBook__c addressBook2 = new AddressBook__c(Account__c=acct.Id , Destination_Name__c='destinationName2' , 
                                                         Shipto_Company__c='shipToCompany2', State__c=state.Id) ;
        insert addressBook2;
        
         
        Order__c order = new Order__c(Account__c = acct.Id, Order_Date__c = system.today() , Order_Status__c = 'Open');
        insert order;

        Order__c order1 = new Order__c(Account__c = acct.Id, Order_Date__c = system.today() , Order_Status__c = 'Send to Comet');
        insert order1;
        
        Order__c order2 = new Order__c(Account__c = acct.Id, Order_Date__c = system.today() , Order_Status__c = 'This order has been submitted to Comet');
        insert order2;

        OrderDestination__c orderDestination = new OrderDestination__c(Order__c = order.Id, AddressBook__c =addressBook.Id, OrderDest_Status__c='open',Comet_Order_Status__c='open',Shipping_Method__c=shippingMethod.Id);
        insert orderDestination;
        
        OrderDestination__c orderDestination1 = new OrderDestination__c(Order__c = order1.Id, AddressBook__c =addressBook.Id, OrderDest_Status__c='open',Comet_Order_Status__c='open',Shipping_Method__c=shippingMethod.Id);
        insert orderDestination1;
        
        OrderDestinationItem__c orderDestinationItems = new OrderDestinationItem__c(OrderDestination__c =orderDestination.Id, POS_Item__c = posItem.Id, Quantity__c = 1);
        insert orderDestinationItems;
    }
    

}