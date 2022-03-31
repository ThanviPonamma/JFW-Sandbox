public class ProgramsController {
     //Global variable which holds the account
     public static Account objAccount;
    //To fetch data about DFV from Standard object Account.
    public static Account getAccount() {  
        
        if(Test.isRunningTest())
        {
            objAccount=[SELECT Id, Name FROM Account
                        WHERE Name LIKE '%DFV%' LIMIT 1];
        }
        else
        {
            objAccount=[SELECT Id, Name FROM Account
                        WHERE Lightning_Community_Id__c=:Network.getNetworkId() LIMIT 1];
        }
        return objAccount; // objAccount object contains data about Mionetto.
    }

    @AuraEnabled(cacheable=true)
    //To return all programs to the frontend actor
    public static List<Program__c> GetAllPrograms(){

         //To hold the account details
         objAccount=getAccount();
        //To hold the program list.
        List<Program__c> programsList =  [SELECT Id,
                                          Name__c 
                                         From Program__c WHERE Account__c=:objAccount.Id];
        
        system.debug('programsList' + programsList);
        system.debug('programsList size' + programsList.size());
        
        return programsList;
    }
}