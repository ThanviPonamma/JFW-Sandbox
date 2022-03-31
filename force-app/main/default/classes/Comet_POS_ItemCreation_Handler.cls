/***
    class :Comet_POS_ItemCreation_Handler
    Description : this is called by Comet_POS_ItemCreation Trigger and it sends a new item to Comet and the item is created in comet using REST API.
    Date : 04 th of June in 2018
    Version : 001
    Author : Pradeep Kumar
***/
public class Comet_POS_ItemCreation_Handler
{
    /***
        Method : createPOS_Item
        Parameters : Map<Id,POS_Item__c> processingPosItems
                    processingPosItems - items which are updated and inserted.
        Return type: None
        Description : this method is used to collect the ids of All Pos Items which are updated and inserted and it calls main method called 'createPOS_Item_Async'.
    ***/
    public static void createPOS_Item(Map<Id,POS_Item__c> processingNewPosItems,Map<Id,POS_Item__c> processingOldPosItems,Boolean isAttachmentToBeDeleted)
    {
        List<Attachment> attachmentList;
        Set<Id>  attachmentIds=new Set<Id> ();
        
        Map<Id,POS_Item__c> posItemsWithAccountDetails=new Map<Id,POS_Item__c>([SELECT Id,Account__r.Is_Comet_Rest_Api__c,Account__r.Comet_API_Key__c FROM POS_Item__c WHERE Id IN : processingNewPosItems.keySet() AND Account__r.Is_Comet_Rest_Api__c=true AND Account__r.Comet_API_Key__c!=null AND Account__r.Comet_API_Key__c!='']);
        if(!posItemsWithAccountDetails.isEmpty() && !System.isFuture())
            createPOS_Item_Async(posItemsWithAccountDetails.keySet()); 
        if(isAttachmentToBeDeleted)
        {
            for(POS_Item__c posItem : processingNewPosItems.values())
            {
                if(processingOldPosItems.get(posItem.Id).Attachment_Id__c!=posItem.Attachment_Id__c)
                {
                    if(String.isNotBlank(processingOldPosItems.get(posItem.Id).Attachment_Id__c))
                    {
                        attachmentIds.add(processingOldPosItems.get(posItem.Id).Attachment_Id__c);
                    }
                }
            }
            attachmentList=[SELECT Id FROM Attachment WHERE Id IN :attachmentIds];
            delete attachmentList;
        }
    }
    
    /***
        Method : createPOS_Item_Async
        Parameters : Set<Id> processingItemIds
                    processingItemIds- items' ids which are updated and inserted.
        Return type: None
        Description : this method is used to submit Pos items(which are new items only) to comet asynchronousy.
    ****/
    @future(callout=true)
    public static void createPOS_Item_Async(Set<Id> processingItemIds)
    {
        Map<Id,POS_Item__c> posItemsToBeCreated=new Map<Id,POS_Item__c>([SELECT Id,Item_Name__c,Name,Price__c,Description__c,ExpirationDateRequired__c,LotNumberRequired__c,HarmonizationCode__c,Account__r.Is_Comet_Rest_Api__c,Account__r.Name,Account__r.Comet_API_Key__c,Item_No__c,Length__c,Height__c,Width__c,Weight__c FROM POS_Item__c WHERE Id IN : processingItemIds AND Account__r.Comet_API_Key__c!=null AND Account__r.Comet_API_Key__c!='']);        
        Set<String> cometAccessTokens=new Set<String> ();
        Map<String,Set<String>> accountWithCometStocknos=new Map<String,Set<String>> ();
        Map<String,String> accountWithCometBadResponse=new Map<String,String> ();
        Map<String,Set<String>> accountWithEmergeStocknos=new Map<String,Set<String>> ();        
        Map<Id,String> posItemWithCometResponse=new Map<Id,String> ();
        for(Account account : [SELECT Id,Comet_API_Key__c,(SELECT Id,Item_No__c FROM POS_Items__r) FROM Account WHERE Id IN  (SELECT Account__c FROM POS_Item__c WHERE Id IN : posItemsToBeCreated.keySet())]) 
        { 
            Set<String> itemNosList=new Set<String> ();
            for(POS_Item__c posItem :account.POS_Items__r)
                itemNosList.add(posItem.Item_No__c.toUpperCase());
            accountWithEmergeStocknos.put(account.Comet_API_Key__c,itemNosList);
        }
        for(POS_Item__c posItem:posItemsToBeCreated.values())
            cometAccessTokens.add(posItem.Account__r.Comet_API_Key__c);
            
        for(String accessToken:cometAccessTokens)
        {  
            List<InventorySummary > StockResponseList=new List<InventorySummary > ();  
            Set<String> stockNos=new Set<String> ();
            HTTP http=new HTTP ();
            HttpRequest request=new HttpRequest ();
            HttpResponse response=new HttpResponse ();
            request.setEndPoint('https://api.complemar.com/v1/inventory/summary');
            request.setMethod('GET'); 
            request.setHeader('Authorization','Bearer '+accessToken);
            request.setHeader('Content-Type','application/json');
            request.setTimeOut(120000); 
            response=http.send(request);
            if(response.getStatusCode()==200 && response.getStatus()=='OK')
            {
                StockResponseList=(List<InventorySummary >)System.JSON.deserialize(response.getBody(),List<InventorySummary >.class);                
                if(StockResponseList!=null)
                    for(InventorySummary  eachInventory : StockResponseList)
                            stockNos.add(eachInventory.StockNumber.toUpperCase()); 
                if(!stockNos.isEmpty()) 
                    accountWithCometStocknos.put(accessToken,stockNos) ; 
            } 
            else
            {
                accountWithCometBadResponse.put(accessToken,response.getStatus()+','+response.getBody());
            }       
        }
        for(POS_Item__c posItem : posItemsToBeCreated.values())
        {
            if(accountWithCometStocknos.get(posItem.Account__r.Comet_API_Key__c)==null)
                posItem.Comet_Response__c=accountWithCometBadResponse.get(posItem.Account__r.Comet_API_Key__c);
            if(accountWithCometStocknos.containsKey(posItem.Account__r.Comet_API_Key__c))
            if(!accountWithCometStocknos.get(posItem.Account__r.Comet_API_Key__c).contains(posItem.Item_No__c.toUpperCase()))
            {
                HTTP http=new HTTP ();
                HttpRequest request=new HttpRequest ();
                HttpResponse response=new HttpResponse ();
                String body='';
                request.setEndPoint('https://api.complemar.com/v1/products/standard');
                request.setMethod('POST'); 
                request.setHeader('Authorization','Bearer '+posItem.Account__r.Comet_API_Key__c);
                request.setHeader('Content-Type','application/json');
                request.setTimeOut(120000);                 
                String StockNumber=(String.isBlank(posItem.Item_No__c)?'':posItem.Item_No__c);
                String Barcode=posItem.Item_No__c;
                String Description=(String.isBlank(posItem.Item_Name__c)?'':posItem.Item_Name__c);
                String Length=(posItem.Length__c==null || posItem.Length__c==0?'0.001':String.valueOf(posItem.Length__c));
                String Width=(posItem.Width__c==null || posItem.Width__c==0?'0.001':String.valueOf(posItem.Width__c));
                String Height=(posItem.Height__c==null || posItem.Height__c==0?'0.001':String.valueOf(posItem.Height__c));
                String Weight=(posItem.Weight__c==null || posItem.Weight__c==0?'0.001':String.valueOf(posItem.Weight__c));
                String LotNumberRequired=String.valueOf(posItem.LotNumberRequired__c);
                String ExpirationDateRequired=String.valueOf(posItem.ExpirationDateRequired__c);
                String HarmonizationCode=(String.isBlank(posItem.HarmonizationCode__c)?'':posItem.HarmonizationCode__c);
                String Price=(posItem.Price__c==null?'0':String.valueOf(posItem.Price__c));
                if( (posItem.Length__c!=0 && posItem.Length__c!=null)   || (posItem.Width__c !=0 && posItem.Width__c!=null) || (posItem.Height__c!=null && posItem.Height__c!=0) || (posItem.Weight__c!=null && posItem.Weight__c!=0))
                    body='{   "StockNumber": "'+StockNumber+'",   "Barcode": "'+Barcode+'",   "Description": "'+Description+'",   "Dimensions": {     "Length": '+Length+',     "Width": '+Width+',     "Height": '+Height+',     "Weight": '+Weight+'   },   "LotNumberRequired": '+LotNumberRequired+',   "ExpirationDateRequired": '+ExpirationDateRequired+',   "HarmonizationCode": "'+HarmonizationCode+'",   "Price": '+Price+' }';
                else
                    body='{   "StockNumber": "'+StockNumber+'",   "Barcode": "'+Barcode+'",   "Description": "'+Description+'", "LotNumberRequired": '+LotNumberRequired+',   "ExpirationDateRequired": '+ExpirationDateRequired+',   "HarmonizationCode": "'+HarmonizationCode+'",   "Price": '+Price+' }'; 
                request.setBody(body);
                response=http.send(request);
                System.debug(response);
                if(response.getStatusCode()==201)
                    posItem.Is_Synchronized__c=true;               
                posItem.Comet_Response__c=response.getBody(); 
            }else
            {
                posItem.Is_Synchronized__c=true;
            }
        }
        System.debug(posItemsToBeCreated);
        if(!posItemsToBeCreated.isEmpty())
            update posItemsToBeCreated.values();
    }               
    
    public class InventorySummary 
    {
        public String StockNumber ;
        public Integer BalanceOnHand ;
        public Integer Allocated ;
        public Integer Available ;
        public Integer Unshippable ;
    }    
}