@isTest
public class InfiniumManageApproval_ApexTest {
    @isTest
    private static void testController ()
    {
        Account acct = new Account(Name='Infinium Spirits');
        insert acct ;
        Contact contact=new Contact(LastName='Testing',AccountId=acct.Id);
        insert contact;
        Profile profile=[SELECT Name FROM Profile WHERE Name='Customer Community Plus User' LIMIT 1];
        User communityUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                      LocaleSidKey='en_US', ProfileId = profile.Id, 
                                      TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com',ContactId=contact.Id);
        
        insert communityUser;
        
        Infinium_Spirits_Email_Notifications__c InfiniumSpiritsCustomSetting=new Infinium_Spirits_Email_Notifications__c(Name='InfiniumSpirits',Cc_Addresses_List__c='thanvi@uxltechnologies.net');
        insert InfiniumSpiritsCustomSetting;
        
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
        
        POS_Item__c posItem1= new POS_Item__c (Item_No__c='Test-No-01',Item_Name__c='testPosItemName1',Available_Stock__c=0,Account__c=acct.Id,Brand__c=brand.Id,Type_of_Item__c=itemType.Id,Active__c=true,
                                               Maximum_order_quantity_applicable__c=false,Approval_Required__c=false);
        insert posItem1;
        
        POS_Item__c posItem2= new POS_Item__c (Item_No__c='Test-No-02',Item_Name__c='testPosItemName2',Available_Stock__c=0,Account__c=acct.Id,Brand__c=brand.Id,Type_of_Item__c=itemType.Id,Active__c=true,
                                               Maximum_order_quantity_applicable__c=false,Approval_Required__c=true);
        insert posItem2;
        
        POS_Item__c posItem3= new POS_Item__c (Item_No__c='Test-No-03',Item_Name__c='testPosItemName3',Available_Stock__c=0,Account__c=acct.Id,Brand__c=brand.Id,Type_of_Item__c=itemType.Id,Active__c=true,
                                               Maximum_order_quantity_applicable__c=true,Approval_Required__c=false,Maximum_Order_Qty__c=1);
        insert posItem3;
        
        POS_Item__c posItem4= new POS_Item__c (Item_No__c='Test-No-04',Item_Name__c='testPosItemName4',Available_Stock__c=0,Account__c=acct.Id,Brand__c=brand.Id,Type_of_Item__c=itemType.Id,Active__c=true,
                                               Maximum_order_quantity_applicable__c=true,Approval_Required__c=true,Maximum_Order_Qty__c=1);
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
        
        //Needs Shipping Method Approval
        OrderDestination__c	orderDestination1 = new OrderDestination__c(Order__c=order.Id,AddressBook__c=addressBook1.Id,Shipping_Method__c=shippingMethod1.Id,Comet_Order_Status__c='Needs Approval');
        insert orderDestination1;
        //Does not Need Shipping Method Approval
        OrderDestination__c	orderDestination2 = new OrderDestination__c(Order__c=order.Id,AddressBook__c=addressBook2.Id,Shipping_Method__c=shippingMethod1.Id,Comet_Order_Status__c='Needs Approval');
        insert orderDestination2;
        
        OrderDestinationItem__c orderDestinationItem1 = new OrderDestinationItem__c (OrderDestination__c=orderDestination1.Id,POS_Item__c=posItem4.Id,Quantity__c=4);
        insert orderDestinationItem1;
        
        OrderDestinationItem__c orderDestinationItem2 = new OrderDestinationItem__c (OrderDestination__c=orderDestination2.Id,POS_Item__c=posItem4.Id,Quantity__c=4);
        insert orderDestinationItem2;
        
        
        Test.startTest();
        InfiniumManageApproval_Apex.loadAllCometApprovalOrders();     
        InfiniumManageApproval_Apex.loadShippingMethodList();
        InfiniumManageApproval_Apex.approveShippingMethod(orderDestination1);
        InfiniumManageApproval_Apex.rejectShippingMethod(orderDestination2);
        InfiniumManageApproval_Apex.approveOrderedItem(orderDestinationItem1);
        InfiniumManageApproval_Apex.rejectOrderedItem(orderDestinationItem2);
        InfiniumManageApproval_Apex.approveMaximumOrderQuantity(orderDestinationItem1);
        InfiniumManageApproval_Apex.rejectMaximumOrderQuantity(orderDestinationItem2);
        
        //Exception
        orderDestination1.Order__c=null;
        InfiniumManageApproval_Apex.approveShippingMethod(orderDestination1);
        InfiniumManageApproval_Apex.rejectShippingMethod(orderDestination1);
        orderDestinationItem2.OrderDestination__c=null;
        InfiniumManageApproval_Apex.approveOrderedItem(orderDestinationItem2);
        InfiniumManageApproval_Apex.rejectOrderedItem(orderDestinationItem2);
        InfiniumManageApproval_Apex.approveMaximumOrderQuantity(orderDestinationItem2);
        InfiniumManageApproval_Apex.rejectMaximumOrderQuantity(orderDestinationItem2);
        Test.stopTest();
    }
    
}