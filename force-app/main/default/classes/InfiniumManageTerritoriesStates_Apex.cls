/**Author : Sanjana; Date : 20-09-2021
Aim: To display the assigned and available state list for the selected territory Id
To save the updated assigned state to the list*/

public with sharing class InfiniumManageTerritoriesStates_Apex {
    
    //To fetch the avaialble state list and assigned states list for the incoming territory id
    @AuraEnabled(cacheable=true)
    public static StateOptionsListWrapper getCurrentTerritoryStateList(String territoryId)
    {
        
        // to hold the available state list
        List<DualListWrapper> allStates=new List<DualListWrapper> ();
        // to hold the selected state list
        List<Id> selectedStates=new List<Id> ();
        //map to hold state id with state details
        Map<Id,State__c> statesInTerritory= new Map<Id,State__c>([SELECT ID, Name, State_Code__C, State_Name__C FROM State__c st  WHERE st.Id IN (
            SELECT State__c  FROM States_Territory__c stdiv WHERE stdiv.Territory__c = :territoryId)
                                                                  ORDER BY st.State_Name__C]);
        //push al the state Id and list to the variable   selectedStates                                                        
        selectedStates.addAll(statesInTerritory.keySet());
        //for all state, add state name and state id to the variable allStates
        for(State__c state :[SELECT ID, Name, State_Code__c, State_Name__c FROM State__c st 
                             ORDER BY st.State_Name__c])
        {
            allStates.add(new DualListWrapper(state.State_Name__c,state.Id));
        }
        System.debug('allStates'+allStates);
        System.debug('selectedStates'+selectedStates);
        //return all staes and selected states
        return new StateOptionsListWrapper(allStates,selectedStates);
    }
    //Wrapper class responsible to hold the selected and available state list
    public class StateOptionsListWrapper
    {
        //variable of type List of wrapper class DualListWrapper to hold the list of states
        @AuraEnabled
        public List<DualListWrapper> allStates;
        //variable of type list of string to hold the selected states
        @AuraEnabled
        public List<String> selectedStates;
        public StateOptionsListWrapper (List<DualListWrapper> allStates,List<String> selectedStates)
        {
            this.allStates=allStates;
            this.selectedStates=selectedStates;
        }
    }
    // Wrapper class responsible to hold the label and value of the available state list
    public class DualListWrapper 
    {
        //variable of type string to hold the state name
        @AuraEnabled
        public String label;
        //variable of type string to hold the state Id
        @AuraEnabled
        public String value;
        public DualListWrapper(String label,String value)
        {
            this.label=label;
            this.value=value;
        }
    }
    //to update the selected state list for the selected territory id
    @AuraEnabled 
    public static String addStateToTerritory(List<String> selectedStateIds, String territoryId) {
        try{
            
            //To hold the existing state list associated with selected territory id
            Map<Id,State__c> existingStateTerritoryMap=new Map<Id,State__c> ([SELECT Id FROM State__c WHERE Id IN :selectedStateIds AND Id IN (SELECT State__c FROM States_Territory__c WHERE Territory__c=:territoryId)]);
            //to hold the updated state list to added to the database
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
            //to delete the states that are not associated territory
            delete [SELECT Id FROM States_Territory__c WHERE Territory__c=:territoryId AND State__c NOT IN :selectedStateIds];
        }
        //email notification if there are any errors
        catch(Exception ex){
            InfiniumEmailNotifications.sendNotification('Add a State To Territory',ex.getMessage()+'\n'+'Inputs are -- selectedStateIds-- '+JSON.serialize(selectedStateIds)
                                                      +'\n'+'-- territoryId -- '+JSON.serialize(territoryId)+'\n'+'Class Name - InfiniumManageTerritoriesStates_Apex '+'-- Line number --'+ex.getLineNumber());
        }
        
        return 'Successful';
    }
}