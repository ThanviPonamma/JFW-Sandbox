@isTest
private class CopperCaneTracking_ApexTest {
    @isTest
    private static void testController ()
    {
        Account acct = new Account(Name='Copper Cane');
        insert acct ;
        Contact contact=new Contact(LastName='Testing',AccountId=acct.Id);
        insert contact;
        Daily_Inventory_Creation__c customSetting=new Daily_Inventory_Creation__c(Trigger_Active_Flag__c=false,Name='Trigger flag');
        insert customSetting;
        Profile profile=[SELECT Name FROM Profile WHERE Name='Customer Community Plus User' LIMIT 1];
        
        Schema.User communityUser = new Schema.User(Alias = 'standt', Email='standarduser@testorg.com', 
                                                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', FirstName='System',
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
        Copper_Cane_Email_Notifications__c CopperCustomSetting=new Copper_Cane_Email_Notifications__c(Name='CopperCane',Cc_Addresses_List__c='thanvi@uxltechnologies.net');
        insert CopperCustomSetting;
        Brand__c brand = new Brand__c (Brand_Name__c='BrandNameSelect',Active__c=true,Account__c=acct.Id);
        insert brand;
        Item_Type__c itemType= new Item_Type__c(Item_Type__c='itemTypeSelect',Active__c=true,Account__c=acct.Id);
        insert itemType;
        POS_Item__c posItem= new POS_Item__c (Item_No__c='Test-No-01',Item_Name__c='testPosItemName',Available_Stock__c=10,Price__c=10.00,
                                              Account__c=acct.Id,Brand__c=brand.Id,Type_of_Item__c=itemType.Id,Active__c=true,Approval_Required__c=true);
        insert posItem;
        
        POS_Item__c posItem2= new POS_Item__c (Item_No__c='Test-No-02',Item_Name__c='testPosItemName',Available_Stock__c=10,Price__c=15.00,
                                               Account__c=acct.Id,Brand__c=brand.Id,Type_of_Item__c=itemType.Id,Active__c=true,Approval_Required__c=true);
        insert posItem2;
        
        Program__c program=new Program__c (Name__c='Testing',Account__c=acct.Id,Start_Date__c=System.today().addDays(-10),
                                           Closing_Date__c=System.today().addDays(+10),
                                           In_Market_Date__c=System.today().addDays(+20));
        insert program;
        
        Program_Item__c prgItem = new Program_Item__c(Program__c=program.Id, POS_Item__c=posItem.Id,Tracking_File_Uploaded__c=false);
        insert prgItem;
        
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
        
        
        Order__c order = new Order__c(Account__c = acct.Id, Order_Date__c =Date.today().addDays(-91), Order_Status__c = 'Confirmed',Program__c=program.Id);
        insert order;
        
        OrderDestination__c orderDestination = new OrderDestination__c(Order__c = order.Id, AddressBook__c =addressBook.Id, OrderDest_Status__c='Needs Approval',Comet_Order_Status__c='Needs Approval',Shipping_Method__c=shippingMethod.Id);
        insert orderDestination;
        OrderDestinationItem__c orderDestinationItems = new OrderDestinationItem__c(OrderDestination__c =orderDestination.Id, POS_Item__c = posItem.Id, Quantity__c = 1);
        insert orderDestinationItems;
        
        //Get Content Documents
        //Create contentVersion
        String str = 'Order Number,Ordered By,Item Number,Item Name,Ordered Quantity,Price,Shipto Name,Ship to Company,Address,Ship to City,State Code,Zip,Phone,Carrier,Tracking Number \n' +
            'IO_7009_2856,Sales Manager,Test-No-01,AG BRUT DUMMY 750 ML,15,300,Josh Hron,General Beverage of Wisconsin,2855 Oregon Street,Oshkosh,WI,54902,1111111111,FedEx,9900417647 \n' +
            'IO_7009_2856,Sales Manager,Test-No-01,AG BRUT DUMMY 750 ML,15,300,Josh Hron,General Beverage of Wisconsin,2855 Oregon Street,Oshkosh,WI,54902,1111111111,FedEx,9900417647';
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'Test.csv';
        cv.VersionData = Blob.valueOf(str);
        cv.IsMajorVersion = true;
        Insert cv;
        
        //Get Content Version
        ContentVersion cvList = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        System.debug(cvList);
        
        Test.startTest();
        CopperCaneTracking_Apex.getProgramList_Apex();
        CopperCaneTracking_Apex.getBrandList();
        CopperCaneTracking_Apex.getProgramPOSList_Apex(program.Id, brand.Id);
        CopperCaneTracking_Apex.getTrackingNumbersOfOrders_Apex(acct.Id,program.Id,posItem.Item_No__c);
        CopperCaneTracking_Apex.UploadCopperTracking_Apex(acct.Id,cvList.ContentDocumentId,program.Id,posItem.Item_No__c);
        CopperCaneTracking_Apex.synchronizeCopperTracking_Apex(acct.Id,program.Id,posItem.Item_No__c);
        
        //Exception
        CopperCaneTracking_Apex.getTrackingNumbersOfOrders_Apex(acct.Id,order.Id,posItem.Id);
        Test.stopTest();
    }
}