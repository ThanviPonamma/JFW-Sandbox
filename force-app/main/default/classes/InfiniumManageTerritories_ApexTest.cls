@isTest
public class InfiniumManageTerritories_ApexTest {
    @isTest
    private static void testController ()
    {
        Account acct = new Account(Name='Infinium Spirits');
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
        Infinium_Spirits_Email_Notifications__c InfiniumSpiritsCustomSetting=new Infinium_Spirits_Email_Notifications__c(Name='InfiniumSpirits',Cc_Addresses_List__c='thanvi@uxltechnologies.net');
        insert InfiniumSpiritsCustomSetting;
        Test.startTest();
        InfiniumManageTerritories_Apex.saveTerritory_Apex(new Territory__c(Territory_Name__c='territoryName' , Active__c=true , Account__c = acct.Id));
        InfiniumManageTerritories_Apex.deactivateTerritoryApex(InfiniumManageTerritories_Apex.getTerritoryList(). territoryList[0]);
        InfiniumManageTerritories_Apex.territoryListWithNames territoryList = InfiniumManageTerritories_Apex.getTerritoryList();
        //InfiniumMangeTerritoryUsers_Apex - Manage Users
        InfiniumMangeTerritoryUsers_Apex.getCurrentTerritoryUserList(territoryList.territoryList[0].Id);
        InfiniumMangeTerritoryUsers_Apex.addUserToTerritory(new List<String> {communityUser.Id},territoryList.territoryList[0].Id);
        
        //InfiniumMangeTerritoryStates_Apex - Manage States
        
        InfiniumManageTerritoriesStates_Apex.getCurrentTerritoryStateList(territoryList.territoryList[0].Id);  
        InfiniumManageTerritoriesStates_Apex.addStateToTerritory(new List<String> {state.Id} ,territoryList.territoryList[0].Id);
        
        //Exception cases
        InfiniumManageTerritories_Apex.saveTerritory_Apex(new Territory__c( Active__c=true , Account__c = acct.Id));
        InfiniumManageTerritories_Apex.deactivateTerritoryApex(new Territory__c( Active__c=true , Account__c = acct.Id));
        InfiniumMangeTerritoryUsers_Apex.addUserToTerritory(new List<String> {communityUser.Id},null);
        InfiniumManageTerritoriesStates_Apex.addStateToTerritory(new List<String> {state.Id} , null);
        Test.stopTest();
    }
}