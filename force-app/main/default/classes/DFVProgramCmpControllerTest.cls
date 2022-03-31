@isTest
private class DFVProgramCmpControllerTest
{
    @isTest
    private static void controllerTest()
    {
        Account acct = new Account(Name='DFV');
        insert acct ;
        DFV_Email_Notifications__c DFVCustomSetting=new DFV_Email_Notifications__c (Name='DFV',Cc_Addresses_List__c='Pradeep@uxltechnologies.net');
        insert DFVCustomSetting;
        Brand__c brand = new Brand__c (Brand_Name__c='BrandNameSelect',Active__c=true,Account__c=acct.Id);
        insert brand;
        
        Item_Type__c itemType= new Item_Type__c(Item_Type__c='itemTypeSelect',Active__c=true,Account__c=acct.Id);
        insert itemType;
        
        POS_Item__c posItem= new POS_Item__c (Item_No__c='Test-No-01',Item_Name__c='testPosItemName',Available_Stock__c=0,Account__c=acct.Id,Brand__c=brand.Id,Type_of_Item__c=itemType.Id);
        insert posItem;
        Organiztaion_Chart__c orgChart = new Organiztaion_Chart__c(Organization_Chart_Name__c='OO1',Checkbox__c=true,Account__c=acct.Id,  Effective_Start_Date_of_Org_Chart__c=System.today(),Effective_End_Date_of_Org_Chart__c=System.today().addDays(2));
        insert orgChart;
        Program_Account__c programAccount=new Program_Account__c (Account_Name__c='Test',Account_Number__c='001');
        insert programAccount;
        Test.startTest();
        List<Program_Account__c> programAccounts=DFVProgramCmpController.getProgramAccountsList_Apex();
        DFVProgramCmpController.saveProgram_Apex(new Program__c(Account__c=acct.Id,Name__c='Test Program',Start_Date__c=System.today(),Closing_Date__c=System.today().addDays(2),In_Market_Date__c=System.today().addDays(4)),
                                                 '','','','CREATE');
        List<Program__c> programs=DFVProgramCmpController.getProgramsList_Apex().programList;
        DFVProgramCmpController.deactivateProgram_Apex(programs[0]);
        DFVProgramCmpController.addPosItemToProgram_Apex(programs[0],posItem);
        DFVProgramCmpController.removePosItemFromProgram_Apex(programs[0],posItem);
        DFVProgramCmpController.saveProgram_Apex(programs[0],'Test','test','test','EDIT');
        DFVProgramCmpController.saveProgram_Apex(new Program__c (),'Test','test','test','CREATE');
        DFVProgramCmpController.deactivateProgram_Apex(new Program__c ());
        DFVProgramCmpController.addPosItemToProgram_Apex(programs[0],null);
        DFVProgramCmpController.removePosItemFromProgram_Apex(programs[0],null);
        Test.stopTest();
    }
}