public class CopperOpenBuyBookList_Apex{
    //To hold Copper Cane Account deatails
    public static Account objAccount;
    
    //To fetch data about Copper Cane from Standard object Account.
    @AuraEnabled
    public static Account getAccount() {  
        
        if(Test.isRunningTest())
        {
            objAccount=[SELECT Id,Lightning_Community_URL__c, Name FROM Account
                        WHERE Name LIKE '%Copper Cane%' LIMIT 1];
        }
        else
        {
            objAccount=[SELECT Id, Name,Lightning_Community_URL__c FROM Account
                        WHERE Lightning_Community_Id__c=:Network.getNetworkId() LIMIT 1];
        }
        return objAccount; // objAccount object contains data about Copper Cane.
    }
    @AuraEnabled(cacheable=true)
    public static List<BuyBook_ChairBudget_Details> getBuyBook_ChairBudgetList_Apex() { 
        objAccount=getAccount();
        List<BuyBook_ChairBudget_Details> buyBook_ChairBudgetDetails=new List<BuyBook_ChairBudget_Details> ();
        Map<Id,Id> buyBookIdWithEmergeOrderIds=new Map<Id,Id> ();
        for(ShoppingCart__c shoppingCart : [SELECT Order__c,Program__c FROM ShoppingCart__c WHERE Active__c=true AND Account__c=:objAccount.Id AND CreatedById=:UserInfo.getUserId() AND CartStatus__c='Open'
                                           ])
            buyBookIdWithEmergeOrderIds.put(shoppingCart.Program__c,shoppingCart.Order__c);   
        for(Chair_Budget__c chairBudget : [SELECT Id,Allocated_Budget__c,Available_Budget__c,Consumed_Budget__c,
                                           Shared_Budget__c,Chair__r.Chair_Name__c,Chair__r.Level__c,Chair__r.Active__c,
                                           Chair__r.User__c,Program__r.Name__c,Program__r.Attachment_Id__c,
                                           Program__r.Start_Date__c,Program__r.Closing_Date__c,Program__r.In_Market_Date__c,Available_Chair_Budget__c,Chair_DFV_Department_Budget__c,Utilized_DFV_Department_Budget__c,Available_DFV_Department_Budget__c FROM Chair_Budget__c WHERE Program__r.Account__c=:objAccount.Id AND Chair__r.User__c=:UserInfo.getUserId()
                                           AND (Program__r.Start_Date__c <= :system.now().date()) AND (Program__r.Closing_Date__c  >=:system.now().date()) Order by Program__r.Name__c])
        {
            String attachmentURL = String.isBlank(chairBudget.Program__r.Attachment_Id__c)?'':objAccount.Lightning_Community_URL__c+'/servlet/servlet.FileDownload?file='+chairBudget.Program__r.Attachment_Id__c;
            
            buyBook_ChairBudgetDetails.add(new BuyBook_ChairBudget_Details(buyBookIdWithEmergeOrderIds.containsKey(chairBudget.Program__c)?String.isBlank(buyBookIdWithEmergeOrderIds.get(chairBudget.Program__c))?'':buyBookIdWithEmergeOrderIds.get(chairBudget.Program__c):'',chairBudget,attachmentURL));
        }            
        System.debug('buyBook_ChairBudgetDetails---->'+buyBook_ChairBudgetDetails);
        return buyBook_ChairBudgetDetails;
    }
    
    public class BuyBook_ChairBudget_Details
    {
        @AuraEnabled
        public String emergeOrderId ;
        @AuraEnabled
        public Chair_Budget__c buyBook_chairBudget;
        @AuraEnabled
        public String buyBookImageURL;
        public BuyBook_ChairBudget_Details (String emergeOrderId,Chair_Budget__c buyBook_chairBudget,String buyBookImageURL)
        {
            this.emergeOrderId=emergeOrderId;
            this.buyBook_chairBudget=buyBook_chairBudget;
            this.buyBookImageURL=buyBookImageURL;
        }
    }
}