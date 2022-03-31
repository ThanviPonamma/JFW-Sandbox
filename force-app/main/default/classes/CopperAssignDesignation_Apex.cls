// Author: Sanjana
//Date: 12-08-2021
//To fetch all the fixed positions, to assign designation to the fixed position and to remove the assigned designation to the fixed positions


public class CopperAssignDesignation_Apex {
    public static Account objAccount;
    
    public static Account getAccount() {  
        
        if(Test.isRunningTest())
        {
            objAccount=[SELECT Id, Name FROM Account
                       WHERE Name LIKE '%Copper Cane%' LIMIT 1];
        }
        else
        {
            objAccount=[SELECT Id, Name FROM Account
                        WHERE Lightning_Community_Id__c=:Network.getNetworkId() LIMIT 1];
        }
        return objAccount; 
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Fixed_Position__c>  getFixedPositionList() {
        objAccount=getAccount();
        List<Fixed_Position__c> fixedPositions =  [SELECT Id, Fixed_Position_Name__c, Level__c,Chair__r.Chair_Name__c FROM Fixed_Position__c 
                WHERE Organizataion_Chart__r.Checkbox__c=true AND Organizataion_Chart__r.Account__c=:objAccount.Id
                ORDER BY Fixed_Position_Name__c
                            ]; 

           System.debug('fixedPositions----->'+fixedPositions);
       return fixedPositions;
        
    }
    @AuraEnabled
    public static List<Fixed_Position__c> saveFixedPosition_Apex (Fixed_Position__c fixedPosition)
    {
        update fixedPosition;
        return getFixedPositionList();
    }
    @AuraEnabled(cacheable=true)
    public static Chair_FixedPosition loadChairs_Apex (String selectedFixedPositionId)
    {
        objAccount=getAccount();

        System.debug('selectedFixedPositionId---->'+selectedFixedPositionId);

        List<Chair__c> chairs=new List<Chair__c> ();
        chairs.addAll([SELECT Id,Chair_Name__c FROM Chair__c WHERE Account__c=:objAccount.Id AND Id NOT IN (SELECT Chair__c FROM Fixed_Position__c WHERE Organizataion_Chart__r.Checkbox__c=true AND Organizataion_Chart__r.Account__c=:objAccount.Id)ORDER BY Chair_Name__c]);
        chairs.addAll([SELECT Id,Chair_Name__c FROM Chair__c WHERE Account__c=:objAccount.Id AND Id NOT IN (SELECT Chair__c FROM Fixed_Position__c WHERE Organizataion_Chart__r.Checkbox__c=true AND Organizataion_Chart__r.Account__c=:objAccount.Id)ORDER BY Chair_Name__c]);
        chairs.sort();
        System.debug('chairs---->'+chairs);

        List<Chair__c> chairsToBeSent = [SELECT Id,Chair_Name__c,Level__c
        FROM Chair__c
        WHERE Id IN :chairs AND Account__c=:objAccount.Id
        ORDER BY Chair_Name__c];  

        System.debug('chairsToBeSent---->'+chairsToBeSent);


        Fixed_Position__c fixedPositionToBeSent = [SELECT Id,Active__c, Chair__c,Level__c FROM Fixed_Position__c where Id=:selectedFixedPositionId];

        System.debug('fixedPositionToBeSent---->'+fixedPositionToBeSent);


        return new Chair_FixedPosition(chairsToBeSent,fixedPositionToBeSent);
                        

                                    //   System.debug('chairFixedPosition---->'+chairFixedPosition);
                                    //   return chairFixedPosition;
    }
    
    public class Chair_FixedPosition
    {
        @AuraEnabled
        public List<Chair__c> chairs;
        @AuraEnabled
        public Fixed_Position__c fixedPosition;
        public Chair_FixedPosition (List<Chair__c> chairs,Fixed_Position__c fixedPosition)
        {
            this.chairs=chairs;
            this.fixedPosition=fixedPosition;
        }
    }
    @AuraEnabled
    public static List<Fixed_Position__c>  removeChair_Apex(Fixed_Position__c fixedPosition) {
        objAccount=getAccount();
        fixedPosition.Chair__c=null;
        update fixedPosition;
        return [SELECT Id, Fixed_Position_Name__c, Level__c,Chair__c,Chair__r.Chair_Name__c FROM Fixed_Position__c
                WHERE Organizataion_Chart__r.Checkbox__c=true
                ORDER BY Fixed_Position_Name__c
                            ]; 
        
    }
    public class FixedPositionListWithNames
    {
        @AuraEnabled
        public List<Fixed_Position__c> fixedPositionList ;
        public FixedPositionListWithNames (List<Fixed_Position__c> fixedPositionList)
         {
             this.fixedPositionList=fixedPositionList;
         }
    }
}