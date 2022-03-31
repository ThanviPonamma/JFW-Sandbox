@isTest
public with sharing class CopperManageBrandList_ApexTest {
    
    @isTest
    private static void testController ()
    {
        Account acct = new Account(Name='Copper Cane');
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
        Copper_Cane_Email_Notifications__c CopperCaneCustomSetting=new Copper_Cane_Email_Notifications__c(Name='CopperCane',Cc_Addresses_List__c='thanvi@uxltechnologies.net');
        insert CopperCaneCustomSetting;
        Test.startTest();
        CopperManageBrandList_Apex.getAccount();
        CopperManageBrandList_Apex.addBrand(new Brand__c(Brand_Name__c='testBrand2',Active__c=true,Account__c=acct.id));
        CopperManageBrandList_Apex.getBrandList();
        CopperManageBrandList_Apex.addBrand(brand);
        CopperManageBrandList_Apex.addUserToBrandManager(new List<Id> {communityUser.Id},brand.Id);
        CopperManageBrandList_Apex.addUserToBrandManager(new List<Id> {communityUser.Id},brand.Id);
        CopperManageBrandList_Apex.deactivateBrandApex(brand);
        CopperManageBrandList_Apex.getCurrentBrandMangerList(brand.Id);
        //email notifications
        CopperManageBrandList_Apex.addBrand(new Brand__c(Active__c=true,Account__c=acct.id));
        CopperManageBrandList_Apex.deactivateBrandApex(new Brand__c(Id=brand.Id,Account__c=null));
        CopperManageBrandList_Apex.addUserToBrandManager(new List<Id> {communityUser.Id},null);
        Test.stopTest();
    }
}