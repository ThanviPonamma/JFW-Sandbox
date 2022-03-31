@isTest
private class AddressSynchronizationJobTest {
    static testmethod void constructorTest(){

        Account acct = new Account(Name='Copper Cane', hasCometConfiguration__c =true, CometJobNo__c = '76961', CometUsername__c ='GJayaram', CometPassword__c= 'IRG123', BudgetRuleNo__c =1, hasAppovalsConfiguration__C= true);
        insert acct ;
        String UserId = userinfo.getUserId();  
        Country__c c = new Country__c(Country_Code__c='US', Country_Name__c ='US');
        insert c;
        State__c state = new State__c( Country__c= c.id, State_Code__c='NY',  State_Name__c='Newyork');
        insert state;
        AddressBook__c address = new AddressBook__c(Address__c='addr1', State__c= state.id, Destination_Name__c = 'Dest1', Shipto_Company__c = 'shiptocomp' , Country__c = c.id, Active__c = true, Account__c = acct.id, Needs_to_be_synchronised__c= True);
        insert address;
        
        Territory__c territory = new Territory__c(Territory_Name__c='testTerritory', Active__c = true, Account__c = acct.id);
        insert territory ;
        System.assertEquals('testTerritory', territory.Territory_Name__c);

        States_Territory__c stateTerritory = new States_Territory__c(State__c = state.id,Territory__c = territory.id);
        insert stateTerritory ;
        
        Users_Territory__c userTerritory = new Users_Territory__c(Territory__c = territory.id, User__c = UserId);
        insert userTerritory ;
        
        
        Test.startTest();
        
        AddressSynchronizationJob.SyncCopperCaneAddresses();
        
        // stop the test
        Test.stopTest();
        
    }
}