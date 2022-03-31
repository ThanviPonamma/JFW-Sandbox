@isTest
public with sharing class JFWManageBrandList_ApexTest {

    @isTest
    private static void testController ()
    {
        Account acct = new Account(Name='JFW');
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
        JFW_Email_Notifications__c JFWCustomSetting=new JFW_Email_Notifications__c(Name='JFW',Cc_Addresses_List__c='sanjana@uxltechnologies.net');
        insert JFWCustomSetting;
        Test.startTest();
        JFWManageBrandList_Apex.getAccount();
        JFWManageBrandList_Apex.addBrand(new Brand__c(Brand_Name__c='testBrand2',Active__c=true,Account__c=acct.id));
        JFWManageBrandList_Apex.getBrandList();
        JFWManageBrandList_Apex.addBrand(brand);
        JFWManageBrandList_Apex.addUserToBrandManager(new List<Id> {communityUser.Id},brand.Id);
        JFWManageBrandList_Apex.addUserToBrandManager(new List<Id> {communityUser.Id},brand.Id);
        JFWManageBrandList_Apex.deactivateBrandApex(brand);
        JFWManageBrandList_Apex.getCurrentBrandMangerList(brand.Id);
        //email notifications
        JFWManageBrandList_Apex.addBrand(new Brand__c(Active__c=true,Account__c=acct.id));
        JFWManageBrandList_Apex.deactivateBrandApex(new Brand__c(Id=brand.Id,Account__c=null));
        JFWManageBrandList_Apex.addUserToBrandManager(new List<Id> {communityUser.Id},null);
        Test.stopTest();
    }
}