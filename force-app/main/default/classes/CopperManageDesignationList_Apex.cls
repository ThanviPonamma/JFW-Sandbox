/** Author : Thanvi
    Date:11/Aug/2021
    Aim:To load the chair name, add/edit the chair details, serach for chair name
 */
public class CopperManageDesignationList_Apex {
    //To hold Copper Cane Account deatails
    public static Account objAccount;
    //To fetch data about Copper Cane from Standard object Account.
    @AuraEnabled(cacheable=true)
    public static Account getAccount() {  
        
        if(Test.isRunningTest())
        {
            objAccount=[SELECT Id, Name FROM Account
                        WHERE Name LIKE '%Copper Cane%' LIMIT 1];
        }
        else
        {
           objAccount=[SELECT Id, Name,Lightning_Community_URL__c FROM Account
                        WHERE Lightning_Community_Id__c=:Network.getNetworkId() LIMIT 1];
        }
        return objAccount; // objAccount object contains data about Copper Cane.
    }


    

    /**Aim: To load the list of designation for the selected designation list*/
    @AuraEnabled(cacheable=true)
    public static DesingationDetails getDesignationList_Apex (String searchKey)
    {
        //Fetch account details for Copper Cane
        objAccount=getAccount();
        //to hold the designation names for valiation of type List of String
        List<String> designationNamesForValidation = new List<String>();
        //to hold the deisgntion for the account Copper Cane
        List<Chair__c> designationList=new List<Chair__c> ();
        if(String.isBlank(searchKey))
            designationList=[SELECT Id, Chair_Name__c, Level__c, Active__c FROM Chair__c WHERE Account__c=:objAccount.Id ORDER BY Chair_Name__c];
        else
        {
            searchKey='%'+searchKey+'%';
               //return the chair details for the search criteria 
               designationList = [SELECT Id, Chair_Name__c, Level__c, Active__c FROM Chair__c WHERE  Account__c=:objAccount.Id AND Chair_Name__c LIKE:searchKey ORDER BY Chair_Name__c];
        }
        //hold each designation name 
        for(Chair__c designation : [SELECT Id, Chair_Name__c, Level__c, Active__c FROM Chair__c WHERE Account__c=:objAccount.Id ORDER BY Chair_Name__c])
            designationNamesForValidation.add(designation.Chair_Name__c.remove(' ').toUpperCase().trim());
        return new DesingationDetails(designationList,designationNamesForValidation);//return the designation details along with the designation namesfor validation
    }
    
     /** Aim: To assign the Account to designation*/
    @AuraEnabled
    public static DesingationDetails addOrUpdateDesignation_Apex(Chair__c selectedDesignation,String searchKey) {
        try{
             //Fetch account details for Copper Cane
            objAccount=getAccount();
            //add the account details
            selectedDesignation.Account__c=objAccount.Id;
            //create or update the record
            upsert selectedDesignation;
            
        }
        catch(Exception ex){
            //if there is an error while removing the item from the buy book , notify the admin by mail
            CopperEmailNotifications.sendNotification('Add/Edit of the Designation',ex.getMessage()+'\n'+'Inputs are --Selected Chair-- '+JSON.serialize(selectedDesignation)+'\n'+'---searc key---'+JSON.serialize(searchKey)+'\n'+'Class Name - CopperManageDesignationList_Apex '+'-- Line number --'+ex.getLineNumber());
        } 
        return getDesignationList_Apex(searchKey);
    }
    
    @AuraEnabled 
    public static DesingationDetails deactivateDesignation_Apex(Chair__c selectedDesignation,String searchKey)
    {
        try{
            //set the value to false
            selectedDesignation.Active__c=false;
            //update the record
            update selectedDesignation;
        }
        catch(Exception ex){
            //if there is an error while removing the item from the buy book , notify the admin by mail
            CopperEmailNotifications.sendNotification('Deactivation the Designation',ex.getMessage()+'\n'+'Inputs are --Selected Chair-- '+JSON.serialize(selectedDesignation)+'\n'+'---searc key---'+JSON.serialize(searchKey)+'\n'+'Class Name - CopperManageDesignationList_Apex '+'-- Line number --'+ex.getLineNumber());
        } 
        return getDesignationList_Apex(searchKey);
    }
    //Wrapper class to hold the list of chairs and the chair names for validation
    public class DesingationDetails 
    {
        @AuraEnabled
        //to hold the list of chairs
        public List<Chair__c> designationList;
        @AuraEnabled
       // chair names for validation
        public List<String> designationNamesForValidation ;
        public DesingationDetails (List<Chair__c> designationList,List<String> designationNamesForValidation)
        {
            this.designationList=designationList;
            this.designationNamesForValidation=designationNamesForValidation;
        }
    }
    
}