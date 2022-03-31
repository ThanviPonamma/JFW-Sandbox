public class DFVAssignDesignationController {
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
    /** Author: NP,TP
     *  Date:05-Aug-2021 
     *  CR No : DFV-08-AUG-30 
     * Aim: The where condition should include Account filter*/
    @AuraEnabled
    public static List<Fixed_Position__c>  getFixedPositionList() {
        objAccount=getAccount();
        return [SELECT Id, Fixed_Position_Name__c, Level__c,Chair__r.Chair_Name__c FROM Fixed_Position__c 
                WHERE Organizataion_Chart__r.Checkbox__c=true AND Organizataion_Chart__r.Account__c=:objAccount.Id
                ORDER BY Fixed_Position_Name__c
                            ]; 
        
    }
    @AuraEnabled
    public static List<Fixed_Position__c> saveFixedPosition_Apex (Fixed_Position__c fixedPosition)
    {
        update fixedPosition;
        return getFixedPositionList();
    }
     /** Author: NP,TP
     *  Date:05-Aug-2021 
     *  CR No : DFV-08-AUG-30 
     * Aim: The where condition should include Account filter*/
    @AuraEnabled
    public static Chair_FixedPosition loadChairs_Apex (String selectedFixedPositionId)
    {
        objAccount=getAccount();
        List<Chair__c> chairs=new List<Chair__c> ();
        chairs.addAll([SELECT Id,Chair_Name__c FROM Chair__c WHERE Id NOT IN (SELECT Chair__c FROM Fixed_Position__c WHERE Organizataion_Chart__r.Checkbox__c=true AND Organizataion_Chart__r.Account__c=:objAccount.Id )ORDER BY Chair_Name__c]);
        chairs.addAll([SELECT Id,Chair_Name__c FROM Chair__c WHERE Id IN (SELECT Chair__c FROM Fixed_Position__c WHERE Id=:selectedFixedPositionId AND Organizataion_Chart__r.Checkbox__c=true) ORDER BY Chair_Name__c]);
        chairs.sort();
        return new Chair_FixedPosition([SELECT Id,Chair_Name__c,Level__c
                                        FROM Chair__c
                                        WHERE Id IN :chairs AND Account__c=:objAccount.Id
                                        ORDER BY Chair_Name__c],
                                      [SELECT Id,Active__c, Chair__c,Level__c FROM Fixed_Position__c WHERE Id=:selectedFixedPositionId ]);
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
    /** Author: NP,TP
     *  Date:05-Aug-2021 
     *  CR No : DFV-08-AUG-30 
     * Aim: The where condition should include Account filter*/
    @AuraEnabled
    public static List<Fixed_Position__c>  removeChair_Apex(Fixed_Position__c fixedPosition) {
        objAccount=getAccount();
        fixedPosition.Chair__c=null;
        update fixedPosition;
        return [SELECT Id, Fixed_Position_Name__c, Level__c,Chair__c,Chair__r.Chair_Name__c FROM Fixed_Position__c
                WHERE Organizataion_Chart__r.Checkbox__c=true AND Organizataion_Chart__r.Account__c=:objAccount.Id
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