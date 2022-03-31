//Author : Sanjana; Date : 22-09-2021

@isTest
public class InfiniumManageDesignationList_ApexTest {
    @isTest
    private static void testController (){
        Account acct = new Account(Name='Infinium Spirits');
        insert acct;
        Contact contact=new Contact(LastName='Testing',AccountId=acct.Id);
        insert contact;
        
        Test.startTest();
        InfiniumManageDesignationList_Apex.getAccount();
        InfiniumManageDesignationList_Apex.addOrUpdateDesignation_Apex(new Chair__c(Chair_Name__c='testChair', Active__c = true, Level__c = '1'),'');
        InfiniumManageDesignationList_Apex.DesingationDetails designations = InfiniumManageDesignationList_Apex.getDesignationList_Apex('');
        InfiniumManageDesignationList_Apex.deactivateDesignation_Apex(designations.designationList[0],''); 
        InfiniumManageDesignationList_Apex.addOrUpdateDesignation_Apex(new Chair__c(Chair_Name__c='testChair1', Active__c = true, Level__c = '1'),'test');
        
        Test.stopTest();
    }
}