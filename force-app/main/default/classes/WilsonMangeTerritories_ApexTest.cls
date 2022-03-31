@isTest
public class WilsonMangeTerritories_ApexTest {
    @isTest
    private static void testController ()
    {
        Account acct = new Account(Name='Wilson Daniels');
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
        Wilson_Daniel_Email_Notifications__c WilsonDanielCustomSetting=new Wilson_Daniel_Email_Notifications__c(Name='WILSON',Cc_Addresses_List__c='thanvi@uxltechnologies.net');
        insert WilsonDanielCustomSetting;
        Test.startTest();
        WilsonMangeTerritories_Apex.addTerritory(new Territory__c(Territory_Name__c='territoryName' , Active__c=true , Account__c = acct.Id));
        WilsonMangeTerritories_Apex.deactivateTerritoryApex(WilsonMangeTerritories_Apex.getTerritoryList(). territoryList[0]);
        WilsonMangeTerritories_Apex.territoryListWithNames territoryList = WilsonMangeTerritories_Apex.getTerritoryList();
        //WilsonMangeTerritoryUsers_Apex - Manage Users
        WilsonMangeTerritoryUsers_Apex.getCurrentTerritoryUserList(territoryList.territoryList[0].Id);
        WilsonMangeTerritoryUsers_Apex.addUserToTerritory(new List<String> {communityUser.Id},territoryList.territoryList[0].Id);
        
        //WilsonMangeTerritoryStates_Apex - Manage States
        
        WilsonMangeTerritoryStates_Apex.getCurrentTerritoryStateList(territoryList.territoryList[0].Id);  
        WilsonMangeTerritoryStates_Apex.addStateToTerritory(new List<String> {state.Id} ,territoryList.territoryList[0].Id);
        
        //Exception cases
        WilsonMangeTerritories_Apex.addTerritory(new Territory__c( Active__c=true , Account__c = acct.Id));
        WilsonMangeTerritories_Apex.deactivateTerritoryApex(new Territory__c( Active__c=true , Account__c = acct.Id));
        WilsonMangeTerritoryUsers_Apex.addUserToTerritory(new List<String> {communityUser.Id},null);
        WilsonMangeTerritoryStates_Apex.addStateToTerritory(new List<String> {state.Id} , null);
        Test.stopTest();
    }
}