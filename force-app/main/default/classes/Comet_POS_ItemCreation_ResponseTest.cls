@isTest
global class Comet_POS_ItemCreation_ResponseTest implements HttpCalloutMock
{
   global HTTPResponse  respond(HTTPRequest request)
   {
       HTTPResponse response=new HTTPResponse ();
       response.setHeader('Content-Type', 'application/json');
       response.setStatus('OK');
       if(request.getEndpoint()=='https://api.complemar.com/v1/inventory/summary')
       {
           response.setStatusCode(200);
           response.setBody('[{"StockNumber": "11234","Product": {"Rel": "product","Name": "Product 11234","Url": "https://api.complemar.com/v1/products/11234"},"BalanceOnHand": 0,"Allocated": 0,"Available": 0,"Unshippable": 0},{"StockNumber": "itm1","Product": {"Rel": "product","Name": "Product itm1","Url": "https://api.complemar.com/v1/products/itm1"},"BalanceOnHand": 0,"Allocated": 0,"Available": 0,"Unshippable": 0} ]');
       }
       else
       {
           if(request.getEndPoint().contains('https://api.complemar.com/v1/advance-shipment-notices/'))
           {
               response.setStatusCode(200);
               response.setBody('{     "Id": 1841,     "Warehouse": {         "Rel": "warehouse",         "Name": "Sparks",         "Url": "https://api.complemar.com/v1/warehouses/SPA"     },     "Status": "Created",     "ExpectedDate": "2018-06-07T16:20:00",     "Carrier": "",     "TrackingNumber": "",     "PONumber": "",     "PackageCount": 0,     "PalletCount": 0,     "Vendor": "",     "Products": [         {             "Link": {                 "Rel": "product",                 "Name": "Z-SJBROCH1216",                 "Url": "https://api.complemar.com/v1/products/Z-SJBROCH1216"             },             "Quantity": 12,             "QuantityReceived": 0         }     ] }');
           }
           else
           {
               response.setStatusCode(201);
               response.setBody('{"Rel": "product","Name": "Standard Product ahegxbsbs2","Url": "https://api.complemar.com/v1/products/ahegxbsbs2" }');
           }
       }
       return response;
   }
}