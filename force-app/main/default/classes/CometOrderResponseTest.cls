global class CometOrderResponseTest implements HttpCalloutMock
{
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{ "ResourceLink": { "Rel": "order","Name": "Order 962","Url": "https://api.complemar.com/v1/orders/962"},"OrderNumber": "962","Message": "Order submitted."}');
        res.setStatusCode(201);
        return res;
    }
}