@isTest
public class InfiniumManageItemTypes_ApexTest {
    @isTest
    private static void testController ()
    {
        Account acct =  new Account(Name='Infinium Spirits');
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
        Infinium_Spirits_Email_Notifications__c InfiniumSpiritsCustomSetting=new Infinium_Spirits_Email_Notifications__c(Name='InfiniumSpirits',Cc_Addresses_List__c='thanvi@uxltechnologies.net');
        insert InfiniumSpiritsCustomSetting;
        InfiniumManageItemTypes_Apex.addOrEditItemType_Apex(new Item_Type__c (Item_Type__c='testItemType',Active__c=true, Account__c=acct.Id)) ;
        InfiniumManageItemTypes_Apex.deactivateItemType_Apex(InfiniumManageItemTypes_Apex.getItemTypeList_Apex().itemTypeList[0]);
        //Exception cases
        InfiniumManageItemTypes_Apex.addOrEditItemType_Apex(new Item_Type__c (Active__c=true, Account__c=acct.Id)) ;
        InfiniumManageItemTypes_Apex.deactivateItemType_Apex(new Item_Type__c (Active__c=true,  Account__c=acct.Id));
        Test.stopTest();
        
    }
    
}