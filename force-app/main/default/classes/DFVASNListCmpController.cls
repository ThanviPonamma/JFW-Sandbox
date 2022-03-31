public class DFVASNListCmpController {
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
    public static List<Advance_Shipment_Notice__c> getAdvanceShipmentList() {
        objAccount=getAccount();
        List<Advance_Shipment_Notice__c> advanceShipmentNoticeList = new List<Advance_Shipment_Notice__c>();
        advanceShipmentNoticeList = [SELECT Id, Name, Account__c,  Emerge_Status__c, Expected_Date__c, Purchase_Order_Number__c, Warehouse_Status__c, 
                                     Carrier__c, Vendor__c, Tracking_Number__c, Package_Count__c, Pallet_Count__c
                                     FROM Advance_Shipment_Notice__c WHERE Account__c=:objAccount.Id ORDER BY Name];
        return advanceShipmentNoticeList;
    }


      @AuraEnabled
    public static List<POS_Item__c> getUnSelected_PosItemsList()
    {   
         objAccount=getAccount();
       Set<Id> totalPOS_Item_ListIds=new Set<Id> ();   
        //if(unSelected_PosItemsList == null)
            List<POS_Item__c> unSelected_PosItemsList =new List<POS_Item__c> ();
            unSelected_PosItemsList = [SELECT Id,Item_No__c,Item_Name__c FROM POS_Item__c 
            WHERE Is_Synchronized__c=true AND Account__c=:objAccount.Id AND Active__c=true  
          //AND  Id NOT IN  (SELECT POS_Item__c FROM ASN_POS_Item__c WHERE Id IN :unSavedASN_PosItemsList )
           ORDER BY Item_Name__c];
            for(POS_Item__c posItem : [SELECT Id FROM POS_Item__c WHERE Is_Synchronized__c=true AND Account__c=:objAccount.Id 
            AND Active__c=true
             //AND Id NOT IN (SELECT POS_Item__c FROM ASN_POS_Item__c WHERE Id IN :unSavedASN_PosItemsList )
             ])
                totalPOS_Item_ListIds.add(posItem.Id);         
       // if(Apexpages.currentPage().getURL().contains('Admin_Advance_Shipment_Notice'))
         //   total_size=totalPOS_Item_ListIds.size(); 
        return unSelected_PosItemsList ;
    } 

    @AuraEnabled
   public static List<ASN_POS_Item__c> getUnSavedASN_PosItemsList()
    {
        //List<ASN_POS_Item__c> unSavedASN_PosItemsList =new List<ASN_POS_Item__c> ();
        List<ASN_POS_Item__c> ASN_PosItemsListWithQuantity =new List<ASN_POS_Item__c> ();
       // if(unSavedASN_PosItemsList ==null)
           List<ASN_POS_Item__c> unSavedASN_PosItemsList =new List<ASN_POS_Item__c> ();        
        unSavedASN_PosItemsList = [SELECT Id,Advance_Shipment_Notice__c,POS_Item__r.Item_No__c,POS_Item__r.Pack_Of__c,Quantity_Received__c,POS_Item__r.Item_Name__c,Quantity__c
         FROM ASN_POS_Item__c WHERE POS_Item__r.Account__c=:objAccount.Id AND Advance_Shipment_Notice__c=null 
         //AND CreatedBy.Id=:userId
         ];
        ASN_PosItemsListWithQuantity =[SELECT Id,POS_Item__r.Pack_Of__c FROM ASN_POS_Item__c WHERE Quantity__c>0 
        //AND Id IN :unSavedASN_PosItemsList
        ];
        return unSavedASN_PosItemsList ;
    }
    @AuraEnabled
    public static List<ASN_POS_Item__c>  getSubmittedASNPosItemsList (String existingId) {
         objAccount=getAccount();
        List<ASN_POS_Item__c> submittedPosItemsList =new List<ASN_POS_Item__c> ();
            submittedPosItemsList =[SELECT Id,Advance_Shipment_Notice__c,POS_Item__r.Item_No__c,Quantity_Received__c,POS_Item__r.Item_Name__c,Quantity__c,POS_Item__r.Pack_Of__c 
                                        FROM ASN_POS_Item__c WHERE POS_Item__r.Account__c=:objAccount.Id AND Advance_Shipment_Notice__c=:existingId];
        return submittedPosItemsList ;
    }
    @AuraEnabled
    public static List<Advance_Shipment_Notice__c> searchASN(String searchKeyword) {
        objAccount=getAccount();
         String query='';
        String completeQuery='';
        List<Advance_Shipment_Notice__c> searchASN_List =new List<Advance_Shipment_Notice__c> ();
        List<Advance_Shipment_Notice__c>ASN_List =new List <Advance_Shipment_Notice__c> ();
        Set<Id> totalASN_ListIds=new Set<Id> ();
        String whereClauseText = '';
        if(String.isBlank(searchKeyword))
            searchKeyword='';
        String tempSearchText='%'+searchKeyword.trim()+'%';
        query= 'SELECT Id,Account__r.Name,ASN_Comet_Response_On__c,ASN_Comet_Response__c,ASN_Submission_Response_On__c,ASN_Submission_Response__c,CreatedBy.Name,'
               +'CreatedDate,Emerge_Status__c,Expected_Date__c,Name,Package_Count__c,Pallet_Count__c,Purchase_Order_Number__c,Tracking_Number__c,Vendor__c,'
               +'Warehouse_ASN_Id__c,Warehouse_Status__c,Carrier__c FROM Advance_Shipment_Notice__c WHERE Account__c=\''+objAccount.Id+'\' ';
        if(!String.isBlank(searchKeyword))
        {
            tempSearchText=tempSearchText.trim();
            whereClauseText = ' AND ((Name LIKE :tempSearchText) OR (Emerge_Status__c  LIKE :tempSearchText)) ';                  
        }
        completeQuery= query+ whereClauseText+'  ORDER BY Name DESC';
        System.debug(completeQuery);
        searchASN_List=Database.query(completeQuery);
        for(Advance_Shipment_Notice__c ASN : searchASN_List)
            totalASN_ListIds.add(ASN.Id);
        ASN_List = [SELECT Id,Account__r.Name,ASN_Comet_Response_On__c,ASN_Comet_Response__c,ASN_Submission_Response_On__c,ASN_Submission_Response__c,CreatedBy.Name,
                    CreatedDate,Emerge_Status__c,Expected_Date__c,Name,Package_Count__c,Pallet_Count__c,Purchase_Order_Number__c,Tracking_Number__c,Vendor__c,
                    Warehouse_ASN_Id__c,Warehouse_Status__c,Carrier__c FROM Advance_Shipment_Notice__c WHERE Id IN :searchASN_List ORDER BY Name DESC]; 
        return ASN_List;
    }
//     @AuraEnabled
//       public static String addPosItemToASN_List (String selectedPosItemId)
//    {      
//        objAccount=getAccount();
//        if(!String.isBlank(selectedPosItemId))
//        {
//             List<ASN_POS_Item__c> newASN_PoSItem=new   List<ASN_POS_Item__c> ();
//            POS_Item__c posItem=[SELECT Id,Item_No__c,Item_Name__c FROM POS_Item__c WHERE Id=:selectedPosItemId];
//            newASN_PoSItem.POS_Item__c=posItem.Id;
//            insert newASN_PoSItem; 
//        }
//        getUnSelected_PosItemsList();
//        getunSavedASN_PosItemsList ();       
//    }

    
  @AuraEnabled
    public static PosItemListWrapper loadPosItemList(String selectedASNId) {
        //System.debug('selectedASNId--->'+selectedASNId);
        objAccount=getAccount();
        List<ASN_POS_Item__c> selectedPosItemList;
        List<Pos_Item__c> unSelectedPosItemList;
        if(String.isNotBlank(selectedASNId))
        {
            selectedPosItemList=[SELECT Id,POS_Item__r.Item_Name__c,POS_Item__r.Pack_Of__c,POS_Item__r.Item_No__c,Quantity__c FROM ASN_POS_Item__c WHERE Advance_Shipment_Notice__c=:selectedASNId];
            unSelectedPosItemList=[SELECT Id,Item_No__c,Pack_Of__c,Item_Name__c FROM POS_Item__c WHERE Id NOT IN (SELECT POS_Item__c FROM ASN_POS_Item__c WHERE Advance_Shipment_Notice__c=:selectedASNId) AND Account__c=:objAccount.Id];
        }
        else
        {
            selectedPosItemList=new List<ASN_POS_Item__c> ();
            //Author: Thanvi Date:12-02-2020
            //Pack of needs to be accessed for display
            unSelectedPosItemList=[SELECT Id,Item_No__c,Item_Name__c,Pack_Of__c FROM POS_Item__c WHERE Account__c=:objAccount.Id];
        }
            return new PosItemListWrapper(selectedPosItemList,unSelectedPosItemList);
    }
    public class PosItemListWrapper{
        @AuraEnabled
        public List<ASN_POS_Item__c> selectedPosItemList;
         @AuraEnabled
        public List<Pos_Item__c> unSelectedPosItemList;
        public PosItemListWrapper(List<ASN_POS_Item__c> selectedPosItemList,List<Pos_Item__c> unSelectedPosItemList)
        {
            this.selectedPosItemList=selectedPosItemList;
            this.unSelectedPosItemList=unSelectedPosItemList;
        }
    }
    @AuraEnabled
    public static List<Advance_Shipment_Notice__c> saveAdvanceShipmentNotice (Advance_Shipment_Notice__c advanceShipmentNotice,List<ASN_POS_Item__c> selectedPosItemList,String actionType)
    {
    try{
      objAccount=getAccount();
        //System.debug(selectedPosItemList);
        if(advanceShipmentNotice.Id==null)
        advanceShipmentNotice.Account__c=objAccount.Id;
        advanceShipmentNotice.Emerge_Status__c='Not Submitted';
        upsert advanceShipmentNotice;
        List<ASN_POS_Item__c> asnPosItemList=new List<ASN_POS_Item__c> ();
        for(ASN_POS_Item__c asnPosItem : selectedPosItemList)
        {
           // System.debug(asnPosItem.Advance_Shipment_Notice__c);
            asnPosItem.Advance_Shipment_Notice__c=advanceShipmentNotice.Id;
            asnPosItemList.add(asnPosItem);
        }
        
        upsert asnPosItemList;
        delete [select Id FROM ASN_POS_Item__c WHERE (Id NOT IN :selectedPosItemList OR (Id IN : selectedPosItemList AND Quantity__c=0)) AND Advance_Shipment_Notice__c=:advanceShipmentNotice.Id];
        if(actionType=='SAVE_AND_SUBMIT')
        {
            advanceShipmentNotice.Emerge_Status__c='Submitted';
            update advanceShipmentNotice;
        }
    }
    catch(Exception ex){
      DFVEmailNotifications.sendNotification('Inserting an ASN ',ex.getMessage()+'\n'+'Inputs are -- selectedPosItemList-- '+JSON.serialize(selectedPosItemList)
                                                    +'\n'+'Class Name - DFVAdvanceShipmentListCmpController '+'-- Line number --'+ex.getLineNumber());
    }
      
        return getAdvanceShipmentList();
    }
    @AuraEnabled
    public static List<POS_Item__c> searchPosItems(String searchKeyWord,List<POS_Item__c> unSelectedTotalPosItemList)
    {
        if(String.isNotBlank(searchKeyWord))
        {
            searchKeyWord='%'+searchKeyWord+'%';
            return [SELECT Id,Item_No__c,Pack_Of__c,Item_Name__c FROM POS_Item__c WHERE Id IN :unSelectedTotalPosItemList AND (Item_Name__c LIKE :searchKeyWord OR Item_No__c LIKE :searchKeyWord)];
        }
        else
            return [SELECT Id,Item_No__c,Pack_Of__c,Item_Name__c FROM POS_Item__c WHERE Id IN :unSelectedTotalPosItemList];
    }
    
}