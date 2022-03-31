public class DFVShippingMethodListCmpController {
    public static Account objAccount;
    public static Account getAccount() {
        if(Test.isRunningTest())
        {
            objAccount=[SELECT Id, Name FROM Account
                       WHERE Name LIKE '%DFV%' LIMIT 1];
        }
        else
        {
            objAccount=[SELECT Id, Name FROM Account
                       WHERE Lightning_Community_Id__c=:Network.getNetworkId() LIMIT 1];
        }
        return objAccount;
    }
     @AuraEnabled
    public static ShippingMethodListWithNames getShippingMethodList() {
        objAccount=getAccount();
        List<Shipping_Method__c> shippingMethodList = new List<Shipping_Method__c>();
        List<String> shippingMethodNamesForValidation=new List<String> ();
        for(Shipping_Method__c shippingMethod : [SELECT Name,Default__c, Shipping_Method_Name__c, Active__c, Account__c, DisplayOrder__c, ApprovalRequired__c
                              FROM Shipping_Method__c
                              WHERE Account__C =:objAccount.ID
                              ORDER BY DisplayOrder__c]) 
        {
            shippingMethodNamesForValidation.add(shippingMethod.Shipping_Method_Name__c.remove(' ').trim().toUppercase());
            shippingMethodList.add(shippingMethod);
        }
        return new ShippingMethodListWithNames(shippingMethodList,shippingMethodNamesForValidation);   
    }
    @AuraEnabled
    public static ShippingMethodListWithNames addShippingMethod(Shipping_Method__c selectedShippingMethod) {
    try{
     objAccount=getAccount();
        Shipping_Method__c shippingMethod = selectedShippingMethod;
        shippingMethod.Account__c = objAccount.Id;
        upsert shippingMethod;
        if(shippingMethod.Default__c)
        {
            List<Shipping_Method__c> changeDefaultForRemainingSMList=new List<Shipping_Method__c> ();
            for(Shipping_Method__c shippingMethodEach : [SELECT Id,Default__c FROM Shipping_Method__c WHERE Account__c=:objAccount.Id
                                                         AND Default__c=true AND Id !=:shippingMethod.Id ])
            {
                shippingMethodEach.Default__c=false;
                changeDefaultForRemainingSMList.add(shippingMethodEach);
            }
            update changeDefaultForRemainingSMList;
        }
    }
    catch(Exception ex){
     DFVEmailNotifications.sendNotification('Inserting a Shipping Method',ex.getMessage()+'\n'+'Inputs are -- selectedShippingMethod-- '+JSON.serialize(selectedShippingMethod)
                                                    +'\n'+'Class Name - DFVShippingMethodListCmpController '+'-- Line number --'+ex.getLineNumber());
    }
       
        return getShippingMethodList();
    }
    @AuraEnabled
    public static ShippingMethodListWithNames deactivateShippingMethodAPEX(Shipping_Method__c selectedShippingMethod) {
    try{
     selectedShippingMethod.Active__c=false;
        update selectedShippingMethod;
    }
    catch(Exception ex){
     DFVEmailNotifications.sendNotification('Deactivating a Shipping Method',ex.getMessage()+'\n'+'Inputs are -- selectedShippingMethod-- '+JSON.serialize(selectedShippingMethod)
                                                    +'\n'+'Class Name - DFVShippingMethodListCmpController '+'-- Line number --'+ex.getLineNumber());
    }
       
        return getShippingMethodList();
    }
    public class ShippingMethodListWithNames
    {
        @AuraEnabled
        public List<Shipping_Method__c> shippingMethodList ;
        @AuraEnabled
        public List<String> shippingMethodNamesForValidation ;
        public ShippingMethodListWithNames (List<Shipping_Method__c> shippingMethodList,List<String> shippingMethodNamesForValidation)
        {
            this.shippingMethodList=shippingMethodList;
            this.shippingMethodNamesForValidation=shippingMethodNamesForValidation;
        }
    }
}