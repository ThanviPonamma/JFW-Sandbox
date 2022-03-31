//Author : Sanjana; Date : 22-09-2021


@isTest
public class InfiniumChairUser_ApexTest {
    @isTest
    private static void testController()
    {
        Account acct = new Account(Name='Infinium Spirits');
        insert acct ;
        Program_Account__c programAccount=new Program_Account__c (Account_Name__c='Testing',Account_Number__c='001');
        insert programAccount;
        Program__c program=new Program__c (Name__c='Testing',Account__c=acct.Id,Start_Date__c=System.today().addDays(-10),
                                           Closing_Date__c=System.today().addDays(+10),
                                           In_Market_Date__c=System.today().addDays(+20),
                                           Program_Account__c=programAccount.Id);
        insert program;
        Organiztaion_Chart__c orgChart = new Organiztaion_Chart__c(Account__c=acct.id , Effective_End_Date_of_Org_Chart__c=Date.newInstance(2016, 12, 9),  Effective_Start_Date_of_Org_Chart__c=Date.newInstance(2016, 22, 9), Checkbox__c = true , Organization_Chart_Name__c = 'Org Chart 1');
        insert orgChart;
        Chair__c chair=new Chair__c(Chair_Name__c='testChair', Active__c = true, Level__c = '1', Account__c=acct.id);
        insert chair;
        Fixed_Position__c fixedPosition=new Fixed_Position__c (Fixed_Position_Name__c='Test',Chair__c=chair.Id,Level__c='1',Organizataion_Chart__c=orgChart.id);
        insert fixedPosition;
        Test.startTest();
        InfiniumChairUser_Apex.getAccount();
        InfiniumChairUser_Apex.saveChair_Apex(chair);
        InfiniumChairUser_Apex.loadChairList_Apex();
        InfiniumChairUser_Apex.loadChairDetails_Apex(chair.Id);
        Test.stopTest();  
    }
}