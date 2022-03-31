/**Authors: Thanvi Date: 16-08-2021
Aim : Class used to fetch the program list for playbook component*/

public class InfiniumProgramPlaybook_Apex {
    
    //Global variable which holds the account
    public static Account objAccount;
    @AuraEnabled
    // to fetch the account information and store the details in objAccount variable.
    public static Account getAccount() {
        if(Test.isRunningTest())
        {
            //fetch Id, name from the account sObject
            objAccount=[SELECT Id, Name,Lightning_Community_URL__c FROM Account
                        WHERE Name LIKE '%Infinium Spirits%' LIMIT 1];
        }
        else
        {
            objAccount=[SELECT Id, Name,Lightning_Community_URL__c FROM Account
                        WHERE Lightning_Community_Id__c=:Network.getNetworkId() LIMIT 1];
        }
        return objAccount;
    }
    
    // To fetch detauils from the object program
    @AuraEnabled(cacheable=true)
    public static List<Program__c> getProgramList_Apex()
    {
        //to hold account details
        objAccount=getAccount();
        return [select ID, Name__c from Program__c WHERE Account__c=:objAccount.Id Order by Name__c ];
    }
    
    // To fetch pos item details for the selected program
    @AuraEnabled
    public static List<ProgramListWithImageURL> getProgramItems_Apex(String programId)
    {
        //to hold account details
        objAccount=getAccount();
        List<ProgramListWithImageURL> programItemDetails=new List<ProgramListWithImageURL> ();
        List<POS_Item__c> posItemList=  [SELECT Name,Item_No__c, Item_Name__c,Attachment_Id__c, Image_of_Item__c,Brand__c,Item_Descrption__c, Brand__r.Brand_Name__c, Pack_Of__c, Price__c, Maximum_Order_Qty__c, Type_of_Item__c, Type_of_Item__r.Item_Type__c, Active__c, Dimension__c FROM POS_Item__c item
                                         WHERE item.Id IN (SELECT prgitem.POS_Item__c From Program_Item__c prgitem WHERE prgitem.Program__c = :programId )
                                         ORDER BY Item_Name__c];
        for(POS_Item__c posItem: posItemList){
            String attachmentURL = String.isBlank(posItem.Attachment_Id__c)?'':objAccount.Lightning_Community_URL__c+'/servlet/servlet.FileDownload?file='+posItem.Attachment_Id__c;
            programItemDetails.add(new ProgramListWithImageURL(posItem,attachmentURL));
        }
        return programItemDetails;
    }
    //Wrapper class to hold programitems along with its image
    public class ProgramListWithImageURL
    {
        // to hold the program item
        @AuraEnabled
        public POS_Item__c programItem ;
        //to hold the program image URL
        @AuraEnabled
        public String programImageURL;
        public ProgramListWithImageURL (POS_Item__c programItem, String programImageURL)
        {
            this.programItem=programItem;
            this.programImageURL = programImageURL;
        }
    }
}