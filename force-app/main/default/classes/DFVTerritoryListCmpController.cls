public class DFVTerritoryListCmpController {
    public static Account objAccount;
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
        return objAccount;
    }
    @AuraEnabled
    public static territoryListWithNames getTerritoryList() {
        objAccount=getAccount();
        List<Territory__c> territoryList = new List<Territory__c>();
        List<String> territoryNamesForValidation=new List<String> ();
        for(Territory__c territory :[SELECT Id, Territory_Name__c, Account__c, Active__c FROM Territory__c
                    WHERE Account__c=:objAccount.Id ORDER BY Territory_Name__c])
        {
            territoryNamesForValidation.add(territory.Territory_Name__c.remove(' ').trim().toUppercase());
            territoryList.add(territory);
        }
        return new territoryListWithNames(territoryList,territoryNamesForValidation); 
    }
    @AuraEnabled
    public static territoryListWithNames addTerritory(Territory__c selectedTerritory) {
    
    try{
     objAccount=getAccount();
        Territory__c territory = selectedTerritory;
        territory.Account__c = objAccount.Id;
        upsert territory;
    }
    catch(Exception ex){
      DFVEmailNotifications.sendNotification('Inserting a Territory',ex.getMessage()+'\n'+'Inputs are -- selectedTerritory-- '+JSON.serialize(selectedTerritory)
                                                    +'\n'+'Class Name - DFVTerritoryListCmpController '+'-- Line number --'+ex.getLineNumber());
    }
    
        return getTerritoryList();
    }
    @AuraEnabled
    public static territoryListWithNames deactivateTerritoryApex(Territory__c selectedTerritory) {
    try{
        objAccount=getAccount();
        Territory__c territory = selectedTerritory;
        territory.Active__c = false;
        update territory;
    }
    catch(Exception ex){
    DFVEmailNotifications.sendNotification('Deactivating a Territory',ex.getMessage()+'\n'+'Inputs are -- selectedTerritory-- '+JSON.serialize(selectedTerritory)
                                                    +'\n'+'Class Name - DFVTerritoryListCmpController '+'-- Line number --'+ex.getLineNumber());
    }
       
        return getTerritoryList();
    }
    @AuraEnabled
    public static List<User> getAccountUsers() {
        objAccount=getAccount();
        List<User> userList = [SELECT Id, Name FROM User WHERE AccountId=:objAccount.Id ORDER BY Name]; 
        return userList;
    }
    @AuraEnabled
     public static userOptionsListWrapper getCurrentTerritoryUserList(String territoryId)
    {
        objAccount=getAccount();
        List<DualListWrapper> allUsers=new List<DualListWrapper> ();
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
        return new userOptionsListWrapper(allUsers,selectedUsers);
    }
    @AuraEnabled 
    public static String addUserToTerritory(List<String> selectedUserIds, String territoryId) {
    try{
     objAccount=getAccount();
        Map<Id,User> existingUserTerritoryMap=new Map<Id,User > ([SELECT Id FROM User WHERE Id IN :selectedUserIds AND Id IN (SELECT User__c FROM Users_Territory__c WHERE Territory__c=:territoryId)]);
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
        delete [SELECT Id FROM Users_Territory__c WHERE Territory__c=:territoryId AND User__c NOT IN :selectedUserIds];
    }
    catch(Exception ex){
     DFVEmailNotifications.sendNotification('Update Territory User',ex.getMessage()+'\n'+'Inputs are -- selectedUserIds-- '+JSON.serialize(selectedUserIds)
                                                    +'\n'+'-- territoryId -- '+JSON.serialize(territoryId)+'\n'+'Class Name - DFVTerritoryListCmpController '+'-- Line number --'+ex.getLineNumber());
    }
       
        return 'successFully';
    }
     @AuraEnabled
     public static List<State__c> getAllStates() {
        objAccount=getAccount();
        List<State__c> stateList =[SELECT ID, Name, State_Code__c, State_Name__c FROM State__c st 
                                   ORDER BY st.State_Name__c]; 
        return stateList;
    }
     @AuraEnabled
     public static StateOptionsListWrapper getCurrentTerritoryStateList(String territoryId)
    {
        objAccount=getAccount();
        List<DualListWrapper> allStates=new List<DualListWrapper> ();
        List<Id> selectedStates=new List<Id> ();
        Map<Id,State__c> statesInTerritory= new Map<Id,State__c>([SELECT ID, Name, State_Code__C, State_Name__C FROM State__c st 
                                           WHERE st.Id IN (
                                           SELECT State__c  FROM States_Territory__c stdiv WHERE stdiv.Territory__c = :territoryId)
                                           ORDER BY st.State_Name__C]);
        selectedStates.addAll(statesInTerritory.keySet());
        for(State__c state :[SELECT ID, Name, State_Code__c, State_Name__c FROM State__c st 
                                   ORDER BY st.State_Name__c])
        {
            allStates.add(new DualListWrapper(state.State_Name__c,state.Id));
        }
        return new StateOptionsListWrapper(allStates,selectedStates);
    }
    @AuraEnabled 
    public static String addStateToTerritory(List<String> selectedStateIds, String territoryId) {
    try{
     objAccount=getAccount();
        Map<Id,State__c> existingStateTerritoryMap=new Map<Id,State__c> ([SELECT Id FROM State__c WHERE Id IN :selectedStateIds 
                                                                          AND Id IN (SELECT State__c FROM States_Territory__c WHERE Territory__c=:territoryId)]);
        List<States_Territory__c> newStatesTerritoryList=new List<States_Territory__c> ();
        for(String stateId : selectedStateIds)
        {
            if(!existingStateTerritoryMap.containsKey(stateId))
            {
                States_Territory__c territoryState=new States_Territory__c();
                territoryState.State__c=stateId;
                territoryState.Territory__c=territoryId;
                newStatesTerritoryList.add(territoryState);
            }
        }
        insert newStatesTerritoryList;
        delete [SELECT Id FROM States_Territory__c WHERE Territory__c=:territoryId AND State__c NOT IN :selectedStateIds];
    }
    catch(Exception ex){
     DFVEmailNotifications.sendNotification('Add a State To Territory',ex.getMessage()+'\n'+'Inputs are -- selectedStateIds-- '+JSON.serialize(selectedStateIds)
                                                    +'\n'+'-- territoryId -- '+JSON.serialize(territoryId)+'\n'+'Class Name - DFVTerritoryListCmpController '+'-- Line number --'+ex.getLineNumber());
    }
       
        return 'Successful';
    }
    
    public class territoryListWithNames
    {
        @AuraEnabled
        public List<Territory__c> territoryList;
        @AuraEnabled
        public List<String> territoryNamesForValidation;
        public territoryListWithNames(List<Territory__c> territoryList,List<String> territoryNamesForValidation)
        {
            this.territoryList=territoryList;
            this.territoryNamesForValidation=territoryNamesForValidation;
        }
    }
    public class StateOptionsListWrapper
    {
        @AuraEnabled
        public List<DualListWrapper> allStates;
        @AuraEnabled
        public List<String> selectedStates;
        public StateOptionsListWrapper (List<DualListWrapper> allStates,List<String> selectedStates)
        {
            this.allStates=allStates;
            this.selectedStates=selectedStates;
        }
    }
    public class userOptionsListWrapper
    {
        @AuraEnabled
        public List<DualListWrapper> allUsers;
        @AuraEnabled
        public List<String> selectedUsers;
        public userOptionsListWrapper (List<DualListWrapper> allUsers,List<String> selectedUsers)
        {
            this.allUsers=allUsers;
            this.selectedUsers=selectedUsers;
        }
    }
    public class DualListWrapper 
    {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
        public DualListWrapper(String label,String value)
        {
            this.label=label;
            this.value=value;
        }
    }
}