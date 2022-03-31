/** Authors : TP,VM
Date : 07/01/2021
Aim : To display and save the orders in preview page of the inventory order flow*/

public class WilsonInventoryPreviewOrder_Apex {
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
                        WHERE Name LIKE '%Wilson Daniels%' LIMIT 1];
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
    /**this method is responsible for confirming the order upon preview */
    public static string confirmOrder (String orderId)
    {        
        try{
            //fetch account details and store it in the variable objAccount									
            objAccount=getAccount();
            //"to get the logged in user details		"															
            User user=getUserDetails();
            //fetch  Id , Active status Order number cart status  of the shopping cart for the logged in user where the shopping cart is active ,account is Wilson Daniels , cart status is open  and the cart belongs to the logged in user and store it in a variable currentActiveShoppingCartForThisUser of type ShoppingCart__c																					
            List<ShoppingCart__c> currentActiveShoppingCartForThisUser = [SELECT Id,Active__c,
                                                                         Wilson_Daniel_Order_Number__c,
                                                                          Account__c,
                                                                          CreatedById,
                                                                          CartStatus__c,
                                                                          Inventory_Seasonal_Program__c
                                                                          FROM ShoppingCart__c
                                                                          WHERE 
                                                                          Active__c=true AND Account__c=:objAccount.Id 
                                                                          AND CreatedById=:UserInfo.getUserId() AND CartStatus__c='Open' 
                                                                          AND Inventory_Seasonal_Program__c='Inventory' ORDER BY CreatedDate];
            //fetch order Id , name , order status , order confirmed date from Order__c for the incoming order id and store it in a variable emergeOrder of type Order__c sObject															
            Order__c emergeOrder = [SELECT Id, Name, Order_Status__c, Order_Confirmation_Date__c FROM Order__c WHERE ID=:orderId];
            //For the fetched order , change the status to 'Send to Comet'
            emergeOrder.Order_Status__c='Send to Comet';
            system.debug('emergeOrder----->'+emergeOrder);
            //Update the order in the database
            update emergeOrder;
            
            //Check if the shopping cart of the logged in user is not empty
            if(!currentActiveShoppingCartForThisUser.isEmpty())
            {
                //if yes,the shopping cart in the variable currentActiveShoppingCartForThisUser must be closed 
                currentActiveShoppingCartForThisUser[0].CartStatus__c='Closed'; 
                //Update the shopping cart in the database
                update currentActiveShoppingCartForThisUser[0];
            }
        }
        //If there is any error in the above step , send the notification to the admin
        catch(exception ex)
        {
            
            WilsonEmailNotifications.sendNotification('Confirming an Order',ex.getMessage()+'\n'+'Inputs are -- orderId-- '+JSON.serialize(orderId)
                                                      +'\n'+'Class Name - WilsonInventoryPreviewOrder_Apex '+'-- Line number --'+ex.getLineNumber());
            //Return not done if there is an error
            return 'not done';
        }
        //if the update is sucessful return done.  
        return 'done';
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