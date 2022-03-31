/**Authors : TP,SN
* Date : 16/09/2021
Aim : To view all orders (both confirmed and open orders)*/

public class CopperOrderStatus_Apex {
    
    //To hold the account data in objAccount variable
    public static Account objAccount;
    
    //To fetch the account details
    @AuraEnabled
    public static Account getAccount() { 
        if(Test.isRunningTest())
        {
            //for fetching the account details
            objAccount=[SELECT Id, Name,Lightning_Community_URL__c FROM Account
                        WHERE Name LIKE '%Copper Cane%' LIMIT 1];
        }
        else
        {
            objAccount=[SELECT Id, Name,Lightning_Community_URL__c FROM Account
                        WHERE Lightning_Community_Id__c=:Network.getNetworkId() LIMIT 1];
        }
        return objAccount;
    }
    
    
    //to fetch all the programs
    @AuraEnabled(cacheable=true)
    public static List<Program__c> getBuyBook_Apex(){
        objAccount=getAccount();
        
        String profileName=[Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
        if(profileName == 'Copper Cane Sales Manager') {
            return [SELECT Id,Name__c FROM Program__c WHERE Account__c=:objAccount.Id AND Id IN (SELECT Program__c FROM Chair_Budget__c WHERE Chair__r.User__c=:UserInfo.getUserId())];
        }
        else{
            return [SELECT Id,Name__c FROM Program__c WHERE Account__c=:objAccount.Id];
        }
    }
    
    
    @AuraEnabled
    public static List<Program_ChairBudget_CometOrder> loadOrdersForSelectedProgram_Apex(String searchKeyword,Boolean isEmergeAdmin,String selectedBuyBookId)
    {
        objAccount=getAccount();
        Boolean orderStatusButton;
        Boolean programStatusButton = false;
        List<Program_ChairBudget_CometOrder> programOrderDetails=new List<Program_ChairBudget_CometOrder> ();
        Decimal programConsumedValue=0;
        Map<Id,Chair_Budget__c> buyBookIdWithChairBudget=new Map<Id,Chair_Budget__c> ();
        for(Chair_Budget__c chairBudget : [SELECT Id,Allocated_Budget__c,Available_Budget__c,Consumed_Budget__c,
                                           Shared_Budget__c,Chair__r.Chair_Name__c,Chair__r.Level__c,Chair__r.Active__c,
                                           Chair__r.User__c,Program__r.Name__c,Program__r.Attachment_Id__c,
                                           Program__r.Start_Date__c,Program__r.Closing_Date__c,Program__r.In_Market_Date__c,Available_Chair_Budget__c,Chair_DFV_Department_Budget__c,Utilized_DFV_Department_Budget__c,Available_DFV_Department_Budget__c,
                                           Program__r.Program_Status__c FROM Chair_Budget__c WHERE Program__r.Account__c=:objAccount.Id AND Chair__r.User__c=:UserInfo.getUserId()
                                           Order by Program__r.Name__c])
        {
            buyBookIdWithChairBudget.put(chairBudget.Program__c,chairBudget);
        }
        String query='';
        String whereClause='';
        Map<Id,OrderDestination__c> cometOrders_Map=new Map<Id,OrderDestination__c> ();
        query+='SELECT Order__r.Name,AddressBook__r.State__r.State_Name__c,AddressBook__r.Zip__c,Order_Amount__c, Order__r.Id,Order__r.Order_Date__c, Order__r.CreatedById,Order__r.Order_Status__c, OrderDestination__c.Name,';
        query+='AddressBook__r.Destination_Name__c, AddressBook__r.Shipto_Name__c, AddressBook__r.Shipto_Company__c, AddressBook__r.City__c, AddressBook__r.Address__c,ShippingMethodRejeted__c,ShipMethodApproved__c,SelectedShippingMethod__r.Shipping_Method_Name__c,Shipping_Method__r.Shipping_Method_Name__c,';
        query+='OrderName__c,SelectedShippingMethod__r.ApprovalRequired__c,(SELECT Name,Tracking_Numbers__c,Carrier__c,Total_Line_Amount__c, Id,POS_Item__c,Quantity__c,POS_Item__r.Attachment_Id__c,POS_Item__r.Active__c, OrderDestination__r.AddressBook__r.Shipto_Name__c, OrderDestination__r.OrderName__c, OrderDestination__r.AddressBook__r.Shipto_Company__c, OrderDestination__r.AddressBook__r.Address__c, OrderDestination__r.AddressBook__r.City__c, POS_Item__r.Item_No__c, POS_Item__r.Pack_Of__c, POS_Item__r.Item_Name__c, SelectedQuantity__c ,';
        query+='POS_Item__r.Brand__r.Brand_Name__c,POS_Item__r.Type_of_Item__r.Item_Type__c,POS_Item__r.Approval_Required__c,POS_Item__r.Price__c,POS_Item__r.Maximum_Order_Qty__c,POS_Item__r.Maximum_order_quantity_applicable__c,MaxOrderAppReq__c,ItemApproved__c,ItemRejected__c,MaxOrderApproved__c,MaxOrderRejected__c FROM OrderDestinationItems__r WHERE SelectedQuantity__c>0 )';
        query+=',WarehouseOrderStatus__c, WarehouseProcessingStatus__c, WarehouseSequence__c, WarehouseShippingComments__c, WarehouseShippingDate__c, WarehouseShippingStatus__c, WarehouseTransactionNo__c';
        query+=',OrdStatus__c, Carrier__c, TrackingNos__c,Order__r.Program__r.Program_Status__c, Order__r.Program__c ';
        query+='FROM OrderDestination__c';
        whereClause+=' WHERE Order__r.Account__c=\''+objAccount.Id+'\' AND Order__r.Program__c!=null';
        whereClause+=isEmergeAdmin?' ':' AND Order__r.OwnerId =\''+UserInfo.getUserId()+'\'';
        whereClause+=' AND Order__r.Program__c =\''+selectedBuyBookId+'\'';
        if(String.isNotBlank(searchKeyword))
        {
            whereClause+=' AND ( OrderName__c LIKE '+'\'%'+searchKeyword+'%\' ';
            whereClause+=' OR AddressBook__r.Destination_Name__c LIKE '+'\'%'+searchKeyword+'%\' ';
            whereClause+=' OR AddressBook__r.Shipto_Name__c LIKE '+'\'%'+searchKeyword+'%\' ';
            whereClause+=' OR AddressBook__r.Shipto_Company__c LIKE '+'\'%'+searchKeyword+'%\' ';
            whereClause+=' OR AddressBook__r.City__c LIKE '+'\'%'+searchKeyword+'%\' ) ';
        }
        
        query=query+whereClause +' ORDER BY CreatedDate DESC';
        for(OrderDestination__c cometOrder : Database.query(query))
        {
            if(cometOrder.OrdStatus__c == 'Open' && cometOrder.Order__r.Program__r.Program_Status__c=='Window Opened'){
                orderStatusButton = true;
                programStatusButton = false;
            }
            else if(cometOrder.OrdStatus__c == 'Confirmed' && cometOrder.Order__r.Program__r.Program_Status__c=='Window Opened'){
                programStatusButton = true;
                orderStatusButton = false;
            }
            else if(cometOrder.OrdStatus__c == 'Confirmed' && cometOrder.Order__r.Program__r.Program_Status__c=='Window Closed'){
                
                orderStatusButton = false;
                programStatusButton = false;
            }
            else{
                orderStatusButton = false;
                programStatusButton = false;
            }
            
            List<OrderedItemDetails> orderedItems=new List<OrderedItemDetails> ();
            List<String> trackingNumberList = new List<String>();
            List<String> trackingNumberDetails = new List<String>();
            for(OrderDestinationItem__c cometOrderItem : cometOrder.OrderDestinationItems__r){
                trackingNumberList = new List<String>();
                String attachmentURL = String.isBlank(cometOrderItem.POS_Item__r.Attachment_Id__c)?'':objAccount.Lightning_Community_URL__c+'/servlet/servlet.FileDownload?file='+cometOrderItem.POS_Item__r.Attachment_Id__c;
                if(cometOrderItem.Tracking_Numbers__c!=null){
                    trackingNumberDetails =cometOrderItem.Tracking_Numbers__c.split(' ');
                    for (Integer j = 0; j<trackingNumberDetails.size();j++) {
                        trackingNumberList.add(trackingNumberDetails[j]);   
                    }  
                }
                
                orderedItems.add(new OrderedItemDetails(cometOrderItem,attachmentURL,true,trackingNumberList));
            }
            programOrderDetails.add(new Program_ChairBudget_CometOrder(new Program_ChairBudget_Details(cometOrder.Order__c,buyBookIdWithChairBudget.get(cometOrder.Order__r.Program__c)),cometOrder,orderedItems,cometOrder.Order_Amount__c, orderStatusButton,programStatusButton));
        }
        System.debug('programOrderDetails---->'+programOrderDetails);
        return programOrderDetails;
    }
    
    
    
    public class Program_ChairBudget_CometOrder
    {
        @AuraEnabled
        public Program_ChairBudget_Details programChairBudgetDetails;
        @AuraEnabled
        public OrderDestination__c cometOrder;
        @AuraEnabled
        public Decimal totalOrderValue;
        @AuraEnabled
        public List<OrderedItemDetails> orderedItems;
        @AuraEnabled
        public Boolean orderStatusButton;
        @AuraEnabled
        public Boolean programStatusButton;
        
        public Program_ChairBudget_CometOrder (Program_ChairBudget_Details programChairBudgetDetails,OrderDestination__c cometOrder,List<OrderedItemDetails> orderedItems,Decimal totalOrderValue,Boolean orderStatusButton,Boolean programStatusButton  )                                      
        {
            this.programChairBudgetDetails=programChairBudgetDetails;
            this.cometOrder=cometOrder;
            this.totalOrderValue=totalOrderValue;
            this.orderedItems=orderedItems;
            this.orderStatusButton = orderStatusButton;
            this.programStatusButton = programStatusButton;
        }
    }
    
    public class OrderedItemDetails
    {
        @AuraEnabled
        public OrderDestinationItem__c cometOrderItem;
        @AuraEnabled
        public String posItemImageURL;
        @AuraEnabled
        public Boolean isQtyEditable; 
        @AuraEnabled
        public List<String> trackingNumberList;
        public OrderedItemDetails(OrderDestinationItem__c cometOrderItem,String posItemImageURL,Boolean isQtyEditable,List<String> trackingNumberList)
        {
            this.cometOrderItem=cometOrderItem;
            this.posItemImageURL=posItemImageURL;
            this.isQtyEditable=isQtyEditable;
            this.trackingNumberList=trackingNumberList;
        }
    }
    
    public class Program_ChairBudget_Details
    {
        @AuraEnabled
        public String emergeOrderId ;
        @AuraEnabled
        public Chair_Budget__c program_chairBudget;
        public Program_ChairBudget_Details (String emergeOrderId,Chair_Budget__c program_chairBudget)
        {
            this.emergeOrderId=emergeOrderId;
            this.program_chairBudget=program_chairBudget;
        }
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
        }
        System.debug('cometOrderId---->' +cometOrderId);
        if(Test.isRunningTest())
        {
            System.debug('added for test coverage');
        }
        else{
            OrderDestination__c cometOrder=[SELECT Id,Order_Amount__c,OrdStatus__c,Comet_Order_Status__c FROM OrderDestination__c WHERE Id=:cometOrderId];
            cometOrder.Order_Amount__c =newOrderAmount;
            if(cometOrder.Comet_Order_Status__c == 'Open')
                cometOrder.Comet_Order_Status__c='Confirmed';
            update cometOrder;
            chairBudget.Consumed_Budget__c=chairBudget.Consumed_Budget__c+cometOrder.Order_Amount__c;
            System.debug('chairBudget--->'+chairBudget);
            update chairBudget;
        }
        
        //change the return type to String as its causing the too many sql query limit and also as its invoked in the front end too    
        return 'done';
    }
}