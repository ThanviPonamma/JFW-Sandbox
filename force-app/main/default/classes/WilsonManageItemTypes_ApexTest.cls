@isTest
public class WilsonManageItemTypes_ApexTest {
    @isTest
    private static void testController ()
    {
        Account acct =  new Account(Name='Wilson Daniels');
        insert acct ;
        Contact contact=new Contact(LastName='Testing',AccountId=acct.Id);
        insert contact;
        Profile profile=[SELECT Name FROM Profile WHERE Name='Customer Community Plus User' LIMIT 1];
        User communityUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                      LocaleSidKey='en_US', ProfileId = profile.Id, 
                                      TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com',ContactId=contact.Id);
        
        insert communityUser;
        Test.startTest();
        Wilson_Daniel_Email_Notifications__c WilsonDanielCustomSetting=new Wilson_Daniel_Email_Notifications__c(Name='WILSON',Cc_Addresses_List__c='thanvi@uxltechnologies.net');
        insert WilsonDanielCustomSetting;
        WilsonManageItemTypes_Apex.addOrEditItemType(new Item_Type__c (Item_Type__c='testItemType',Active__c=true, Account__c=acct.Id)) ;
        WilsonManageItemTypes_Apex.deactivateItemType(WilsonManageItemTypes_Apex.getItemTypeList().itemTypeList[0]);
        //Exception cases
        WilsonManageItemTypes_Apex.addOrEditItemType(new Item_Type__c (Active__c=true, Account__c=acct.Id)) ;
        WilsonManageItemTypes_Apex.deactivateItemType(new Item_Type__c (Active__c=true,  Account__c=acct.Id));
        Test.stopTest();
        
    }
    
}