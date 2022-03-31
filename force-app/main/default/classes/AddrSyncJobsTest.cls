@isTest
private class AddrSyncJobsTest {
    static testmethod void constructorTest(){
        
        Account acct = new Account(Name='testAcct', hasCometConfiguration__c =true, CometJobNo__c = '76961', CometUsername__c ='GJayaram', CometPassword__c= 'IRG123');
        insert acct ;
        
        acct = new Account(Name='Bogle Vineyards', hasCometConfiguration__c =true, CometJobNo__c = '76961', CometUsername__c ='GJayaram', CometPassword__c= 'IRG123', BudgetRuleNo__c =1, ApproverName__C= 'ApprName', ApprovalMailsList__C='uday@uxlconsulting.com, uday@ambood.com', hasAppovalsConfiguration__C= true);
        insert acct ;
        

        
        //acct = new Account(Name='Guarachi Wine Partners', hasCometConfiguration__c =true, CometJobNo__c = '76961', CometUsername__c ='GJayaram', CometPassword__c= 'IRG123', BudgetRuleNo__c =1, ApproverName__C= 'ApprName', ApprovalMailsList__C='uday@uxlconsulting.com, uday@ambood.com', hasAppovalsConfiguration__C= true);
        //insert acct ;
        
        //acct = new Account(Name='Bogle');
        //insert acct ;
        
        Country__c c = new Country__c(Country_Code__c='US', Country_Name__c ='US');
        insert c;
        State__c state = new State__c( Country__c= c.id, State_Code__c='NY',  State_Name__c='Newyork');
        insert state;
        AddressBook__c address = new AddressBook__c(Address__c='addr1', State__c= state.id, Destination_Name__c = 'Dest1', Shipto_Company__c = 'shiptocomp' , Country__c = c.id, Active__c = true, Account__c = acct.id, Needs_to_be_synchronised__c= True);
        insert address;
        
       
        
        // set up some test data to work with
        Territory__c territory = new Territory__c(Territory_Name__c='testTerritory', Active__c = true, Account__c = acct.id);
        insert territory ;
        System.assertEquals('testTerritory', territory.Territory_Name__c);
        
        
        States_Territory__c stTer = new States_Territory__c(State__c = state.id,Territory__c = territory.id);
        insert stTer ;
       
        String UserId = userinfo.getUserId();  
        Users_Territory__c usrter;
        usrter = new Users_Territory__c(Territory__c = territory.id, User__c = UserId);
        insert usrter ;
        
        acct = new Account(Name='Guarachi Wine Partners', hasCometConfiguration__c =true, CometJobNo__c = '76961', CometUsername__c ='GJayaram', CometPassword__c= 'IRG123', BudgetRuleNo__c =1, ApproverName__C= 'ApprName', ApprovalMailsList__C='uday@uxlconsulting.com, uday@ambood.com', hasAppovalsConfiguration__C= true);
        insert acct ;
        
        address = new AddressBook__c(Address__c='addr1', State__c= state.id, Destination_Name__c = 'Dest1', Shipto_Company__c = 'shiptocomp' , Country__c = c.id, Active__c = true, Account__c = acct.id, Needs_to_be_synchronised__c= True);
        insert address;
        
       
        
        // set up some test data to work with
        territory = new Territory__c(Territory_Name__c='testTerritory', Active__c = true, Account__c = acct.id);
        insert territory ;
        System.assertEquals('testTerritory', territory.Territory_Name__c);
        
        
        stTer = new States_Territory__c(State__c = state.id,Territory__c = territory.id);
        insert stTer ;
       
        usrter = new Users_Territory__c(Territory__c = territory.id, User__c = UserId);
        insert usrter ;
        
        // Mionetto Data
        acct = new Account(Name='Mionetto', hasCometConfiguration__c =true, CometJobNo__c = '76961', CometUsername__c ='GJayaram', CometPassword__c= 'IRG123', BudgetRuleNo__c =1, ApproverName__C= 'ApprName', ApprovalMailsList__C='uday@uxlconsulting.com, uday@ambood.com', hasAppovalsConfiguration__C= true);
        insert acct ;
        
        address = new AddressBook__c(Address__c='addr1', State__c= state.id, Destination_Name__c = 'Dest1', Shipto_Company__c = 'shiptocomp' , Country__c = c.id, Active__c = true, Account__c = acct.id, Needs_to_be_synchronised__c= True);
        insert address;
        
        
        // set up some test data to work with
        territory = new Territory__c(Territory_Name__c='testTerritory', Active__c = true, Account__c = acct.id);
        insert territory ;
        System.assertEquals('testTerritory', territory.Territory_Name__c);
        
        
        stTer = new States_Territory__c(State__c = state.id,Territory__c = territory.id);
        insert stTer ;
       
        usrter = new Users_Territory__c(Territory__c = territory.id, User__c = UserId);
        insert usrter ;
        
        // DFV Data
        acct = new Account(Name='DFV', hasCometConfiguration__c =true, CometJobNo__c = '76961', CometUsername__c ='GJayaram', CometPassword__c= 'IRG123', BudgetRuleNo__c =1, ApproverName__C= 'ApprName', ApprovalMailsList__C='uday@uxlconsulting.com, uday@ambood.com', hasAppovalsConfiguration__C= true);
        insert acct ;
        
        address = new AddressBook__c(Address__c='addr1', State__c= state.id, Destination_Name__c = 'Dest1', Shipto_Company__c = 'shiptocomp' , Country__c = c.id, Active__c = true, Account__c = acct.id, Needs_to_be_synchronised__c= True);
        insert address;
        
        
        // set up some test data to work with
        territory = new Territory__c(Territory_Name__c='testTerritory', Active__c = true, Account__c = acct.id);
        insert territory ;
        System.assertEquals('testTerritory', territory.Territory_Name__c);
        
        
        stTer = new States_Territory__c(State__c = state.id,Territory__c = territory.id);
        insert stTer ;
       
        usrter = new Users_Territory__c(Territory__c = territory.id, User__c = UserId);
        insert usrter ;
        
        // DAOU Data
        acct = new Account(Name='DAOU', hasCometConfiguration__c =true, CometJobNo__c = '76961', CometUsername__c ='GJayaram', CometPassword__c= 'IRG123', BudgetRuleNo__c =1, ApproverName__C= 'ApprName', ApprovalMailsList__C='uday@uxlconsulting.com, uday@ambood.com', hasAppovalsConfiguration__C= true);
        insert acct ;
        
        address = new AddressBook__c(Address__c='addr1', State__c= state.id, Destination_Name__c = 'Dest1', Shipto_Company__c = 'shiptocomp' , Country__c = c.id, Active__c = true, Account__c = acct.id, Needs_to_be_synchronised__c= True);
        insert address;
        
        
        // set up some test data to work with
        territory = new Territory__c(Territory_Name__c='testTerritory', Active__c = true, Account__c = acct.id);
        insert territory ;
        System.assertEquals('testTerritory', territory.Territory_Name__c);
        
        
        stTer = new States_Territory__c(State__c = state.id,Territory__c = territory.id);
        insert stTer ;
       
        usrter = new Users_Territory__c(Territory__c = territory.id, User__c = UserId);
        insert usrter ;
        // start the test execution context
        Test.startTest();
        
      
        
        AddrSyncJobs.SyncDFVAddresses();
        
      
        
        // stop the test
        Test.stopTest();
        
    }
}