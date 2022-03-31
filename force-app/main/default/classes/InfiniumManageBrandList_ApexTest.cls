@isTest
public with sharing class InfiniumManageBrandList_ApexTest {
    
    @isTest
    private static void testController ()
    {
        Account acct = new Account(Name='Infinium Spirits');
        insert acct ;
        Contact contact=new Contact(LastName='Testing',AccountId=acct.Id);
        insert contact;
        Brand__c brand = new Brand__c(Brand_Name__c='testBrand', Active__c = true, Account__c = acct.id);
        insert brand ;
        Profile profile=[SELECT Name FROM Profile WHERE Name='Customer Community Plus User' LIMIT 1];
        User communityUser = new User(Alias = 'standt', Email='standarduser@testorg.com',
                                      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                      LocaleSidKey='en_US', ProfileId = profile.Id,
                                      TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com',ContactId=contact.Id);
        insert communityUser;
        Infinium_Spirits_Email_Notifications__c InfiniumSpiritsCustomSetting=new Infinium_Spirits_Email_Notifications__c(Name='InfiniumSpirits',Cc_Addresses_List__c='thanvi@uxltechnologies.net');
        insert InfiniumSpiritsCustomSetting;
        Test.startTest();
        InfiniumManageBrandList_Apex.getAccount();
        InfiniumManageBrandList_Apex.addBrand(new Brand__c(Brand_Name__c='testBrand2',Active__c=true,Account__c=acct.id));
        InfiniumManageBrandList_Apex.getBrandList();
        InfiniumManageBrandList_Apex.addBrand(brand);
        InfiniumManageBrandList_Apex.addUserToBrandManager(new List<Id> {communityUser.Id},brand.Id);
        InfiniumManageBrandList_Apex.addUserToBrandManager(new List<Id> {communityUser.Id},brand.Id);
        InfiniumManageBrandList_Apex.deactivateBrandApex(brand);
        InfiniumManageBrandList_Apex.getCurrentBrandMangerList(brand.Id);
        //email notifications
        InfiniumManageBrandList_Apex.addBrand(new Brand__c(Active__c=true,Account__c=acct.id));
        InfiniumManageBrandList_Apex.deactivateBrandApex(new Brand__c(Id=brand.Id,Account__c=null));
        InfiniumManageBrandList_Apex.addUserToBrandManager(new List<Id> {communityUser.Id},null);
        Test.stopTest();
    }
}