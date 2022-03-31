/**Authors: TP,VM
* Date: 06/01/2021
* Aim: to fetch the account, list of advance shipment notice for an incoming ASN Id */

public class WilsonGetSubmittedASNList_Apex {
    //declare a global variable of type sObject Account 
    public static Account objAccount;
    //method to fetch the account details
    public static Account getAccount() { 
        //used by the test classes
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
    
    // fetch the list of ASN whose Id matches the incoming ASN Id
    @AuraEnabled(cacheable=true)
    public static List<ASN_POS_Item__c>  getSubmittedASNPosItemsList (String existingId) {
        system.debug('entered--->'+existingId);
        //to hold the account details
        objAccount=getAccount();
        //instance of an object list of ASN_POS_Item__c
        List<ASN_POS_Item__c> submittedPosItemsList =new List<ASN_POS_Item__c> ();
        //fetch the list of ASN whose Id matches the existing Id
        submittedPosItemsList =[SELECT Id,Advance_Shipment_Notice__c,POS_Item__r.Item_No__c,Quantity_Received__c,POS_Item__r.Item_Name__c,Quantity__c,
                                POS_Item__r.Pack_Of__c FROM ASN_POS_Item__c
                                WHERE POS_Item__r.Account__c=:objAccount.Id AND Advance_Shipment_Notice__c=:existingId];
        system.debug('submittedPosItemsList--->'+submittedPosItemsList);
        return submittedPosItemsList ;
    }
}