//Author : VB
//Date: 17/8/21
@isTest
public class CopperAssignDesignation_ApexTest {
    @isTest
    private static void controllerTest()
    {
        Account acct = new Account(Name='Copper Cane');
        insert acct ;
        Organiztaion_Chart__c orgChart=new Organiztaion_Chart__c (Account__c=acct.Id,Checkbox__c=true,Effective_End_Date_of_Org_Chart__c=System.today().addDays(+100),Effective_Start_Date_of_Org_Chart__c=System.today().addDays(-100),Organization_Chart_Name__c='Infinium');
        insert orgChart;  
        Chair__c chair=new Chair__c(Chair_Name__c='testChair', Active__c = true, Level__c = '1' , Account__c=acct.id);
        insert chair;
        Fixed_Position__c fixedPosition=new Fixed_Position__c (Fixed_Position_Name__c='Test',Chair__c=chair.Id,Level__c='1', Organizataion_Chart__c =orgChart.Id);
        insert fixedPosition;
        
        Test.startTest();
        CopperAssignDesignation_Apex.getAccount();
        CopperAssignDesignation_Apex.getFixedPositionList();
        CopperAssignDesignation_Apex.loadChairs_Apex(fixedPosition.Id);
        CopperAssignDesignation_Apex.FixedPositionListWithNames fixedPositions=new CopperAssignDesignation_Apex.FixedPositionListWithNames(new List<Fixed_Position__c> ());
        CopperAssignDesignation_Apex.saveFixedPosition_Apex(fixedPosition);
        CopperAssignDesignation_Apex.removeChair_Apex(fixedPosition);
        Test.stopTest();        
    }
}