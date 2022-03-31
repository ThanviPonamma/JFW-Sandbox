@isTest
public class CopperManageShippingMethod_ApexTest {
    
    @isTest
    private static void testController ()
    {
        Account acct = new Account(Name='Copper Cane');
        insert acct ;
        Copper_Cane_Email_Notifications__c CopperCaneCustomSetting=new Copper_Cane_Email_Notifications__c(Name='CopperCane',Cc_Addresses_List__c='thanvi@uxltechnologies.net');
        insert CopperCaneCustomSetting;
        Test.startTest();
        CopperManageShippingMethod_Apex.addOrEditShippingMethod(new Shipping_Method__c(Shipping_Method_Name__c='shippingMethodName' , Account__c=acct.Id, Default__c=true));
        CopperManageShippingMethod_Apex.addOrEditShippingMethod(new Shipping_Method__c(Shipping_Method_Name__c='shippingMethodName2' , Account__c=acct.Id, Default__c=true));
        CopperManageShippingMethod_Apex.deactivateShippingMethod(CopperManageShippingMethod_Apex.getShippingMethodList().shippingMethodList[0]);
        //Exception cases
        CopperManageShippingMethod_Apex.addOrEditShippingMethod(new Shipping_Method__c(Account__c=acct.Id, Default__c=true));
        CopperManageShippingMethod_Apex.deactivateShippingMethod(new Shipping_Method__c(Account__c=acct.Id, Default__c=true));
        Test.stopTest();
    }
    
}