//Author : Sanjana; Date : 22-09-2021

@isTest
public class InfiniumAssignDesignation_ApexTest {
    @isTest
    private static void controllerTest()
    {
        Account acct = new Account(Name='Infinium Spirits');
        insert acct ;
        Organiztaion_Chart__c orgChart = new Organiztaion_Chart__c(Account__c=acct.id , Effective_End_Date_of_Org_Chart__c=Date.newInstance(2016, 12, 9),  Effective_Start_Date_of_Org_Chart__c=Date.newInstance(2016, 22, 9), Checkbox__c = true , Organization_Chart_Name__c = 'Org Chart 1');
        insert orgChart;
        Chair__c chair=new Chair__c(Chair_Name__c='testChair', Active__c = true, Level__c = '1' , Account__c=acct.id);
        insert chair;
        Fixed_Position__c fixedPosition=new Fixed_Position__c (Fixed_Position_Name__c='Test',Chair__c=chair.Id,Level__c='1', Organizataion_Chart__c =orgChart.Id);
        insert fixedPosition;
        Test.startTest();
        InfiniumAssignDesignation_Apex.getAccount();
        InfiniumAssignDesignation_Apex.getFixedPositionList();
        InfiniumAssignDesignation_Apex.loadChairs_Apex(fixedPosition.Id);
        InfiniumAssignDesignation_Apex.FixedPositionListWithNames fixedPositions=new InfiniumAssignDesignation_Apex.FixedPositionListWithNames(new List<Fixed_Position__c> ());
        InfiniumAssignDesignation_Apex.saveFixedPosition_Apex(fixedPosition);
        InfiniumAssignDesignation_Apex.removeChair_Apex(fixedPosition);
        Test.stopTest();        
    }
}