@isTest
public class JFWManageShippingMethods_ApexTest {

    @isTest
    private static void testController ()
    {
        Account acct = new Account(Name='JFW');
        insert acct ;
        JFW_Email_Notifications__c JFWCustomSetting=new JFW_Email_Notifications__c(Name='JFW',Cc_Addresses_List__c='Pradeep@uxltechnologies.net');
        insert JFWCustomSetting;
        Test.startTest();
        JFWManageShippingMethods_Apex.addOrEditShippingMethod(new Shipping_Method__c(Shipping_Method_Name__c='shippingMethodName' , Account__c=acct.Id, Default__c=true));
        JFWManageShippingMethods_Apex.addOrEditShippingMethod(new Shipping_Method__c(Shipping_Method_Name__c='shippingMethodName2' , Account__c=acct.Id, Default__c=true));
        JFWManageShippingMethods_Apex.deactivateShippingMethod(JFWManageShippingMethods_Apex.getShippingMethodList().shippingMethodList[0]);
        //Exception cases
        JFWManageShippingMethods_Apex.addOrEditShippingMethod(new Shipping_Method__c(Account__c=acct.Id, Default__c=true));
        JFWManageShippingMethods_Apex.deactivateShippingMethod(new Shipping_Method__c(Account__c=acct.Id, Default__c=true));
        Test.stopTest();
    }

}