@isTest
public class JFWMangeTerritories_ApexTest {
    @isTest
    private static void testController ()
    {
        Account acct = new Account(Name='JFW');
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
        JFW_Email_Notifications__c JFWCustomSetting=new JFW_Email_Notifications__c(Name='JFW',Cc_Addresses_List__c='Pradeep@uxltechnologies.net');
        insert JFWCustomSetting;
        Test.startTest();
        JFWMangeTerritories_Apex.addTerritory(new Territory__c(Territory_Name__c='territoryName' , Active__c=true , Account__c = acct.Id));
        JFWMangeTerritories_Apex.deactivateTerritoryApex(JFWMangeTerritories_Apex.getTerritoryList(). territoryList[0]);
        JFWMangeTerritories_Apex.territoryListWithNames territoryList = JFWMangeTerritories_Apex.getTerritoryList();
        //JFWMangeTerritoryUsers_Apex - Manage Users
        JFWMangeTerritoryUsers_Apex.getCurrentTerritoryUserList(territoryList.territoryList[0].Id);
        JFWMangeTerritoryUsers_Apex.addUserToTerritory(new List<String> {communityUser.Id},territoryList.territoryList[0].Id);
        
        //JFWMangeTerritoryStates_Apex - Manage States
        
        JFWMangeTerritoryStates_Apex.getCurrentTerritoryStateList(territoryList.territoryList[0].Id);  
        JFWMangeTerritoryStates_Apex.addStateToTerritory(new List<String> {state.Id} ,territoryList.territoryList[0].Id);
        
        //Exception cases
        JFWMangeTerritories_Apex.addTerritory(new Territory__c( Active__c=true , Account__c = acct.Id));
        JFWMangeTerritories_Apex.deactivateTerritoryApex(new Territory__c( Active__c=true , Account__c = acct.Id));
        JFWMangeTerritoryUsers_Apex.addUserToTerritory(new List<String> {communityUser.Id},null);
        JFWMangeTerritoryStates_Apex.addStateToTerritory(new List<String> {state.Id} , null);
        Test.stopTest();
    }
}