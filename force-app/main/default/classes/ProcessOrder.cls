public class ProcessOrder
{
    public string open='Open';
    public string inProcess='In Process';
    public string sendToComet='Send to Comet';
    public string needsApproval = 'Needs Approval';
    public string orderProcessed = 'This Order has been processed';
    public void updateCometOrderFlags(Map<Id,Order__c> oldEmergeOrderMap,Map<Id,Order__c> newEmergeOrderMap)
    {
        //this method is deleting empty comet ords and items.
        deleteEmptyCometOrders(oldEmergeOrderMap, newEmergeOrderMap); 
        
        // This method is calculates Inprocess inventory and holds the same
        manageInprocessInventory(oldEmergeOrderMap, newEmergeOrderMap);
        
        //this method is updating comet order statuses.
        updateApprovalFlags(oldEmergeOrderMap,newEmergeOrderMap);
    }
    
    
    //this method is deleting empty comet ords and items
    public void deleteEmptyCometOrders(Map<Id,Order__c> oldEmergeOrderMap,Map<Id,Order__c> newEmergeOrderMap)
    {
        List<OrderDestinationItem__c> cometOrderItems= new List<OrderDestinationItem__c>();//
        List<OrderDestination__c> cometOrders=new List<OrderDestination__c> ();
        Map<Id,Account> emergeAccounts=new Map<Id,Account> ([SELECT Id,Is_Comet_Rest_Api__c FROM Account WHERE Id IN (SELECT Account__c FROM Order__c WHERE Id IN :newEmergeOrderMap.keySet())]);
        for(Order__c emergeOrder:newEmergeOrderMap.values())
        {
            if((oldEmergeOrderMap.get(emergeOrder.Id).Order_Status__c == open) && (newEmergeOrderMap.get(emergeOrder.Id).Order_Status__c == sendToComet) && emergeAccounts.get(emergeOrder.Account__c).Is_Comet_Rest_Api__c ==true)
            {
                //add empty comet orders and items to list.
                cometOrderItems.addAll([SELECT Id, Name FROM OrderDestinationItem__c WHERE Quantity__C =0 AND OrderDestination__r.Order__c =:emergeOrder.Id]);//
                cometOrders.addAll([SELECT Id,Order__c FROM OrderDestination__c WHERE Order__c  =:emergeOrder.Id AND  Id NOT IN (SELECT OrderDestination__c FROM OrderDestinationItem__c WHERE Quantity__C >0)]);                
            }
        }
        delete cometOrderItems;
        delete cometOrders;
    }
    
    // This method is to handle Inprocess inventory
    public void manageInprocessInventory(Map<Id,Order__c> oldEmergeOrderMap,Map<Id,Order__c> newEmergeOrderMap)
    {
        List<OrderDestination__c> validCometOrders=new List<OrderDestination__c> ([SELECT Id,Order__c FROM OrderDestination__c WHERE Order__c IN :newEmergeOrderMap.keySet() ]);
        List<OrderDestinationItem__c> validCometOrderItems = new List<OrderDestinationItem__c>([SELECT Id, Name, Is_Inventory_Added__c, POS_Item__c,Quantity__c  FROM OrderDestinationItem__c WHERE OrderDestination__r.Order__c IN :newEmergeOrderMap.keySet()]);
        Map<Id,Account> emergeAccounts=new Map<Id,Account> ([SELECT Id,Is_Comet_Rest_Api__c FROM Account WHERE Id IN (SELECT Account__c FROM Order__c WHERE Id IN :newEmergeOrderMap.keySet())]);
        //Map<Id,OrderDestination__c> cometOrdersMap=new Map<Id,OrderDestination__c> ([SELECT Id,(SELECT Id,Pos_Item__c,Quantity__c,ItemName__c,Is_Inventory_Added__c,ItemAppReq__c,MaxOrderAppReq__c,ItemApproved__c,ItemRejected__c,MaxOrderApproved__c,MaxOrderRejected__c FROM OrderDestinationItems__r WHERE Quantity__c >0) FROM OrderDestination__c WHERE Id IN :newEmergeOrderMap.keySet()]);
        Map<Id,Decimal> quantityOrderedforAllCometOrders=new Map<Id,Decimal> ();
        List<OrderDestinationItem__c> cometOrdItems=new List<OrderDestinationItem__c> ();
        List<Pos_Item__c> posItems=new List<Pos_Item__c> ();
        
        
        for(Order__c emergeOrder:newEmergeOrderMap.values())
        {
            if((oldEmergeOrderMap.get(emergeOrder.Id).Order_Status__c == open) && (newEmergeOrderMap.get(emergeOrder.Id).Order_Status__c == sendToComet) && emergeAccounts.get(emergeOrder.Account__c).Is_Comet_Rest_Api__c ==true)
            {
                //String logicalHistory='';
                for(OrderDestinationItem__c cometOrdItm :validCometOrderItems )
                {
                    if(cometOrdItm.Is_Inventory_Added__c==false)
                    {
                        if(quantityOrderedforAllCometOrders.containsKey(cometOrdItm.Pos_Item__c))
                        {
                            Decimal quantity=quantityOrderedforAllCometOrders.get(cometOrdItm.Pos_Item__c);
                            quantityOrderedforAllCometOrders.put(cometOrdItm.Pos_Item__c,quantity+cometOrdItm.Quantity__c);    
                        }else
                        {
                            quantityOrderedforAllCometOrders.put(cometOrdItm.Pos_Item__c,cometOrdItm.Quantity__c);    
                        }  
                        //logicalHistory+='\n'+cometOrdItm.ItemName__c+' ---> '+String.valueOf(cometOrdItm.Quantity__c)+'\n' ;
                        cometOrdItm.Is_Inventory_Added__c=true;
                        cometOrdItems.add(cometOrdItm);
                    }
                }
                //if(od.Logical_Inventory_Histroy__c==null)
                //    od.Logical_Inventory_Histroy__c='';
                //od.Logical_Inventory_Histroy__c+=logicalHistory;
            }
        }  
        
        for(Pos_Item__c posItem:[SELECT Id,InProcess_Inventory_Stock__c FROM Pos_Item__c WHERE Id IN :quantityOrderedforAllCometOrders.keySet()]) 
        {
            if(posItem.InProcess_Inventory_Stock__c==null)
                posItem.InProcess_Inventory_Stock__c=0;
            posItem.InProcess_Inventory_Stock__c+=quantityOrderedforAllCometOrders.get(posItem.Id); 
            posItems.add(posItem);
        }
        
        update cometOrdItems;
        update posItems;
        
    }
    
    public void updateApprovalFlags(Map<Id,Order__c> oldEmergeOrderMap,Map<Id,Order__c> newEmergeOrderMap)
    {
        Map<Id,Order__c> emergeOrderWithCometOrders=new Map<Id,Order__c> ([SELECT Id,(SELECT ShipMethAppReq__c,ShipMethodApproved__c,ShippingMethodRejeted__c FROM OrderDestinations__r  WHERE Id IN (SELECT OrderDestination__c FROM OrderDestinationItem__c WHERE Quantity__c >0)) FROM Order__c WHERE Id IN :newEmergeOrderMap.keySet()]);
        List<OrderDestination__c> cometOrdersList=new List<OrderDestination__c> ();
        Map<Id,Boolean> cometOrderWithApprovalFlags=new Map<Id,Boolean> ();
        Map<Id,Account> emergeAccounts=new Map<Id,Account> ([SELECT Id,Is_Comet_Rest_Api__c FROM Account WHERE Id IN (SELECT Account__c FROM Order__c WHERE Id IN :newEmergeOrderMap.keySet())]);
        //--- This for loop is taking the approval flags from ordDestItems -----//
        for(OrderDestination__c cometOrder:[SELECT Id,(SELECT Id,Quantity__c,Is_Inventory_Added__c,Pos_Item__c,ItemName__c,OrderDestination__r.Order__c,OrderDestination__r.ShipMethAppReq__c,Name,ItemAppReq__c,MaxOrderAppReq__c,ItemApproved__c,ItemRejected__c,MaxOrderApproved__c,MaxOrderRejected__c,OrderDestination__r.ShipMethodApproved__c,OrderDestination__r.ShippingMethodRejeted__c FROM OrderDestinationItems__r WHERE Quantity__C>0) FROM OrderDestination__c WHERE Id IN (SELECT OrderDestination__c FROM OrderDestinationItem__c WHERE Quantity__c>0) AND Order__c IN :newEmergeOrderMap.keySet()])
        {
            Boolean isItemOrMaxOrdQtyApplReq=false;
            for(OrderDestinationItem__c orderItem: cometOrder.OrderDestinationItems__r)
            {
                if(orderItem.ItemAppReq__c==true || orderItem.MaxOrderAppReq__c==true)
                    isItemOrMaxOrdQtyApplReq=true;
            }
            cometOrderWithApprovalFlags.put(cometOrder.Id,isItemOrMaxOrdQtyApplReq);
        }
        
        //this for loop is giving appropriate order stasues to Comet Order.//
        for(Order__c emergeOrder: newEmergeOrderMap.values())
        {
            if(oldEmergeOrderMap.get(emergeOrder.Id).Order_Status__c== open && newEmergeOrderMap.get(emergeOrder.Id).Order_Status__c== sendToComet && emergeAccounts.get(emergeOrder.Account__c).Is_Comet_Rest_Api__c ==true)
            {
                Boolean isShipMethAppReq=false;
                Boolean isItemOrMaxOrdQtyApplReq=false;
                for(OrderDestination__c cometOrder:emergeOrderWithCometOrders.get(emergeOrder.Id).OrderDestinations__r)
                {
                    if((cometOrder.ShipMethAppReq__c == true) || (cometOrderWithApprovalFlags.get(cometOrder.Id) == true) )
                        cometOrder.Comet_Order_Status__c=needsApproval;
                    else
                        cometOrder.Comet_Order_Status__c=sendToComet;
                    System.debug('Comet Order status is : '+  cometOrder.Comet_Order_Status__c);
                    cometOrdersList.add(cometOrder);         
                } 
            }
        }
        update cometOrdersList;
    }
    
    
    
}