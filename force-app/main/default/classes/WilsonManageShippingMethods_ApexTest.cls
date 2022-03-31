@isTest
public class WilsonManageShippingMethods_ApexTest {
    
    @isTest
    private static void testController ()
    {
        Account acct = new Account(Name='Wilson Daniels');
        insert acct ;
        Wilson_Daniel_Email_Notifications__c WilsonDanielCustomSetting=new Wilson_Daniel_Email_Notifications__c(Name='WILSON',Cc_Addresses_List__c='thanvi@uxltechnologies.net');
        insert WilsonDanielCustomSetting;
        Test.startTest();
        WilsonManageShippingMethods_Apex.addOrEditShippingMethod(new Shipping_Method__c(Shipping_Method_Name__c='shippingMethodName' , Account__c=acct.Id, Default__c=true));
        WilsonManageShippingMethods_Apex.addOrEditShippingMethod(new Shipping_Method__c(Shipping_Method_Name__c='shippingMethodName2' , Account__c=acct.Id, Default__c=true));
        WilsonManageShippingMethods_Apex.deactivateShippingMethod(WilsonManageShippingMethods_Apex.getShippingMethodList().shippingMethodList[0]);
        //Exception cases
        WilsonManageShippingMethods_Apex.addOrEditShippingMethod(new Shipping_Method__c(Account__c=acct.Id, Default__c=true));
        WilsonManageShippingMethods_Apex.deactivateShippingMethod(new Shipping_Method__c(Account__c=acct.Id, Default__c=true));
        Test.stopTest();
    }
    
}