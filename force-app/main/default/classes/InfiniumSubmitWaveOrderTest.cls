//Authors:Sanjana    Date:11-11-2021
@isTest
public class InfiniumSubmitWaveOrderTest 
{
    @isTest
    private static void InfiniumSubmitWaveOrderTestController()
    {
         //Creating Account
        Account account = new Account(Name = 'Infinium Spirits');
        insert account;
        
        //Creating Contact and user
        Contact contact=new Contact(LastName='Testing',AccountId=account.Id);
        insert contact;
        Profile profile=[SELECT Name FROM Profile WHERE Name='Customer Community Plus User' LIMIT 1];
        User communityUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                      EmailEncodingKey='UTF-8', FirstName = 'Varsha',LastName='Testing', LanguageLocaleKey='en_US', 
                                      LocaleSidKey='en_US', ProfileId = profile.Id,CommunityNickname = 'Goverdhan Jayaram',  
                                      TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com',ContactId=contact.Id);
        insert communityUser;
        //Creating brand
        Brand__c brand = new Brand__c(Brand_Name__c = 'Nike' ,Account__c = account.Id );
        insert brand;
        //Creating Item type
        Item_Type__c itemType = new Item_Type__c(Item_Type__c ='Shoes' ,Account__c = account.Id );
        insert itemType;
        //Creating Pos Item
        POS_Item__c posItem = new POS_Item__c(Account__c = account.Id ,Brand__c = brand.Id, Type_of_Item__c =itemType.Id,Item_Name__c='Nike Cap',Item_No__c = 'TEST-101', Price__c = 100);
        insert posItem;

        //Creating program
        Program__c program = new Program__c(Name__c='Holiday Test',Start_Date__c=System.today(),Closing_Date__c=System.today().addDays(3),In_Market_Date__c=System.today().addDays(5));
        insert program;
        //Creating chair
        Chair__c chair = new Chair__c(Chair_Name__c = 'Regional Manager',Level__c = '1', User__c =communityUser.Id,Account__c=account.Id );
        insert chair;
        //Creating chair budget
        Chair_Budget__c chairBudget = new Chair_Budget__c(Allocated_Budget__c = 10000 ,Chair__c = chair.Id, Program__c = program.Id);
        insert chairBudget;
        
        //Creating Country
        Country__c country = new Country__c(Country_Code__c = 'USA', Country_Name__c= 'Unite State');
        insert country;
        //Creating state
        State__c state = new State__c(Country__c = country.Id, State_Code__c= 'KA', State_Name__c	= 'Karnataka' );
        insert state;
        //Creating address book
        AddressBook__c addressBook = new AddressBook__c(Account__c = account.Id, Destination_Name__c = 'Jaya Prasad',Shipto_Company__c = 'UXL Technologies',Shipto_Name__c ='JP',
                                                        State__c = state.Id , City__c= 'smartcity', Zip__c = '630253', Active__c = true);
        insert addressBook;
        
        //Creating First Order
        Order__c order = new Order__c(Account__c = account.Id, Program__c =program.Id, OwnerId = communityUser.Id);
        insert order;
        //Creating Order Destination
        OrderDestination__c ordDestination = new OrderDestination__c(Order__c = order.Id, AddressBook__c = addressBook.Id , Comet_Order_Status__c = 'Confirmed' , Is_Selected__c = true);
        insert ordDestination;
        //Creating Order Destination items
        OrderDestinationItem__c ordDestItem = new OrderDestinationItem__c(OrderDestination__c = ordDestination.Id, POS_Item__c = posItem.Id, Quantity__c = 10, Item_Price__c= 10, Sent_To_Warehouse__c =false,
                                                                                Wave_Order_Number__c = '' , Ready_To_Be_Sent__c = false , Warehouse_Transaction_Number__c = '', On_Hold__c = false, Order_Destination_Item_Status__c = 'Open');
        insert ordDestItem;
        
        
        
        Test.startTest();
        InfiniumSubmitWaveOrder_Apex.submitSelectedOrdersToComet(program.Id, communityUser.Id);
       
        Test.stopTest();
    }

}