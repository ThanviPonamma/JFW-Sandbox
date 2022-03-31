/**Authors: TP,VM Date: 08/01/2021
 * Aim: 1 - To load the comet orders for approval and shipping method list
		2- To approve or reject the comet order based on shipping method,item approval and max order quantity*/
public class WilsonManageApproval_Apex {
    // Declare a variable to hold the Wilson Daniels account details of type Account sObject
    public static Account objAccount;
    @AuraEnabled
    //To fetch account details
    public static Account getAccount() { 
        if(Test.isRunningTest())
        {
            //Fetch account id , name from account for Wilson Daniels
            objAccount=[SELECT Id, Name FROM Account
                        WHERE Name LIKE '%Wilson Daniels%' LIMIT 1];
        }
        else
        {
            objAccount=[SELECT Id, Name FROM Account
            			 WHERE Lightning_Community_Id__c=:Network.getNetworkId() LIMIT 1];
        }
        return objAccount;
    }
    //Aim : to get all comet approval orders
    @AuraEnabled(cacheable = true)
    public static List<CometOrderApprovalWrapper> loadAllCometApprovalOrders()
    {
        //fetch account details
        Account objAccount=getAccount();
        //create an instance of the wrapper class CometOrderApprovalWrapper and store it in the variable approvalOrders of type List of CometOrderApprovalWrapper
        List<CometOrderApprovalWrapper> approvalOrders=new List<CometOrderApprovalWrapper> ();
        //for all the order destination held by a variable cometOrder of type order destination, fetch all the details from sObject order destination that requires approval
        //order destination items that require shipping method approval
        for(OrderDestination__c cometOrder : [SELECT Id,ShipMethAppReq__c,Shipping_Method__c,SelectedShippingMethod__r.Shipping_Method_Name__c,All_Approvals_Cleared__c,ShippingMethodRejeted__c,AddressBook__r.Shipto_Name__c,
                                              AddressBook__r.Address__c, CreatedDate, Order__r.Order_Confirmation_Date__c,Order__r.Account__c, 
                                              CreatedBy.Name, OrderName__c, Order__r.Name,Order__r.Account__r.Name, 
                                              Shipping_Method__r.Shipping_Method_Name__c, AddressBook__r.Shipto_Company__c, AddressBook__r.City__c , 
                                              ShipMethodApproved__c,Comet_Order_Status__c,(SELECT Id,ItemAppReq__c,SelectedQuantity__c,OrderDestination__r.ShipMethAppReq__c,Pos_Item__r.Logical_Invenory_Stock__c,MaxOrderRejected__c,OrderDestination__r.ShipMethodApproved__c,OrderDestination__r.ShippingMethodRejeted__c,
                                                                                           OrderDestination__r.Shipping_Method__r.ApprovalRequired__c,POS_Item__r.Item_No__c,OrderDestination__c,
                                                                                           ItemApproved__c,OrderDestination__r.CreatedBy.Id,OrderDestination__r.AddressBook__r.Address__c,
                                                                                           OrderDestination__r.AddressBook__r.Shipto_Name__c, CreatedDate,ItemRejected__c, 
                                                                                           OrderDestination__r.Order__r.Order_Confirmation_Date__c, OrderDestination__r.Order__r.Account__c, 
                                                                                           CreatedBy.Name, ItemName__c, OrderDestination__r.OrderName__c, OrderDestination__r.Order__r.Name,
                                                                                           POS_Item__r.Item_Name__c, POS_Item__r.Maximum_Order_Qty__c,POS_Item__r.Available_Stock__c, 
                                                                                           Quantity__c, POS_Item__r.Brand__r.Brand_Name__c, POS_Item__r.Pack_Of__c, POS_Item__r.Price__c, 
                                                                                           MaxOrderApproved__c, MaxOrderAppReq__c, OrderDestination__r.AddressBook__r.Shipto_Company__c, 
                                                                                           OrderDestination__r.AddressBook__r.City__c  FROM OrderDestinationItems__r WHERE Quantity__c>0 AND Quantity__c!=null) 
                                              FROM OrderDestination__c WHERE Order__r.Account__c=:objAccount.Id AND 
                                              OrdStatus__c='Needs Approval' 
                                              AND Id IN (SELECT OrderDestination__c FROM OrderDestinationItem__c WHERE Quantity__c>0
                                                         AND ((OrderDestination__r.ShipMethAppReq__c=true 
                                                               AND OrderDestination__r.ShippingMethodRejeted__c=false 
                                                               AND OrderDestination__r.ShipMethodApproved__c=false)
                                                              OR (ItemAppReq__c=true AND ItemApproved__c=false AND ItemRejected__c=false)
                                                              OR (MaxOrderAppReq__c=true AND MaxOrderApproved__c=false AND MaxOrderRejected__c=false)))])
        {
            System.debug('cometOrder--->'+cometOrder.Id);
            //create an instace of the sObject order destination item and store in a variable cometOrderItemsForItemApproval of type list of the sObject OrderDestinationItem__c
            List<OrderDestinationItem__c> cometOrderItemsForItemApproval=new List<OrderDestinationItem__c> ();
            //create an instace of the wrapper class CometItemsForMaxOrdQtyApprovalWithQuantityDisable and store in a variable cometOrderItemsForMaxOrdQtyApproval 
            //of type list of the wrapper class CometItemsForMaxOrdQtyApprovalWithQuantityDisable
            List<CometItemsForMaxOrdQtyApprovalWithQuantityDisable>  cometOrderItemsForMaxOrdQtyApproval=new List<CometItemsForMaxOrdQtyApprovalWithQuantityDisable>();
            //for all the sObject OrderDestinationItem__c held by the variable cometOrderItem
            for(OrderDestinationItem__c cometOrderItem : cometOrder.OrderDestinationItems__r)
            {
                //check if the approval for item is required, if the item needs approval and if the item is rejected
                if(cometOrderItem.ItemAppReq__c && !cometOrderItem.ItemApproved__c && !cometOrderItem.ItemRejected__c)
                    //if the item requires approval, if the item is not approved and if the item is not rejected
                    //add the item to the variable cometOrderItemsForItemApproval
                    cometOrderItemsForItemApproval.add(cometOrderItem);
                //check if the item required max order quantity approval, if the max order quantity is approved and max order quantity is rejected
                if(cometOrderItem.MaxOrderAppReq__c && !cometOrderItem.MaxOrderApproved__c && !cometOrderItem.MaxOrderRejected__c){
                    //if the item requires max order quantity approval, if the max order quantity is is not approved and if the max order quantity is is not rejected
                    //add the item to cometOrderItemsForMaxOrdQtyApproval which is of type wrapper class CometItemsForMaxOrdQtyApprovalWithQuantityDisable with the value false
                    cometOrderItemsForMaxOrdQtyApproval.add(new CometItemsForMaxOrdQtyApprovalWithQuantityDisable(cometOrderItem,false));
                    
                }   
            }
            // cometOrderItemsForMaxOrdQtyApproval.add(cometItemWithQuantity);
            //add the variables cometOrder,cometOrderItemsForItemApproval, cometOrderItemsForMaxOrdQtyApproval, true value if cometOrderItemsForItemApproval size is greater than zero else false, true value if cometOrderItemsForMaxOrdQtyApproval size is greater than zero else false
            approvalOrders.add(new CometOrderApprovalWrapper(cometOrder,cometOrderItemsForItemApproval,cometOrderItemsForMaxOrdQtyApproval,cometOrderItemsForItemApproval.size()>0?true:false,cometOrderItemsForMaxOrdQtyApproval.size()>0?true:false));
        }
        System.debug('approvalOrders--->'+approvalOrders);
        System.debug('approvalOrders--->'+approvalOrders.size());
        //return approvalOrders
        return approvalOrders;
    }
    //Aim : wrapper class to hold a variable of type OrderDestinationItem__c and another variable of type boolean. 
    //used by the wrapper class CometOrderApprovalWrapper
    public class CometItemsForMaxOrdQtyApprovalWithQuantityDisable
    {
        @AuraEnabled
        //variable of type sObject OrderDestinationItem__c to hold the ordered items that requires max order quantity approval
        public OrderDestinationItem__c cometOrderItemsForMaxOrdQtyApproval;
        @AuraEnabled
        //boolean value to disable the quantity field
        public Boolean isdisableQuantity;
        //constructor of the wrapper class CometItemsForMaxOrdQtyApprovalWithQuantityDisable
        public CometItemsForMaxOrdQtyApprovalWithQuantityDisable (OrderDestinationItem__c cometOrderItemsForMaxOrdQtyApproval,Boolean isdisableQuantity)
        {
            this.cometOrderItemsForMaxOrdQtyApproval=cometOrderItemsForMaxOrdQtyApproval;
            this.isdisableQuantity=isdisableQuantity;
        }
    }
    //Aim: Wrapper class to hold the variables of type OrderDestination__c, list of OrderDestinationItem__c, 
    //boolean and list of CometItemsForMaxOrdQtyApprovalWithQuantityDisable
    //used by the methods loadAllCometApprovalOrders, getApprovalList, sendToCometApprovalOrder
    //rejectShippingMethod, approveOrderedItem, rejectOrderedItem, approveMaximumOrderQuantity
    //rejectMaximumOrderQuantity and checkForApprovalsAndSendToComet
    public class CometOrderApprovalWrapper
    {
        @AuraEnabled
        //variable to hold the data of the sObject OrderDestination__c
        public OrderDestination__c cometOrder;
        @AuraEnabled
        //variable to hold the data of the sObject list of OrderDestinationItem__c
        public List<OrderDestinationItem__c> cometOrderItemsForItemApproval;
        @AuraEnabled
        //variable to hold boolean value for the items items that requires approval
        public Boolean isCometOrderItemsForApprovalExists;
        @AuraEnabled
        //variable to hold the variable of type list of wrapper class CometItemsForMaxOrdQtyApprovalWithQuantityDisable
        public List<CometItemsForMaxOrdQtyApprovalWithQuantityDisable> cometOrderItemsForMaxOrdQtyApprovalWithQuantityDisable;
        @AuraEnabled
        //variable to hold the boolean value for the item if it requires max order quantity
        public Boolean isCometOrderItemsForMaxOrdQtyApprovalExists;
        //constructor of the wrapper class CometOrderApprovalWrapper with all the variables as parameter
        public CometOrderApprovalWrapper (OrderDestination__c cometOrder,List<OrderDestinationItem__c> cometOrderItemsForItemApproval,List<CometItemsForMaxOrdQtyApprovalWithQuantityDisable> cometOrderItemsForMaxOrdQtyApprovalWithQuantityDisable,Boolean isCometOrderItemsForApprovalExists,Boolean isCometOrderItemsForMaxOrdQtyApprovalExists)
        {
            this.cometOrder=cometOrder;
            this.cometOrderItemsForItemApproval=cometOrderItemsForItemApproval;
            this.cometOrderItemsForMaxOrdQtyApprovalWithQuantityDisable=cometOrderItemsForMaxOrdQtyApprovalWithQuantityDisable;
            this.isCometOrderItemsForApprovalExists = isCometOrderItemsForApprovalExists;
            this.isCometOrderItemsForMaxOrdQtyApprovalExists = isCometOrderItemsForMaxOrdQtyApprovalExists;
        }
        //constructor of the wrapper class CometOrderApprovalWrapper with the variables cometOrder
        //cometOrderItemsForItemApproval and isCometOrderItemsForMaxOrdQtyApprovalExists as parameters
        public CometOrderApprovalWrapper (OrderDestination__c cometOrder,List<OrderDestinationItem__c> cometOrderItemsForItemApproval,List<CometItemsForMaxOrdQtyApprovalWithQuantityDisable> cometOrderItemsForMaxOrdQtyApprovalWithQuantityDisable)
        {
            this.cometOrder=cometOrder;
            this.cometOrderItemsForItemApproval=cometOrderItemsForItemApproval;
            this.cometOrderItemsForMaxOrdQtyApprovalWithQuantityDisable=cometOrderItemsForMaxOrdQtyApprovalWithQuantityDisable;
        }
    }
    //Aim: to load all shipping method list
    @AuraEnabled(cacheable = true)    
    public static List<Shipping_Method__c> loadShippingMethodList()
    {
        //to hold the account details
        Account objAccount=getAccount();
        //return variable shippingMethodlist of type list of shipping methods of the account Wilson Daniels and the list is ordered in the ascending order of the shipping method
        List<Shipping_Method__c> shippingMethodlist = [SELECT Name, Shipping_Method_Name__c, Active__c, Account__c, DisplayOrder__c, ApprovalRequired__c FROM Shipping_Method__c WHERE Account__C =:objAccount.ID AND ApprovalRequired__c = true ORDER BY Shipping_Method_Name__c];
        system.debug('shippingMethodlist----->'+shippingMethodlist);
        return shippingMethodlist;
    }
    
    //Aim: To approve shipping method
    @AuraEnabled
    public static List<CometOrderApprovalWrapper> approveShippingMethod (OrderDestination__c cometOrder) {
        try {
            System.debug('cometOrder in approve shipping method----->'+cometOrder);
            //approve the shipping method of the incoming order destination by the assigning true value to the field ShipMethodApproved__c
            cometOrder.ShipMethodApproved__c=true;
            //assign the logged in user name to the field ShipMethod_App_Or_Rej_By__c
            cometOrder.ShipMethod_App_Or_Rej_By__c= UserInfo.getUserId();
            //assign the current time to the field ShipMethod_App_Or_Rej_On__c
            cometOrder.ShipMethod_App_Or_Rej_On__c= System.now();
            system.debug('cometOrder that needs to be approved----->'+cometOrder);
            //update the variable cometOrder
            update cometOrder;
        }
        catch(Exception ex) {
            //if an exception is encountered while updating an order destination, an email is sent
            WilsonEmailNotifications.sendNotification('Approval Method',ex.getMessage()+'\n'+'Inputs are -- cometOrder-- '+JSON.serialize(cometOrder)
                                                   +'\n'+'Class Name - WilsonManageApproval_Apex '+'-- Line number --'+ex.getLineNumber());
        }
        //to invoke the method checkForApprovalsAndSendToComet with the comet order ID
        return checkForApprovalsAndSendToComet(cometOrder.Id);
    }
    //Aim: To check if the order needs approval
    public static Boolean checkOrderForApprovals (Id cometOrderId) {
        //declare a variable of type list of sObject OrderDestination__c to hold the list of
        //order destination and its order destination items that requires approval, items that have not yet approved and have not been rejected 
        //or items that require max order quantity approval and whose max order quantity is not approved/ rejected
        List<OrderDestination__c> cometOrders = [SELECT Id FROM OrderDestination__c WHERE Id=:cometOrderId 
                                                 AND 
                                                 Id IN (SELECT OrderDestination__c FROM OrderDestinationItem__c WHERE (ItemAppReq__c= true AND ItemApproved__c=false 
                                                                                                                       AND ItemRejected__c= false)
                                                        OR (MaxOrderAppReq__c= true AND MaxOrderApproved__c=false AND MaxOrderRejected__c= false) )
                                                ];
        System.debug('checkOrderForApprovals'+cometOrders);
        System.debug('checkOrderForApprovals'+cometOrders.isEmpty());
        //return true/false based on the data held by the variable cometOrders
        return cometOrders.isEmpty();
    }
    //Aim: to get all the order destination items that needs approval
    public static CometOrderApprovalWrapper getApprovalList (Id cometOrderId) {
        //to hold the account details
        Account objAccount=getAccount();
        //declare a variable approvalOrders of type list of wrapper class CometOrderApprovalWrapper
        List<CometOrderApprovalWrapper> approvalOrders=new List<CometOrderApprovalWrapper> ();
        //for all the order destinations held by the variable cometOrder fetch order destination and 
        //order destination items that requires approval 
        for(OrderDestination__c cometOrder : [SELECT Id,ShipMethAppReq__c,Shipping_Method__c,SelectedShippingMethod__r.Shipping_Method_Name__c,All_Approvals_Cleared__c,ShippingMethodRejeted__c,AddressBook__r.Shipto_Name__c,
                                              AddressBook__r.Address__c, CreatedDate, Order__r.Order_Confirmation_Date__c,Order__r.Account__c, 
                                              CreatedBy.Name, OrderName__c, Order__r.Name,Order__r.Account__r.Name, 
                                              Shipping_Method__r.Shipping_Method_Name__c, AddressBook__r.Shipto_Company__c, AddressBook__r.City__c , 
                                              ShipMethodApproved__c,Comet_Order_Status__c,(SELECT Id,ItemAppReq__c,SelectedQuantity__c,OrderDestination__r.ShipMethAppReq__c,Pos_Item__r.Logical_Invenory_Stock__c,MaxOrderRejected__c,OrderDestination__r.ShipMethodApproved__c,OrderDestination__r.ShippingMethodRejeted__c,OrderDestination__r.Shipping_Method__r.ApprovalRequired__c,POS_Item__r.Item_No__c,OrderDestination__c,ItemApproved__c,OrderDestination__r.CreatedBy.Id,OrderDestination__r.AddressBook__r.Address__c,OrderDestination__r.AddressBook__r.Shipto_Name__c, CreatedDate,ItemRejected__c, OrderDestination__r.Order__r.Order_Confirmation_Date__c, OrderDestination__r.Order__r.Account__c, 
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
            //declare a variable cometOrderItemsForItemApproval of type list of OrderDestinationItem__c
            List<OrderDestinationItem__c> cometOrderItemsForItemApproval=new List<OrderDestinationItem__c> ();
            //declare a variable cometOrderItemsForMaxOrdQtyApproval of type list wrapper class CometItemsForMaxOrdQtyApprovalWithQuantityDisable
            List<CometItemsForMaxOrdQtyApprovalWithQuantityDisable> cometOrderItemsForMaxOrdQtyApproval=new List<CometItemsForMaxOrdQtyApprovalWithQuantityDisable> ();
            //for all the order destination held by the variable cometOrderItem 
            for(OrderDestinationItem__c cometOrderItem : cometOrder.OrderDestinationItems__r)
            {
                //if the item requires approval, if the item is not approved and if the item is not rejected
                //add the item to the variable cometOrderItemsForItemApproval
                if(cometOrderItem.ItemAppReq__c && !cometOrderItem.ItemApproved__c && !cometOrderItem.ItemRejected__c)
                    cometOrderItemsForItemApproval.add(cometOrderItem);
                //if the item requires max order quantity approval, if the max order quantity is is not approved and if the max order quantity is is not rejected
                //add the item to cometOrderItemsForMaxOrdQtyApproval which is of type wrapper class CometItemsForMaxOrdQtyApprovalWithQuantityDisable with the value false
                if(cometOrderItem.MaxOrderAppReq__c && !cometOrderItem.MaxOrderApproved__c && !cometOrderItem.MaxOrderRejected__c)
                    // cometOrderItemsForMaxOrdQtyApproval.add(cometOrderItem);
                    cometOrderItemsForMaxOrdQtyApproval.add(new CometItemsForMaxOrdQtyApprovalWithQuantityDisable(cometOrderItem,false));
                
            }
            //send the variables cometOrder,cometOrderItemsForItemApproval,cometOrderItemsForMaxOrdQtyApproval to the wrapper class CometOrderApprovalWrapper
            approvalOrders.add(new CometOrderApprovalWrapper(cometOrder,cometOrderItemsForItemApproval,cometOrderItemsForMaxOrdQtyApproval));
        }
        system.debug('approvalOrders----->'+approvalOrders);
        return approvalOrders[0];
    }
    //Aim : To update comet order status and update the comet orders based on conditions
    public static List<CometOrderApprovalWrapper> sendToCometApprovalOrder(Id cometOrderId) {
        try {
            //declare a variable approvalOrders of type list of wrapper class CometOrderApprovalWrapper
            List<CometOrderApprovalWrapper> approvalOrders=new List<CometOrderApprovalWrapper> ();
            //declare a variable of type list of sObject OrderDestination__c to hold the list of order destination and order destination items whose quantity is greater than zero and not equal to null
            List<OrderDestination__c> cometOrders = [SELECT Id,OrdStatus__c,OrderName__c, (SELECT Id FROM OrderDestinationItems__r 
                                                                                           WHERE Quantity__c>0 AND Quantity__c!=null) 
                                                     FROM OrderDestination__c WHERE Id=:cometOrderId];
            //check if the cometOrder needs approval
            if(cometOrders[0].OrdStatus__c== 'Needs Approval') {
                //assign true value to the field All_Approvals_Cleared__c of the cometOrder
                cometOrders[0].All_Approvals_Cleared__c=true;
                //check if the order destination has order destination items
                if(cometOrders[0].OrderDestinationItems__r.isEmpty()) {
                    //assign the string value 'Rejected' to the field Comet_Order_Status__c of the cometOrders
                    cometOrders[0].Comet_Order_Status__c='Rejected';
                }
                ////check if the order destination doesnot have order destination items
                else
                {
                    //assign the string value 'Send to Comet' to the field Comet_Order_Status__c of the cometOrders
                    cometOrders[0].Comet_Order_Status__c='Send to Comet';
                }
                //update the record cometOrders
                update cometOrders[0];
            }
            //add the 0th index of the cometOrders, new isntance of the list of sObject OrderDestinationItem__c
            //and new isntance of the list of the wrapper class CometItemsForMaxOrdQtyApprovalWithQuantityDisable
            approvalOrders.add(new  CometOrderApprovalWrapper(cometOrders[0],new List<OrderDestinationItem__c>(),new List<CometItemsForMaxOrdQtyApprovalWithQuantityDisable>()));
            //add the result of the method loadAllCometApprovalOrders to the variable approvalOrders
            approvalOrders.addAll(loadAllCometApprovalOrders());
            system.debug('approvalOrders------>'+approvalOrders);
            //return approvalOrders
            return approvalOrders;
        }
        catch(Exception ex) {
            //if an exception is encountered while updating an order destination, an email is sent
            WilsonEmailNotifications.sendNotification('Sending Comet Order For Approval',ex.getMessage()+'\n'+'Inputs are -- cometOrderId-- '+JSON.serialize(cometOrderId)
                                                   +'\n'+'Class Name - WilsonManageApproval_Apex '+'-- Line number --'+ex.getLineNumber());
            
            return new List<CometOrderApprovalWrapper>();
        }
        
    }
    //Aim : To reject the shipping method and update comet order status
    @AuraEnabled
    public static List<CometOrderApprovalWrapper> rejectShippingMethod (OrderDestination__c cometOrder) {
        try {
            System.debug('CometOrder in reject method-->' +cometOrder);
            //declare a variable cometOrderItems of type list of the sObject OrderDestinationItem__c
            List<OrderDestinationItem__c> cometOrderItems = new List<OrderDestinationItem__c>();
            //declare a variable approvalOrders of type list of wrapper class CometOrderApprovalWrapper
            List<CometOrderApprovalWrapper> approvalOrders=new List<CometOrderApprovalWrapper> ();
            //for all the sObject OrderDestinationItem__c declare a variable of type list of sObject OrderDestination__c to hold 
            //the list of order destination and order destination items whose quantity is greater than zero and not equal to null
            for (OrderDestinationItem__c cometOrderItem : [SELECT Id,ItemAppReq__c,MaxOrderAppReq__c,Quantity__c 
                                                           FROM OrderDestinationItem__c WHERE OrderDestination__c=:cometOrder.Id AND Quantity__c>0] )
            {
                //assign the quantity 0
                cometOrderItem.Quantity__c=0;
                //check if the order destination item needs approval
                if(cometOrderItem.ItemAppReq__c)  {
                    //reject the cometOrderItem by assigning true value to the field ItemRejected__c of the cometOrderItem
                    cometOrderItem.ItemRejected__c=true;
                    //assign the logged in user name to the field ShipMethod_App_Or_Rej_By__c
                    cometOrderItem.Item_Approved_Or_Rejected_By__c= UserInfo.getUserId();
                    //assign the current time to the field ShipMethod_App_Or_Rej_On__c
                    cometOrderItem.Item_Approved_Or_Rejected_On__c= System.now();
                }
                if(cometOrderItem.MaxOrderAppReq__c) {
                    //reject the cometOrderItem by assigning true value to the field MaxOrderRejected__c of the cometOrderItem
                    cometOrderItem.MaxOrderRejected__c=true;
                    //assign the logged in user name to the field Max_Ord_Qty_Approved_Or_Rejected_By__c
                    cometOrderItem.Max_Ord_Qty_Approved_Or_Rejected_By__c= UserInfo.getUserId();
                    //assign the current time to the field Max_Ord_Qty_Approved_Or_Rejected_On__c
                    cometOrderItem.Max_Ord_Qty_Approved_Or_Rejected_On__c= System.now();
                }
                //add the data in the variable cometOrderItem to the variable cometOrderItems
                cometOrderItems.add(cometOrderItem);
            }
            //updating cometOrderItems
            update cometOrderItems;
            //assign the string value 'Rejected due to choice of Shipping method' to the field Comet_Order_Status__c of the cometOrder
            cometOrder.Comet_Order_Status__c='Rejected due to choice of Shipping method';
            //reject the shipping method of the cometOrder by assigning true value to the field ShippingMethodRejeted__c of the cometOrder
            cometOrder.ShippingMethodRejeted__c=true;
            //assign the logged in user name to the field ShipMethod_App_Or_Rej_By__c
            cometOrder.ShipMethod_App_Or_Rej_By__c= UserInfo.getUserId();
            //assign the current time to the field ShipMethod_App_Or_Rej_On__c
            cometOrder.ShipMethod_App_Or_Rej_On__c= System.now();
            //update cometOrder record
            update cometOrder;
            //add the 0th index of the cometOrders, new isntance of the list of sObject OrderDestinationItem__c
            //and new isntance of the list of the wrapper class CometItemsForMaxOrdQtyApprovalWithQuantityDisable
            approvalOrders.add(new CometOrderApprovalWrapper(cometOrder,new List<OrderDestinationItem__c>(),new List<CometItemsForMaxOrdQtyApprovalWithQuantityDisable>()));
            //add the result of the method loadAllCometApprovalOrders to the variable approvalOrders
            approvalOrders.addAll(loadAllCometApprovalOrders());
            system.debug('approvalOrders------>'+approvalOrders);
            //return approvalOrders
            return approvalOrders;
        }
        catch(Exception ex) {
            //if an exception is encountered while updating an order destination, an email is sent
            WilsonEmailNotifications.sendNotification('Rejecting Shipping Method',ex.getMessage()+'\n'+'Inputs are -- cometOrder-- '+JSON.serialize(cometOrder)
                                                   +'\n'+'Class Name - WilsonManageApproval_Apex '+'-- Line number --'+ex.getLineNumber());
            return new List<CometOrderApprovalWrapper>();
        }
        
    }
    //Aim : To approve ordered item
    @AuraEnabled
    public static List<CometOrderApprovalWrapper> approveOrderedItem (OrderDestinationItem__c cometOrderItem) {
        try{
            
            System.debug('Comet Order item which are to be approved---->' +cometOrderItem);
            //approve the cometOrderItem  by assigning true value to the field ItemApproved__c of the incoming cometOrderItem
            cometOrderItem.ItemApproved__c=true;
            //assign the logged in user name to the field Item_Approved_Or_Rejected_By__c of the cometOrderItem
            cometOrderItem.Item_Approved_Or_Rejected_By__c= UserInfo.getUserId();
            //assign the current time to the field Item_Approved_Or_Rejected_On__c of the cometOrderItem
            cometOrderItem.Item_Approved_Or_Rejected_On__c= System.now();
            //update the record cometOrderItem
            system.debug('cometOrderItem---->'+cometOrderItem);
            update cometOrderItem;
        }
        catch(Exception ex) {
            //if an exception is encountered while updating an order destination, an email is sent
            WilsonEmailNotifications.sendNotification('Approving an Item',ex.getMessage()+'\n'+'Inputs are -- cometOrderItem-- '+JSON.serialize(cometOrderItem)
                                                   +'\n'+'Class Name - WilsonManageApproval_Apex '+'-- Line number --'+ex.getLineNumber());
            
        }
        System.debug('cometOrderItem.OrderDestination__c'+cometOrderItem.OrderDestination__c);
        //return the sObject OrderDestination__c in cometOrderItem
        return  checkForApprovalsAndSendToComet(cometOrderItem.OrderDestination__c);     
    }
    //To reject the ordered item
    @AuraEnabled
    public static List<CometOrderApprovalWrapper> rejectOrderedItem (OrderDestinationItem__c cometOrderItem) {
        try {
            //make the cometOrderItem quantity 0
            cometOrderItem.Quantity__c=0;
            //reject the cometOrderItem by assigning true value to the field ItemRejected__c of the incoming cometOrderItem
            cometOrderItem.ItemRejected__c=true;
            //assign the logged in user name to the field Item_Approved_Or_Rejected_By__c of the cometOrderItem
            cometOrderItem.Item_Approved_Or_Rejected_By__c= UserInfo.getUserId();
            //assign the current time to the field Item_Approved_Or_Rejected_On__c of the cometOrderItem
            cometOrderItem.Item_Approved_Or_Rejected_On__c= System.now();
            if(cometOrderItem.MaxOrderAppReq__c) {
                //reject the cometOrderItem by assigning true value to the field MaxOrderRejected__c of the cometOrderItem
                cometOrderItem.MaxOrderRejected__c=true;
                //assign the logged in user name to the field Max_Ord_Qty_Approved_Or_Rejected_By__c
                cometOrderItem.Max_Ord_Qty_Approved_Or_Rejected_By__c= UserInfo.getUserId();
                //assign the current time to the field Max_Ord_Qty_Approved_Or_Rejected_On__c
                cometOrderItem.Max_Ord_Qty_Approved_Or_Rejected_On__c= System.now();
            }
            //update the record cometOrderItem
            system.debug('cometOrderItem---->'+cometOrderItem);
            update cometOrderItem;
        }
        catch(Exception ex) {
            //if an exception is encountered while updating an order destination, an email is sent
            WilsonEmailNotifications.sendNotification('Rejecting Ordered Item',ex.getMessage()+'\n'+'Inputs are -- cometOrderItem-- '+JSON.serialize(cometOrderItem)
                                                   +'\n'+'Class Name - WilsonManageApproval_Apex '+'-- Line number --'+ex.getLineNumber());
        }
        System.debug('cometOrderItem.OrderDestination__c'+cometOrderItem.OrderDestination__c);
        //return the sObject OrderDestination__c in cometOrderItem
        return  checkForApprovalsAndSendToComet(cometOrderItem.OrderDestination__c);        
    }
    //Aim : To approve maximum order quantity
    @AuraEnabled
    public static List<CometOrderApprovalWrapper> approveMaximumOrderQuantity(OrderDestinationItem__c cometOrderItem) {
        try {
            //approve the cometOrderItem by assigning true value to the field MaxOrderApproved__c of the cometOrderItem
            cometOrderItem.MaxOrderApproved__c=true;
            //assign the logged in user name to the field Max_Ord_Qty_Approved_Or_Rejected_By__c
            cometOrderItem.Max_Ord_Qty_Approved_Or_Rejected_By__c= UserInfo.getUserId();
            //assign the current time to the field Max_Ord_Qty_Approved_Or_Rejected_On__c
            cometOrderItem.Max_Ord_Qty_Approved_Or_Rejected_On__c= System.now();
            //update the record cometOrderItem
            system.debug('cometOrderItem to be approved for mex order quanity---->'+cometOrderItem);
            update cometOrderItem;
        }
        catch(Exception ex) {
            //if an exception is encountered while updating an order destination, an email is sent
            WilsonEmailNotifications.sendNotification('Approve Maximum Order Quantity',ex.getMessage()+'\n'+'Inputs are -- cometOrderItem-- '+JSON.serialize(cometOrderItem)
                                                   +'\n'+'Class Name - WilsonManageApproval_Apex '+'-- Line number --'+ex.getLineNumber());
        }
        System.debug('cometOrderItem.OrderDestination__c'+cometOrderItem.OrderDestination__c);
        //return the sObject OrderDestination__c in cometOrderItem
        return  checkForApprovalsAndSendToComet(cometOrderItem.OrderDestination__c);        
    }
    //Aim : To reject maximum order quantity
    @AuraEnabled
    public static List<CometOrderApprovalWrapper> rejectMaximumOrderQuantity (OrderDestinationItem__c cometOrderItem) {
        try{
            //make the cometOrderItem quantity 0
            cometOrderItem.Quantity__c=0;     
            //reject the cometOrderItem by assigning true value to the field MaxOrderRejected__c of the cometOrderItem
            cometOrderItem.MaxOrderRejected__c=true;
            //assign the logged in user name to the field Max_Ord_Qty_Approved_Or_Rejected_By__c
            cometOrderItem.Max_Ord_Qty_Approved_Or_Rejected_By__c= UserInfo.getUserId();
            //assign the current time to the field Max_Ord_Qty_Approved_Or_Rejected_On__c
            cometOrderItem.Max_Ord_Qty_Approved_Or_Rejected_On__c= System.now();
            //update the record cometOrderItem
            system.debug('cometOrderItem that has been rejected---->'+cometOrderItem);
            update cometOrderItem;
        }
        catch(Exception ex) {
            //if an exception is encountered while updating an order destination, an email is sent
            WilsonEmailNotifications.sendNotification('Reject Maximum Order Quantity',ex.getMessage()+'\n'+'Inputs are -- cometOrderItem-- '+JSON.serialize(cometOrderItem)
                                                   +'\n'+'Class Name - WilsonManageApproval_Apex '+'-- Line number --'+ex.getLineNumber());
        }
        System.debug('cometOrderItem.OrderDestination__c'+cometOrderItem.OrderDestination__c);
        //return the sObject OrderDestination__c in cometOrderItem
        return  checkForApprovalsAndSendToComet(cometOrderItem.OrderDestination__c);       
    }
    
    
    //Aim: To check for approvals and to call the method sendToCometApprovalOrder
    public static List<CometOrderApprovalWrapper> checkForApprovalsAndSendToComet (Id cometOrderId) {
        // System.debug('Before If Condition----->'+cometOrderId);
        //check if the checkOrderForApprovals method returns true or false
        if(!checkOrderForApprovals(cometOrderId))
        {
            system.debug('items exist for approval' );           
            //if true, get the list approvals for the incoming cometOrder Id
            return new List<CometOrderApprovalWrapper>{getApprovalList(cometOrderId)};         
                }
        else {
            system.debug('No more items for approval');
            //if false, invoke the method sendToCometApprovalOrder for the incoming cometOrderId
            return sendToCometApprovalOrder(cometOrderId);
        }
    }
}