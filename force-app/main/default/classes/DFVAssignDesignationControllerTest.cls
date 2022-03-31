@isTest
public class DFVAssignDesignationControllerTest {
@isTest
    private static void controllerTest()
    {
        Account acct = new Account(Name='DFV');
        insert acct ;
        Organiztaion_Chart__c orgChart = new Organiztaion_Chart__c(Account__c=acct.Id,Organization_Chart_Name__c='CopperORG',Checkbox__c=true,Effective_End_Date_of_Org_Chart__c =System.today().addDays(+10) ,Effective_Start_Date_of_Org_Chart__c=System.today().addDays(-10));
        insert orgChart;
        Chair__c chair=new Chair__c(Chair_Name__c='testChair', Active__c = true, Level__c = '1',Account__c=acct.Id);
        insert chair;
        Fixed_Position__c fixedPosition=new Fixed_Position__c (Fixed_Position_Name__c='Test',Chair__c=chair.Id,Level__c='1',Organizataion_Chart__c=orgChart.Id);
        insert fixedPosition;
        Test.startTest();
            DFVAssignDesignationController.getAccount();
            DFVAssignDesignationController.getFixedPositionList();
            DFVAssignDesignationController.loadChairs_Apex(fixedPosition.Id);
            DFVAssignDesignationController.FixedPositionListWithNames fixedPositions=new DFVAssignDesignationController.FixedPositionListWithNames(new List<Fixed_Position__c> ());
            DFVAssignDesignationController.saveFixedPosition_Apex(fixedPosition);
            DFVAssignDesignationController.removeChair_Apex(fixedPosition);
        Test.stopTest();        
    }
}