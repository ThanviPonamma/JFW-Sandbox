@isTest
public class ProgramChairBudgetForUserWithNoOrderTest {
    
    @isTest
    private static void userSummaryWithNoOrderController(){
        
        Account account = new Account(Name = 'DFV');
        insert account;
        
        Contact contact=new Contact(LastName='Testing',AccountId=account.Id);
        insert contact;
        
        Contact contact2=new Contact(LastName='Testing2',AccountId=account.Id);
        insert contact2;
        Profile profile=[SELECT Name FROM Profile WHERE Name='Customer Community Plus User' LIMIT 1];
        User communityUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                      EmailEncodingKey='UTF-8', FirstName = 'Varsha',LastName='Testing', LanguageLocaleKey='en_US', 
                                      LocaleSidKey='en_US', ProfileId = profile.Id,CommunityNickname = 'Goverdhan Jayaram',  
                                      TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com',ContactId=contact.Id);
        insert communityUser;
        
        User communityUser2 = new User(Alias = 'Some', Email='standard@testorg.com', 
                                      EmailEncodingKey='UTF-8', FirstName = 'Varsha1',LastName='Testing1', LanguageLocaleKey='en_US', 
                                      LocaleSidKey='en_US', ProfileId = profile.Id,CommunityNickname = 'Jayaram1',  
                                      TimeZoneSidKey='America/Los_Angeles', UserName='standard@testorg.com',ContactId=contact2.Id);
        insert communityUser2;
        
        Brand__c brand = new Brand__c(Brand_Name__c = 'Nike' ,Account__c = account.Id );
        insert brand;
        Item_Type__c itemType = new Item_Type__c(Item_Type__c ='Shoes' ,Account__c = account.Id );
        insert itemType;
        POS_Item__c posItem = new POS_Item__c(Account__c = account.Id ,Brand__c = brand.Id, Type_of_Item__c =itemType.Id,Item_Name__c='Nike Cap',Item_No__c = 'TEST-101', Price__c = 100);
        insert posItem;
        Program__c program = new Program__c(Name__c='Holiday Test',Start_Date__c=System.today(),Closing_Date__c=System.today().addDays(3),In_Market_Date__c=System.today().addDays(5));
        insert program;
        
        Order__c order = new Order__c(Account__c = account.Id, Program__c =program.Id);
        insert order;
                Country__c country = new Country__c(Country_Code__c = 'USA', Country_Name__c= 'Unite State');
        insert country;
        State__c state = new State__c(Country__c = country.Id, State_Code__c= 'KA', State_Name__c	= 'Karnataka' );
        insert state;
        
        AddressBook__c addressBook = new AddressBook__c(Account__c = account.Id, Destination_Name__c = 'Jaya Prasad',Shipto_Company__c = 'UXL Technologies', State__c = state.Id );
        insert addressBook;
        
        OrderDestination__c ordDestination = new OrderDestination__c(Order__c = order.Id, AddressBook__c = addressBook.Id , Comet_Order_Status__c = 'Confirmed' );
        insert ordDestination;
        
       Chair__c chair = new Chair__c(Chair_Name__c = 'Regional Manager',Level__c = '1', User__c =communityUser.Id );
        insert chair;
        
        Chair__c chair2 = new Chair__c(Chair_Name__c = 'Regional Sale Manager',Level__c = '1', User__c =communityUser2.Id );
        insert chair2;
        
        Chair_Budget__c chairBudget = new Chair_Budget__c(Allocated_Budget__c = 10000,Chair__c = chair.Id, Program__c = program.Id);
        insert chairBudget;
        
         Chair_Budget__c chairBudget2 = new Chair_Budget__c(Allocated_Budget__c = 10000,Chair__c = chair2.Id, Program__c = program.Id);
        insert chairBudget2;
        
         Test.startTest();
         ProgramChairBudgetForUserWithNoOrder.getProgramList();
         ProgramChairBudgetForUserWithNoOrder.UserReportWithNoOrders(program.Id);
         Test.stopTest();
        
        
    }

}