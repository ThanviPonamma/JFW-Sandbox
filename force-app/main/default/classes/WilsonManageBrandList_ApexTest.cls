@isTest
public with sharing class WilsonManageBrandList_ApexTest {
    
    @isTest
    private static void testController ()
    {
        Account acct = new Account(Name='Wilson Daniels');
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
        Wilson_Daniel_Email_Notifications__c WilsonDanielCustomSetting=new Wilson_Daniel_Email_Notifications__c(Name='WILSON',Cc_Addresses_List__c='thanvi@uxltechnologies.net');
        insert WilsonDanielCustomSetting;
        Test.startTest();
        WilsonManageBrandList_Apex.getAccount();
        WilsonManageBrandList_Apex.addBrand(new Brand__c(Brand_Name__c='testBrand2',Active__c=true,Account__c=acct.id));
        WilsonManageBrandList_Apex.getBrandList();
        WilsonManageBrandList_Apex.addBrand(brand);
        WilsonManageBrandList_Apex.addUserToBrandManager(new List<Id> {communityUser.Id},brand.Id);
        WilsonManageBrandList_Apex.addUserToBrandManager(new List<Id> {communityUser.Id},brand.Id);
        WilsonManageBrandList_Apex.deactivateBrandApex(brand);
        WilsonManageBrandList_Apex.getCurrentBrandMangerList(brand.Id);
        //email notifications
        WilsonManageBrandList_Apex.addBrand(new Brand__c(Active__c=true,Account__c=acct.id));
        WilsonManageBrandList_Apex.deactivateBrandApex(new Brand__c(Id=brand.Id,Account__c=null));
        WilsonManageBrandList_Apex.addUserToBrandManager(new List<Id> {communityUser.Id},null);
        Test.stopTest();
    }
}