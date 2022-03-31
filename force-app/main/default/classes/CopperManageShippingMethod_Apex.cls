/**Author:Sanjana
Date: 11-08-2021
* Aim : To load , create , edit and deactivate Shipping methods.*/

public class CopperManageShippingMethod_Apex {
    
    public static Account objAccount;
    
    //Aim:To fetch account details 
    public static Account getAccount() {
        // used by the test class
        if(Test.isRunningTest())
        {
            //fetch Id, name from the account sObject
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
    
    //To fetch all the stored shipping methods
    @AuraEnabled(cacheable=true)
    //to fetch shipping method list
    public static ShippingMethodListWithNames_Wrapper getShippingMethodList() {
        
        //to hold account details
        objAccount=getAccount();
        //variable to hold the instance of the List of custom object Shipping_Method__c
        List<Shipping_Method__c> shippingMethodList = new List<Shipping_Method__c>();
        //declaring a variable of type List of string
        List<String> shippingMethodNamesForValidation=new List<String> ();
        //for all the custom object Shipping_Method__c, fetch the details of the shipping method
        for(Shipping_Method__c shippingMethod : [SELECT Name,Default__c, Shipping_Method_Name__c, Active__c, Account__c, DisplayOrder__c, ApprovalRequired__c
                                                 FROM Shipping_Method__c
                                                 WHERE Account__C =:objAccount.ID
                                                 ORDER BY DisplayOrder__c]) 
        {
            //add shipping method name to the variable shippingMethodNamesForValidation by removing the spaces and converting it to upper case
            shippingMethodNamesForValidation.add(shippingMethod.Shipping_Method_Name__c.remove(' ').trim().toUppercase());
            //add the shipping method details to the variable shippingMethodList
            shippingMethodList.add(shippingMethod);
        }
        System.debug('shippingMethodList--->'+shippingMethodList);
        System.debug('shippingMethodNamesForValidation--->'+shippingMethodNamesForValidation);
        //return the wrapper class ShippingMethodListWithNames_Wrapper which holds the variables shippingMethodList and shippingMethodNamesForValidation
        return new ShippingMethodListWithNames_Wrapper(shippingMethodList,shippingMethodNamesForValidation);   
    }
    
    //Aim: To create or update the existing shipping method.
    @AuraEnabled
    public static String addOrEditShippingMethod(Shipping_Method__c selectedShippingMethod) {
        try{
            //to hold account details
            objAccount=getAccount();
            //Create a new shipping method object and assign the incoming shipping method to it.
            Shipping_Method__c shippingMethod = selectedShippingMethod;
            shippingMethod.Account__c = objAccount.Id;
            //Save the shipping method in the database.
            upsert shippingMethod;
            //check if the defualt shipping method is set to the new/updated shipping method , if yes change the previously selected default shipping method to false.
            if(shippingMethod.Default__c)
            {
                //variable to hold an instance of list of the custom object Shipping_Method__c
                List<Shipping_Method__c> changeDefaultForRemainingSMList=new List<Shipping_Method__c> ();
                //for all shipping method, fetch its Id and default value
                for(Shipping_Method__c shippingMethodEach : [SELECT Id,Default__c FROM Shipping_Method__c WHERE Account__c=:objAccount.Id
                                                             AND Default__c=true AND Id !=:shippingMethod.Id ])
                {
                    //make the default value false
                    shippingMethodEach.Default__c=false;
                    //add shipping method details to the variable changeDefaultForRemainingSMList
                    changeDefaultForRemainingSMList.add(shippingMethodEach);
                }
                //update the shiping method record
                update changeDefaultForRemainingSMList;
            }
            //  return string
            return 'done';
        }
        catch(Exception ex){
            //send an email notification with error description incase of an exception
            CopperEmailNotifications.sendNotification('Inserting a Shipping Method',ex.getMessage()+'\n'+'Inputs are -- selectedShippingMethod-- '+JSON.serialize(selectedShippingMethod)
                                                      +'\n'+'Class Name - CopperManageShippingMethod_Apex '+'-- Line number --'+ex.getLineNumber());
            //return a string                                               
            return 'not done';                                               
        }
        
    }
    //To deactivate the shipping method
    @AuraEnabled
    public static String deactivateShippingMethod(Shipping_Method__c selectedShippingMethod) {
        try{
            //deavtivate the incoming shipping method record
            selectedShippingMethod.Active__c=false;
            //update the record
            update selectedShippingMethod;
            //return a string
            return 'done';
        }
        catch(Exception ex){
            //send an email notification with error description incase of an exception
            CopperEmailNotifications.sendNotification('Deactivating a Shipping Method',ex.getMessage()+'\n'+'Inputs are -- selectedShippingMethod-- '+JSON.serialize(selectedShippingMethod)
                                                      +'\n'+'Class Name - CopperManageShippingMethod_Apex '+'-- Line number --'+ex.getLineNumber());
            //return a string  
            return 'not done';                                               
        }
        
    }
    
    //To hold the shipping method list with the list of validation of all the shipping methods.
    public class ShippingMethodListWithNames_Wrapper
    {
        //variable of type list of custom object Shipping_Method__c to hold the list of shipping method
        @AuraEnabled
        public List<Shipping_Method__c> shippingMethodList ;
        //variable of type List of String to hold shipping method name with all the spaces removed and converted to upper case
        @AuraEnabled
        public List<String> shippingMethodNamesForValidation ;
        public ShippingMethodListWithNames_Wrapper (List<Shipping_Method__c> shippingMethodList,List<String> shippingMethodNamesForValidation)
        {
            this.shippingMethodList=shippingMethodList;
            this.shippingMethodNamesForValidation=shippingMethodNamesForValidation;
        }
    }
}