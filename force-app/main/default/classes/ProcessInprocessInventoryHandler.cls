public class ProcessInprocessInventoryHandler {
    public final static String rejectedShippingMethod='Rejected due to choice of Shipping method';
    
    public static void calculateInprocessInventory(Map<Id,OrderDestinationItem__c> oldCometOrderItems,Map<Id,OrderDestinationItem__c> newCometOrderItems)
    {
        Map<Id,Decimal> posItemsWithInprocessInventory=new Map<Id,Decimal> ();
        Map<Id,String> cometOrdersWithLogicalInv_History=new Map<Id,String> ();
        List<OrderDestinationItem__c> cometOrderItems=new List<OrderDestinationItem__c> ();
        List<Pos_Item__c> posItems=new List<Pos_Item__c> ();
        List<OrderDestination__c> cometOrders=new List<OrderDestination__c> ();
        Map<Id,OrderDestination__c> CometOrders_Map=new Map<Id,OrderDestination__c> ([SELECT Id,Order__c,Comet_Order_Status__c FROM OrderDestination__c WHERE Id IN (SELECT OrderDestination__c FROM OrderDestinationItem__c WHERE Id IN :newCometOrderItems.values())]);
        Map<Id,Order__c> emergeOrders_Map=new Map<Id,Order__c> ([SELECT Id,Account__r.Is_Comet_Rest_Api__c FROM Order__c WHERE Id IN (SELECT Order__c FROM OrderDestination__c WHERE Id IN :CometOrders_Map.keySet()) ]);
        
        //System.debug(newCometOrderItems);
        //System.debug(oldCometOrderItems);
        
        for(OrderDestinationItem__c cometOrderItem:newCometOrderItems.values())
        {
            /*
            flags need to be set:
            1.if item requires approval and item is rejected and old quanity is not zero and new quantity is zero and selected qty is not zero and this is for comet rest api only.
            */
            if(((cometOrderItem.ItemAppReq__c==true && cometOrderItem.ItemRejected__c==true && oldCometOrderItems.get(cometOrderItem.Id).ItemRejected__c==false) || (cometOrderItem.MaxOrderAppReq__c==true && cometOrderItem.MaxOrderRejected__c==true && oldCometOrderItems.get(cometOrderItem.Id).MaxOrderRejected__c==false) || (cometOrderItem.ItemAppReq__c==false && cometOrderItem.MaxOrderAppReq__c==false && CometOrders_Map.get(cometOrderItem.OrderDestination__c).Comet_Order_Status__c == rejectedShippingMethod)) && cometOrderItem.Quantity__c ==0 && oldCometOrderItems.get(cometOrderItem.Id).Quantity__c !=0 && cometOrderItem.SelectedQuantity__c !=0 && cometOrderItem.Is_Inventory_Added__c==true && emergeOrders_Map.get(CometOrders_Map.get(cometOrderItem.OrderDestination__c).Order__c).Account__r.Is_Comet_Rest_Api__c==true)
            {
                    //Inprocess Inventory calculation starts here.........//
                    if(posItemsWithInprocessInventory.containsKey(cometOrderItem.Pos_Item__c))
                    {
                        Decimal quantity=posItemsWithInprocessInventory.get(cometOrderItem.Pos_Item__c);
                        posItemsWithInprocessInventory.put(cometOrderItem.Pos_Item__c,cometOrderItem.SelectedQuantity__c+quantity);
                    }else
                    {
                        posItemsWithInprocessInventory.put(cometOrderItem.Pos_Item__c,cometOrderItem.SelectedQuantity__c);   
                    }
                    
                    //Logical history calculation starts here.........//
                    if(cometOrdersWithLogicalInv_History.containsKey(cometOrderItem.OrderDestination__c))
                    {
                        String history=cometOrdersWithLogicalInv_History.get(cometOrderItem.OrderDestination__c);
                        cometOrdersWithLogicalInv_History.put(cometOrderItem.OrderDestination__c,history+'\n'+cometOrderItem.ItemName__c+' ---> '+String.valueOf(cometOrderItem.SelectedQuantity__c)+' is deducted from Inprocess Inventory at '+System.now().format()+'.\n');
                    }else
                    {
                        cometOrdersWithLogicalInv_History.put(cometOrderItem.OrderDestination__c,'\n'+cometOrderItem.ItemName__c+' ---> '+String.valueOf(cometOrderItem.SelectedQuantity__c)+' is deducted from Inprocess Inventory at '+System.now().format()+'.\n');
                    }
                    //OrderDestinationItem__c cometOrderItmToUpdate=new OrderDestinationItem__c (Id=cometOrderItem.Id);
                        cometOrderItem.Is_Inventory_Deducted__c=true;
                    //cometOrderItems.add(cometOrderItem);
            }
            if(cometOrderItem.MaxOrderAppReq__c==true && cometOrderItem.MaxOrderApproved__c==true && oldCometOrderItems.get(cometOrderItem.Id).MaxOrderApproved__c!=true && cometOrderItem.Quantity__c<cometOrderItem.SelectedQuantity__c && cometOrderItem.Is_Inventory_Added__c==true && emergeOrders_Map.get(CometOrders_Map.get(cometOrderItem.OrderDestination__c).Order__c).Account__r.Is_Comet_Rest_Api__c==true)
            {
                    //Inprocess Inventory calculation starts here.........//
                    if(posItemsWithInprocessInventory.containsKey(cometOrderItem.Pos_Item__c))
                    {
                        Decimal quantity=posItemsWithInprocessInventory.get(cometOrderItem.Pos_Item__c);
                        posItemsWithInprocessInventory.put(cometOrderItem.Pos_Item__c,(cometOrderItem.SelectedQuantity__c-cometOrderItem.Quantity__c)+quantity);
                    }else
                    {
                        posItemsWithInprocessInventory.put(cometOrderItem.Pos_Item__c,cometOrderItem.SelectedQuantity__c-cometOrderItem.Quantity__c);   
                    }
                    
                    //Logical history calculation starts here.........// 
                    if(cometOrdersWithLogicalInv_History.containsKey(cometOrderItem.OrderDestination__c))
                    {
                        String history=cometOrdersWithLogicalInv_History.get(cometOrderItem.OrderDestination__c);
                        cometOrdersWithLogicalInv_History.put(cometOrderItem.OrderDestination__c,history+'\n'+cometOrderItem.ItemName__c+' ---> '+String.valueOf(cometOrderItem.SelectedQuantity__c-cometOrderItem.Quantity__c)+' is deducted from Inprocess Inventory at '+System.now().format()+'.\n');
                    }else
                    {
                        cometOrdersWithLogicalInv_History.put(cometOrderItem.OrderDestination__c,'\n'+cometOrderItem.ItemName__c+' ---> '+String.valueOf(cometOrderItem.SelectedQuantity__c-cometOrderItem.Quantity__c)+' is deducted from Inprocess Inventory at '+System.now().format()+'.\n');
                    }   
            }
        }
        
        for(Pos_Item__c posItem:[SELECT Id,InProcess_Inventory_Stock__c FROM Pos_Item__c WHERE Id IN :posItemsWithInprocessInventory.keySet()])
        {
            if(posItem.InProcess_Inventory_Stock__c==null)
            posItem.InProcess_Inventory_Stock__c=0;
            posItem.InProcess_Inventory_Stock__c-=posItemsWithInprocessInventory.get(posItem.Id);
            posItems.add(posItem);
        }
        for(OrderDestination__c cometOrder:[SELECT Id,Logical_Inventory_Histroy__c FROM OrderDestination__c WHERE Id IN :cometOrdersWithLogicalInv_History.keySet()])
        {
            if(cometOrder.Logical_Inventory_Histroy__c==null)
            cometOrder.Logical_Inventory_Histroy__c='';
            cometOrder.Logical_Inventory_Histroy__c +=cometOrdersWithLogicalInv_History.get(cometOrder.Id);
            cometOrders.add(cometOrder);
        }
        update posItems;
       // update cometOrderItems;
        update cometOrders;
    }
    }