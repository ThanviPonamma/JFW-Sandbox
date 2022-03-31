//Author : VB
//Date : 17/8/2021
@isTest
public class CopperManageDesignationList_ApexTest {
    @isTest
    private static void testController (){
        Account acct = new Account(Name='Copper Cane');
        insert acct;
        Contact contact=new Contact(LastName='Testing',AccountId=acct.Id);
        insert contact;
        
        Test.startTest();
        CopperManageDesignationList_Apex.getAccount();
        CopperManageDesignationList_Apex.addOrUpdateDesignation_Apex(new Chair__c(Chair_Name__c='testChair', Active__c = true, Level__c = '1'),'');
        CopperManageDesignationList_Apex.DesingationDetails designations = CopperManageDesignationList_Apex.getDesignationList_Apex('');
        CopperManageDesignationList_Apex.deactivateDesignation_Apex(designations.designationList[0],''); 
        CopperManageDesignationList_Apex.addOrUpdateDesignation_Apex(new Chair__c(Chair_Name__c='testChair1', Active__c = true, Level__c = '1'),'test');
        Test.stopTest();
    }
}