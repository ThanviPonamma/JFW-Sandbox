/**Authors : Sanjana
Date : 08/11/2021
Aim : To view all orders (both confirmed and open orders)*/

public class InfiniumInventoryOrderStatus_Apex {
    
    //To hold the account data in objAccount variable
    public static Account objAccount;
    
    //To fetch the account details
    @AuraEnabled
    public static Account getAccount() { 
        if(Test.isRunningTest())
        {
            //for fetching the account details
            objAccount=[SELECT Id, Name,Lightning_Community_URL__c FROM Account
                        WHERE Name LIKE '%Infinium Spirits%' LIMIT 1];
        }
        else
        {
            objAccount=[SELECT Id, Name,Lightning_Community_URL__c FROM Account
                        WHERE Lightning_Community_Id__c=:Network.getNetworkId() LIMIT 1];
        }
        return objAccount;
    }
    
    //To fetch all the inventory orders both open and confirmed
    @AuraEnabled(cacheable=true)
    public static List<OrderStatus_Wrapper> getAllInventoryOrders (String searchKeyword)
    {
        
        List<OrderStatus_Wrapper> orderDetailsWrapper = new List<OrderStatus_Wrapper>();
        String query='';
        String whereClause='';
        objAccount = getAccount();
        //to fecth all the order details for the account infinium spirits
        query+='SELECT Order__r.Name, Order__r.Id,Order__r.Order_Date__c, Order__r.CreatedById,Order__r.Order_Status__c, OrderDestination__c.Name,';
        query+='AddressBook__r.Destination_Name__c, AddressBook__r.Shipto_Name__c,AddressBook__r.Zip__c, AddressBook__r.Shipto_Company__c, AddressBook__r.City__c,AddressBook__r.State__r.State_Code__c,AddressBook__r.State__r.State_Name__c, AddressBook__r.Address__c,ShippingMethodRejeted__c,ShipMethodApproved__c,SelectedShippingMethod__r.Shipping_Method_Name__c,Shipping_Method__r.Shipping_Method_Name__c,';
        query+='OrderName__c,SelectedShippingMethod__r.ApprovalRequired__c,(SELECT Name, Id,POS_Item__c,Quantity__c,POS_Item__r.Attachment_Id__c,POS_Item__r.Active__c, OrderDestination__r.AddressBook__r.Shipto_Name__c,  OrderDestination__r.AddressBook__r.Zip__c,OrderDestination__r.OrderName__c, OrderDestination__r.AddressBook__r.Shipto_Company__c, OrderDestination__r.AddressBook__r.Address__c, OrderDestination__r.AddressBook__r.City__c,OrderDestination__r.AddressBook__r.State__r.State_Code__c,OrderDestination__r.AddressBook__r.State__r.State_Name__c, POS_Item__r.Item_No__c, POS_Item__r.Pack_Of__c, POS_Item__r.Item_Name__c, SelectedQuantity__c ,';
        query+='POS_Item__r.Brand__r.Brand_Name__c,POS_Item__r.Type_of_Item__r.Item_Type__c,POS_Item__r.Approval_Required__c,POS_Item__r.Maximum_Order_Qty__c,POS_Item__r.Maximum_order_quantity_applicable__c,MaxOrderAppReq__c,ItemApproved__c,ItemRejected__c,MaxOrderApproved__c,MaxOrderRejected__c FROM OrderDestinationItems__r WHERE SelectedQuantity__c>0 )';
        query+=',WarehouseOrderStatus__c, WarehouseProcessingStatus__c, WarehouseSequence__c, WarehouseShippingComments__c, WarehouseShippingDate__c, WarehouseShippingStatus__c, WarehouseTransactionNo__c';
        query+=',OrdStatus__c, Carrier__c, TrackingNos__c ';
        query+='FROM OrderDestination__c';
        whereClause+=' WHERE Order__r.Account__c=\''+objAccount.Id+'\' AND Order__r.Program__c=null';
        whereClause+=' AND Order__r.OwnerId =\''+UserInfo.getUserId()+'\'';
        //to obtained the order details based on the searchkeyword, if the keyword exists
        if(String.isNotBlank(searchKeyword))
        {
            System.debug('searchKeyword->'+searchKeyword);
            //Search key word result to be returned based on the order name 
            whereClause+=' AND ( OrderName__c LIKE '+'\'%'+searchKeyword+'%\' ';
            //Search key word result to be returned based on the Destination name 
            whereClause+=' OR AddressBook__r.Destination_Name__c LIKE '+'\'%'+searchKeyword+'%\' ';
            //Search key word result to be returned based on the Ship to name 
            whereClause+=' OR AddressBook__r.Shipto_Name__c LIKE '+'\'%'+searchKeyword+'%\' ';
            //Search key word result to be returned based on the Ship to company 
            whereClause+=' OR AddressBook__r.Shipto_Company__c LIKE '+'\'%'+searchKeyword+'%\' ';
            //Search key word result to be returned based on the city
            whereClause+=' OR AddressBook__r.City__c LIKE '+'\'%'+searchKeyword+'%\' ) ';
        }
        //after all the conditions are met they are ordered based on created by date
        query=query+whereClause +' ORDER BY CreatedDate DESC';
        List<OrderDestination__c> result = new List<OrderDestination__c>();
        //result variable contains all the inventory orders that are confirmed and open.
        result =  Database.query(query);
        //for every order destination in result vaiable check if the orders are open , if yes , set button to true to display edit details in the frontend.
        for(OrderDestination__c orderDest: result){
            Boolean orderStatusButton = false;
            if(orderDest.Order__r.Order_Status__c == 'Open'){     
                orderStatusButton  = true;
                //add the particular order destination and a order status button value to the list of wrapper class to the frontend.
                orderDetailsWrapper.add(new OrderStatus_Wrapper(orderDest,orderStatusButton));
                
            }
            //if no , then set the order status button of the wrapper class to false , to display view display button in the front end.
            else{
                orderStatusButton = false;
                //add the particular order destination and a order status button value to the list of wrapper class to the frontend.
                orderDetailsWrapper.add(new OrderStatus_Wrapper(orderDest,orderStatusButton));
            }
        }
        System.debug(orderDetailsWrapper);
        // return the list of wrapper class to the frontend.
        return orderDetailsWrapper;      
    }
    
    //Aim : To get the image URL and order details for the selected comet order.
    
    @AuraEnabled(cacheable=true)
    public static List<OrderStatusDetails_Wrapper> getOrderDetailsOfSelectedOrder (String orderDestinationId)
    {
        system.debug('orderDestinationId -->'+orderDestinationId);
        objAccount = getAccount();
        List<OrderStatusDetails_Wrapper>  orderDetailsOfSelectedOrder = new List<OrderStatusDetails_Wrapper>();
        // to get the comet order details for the selected comet order Id
        List<OrderDestinationItem__c> orderDestinationItems = [SELECT Name, Id,POS_Item__c,Quantity__c,POS_Item__r.Attachment_Id__c,POS_Item__r.Active__c, OrderDestination__r.AddressBook__r.Shipto_Name__c,
                                                               OrderDestination__r.OrderName__c, OrderDestination__r.AddressBook__r.Shipto_Company__c,
                                                               OrderDestination__r.AddressBook__r.Address__c, OrderDestination__r.AddressBook__r.City__c,
                                                               POS_Item__r.Item_No__c, POS_Item__r.Pack_Of__c, POS_Item__r.Item_Name__c,POS_Item__r.Brand__r.Brand_Name__c,POS_Item__r.Type_of_Item__r.Item_Type__c,POS_Item__r.Approval_Required__c,POS_Item__r.Maximum_Order_Qty__c,MaxOrderAppReq__c,ItemApproved__c,ItemRejected__c,MaxOrderApproved__c,MaxOrderRejected__c,
                                                               OrderDestination__r.Order__r.Order_Status__c, SelectedQuantity__c,OrderDestination__r.SelectedShippingMethod__r.Shipping_Method_Name__c,OrderDestination__r.TrackingNos__c,OrderDestination__r.OrdStatus__c
                                                               FROM OrderDestinationItem__c WHERE orderDestination__c=:orderDestinationId ];
        // to hold the pos item image of the comet order item
        List<String> posItemImageURL = new List<String>();
        for(orderDestinationItem__c item : orderDestinationItems){
            // to hold the pos item attachment id , if the item had a pos item attachment id else will be null
            String attachmentURL = String.isBlank(item.POS_Item__r.Attachment_Id__c)?'':objAccount.Lightning_Community_URL__c+'/servlet/servlet.FileDownload?file='+item.POS_Item__r.Attachment_Id__c;
            orderDetailsOfSelectedOrder.add(new OrderStatusDetails_Wrapper(item,attachmentURL));            
        }
        System.debug('orderDetailsOfSelectedOrder--->'+orderDetailsOfSelectedOrder);
        // return the comet order details
        return orderDetailsOfSelectedOrder;
    }
    
    //Aim : To hold the Image URL and Ordered items details of the order statuses
    public class OrderStatusDetails_Wrapper{
        
        @AuraEnabled 
        public OrderDestinationItem__c OrderItems;// to hold comet order item details
        @AuraEnabled
        public String posItemImageURL;// to hold the pos item image id
        
        public OrderStatusDetails_Wrapper(OrderDestinationItem__c OrderItems , String posItemImageURL){
            
            this.OrderItems = OrderItems;
            this.posItemImageURL = posItemImageURL;
            
        }   
    }
    //Aim : To hold the order destination and the order status button value.
    public class OrderStatus_Wrapper{
        @AuraEnabled 
        public OrderDestination__c OrderDestination;// to hold the order detsination details
        @AuraEnabled
        public Boolean orderStatusButton;// to hold the true/false, based on the status of the order
        
        public OrderStatus_Wrapper(OrderDestination__c OrderDestination , Boolean orderStatusButton){
            
            this.OrderDestination = OrderDestination;
            this.orderStatusButton = orderStatusButton;
            
        }
        
    }
    
}