/** Authors : TP,SN
Date : 15/09/2021
Aim : To display and save the orders in preview page of the inventory order flow*/

public class CopperPreviewOrder_Apex {
    //To hold the account data in objAccount variable    
    public static Account objAccount;
    
    //AIM:to get the logged in user details
    @AuraEnabled
    public static Schema.User getUserDetails()
    {
        
        Schema.User userDetails = [SELECT Id,UserName,International_Address_Accessible__c,Profile.Name,Profile.Id,Email FROM User WHERE Id=:UserInfo.getUserId()];
        system.debug('userDetails----->'+userDetails);
        return userDetails;
    }
    
    //Aim: To get the account data
    @AuraEnabled
    public static Account getAccount() { 
        if(Test.isRunningTest())
        {
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
    
    //To display the orders and the related order destination and their items.
    //Parameter:emergeOrderd:To hold the order id for which the order destination items has to be displayed
    @AuraEnabled(cacheable=true)
    public static List<CometOrders_Wrapper> getAllCometOrders(String emergeOrderId)
    {
        //fetch account details and store it in the variable objAccount
        objAccount = getAccount();
        //Declare a list variable wrapperInstance of type CometOrders_Wrapper  hold the Image URL and Ordered items(this is newly added to send the image url to the frontend)
        List<CometOrders_Wrapper>  wrapperInstance = new List<CometOrders_Wrapper>();
        //Declare a list variable orderDestinationItems of type OrderDestinationItem__c to hold name , id , pos item , quantity , pos item attachment id , pos item active status,address ,shipping method from order destination item for the quantity greater than 0 and order id is same as the incoming order id.
        List<OrderDestinationItem__c> orderDestinationItems = [SELECT Name, Id,POS_Item__c,Quantity__c,POS_Item__r.Attachment_Id__c,
                                                               POS_Item__r.Active__c, OrderDestination__r.AddressBook__r.Shipto_Name__c,
                                                               OrderDestination__r.OrderName__c, OrderDestination__r.AddressBook__r.Shipto_Company__c,
                                                               OrderDestination__r.AddressBook__r.Address__c, OrderDestination__r.AddressBook__r.City__c,
                                                               OrderDestination__r.AddressBook__r.State__r.State_Code__c,OrderDestination__r.AddressBook__r.State__r.State_Name__c,
                                                               POS_Item__r.Item_No__c, POS_Item__r.Pack_Of__c, POS_Item__r.Item_Name__c,
                                                               SelectedQuantity__c,OrderDestination__r.SelectedShippingMethod__r.Shipping_Method_Name__c 
                                                               FROM OrderDestinationItem__c 
                                                               WHERE SelectedQuantity__c>0 
                                                               AND OrderDestination__r.Order__r.Id =:emergeOrderId];
        
        //for every fetched order destination item , form the image URL and store it in attachmentURL and add it to the wrapper class.
        for(orderDestinationItem__c item : orderDestinationItems){
            
            String attachmentURL = String.isBlank(item.POS_Item__r.Attachment_Id__c)?'':objAccount.Lightning_Community_URL__c+'/servlet/servlet.FileDownload?file='+item.POS_Item__r.Attachment_Id__c;
            wrapperInstance.add(new CometOrders_Wrapper(item,attachmentURL));
            
        }
        
        system.debug('wrapperInstance---->'+wrapperInstance);
        //return the wrapper instance to the front end 
        return wrapperInstance;
        
    }
    
    
    
    @AuraEnabled
    public static String confirmOrder_Apex(String emergeOrderId,String selectedProgramId)
    {
        System.debug('emergeOrderId----->'+emergeOrderId);
        System.debug('selectedProgramId----->'+selectedProgramId);
        
        try{
            objAccount=getAccount();
            Decimal totalOrderedAmount=0;
            Decimal totalNewOrderedAmount=0;
            List<OrderDestination__c> cometOrders=new List<OrderDestination__c> ();
            List<OrderDestinationItem__c> cometOrderItems=new List<OrderDestinationItem__c> ();
            List<ShoppingCart__c> currentActiveShoppingCartForThisUser=[SELECT Id,Copper_Cane_Order_Number__c FROM ShoppingCart__c WHERE Active__c=true AND Account__c=:objAccount.Id AND CreatedById=:UserInfo.getUserId() AND CartStatus__c='Open' AND Program__c=:selectedProgramId ORDER BY CreatedDate];
            Chair_Budget__c chairbudget=[SELECT Id,Allocated_Budget__c,Available_Budget__c,Consumed_Budget__c,
                                         Shared_Budget__c,Chair__r.Chair_Name__c,Chair__r.Level__c,Chair__r.Active__c,
                                         Chair__r.User__c,Program__r.Name__c,Program__r.Attachment_Id__c,
                                         Program__r.Start_Date__c,Program__r.Closing_Date__c,Program__r.In_Market_Date__c,Available_Chair_Budget__c FROM Chair_Budget__c WHERE Chair__r.User__c=:UserInfo.getUserId() AND Program__c=:selectedProgramId];
            
            
            for(OrderDestination__c cometOrder : [SELECT Id,Order_Amount__c,(SELECT Id,Total_Line_Amount__c FROM OrderDestinationItems__r WHERE Quantity__c>0) FROM OrderDestination__c WHERE Order__c=:emergeOrderId])                        
            {
                totalOrderedAmount+=cometOrder.Order_Amount__c==null?0:cometOrder.Order_Amount__c;
                Decimal orderAmount=0;
                for(OrderDestinationItem__c cometOrderItem : cometOrder.OrderDestinationItems__r)
                {
                    orderAmount+=cometOrderItem.Total_Line_Amount__c;
                }
                cometOrder.Order_Amount__c=orderAmount;
                totalNewOrderedAmount+=orderAmount;
                cometOrder.Comet_Order_Status__c='Confirmed';
                cometOrders.add(cometOrder);
            }
            
            if(chairBudget.Consumed_Budget__c==null)
                chairBudget.Consumed_Budget__c=0;
            chairBudget.Consumed_Budget__c-=totalOrderedAmount;
            chairBudget.Consumed_Budget__c+=totalNewOrderedAmount;
            
            update cometOrders;
            update chairBudget;
            if(!currentActiveShoppingCartForThisUser.isEmpty())
            {
                currentActiveShoppingCartForThisUser[0].CartStatus__c='Closed';
                update currentActiveShoppingCartForThisUser[0];
            }
            
            Order__c emergeOrder = [SELECT Id, Name,(SELECT Id,OrdStatus__c,Comet_Order_Status__c FROM OrderDestinations__r WHERE OrdStatus__c='Open' AND Comet_Order_Status__c='Open'), Order_Status__c, Order_Confirmation_Date__c from Order__c WHERE ID=:emergeOrderId LIMIT 1];
            emergeOrder.Order_Status__c='This Order has been processed' ; 
            
            System.debug('emergeOrder----->'+emergeOrder);
            update emergeOrder;
            
            delete [SELECT Id FROM OrderDestination__c WHERE Order__c=:emergeOrder.Id AND Id NOT IN (SELECT OrderDestination__c FROM OrderDestinationItem__c WHERE Quantity__c>0 AND OrderDestination__r.Order__c=:emergeOrder.Id)];
            return 'Done';
        }
        catch(exception ex)
        {
            CopperEmailNotifications.sendNotification('Confirming an Order',ex.getMessage()+'\n'+'Inputs are -- emergeOrderId-- '+JSON.serialize(emergeOrderId)
                                                      +'\n'+'Class Name - CopperPreviewOrder_Apex '+'-- Line number --'+ex.getLineNumber());
            return 'Not_Done';
        }
    }
    
    //Aim : To hold the Image URL and Ordered items(this is newly added to send the image url to te frontend)
    public class CometOrders_Wrapper{     
        @AuraEnabled 
        public OrderDestinationItem__c OrderItems;
        @AuraEnabled
        public String posItemAttachmentURL;
        
        public CometOrders_Wrapper(OrderDestinationItem__c OrderItems , String posItemAttachmentURL){
            
            this.OrderItems = OrderItems;
            this.posItemAttachmentURL = posItemAttachmentURL;
            
        }
        
    }
}