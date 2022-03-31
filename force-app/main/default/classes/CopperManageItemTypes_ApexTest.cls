@isTest
public class CopperManageItemTypes_ApexTest {
    @isTest
    private static void testController ()
    {
        Account acct =  new Account(Name='Copper Cane');
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
        Copper_Cane_Email_Notifications__c CopperCaneCustomSetting=new Copper_Cane_Email_Notifications__c(Name='CopperCane',Cc_Addresses_List__c='thanvi@uxltechnologies.net');
        insert CopperCaneCustomSetting;
        CopperManageItemTypes_Apex.addOrEditItemType(new Item_Type__c (Item_Type__c='testItemType',Active__c=true, Account__c=acct.Id)) ;
        CopperManageItemTypes_Apex.deactivateItemType(CopperManageItemTypes_Apex.getItemTypeList().itemTypeList[0]);
        //Exception cases
        CopperManageItemTypes_Apex.addOrEditItemType(new Item_Type__c (Active__c=true, Account__c=acct.Id)) ;
        CopperManageItemTypes_Apex.deactivateItemType(new Item_Type__c (Active__c=true,  Account__c=acct.Id));
        Test.stopTest();
        
    }
    
}