@isTest
    public class DFVOrderSummaryReportTest {
        @isTest
        private static void orderSummaryController ()
        {
            Account acc = new Account(Name ='DFV');
            insert acc;
            Contact contact=new Contact(LastName='Testing',AccountId=acc.Id);
            insert contact;
            Profile profile=[SELECT Name FROM Profile WHERE Name='Customer Community Plus User' LIMIT 1];
            User communityUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                          LocaleSidKey='en_US', ProfileId = profile.Id, 
                                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com',ContactId=contact.Id);
            
            insert communityUser;
            
            Brand__c brand = new Brand__c(Account__c=acc.Id,Brand_Name__c='DFV Test Brand',Active__c=true);
            insert brand;
            Item_Type__c itemType = new Item_Type__c(Account__c=acc.Id,Item_Type__c='test Item type',Active__c=true);
            insert itemType;
            POS_Item__c posItem1 = new POS_Item__c(Account__c=acc.Id,Available_Stock__c=10,Brand__c=brand.Id,Type_of_Item__c=itemType.Id,Item_No__c='Test12345',Item_Name__c='test Pos Item 1',Inventory_Seasonal_Program__c='Seasonal Program');
            insert posItem1;
            POS_Item__c posItem2 = new POS_Item__c(Account__c=acc.Id,Available_Stock__c=10,Brand__c=brand.Id,Type_of_Item__c=itemType.Id,Item_No__c='DFv12345',Item_Name__c='test Pos Item 2',Inventory_Seasonal_Program__c='Seasonal Program');
            insert posItem2;
            Program__c program = new Program__c(Account__c=acc.Id,Name__c='Summar Program',Start_Date__c=System.today(),Closing_Date__c=System.today().addDays(2),In_Market_Date__c=System.today().addDays(3));
            insert program;
            Program_Item__c programItem = new Program_Item__c(Program__c=program.Id, POS_Item__c=posItem1.Id);
            insert programItem;
            Country__c country = new Country__c(Country_Code__c='abcd',Country_Name__c='USA');
            insert country;
            State__c state = new State__c(Country__c=country.Id,State_Code__c='CA',State_Name__c='california');
            insert state;
            AddressBook__c addressBook = new AddressBook__c(Account__c=acc.Id,Destination_Name__c='alaska',Shipto_Company__c='delicatowines',State__c=state.Id,Zip__c='12345');
            insert addressBook;
            Order__c order = new Order__c(Account__c=acc.Id,Order_Date__c=System.today(),Order_Status__c='OPEN',Program__c=program.Id);
            insert order;
            OrderDestination__c orderDestinations = new OrderDestination__c(Order__c=order.Id,AddressBook__c=addressBook.Id,OrderDest_Status__c='Submitted',Comet_Order_Status__c='Submitted');
            insert orderDestinations;
            OrderDestinationItem__c orderDestinationItem1 = new OrderDestinationItem__c(OrderDestination__c=orderDestinations.Id,POS_Item__c=posItem1.Id,Quantity__c=12);
            insert orderDestinationItem1;
            OrderDestinationItem__c orderDestinationItem2 = new OrderDestinationItem__c(OrderDestination__c=orderDestinations.Id,POS_Item__c=posItem2.Id,Quantity__c=12);
            insert orderDestinationItem2;
            
            
            Test.startTest();
            DFVOrderSummaryReport.GetOrderDestinationItems(program.Id,UserInfo.getUserId());
            // exception
            DFVOrderSummaryReport.GetOrderDestinationItems('',UserInfo.getUserId());
            Test.stopTest();
        }
    }