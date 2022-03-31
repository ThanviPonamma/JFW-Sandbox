// Authors: Sanjana, Jaya prasad
// Date: 21-10-2020
// Aim: to fetch the account, to load unselected pos items, save ASN and load all ASN List

public class JFWHanadleASNPOSItemsList_Apex {
    
    //declare a global variable of type sObject Account 
    public static Account objAccount;
    //method to fetch the account details
    public static Account getAccount() { 
        //used by the test classes
        if(Test.isRunningTest())
        {
            objAccount=[SELECT Id, Name FROM Account
                        WHERE Name LIKE '%JFW%' LIMIT 1];
        }
        else
        {
            objAccount=[SELECT Id, Name FROM Account
                        WHERE Lightning_Community_Id__c=:Network.getNetworkId() LIMIT 1];
            // objAccount=[SELECT Id, Name FROM Account
            //               WHERE Name LIKE '%JFW%' LIMIT 1];
        }
        return objAccount;
    }
    
    //wrapper class to hold the selected and unSelected pos items list
    public class PosItemListWrapper{
        //variable of type list of custom object ASN_POS_Item__c that holds the list of selected pos items
        @AuraEnabled
        public List<selectedPosItemListWrapper> selectedPosItems;
        // variable of type list of custom object ASN_POS_Item__c that holds the list of unselected pos items
        @AuraEnabled
        public List<unSelectedPosItemListWrapper> unSelectedPosItems;
        //creating a constructor for the wrapper class
        public PosItemListWrapper( List<selectedPosItemListWrapper> selectedPosItems,List<unSelectedPosItemListWrapper> unSelectedPosItems)
        {
            this.selectedPosItems=selectedPosItems;
            this.unSelectedPosItems=unSelectedPosItems;
        }
    }
    
    public class selectedPosItemListWrapper{
        @AuraEnabled
        public ASN_POS_Item__c posItemList;
        @AuraEnabled
        public Boolean isPosItemSelected;
        public selectedPosItemListWrapper(ASN_POS_Item__c posItemList,Boolean isPosItemSelected){
            this.posItemList = posItemList;
            this.isPosItemSelected = isPosItemSelected;
        }
    }
    public class unSelectedPosItemListWrapper{
        @AuraEnabled
        public POS_Item__c posItemList;
        @AuraEnabled
        public Boolean isPosItemSelected;
        public unSelectedPosItemListWrapper(POS_Item__c posItemList,Boolean isPosItemSelected){
            this.posItemList = posItemList;
            this.isPosItemSelected = isPosItemSelected;
        }
    }
    
    
    
    @AuraEnabled(cacheable=true)
    public static PosItemListWrapper loadPosItemList(String selectedASNId) {
        System.debug('selectedASNId--->'+selectedASNId);
        objAccount=getAccount();
        List<ASN_POS_Item__c> selectedPosItemList;
        List<Pos_Item__c> unSelectedPosItemList;
        List<selectedPosItemListWrapper> selectedItemsListWrapper = new  List<selectedPosItemListWrapper>();
        List<unSelectedPosItemListWrapper> unSelectedItemsListWrapper = new List<unSelectedPosItemListWrapper>();
        //to check if selectedASNId is not blank
        if(String.isNotBlank(selectedASNId))
        {
            //fetch selected pos items
            selectedPosItemList=[SELECT Id,POS_Item__r.Item_Name__c,POS_Item__r.Pack_Of__c,POS_Item__r.Item_No__c,Quantity__c FROM ASN_POS_Item__c WHERE Advance_Shipment_Notice__c=:selectedASNId];
            //to  fetch the unselected pos items for the selectedASNId
            for(ASN_POS_Item__c selectedItems : selectedPosItemList){
                
                selectedItemsListWrapper.add(new selectedPosItemListWrapper(selectedItems,true));
            }
            system.debug('selectedItemsListWrapper------>'+selectedItemsListWrapper);
            
            unSelectedPosItemList =  [SELECT Id,Item_No__c,Pack_Of__c,Item_Name__c FROM POS_Item__c WHERE Id NOT IN (SELECT POS_Item__c FROM ASN_POS_Item__c WHERE Advance_Shipment_Notice__c=:selectedASNId) AND Account__c=:objAccount.Id];
            for(POS_Item__c unSelectedItems : unSelectedPosItemList){
                
                unSelectedItemsListWrapper.add(new unSelectedPosItemListWrapper(unSelectedItems,false));
            }
            system.debug('unSelectedItemsListWrapper------>'+unSelectedItemsListWrapper);
        }
        
        else{
            
            //to  fetch the unselected pos items 
            unSelectedPosItemList =  [SELECT Id,Item_No__c,Item_Name__c,Pack_Of__c FROM POS_Item__c WHERE Account__c=:objAccount.Id];
            for(POS_Item__c unSelectedItems : unSelectedPosItemList){
                
                unSelectedItemsListWrapper.add(new unSelectedPosItemListWrapper(unSelectedItems,false));
            }
            
        }
        system.debug('unSelectedItemsListWrapper------>'+unSelectedItemsListWrapper);
        system.debug('unSelectedItemsListWrapper----->'+unSelectedItemsListWrapper.size());
        //return the selectedPosItemList and  unSelectedPosItemList using the wrapper class PosItemListWrapper
        return new PosItemListWrapper(selectedItemsListWrapper,unSelectedItemsListWrapper);
    }
    
    
    
    
    //to save the advance shipment notice
    @AuraEnabled
    public static String saveAdvanceShipmentNotice(Advance_Shipment_Notice__c advanceShipmentNotice,List<ASN_POS_Item__c> selectedPosItemList,String actionType)
    {
        system.debug('entered--->');
        system.debug('advanceShipmentNotice--->'+advanceShipmentNotice);
        system.debug('selectedPosItemList--->'+selectedPosItemList);
        system.debug('actionType--->'+actionType);
        
        try{
            //get account details
            objAccount=getAccount();
            //System.debug(selectedPosItemList);
            //check if the advanceShipmentNotice id is null
            if(advanceShipmentNotice.Id==null)
                //assign the JFW account id to the account field of ASN
                advanceShipmentNotice.Account__c=objAccount.Id;
            //assign the field Emerge_Status__c of the ASN with the value "Not Submitted"
            advanceShipmentNotice.Emerge_Status__c='Not Submitted';
            //update the record
            upsert advanceShipmentNotice;
            
            // instance of the custom object List of ASN_POS_Item__c
            List<ASN_POS_Item__c> asnPosItemList=new List<ASN_POS_Item__c> ();
            // for all the selected pos items
            for(ASN_POS_Item__c asnPosItem : selectedPosItemList)
            {
                //assign the advanceShipmentNotice id 
                asnPosItem.Advance_Shipment_Notice__c=advanceShipmentNotice.Id;
                //add all the asnPosItem to the variable asnPosItemList
                asnPosItemList.add(asnPosItem);
            }
            //upsert asnPosItemList
            upsert asnPosItemList;
            //delete the pos item whose quantity is 0 or not in the selectedPosItemList
            delete [select Id FROM ASN_POS_Item__c WHERE (Id NOT IN :selectedPosItemList OR (Id IN : selectedPosItemList AND Quantity__c=0)) AND Advance_Shipment_Notice__c=:advanceShipmentNotice.Id];
            
            //if the user clicks on "SAVE_AND_SUBMIT"
            if(actionType=='SAVE_AND_SUBMIT')
            {
                //change the status of the emerge status of the advanceShipmentNotice
                advanceShipmentNotice.Emerge_Status__c='Submitted';
                //update the advanceShipmentNotice record
                update advanceShipmentNotice;
            }
            return 'done';
        }
        
        //incase of an exception, send an email with the description of the error
        catch(Exception ex){
            JFWEmailNotifications.sendNotification('Inserting an ASN ',ex.getMessage()+'\n'+'Inputs are -- selectedPosItemList-- '+JSON.serialize(selectedPosItemList) +'\n'+'Class Name - JFWAdvanceShipmentListCmpController '+'-- Line number --'+ex.getLineNumber());
            return 'not done';
        }
        
    }
    
}