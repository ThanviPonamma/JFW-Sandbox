@isTest
private class DFVProgramPlaybookCmpControllerTest
{
    @isTest
    private static void controllerTest()
    {
        Test.startTest();
            Program__c program=DFVProgramPlaybookCmpController.getProgramsList_Apex()[0];
            DFVProgramPlaybookCmpController.getProgramItems_Apex(program.Id);
            Admin_Program_PlaybookController controller=new Admin_Program_PlaybookController(new ApexPages.StandardController(program));
        Test.stopTest();
    }
    @testSetUp
    private static void records()
    {
        Account acct = new Account(Name='DFV');
        insert acct ;
           DFV_Email_Notifications__c DFVCustomSetting=new DFV_Email_Notifications__c(Name='DFV',Cc_Addresses_List__c='Pradeep@uxltechnologies.net');
        insert DFVCustomSetting;
        Brand__c brand = new Brand__c (Brand_Name__c='BrandNameSelect',Active__c=true,Account__c=acct.Id);
        insert brand;
        
        Item_Type__c itemType= new Item_Type__c(Item_Type__c='itemTypeSelect',Active__c=true,Account__c=acct.Id);
        insert itemType;
        
        POS_Item__c posItem= new POS_Item__c (Item_No__c='Test-No-01',Item_Name__c='testPosItemName',Available_Stock__c=0,Account__c=acct.Id,Brand__c=brand.Id,Type_of_Item__c=itemType.Id);
        insert posItem;
        Program__c program=new Program__c(Account__c=acct.Id,Name__c='Test Program',Start_Date__c=System.today(),Closing_Date__c=System.today().addDays(2),In_Market_Date__c=System.today().addDays(4));
        insert program;
        insert new Program_Item__c(POS_Item__c=posItem.Id,Program__c=program.Id);
        
    }
}