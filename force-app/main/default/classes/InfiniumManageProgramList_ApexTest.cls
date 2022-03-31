//Author : Sanjana; Date : 22-09-2021


@isTest
private class InfiniumManageProgramList_ApexTest
{
    @isTest
    private static void controllerTest()
    {
        Account acct = new Account(Name='Infinium Spirits');
        insert acct ;
        Infinium_Spirits_Email_Notifications__c InfiniumSpiritsCustomSetting=new Infinium_Spirits_Email_Notifications__c(Name='InfiniumSpirits',Cc_Addresses_List__c='thanvi@uxltechnologies.net');
        insert InfiniumSpiritsCustomSetting;
        Brand__c brand = new Brand__c (Brand_Name__c='BrandNameSelect',Active__c=true,Account__c=acct.Id);
        insert brand;
        
        Item_Type__c itemType= new Item_Type__c(Item_Type__c='itemTypeSelect',Active__c=true,Account__c=acct.Id);
        insert itemType;
        
        POS_Item__c posItem= new POS_Item__c (Item_No__c='Test-No-01',Item_Name__c='testPosItemName',Available_Stock__c=0,Account__c=acct.Id,Brand__c=brand.Id,Type_of_Item__c=itemType.Id);
        insert posItem;
        Organiztaion_Chart__c orgChart = new Organiztaion_Chart__c(Organization_Chart_Name__c='OO1',Checkbox__c=true,Account__c=acct.Id,  Effective_Start_Date_of_Org_Chart__c=System.today(),Effective_End_Date_of_Org_Chart__c=System.today().addDays(2));
        insert orgChart;
        Test.startTest();
        InfiniumManageProgramList_Apex.saveProgram_Apex(new Program__c(Account__c=acct.Id,Name__c='Test Program',Start_Date__c=System.today(),Closing_Date__c=System.today().addDays(2),In_Market_Date__c=System.today().addDays(4)),
                                                 '','','','CREATE');
        
        
        InfiniumManageProgramList_Apex.ProgramListWithNames programList=InfiniumManageProgramList_Apex.getProgramsList_Apex();
        InfiniumManageProgramList_Apex.saveProgram_Apex(programList.programList[0].program,
                                                 '','','','EDIT');
        InfiniumManageProgramList_Apex.createChairBudget_Apex(programList.programList[0].program);
        InfiniumManageProgramList_Apex.addPosItemToProgram_Apex(programList.programList[0].program,posItem);
        InfiniumManageProgramList_Apex.deactivateProgram_Apex(new Program__c ());
        InfiniumManageProgramList_Apex.removePosItemFromProgram_Apex(programList.programList[0].program,null);
        Test.stopTest();
    }
}