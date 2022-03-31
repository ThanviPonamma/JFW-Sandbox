// Author : Sanjana; Date : 21-09-2021
//class to load chair list, chair details and save chair
public class InfiniumChairUser_Apex {
    public static Account objAccount;
    
    public static Account getAccount() {  
        
        if(Test.isRunningTest())
        {
            objAccount=[SELECT Id, Name FROM Account
                        WHERE Name LIKE '%Infinium Spirits%' LIMIT 1];
        }
        else
        {
            objAccount=[SELECT Id, Name FROM Account
                        WHERE Lightning_Community_Id__c=:Network.getNetworkId() LIMIT 1];
            //    objAccount=[SELECT Id, Name FROM Account
            //    WHERE Name LIKE '%Copper Cane%' LIMIT 1];
        }
        return objAccount; 
    }
    @AuraEnabled(cacheable=true)
    public static List<Chair_FixedPosition> loadChairList_Apex()
    {
        objAccount=getAccount();
        System.debug('Entered----->');
        List<Chair_FixedPosition> chairFixedPosition=new List<Chair_FixedPosition> ();
        Map<Id,Chair__c> chair_Map=new Map<Id,Chair__c> ([SELECT Id,Chair_Name__c,User__r.Name,User__r.LastName,Active__c,Level__c,User__c FROM Chair__c WHERE Account__c=:objAccount.Id]);
        List<Chair_FixedPosition> chairsByPositions=new List<Chair_FixedPosition> ();
        List<Chair_FixedPosition> chairs=new List<Chair_FixedPosition> ();
        Set<Id> chairIds=new Set<Id> ();
        for(Fixed_Position__c fixedPosition : [SELECT Id,Fixed_Position_Name__c,Chair__c FROM Fixed_Position__c
                                               WHERE Organizataion_Chart__r.Checkbox__c=true AND Organizataion_Chart__r.Account__c=:objAccount.Id
                                               AND Chair__c!=null ORDER BY Fixed_Position_Name__c ])
        {
            chairsByPositions.add(new Chair_FixedPosition(chair_Map.get(fixedPosition.Chair__c),fixedPosition));
            chairIds.add(fixedPosition.Chair__c);
        }
        
        for(Chair__c chair : chair_Map.values())
        {
            if(!chairIds.contains(chair.Id))
                chairs.add(new Chair_FixedPosition(chair,new Fixed_Position__c ()));
        }
        chairFixedPosition.addAll(chairsByPositions);
        chairFixedPosition.addAll(chairs);
        System.debug('chairFixedPosition----->'+chairFixedPosition);
        return chairFixedPosition;
    }
    @AuraEnabled
    public static List<Chair_FixedPosition> saveChair_Apex(Chair__c chair)
    {
        update chair;
        return loadChairList_Apex();
    }
    
    @AuraEnabled(cacheable=true)
    public static Chair_Users  loadChairDetails_Apex(String selectedChairId)
    {
        objAccount=getAccount();
        return new Chair_Users([SELECT Id,Chair_Name__c,User__r.Name,Active__c,Level__c,User__c FROM Chair__c WHERE Id=:selectedChairId],
                               [SELECT Id,Name FROM User WHERE AccountId=:objAccount.Id AND IsActive =true AND Id NOT IN (SELECT User__c FROM Chair__c WHERE Id!=:selectedChairId) ORDER BY Name]);
    }
    public class Chair_Users
    {
        @AuraEnabled
        public Chair__c chair;
        @AuraEnabled
        public List<User> usersList;
        public Chair_Users (Chair__c chair,List<User> usersList)
        {
            this.chair=chair;
            this.usersList=usersList;
        }
    }
    public class Chair_FixedPosition
    {
        @AuraEnabled
        public Chair__c chair;
        @AuraEnabled
        public Fixed_Position__c fixedPosition;
        public Chair_FixedPosition (Chair__c chair,Fixed_Position__c fixedPosition)
        {
            this.chair=chair;
            this.fixedPosition=fixedPosition;
        }
    }
}