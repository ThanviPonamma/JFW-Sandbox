@isTest
public class DFVShippingMethodListCmpControllerTest {
     @isTest
    private static void testController ()
    {
        Account acct = new Account(Name='DFV');
        insert acct ;
       DFV_Email_Notifications__c DFVCustomSetting=new DFV_Email_Notifications__c(Name='DFV',Cc_Addresses_List__c='Pradeep@uxltechnologies.net');
        insert DFVCustomSetting;
        Test.startTest();
        DFVShippingMethodListCmpController.addShippingMethod(new Shipping_Method__c(Shipping_Method_Name__c='shippingMethodName' , Account__c=acct.Id, Default__c=true));
        DFVShippingMethodListCmpController.addShippingMethod(new Shipping_Method__c(Shipping_Method_Name__c='shippingMethodName2' , Account__c=acct.Id, Default__c=true));
        DFVShippingMethodListCmpController.deactivateShippingMethodAPEX(DFVShippingMethodListCmpController.getShippingMethodList().shippingMethodList[0]);
        //Exception cases
        DFVShippingMethodListCmpController.addShippingMethod(new Shipping_Method__c(Account__c=acct.Id, Default__c=true));
        DFVShippingMethodListCmpController.deactivateShippingMethodAPEX(new Shipping_Method__c(Account__c=acct.Id, Default__c=true));
        Test.stopTest();
    }

}