@isTest
public class DFVTerritoryListCmpControllerTest {
     @isTest
    private static void testController ()
    {
        Account acct = new Account(Name='DFV');
        insert acct ;
        Contact contact=new Contact(LastName='Testing',AccountId=acct.Id);
        insert contact;
        Country__c country=new Country__c(Active__c=true , Country_Code__c='countryCode' , Country_Name__c='countryName');
        insert country;
        State__c state = new State__c(State_Name__c='testState', Active__c = true, Country__c=country.id ,State_Code__c='stateCode');
        insert state ;
        Profile profile=[SELECT Name FROM Profile WHERE Name='Customer Community Plus User' LIMIT 1];
        User communityUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = profile.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com',ContactId=contact.Id);
        insert communityUser;
           DFV_Email_Notifications__c DFVCustomSetting=new DFV_Email_Notifications__c(Name='DFV',Cc_Addresses_List__c='Pradeep@uxltechnologies.net');
        insert DFVCustomSetting;
        Test.startTest();
        DFVTerritoryListCmpController.addTerritory(new Territory__c(Territory_Name__c='territoryName' , Active__c=true , Account__c = acct.Id));
        DFVTerritoryListCmpController.deactivateTerritoryApex(DFVTerritoryListCmpController.getTerritoryList(). territoryList[0]);
        DFVTerritoryListCmpController.getAccountUsers();
        DFVTerritoryListCmpController.addUserToTerritory(new List<String> {communityUser.Id},DFVTerritoryListCmpController.getTerritoryList(). territoryList[0].Id);
        DFVTerritoryListCmpController.getCurrentTerritoryUserList(DFVTerritoryListCmpController.getTerritoryList(). territoryList[0].Id);
        DFVTerritoryListCmpController.getAllStates();
        DFVTerritoryListCmpController.addStateToTerritory(new List<String> {state.Id} , DFVTerritoryListCmpController.getTerritoryList(). territoryList[0].Id);
        DFVTerritoryListCmpController.getCurrentTerritoryStateList(DFVTerritoryListCmpController.getTerritoryList(). territoryList[0].Id);  
        //Exception cases
         DFVTerritoryListCmpController.addTerritory(new Territory__c( Active__c=true , Account__c = acct.Id));
         DFVTerritoryListCmpController.deactivateTerritoryApex(new Territory__c( Active__c=true , Account__c = acct.Id));
         DFVTerritoryListCmpController.addUserToTerritory(new List<String> {communityUser.Id},null);
         DFVTerritoryListCmpController.addStateToTerritory(new List<String> {state.Id} , null);
            Test.stopTest();
}
}