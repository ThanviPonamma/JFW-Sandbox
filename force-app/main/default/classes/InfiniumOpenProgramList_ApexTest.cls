@isTest
public class InfiniumOpenProgramList_ApexTest {
@isTest
    private static void controllerTest()
    {
        Account acct = new Account(Name='Infinium Spirits');
        insert acct ;
        Program__c program = new Program__c(Account__c=acct.Id,Name__c='test',Closing_Date__c= date.newInstance(2023, 12, 15),Start_Date__c=date.newInstance(2014, 12, 15),In_Market_Date__c=date.newInstance(2024, 12, 15),Attachment_Id__c='00P0v0000063gnqEAA');
        insert program;
        
        Chair__c chair=new Chair__c (Account__c=acct.Id,Chair_Name__c='Test',Level__c='1',User__c=UserInfo.getUserId(),Active__c=true);
        insert chair;
        Chair_Budget__c chairBudget=new Chair_Budget__c (Allocated_Budget__c=1000,Shared_Budget__c=200,
                                                         Chair__c=chair.Id,Program__c=program.Id);
        insert chairBudget;
         
        InfiniumOpenProgramList_Apex.getAccount_Apex();    
        InfiniumOpenProgramList_Apex.getProgram_ChairBudgetList_Apex();       
        InfiniumOpenProgramList_Apex.Program_ChairBudget_Details programChairBudgetDetails = new InfiniumOpenProgramList_Apex.Program_ChairBudget_Details(new Chair_Budget__c(Allocated_Budget__c=2000,Chair__c=chair.Id,Program__c=program.Id),'00P0v0000063gnqEAA');
    }
}