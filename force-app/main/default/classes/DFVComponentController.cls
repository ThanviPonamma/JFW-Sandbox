public class DFVComponentController {
    public static Account objAccount;
    @AuraEnabled
    public static User getUserDetails()
    {
        return [SELECT Id,UserName,Profile.Name,Profile.Id,Email FROM User WHERE Id=:UserInfo.getUserId()];
    }
    @AuraEnabled
    public static Account getAccount() { 
        if(Test.isRunningTest())
        {
            objAccount=[SELECT Id, Name,Lightning_Community_URL__c FROM Account
                        WHERE Name LIKE '%DFV%' LIMIT 1];
        }
        else
        {
            objAccount=[SELECT Id, Name,Lightning_Community_URL__c FROM Account
                        WHERE Lightning_Community_Id__c=:Network.getNetworkId() LIMIT 1];
        }
        return objAccount;
    }

    

        @AuraEnabled
        /** This method is used to load the Pos items if they already exist in the shopping cart*/
       public static List<PosItemsListWithCartDetails> loadCartItemsList()
    {
        objAccount=getAccount();
        List<PosItemsListWithCartDetails> posItemsWithCart=new List<PosItemsListWithCartDetails> ();
         /** to check a record in the shopping cart belongs to the inventory ordering flow by passing the value to the parameter as "Inventory" on change request.
                 Date - 21 Jan 2020  Author - Thanvi - CR number : DAOU-20-JAN-6 **/
        List<ShoppingCart__c> currentActiveShoppingCartForThisUser=[SELECT Id,DFV_Order_Number__c FROM ShoppingCart__c WHERE Active__c=true AND Account__c=:objAccount.Id AND CreatedById=:UserInfo.getUserId() AND CartStatus__c='Open' AND Inventory_Seasonal_Program__c='Inventory' ORDER BY CreatedDate];
        
        Map<Id,List<ShippingAddressDetailsWithQuantity>> posItemWithShippingAddressDetails=new Map<Id,List<ShippingAddressDetailsWithQuantity>> ();
        if(!currentActiveShoppingCartForThisUser.isEmpty())
        {
            if(String.isNotBlank(currentActiveShoppingCartForThisUser[0].DFV_Order_Number__c))
            {
                Map<Id,AddressBook__c> selectedAddressBookList=new Map<Id,AddressBook__c> ([SELECT Id, Name, Destination_Name__c, Shipto_Company__c, Shipto_Name__c, State__c, State__r.State_Name__c, Address__c, Division__r.Territory_Name__c, Active__c,State__r.Country__r.Country_Code__c,State__r.Country__r.Country_Name__c  FROM AddressBook__c
                                                                                            WHERE Account__C = :objAccount.ID AND Id IN (SELECT AddressBook__c FROM OrderDestination__c WHERE Order__c=:currentActiveShoppingCartForThisUser[0].DFV_Order_Number__c)]);
                Map<Id,Shipping_Method__c> selectedShippingMethod=new Map<Id,Shipping_Method__c> ([SELECT Name, Shipping_Method_Name__c, Active__c, Account__c, DisplayOrder__c, ApprovalRequired__c FROM Shipping_Method__c 
                                                                                                   WHERE Account__C =:objAccount.ID AND Id IN (SELECT Shipping_Method__c FROM OrderDestination__c WHERE Order__c=:currentActiveShoppingCartForThisUser[0].DFV_Order_Number__c)]);
                for(OrderDestinationItem__c cometOrderItem : [SELECT OrderDestination__r.AddressBook__c,OrderDestination__r.Shipping_Method__c,POS_Item__c,Quantity__c FROM OrderDestinationItem__c WHERE OrderDestination__r.Order__c=:currentActiveShoppingCartForThisUser[0].DFV_Order_Number__c])
                {
                    if(!posItemWithShippingAddressDetails.containsKey(cometOrderItem.POS_Item__c))
                        posItemWithShippingAddressDetails.put(cometOrderItem.POS_Item__c,new List<ShippingAddressDetailsWithQuantity>{new ShippingAddressDetailsWithQuantity(true,selectedAddressBookList.get(cometOrderItem.OrderDestination__r.AddressBook__c),Integer.valueOf(cometOrderItem.Quantity__c),selectedShippingMethod.get(cometOrderItem.OrderDestination__r.Shipping_Method__c),cometOrderItem.OrderDestination__r.Shipping_Method__c)});
                    else
                    {
                        List<ShippingAddressDetailsWithQuantity> shippingDetails=posItemWithShippingAddressDetails.get(cometOrderItem.POS_Item__c);
                        if(shippingDetails==null)
                            shippingDetails=new List<ShippingAddressDetailsWithQuantity> ();
                        shippingDetails.add(new ShippingAddressDetailsWithQuantity(true,selectedAddressBookList.get(cometOrderItem.OrderDestination__r.AddressBook__c),Integer.valueOf(cometOrderItem.Quantity__c),selectedShippingMethod.get(cometOrderItem.OrderDestination__r.Shipping_Method__c),cometOrderItem.OrderDestination__r.Shipping_Method__c));
                        posItemWithShippingAddressDetails.put(cometOrderItem.POS_Item__c,shippingDetails);
                    }
                }
            }
            Map<Id,POS_Item__c> posItems_Map=new Map<Id,POS_Item__c> ([SELECT Id,Item_Name__c,Active__c,Attachment_Id__c,Item_No__c,Pack_Of__c,Price__c,Logical_Invenory_Stock__c,Brand__r.Brand_Name__c,
                                                                       Approval_Required__c,Maximum_Order_Qty__c,Maximum_order_quantity_applicable__c,
                                                                       Type_of_Item__r.Item_Type__c FROM POS_Item__c WHERE Account__c=:objAccount.Id AND Id IN (SELECT POS_Item__c FROM ShoppingCartItems__c WHERE ShoppingCart__c=:currentActiveShoppingCartForThisUser[0].Id)]);
            for(POS_Item__c posItem :[SELECT Id,Attachment_Id__c,Item_Name__c,Active__c,Item_No__c,Pack_Of__c,Price__c,Logical_Invenory_Stock__c,Brand__r.Brand_Name__c,
                                      Approval_Required__c,Maximum_Order_Qty__c,Maximum_order_quantity_applicable__c,
                                      (SELECT Id,ShoppingCart__r.DFV_Order_Number__c FROM ShoppingCartItems__r WHERE ShoppingCart__r.Active__c=true AND ShoppingCart__r.Account__c=:objAccount.Id AND ShoppingCart__r.CreatedById=:UserInfo.getUserId() AND ShoppingCart__r.CartStatus__c='Open' AND ShoppingCart__r.Inventory_Seasonal_Program__c='Inventory'),
                                      Type_of_Item__r.Item_Type__c FROM POS_Item__c WHERE Account__c=:objAccount.Id AND Id IN (SELECT POS_Item__c FROM ShoppingCartItems__c WHERE ShoppingCart__c=:currentActiveShoppingCartForThisUser[0].Id) ORDER BY Item_Name__c])
            {
                if(!posItemWithShippingAddressDetails.containsKey(posItem.Id))
                    posItemsWithCart.add(new PosItemsListWithCartDetails(posItems_Map.get(posItem.Id),true,new List<ShippingAddressDetailsWithQuantity> (),(String.isBlank(posItem.ShoppingCartItems__r[0].ShoppingCart__r.DFV_Order_Number__c)?'':posItem.ShoppingCartItems__r[0].ShoppingCart__r.DFV_Order_Number__c),posItem.ShoppingCartItems__r,0,posItem.Attachments.isEmpty()?'':posItem.Attachments[0].Id));
                else
                {
                    Integer totalQuantity=0;
                    for(ShippingAddressDetailsWithQuantity eachShippingAddress: posItemWithShippingAddressDetails.get(posItem.Id))
                    {
                        totalQuantity=totalQuantity+(eachShippingAddress.quantity==null?0:eachShippingAddress.quantity);
                    }
                    posItemsWithCart.add(new PosItemsListWithCartDetails(posItems_Map.get(posItem.Id),true,posItemWithShippingAddressDetails.get(posItem.Id),(String.isBlank(posItem.ShoppingCartItems__r[0].ShoppingCart__r.DFV_Order_Number__c)?'':posItem.ShoppingCartItems__r[0].ShoppingCart__r.DFV_Order_Number__c),posItem.ShoppingCartItems__r,totalQuantity,posItem.Attachments.isEmpty()?'':posItem.Attachments[0].Id));
                    
                }
            }
        }
        return posItemsWithCart;
    }

public class PosItemsListWithCartDetails {
        @AuraEnabled
        public POS_Item__c posItem; // each pos item
        @AuraEnabled
        public Boolean isItemAddedToCart ; // it refers to whether item is added to cart or not
        @AuraEnabled
        public List<ShippingAddressDetailsWithQuantity> selectedAddressWithQtyDetails ;// this is storing added addresses from order.
        @AuraEnabled
        public String orderId ;
        @AuraEnabled 
        public List<ShoppingCartItems__c> shoppingCartItems;
        @AuraEnabled
        public Integer totalQuantityFromAllAddresses ;
        @AuraEnabled
        public String posItemImageAttachmentUrl;
        public PosItemsListWithCartDetails(POS_Item__c posItem,Boolean isItemAddedToCart,List<ShippingAddressDetailsWithQuantity> selectedAddressWithQtyDetails,String orderId,List<ShoppingCartItems__c> shoppingCartItems,Integer totalQuantityFromAllAddresses,String posItemImageAttachmentUrl )
        {
            this.posItem=posItem;
            this.isItemAddedToCart=isItemAddedToCart;
            this.selectedAddressWithQtyDetails=selectedAddressWithQtyDetails;
            this.orderId=orderId;
            this.shoppingCartItems=shoppingCartItems;
            this.totalQuantityFromAllAddresses =totalQuantityFromAllAddresses;
            this.posItemImageAttachmentUrl=posItemImageAttachmentUrl;
        }
    }
    public class ShippingAddressDetailsWithQuantity
    {
        @AuraEnabled
        public Boolean isCheckboxClicked ;
        @AuraEnabled
        public AddressBook__c selectedAddress ;
        @AuraEnabled
        public Integer quantity ;
        @AuraEnabled
        public Shipping_Method__c selectedShippingMethod;
        @AuraEnabled
        public String selectedShippingMethodId ;
        public ShippingAddressDetailsWithQuantity(Boolean isCheckboxClicked,AddressBook__c selectedAddress,Integer quantity,Shipping_Method__c selectedShippingMethod,String selectedShippingMethodId)
        {
            this.isCheckboxClicked=isCheckboxClicked;
            this.selectedAddress=selectedAddress;
            this.quantity=quantity;
            this.selectedShippingMethod=selectedShippingMethod;
            this.selectedShippingMethodId=selectedShippingMethodId;
        }
    }
}