@isTest
public class BrandManagerApprovalNotificationsTest {
@isTest
    private static void programOrderBrandSummaryController()
    {
        Account account = new Account(Name = 'DFV');
        insert account;
        Brand__c brand = new Brand__c(Brand_Name__c = 'BrandTest' ,Account__c = account.Id );
        insert brand;
        Brand_Manager__c brandManger = new Brand_Manager__c	(Brand__c=brand.Id,User__c=UserInfo.getUserId());
        insert brandManger;
        Item_Type__c itemType = new Item_Type__c(Item_Type__c ='ItemTest' ,Account__c = account.Id );
        insert itemType;
        POS_Item__c posItem = new POS_Item__c(Account__c = account.Id ,Approval_Required__c=true,Brand__c = brand.Id, Type_of_Item__c =itemType.Id,Item_Name__c='posItem1',Item_No__c = 'TEST-101', Price__c = 100);
        insert posItem;
        POS_Item__c posItem1 = new POS_Item__c(Account__c = account.Id ,Approval_Required__c=true,Brand__c = brand.Id, Type_of_Item__c =itemType.Id,Item_Name__c='positem2',Item_No__c = 'TEST-102', Price__c = 100);
        insert posItem1;
        
        Order__c order = new Order__c(Account__c = account.Id,Order_Status__c='Send to Comet');
        insert order;

        Country__c country = new Country__c(Country_Code__c = 'US', Country_Name__c= 'Unites State');
        insert country;
        
        State__c state = new State__c(Country__c = country.Id, State_Code__c= 'CA',  State_Name__c	= 'California' );
        insert state;
        
        AddressBook__c addressBook = new AddressBook__c(Account__c = account.Id, Destination_Name__c = 'Jaya Prasad',Shipto_Company__c = 'UXL Technologies', State__c = state.Id );
        insert addressBook;
        
        
        OrderDestination__c ordDestination = new OrderDestination__c(Order__c = order.Id, AddressBook__c = addressBook.Id , Comet_Order_Status__c = 'Needs Approval' );
        insert ordDestination;
        OrderDestinationItem__c ordDest = new OrderDestinationItem__c(OrderDestination__c = ordDestination.Id, POS_Item__c = posItem.Id, Quantity__c = 10, Item_Price__c= 10);

        OrderDestinationItem__c ordDest1 = new OrderDestinationItem__c(OrderDestination__c = ordDestination.Id, POS_Item__c = posItem1.Id, Quantity__c = 10, Item_Price__c= 10);

        
        List<OrderDestinationItem__c> orderDestItems=new List<OrderDestinationItem__c> ();
        orderDestItems.add(ordDest);
        orderDestItems.add(ordDest1);  
        insert orderDestItems; 
        System.debug('order--->'+order);
        System.debug('ordDestination--->'+ordDestination);
        System.debug('orderDestItems--->'+orderDestItems.size());
        order.Order_Date__c = System.today();
        update order;
    }
}