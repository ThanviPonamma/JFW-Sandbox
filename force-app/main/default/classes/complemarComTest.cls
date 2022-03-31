@IsTest
private with sharing class complemarComTest
{
    private static testMethod void coverTypes()
    {
               
 new complemarCom.AddressRequest();
 new complemarCom.ArrayOfBoxInfo();
 new complemarCom.ArrayOfBoxItemInfo();
 new complemarCom.ArrayOfOrderItemTagRequest();
 new complemarCom.ArrayOfOrderRequestItem();
 new complemarCom.ArrayOfOrderStatus();
 new complemarCom.ArrayOfProductInventoryStatus();
 new complemarCom.ArrayOfShippingSystemKanBanRequest();
 new complemarCom.ArrayOfShippingSystemPackageRequest();
 new complemarCom.ArrayOfShippingSystemStatus();
 new complemarCom.ArrayOfString();
 new complemarCom.AvailableBalance_element();
 new complemarCom.AvailableBalanceFromJobNumber_element();
 new complemarCom.AvailableBalanceFromJobNumberResponse_element();
 new complemarCom.AvailableBalanceResponse_element();
 new complemarCom.AvailableBalances_element();
 new complemarCom.AvailableBalancesResponse_element();
 new complemarCom.BillToRequest();
 new complemarCom.BoxInfo();
 new complemarCom.BoxItemInfo();
 new complemarCom.CometERPWSSoap();
 new complemarCom.ContactRequest();
 new complemarCom.CreateOrder_element();
 new complemarCom.CreateOrderResponse_element();
 new complemarCom.CreditCardRequest();
 new complemarCom.CustomerLevelRequest();
 new complemarCom.CustomFieldRequest();
 new complemarCom.EmailRequest();
 new complemarCom.GetOrderStatus_element();
 new complemarCom.GetOrderStatusFromJobNumber_element();
 new complemarCom.GetOrderStatusFromJobNumberResponse_element();
 new complemarCom.GetOrderStatusList_element();
 new complemarCom.GetOrderStatusListResponse_element();
 new complemarCom.GetOrderStatusResponse_element();
 new complemarCom.GiftCardRequest();
 new complemarCom.MessageRequest();
 new complemarCom.OrderedByRequest();
 new complemarCom.OrderItemTagRequest();
 new complemarCom.OrderRequest();
 new complemarCom.OrderRequestItem();
 new complemarCom.OrderStatus();
 new complemarCom.PaymentRequest();
 new complemarCom.PhoneNumberRequest();
 new complemarCom.ProductInventoryStatus();
 new complemarCom.PurchaseOrderRequest();
 new complemarCom.ReceiptStatus();
 new complemarCom.Request();
 new complemarCom.ShipmentRequest_element();
 new complemarCom.ShipmentRequestResponse_element();
 new complemarCom.ShippingInfo();
 new complemarCom.ShippingRequest();
 new complemarCom.ShippingSystemKanBanOrders_element();
 new complemarCom.ShippingSystemKanBanOrdersResponse_element();
 new complemarCom.ShippingSystemKanBanRequest();
 new complemarCom.ShippingSystemPackageRequest();
 new complemarCom.ShippingSystemShipmentRequest();
 new complemarCom.ShippingSystemStatus();
 new complemarCom.ShippingSystemUpdateOrder_element();
 new complemarCom.ShippingSystemUpdateOrderResponse_element();
 new complemarCom.ShipToRequest();
 new complemarCom.Status();
 new complemarCom.TimeSpan();
    }
    
    
    private class WebServiceMockImpl implements WebServiceMock
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType)
        {
            if(request instanceof complemarCom.AvailableBalance_element)
                response.put('response_x', new complemarCom.AvailableBalanceResponse_element());
            if(request instanceof complemarCom.AvailableBalanceFromJobNumber_element)
                response.put('response_x', new complemarCom.AvailableBalanceFromJobNumberResponse_element());
            if(request instanceof complemarCom.AvailableBalances_element)
                response.put('response_x', new complemarCom.AvailableBalancesResponse_element());
            if(request instanceof complemarCom.CreateOrder_element)
                response.put('response_x', new complemarCom.CreateOrderResponse_element());  
            if(request instanceof complemarCom.GetOrderStatus_element)
                response.put('response_x', new complemarCom.GetOrderStatusResponse_element()); 
            if(request instanceof complemarCom.GetOrderStatusFromJobNumber_element)
                response.put('response_x', new complemarCom.GetOrderStatusFromJobNumberResponse_element()); 
            if(request instanceof complemarCom.GetOrderStatusList_element)
                response.put('response_x', new complemarCom.GetOrderStatusListResponse_element()); 
            if(request instanceof complemarCom.ShipmentRequest_element)
                response.put('response_x', new complemarCom.ShipmentRequestResponse_element()); 
            if(request instanceof complemarCom.ShippingSystemKanBanOrders_element)
                response.put('response_x', new complemarCom.ShippingSystemKanBanOrdersResponse_element()); 
            if(request instanceof complemarCom.ShippingSystemUpdateOrder_element)
                response.put('response_x', new complemarCom.ShippingSystemUpdateOrderResponse_element());                 
            return;
        }
    }
    
    private static testMethod void coverMethods()
    {
        complemarCom.blnIsTest = true;
        new complemarCom.CometERPWSSoap().AvailableBalance('a', 'b', 'c', 'd');
        new complemarCom.CometERPWSSoap().AvailableBalanceFromJobNumber(null, null, null, null,null);
        
        new complemarCom.CometERPWSSoap().AvailableBalances(null, null, null);
        new complemarCom.CometERPWSSoap().CreateOrder(null, null, null);
        new complemarCom.CometERPWSSoap().GetOrderStatus(null, null, null, null);
        new complemarCom.CometERPWSSoap().GetOrderStatusFromJobNumber(null, null, null, null, null);
        new complemarCom.CometERPWSSoap().GetOrderStatusList(null, null, null, null);
        new complemarCom.CometERPWSSoap().ShipmentRequest(null, null, null, null, null, null, null);
        new complemarCom.CometERPWSSoap().ShippingSystemKanBanOrders(null, null, null);
        new complemarCom.CometERPWSSoap().ShippingSystemUpdateOrder(null, null, null, null, null);

    }
    
}