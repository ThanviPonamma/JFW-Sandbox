@isTest
private class CopperBuyBookPlaybook_ApexTest
{
    @isTest
    private static void controllerTest()
    {
        Test.startTest();
        Program__c program=CopperBuyBookPlaybook_Apex.getBuyBookList_Apex()[0];
        CopperBuyBookPlaybook_Apex.getBuyBookItems_Apex(program.Id);
        Copper_Program_PlaybookController controller=new Copper_Program_PlaybookController(new ApexPages.StandardController(program));
        Test.stopTest();
    }
    @testSetUp
    private static void records()
    {
        Account acct = new Account(Name='Copper Cane');
        insert acct ;
        Copper_Cane_Email_Notifications__c CopperCustomSetting=new Copper_Cane_Email_Notifications__c(Name='CopperCane',Cc_Addresses_List__c='thanvi@uxltechnologies.net');
        insert CopperCustomSetting;
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