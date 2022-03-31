/** Author : Thanvi
Date:20/SEP/2021
**/
public class InfiniumOpenProgramList_Apex{
    //To hold Infinium Spirits Account details-
    public static Account objAccount;
    //To fetch data about Infinium Spirits from Standard object Account.
    @AuraEnabled(cacheable=true)
    public static Account getAccount_Apex() {  
        
        if(Test.isRunningTest())
        {
            objAccount=[SELECT Id,Lightning_Community_URL__c, Name FROM Account
                        WHERE Name LIKE '%Infinium Spirits%' LIMIT 1];
        }
        else
        {
           objAccount=[SELECT Id, Name,Lightning_Community_URL__c FROM Account
                        WHERE Lightning_Community_Id__c=:Network.getNetworkId() LIMIT 1];
        }
        return objAccount; // objAccount object contains data about Infinium Spirits.
   }
   // to fetch the program details aling with budget for the logged in user
   @AuraEnabled(cacheable=true)
   public static List<Program_ChairBudget_Details> getProgram_ChairBudgetList_Apex() { 
       objAccount=getAccount_Apex();
       List<Program_ChairBudget_Details> program_ChairBudget_Details=new List<Program_ChairBudget_Details> ();
       
       for(Chair_Budget__c chairBudget : [SELECT Id,Allocated_Budget__c,Available_Budget__c,Consumed_Budget__c,
                                          Shared_Budget__c,Chair__r.Chair_Name__c,Chair__r.Level__c,Chair__r.Active__c,
                                          Chair__r.User__c,Program__r.Name__c,Program__r.Attachment_Id__c,
                                          Program__r.Start_Date__c,Program__r.Closing_Date__c,Program__r.In_Market_Date__c,Available_Chair_Budget__c,Chair_DFV_Department_Budget__c,Utilized_DFV_Department_Budget__c,Available_DFV_Department_Budget__c FROM Chair_Budget__c WHERE Program__r.Account__c=:objAccount.Id AND Chair__r.User__c=:UserInfo.getUserId()
                                          AND (Program__r.Start_Date__c <= :system.now().date()) AND (Program__r.Closing_Date__c  >=:system.now().date()) Order by Program__r.Name__c])
       {

                String attachmentURL = String.isBlank(chairBudget.Program__r.Attachment_Id__c)?'':objAccount.Lightning_Community_URL__c+'/servlet/servlet.FileDownload?file='+chairBudget.Program__r.Attachment_Id__c;

           program_ChairBudget_Details.add(new Program_ChairBudget_Details(chairBudget,attachmentURL));
           
          
       }   
     
       System.debug('program_ChairBudget_Details---->'+program_ChairBudget_Details);
       return program_ChairBudget_Details;
   }
   
   // Wrapper class to hold program and budget details
   public class Program_ChairBudget_Details
   {
       // to hold program along with chair budget detials
       @AuraEnabled
       public Chair_Budget__c program_chairBudget;
       // to program image to be displayed
       @AuraEnabled
       public String programImageURL;
       public Program_ChairBudget_Details (Chair_Budget__c program_chairBudget,String programImageURL)
       {
           this.program_chairBudget=program_chairBudget;
           this.programImageURL=programImageURL;
       }
   }
    

}