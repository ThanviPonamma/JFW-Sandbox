public class DFVDesigantionListCmpController {
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
    public static DesingationDetails loadDesignation_Apex (String selectedDesignationId)
    {
        objAccount=getAccount();
        Chair__c selectedDesignation=new Chair__c ();
        List<String> designationNamesForValidation = new List<String>();
        Map<Id,Chair__c> designations_Map=new Map<Id,Chair__c> ([SELECT Id, Chair_Name__c, Level__c, Active__c FROM Chair__c WHERE Account__c=:objAccount.Id ORDER BY Chair_Name__c]);
        if(String.isNotBlank(selectedDesignationId))
        {
            selectedDesignation=designations_Map.containsKey(selectedDesignationId) ? designations_Map.get(selectedDesignationId) : new Chair__c();
        }
        
        for(Chair__c designation : designations_Map.values())
            designationNamesForValidation.add(designation.Chair_Name__c.remove(' ').toUpperCase().trim());
        return new DesingationDetails(selectedDesignation,designationNamesForValidation);
    }
     /** Author: NP,TP
     *  Date:05-Aug-2021 
     *  CR No : DFV-08-AUG-30 
     * Aim: The where condition should include Account filter*/
    @AuraEnabled
    public static List<Chair__c> getDesignationList(String searchKey) {
        objAccount=getAccount();
        if(String.isBlank(searchKey))
        	return [SELECT Id, Chair_Name__c, Level__c, Active__c FROM Chair__c WHERE Account__c=:objAccount.Id ORDER BY Chair_Name__c];
        else
        {
            searchKey='%'+searchKey+'%';
            return [SELECT Id, Chair_Name__c, Level__c, Active__c FROM Chair__c WHERE  Account__c=:objAccount.Id AND Chair_Name__c LIKE:searchKey ORDER BY Chair_Name__c];
        }
        	
    }
     /** Author: NP,TP
     *  Date:05-Aug-2021 
     *  CR No : DFV-08-AUG-30 
     * Aim: To assign the Account to designation*/
    @AuraEnabled
    public static List<Chair__c> addDesignation(Chair__c selectedDesignation,String searchKey) {
        objAccount=getAccount();
        selectedDesignation.Account__c=objAccount.Id;
        upsert selectedDesignation;
        return getDesignationList(searchKey);
    }
    
    @AuraEnabled 
    public static List<Chair__c> deactivateDesignationApex(Chair__c selectedDesignation,String searchKey)
    {
        objAccount=getAccount();
        selectedDesignation.Active__c=false;
        update selectedDesignation;
        return getDesignationList(searchKey);
    }
    public class DesingationDetails 
    {
        @AuraEnabled
        public Chair__c selectedDesignation;
        @AuraEnabled
        public List<String> designationNamesForValidation ;
        public DesingationDetails (Chair__c selectedDesignation,List<String> designationNamesForValidation)
        {
            this.selectedDesignation=selectedDesignation;
            this.designationNamesForValidation=designationNamesForValidation;
        }
    }
    
}