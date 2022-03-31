public class DFVProgramPlaybookCmpController {
    //Global variable which holds the account
    public static Account objAccount;
    //To fetch data about DFV from Standard object Account.
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
        return objAccount; // objAccount object contains data about Mionetto.
    }
	@AuraEnabled
    public static List<Program__c> getProgramsList_Apex()
    {
        //To hold the account details
        objAccount=getAccount();
        return [SELECT ID, Name__c from Program__c WHERE Account__c =:objAccount.Id  Order by Name__c ];
    }
    @AuraEnabled
    public static List<POS_Item__c> getProgramItems_Apex(String programId)
    {
        return  [SELECT Name,Item_No__c, Item_Name__c,Attachment_Id__c, Image_of_Item__c,Brand__c,Item_Descrption__c, Brand__r.Brand_Name__c, Pack_Of__c, Price__c, Maximum_Order_Qty__c, Type_of_Item__c, Type_of_Item__r.Item_Type__c, Active__c, Dimension__c FROM POS_Item__c item
                WHERE item.Id IN (
                    SELECT prgitem.POS_Item__c From Program_Item__c prgitem WHERE prgitem.Program__c = :programId             
                )
                ORDER BY Item_Name__c 
            ];
    }
}