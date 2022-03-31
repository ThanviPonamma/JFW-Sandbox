@isTest
private class DFVBrandListCmpControllerTest {
    @isTest
    private static void testController ()
    {
        Account acct = new Account(Name='DFV');
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
        DFV_Email_Notifications__c DFVCustomSetting=new DFV_Email_Notifications__c(Name='DFV',Cc_Addresses_List__c='Pradeep@uxltechnologies.net');
        insert DFVCustomSetting;
        Test.startTest();
        DFVBrandListCmpController.getAccount();
        DFVBrandListCmpController.addBrand(new Brand__c(Brand_Name__c='testBrand2',Active__c=true,Account__c=acct.id));
        DFVBrandListCmpController.getBrandList();
        DFVBrandListCmpController.addBrand(brand);
        DFVBrandListCmpController.addUserToBrandManager(new List<Id> {communityUser.Id},brand.Id);
        DFVBrandListCmpController.addUserToBrandManager(new List<Id> {communityUser.Id},brand.Id);
        DFVBrandListCmpController.deactivateBrandApex(brand);
        DFVBrandListCmpController.getCurrentBrandMangerList(brand.Id);
        //email notifications
        DFVBrandListCmpController.addBrand(new Brand__c(Active__c=true,Account__c=acct.id));
        DFVBrandListCmpController.deactivateBrandApex(new Brand__c(Id=brand.Id,Account__c=null));
        DFVBrandListCmpController.addUserToBrandManager(new List<Id> {communityUser.Id},null);
        Test.stopTest();
    }
}