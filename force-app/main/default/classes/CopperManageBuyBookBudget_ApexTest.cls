@isTest
public class CopperManageBuyBookBudget_ApexTest {
    @isTest
    private static void controllerTest()
    {
        Account acct = new Account(Name='Copper Cane');
        insert acct ;
        Organiztaion_Chart__c orgChart = new Organiztaion_Chart__c(Account__c=acct.Id,Organization_Chart_Name__c='CopperORg',Checkbox__c=true,Effective_End_Date_of_Org_Chart__c =System.today().addDays(+10) ,Effective_Start_Date_of_Org_Chart__c=System.today().addDays(-10));
        insert orgChart;
        Program__c BuyBook=new Program__c (Name__c='Testing',Account__c=acct.Id,Start_Date__c=System.today().addDays(-10),
                                           Closing_Date__c=System.today().addDays(+10),Program_Budget__c=10000000,
                                           In_Market_Date__c=System.today().addDays(+20),Organizataion_Chart_ID__c=orgChart.Id);
        insert BuyBook;
        
        Chair__c chair=new Chair__c(Chair_Name__c='testChair', Active__c = true, Level__c = '1',Account__c=acct.Id);
        insert chair;
        
        Chair__c CH1=new Chair__c(Chair_Name__c='testChair1', Active__c = true, Level__c = '2',Account__c=acct.Id);
        insert CH1;
        
        Chair__c CH2=new Chair__c(Chair_Name__c='testChair2', Active__c = true, Level__c = '3',Account__c=acct.Id);
        insert CH2;
        
        Fixed_Position__c fixedPosition=new Fixed_Position__c (Fixed_Position_Name__c='FP-1',Chair__c=chair.Id,Level__c='1',Organizataion_Chart__c=orgChart.Id);
        insert fixedPosition;
        
        Fixed_Position__c fixedPosition1=new Fixed_Position__c (Fixed_Position_Name__c='FP-1.1',Chair__c=CH1.Id,Level__c='2',Organizataion_Chart__c=orgChart.Id);
        insert fixedPosition1;
        
        Fixed_Position__c fixedPosition2=new Fixed_Position__c (Fixed_Position_Name__c='FP-1.1.1',Chair__c=CH2.Id,Level__c='3',Organizataion_Chart__c=orgChart.Id);
        insert fixedPosition2;
        
        Chair_Budget__c chairBudget=new Chair_Budget__c (Allocated_Budget__c=1000000,Shared_Budget__c=50000,Chair__c=chair.Id,Program__c=BuyBook.Id);
        insert chairBudget;
        
        Chair_Budget__c CB1=new Chair_Budget__c (Allocated_Budget__c=50000,Shared_Budget__c=25000,Chair__c=CH1.Id,Program__c=BuyBook.Id);
        insert CB1;
        Chair_Budget__c CB2=new Chair_Budget__c (Allocated_Budget__c=25000,Shared_Budget__c=0,
                                                 Chair__c=CH2.Id,Program__c=BuyBook.Id);
        insert CB2;
        
        Test.startTest();
        CopperManageBuyBookBudget_Apex.getAccount();
        CopperManageBuyBookBudget_Apex.loadBuyBookList_Apex();
        CopperManageBuyBookBudget_Apex.loadChairBudgetList_Apex(BuyBook.Id);
        CopperManageBuyBookBudget_Apex.checkAndValidateAllocatedChairBudget_Apex(BuyBook.Id,chairBudget.Id,1000);
        CopperManageBuyBookBudget_Apex.checkAndValidateAllocatedChairBudget_Apex(BuyBook.Id,chairBudget.Id,100);
        CopperManageBuyBookBudget_Apex.checkAndValidateAllocatedChairBudget_Apex(BuyBook.Id,CB1.Id,1000);
        CopperManageBuyBookBudget_Apex.checkAndValidateAllocatedChairBudget_Apex(BuyBook.Id,CB1.Id,100000);
        CopperManageBuyBookBudget_Apex.checkAndValidateAllocatedChairBudget_Apex(BuyBook.Id,CB2.Id,100);
        CopperManageBuyBookBudget_Apex.checkAndValidateAllocatedChairBudget_Apex(BuyBook.Id,CB2.Id,10);

        //Exception 
        CopperManageBuyBookBudget_Apex.checkAndValidateAllocatedChairBudget_Apex(BuyBook.Id,chairBudget.Id,-10);
        Test.stopTest();  
    }
}