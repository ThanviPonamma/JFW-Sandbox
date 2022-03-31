@isTest
private class CopperManageAddressBook_ApexTest {
    @isTest
    private static void testController ()
    {
        Account acct = new Account(Name='Copper Cane');
        insert acct ;
        Contact contact=new Contact(LastName='Testing',AccountId=acct.Id);
        insert contact;
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
        Copper_Cane_Email_Notifications__c CopperCaneCustomSetting=new Copper_Cane_Email_Notifications__c(Name='CopperCane',Cc_Addresses_List__c='thanvi@uxltechnologies.net');
        insert CopperCaneCustomSetting;
        AddressBook__c address = new AddressBook__c(Address__c='addr1', State__c= state.id, Destination_Name__c = 'Dest1', Shipto_Company__c = 'shiptocomp' , Country__c = country.id, Account__c = acct.id, Active__c= true, Phone__c ='+919493908910',Needs_to_be_synchronised__c=true);
        insert address;
        
        Test.startTest();
        CopperManageAddressBook_Apex.currentUser();
        CopperManageAddressBook_Apex.getAllStates();
        CopperManageAddressBook_Apex.getProfile();
        CopperManageAddressBook_Apex.AddressBookListWithSizeWrapper addressList = CopperManageAddressBook_Apex.loadAddressBookListWithSearch(null,10);
        CopperManageAddressBook_Apex.AddressBookListWithSizeWrapper add = CopperManageAddressBook_Apex.loadAddressBookListWithSearch('test',0);
        CopperManageAddressBook_Apex.updateAddressBook(new AddressBook__c (Destination_Name__c='testDestinationName', Shipto_Company__c='testShipToCompany',State__c=state.Id ,Active__c=true,Account__c=acct.Id));
        CopperManageAddressBook_Apex.deactivateAddressBook(add.AddressBookList[0]); 
        CopperManageAddressBook_Apex.synchronizeAddressBook();
        
        //Exception cases
        CopperManageAddressBook_Apex.updateAddressBook(new AddressBook__c (Active__c=true,  Account__c=acct.Id)) ;
        CopperManageAddressBook_Apex.deactivateAddressBook(new AddressBook__c (Destination_Name__c='testDestinationName', Shipto_Company__c='testShipToCompany',State__c=state.Id ,Active__c=true,Account__c=null));
        Test.stopTest();
    }
}