public class CopperEditOrderForDivisionalManager_Apex {
 public static Account objAccount;
    //To fetch data about Copper Cane from Standard object Account.
    @AuraEnabled(cacheable=true)
    public static Account getAccount() {  
        
        if(Test.isRunningTest())
        {
            objAccount=[SELECT Id, Name FROM Account
                        WHERE Name LIKE '%Copper Cane%' LIMIT 1];
        }
        else
        {
           objAccount=[SELECT Id, Name,Lightning_Community_URL__c FROM Account
                       WHERE Lightning_Community_Id__c=:Network.getNetworkId() LIMIT 1];
                        // objAccount=[SELECT Id, Name FROM Account
                      //  WHERE Name LIKE '%Copper Cane%' LIMIT 1];
        }
        return objAccount; // objAccount object contains data about Copper Cane.
    }
    
    //to fetch all active programs to display 
      @AuraEnabled(cacheable=true)
    public static List<Program__c> getAllBuyBookList_Apex()
    {
        objAccount=getAccount();
       
            return [SELECT Id,Name__c FROM Program__c WHERE Account__c=:objAccount.Id AND Active__c=true];
     
    }
    
    //to get all the users whose fixed posotions is under the fixed position of the logged in user
    @AuraEnabled(cacheable=true)
    public static List<User> getAllUsersToDisplay_Apex(){
        
        objAccount=getAccount();
        
        User users = new User();
        
        List<User> usersToBeDisplayed = new List<User>();

        Fixed_Position__c fixedPositionOfTheLoggedInUser = [Select Id, Fixed_Position_Name__c FROM Fixed_Position__c WHERE 
                                                           Chair__r.User__c=:UserInfo.getUserId()];
        System.debug('fixedPositionOfTheLoggedInUser--->'+fixedPositionOfTheLoggedInUser.Fixed_Position_Name__c);

        String fixedPositionName = '%'+fixedPositionOfTheLoggedInUser.Fixed_Position_Name__c+'%';

        List<Fixed_Position__c> subordinateFixedPositions = [Select Chair__r.User__c, Fixed_Position_Name__c 
                                                              FROM Fixed_Position__c 
                                                              WHERE Chair__r.Account__c=:objAccount.Id
                                                              AND Chair__r.User__c !=null
                                                              AND Fixed_Position_Name__c LIKE :fixedPositionName];
        
        for(Fixed_Position__c fixedPositions : subordinateFixedPositions){
            
            users = [Select Id,Name from User WHERE Id=:fixedPositions.Chair__r.User__c];
			usersToBeDisplayed.add(users);
        }
		        
        System.debug('usersToBeDisplayed--->'+usersToBeDisplayed);
        System.debug('subordinateFixedPositions--->'+subordinateFixedPositions.size());
        return usersToBeDisplayed;
        
    }
    
     public class OrderedItemDetails
    {
        @AuraEnabled
        public OrderDestinationItem__c cometOrderItem;
        @AuraEnabled
        public String posItemImage; 
        @AuraEnabled
        public Boolean isQtyEditable; 
        public OrderedItemDetails(OrderDestinationItem__c cometOrderItem,String posItemImage,Boolean isQtyEditable)
        {
            this.cometOrderItem=cometOrderItem;
            this.posItemImage=posItemImage;
            this.isQtyEditable=isQtyEditable;
        }
    }
    public class CometOrder_ChairBudget
    {
        @AuraEnabled
        public OrderDestination__c cometOrder;
        @AuraEnabled
        public List<OrderedItemDetails> orderedItems;
        @AuraEnabled
        public Chair_Budget__c chairBudget;
        @AuraEnabled
        public Decimal totalOrderValue;
        @AuraEnabled
        public Decimal buyBookConsumedValue;
        public CometOrder_ChairBudget(OrderDestination__c cometOrder,List<OrderedItemDetails> orderedItems, Chair_Budget__c chairBudget,Decimal totalOrderValue,Decimal buyBookConsumedValue)
        {
            this.cometOrder=cometOrder;
            this.chairBudget=chairBudget;
            this.orderedItems=orderedItems;
            this.totalOrderValue=totalOrderValue;
            this.buyBookConsumedValue=buyBookConsumedValue;
        }
        
    }
    
    @AuraEnabled
    public static List<CometOrder_ChairBudget> loadOrdersForSelectedBuyBookAndUser_Apex(String selectedUser,String selectedBuyBookId)
    {
        objAccount=getAccount();
        List<CometOrder_ChairBudget> buyBookOrderDetails=new List<CometOrder_ChairBudget> ();
        Map<Id,Chair_Budget__c> chairIdWithChairBudget=new Map<Id,Chair_Budget__c> ();
        System.debug('testing----> '+selectedBuyBookId);
        if(String.isNotBlank(selectedBuyBookId))
        {
            if(String.isBlank(selectedUser))
                selectedUser='';
            if(String.isNotBlank(selectedUser))   
            {
                //selectedUser='%'+selectedUser+'%';
                for(Chair_Budget__c chairBudget : [SELECT Id,Allocated_Budget__c,Available_Budget__c,Consumed_Budget__c,
                                                   Shared_Budget__c,Chair__r.Chair_Name__c,Chair__r.Level__c,Chair__r.Active__c,
                                                   Chair__r.User__c,Program__r.Name__c,Program__r.Attachment_Id__c,
                                                   Program__r.Start_Date__c,Program__r.Closing_Date__c,Program__r.In_Market_Date__c,Available_Chair_Budget__c,
                                                   Program__r.Program_Status__c FROM Chair_Budget__c WHERE Program__r.Account__c=:objAccount.Id AND Chair__r.User__r.Id = :selectedUser   AND Program__c=:selectedBuyBookId
                                                   Order by Program__r.Name__c])
                {
                    chairIdWithChairBudget.put(chairBudget.Chair__r.User__c,chairBudget);
                }
                for(OrderDestination__c cometOrder : [SELECT Order__r.Name, Order__r.Id,Order__r.Order_Date__c, Order__r.CreatedById,Order__r.Order_Status__c, OrderDestination__c.Name,Order_Amount__c,
                                                      AddressBook__r.Destination_Name__c, AddressBook__r.Shipto_Name__c, AddressBook__r.Shipto_Company__c, AddressBook__r.City__c, AddressBook__r.Address__c,ShippingMethodRejeted__c,ShipMethodApproved__c,SelectedShippingMethod__r.Shipping_Method_Name__c,Shipping_Method__r.Shipping_Method_Name__c,
                                                      OrderName__c,SelectedShippingMethod__r.ApprovalRequired__c,(SELECT Name,Total_Line_Amount__c, Id,POS_Item__c,Quantity__c,POS_Item__r.Attachment_Id__c,POS_Item__r.Active__c, OrderDestination__r.AddressBook__r.Shipto_Name__c, OrderDestination__r.OrderName__c, OrderDestination__r.AddressBook__r.Shipto_Company__c, OrderDestination__r.AddressBook__r.Address__c, OrderDestination__r.AddressBook__r.City__c, POS_Item__r.Item_No__c, POS_Item__r.Pack_Of__c,POS_Item__r.Price__c, POS_Item__r.Item_Name__c, SelectedQuantity__c ,
                                                                                                                  POS_Item__r.Brand__r.Brand_Name__c,POS_Item__r.Type_of_Item__r.Item_Type__c,POS_Item__r.Approval_Required__c,POS_Item__r.Maximum_Order_Qty__c,POS_Item__r.Maximum_order_quantity_applicable__c,MaxOrderAppReq__c,ItemApproved__c,ItemRejected__c,MaxOrderApproved__c,MaxOrderRejected__c FROM OrderDestinationItems__r  )
                                                      ,WarehouseOrderStatus__c, WarehouseProcessingStatus__c, WarehouseSequence__c, WarehouseShippingComments__c, WarehouseShippingDate__c, WarehouseShippingStatus__c, WarehouseTransactionNo__c
                                                      ,OrdStatus__c, Carrier__c,Order__r.OwnerId, TrackingNos__c, Order__r.Program__c, Order__r.Owner.Name, AddressBook__r.Zip__c,AddressBook__r.State__r.State_Name__c
                                                      FROM OrderDestination__c WHERE Order__r.Account__c=:objAccount.Id AND Order__r.Program__c!=null AND Order__r.Owner.Id =:selectedUser  AND Order__r.Program__c =:selectedBuyBookId])
                {
                    Decimal totalOrderValue=0;
                    List<OrderedItemDetails> orderedItems=new List<OrderedItemDetails>();
                    for(OrderDestinationItem__c cometOrderItem : cometOrder.OrderDestinationItems__r )
                    {
                        totalOrderValue+=cometOrderItem.Total_Line_Amount__c;
                        String attachmentURL = String.isBlank(cometOrderItem.POS_Item__r.Attachment_Id__c)?'':objAccount.Lightning_Community_URL__c+'/servlet/servlet.FileDownload?file='+cometOrderItem.POS_Item__r.Attachment_Id__c;

                        orderedItems.add(new OrderedItemDetails(cometOrderItem,attachmentURL,true));
                    }
                    List<AggregateResult> aggregateResults=[SELECT SUM(Consumed_Budget__c) total FROM Chair_Budget__c WHERE Program__c=:selectedBuyBookId];
                    buyBookOrderDetails.add(new CometOrder_ChairBudget(cometOrder,
                                                                       orderedItems, chairIdWithChairBudget.get(cometOrder.Order__r.OwnerId),totalOrderValue,aggregateResults.isEmpty()?0:(Decimal)aggregateResults[0].get('total')));
                }
            }
            else
            { 
                for(Chair_Budget__c chairBudget : [SELECT Id,Allocated_Budget__c,Available_Budget__c,Consumed_Budget__c,
                                                   Shared_Budget__c,Chair__r.Chair_Name__c,Chair__r.Level__c,Chair__r.Active__c,
                                                   Chair__r.User__c,Program__r.Name__c,Program__r.Attachment_Id__c,
                                                   Program__r.Start_Date__c,Program__r.Closing_Date__c,Program__r.In_Market_Date__c,Available_Chair_Budget__c,
                                                   Program__r.Program_Status__c FROM Chair_Budget__c WHERE Program__r.Account__c=:objAccount.Id AND Program__c=:selectedBuyBookId
                                                   Order by Program__r.Name__c])
                {
                    chairIdWithChairBudget.put(chairBudget.Chair__r.User__c,chairBudget);
                }
                System.debug(chairIdWithChairBudget.values());
                for(OrderDestination__c cometOrder : [SELECT Order__r.Name, Order__r.Id,Order__r.Order_Date__c, Order__r.CreatedById,Order__r.Order_Status__c, OrderDestination__c.Name,Order_Amount__c,
                                                      AddressBook__r.Destination_Name__c, AddressBook__r.Shipto_Name__c, AddressBook__r.Shipto_Company__c, AddressBook__r.City__c, AddressBook__r.Address__c,ShippingMethodRejeted__c,ShipMethodApproved__c,SelectedShippingMethod__r.Shipping_Method_Name__c,Shipping_Method__r.Shipping_Method_Name__c,
                                                      OrderName__c,SelectedShippingMethod__r.ApprovalRequired__c,(SELECT Name,Total_Line_Amount__c, Id,POS_Item__c,Quantity__c,POS_Item__r.Attachment_Id__c,POS_Item__r.Active__c, OrderDestination__r.AddressBook__r.Shipto_Name__c, OrderDestination__r.OrderName__c, OrderDestination__r.AddressBook__r.Shipto_Company__c, OrderDestination__r.AddressBook__r.Address__c, OrderDestination__r.AddressBook__r.City__c, POS_Item__r.Item_No__c, POS_Item__r.Pack_Of__c,POS_Item__r.Price__c, POS_Item__r.Item_Name__c, SelectedQuantity__c ,
                                                                                                                  POS_Item__r.Brand__r.Brand_Name__c,POS_Item__r.Type_of_Item__r.Item_Type__c,POS_Item__r.Approval_Required__c,POS_Item__r.Maximum_Order_Qty__c,POS_Item__r.Maximum_order_quantity_applicable__c,MaxOrderAppReq__c,ItemApproved__c,ItemRejected__c,MaxOrderApproved__c,MaxOrderRejected__c FROM OrderDestinationItems__r  )
                                                      ,WarehouseOrderStatus__c, WarehouseProcessingStatus__c, WarehouseSequence__c, WarehouseShippingComments__c, WarehouseShippingDate__c, WarehouseShippingStatus__c, WarehouseTransactionNo__c
                                                      ,OrdStatus__c, Carrier__c,Order__r.OwnerId, TrackingNos__c, Order__r.Program__c, Order__r.Owner.Name, AddressBook__r.Zip__c,AddressBook__r.State__r.State_Name__c
                                                      FROM OrderDestination__c WHERE Order__r.Account__c=:objAccount.Id AND Order__r.Program__c!=null AND Order__r.Program__c =:selectedBuyBookId])
                {
                    Decimal totalOrderValue=0;
                    List<OrderedItemDetails> orderedItems=new List<OrderedItemDetails>();
                    for(OrderDestinationItem__c cometOrderItem : cometOrder.OrderDestinationItems__r )
                    {
                        totalOrderValue+=cometOrderItem.Total_Line_Amount__c;
                        String attachmentURL = String.isBlank(cometOrderItem.POS_Item__r.Attachment_Id__c)?'':objAccount.Lightning_Community_URL__c+'/servlet/servlet.FileDownload?file='+cometOrderItem.POS_Item__r.Attachment_Id__c;
                        orderedItems.add(new OrderedItemDetails(cometOrderItem,attachmentURL,true));
                    }
                    List<AggregateResult> aggregateResults=[SELECT SUM(Consumed_Budget__c) total FROM Chair_Budget__c WHERE Program__c=:selectedBuyBookId];
                    buyBookOrderDetails.add(new CometOrder_ChairBudget(cometOrder,
                                                                       orderedItems, chairIdWithChairBudget.get(cometOrder.Order__r.OwnerId),totalOrderValue,aggregateResults.isEmpty()?0:(Decimal)aggregateResults[0].get('total')));
                }
            }
            
            
        }
        System.debug('buyBookOrderDetails---->'+buyBookOrderDetails);
        return buyBookOrderDetails;
    }
    
    @AuraEnabled
    public static String saveEditedOrder_Apex(String seasonalOrderItems,Decimal orderAmount,String cometOrderId,Chair_Budget__c chairBudget)
    {
        
        if(chairBudget.Consumed_Budget__c==null)
            chairBudget.Consumed_Budget__c=0;
        chairBudget.Consumed_Budget__c=chairBudget.Consumed_Budget__c-orderAmount;
        update chairBudget;
        List<OrderedItemDetails> orderedItems=(List<OrderedItemDetails>)System.JSON.deserialize(seasonalOrderItems, List<OrderedItemDetails>.class);
        List<OrderDestinationItem__c> cometOrderItems = new List<OrderDestinationItem__c>();
        system.debug('Ordered Items count' +orderedItems.size());
        for(OrderedItemDetails orderedItem : orderedItems ){
            if(!orderedItem.isQtyEditable){
                cometOrderItems.add(orderedItem.cometOrderItem);
            }
        }
        update cometOrderItems;
        Decimal newOrderAmount=0;
        for(OrderDestinationItem__c cometOrderItem : [SELECT Id,Total_Line_Amount__c FROM OrderDestinationItem__c WHERE OrderDestination__c=:cometOrderId]){
            newOrderAmount+=cometOrderItem.Total_Line_Amount__c ;
            system.debug('cometOrderItem' +cometOrderItem);
        }
        OrderDestination__c cometOrder=[SELECT Id,Order_Amount__c,OrdStatus__c,Comet_Order_Status__c FROM OrderDestination__c WHERE Id=:cometOrderId];
        cometOrder.Order_Amount__c =newOrderAmount;
        if(cometOrder.Comet_Order_Status__c == 'Open')
            cometOrder.Comet_Order_Status__c='Confirmed';
        update cometOrder;
        chairBudget.Consumed_Budget__c=chairBudget.Consumed_Budget__c+cometOrder.Order_Amount__c;
        System.debug('chairBudget--->'+chairBudget);
        update chairBudget;
        //change the return type to String as its causing the too many sql query limit and also as its invoked in the front end too		
        return 'done';
    }
}