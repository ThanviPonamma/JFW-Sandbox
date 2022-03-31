public class DFVApprovalComponentController {
    public static Account objAccount;
    @AuraEnabled
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
    public static List<CometOrderApprovalWrapper> loadAllCometApprovalOrders()
    {
        Account objAccount=getAccount();
        List<CometOrderApprovalWrapper> approvalOrders=new List<CometOrderApprovalWrapper> ();
        // return [SELECT Id,SelectedShippingMethod__r.Shipping_Method_Name__c,(SELECT Id FROM OrderDestinationItems__r WHERE Quantity__c>0),ShippingMethodRejeted__c,ShipMethAppReq__c,AddressBook__r.Shipto_Name__c,AddressBook__r.Address__c, CreatedDate, Order__r.Order_Confirmation_Date__c,Order__r.Account__c, CreatedBy.Name, OrderName__c, Order__r.Name,  Shipping_Method__r.Shipping_Method_Name__c, AddressBook__r.Shipto_Company__c, AddressBook__r.City__c , ShipMethodApproved__c 
        //         FROM OrderDestination__c WHERE Order__r.Account__c=:objAccount.Id AND OrdStatus__c='Needs Approval' AND Id IN (SELECT OrderDestination__c FROM OrderDestinationItem__c WHERE Quantity__c>0)];
        for(OrderDestination__c cometOrder : [SELECT Id,ShipMethAppReq__c,Shipping_Method__c,SelectedShippingMethod__r.Shipping_Method_Name__c,
                                              All_Approvals_Cleared__c,ShippingMethodRejeted__c,AddressBook__r.Shipto_Name__c,
                                              AddressBook__r.Address__c, CreatedDate, Order__r.Order_Confirmation_Date__c,Order__r.Account__c, 
                                              CreatedBy.Name, OrderName__c, Order__r.Name,Order__r.Account__r.Name, 
                                              Shipping_Method__r.Shipping_Method_Name__c, AddressBook__r.Shipto_Company__c, AddressBook__r.City__c , 
                                              ShipMethodApproved__c,Comet_Order_Status__c,(SELECT Id,ItemAppReq__c,SelectedQuantity__c,OrderDestination__r.ShipMethAppReq__c,Pos_Item__r.Logical_Invenory_Stock__c,
                                            MaxOrderRejected__c,OrderDestination__r.ShipMethodApproved__c,OrderDestination__r.ShippingMethodRejeted__c,
                                            OrderDestination__r.Shipping_Method__r.ApprovalRequired__c,POS_Item__r.Item_No__c,OrderDestination__c,
                                            ItemApproved__c,OrderDestination__r.CreatedBy.Id,OrderDestination__r.AddressBook__r.Address__c,
                                            OrderDestination__r.AddressBook__r.Shipto_Name__c, CreatedDate,ItemRejected__c, 
                                            OrderDestination__r.Order__r.Order_Confirmation_Date__c, OrderDestination__r.Order__r.Account__c, 
                                            CreatedBy.Name, ItemName__c, OrderDestination__r.OrderName__c, OrderDestination__r.Order__r.Name,
                                            POS_Item__r.Item_Name__c, POS_Item__r.Maximum_Order_Qty__c,POS_Item__r.Available_Stock__c, 
                                            Quantity__c, POS_Item__r.Brand__r.Brand_Name__c, POS_Item__r.Pack_Of__c, POS_Item__r.Price__c, 
                                            MaxOrderApproved__c, MaxOrderAppReq__c, OrderDestination__r.AddressBook__r.Shipto_Company__c, 
                                            OrderDestination__r.AddressBook__r.City__c  
                                            FROM OrderDestinationItems__r 
                                            WHERE Quantity__c>0 AND Quantity__c!=null) 
                                              FROM OrderDestination__c WHERE Order__r.Account__c=:objAccount.Id AND 
                                              OrdStatus__c='Needs Approval' 
                                            AND Id IN (SELECT OrderDestination__c FROM OrderDestinationItem__c WHERE Quantity__c>0
                                             AND ((OrderDestination__r.ShipMethAppReq__c=true 
                                             AND OrderDestination__r.ShippingMethodRejeted__c=false 
                                             AND OrderDestination__r.ShipMethodApproved__c=false)
                                            OR (ItemAppReq__c=true AND ItemApproved__c=false AND ItemRejected__c=false)
                                             OR (MaxOrderAppReq__c=true AND MaxOrderApproved__c=false AND MaxOrderRejected__c=false)))])
        {
            List<OrderDestinationItem__c> cometOrderItemsForItemApproval=new List<OrderDestinationItem__c> ();
            List<OrderDestinationItem__c> cometOrderItemsForMaxOrdQtyApproval=new List<OrderDestinationItem__c> ();
            for(OrderDestinationItem__c cometOrderItem : cometOrder.OrderDestinationItems__r)
            {
                if(cometOrderItem.ItemAppReq__c && !cometOrderItem.ItemApproved__c && !cometOrderItem.ItemRejected__c)
                    cometOrderItemsForItemApproval.add(cometOrderItem);
                if(cometOrderItem.MaxOrderAppReq__c && !cometOrderItem.MaxOrderApproved__c && !cometOrderItem.MaxOrderRejected__c)
                    cometOrderItemsForMaxOrdQtyApproval.add(cometOrderItem);
                
            }
            approvalOrders.add(new CometOrderApprovalWrapper(cometOrder,cometOrderItemsForItemApproval,cometOrderItemsForMaxOrdQtyApproval));
        }
        return approvalOrders;
    }
    public class CometOrderApprovalWrapper
    {
        @AuraEnabled
        public OrderDestination__c cometOrder;
        @AuraEnabled
        public List<OrderDestinationItem__c> cometOrderItemsForItemApproval;
        @AuraEnabled
        public List<OrderDestinationItem__c> cometOrderItemsForMaxOrdQtyApproval;
        public CometOrderApprovalWrapper (OrderDestination__c cometOrder,List<OrderDestinationItem__c> cometOrderItemsForItemApproval,List<OrderDestinationItem__c> cometOrderItemsForMaxOrdQtyApproval)
        {
            this.cometOrder=cometOrder;
            this.cometOrderItemsForItemApproval=cometOrderItemsForItemApproval;
            this.cometOrderItemsForMaxOrdQtyApproval=cometOrderItemsForMaxOrdQtyApproval;
        }
    }
    @AuraEnabled
    public static List<Shipping_Method__c> loadShippingMethodList()
    {
        Account objAccount=getAccount();
        return [SELECT Name, Shipping_Method_Name__c, Active__c, Account__c, DisplayOrder__c, ApprovalRequired__c FROM Shipping_Method__c WHERE Account__C =:objAccount.ID AND ApprovalRequired__c = true ORDER BY Shipping_Method_Name__c];
    }
    @AuraEnabled
    public static List<CometOrderApprovalWrapper> approveShippingMethod (OrderDestination__c cometOrder) {
        try {
            cometOrder.ShipMethodApproved__c=true;
            cometOrder.ShipMethod_App_Or_Rej_By__c= UserInfo.getUserId();
            cometOrder.ShipMethod_App_Or_Rej_On__c= System.now();
            
            update cometOrder;
        }
        catch(Exception ex) {
            DFVEmailNotifications.sendNotification('Approval Method',ex.getMessage()+'\n'+'Inputs are -- cometOrder-- '+JSON.serialize(cometOrder)
                                                   +'\n'+'Class Name - DFVApprovalOrderController '+'-- Line number --'+ex.getLineNumber());
        }
        return checkForApprovalsAndSendToComet(cometOrder.Id);
    }
    public static Boolean checkOrderForApprovals (Id cometOrderId) {
            List<OrderDestination__c> cometOrders = [SELECT Id FROM OrderDestination__c WHERE Id=:cometOrderId 
            AND 
            Id IN (SELECT OrderDestination__c FROM OrderDestinationItem__c WHERE (ItemAppReq__c= true AND ItemApproved__c=false 
                                                                                AND ItemRejected__c= false)
                OR (MaxOrderAppReq__c= true AND MaxOrderApproved__c=false AND MaxOrderRejected__c= false) )
                                        ];
        System.debug('checkOrderForApprovals'+cometOrders.isEmpty());
        return cometOrders.isEmpty();
    }
    public static CometOrderApprovalWrapper getApprovalList (Id cometOrderId) {
        Account objAccount=getAccount();
        List<CometOrderApprovalWrapper> approvalOrders=new List<CometOrderApprovalWrapper> ();
        // return [SELECT Id,SelectedShippingMethod__r.Shipping_Method_Name__c,(SELECT Id FROM OrderDestinationItems__r WHERE Quantity__c>0),ShippingMethodRejeted__c,ShipMethAppReq__c,AddressBook__r.Shipto_Name__c,AddressBook__r.Address__c, CreatedDate, Order__r.Order_Confirmation_Date__c,Order__r.Account__c, CreatedBy.Name, OrderName__c, Order__r.Name,  Shipping_Method__r.Shipping_Method_Name__c, AddressBook__r.Shipto_Company__c, AddressBook__r.City__c , ShipMethodApproved__c 
        //         FROM OrderDestination__c WHERE Order__r.Account__c=:objAccount.Id AND OrdStatus__c='Needs Approval' AND Id IN (SELECT OrderDestination__c FROM OrderDestinationItem__c WHERE Quantity__c>0)];
        for(OrderDestination__c cometOrder : [SELECT Id,ShipMethAppReq__c,Shipping_Method__c,SelectedShippingMethod__r.Shipping_Method_Name__c,
                                              All_Approvals_Cleared__c,ShippingMethodRejeted__c,AddressBook__r.Shipto_Name__c,
                                              AddressBook__r.Address__c, CreatedDate, Order__r.Order_Confirmation_Date__c,Order__r.Account__c, 
                                              CreatedBy.Name, OrderName__c, Order__r.Name,Order__r.Account__r.Name, 
                                              Shipping_Method__r.Shipping_Method_Name__c, AddressBook__r.Shipto_Company__c, AddressBook__r.City__c , 
                                              ShipMethodApproved__c,Comet_Order_Status__c,(SELECT Id,ItemAppReq__c,SelectedQuantity__c,OrderDestination__r.ShipMethAppReq__c,Pos_Item__r.Logical_Invenory_Stock__c,
                                                                                           MaxOrderRejected__c,OrderDestination__r.ShipMethodApproved__c,OrderDestination__r.ShippingMethodRejeted__c,
                                                                                           OrderDestination__r.Shipping_Method__r.ApprovalRequired__c,POS_Item__r.Item_No__c,OrderDestination__c,
                                                                                           ItemApproved__c,OrderDestination__r.CreatedBy.Id,OrderDestination__r.AddressBook__r.Address__c,
                                                                                           OrderDestination__r.AddressBook__r.Shipto_Name__c, CreatedDate,ItemRejected__c, 
                                                                                           OrderDestination__r.Order__r.Order_Confirmation_Date__c, OrderDestination__r.Order__r.Account__c, 
                                                                                           CreatedBy.Name, ItemName__c, OrderDestination__r.OrderName__c, OrderDestination__r.Order__r.Name,
                                                                                           POS_Item__r.Item_Name__c, POS_Item__r.Maximum_Order_Qty__c,POS_Item__r.Available_Stock__c, 
                                                                                           Quantity__c, POS_Item__r.Brand__r.Brand_Name__c, POS_Item__r.Pack_Of__c, POS_Item__r.Price__c, 
                                                                                           MaxOrderApproved__c, MaxOrderAppReq__c, OrderDestination__r.AddressBook__r.Shipto_Company__c, 
                                                                                           OrderDestination__r.AddressBook__r.City__c  
                                                                                           FROM OrderDestinationItems__r 
                                                                                           WHERE Quantity__c>0 AND Quantity__c!=null) 
                                              FROM OrderDestination__c WHERE Order__r.Account__c=:objAccount.Id AND OrdStatus__c='Needs Approval' 
                                              AND Id=:cometOrderId AND Id IN 
                                              (SELECT OrderDestination__c FROM OrderDestinationItem__c WHERE Quantity__c>0 )])
        {
            List<OrderDestinationItem__c> cometOrderItemsForItemApproval=new List<OrderDestinationItem__c> ();
            List<OrderDestinationItem__c> cometOrderItemsForMaxOrdQtyApproval=new List<OrderDestinationItem__c> ();
            for(OrderDestinationItem__c cometOrderItem : cometOrder.OrderDestinationItems__r)
            {
                if(cometOrderItem.ItemAppReq__c && !cometOrderItem.ItemApproved__c && !cometOrderItem.ItemRejected__c)
                    cometOrderItemsForItemApproval.add(cometOrderItem);
                if(cometOrderItem.MaxOrderAppReq__c && !cometOrderItem.MaxOrderApproved__c && !cometOrderItem.MaxOrderRejected__c)
                    cometOrderItemsForMaxOrdQtyApproval.add(cometOrderItem);
                
            }
            approvalOrders.add(new CometOrderApprovalWrapper(cometOrder,cometOrderItemsForItemApproval,cometOrderItemsForMaxOrdQtyApproval));
        }
        return approvalOrders[0];
    }
    public static List<CometOrderApprovalWrapper> sendToCometApprovalOrder(Id cometOrderId) {
        try {
            List<CometOrderApprovalWrapper> approvalOrders=new List<CometOrderApprovalWrapper> ();
            List<OrderDestination__c> cometOrders = [SELECT Id,OrdStatus__c,OrderName__c, (SELECT Id FROM OrderDestinationItems__r WHERE Quantity__c>0 AND Quantity__c!=null) FROM OrderDestination__c WHERE Id=:cometOrderId];
            if(cometOrders[0].OrdStatus__c== 'Needs Approval') {
                cometOrders[0].All_Approvals_Cleared__c=true;
                if(cometOrders[0].OrderDestinationItems__r.isEmpty()) {
                    cometOrders[0].Comet_Order_Status__c='Rejected';
                }
                else
                {
                    cometOrders[0].Comet_Order_Status__c='Send to Comet';
                }
                update cometOrders[0];
                
            }
            approvalOrders.add(new  CometOrderApprovalWrapper(cometOrders[0],new List<OrderDestinationItem__c>(),new List<OrderDestinationItem__c>()));
            approvalOrders.addAll(loadAllCometApprovalOrders());
            //return new  CometOrderApprovalWrapper(cometOrders[0],new List<OrderDestinationItem__c>(),new List<OrderDestinationItem__c>());
            return approvalOrders;
        }
        catch(Exception ex) {
            DFVEmailNotifications.sendNotification('Sending Comet Order For Approval',ex.getMessage()+'\n'+'Inputs are -- cometOrderId-- '+JSON.serialize(cometOrderId)
                                                   +'\n'+'Class Name - DFVApprovalOrderController '+'-- Line number --'+ex.getLineNumber());
            
            return new List<CometOrderApprovalWrapper>();
        }
        
    }
    @AuraEnabled
    public static List<CometOrderApprovalWrapper> rejectShippingMethod (OrderDestination__c cometOrder) {
        try {
            List<OrderDestinationItem__c> cometOrderItems = new List<OrderDestinationItem__c>();
            List<CometOrderApprovalWrapper> approvalOrders=new List<CometOrderApprovalWrapper> ();
            for (OrderDestinationItem__c cometOrderItem : [SELECT Id,ItemAppReq__c,MaxOrderAppReq__c,Quantity__c 
                                                           FROM OrderDestinationItem__c WHERE OrderDestination__c=:cometOrder.Id AND Quantity__c>0] )
            {
                cometOrderItem.Quantity__c=0;
                if(cometOrderItem.ItemAppReq__c)  {
                    cometOrderItem.ItemRejected__c=true;
                    cometOrderItem.Item_Approved_Or_Rejected_By__c= UserInfo.getUserId();
                    cometOrderItem.Item_Approved_Or_Rejected_On__c= System.now();
                }
                if(cometOrderItem.MaxOrderAppReq__c) {
                    cometOrderItem.MaxOrderRejected__c=true;
                    cometOrderItem.Max_Ord_Qty_Approved_Or_Rejected_By__c= UserInfo.getUserId();
                    cometOrderItem.Max_Ord_Qty_Approved_Or_Rejected_On__c= System.now();
                }
                cometOrderItems.add(cometOrderItem);
            }
            update cometOrderItems;
            cometOrder.Comet_Order_Status__c='Rejected due to choice of Shipping method';
            cometOrder.ShippingMethodRejeted__c=true;
            cometOrder.ShipMethod_App_Or_Rej_By__c= UserInfo.getUserId();
            cometOrder.ShipMethod_App_Or_Rej_On__c= System.now();
            update cometOrder;
            approvalOrders.add(new CometOrderApprovalWrapper(cometOrder,new List<OrderDestinationItem__c>(),new List<OrderDestinationItem__c>()));
            approvalOrders.addAll(loadAllCometApprovalOrders());
            return approvalOrders;
        }
        catch(Exception ex) {
            DFVEmailNotifications.sendNotification('Rejecting Shipping Method',ex.getMessage()+'\n'+'Inputs are -- cometOrder-- '+JSON.serialize(cometOrder)
                                                   +'\n'+'Class Name - DFVApprovalOrderController '+'-- Line number --'+ex.getLineNumber());
            return new List<CometOrderApprovalWrapper>();
        }
        
    }
    @AuraEnabled
    public static List<CometOrderApprovalWrapper> approveOrderedItem (OrderDestinationItem__c cometOrderItem) {
        try{
            cometOrderItem.ItemApproved__c=true;
            cometOrderItem.Item_Approved_Or_Rejected_By__c= UserInfo.getUserId();
            cometOrderItem.Item_Approved_Or_Rejected_On__c= System.now();
            update cometOrderItem;
        }
        catch(Exception ex) {
            DFVEmailNotifications.sendNotification('Approving an Item',ex.getMessage()+'\n'+'Inputs are -- cometOrderItem-- '+JSON.serialize(cometOrderItem)
                                                   +'\n'+'Class Name - DFVApprovalOrderController '+'-- Line number --'+ex.getLineNumber());
            
        }
        return  checkForApprovalsAndSendToComet(cometOrderItem.OrderDestination__c);     
    }
    @AuraEnabled
    public static List<CometOrderApprovalWrapper> rejectOrderedItem (OrderDestinationItem__c cometOrderItem) {
        try {
            cometOrderItem.Quantity__c=0;
            cometOrderItem.ItemRejected__c=true;
            cometOrderItem.Item_Approved_Or_Rejected_By__c= UserInfo.getUserId();
            cometOrderItem.Item_Approved_Or_Rejected_On__c= System.now();
            if(cometOrderItem.MaxOrderAppReq__c) {
                cometOrderItem.MaxOrderRejected__c=true;
                cometOrderItem.Max_Ord_Qty_Approved_Or_Rejected_By__c= UserInfo.getUserId();
                cometOrderItem.Max_Ord_Qty_Approved_Or_Rejected_On__c= System.now();
            }
            update cometOrderItem;
        }
        catch(Exception ex) {
            DFVEmailNotifications.sendNotification('Rejecting Ordered Item',ex.getMessage()+'\n'+'Inputs are -- cometOrderItem-- '+JSON.serialize(cometOrderItem)
                                                   +'\n'+'Class Name - DFVApprovalOrderController '+'-- Line number --'+ex.getLineNumber());
        }
        return  checkForApprovalsAndSendToComet(cometOrderItem.OrderDestination__c);        
    }
    @AuraEnabled
    public static List<CometOrderApprovalWrapper> approveMaximumOrderQuantity(OrderDestinationItem__c cometOrderItem) {
        try {
            cometOrderItem.MaxOrderApproved__c=true;
            cometOrderItem.Max_Ord_Qty_Approved_Or_Rejected_By__c= UserInfo.getUserId();
            cometOrderItem.Max_Ord_Qty_Approved_Or_Rejected_On__c= System.now();
            update cometOrderItem;
        }
        catch(Exception ex) {
            DFVEmailNotifications.sendNotification('Approve Maximum Order Quantity',ex.getMessage()+'\n'+'Inputs are -- cometOrderItem-- '+JSON.serialize(cometOrderItem)
                                                   +'\n'+'Class Name - DFVApprovalOrderController '+'-- Line number --'+ex.getLineNumber());
        }
        return  checkForApprovalsAndSendToComet(cometOrderItem.OrderDestination__c);        
    }
    @AuraEnabled
    public static List<CometOrderApprovalWrapper> rejectMaximumOrderQuantity (OrderDestinationItem__c cometOrderItem) {
        try{
            cometOrderItem.Quantity__c=0;      
            cometOrderItem.MaxOrderRejected__c=true;
            cometOrderItem.Max_Ord_Qty_Approved_Or_Rejected_By__c= UserInfo.getUserId();
            cometOrderItem.Max_Ord_Qty_Approved_Or_Rejected_On__c= System.now();
            update cometOrderItem;
        }
        catch(Exception ex) {
            DFVEmailNotifications.sendNotification('Reject Maximum Order Quantity',ex.getMessage()+'\n'+'Inputs are -- cometOrderItem-- '+JSON.serialize(cometOrderItem)
                                                   +'\n'+'Class Name - DFVApprovalOrderController '+'-- Line number --'+ex.getLineNumber());
        }
        return  checkForApprovalsAndSendToComet(cometOrderItem.OrderDestination__c);       
    }
    public static List<CometOrderApprovalWrapper> checkForApprovalsAndSendToComet (Id cometOrderId) {
        System.debug('Before If Condition----->'+cometOrderId);
        if(!checkOrderForApprovals(cometOrderId))
        {
            return new List<CometOrderApprovalWrapper>{getApprovalList(cometOrderId)};         
                }
        else {
            return sendToCometApprovalOrder(cometOrderId);
        }
    }
}