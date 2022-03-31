@isTest
public class ProgramsControllerTest {
    @isTest
    private static void orderSummaryController ()
    {
        Account acc = new Account(Name ='DFV');
        insert acc;
        Program__c program = new Program__c(Account__c=acc.Id,Name__c='Summar Program',Start_Date__c=System.today(),Closing_Date__c=System.today().addDays(2),In_Market_Date__c=System.today().addDays(3));
        insert program;
        Test.startTest();
        ProgramsController.GetAllPrograms();
        
        Test.stopTest();
    }
}