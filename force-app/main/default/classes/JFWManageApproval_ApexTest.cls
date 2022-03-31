@isTest
public class JFWManageApproval_ApexTest {
    @isTest
    private static void testController ()
    {
        Account acct = new Account(Name='JFW');
        insert acct ;
        Contact contact=new Contact(LastName='Testing',AccountId=acct.Id);
        insert contact;
        Profile profile=[SELECT Name FROM Profile WHERE Name='Customer Community Plus User' LIMIT 1];
        User communityUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                      LocaleSidKey='en_US', ProfileId = profile.Id, 
                                      TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com',ContactId=contact.Id);
        
        insert communityUser;
        
        JFW_Email_Notifications__c JFWCustomSetting=new JFW_Email_Notifications__c(Name='DFV',Cc_Addresses_List__c='Thanvi@uxltechnologies.net');
        insert JFWCustomSetting;
        
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
        
        POS_Item__c posItem1= new POS_Item__c (Item_No__c='Test-No-01',Item_Name__c='testPosItemName1',Available_Stock__c=1000,Account__c=acct.Id,Brand__c=brand.Id,Type_of_Item__c=itemType.Id,Active__c=true,
                                               Maximum_order_quantity_applicable__c=true,Approval_Required__c=true,Maximum_Order_Qty__c=5);
        insert posItem1;
        
        POS_Item__c posItem2= new POS_Item__c (Item_No__c='Test-No-02',Item_Name__c='testPosItemName2',Available_Stock__c=1000,Account__c=acct.Id,Brand__c=brand.Id,Type_of_Item__c=itemType.Id,Active__c=true,
                                               Maximum_order_quantity_applicable__c=false,Approval_Required__c=true);
        insert posItem2;
        
        POS_Item__c posItem3= new POS_Item__c (Item_No__c='Test-No-03',Item_Name__c='testPosItemName3',Available_Stock__c=100,Account__c=acct.Id,Brand__c=brand.Id,Type_of_Item__c=itemType.Id,Active__c=true,
                                               Maximum_order_quantity_applicable__c=true,Approval_Required__c=true,Maximum_Order_Qty__c=5);
        insert posItem3;
        
        POS_Item__c posItem4= new POS_Item__c (Item_No__c='Test-No-04',Item_Name__c='testPosItemName4',Available_Stock__c=100,Account__c=acct.Id,Brand__c=brand.Id,Type_of_Item__c=itemType.Id,Active__c=true,
                                               Maximum_order_quantity_applicable__c=true,Approval_Required__c=true,Maximum_Order_Qty__c=5);
        insert posItem4;
        
        Shipping_Method__c shippingMethod1 = new Shipping_Method__c(Account__c=acct.Id , Active__c=true , ApprovalRequired__c=true , Shipping_Method_Name__c='shippingMethod1');
        insert shippingMethod1;
        
        Shipping_Method__c shippingMethod2 = new Shipping_Method__c(Account__c=acct.Id , Active__c=true , ApprovalRequired__c=false , Default__c=true , Shipping_Method_Name__c='shippingMethod2');
        insert shippingMethod2;
        
        AddressBook__c addressBook1 = new AddressBook__c(Account__c=acct.Id , Destination_Name__c='destinationName' , Shipto_Company__c='shipToCompany', State__c=state.Id) ;
        insert addressBook1;
        
        AddressBook__c addressBook2 = new AddressBook__c(Account__c=acct.Id , Destination_Name__c='destinationName2' , Shipto_Company__c='shipToCompany2', State__c=state.Id) ;
        insert addressBook2;
        
        Order__c order = new Order__c(Account__c=acct.Id);
        insert order;
        OrderDestination__c	orderDestination1 = new OrderDestination__c(Order__c=order.Id,AddressBook__c=addressBook1.Id,Shipping_Method__c=shippingMethod1.Id,Comet_Order_Status__c='Needs Approval');
        insert orderDestination1;
        OrderDestination__c	orderDestination2 = new OrderDestination__c(Order__c=order.Id,AddressBook__c=addressBook2.Id,Shipping_Method__c=shippingMethod2.Id,Comet_Order_Status__c='Needs Approval');
        insert orderDestination2;
        OrderDestination__c orderDestination3 = new OrderDestination__c(Order__c=order.Id,AddressBook__c=addressBook1.Id,Shipping_Method__c=shippingMethod1.Id,Comet_Order_Status__c='Needs Approval');
        insert orderDestination3;
        //Does not Need Shipping Method Approval
        OrderDestination__c	orderDestination4 = new OrderDestination__c(Order__c=order.Id,AddressBook__c=addressBook2.Id,Shipping_Method__c=shippingMethod1.Id,Comet_Order_Status__c='Needs Approval');
        insert orderDestination4;
        
        OrderDestinationItem__c orderDestinationItem1 = new OrderDestinationItem__c (OrderDestination__c=orderDestination1.Id,POS_Item__c=posItem1.Id,Quantity__c=4,SelectedQuantity__c=4);
        insert orderDestinationItem1;
        
        OrderDestinationItem__c orderDestinationItem2 = new OrderDestinationItem__c (OrderDestination__c=orderDestination2.Id,POS_Item__c=posItem3.Id,Quantity__c=1,SelectedQuantity__c=1);
        insert orderDestinationItem2;
        OrderDestinationItem__c orderDestinationItem3 = new OrderDestinationItem__c (OrderDestination__c=orderDestination3.Id,POS_Item__c=posItem3.Id,Quantity__c=4,SelectedQuantity__c=10);
        insert orderDestinationItem3;
        
        OrderDestinationItem__c orderDestinationItem4 = new OrderDestinationItem__c (OrderDestination__c=orderDestination4.Id,POS_Item__c=posItem4.Id,Quantity__c=8,SelectedQuantity__c=7);
        insert orderDestinationItem4;
        
        
        Test.startTest();
        JFWManageApproval_Apex.loadAllCometApprovalOrders();     
        JFWManageApproval_Apex.loadShippingMethodList();
        
        JFWManageApproval_Apex.approveShippingMethod(orderDestination1);
        JFWManageApproval_Apex.approveOrderedItem(orderDestinationItem1);
        JFWManageApproval_Apex.approveMaximumOrderQuantity(orderDestinationItem1);
        
        JFWManageApproval_Apex.rejectShippingMethod(orderDestination3);
        
        JFWManageApproval_Apex.rejectOrderedItem(orderDestinationItem2);
        
        JFWManageApproval_Apex.approveShippingMethod(orderDestination4);
        JFWManageApproval_Apex.approveOrderedItem(orderDestinationItem4);
        JFWManageApproval_Apex.rejectMaximumOrderQuantity(orderDestinationItem4); 
        //Exception
        //
        Test.stopTest();
    }
    
}