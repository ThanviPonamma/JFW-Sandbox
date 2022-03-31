//Aim : is responsible for creating the record in the Brand Order Approval
//      for the OrderDestination Items that require approval on the click of Confirm Order button.
//Created by : Thanvi,Ranjith,Nachappa

public class brandApprovalNotifications {
    
    //To create the record in the Brand Order Approval
    // for the OrderDestination Items that require approval on the click of Confirm Order button.
    public static void checkTheOrderedItems(Map<Id,Order__c> newEmergeOrderMap){    
        //To hold the list of order destinations for the triggered order Sobject.
        List<OrderDestination__c> orderDestinationList = new List<OrderDestination__c>();
        //To hold the list of order destination items that requires approval
        List<OrderDestinationItem__c>  orderDestinationItem = new  List<OrderDestinationItem__c>();
        List<OrderDestinationItem__c> orderDestinationItemList = new List<OrderDestinationItem__c>();
        
        // newEmergeOrderMap - To hold the newly created data of orders
        for(Order__c order: newEmergeOrderMap.values()){
            System.debug('order---->' + order);
           /** 
            * Authors : SN,TP Date: 15-05-2020 CR Number - DFV-15-May-17. 
            * The below line is commented to added additional fields to be fectehed		
            orderDestinationList = [SELECT Id,
                                    OrdStatus__c,
                                    ShipToName__c,
                                    ShipToCompany__c,
                                    ShipToCity__c,
                                    FROM OrderDestination__c 
                                    WHERE (Order__c = :order.Id AND Order__r.Order_Status__c='Send to Comet'
                                          )]; **/
            orderDestinationList = [SELECT Id,
                                    OrdStatus__c,
                                    ShipToName__c,
                                    ShipToCompany__c,
                                    ShipToCity__c,
                                    Order_Date__c
                                    FROM OrderDestination__c 
                                    WHERE (Order__c = :order.Id AND Order__r.Order_Status__c='Send to Comet'
                                          )];
            
        }
        System.debug('orderDestinationList ---->'+orderDestinationList );
        System.debug('orderDestinationList Size ---->'+orderDestinationList.size());
        
        if(orderDestinationList.size()>0)
        {
            for(OrderDestination__c orderDestination : orderDestinationList){
                if(orderDestination.OrdStatus__c == 'Needs Approval')
                {
             /** 
            * Authors : SN,TP Date: 15-05-2020 CR Number - DFV-15-May-17. 
            * The below line is commented to added additional fields to be fectehed
                    orderDestinationItem = 
                        [SELECT POS_Item__c,
                         ItemAppReq__c,
                         ItemApproved__c,
                         ItemRejected__c,
                         MaxOrderAppReq__c,
                         MaxOrderRejected__c,
                         MaxOrderApproved__c,
                         POS_Item__r.Item_Name__c,
                         POS_Item__r.Item_No__c,
                         OrderDestination__c,
                         POS_Item__r.Brand__c,
                         POS_Item__r.Brand__r.Brand_Name__c,
                         OrderDestination__r.OrderName__c 
                         FROM OrderDestinationItem__c 
                         WHERE OrderDestination__c=:orderDestination.Id AND
                         ((ItemAppReq__c = true AND ItemApproved__c = false AND ItemRejected__c =false) OR 
                          (MaxOrderAppReq__c  = true AND MaxOrderApproved__c = false AND MaxOrderRejected__c =false))]; **/
                    
                    orderDestinationItem = 
                        [SELECT POS_Item__c,
                         ItemAppReq__c,
                         ItemApproved__c,
                         ItemRejected__c,
                         MaxOrderAppReq__c,
                         MaxOrderRejected__c,
                         MaxOrderApproved__c,
                         POS_Item__r.Item_Name__c,
                         POS_Item__r.Item_No__c,
                         OrderDestination__c,
                         POS_Item__r.Brand__c,
                         POS_Item__r.Brand__r.Brand_Name__c,
                         OrderDestination__r.OrderName__c,
                         OrderDestination__r.ShipToName__c,
                         OrderDestination__r.ShipToCity__c,
                         OrderDestination__r.OrdStatus__c,
                         OrderDestination__r.Order_owner__c,
                         OrderDestination__r.Order_Date__c,
                         Quantity__c 
                         FROM OrderDestinationItem__c 
                         WHERE OrderDestination__c=:orderDestination.Id AND
                         ((ItemAppReq__c = true AND ItemApproved__c = false AND ItemRejected__c =false) OR 
                          (MaxOrderAppReq__c  = true AND MaxOrderApproved__c = false AND MaxOrderRejected__c =false))]; 
                    
                }
                orderDestinationItemList.addAll(orderDestinationItem);
            }
            System.debug('orderDestinationItemList Size end of if---->'+orderDestinationItemList.size());
            //Check whether BrandOrderApprovals created or not.
            if(orderDestinationItemList.size()>0)
            {
            boolean isBrandOrderApprovalsCreated = createBrandOrderApprovals(orderDestinationItemList);
            System.debug('isBrandOrderApprovalsCreated---->' + String.valueOf(isBrandOrderApprovalsCreated));
            }
        }
    }
    
    
    
    //To create Brand Order Approvals for the orderDestinationItems
    public static boolean createBrandOrderApprovals(List<OrderDestinationItem__c> orderDestinationItemList){
        //To hold the list of BrandOrderApprovals that has to be created.
        List<Brand_Order_Approval__c> brandOrderApprovalList = new List<Brand_Order_Approval__c>(); 
        //To hold the boolean value as true -(if Brand Order Approvals are created) & false - (Not created)
        boolean isBrandOrderApprovalsCreated = false;
        //To hold the orderDestinationId for the orderDestinationItems  
        string orderDestinationId = orderDestinationItemList[0].OrderDestination__c;
        
        //Check any order destination item requires approval
        if(orderDestinationItemList.size() > 0)
        {
            for(OrderDestinationItem__c orderDestinationItem : orderDestinationItemList)
            {   
                
                //To hold the brandId for each orderDestinationItem
                string brandId = orderDestinationItem.POS_Item__r.Brand__c;
                
                //To hold the list of brand Managers Using the brand Id
                List<Brand_Manager__c> brandMangerList = [SELECT 
                                                          Id,
                                                          User__r.Name,
                                                          User__c,
                                                          User__r.Email 
                                                          FROM Brand_Manager__c 
                                                          WHERE Brand__c = :brandId];
                
                //For each BrandManager create Brand Order Approval record
                for(Brand_Manager__c brandManger : brandMangerList){
                    /** 
            * Authors : SN,TP Date: 15-05-2020 CR Number - DFV-15-May-17. 
            * The below line is commented to added additional fields for insertion
                    brandOrderApprovalList.add(
                        new Brand_Order_Approval__c(
                            Brand_Id__c = orderDestinationItem.POS_Item__r.Brand__c,
                            Brand_Manager_ID__c = brandManger.Id,
                            Brand_Name__c = orderDestinationItem.POS_Item__r.Brand__r.Brand_Name__c,
                            Comet_Order_Name__c = orderDestinationItem.OrderDestination__r.OrderName__c,
                            Email__c = brandManger.User__r.Email,
                            Order_Destination_ID__c = orderDestinationId,
                            POS_Item_ID__c = orderDestinationItem.POS_Item__c,
                            POS_Item_Name__c = orderDestinationItem.POS_Item__r.Item_Name__c,
                            User_ID__c = brandManger.User__c,
                            User_Name__c = brandManger.User__r.Name));  **/
                    brandOrderApprovalList.add(
                        new Brand_Order_Approval__c(
                            Brand_Id__c = orderDestinationItem.POS_Item__r.Brand__c,
                            Brand_Manager_ID__c = brandManger.Id,
                            Brand_Name__c = orderDestinationItem.POS_Item__r.Brand__r.Brand_Name__c,
                            Comet_Order_Name__c = orderDestinationItem.OrderDestination__r.OrderName__c,
                            Email__c = brandManger.User__r.Email,
                            Order_Destination_ID__c = orderDestinationId,
                            Ship_To_City__c = orderDestinationItem.OrderDestination__r.ShipToCity__c,
                            Ship_To_Name__c = orderDestinationItem.OrderDestination__r.ShipToName__c,
                            Order_Owner_Name__c = orderDestinationItem.OrderDestination__r.Order_owner__c,
                            Order_Date__c = orderDestinationItem.OrderDestination__r.Order_Date__c,
                            Order_Destination_Status__c = orderDestinationItem.OrderDestination__r.OrdStatus__c,
                            POS_Item_ID__c = orderDestinationItem.POS_Item__c,
                            POS_Item_Name__c = orderDestinationItem.POS_Item__r.Item_Name__c,
                            Quantity__c = orderDestinationItem.Quantity__c,
                            User_ID__c = brandManger.User__c,
                            User_Name__c = brandManger.User__r.Name));
                    
                }
                
            }
            insert brandOrderApprovalList;
            isBrandOrderApprovalsCreated = true;
        }
        
        return isBrandOrderApprovalsCreated;
    }
}