@isTest
public class ProgramOrderBrandSummaryTest {
    @isTest
    private static void programOrderBrandSummaryController()
    {
        Account account = new Account(Name = 'DFV');
        insert account;
        Brand__c brand = new Brand__c(Brand_Name__c = 'Nike' ,Account__c = account.Id );
        insert brand;
        Item_Type__c itemType = new Item_Type__c(Item_Type__c ='Shoes' ,Account__c = account.Id );
        insert itemType;
        POS_Item__c posItem = new POS_Item__c(Account__c = account.Id ,Brand__c = brand.Id, Type_of_Item__c =itemType.Id,Item_Name__c='Nike Cap',Item_No__c = 'TEST-101', Price__c = 100);
        insert posItem;
        
        Program__c program = new Program__c(Name__c='Holiday Test',Start_Date__c=System.today(),Closing_Date__c=System.today().addDays(3),In_Market_Date__c=System.today().addDays(5));
        insert program;
        
        Program_Item__c programItem = new Program_Item__c(Program__c =program.Id, POS_Item__c = posItem.Id, Quantity_Procured__c = 10  );
        insert programItem;
        
        Order__c order = new Order__c(Account__c = account.Id, Program__c =program.Id );
        insert order;
        
        Country__c country = new Country__c(Country_Code__c = 'USA', Country_Name__c= 'Unite State');
        insert country;
        
        State__c state = new State__c(Country__c = country.Id, State_Code__c= 'KA',  State_Name__c	= 'Karnataka' );
        insert state;
        
        AddressBook__c addressBook = new AddressBook__c(Account__c = account.Id, Destination_Name__c = 'Jaya Prasad',Shipto_Company__c = 'UXL Technologies', State__c = state.Id );
        insert addressBook;
        
        
        OrderDestination__c ordDestination = new OrderDestination__c(Order__c = order.Id, AddressBook__c = addressBook.Id , Comet_Order_Status__c = 'Confirmed' );
        insert ordDestination;
        
        
        
        
        OrderDestinationItem__c ordDest = new OrderDestinationItem__c(OrderDestination__c = ordDestination.Id, POS_Item__c = posItem.Id, Quantity__c = 10, Item_Price__c= 10);
        insert ordDest;
        
        
        Test.startTest();
        ProgramOrderBrandSummary.getProgramList();
        ProgramOrderBrandSummary.ReportWithTotalBrandOrder(program.Id);
        Test.stopTest();
        
        
        
        
    }
  
    
    
}