//Author : VB
//DAte: 23/8/21

@isTest
public class CopperChairUser_ApexTest {
    @isTest
    private static void testController()
    {
        Account acct = new Account(Name='Copper Cane');
        insert acct ;
        Program_Account__c programAccount=new Program_Account__c (Account_Name__c='Testing',Account_Number__c='001');
        insert programAccount;
        Program__c program=new Program__c (Name__c='Testing',Account__c=acct.Id,Start_Date__c=System.today().addDays(-10),
                                           Closing_Date__c=System.today().addDays(+10),
                                           In_Market_Date__c=System.today().addDays(+20),
                                           Program_Account__c=programAccount.Id);
        insert program;
        Organiztaion_Chart__c orgChart=new Organiztaion_Chart__c (Account__c=acct.Id,Checkbox__c=true,Effective_End_Date_of_Org_Chart__c=System.today().addDays(+100),Effective_Start_Date_of_Org_Chart__c=System.today().addDays(-100),Organization_Chart_Name__c='Infinium');
        insert orgChart;  
        Chair__c chair=new Chair__c(Chair_Name__c='testChair', Active__c = true, Level__c = '1', Account__c=acct.id);
        insert chair;
        Fixed_Position__c fixedPosition=new Fixed_Position__c (Fixed_Position_Name__c='Test',Chair__c=chair.Id,Level__c='1',Organizataion_Chart__c=orgChart.Id);
        insert fixedPosition;
        
        Test.startTest();
        CopperChairUser_Apex.getAccount();
        CopperChairUser_Apex.saveChair_Apex(chair);
        CopperChairUser_Apex.loadChairList_Apex();
        CopperChairUser_Apex.loadChairDetails_Apex(chair.Id);
        Test.stopTest();  
    }
}