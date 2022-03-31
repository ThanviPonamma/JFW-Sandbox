//Authors: TP,VP Date - 19-10-2020
//Aim: 1: To display the territory List 
//     2: To de-activate the selected territory 
//     3: Update or create a new territory
public class JFWMangeTerritories_Apex {
    // to hold the account details
    public static Account objAccount;
    // to fetch the account information and store the details in objAccount variable
    public static Account getAccount() {
        //used by the test classes
        if(Test.isRunningTest())
        {
            //fetch Id, name from the account sObject
            objAccount=[SELECT Id, Name FROM Account
                        WHERE Name LIKE '%JFW%' LIMIT 1];
        }
        else
        {
             //fetch Id, name from the account sObject
            objAccount=[SELECT Id, Name FROM Account
                      WHERE Lightning_Community_Id__c=:Network.getNetworkId() LIMIT 1];
             //objAccount=[SELECT Id, Name FROM Account
                      //  WHERE Name LIKE '%JFW%' LIMIT 1];
        }
        //return the account details
        return objAccount;
    }
    //to hold the territory list to be displayed, along with territory name that already exist, in order for front end validation
    @AuraEnabled(cacheable=true)
    public static territoryListWithNames getTerritoryList() {
        //to hold the account details
        objAccount=getAccount();
        //to hold the territory list
        List<Territory__c> territoryList = new List<Territory__c>();
        // to hold the territory names for validations
        List<String> territoryNamesForValidation=new List<String> ();
        //to get the territory list and hold each territory name for validations
        for(Territory__c territory :[SELECT Id, Territory_Name__c, Account__c, Active__c FROM Territory__c
                                     WHERE Account__c=:objAccount.Id ORDER BY Territory_Name__c])
        {
            //to remove the spaces in the territory name and convert them to the upper case and store it in the variable territoryNamesForValidation
            territoryNamesForValidation.add(territory.Territory_Name__c.remove(' ').trim().toUppercase());
            //to add the list of territories and store it in the variable territoryList
            territoryList.add(territory);
        }
        System.debug('territoryList'+territoryList);
        System.debug('territoryNamesForValidation'+territoryNamesForValidation);
        //return the wrapper class holdin the variables territoryList and territoryNamesForValidation
        return new territoryListWithNames(territoryList,territoryNamesForValidation); 
    }
    
    //to update or create a new territory
    @AuraEnabled
    public static String addTerritory(Territory__c selectedTerritory) {
        
        try{
            //to hold the account details
            objAccount=getAccount();
            //to add the selected territory detail from the lwc to the Territory__c object
            Territory__c territory = selectedTerritory;
            //to assign the account to territory account field
            territory.Account__c = objAccount.Id;
            upsert territory;
            return 'Done';
        }
        catch(Exception ex){
            JFWEmailNotifications.sendNotification('Inserting a Territory',ex.getMessage()+'\n'+'Inputs are -- selectedTerritory-- '+JSON.serialize(selectedTerritory)
                                                   +'\n'+'Class Name - JFWMangeTerritories_Apex '+'-- Line number --'+ex.getLineNumber());
            
            return'Not Done';
        }
    }
    //to deactivate the selected territory active status
    @AuraEnabled
    public static String deactivateTerritoryApex(Territory__c selectedTerritory) {
        try{
            //hold the account details
            objAccount=getAccount();
            //assign the incoming selectedTerritory to the variable territory of type Territory__c
            Territory__c territory = selectedTerritory;
            //to deactivate the terriory
            territory.Active__c = false;
            //update the record
            update territory;
            //return done
            return 'Done';
        }
        catch(Exception ex){
            JFWEmailNotifications.sendNotification('Deactivating a Territory',ex.getMessage()+'\n'+'Inputs are -- selectedTerritory-- '+JSON.serialize(selectedTerritory)
                                                   +'\n'+'Class Name - JFWMangeTerritories_Apex '+'-- Line number --'+ex.getLineNumber());
            return 'Note Done';
        }
        
    }
    
    //wrapper class to hold the territory list and the territory names for validation
    public class territoryListWithNames
    {
        //variable of type  List<Territory__c> to hold the territory list
        @AuraEnabled
        public List<Territory__c> territoryList;
        //variable of type List<String> to hold the territory name for front end validation
        @AuraEnabled
        public List<String> territoryNamesForValidation;
        public territoryListWithNames(List<Territory__c> territoryList,List<String> territoryNamesForValidation)
        {
            this.territoryList=territoryList;
            this.territoryNamesForValidation=territoryNamesForValidation;
        }
    }
    
}