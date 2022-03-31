@isTest
public class DFVDesigantionListCmpControllerTest {
    @isTest
    private static void testController (){
        Account acct = new Account(Name='DFV');
        insert acct;
        Contact contact=new Contact(LastName='Testing',AccountId=acct.Id);
        insert contact;
        
        Test.startTest();
        DFVDesigantionListCmpController.getAccount();
        List<Chair__c> chairs=DFVDesigantionListCmpController.addDesignation(new Chair__c(Chair_Name__c='testChair', Active__c = true, Level__c = '1',Account__c=acct.Id),'');
        DFVDesigantionListCmpController.deactivateDesignationApex(chairs[0],''); 
        List<Chair__c> chair1=DFVDesigantionListCmpController.addDesignation(new Chair__c(Chair_Name__c='testChair1', Active__c = true, Level__c = '1',Account__c=acct.Id),'test');
        DFVDesigantionListCmpController.loadDesignation_Apex('');
        Test.stopTest();
    }
}