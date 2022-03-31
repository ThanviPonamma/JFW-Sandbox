/**Authors: TP,VM Date - 05-01-2021
Aim: To display the assigned and available users list for the selected territory Id
To save the updated assigned users to the list */

public with sharing class WilsonMangeTerritoryUsers_Apex {
    // to hold the account details
    public static Account objAccount;
    // to fetch the account information and store the details in objAccount variable.
    public static Account getAccount() {
        if(Test.isRunningTest())
        {
            //fetch Id, name from the account sObject
            objAccount=[SELECT Id, Name FROM Account
                        WHERE Name LIKE '%Wilson Daniels%' LIMIT 1];
        }
        else
        {
            objAccount=[SELECT Id, Name FROM Account
                        WHERE Lightning_Community_Id__c=:Network.getNetworkId() LIMIT 1];
        }
        return objAccount;
    }
    
    //To fetch the available users list and assigned users list for the incoming territory id
    @AuraEnabled(cacheable=true)
    public static userOptionsListWrapper getCurrentTerritoryUserList(String territoryId)
    {
        //get the account details
        objAccount=getAccount();
        // to hold the available users list
        List<DualListWrapper> allUsers=new List<DualListWrapper> ();
        // to hold the selected users list
        List<Id> selectedUsers=new List<Id> ();
        Map<Id,User> usersInTerritory= new Map<Id,User>([SELECT ID, Name, Email, Username  FROM User usr 
                                                         WHERE usr.AccountId =: objAccount.ID
                                                         AND usr.Id IN (
                                                             SELECT User__C  FROM Users_Territory__c usrdiv WHERE usrdiv.Territory__c = :territoryId)
                                                         ORDER BY usr.Username]);
        selectedUsers.addAll(usersInTerritory.keySet());
        for(User user : [SELECT Id, Name FROM User WHERE AccountId=:objAccount.Id ORDER BY Name])
        {
            allUsers.add(new DualListWrapper(user.Name,user.Id));
        }
        System.debug('allUsers'+allUsers);
        System.debug('selectedUsers'+selectedUsers);
        return new userOptionsListWrapper(allUsers,selectedUsers);
    }
    //to update the selected users list for the selected territory id
    @AuraEnabled 
    public static String addUserToTerritory(List<String> selectedUserIds, String territoryId) {
        try{
            //get the account details
            objAccount=getAccount();
            //To hold the existing users list associated with selected territory id
            Map<Id,User> existingUserTerritoryMap=new Map<Id,User > ([SELECT Id FROM User WHERE Id IN :selectedUserIds AND Id IN (SELECT User__c FROM Users_Territory__c WHERE Territory__c=:territoryId)]);
            //to hold the updated users list to added to the database
            List<Users_Territory__c> newUserTerritoryList=new List<Users_Territory__c> ();
            for(String userId : selectedUserIds)
            {
                if(!existingUserTerritoryMap.containsKey(userId))
                {
                    Users_Territory__c territoryUser=new Users_Territory__c();
                    territoryUser.User__c=userId;
                    territoryUser.Territory__c=territoryId;
                    newUserTerritoryList.add(territoryUser); 
                }
            }
            insert newUserTerritoryList;
            //to delete the users that are not associated territory
            delete [SELECT Id FROM Users_Territory__c WHERE Territory__c=:territoryId AND User__c NOT IN :selectedUserIds];
            System.debug('done');
            return 'done';
        }
        catch(Exception ex){
            //send email notification incase of exceptions
            WilsonEmailNotifications.sendNotification('Update Territory User',ex.getMessage()+'\n'+'Inputs are -- selectedUserIds-- '+JSON.serialize(selectedUserIds)
                                                      +'\n'+'-- territoryId -- '+JSON.serialize(territoryId)+'\n'+'Class Name - WilsonMangeTerritoryUsers_Apex '+'-- Line number --'+ex.getLineNumber());
            System.debug('not done');
            return 'not done';
        }
    }
    //Wrapper class responsible to hold the selected and available users list
    public class userOptionsListWrapper
    {
        //to hold the list of all users
        @AuraEnabled
        public List<DualListWrapper> allUsers;
        //to hold the list of selected users
        @AuraEnabled
        public List<String> selectedUsers;
        //creating a constructor for the above class
        public userOptionsListWrapper (List<DualListWrapper> allUsers,List<String> selectedUsers)
        {
            this.allUsers=allUsers;
            this.selectedUsers=selectedUsers;
        }
    }
    // Wrapper class responsible to hold the label and value of the available users list
    public class DualListWrapper 
    {
        //to hold the name of the territory
        @AuraEnabled
        public String label;
        //to hold the Id of the territory
        @AuraEnabled
        public String value;
        public DualListWrapper(String label,String value)
        {
            this.label=label;
            this.value=value;
        }
    }
}