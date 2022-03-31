/***
    Trigger Name : ASNformSubmissionToWarehouse_Handler
    Version : 001
    Author : Pradeep Kumar
    Description : submtting ASN to Comet and it is invoked by ASNformSubmissionToWarehouse trigger.
***/
public class ASNformSubmissionToWarehouse_Handler
{
    public static String NotSubmitted='Not Submitted';
    public static String Submitted='Submitted';
    public static String FailedToSubmit='Failed to submit to warehouse';
    public static String sentToComet='This ASN has been sent to warehouse';
    
    /**
        Method: submitASN
        Purpose: this method is used to submit ASN to Comet and check for other required parameters which should be sent to Comet.
        Parameters:none 
        Returns: void
    */
    public static void submitASN (Map<Id,Advance_Shipment_Notice__c> oldASN_List,Map<Id,Advance_Shipment_Notice__c> newASN_List)
    {
        Map<Id,Advance_Shipment_Notice__c> ASN_ListwithAccountDestails=new Map<Id,Advance_Shipment_Notice__c> ([SELECT Id,Account__r.Is_Comet_Rest_Api__c,Account__r.Comet_API_Key__c,Account__r.Warehouse_Code__c,(SELECT Id FROM ASN_POS_Items__r WHERE Quantity__c>0 AND Quantity__c!=NULL) FROM Advance_Shipment_Notice__c WHERE Id IN :newASN_List.keySet()]);
        Set<Id> validASN_Ids=new Set<Id> ();
        Set<Id> inValidASN_Ids=new Set<Id> ();
        
        for(Advance_Shipment_Notice__c ASN : newASN_List.values())
        {
            if(oldASN_List.get(ASN.Id).Emerge_Status__c!=Submitted && ASN.Emerge_Status__c==Submitted)
            {
                if( ASN_ListwithAccountDestails.get(ASN.Id).ASN_POS_Items__r.size()>0 && ASN_ListwithAccountDestails.get(ASN.Id).Account__r.Is_Comet_Rest_Api__c!=false && ASN_ListwithAccountDestails.get(ASN.Id).Account__r.Comet_API_Key__c!='' && ASN_ListwithAccountDestails.get(ASN.Id).Account__r.Comet_API_Key__c!=null && ASN_ListwithAccountDestails.get(ASN.Id).Account__r.Warehouse_Code__c!=NULL && ASN_ListwithAccountDestails.get(ASN.Id).Account__r.Warehouse_Code__c!='')
                    validASN_Ids.add(ASN.Id);
                else
                    inValidASN_Ids.add(ASN.Id);
            }
        }
        
        if(!validASN_Ids.isEmpty())
            sendASNtoWarehouse(validASN_Ids);
        if(!inValidASN_Ids.isEmpty()) 
            updateInValidASN_List(inValidASN_Ids);     
    }
    
    /**
        Method: sendASNtoWarehouse
        Purpose: this method is used to submit ASN to Comet and calling a webservice Asynchronously.
        Parameters: validASN_Ids-it is taking valid ASN Ids
        Returns: void
    */
    
    @future(callout=true)
    public static void sendASNtoWarehouse(Set<Id> validASN_Ids)
    {
        Map<Id,Advance_Shipment_Notice__c> validASN_Map=new Map<Id,Advance_Shipment_Notice__c> ([SELECT Id,Account__r.Comet_API_Key__c,(SELECT Id,Quantity__c,POS_Item__r.Item_Name__c,POS_Item__r.Item_No__c FROM ASN_POS_Items__r WHERE Quantity__c>0 AND Quantity__c!=NULL),Account__r.Warehouse_Code__c,Package_Count__c,ASN_Comet_Response__c,ASN_Submission_Response__c,Expected_Date__c,Pallet_Count__c,Purchase_Order_Number__c,Tracking_Number__c,Vendor__c,Warehouse_Status__c,Carrier__c FROM Advance_Shipment_Notice__c WHERE Id IN :validASN_Ids]);
        Map<Id,cometResponse> ASNwithCometResponse=new Map<Id,cometResponse> ();
        
        for(Advance_Shipment_Notice__c ASN:validASN_Map.values())
        {
            HTTP http=new HTTP ();
            HttpRequest request=new HttpRequest ();
            HttpResponse response=new HttpResponse ();
            String Body='';
            Boolean isBodyContainsElements=false;
            String WarehouseCode=(String.isBlank(ASN.Account__r.Warehouse_Code__c)?'':ASN.Account__r.Warehouse_Code__c);
            String ExpectedDate=ASN.Expected_Date__c.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            String Carrier=(String.isBlank(ASN.Carrier__c)?'':ASN.Carrier__c);
            String TrackingNumber=(String.isBlank(ASN.Tracking_Number__c)?'':ASN.Tracking_Number__c);
            String PONumber=(String.isBlank(ASN.Purchase_Order_Number__c)?'':ASN.Purchase_Order_Number__c);
            Integer PackageCount=(ASN.Package_Count__c==null?0:Integer.valueOf(ASN.Package_Count__c));
            Integer PalletCount=(ASN.Pallet_Count__c==null?0:Integer.valueOf(ASN.Pallet_Count__c));
            String Vendor=(String.isBlank(ASN.Vendor__c)?'':ASN.Vendor__c);            
            
            request.setEndPoint('https://api.complemar.com/v1/advance-shipment-notices');
            request.setMethod('POST'); 
            request.setHeader('Authorization','Bearer '+ASN.Account__r.Comet_API_Key__c);
            request.setHeader('Content-Type','application/json');
            request.setTimeOut(120000);
            
            Body='{   "WarehouseCode": "'+WarehouseCode+'",   "ExpectedDate": "'+ExpectedDate+'",   "Carrier": "'+Carrier+'",   "TrackingNumber": "'+TrackingNumber+'",   "PONumber": "'+PONumber+'",   "PackageCount": '+String.valueOf(PackageCount)+',   "PalletCount": '+String.valueOf(PalletCount)+',   "Vendor": "'+Vendor+'",   "Products": [   ';            
            for(ASN_POS_Item__c ASN_POSItem:ASN.ASN_POS_Items__r)
            {
                Integer Quantity=(ASN_POSItem.Quantity__c==null?0:Integer.valueOf(ASN_POSItem.Quantity__c));
                String StockNumber=ASN_POSItem.POS_Item__r.Item_No__c;
                Body+='  {      "StockNumber": "'+StockNumber+'",      "Quantity": '+String.valueOf(Quantity)+'   },';
                isBodyContainsElements=true;
            }
            Body=Body.substringBeforeLast(',');
            Body+='  ] }';
            System.debug('Body-->'+Body);
            
            if(isBodyContainsElements)
            {
               request.setBody(Body);
               response=http.send(request); 
               ASNwithCometResponse.put(ASN.Id,new cometResponse(response.getStatus(),response.getStatusCode(),response.getBody()));
            }           
        }
        for(Id ASNid:ASNwithCometResponse.keySet())
        {            
            if(ASNwithCometResponse.get(ASNid).statusCode==201) 
            {
                 CometTransactionResponse comet=(CometTransactionResponse)System.JSON.deserialize(ASNwithCometResponse.get(ASNid).statusDescription,CometTransactionResponse.class);
                 validASN_Map.get(ASNid).Warehouse_Status__c=sentToComet; 
                 validASN_Map.get(ASNid).Warehouse_ASN_Id__c=comet.Url.substringAfterLast('/');     
            }
            else
            {
                 validASN_Map.get(ASNid).Warehouse_Status__c=FailedToSubmit;
            }
            validASN_Map.get(ASNid).ASN_Submission_Response__c=ASNwithCometResponse.get(ASNid).statusDescription;
            validASN_Map.get(ASNid).ASN_Submission_Response_On__c=System.now(); 
            validASN_Map.get(ASNid).ASN_Comet_Response__c=ASNwithCometResponse.get(ASNid).statusDescription;
            validASN_Map.get(ASNid).ASN_Comet_Response_On__c=System.now();   
        }          
        if(!validASN_Map.isEmpty())
            Database.update(validASN_Map.values(),false);             
    }
    
    /**
        Method: updateInValidASN_List 
        Purpose: this method is used to update ASN status to failed to submit Asynchronously,if ASN doesn't have comet access token or warehouse code or valid ASN POS Items.
        Parameters: inValidASN_Ids-it is taking in valid ASN Ids means if ASN doesn't have comet access token or warehouse code or ASN POS Items,then it takes those ids of ASN.
        Returns: void
    */
    
    @future
    public static void updateInValidASN_List (Set<Id> inValidASN_Ids)
    {
        Map<Id,Advance_Shipment_Notice__c> inValidASN_Map=new Map<Id,Advance_Shipment_Notice__c> ([SELECT Id,Account__r.Is_Comet_Rest_Api__c,Account__r.Comet_API_Key__c,Account__r.Warehouse_Code__c,(SELECT Id FROM ASN_POS_Items__r WHERE Quantity__c>0 AND Quantity__c!=NULL) FROM Advance_Shipment_Notice__c WHERE Id IN :inValidASN_Ids]);
        for(Advance_Shipment_Notice__c ASN : inValidASN_Map.values())
        {
            String requiredElementsToSubmit='';   
            if(ASN.ASN_POS_Items__r.size()==0 ) 
                requiredElementsToSubmit='Items don\'t exist. \n' ;
            if(ASN.Account__r.Is_Comet_Rest_Api__c==false)
                requiredElementsToSubmit+='Is Comet API flag must be setup in Account. \n'; 
            if(ASN.Account__r.Comet_API_Key__c==null || ASN.Account__r.Comet_API_Key__c=='') 
                requiredElementsToSubmit+='Comet API Key can not be empty or null in Account.\n' ;
            if(String.isBlank(ASN.Account__r.Warehouse_Code__c))
                requiredElementsToSubmit+='Warehouse Code can not be blank.\n';       
            ASN.ASN_Submission_Response_On__c=System.now();
            ASN.ASN_Submission_Response__c=requiredElementsToSubmit;
            ASN.Warehouse_Status__c=FailedToSubmit;
        }
        if(!inValidASN_Map.isEmpty())
            Database.update(inValidASN_Map.values(),false);
    }
    
    /**
        class : CometTransactionResponse
        Purpose: this is used by sendASNtoWarehouse and this is used for deserializing comet response.
        Parameters: none
        Returns: none
    */
    
    public class CometTransactionResponse
    {
        public String Rel;
        public String Name;
        public String Url;
    }
    
    /**
        class : cometResponse
        Purpose: this is used by sendASNtoWarehouse and this is used for mapping ASN Id with Comet Response.
        Parameters: none
        Returns: none
    */
    
    public class cometResponse
    {
        public String status;
        public Integer statusCode;
        public String statusDescription;
        public cometResponse(String status,Integer statusCode,String statusDescription){
            this.status=status;
            this.statusCode=statusCode;
            this.statusDescription=statusDescription;
        }
    }
}