@isTest
public class DFVChairUserComponentControllerTest {
    @isTest
    private static void controllerTest()
    {
        Account acct = new Account(Name='DFV');
        insert acct ;
        Organiztaion_Chart__c orgChart = new Organiztaion_Chart__c(Account__c=acct.Id,Organization_Chart_Name__c='CopperORG',Checkbox__c=true,Effective_End_Date_of_Org_Chart__c =System.today().addDays(+10) ,Effective_Start_Date_of_Org_Chart__c=System.today().addDays(-10));
        insert orgChart;

        Program__c program=new Program__c (Name__c='Testing',Account__c=acct.Id,Start_Date__c=System.today().addDays(-10),
                                           Closing_Date__c=System.today().addDays(+10),
                                           In_Market_Date__c=System.today().addDays(+20),Organizataion_Chart_ID__c=orgChart.Id);
        insert program;
        
        Chair__c chair=new Chair__c(Chair_Name__c='testChair', Active__c = true, Level__c = '1',Account__c=acct.Id);
        insert chair;
        Fixed_Position__c fixedPosition=new Fixed_Position__c (Fixed_Position_Name__c='Test',Chair__c=chair.Id,Level__c='1',Organizataion_Chart__c=orgChart.Id);
        insert fixedPosition;
        Test.startTest();
        DFVChairUserComponentController.getAccount();
        DFVChairUserComponentController.saveChair_Apex(chair);
        DFVChairUserComponentController.loadChairList_Apex();
        DFVChairUserComponentController.loadChairDetails_Apex(chair.Id);
        Test.stopTest();  
    }
}