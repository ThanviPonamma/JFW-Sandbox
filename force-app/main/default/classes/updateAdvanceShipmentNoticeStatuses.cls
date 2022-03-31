/***
Class Name : updateAdvanceShipmentNoticeStatuses 
Version : 001
Author : Pradeep Kumar
Description : getting Statuses of ASN using REST API webservice.
***/
global class updateAdvanceShipmentNoticeStatuses implements Database.AllowsCallouts,Database.Batchable<Sobject>
{
    global String ASN_Query ;
    
    /**
Method: updateAdvanceShipmentNoticeStatuses 
Purpose: this constructor is giving dynamic query.
Parameters: ASN_Query is dynamic query.
Returns: none
*/
    global updateAdvanceShipmentNoticeStatuses (String ASN_Query)
    {
        this.ASN_Query = ASN_Query ;
        /***
Query must be-->
SELECT Id,Emerge_Status__c,Account__r.Comet_API_Key__c,Warehouse_Status__c,Warehouse_ASN_Id__c,Account__r.Warehouse_Code__c FROM Advance_Shipment_Notice__c WHERE Account__r.Warehouse_Code__c!=NULL AND Account__r.Warehouse_Code__c!=\'\' AND Emerge_Status__c=\'Submitted\' AND Warehouse_Status__c!=\'Cancelled\'  AND Warehouse_Status__c!=\'Delivered \'  AND Warehouse_Status__c!=\'Open\'  AND  Warehouse_Status__c!=\'Failed to submit to warehouse\' AND   Warehouse_ASN_Id__c!=\'\'';
***/
    }
    
    /**
Method: start 
Purpose: this method must be used for getting all records whichever want to be proceeded.
Parameters: bc is an interface.this is default and this must be used for giving the records to next method.
Returns: Database.QueryLocator
*/
    
    global Database.QueryLocator start (Database.BatchableContext bc)
    {
        return Database.getQueryLocator(ASN_Query);
    }
    
    /**
Method: execute 
Purpose: this method must be used for executing all the records and this is default and main method and this is getting all statuses of ASN
Parameters: bc is an interface.this is default and this must be used for giving the records to next batch and ASN_List is taking all records from Start method.
Returns: none
*/
    
    global void execute (Database.BatchableContext bc,List<Advance_Shipment_Notice__c> ASN_List)
    {
        Map<Id,Advance_Shipment_Notice__c> ASN_Map=new Map<Id,Advance_Shipment_Notice__c> (ASN_List);
        List<ASN_POS_Item__c> ASN_POS_ItemsList=new List<ASN_POS_Item__c> ([SELECT Id,Advance_Shipment_Notice__c,POS_Item__r.Item_Name__c,POS_Item__r.Item_No__c FROM ASN_POS_Item__c WHERE Advance_Shipment_Notice__c IN : ASN_Map.keySet()]);
        Map<Id,List<AdvanceShipmentItem>> ASNwithProducts=new Map<Id,List<AdvanceShipmentItem>> ();
        Map<Id,CometResponse> ASN_CometResponse=new Map<Id,CometResponse> ();
        
        for(Advance_Shipment_Notice__c ASN : ASN_List)
        {
            HTTP http=new HTTP ();
            HttpRequest request=new HttpRequest ();
            HttpResponse response=new HttpResponse ();
            
            request.setEndPoint('https://api.complemar.com/v1/advance-shipment-notices/'+ASN.Account__r.Warehouse_Code__c+'/'+ASN.Warehouse_ASN_Id__c);
            request.setMethod('GET'); 
            request.setHeader('Authorization','Bearer '+ASN.Account__r.Comet_API_Key__c);
            request.setHeader('Content-Type','application/json');
            request.setTimeOut(120000); 
            
            response=http.send(request);
            ASN_CometResponse.put(ASN.Id,new CometResponse(response.getStatus(),response.getStatusCode(),response.getBody()));
        }
        
        for(Id ASN_Id : ASN_Map.keySet() )
        {
            if(ASN_CometResponse.containsKey(ASN_Id))
            {
                if(ASN_CometResponse.get(ASN_Id).statusCode==200)
                {
                    JsonResponse ASN_Response=(JsonResponse)System.JSON.deSerialize(ASN_CometResponse.get(ASN_Id).statusDescription,JsonResponse.class);       
                    ASN_Map.get(ASN_Id).Warehouse_Status__c=ASN_Response.Status;
                    if(ASN_Response.Products!=null)  
                        ASNwithProducts.put(ASN_Id,ASN_Response.Products); 
                    ASN_Map.get(ASN_Id).ASN_Comet_Response__c=ASN_CometResponse.get(ASN_Id).statusDescription;   
                }
                else
                    ASN_Map.get(ASN_Id).ASN_Comet_Response__c=ASN_CometResponse.get(ASN_Id).statusDescription;    
            }
            else
                ASN_Map.get(ASN_Id).ASN_Comet_Response__c='Request failed to get status from Comet';
            ASN_Map.get(ASN_Id).ASN_Comet_Response_On__c=System.now();
        }
        
        for(ASN_POS_Item__c ASN_POS_Item :ASN_POS_ItemsList)
        {
            if(ASNwithProducts.containsKey(ASN_POS_Item.Advance_Shipment_Notice__c))
            {
                for(AdvanceShipmentItem AS_Item :ASNwithProducts.get(ASN_POS_Item.Advance_Shipment_Notice__c))
                {
                    if(ASN_POS_Item.POS_Item__r.Item_No__c.trim().toUpperCase()==AS_Item.Link.Name.trim().toUpperCase())
                        ASN_POS_Item.Quantity_Received__c=AS_Item.QuantityReceived ;
                }
            }    
        }
        
        update ASN_Map.values();
        update ASN_POS_ItemsList;
    }
    
    /**
Method: finish 
Purpose: this method must be used .and this is default method
Parameters: bc is an interface.this is default interface.
Returns: none
*/
    
    global void finish (Database.BatchableContext bc)
    {
    }
    
    /***
Class Name : JsonResponse,AdvanceShipmentItem,IResourceLink,CometResponse
Description : getting comet response and stored in to objects

***/
    
    global class JsonResponse
    {
        global Integer Id ;
        global String Status ;
        global List<AdvanceShipmentItem> Products ;        
    }
    global class AdvanceShipmentItem
    {
        global IResourceLink Link ;
        global Integer Quantity ;
        global Integer QuantityReceived ;
    }
    global class IResourceLink 
    {
        global String Rel ;
        global String Name ;
        global String Url ;    
    }
    global class CometResponse
    {
        global String status;
        global Integer statusCode;
        global String statusDescription;
        global cometResponse(String status,Integer statusCode,String statusDescription){
            this.status=status;
            this.statusCode=statusCode;
            this.statusDescription=statusDescription;
        }
    }
}