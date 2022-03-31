public class RestAPIjobs  
{  
    class cometOrderJsonResponse
    {
        HttpResponse response ;
        String errorMessage ;
    }   
    
    
    @future(callout=true)
    public static void updateOrderStatusForAccount(String accountName)
    {
        
        List<OrderDestination__c> OdList;
        String apiToken ='';
        List<Account> objAccountList_curr;
        if ( accountName == '')
            objAccountList_curr  = [SELECT ID, Name, Comet_API_Key__c, Is_Comet_Rest_Api__c FROM Account WHERE Is_Comet_Rest_Api__c = true];
        else
            objAccountList_curr = [SELECT ID, Name, Comet_API_Key__c, Is_Comet_Rest_Api__c FROM Account WHERE Is_Comet_Rest_Api__c = true  AND Name =:accountName ];
        
        for (Account objAccount: objAccountList_curr)
        {
            apiToken =objAccount.Comet_API_Key__c;
            OdList = [Select ID, Name, OrderName__C, WarehouseOrderStatus__c, WarehouseProcessingStatus__c, WarehouseSequence__c, WarehouseShippingComments__c, WarehouseShippingDate__c, WarehouseShippingStatus__c, WarehouseTransactionNo__c, Carrier__c, TrackingNos__c FROM OrderDestination__c WHERE Order__r.Account__c =: objAccount.id AND WarehouseTransactionNo__c !=NULL AND WarehouseTransactionNo__c !='0'  AND WarehouseShippingStatus__c = NULL ORDER BY WarehouseResponseDate__c ASC LIMIT 25];
            OrderDestination__c cometOrder = new OrderDestination__c();
            for (Integer a = 0; a< OdList.size(); a++)
            {
                OdList[a].WarehouseResponseDate__c = System.Now();
                Http http=new Http ();
                HttpRequest request=new HttpRequest ();
                HttpResponse response=new HttpResponse ();
                cometOrderJsonResponse jsonResponse=new cometOrderJsonResponse();
                request.setEndPoint('https://api.complemar.com/v1/orders/'+OdList[a].WarehouseTransactionNo__c );
                //testing...
                //request.setHeader('Authorization','Bearer '+'5zkbnOTmq6rBQko0bLh5Oltmr6OJyUwQDiK2FYrvY8IDYrs6OV');
                request.setHeader('Authorization','Bearer '+objAccount.Comet_API_Key__c);
                request.setHeader('Content-Type','application/json');
                request.setTimeOut(120000);
                request.setMethod('GET');
                try{
                    response=http.send(request);
                    jsonResponse.response=response;  
                }
                catch(exception ex)
                {
                    jsonResponse.errorMessage =ex.getMessage();
                    OdList[a].WarehouseShippingComments__c = ex.getMessage();
                    System.debug('ex.getMessage()  '+ ex.getMessage());
                }
                
                response=jsonResponse.response;
                if(response!=null)
                {
                    System.debug(response);
                    OdList[a].WarehouseShippingComments__c = String.valueOf(response);
                    if(response.getStatusCode()==200)
                    {
                        JSONParser parser = JSON.createParser(response.getBody());
                        JSONParser parserForOrderStatus = JSON.createParser(response.getBody());
                        string TrackingNo='';
                        String orderStatus='';
                        String fulfillmentStatus='';
                        String fulfillmentDate='';
                        String Carrier='';
                        String deliveryOption ='';
                        parserForOrderStatus.nextToken();
                        parserForOrderStatus.nextToken();
                        parserForOrderStatus.nextToken();
                        parserForOrderStatus.nextToken();
                        parserForOrderStatus.nextToken();
                        orderStatus=parserForOrderStatus.getText();
                        while(parserForOrderStatus.nextToken() != null)
                        {
                            if((parserForOrderStatus.getCurrentToken() == JSONToken.FIELD_NAME) && (parserForOrderStatus.getText() == 'Status'))
                            {
                                parserForOrderStatus.nextToken();
                                fulfillmentStatus=parserForOrderStatus.getText();
                            }
                            if((parserForOrderStatus.getCurrentToken() == JSONToken.FIELD_NAME) && (parserForOrderStatus.getText() == 'DeliveryOption'))
                            {
                                parserForOrderStatus.nextToken();
                                deliveryOption=parserForOrderStatus.getText();
                            }
                            if((parserForOrderStatus.getCurrentToken() == JSONToken.FIELD_NAME) && (parserForOrderStatus.getText() == 'FulfillmentDate'))
                            {
                                parserForOrderStatus.nextToken();
                                fulfillmentDate=parserForOrderStatus.getText();
                            }
                            if((parserForOrderStatus.getCurrentToken() == JSONToken.FIELD_NAME) && (parserForOrderStatus.getText() == 'Carrier'))
                            {
                                parserForOrderStatus.nextToken();
                                Carrier=parserForOrderStatus.getText();
                            }
                        }
                        while (parser.nextToken() != null)
                        {
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'TrackingNumber'))
                            {
                                parser.nextToken();
                                TrackingNo += parser.getText()+', ';
                            }
                        }
                        TrackingNo = TrackingNo.removeEnd(', ');
                        OdList[a].WarehouseProcessingStatus__c = orderStatus;
                        if (( TrackingNo != null) && (TrackingNo != ''))
                        {
                            OdList[a].WarehouseShippingStatus__c ='Shipped';
                            OdList[a].WarehouseShippingDate__c=System.now();
                            OdList[a].WarehouseShippingComments__c = 'Carrier : ' + Carrier + ' ShipmentNumber : ' + ' Method : ' + deliveryOption + ' TrackingNumbers : ' + TrackingNo;
                            OdList[a].Carrier__c = Carrier;
                            OdList[a].TrackingNos__c = TrackingNo;
                        }
                    }
                }
            }
            update OdList;
        }
    }
}