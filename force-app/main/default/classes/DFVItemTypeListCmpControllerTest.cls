@isTest
private class DFVItemTypeListCmpControllerTest {
   @isTest
    private static void testController ()
    {
          Account acct = new Account(Name='DFV');
        insert acct ;
          Contact contact=new Contact(LastName='Testing',AccountId=acct.Id);
        insert contact;
        Profile profile=[SELECT Name FROM Profile WHERE Name='Customer Community Plus User' LIMIT 1];
        User communityUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = profile.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com',ContactId=contact.Id);
        
        insert communityUser;
        DFV_Email_Notifications__c DFVCustomSetting=new DFV_Email_Notifications__c(Name='DFV',Cc_Addresses_List__c='Pradeep@uxltechnologies.net');
        insert DFVCustomSetting;
        Test.startTest();
        DFVItemTypeListCmpController.addItemType(new Item_Type__c (Item_Type__c='testItemType',Active__c=true, Account__c=acct.Id)) ;
        DFVItemTypeListCmpController.deactivateItemTypeApex(DFVItemTypeListCmpController.getItemTypeList().itemTypeList[0]);
        //Exception cases
        DFVItemTypeListCmpController.addItemType(new Item_Type__c (Active__c=true, Account__c=acct.Id)) ;
        DFVItemTypeListCmpController.deactivateItemTypeApex(new Item_Type__c (Active__c=true,  Account__c=acct.Id));
        Test.stopTest();
        
    }
}