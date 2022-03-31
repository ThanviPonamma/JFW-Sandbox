@isTest
public class InfiniumManageShippingMethod_ApexTest {
    
    @isTest
    private static void testController ()
    {
        Account acct = new Account(Name='Infinium Spirits');
        insert acct ;
        Infinium_Spirits_Email_Notifications__c InfiniumSpiritsCustomSetting=new Infinium_Spirits_Email_Notifications__c(Name='InfiniumSpirits',Cc_Addresses_List__c='thanvi@uxltechnologies.net');
        insert InfiniumSpiritsCustomSetting;
        Test.startTest();
        InfiniumManageShippingMethod_Apex.addOrEditShippingMethod(new Shipping_Method__c(Shipping_Method_Name__c='shippingMethodName' , Account__c=acct.Id, Default__c=true));
        InfiniumManageShippingMethod_Apex.addOrEditShippingMethod(new Shipping_Method__c(Shipping_Method_Name__c='shippingMethodName2' , Account__c=acct.Id, Default__c=true));
        InfiniumManageShippingMethod_Apex.deactivateShippingMethod(InfiniumManageShippingMethod_Apex.getShippingMethodList().shippingMethodList[0]);
        //Exception cases
        InfiniumManageShippingMethod_Apex.addOrEditShippingMethod(new Shipping_Method__c(Account__c=acct.Id, Default__c=true));
        InfiniumManageShippingMethod_Apex.deactivateShippingMethod(new Shipping_Method__c(Account__c=acct.Id, Default__c=true));
        Test.stopTest();
    }
    
}