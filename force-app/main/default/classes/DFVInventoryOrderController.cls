public class DFVInventoryOrderController {
    public static Account objAccount;
    public static List<ShippingAddressDetailsWithQuantity> allAddressBookList = new List<ShippingAddressDetailsWithQuantity>();
    
    
    
    @AuraEnabled
    public static Schema.User getUserDetails()
    {
        return [SELECT Id,UserName,International_Address_Accessible__c,Profile.Name,Profile.Id,Email FROM User WHERE Id=:UserInfo.getUserId()];
    }
    @AuraEnabled
    public static String getCurrentUserSessionIdApex()
    {
        return UserInfo.getSessionId();
    }
    @AuraEnabled
    public static User currentUser()
    {
        return [SELECT Id FROM User WHERE Id=:UserInfo.getUserId()];
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
    /** @AuraEnabled
/**this method is responsible for fetching the pos item list for inventory ordering and also to check if any item already exist in the shopping cart and belongs to the order 
public static List<PosItemsListWithCartDetails> loadPosItemsList()
{
objAccount=getAccount();
List<PosItemsListWithCartDetails> posItemsWithCart=new List<PosItemsListWithCartDetails> ();
Profile profile=[SELECT Id,Name FROM Profile WHERE Id=:UserInfo.getProfileId()];
Map<Id,POS_Item__c> posItems_Map=new Map<Id,POS_Item__c> ([SELECT Id,Attachment_Id__c,Active__c,Item_Name__c,Item_No__c,Pack_Of__c,Price__c,Logical_Invenory_Stock__c,Brand__r.Brand_Name__c,
Approval_Required__c,Maximum_Order_Qty__c,Maximum_order_quantity_applicable__c,
Type_of_Item__r.Item_Type__c FROM POS_Item__c WHERE Account__c=:objAccount.Id AND Active__c=true 
AND (Inventory_Seasonal_Program__c='Inventory' OR Inventory_Seasonal_Program__c='Both') ORDER BY Item_Name__c]);                                                       
for(POS_Item__c posItem :[SELECT Id,Attachment_Id__c,Active__c,Item_Name__c,(SELECT Id FROM Attachments Order By CreatedDate DESC),Item_No__c,Pack_Of__c,Price__c,Logical_Invenory_Stock__c,Brand__r.Brand_Name__c,
Approval_Required__c,Maximum_Order_Qty__c,Maximum_order_quantity_applicable__c,
(SELECT Id,ShoppingCart__r.DFV_Order_Number__c FROM ShoppingCartItems__r WHERE ShoppingCart__r.Active__c=true AND ShoppingCart__r.Account__c=:objAccount.Id AND ShoppingCart__r.CreatedById=:UserInfo.getUserId() AND ShoppingCart__r.CartStatus__c='Open' AND ShoppingCart__r.Inventory_Seasonal_Program__c='Inventory'),
Type_of_Item__r.Item_Type__c FROM POS_Item__c WHERE Account__c=:objAccount.Id AND Active__c=true  AND (Inventory_Seasonal_Program__c='Inventory' OR Inventory_Seasonal_Program__c='Both') ORDER BY Item_Name__c ])
{
if(!posItem.ShoppingCartItems__r.isEmpty())
posItemsWithCart.add(new PosItemsListWithCartDetails(posItems_Map.get(posItem.Id),true,new List<ShippingAddressDetailsWithQuantity> (),String.isBlank(posItem.ShoppingCartItems__r[0].ShoppingCart__r.DFV_Order_Number__c)?'':posItem.ShoppingCartItems__r[0].ShoppingCart__r.DFV_Order_Number__c,posItem.ShoppingCartItems__r,0,posItem.Attachments.isEmpty()?'':posItem.Attachments[0].Id));
else
posItemsWithCart.add(new PosItemsListWithCartDetails(posItems_Map.get(posItem.Id),false,new List<ShippingAddressDetailsWithQuantity> (),'',posItem.ShoppingCartItems__r,0,posItem.Attachments.isEmpty()?'':posItem.Attachments[0].Id));
}
return posItemsWithCart;
}**/
    @AuraEnabled
    public static List<Brand__c> loadBrandsList()
    {
        objAccount=getAccount();
        //Author:Thanvi,Varsha Date: 01-feb-2021 CR No:DFV-01-Feb-27 
        //the belowis commeneted to meet the requirements of the CR
        //The new profile is added to the DFV account - "Customer Developement"

        //return [SELECT Id,Brand_Name__c FROM Brand__c WHERE Account__c=:objAccount.Id ORDER BY Brand_Name__c ];

        //Author:Thanvi,Varsha Date: 01-feb-2021 CR No:DFV-01-Feb-27 
        //the below  is added to meet the requirements of the CR
        //The new profile is added to the DFV account - "Customer Developement" 
            
        String profileName=[Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
        //if profile name is 'customer development' fetch brand details whose  brand name is 'Customer Develoment'
        if(profileName == 'DFVCustomerDevelopment') {
            return [SELECT Id,Brand_Name__c FROM Brand__c WHERE Account__c=:objAccount.Id AND Brand_Name__c LIKE 'Customer Development'  ORDER BY Brand_Name__c ];
            
        }
       // else fetch all the brands and it's details which belong to DFV
        else {

            return [SELECT Id,Brand_Name__c FROM Brand__c WHERE Account__c=:objAccount.Id ORDER BY Brand_Name__c ];
        }
    }
    @AuraEnabled
    public static List<Item_Type__c> loadItemTypesList()
    {
        objAccount=getAccount();
        return [SELECT Id,Item_Type__c FROM Item_Type__c WHERE Account__c=:objAccount.Id ORDER BY Item_Type__c];
    }
    public class PosItem_DetailsWrapper
    {
        @AuraEnabled
        public Boolean isItemAddedToCart ;  
        @AuraEnabled
        public POS_Item__c posItem;
        @AuraEnabled
        public Boolean isItemProcessing;
        
        public PosItem_DetailsWrapper(Boolean isItemAddedToCart,POS_Item__c posItem,Boolean isItemProcessing)
        {
            this.isItemAddedToCart=isItemAddedToCart;
            this.posItem=posItem;
            this.isItemProcessing=isItemProcessing;
        }
    }
    
    public class PosItem_DetailsListWrapper
    {
        @AuraEnabled
        public List<PosItem_DetailsWrapper> PosItemDetails;
        @AuraEnabled
        public Integer totalPosItemsSize;
        @AuraEnabled
        public Integer totalCartItemsSize;
        public PosItem_DetailsListWrapper (List<PosItem_DetailsWrapper> PosItemDetails,
                                           Integer totalPosItemsSize, Integer totalCartItemsSize)
        {
            this.PosItemDetails=PosItemDetails;
            this.totalPosItemsSize=totalPosItemsSize;
            this.totalCartItemsSize=totalCartItemsSize;
        }
        
    }
    @AuraEnabled
    public static PosItem_DetailsListWrapper loadPosItemsQueryList (String searchPosItemKeyword,String chosenBrandId,
                                                                    String chosenItemTypeId,String sortById,Integer recordStartIndex)
    {
        objAccount=getAccount();
        Set<Id> posItemIdsInCart=new Set<Id> ();
        List<POS_Item__c> posItems=new List<POS_Item__c> ();
        List<PosItem_DetailsWrapper> posItemDetails=new List<PosItem_DetailsWrapper> ();
        String Inventory= 'Inventory';
        String Both= 'Both';
        //Autors - Thanvi,Sanjana Date - 14-02-2020
        //The condition Inventory_Seasonal_Program__c='Inventory' is introduced to fetch all the Pos items in the shopping cart that belonged to inventory
        for(ShoppingCartItems__c shoppingCartItem : [SELECT POS_Item__c FROM ShoppingCartItems__c WHERE ShoppingCart__r.Active__c=true AND ShoppingCart__r.Account__c=:objAccount.Id AND ShoppingCart__r.CreatedById=:UserInfo.getUserId() AND ShoppingCart__r.Inventory_Seasonal_Program__c='Inventory' AND ShoppingCart__r.CartStatus__c='Open'])
            posItemIdsInCart.add(shoppingCartItem.POS_Item__c);

        String profileName=[Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;

        // CR Number: DFV-19-Feb-5   Date: 20-02-2020 Author:Thanvi
        //Only the items whose logical inventory is greater than 0 is displayed 
        
        String getAllPosItems='SELECT Id,Attachment_Id__c,Item_Descrption__c,Active__c,Item_Name__c,Item_No__c,Pack_Of__c,Logical_Invenory_Stock__c,Brand__r.Brand_Name__c,Approval_Required__c,Maximum_Order_Qty__c,Maximum_order_quantity_applicable__c,Marketing_Only__c,Price__c,Type_of_Item__r.Item_Type__c,Inventory_Seasonal_Program__c';
        
        //Author:Thanvi Date: 12-03-2020 CR No:DFV-12-Mar-1
        //obtain the profile name of the logged in user, and check if the logged in user is salesmanager or brand manager if so then do not show marketing only item,
        //else show the all the items including marketing only
        
        //Author:Thanvi,Varsha Date: 01-feb-2021 CR No:DFV-01-Feb-27 
        //the below if else confition is commenetd to meet the requirements of the CR
        //The new profile is added to the DFV account - "Customer Developement"     
        /**if(profileName == 'DFVsalesmanager' || profileName =='DFVBrandmanager') {
            getAllPosItems=getAllPosItems+' FROM POS_Item__c WHERE Account__c=\''+objAccount.Id+'\' AND Marketing_Only__c=false AND Active__c=true AND Logical_Invenory_Stock__c>0 AND ( Inventory_Seasonal_Program__c=\''+Inventory+'\' OR  Inventory_Seasonal_Program__c=\''+Both+'\')';
        }
        
        else {
            getAllPosItems=getAllPosItems+' FROM POS_Item__c WHERE Account__c=\''+objAccount.Id+'\' AND Active__c=true AND Logical_Invenory_Stock__c>0 AND ( Inventory_Seasonal_Program__c=\''+Inventory+'\' OR  Inventory_Seasonal_Program__c=\''+Both+'\')';
        }**/
        
        //Author:Thanvi,Varsha Date: 01-feb-2021 CR No:DFV-01-Feb-27 
        //the below if else-if else confition is added to meet the requirements of the CR
        //The new profile is added to the DFV account - "Customer Developement"     
        //if profile name is brandmanager/salesmanage fetch pos items with the its conditions
        if(profileName == 'DFVsalesmanager' || profileName =='DFVBrandmanager') {
            getAllPosItems=getAllPosItems+' FROM POS_Item__c WHERE Account__c=\''+objAccount.Id+'\' AND Marketing_Only__c=false AND Active__c=true AND Logical_Invenory_Stock__c>0 AND ( Inventory_Seasonal_Program__c=\''+Inventory+'\' OR  Inventory_Seasonal_Program__c=\''+Both+'\')';
        }
        //else if the profile name is customer development and fetch the items that belong to the brand name - 'customer development'
        else if(profileName == 'DFVCustomerDevelopment')
        {
            //to hold the customer development brand name.
            String CustomerDevelopment = 'Customer Development';
            //Author:Thanvi,Varsha Date: 03-feb-2021 CR No:DFV-03-Feb-28  
            //the below line is commented to meet the requirements of the CR. To alllow the access to marketing only items
            // getAllPosItems=getAllPosItems+' FROM POS_Item__c WHERE Account__c=\''+objAccount.Id+'\' AND Marketing_Only__c=false AND Active__c=true AND Logical_Invenory_Stock__c>0 AND ( Inventory_Seasonal_Program__c=\''+Inventory+'\' OR  Inventory_Seasonal_Program__c=\''+Both+'\') AND Brand__r.Brand_Name__c LIKE :CustomerDevelopment';

            getAllPosItems=getAllPosItems+' FROM POS_Item__c WHERE Account__c=\''+objAccount.Id+'\' AND Active__c=true AND Logical_Invenory_Stock__c>0 AND ( Inventory_Seasonal_Program__c=\''+Inventory+'\' OR  Inventory_Seasonal_Program__c=\''+Both+'\') AND Brand__r.Brand_Name__c LIKE :CustomerDevelopment';
        } 
        //else profile is admin/adminrpt then fetch pos item with its filter condition
        else {
            getAllPosItems=getAllPosItems+' FROM POS_Item__c WHERE Account__c=\''+objAccount.Id+'\' AND Active__c=true AND Logical_Invenory_Stock__c>0 AND ( Inventory_Seasonal_Program__c=\''+Inventory+'\' OR  Inventory_Seasonal_Program__c=\''+Both+'\')';
        }
        
        //System.debug('getAllPosItems'+getAllPosItems);
        String whereCondition=''; 
        
        String sortByOption='';
        //  System.debug('sortByOption'+sortByOption);
        String offsetValue='';
        // System.debug('offsetValue'+offsetValue);
        if(String.isNotBlank(searchPosItemKeyword))
        {
            searchPosItemKeyword='%'+searchPosItemKeyword+'%';
            whereCondition=whereCondition+' AND (Item_Name__c LIKE : searchPosItemKeyword OR Item_No__c LIKE : searchPosItemKeyword) ';
        }
        if(String.isNotBlank(chosenBrandId))
            whereCondition=whereCondition+' AND Brand__c =:chosenBrandId ';
        if(String.isNotBlank(chosenItemTypeId))
            whereCondition=whereCondition+' AND Type_of_Item__c =:chosenItemTypeId ';
        if(String.isNotBlank(sortById))
        {
            if(sortById=='LAST_N_DAYS')
                whereCondition=whereCondition+' AND CreatedDate = LAST_N_DAYS:10 ORDER BY CreatedDate DESC ';
            else
            {
                if(sortById != 'RECENT_ADDED_CARTITEMS')
                    sortByOption=' ORDER BY '+sortById;
            }
        }
        else
            sortByOption=' ORDER BY Item_Name__c ';
        System.debug('sortByOption'+sortByOption);
        List<POS_Item__c> posItems_bySearch=Database.query(getAllPosItems+whereCondition+sortByOption);
        System.debug('posItems_bySearch'+posItems_bySearch);
        System.debug('posItems_bySearch Size'+posItems_bySearch.size());
        if(sortById == 'LAST_N_DAYS')
        {
            List<POS_Item__C> items=new List<POS_Item__C> ();  
            List<POS_Item__C> cartItems=[SELECT Id,Item_Name__c,Attachment_Id__c,Active__c,Item_No__c,Pack_Of__c,Logical_Invenory_Stock__c,Brand__r.Brand_Name__c,Approval_Required__c,Item_Descrption__c,
                                         Maximum_Order_Qty__c,Maximum_order_quantity_applicable__c,Type_of_Item__r.Item_Type__c              
                                         FROM POS_Item__c WHERE (Inventory_Seasonal_Program__c='Inventory' OR Inventory_Seasonal_Program__c='Both') AND Account__c=:objAccount.Id AND Id IN :posItems_bySearch 
                                         AND Id IN (SELECT POS_Item__c FROM ShoppingCartItems__c WHERE ShoppingCart__r.Active__c=true AND ShoppingCart__r.Account__c=:objAccount.Id AND ShoppingCart__r.CreatedById=:UserInfo.getUserId() AND ShoppingCart__r.CartStatus__c='Open') 
                                         ORDER BY Item_Name__c];
            List<POS_Item__C> nonCartItems=[SELECT Id,Item_Name__c,Attachment_Id__c,Active__c,Item_No__c,Pack_Of__c,Logical_Invenory_Stock__c,Brand__r.Brand_Name__c,Approval_Required__c,Item_Descrption__c,
                                            Maximum_Order_Qty__c,Maximum_order_quantity_applicable__c,Type_of_Item__r.Item_Type__c
                                            FROM POS_Item__c WHERE (Inventory_Seasonal_Program__c='Inventory' OR Inventory_Seasonal_Program__c='Both') AND  Account__c=:objAccount.Id AND Id IN :posItems_bySearch 
                                            AND Id NOT IN (SELECT POS_Item__c FROM ShoppingCartItems__c WHERE ShoppingCart__r.Active__c=true AND ShoppingCart__r.Account__c=:objAccount.Id AND ShoppingCart__r.CreatedById=:UserInfo.getUserId() AND ShoppingCart__r.CartStatus__c='Open' ) ORDER BY Item_Name__c];
            // System.debug('cartItems'+cartItems);
            //System.debug('nonCartItems'+nonCartItems);
            
            items.addAll(cartItems);
            items.addAll(nonCartItems);
            System.debug('items'+items);
            System.debug('items Size'+items.size());
            for(Integer i=recordStartIndex==null?0:recordStartIndex;i<=recordStartIndex+11;i++)
            {
                if(i<items.size())
                    posItems.add(items[i]);
                
            }
            
        }
        else
        {
            for(Integer i=recordStartIndex==null?0:recordStartIndex;i<=recordStartIndex+11;i++)
            {
                if(i<posItems_bySearch.size())
                    posItems.add(posItems_bySearch[i]);
            }
            // System.debug('posItems'+posItems);
        }
        for(POS_Item__c posItem :posItems)
            posItemDetails.add(new PosItem_DetailsWrapper(posItemIdsInCart.contains(posItem.Id),posItem,false));
        System.debug('posItemDetails'+posItemDetails);
        // System.debug('',)
        return new PosItem_DetailsListWrapper(posItemDetails,posItems_bySearch.size(),posItemIdsInCart.size());
    }
    @AuraEnabled
    /**this method is responsible for adding the selected pos item for inventory ordering**/
    public static List<PosItemsListWithCartDetails> addItemToCart(String selectedPosItemId)
    {
        try{
            
            // System.debug(selectedPosItemId);
            System.debug(selectedPosItemId);
            User user=currentUser();
            objAccount=getAccount();
            List<ShoppingCart__c> currentActiveShoppingCartForThisUser=[SELECT Id FROM ShoppingCart__c 
                                                                        WHERE Active__c=true 
                                                                        AND Account__c=:objAccount.Id 
                                                                        AND CreatedById=:user.Id 
                                                                        AND CartStatus__c='Open' 
                                                                        AND Inventory_Seasonal_Program__c='Inventory' 
                                                                        ORDER BY CreatedDate];
            if(currentActiveShoppingCartForThisUser.isEmpty())
            {
                ShoppingCart__c shoppingCart=new ShoppingCart__c();
                shoppingCart.Active__c=true;
                shoppingCart.CartStatus__c='Open';
                shoppingCart.Account__c=objAccount.Id;
                shoppingCart.Inventory_Seasonal_Program__c = 'Inventory';
                insert shoppingCart;
                ShoppingCartItems__c shoppingCartItem=new ShoppingCartItems__c();
                shoppingCartItem.Active__c=true;
                shoppingCartItem.POS_Item__c=selectedPosItemId;
                shoppingCartItem.ShoppingCart__c=shoppingCart.Id;
                insert shoppingCartItem;
            }
            else
            {
                if([SELECT Id FROM POS_Item__c WHERE Id=:selectedPosItemId AND Id IN (SELECT POS_Item__c FROM ShoppingCartItems__c WHERE ShoppingCart__c=:currentActiveShoppingCartForThisUser[0].Id)].isEmpty())
                {
                    ShoppingCartItems__c shoppingCartItem=new ShoppingCartItems__c();
                    shoppingCartItem.Active__c=true;
                    shoppingCartItem.POS_Item__c=selectedPosItemId;
                    shoppingCartItem.ShoppingCart__c=currentActiveShoppingCartForThisUser[0].Id;
                    insert shoppingCartItem;
                }
            }
        }catch(Exception ex)
        {
            DFVEmailNotifications.sendNotification('Adding Item To Cart',ex.getMessage()+'\n'+'Inputs are -- selectedPosItemId-- '+JSON.serialize(selectedPosItemId)
                                                   +'\n'+'Class Name - DFVInventoryOrderController '+'-- Line number --'+ex.getLineNumber());
        }
        return loadCartItemsList();
    }
    @AuraEnabled
    /**this method is responsible for removing the selected pos item for inventory ordering**/
    public static List<PosItemsListWithCartDetails> removeItemFromCart (String selectedPosItemId)
    {
        try{
            User user=currentUser();
            objAccount=getAccount();
            /** to create a record in the shopping cart for inventory ordering flow by passing the value to the parameter as "Inventory" on change request.
Date - 21 Jan 2020  Author - Thanvi - CR number : DAOU-20-JAN-5 **/
            List<ShoppingCart__c> currentActiveShoppingCartForThisUser=[SELECT Id,DFV_Order_Number__c FROM ShoppingCart__c WHERE Active__c=true AND Account__c=:objAccount.Id AND CreatedById=:user.Id AND CartStatus__c='Open' AND Inventory_Seasonal_Program__c='Inventory' ORDER BY CreatedDate];
            delete [SELECT Id FROM ShoppingCartItems__c WHERE POS_Item__c=:selectedPosItemId AND ShoppingCart__c=:currentActiveShoppingCartForThisUser[0].Id];
            List<OrderDestinationItem__c> cometOrderItems=[SELECT Id FROM OrderDestinationItem__c WHERE OrderDestination__r.Order__c=:currentActiveShoppingCartForThisUser[0].DFV_Order_Number__c AND POS_Item__c=:selectedPosItemId];
            delete cometOrderItems;
            List<OrderDestination__c> cometOrders=[SELECT Id FROM OrderDestination__c WHERE Order__c=:currentActiveShoppingCartForThisUser[0].DFV_Order_Number__c AND Id NOT IN (SELECT OrderDestination__c  FROM OrderDestinationItem__c)]; 
            delete cometOrders;
        }
        catch(Exception ex)
        {
            DFVEmailNotifications.sendNotification('Removing Items To Cart',ex.getMessage()+'\n'+'Inputs are -- selectedPosItemId-- '+JSON.serialize(selectedPosItemId)
                                                   +'\n'+'Class Name - DFVInventoryOrderController '+'-- Line number --'+ex.getLineNumber());
        }
        
        return loadCartItemsList();
    }
    @AuraEnabled
    public static List<PosItemsListWithCartDetails> addItemsToCart(String posItemsListWithCart)
    {
        try{
            objAccount=getAccount();
            Map<Id,PosItemsListWithCartDetails> posItemIdWithCartDetails=new Map<Id,PosItemsListWithCartDetails> ();
            System.debug(posItemsListWithCart);
            if(String.isNotBlank(posItemsListWithCart))
                for(PosItemsListWithCartDetails posItemWithCart:(List<PosItemsListWithCartDetails>)System.JSON.deserialize(posItemsListWithCart, List<PosItemsListWithCartDetails>.class))
                posItemIdWithCartDetails.put(posItemWithCart.posItem.Id,posItemWithCart);
            List<ShoppingCart__c> currentActiveShoppingCartForThisUser=[SELECT Id,DFV_Order_Number__c FROM ShoppingCart__c WHERE Active__c=true AND Account__c=:objAccount.Id AND CreatedById=:UserInfo.getUserId() AND CartStatus__c='Open' ORDER BY CreatedDate];
            //  Map<Id,Pos_Item__c> existingShoppingCartItems=new Map<Id,Pos_Item__c> ([SELECT Id,Attachment_Id__c,Active__c FROM POS_Item__c WHERE Id IN (SELECT Pos_Item__c FROM ShoppingCartItems__c WHERE ShoppingCart__c=:currentActiveShoppingCartForThisUser[0].Id)]);
            // delete [SELECT Id FROM ShoppingCartItems__c WHERE ShoppingCart__c=:currentActiveShoppingCartForThisUser[0].Id AND POS_Item__c NOT IN :posItemIdWithCartDetails.keySet()];
            delete [SELECT Id FROM ShoppingCartItems__c WHERE ShoppingCart__c=:currentActiveShoppingCartForThisUser[0].Id];
            // Map<Id,Pos_Item__c> existingShoppingCartItems=new Map<Id,Pos_Item__c> ([SELECT Id,Attachment_Id__c,Active__c FROM POS_Item__c WHERE Id IN (SELECT Pos_Item__c FROM ShoppingCartItems__c WHERE ShoppingCart__c=:currentActiveShoppingCartForThisUser[0].Id)]);
            List<ShoppingCartItems__c> newShoppingCartItems=new List<ShoppingCartItems__c> ();
            // System.debug(existingShoppingCartItems);
            for(Id posItemId:posItemIdWithCartDetails.keySet())
            {
                // if(!existingShoppingCartItems.containsKey(posItemId))
                //  {
                ShoppingCartItems__c shoppingCartItem=new ShoppingCartItems__c();
                shoppingCartItem.Active__c=true;
                shoppingCartItem.POS_Item__c=posItemId;
                shoppingCartItem.ShoppingCart__c=currentActiveShoppingCartForThisUser[0].Id;
                newShoppingCartItems.add(shoppingCartItem);
                //  }
            }
            insert newShoppingCartItems;
            if(String.isNotBlank(currentActiveShoppingCartForThisUser[0].DFV_Order_Number__c))
            {
                List<OrderDestinationItem__c> cometOrderItems=[SELECT Id FROM OrderDestinationItem__c WHERE OrderDestination__r.Order__c=:currentActiveShoppingCartForThisUser[0].DFV_Order_Number__c AND POS_Item__c NOT IN : posItemIdWithCartDetails.keySet()];
                delete cometOrderItems;
                delete [SELECT Id FROM OrderDestination__c WHERE Order__c=:currentActiveShoppingCartForThisUser[0].DFV_Order_Number__c AND Id NOT IN (SELECT OrderDestination__c FROM OrderDestinationItem__c WHERE OrderDestination__r.Order__c=:currentActiveShoppingCartForThisUser[0].DFV_Order_Number__c)];
            }
            //List<Id,[SELECT Id FROM ShoppingCartItems__c WHERE ShoppingCart__c ];
        }
        catch(Exception ex)
        {
            DFVEmailNotifications.sendNotification('Inserting Items To Cart',ex.getMessage()+'\n'+'Inputs are -- posItemsListWithCart-- '+JSON.serialize(posItemsListWithCart)
                                                   +'\n'+'Class Name - DFVInventoryOrderController '+'-- Line number --'+ex.getLineNumber());
        }
        return loadCartItemsList();
    }
    
    /** Changing the actor name of the apex method createShoppingCart to createInventoryShoppingCart_Apex  on change request.
Date - 21 Jan 2020  Author - Thanvi - CR number : DAOU-20-JAN-1 **/
    @AuraEnabled 
    /** This method is used to create a record in the shopping cart to a user if the user doesn't have a shopping cart already */
    public static String createInventoryShoppingCart_Apex()
    {
        try{
            objAccount=getAccount();
            List<ShoppingCart__c> currentActiveShoppingCartForThisUser=[SELECT Id FROM ShoppingCart__c WHERE Active__c=true AND Account__c=:objAccount.Id AND CreatedById=:UserInfo.getUserId() AND CartStatus__c='Open' AND Inventory_Seasonal_Program__c='Inventory' ORDER BY CreatedDate];
            if(currentActiveShoppingCartForThisUser.isEmpty())
            {
                ShoppingCart__c shoppingCart=new ShoppingCart__c();
                shoppingCart.Active__c=true;
                shoppingCart.CartStatus__c='Open';
                shoppingCart.Account__c=objAccount.Id;
                /** to create a record in the shopping cart for inventory ordering flow by passing the value to the parameter as "Inventory" on change request.
Date - 21 Jan 2020  Author - Thanvi - CR number : DAOU-20-JAN-1 **/
                shoppingCart.Inventory_Seasonal_Program__c = 'Inventory';
                insert shoppingCart;
                return 'new Cart is created';
            }
            else
            {
                return 'Cart already exists';
            }
        }
        catch(exception ex)
        {
            DFVEmailNotifications.sendNotification('Creating a cart',ex.getMessage()+'\n' +'\n'+'Class Name - DFVInventoryOrderController '+'-- Line number --'+ex.getLineNumber());
            //  DFVEmailNotifications.sendNotification('Inserting a Cart',ex.getMessage()+'\n'+'Class Name - DFVInventoryOrderController '+'-- Line number --'+ex.getLineNumber());
            return 'Not Done';
        }
        
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
        
        //system.debug('currentActiveShoppingCartForThisUser-->'+currentActiveShoppingCartForThisUser[0]);
        
        Map<Id,List<ShippingAddressDetailsWithQuantity>> posItemWithShippingAddressDetails=new Map<Id,List<ShippingAddressDetailsWithQuantity>> ();
        if(!currentActiveShoppingCartForThisUser.isEmpty())
        {
            if(String.isNotBlank(currentActiveShoppingCartForThisUser[0].DFV_Order_Number__c))
            {
                Map<Id,AddressBook__c> selectedAddressBookList=new Map<Id,AddressBook__c> ([SELECT Id, Name, Destination_Name__c, Shipto_Company__c, Shipto_Name__c, State__c, State__r.State_Name__c, Address__c, Division__r.Territory_Name__c, Active__c,State__r.Country__r.Country_Code__c,State__r.Country__r.Country_Name__c  FROM AddressBook__c
                                                                                            WHERE Account__C = :objAccount.ID AND Id IN (SELECT AddressBook__c FROM OrderDestination__c WHERE Order__c=:currentActiveShoppingCartForThisUser[0].DFV_Order_Number__c)]);
                Map<Id,Shipping_Method__c> selectedShippingMethod=new Map<Id,Shipping_Method__c> ([SELECT Name, Shipping_Method_Name__c, Active__c, Account__c, DisplayOrder__c, ApprovalRequired__c FROM Shipping_Method__c 
                                                                                                   WHERE Account__C =:objAccount.ID AND Id IN (SELECT Shipping_Method__c FROM OrderDestination__c WHERE Order__c=:currentActiveShoppingCartForThisUser[0].DFV_Order_Number__c)]);
                system.debug('cometOrderItem--->'+[SELECT OrderDestination__r.AddressBook__c,OrderDestination__r.Shipping_Method__c,POS_Item__c,Quantity__c 
                                                   FROM OrderDestinationItem__c 
                                                   WHERE OrderDestination__r.Order__c=:currentActiveShoppingCartForThisUser[0].DFV_Order_Number__c]);
                system.debug('DFV order number-->'+currentActiveShoppingCartForThisUser[0].DFV_Order_Number__c);
                for(OrderDestinationItem__c cometOrderItem : [SELECT OrderDestination__r.AddressBook__c,
                                                              OrderDestination__r.Shipping_Method__c,POS_Item__c,Quantity__c 
                                                              FROM OrderDestinationItem__c 
                                                              WHERE OrderDestination__r.Order__c=:currentActiveShoppingCartForThisUser[0].DFV_Order_Number__c])
                    
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
    
   /** @AuraEnabled
    public static ShippingAddressDetailsWithPagination loadUserAddressBookList(String selectedAddresses,String posItemsListWithCart,String selectedRadioType, Integer recordStartIndex )
    {
        // System.debug(selectedAddresses);
        objAccount=getAccount();
        User user=getUserDetails();
        Set<Id> allPosItemIds=new Set<Id> ();
        Map<Id,Integer> addressIdWithCount=new Map<Id,Integer> ();
        Map<Id,String> addressIdWithShippingMethodId=new Map<Id,String> ();
        Set<Id> userStateIds=new Set<Id> ();
        Map<Id,ShippingAddressDetailsWithQuantity> selectedAddresses_Map = new Map<Id,ShippingAddressDetailsWithQuantity>();
        
        
        //Added by  VB, JP, RM on 01.06.2020 
        //Ref: CR No: DFV-03-Jun-1 
        //Aim: To hold the list of pagination addresses.
        List<ShippingAddressDetailsWithQuantity> paginatedShippingAddressesWithQuantity = new List<ShippingAddressDetailsWithQuantity>();
        //Added by  VB, JP, RM on 01.06.2020
        //Ref: CR No: DFV-03-Jun-1 
        //Aim: To hold list of pagination addresses, size of  all addresses and all addresses.  
        ShippingAddressDetailsWithPagination shippingAddressesDetailsWithTotalSize=new ShippingAddressDetailsWithPagination();
        
        
        if(String.isNotBlank(selectedAddresses))
        {
            //selectedAddresses_Map.putAll(selectedAddresses);  
            for(ShippingAddressDetailsWithQuantity shippingAddressDetail:(List<ShippingAddressDetailsWithQuantity>)System.JSON.deserialize(selectedAddresses, List<ShippingAddressDetailsWithQuantity>.class))
            {
                selectedAddresses_Map.put(shippingAddressDetail.selectedAddress.Id,shippingAddressDetail);
            }
        }
        System.debug(selectedAddresses_Map);
        List<ShippingAddressDetailsWithQuantity> shippingAddressesWithQuantity=new List<ShippingAddressDetailsWithQuantity> ();
        List<ShippingAddressDetailsWithQuantity> shippingAddressesWithQuantity_Selected=new List<ShippingAddressDetailsWithQuantity> ();
        for(PosItemsListWithCartDetails posItemWithCartDetail : (List<PosItemsListWithCartDetails>)System.JSON.deserialize(posItemsListWithCart, List<PosItemsListWithCartDetails>.class))
        {
            allPosItemIds.add(posItemWithCartDetail.posItem.Id);
            for(ShippingAddressDetailsWithQuantity shippingAddressDetail : posItemWithCartDetail.selectedAddressWithQtyDetails)
            {
                if(!addressIdWithCount.containsKey(shippingAddressDetail.selectedAddress.Id))
                    addressIdWithCount.put(shippingAddressDetail.selectedAddress.Id,1);
                else
                {
                    Integer quantity=addressIdWithCount.get(shippingAddressDetail.selectedAddress.Id);
                    if(quantity == null)
                        quantity=0;
                    quantity=quantity+1;
                    addressIdWithCount.put(shippingAddressDetail.selectedAddress.Id,quantity);
                }
                
                if(!addressIdWithShippingMethodId.containsKey(shippingAddressDetail.selectedAddress.Id))
                    addressIdWithShippingMethodId.put(shippingAddressDetail.selectedAddress.Id,shippingAddressDetail.selectedShippingMethodId);
            }
        }
        
        if(selectedRadioType == 'ALL' || selectedRadioType == 'DOMESTIC')
            for(States_Territory__c stateTerritory : [SELECT ID, Name, State__c FROM States_Territory__c WHERE Territory__c IN ( SELECT Territory__c FROM Users_Territory__c WHERE (User__c =:UserInfo.getUserId() OR User__c='005L0000003z7qu')) ])
            userStateIds.add(stateTerritory.State__c);
        if((selectedRadioType == 'INTERNATIONAL' || selectedRadioType == 'ALL' ) && user.International_Address_Accessible__c)
            for(State__c state : [SELECT Id FROM State__c WHERE Country__r.Is_It_International_Country__c=true])
            userStateIds.add(state.Id);
        
        for(AddressBook__c addressBook : [SELECT Id, Name,City__c, Destination_Name__c, Shipto_Company__c, Shipto_Name__c, State__c, State__r.State_Name__c, Address__c, Division__r.Territory_Name__c, Active__c,State__r.Country__r.Country_Code__c,State__r.Country__r.Country_Name__c  FROM AddressBook__c 
                                          WHERE Account__C = :objAccount.ID AND Active__c=True AND (State__c IN :userStateIds) ORDER BY Destination_Name__c ASC])
        {
            if(addressIdWithCount.containsKey(addressBook.Id))
            {
                if(addressIdWithCount.get(addressBook.Id) == allPosItemIds.size())
                    shippingAddressesWithQuantity.add(new ShippingAddressDetailsWithQuantity(true,addressBook,0,new Shipping_Method__c(),addressIdWithShippingMethodId.get(addressBook.Id)));
                else
                    shippingAddressesWithQuantity.add(new ShippingAddressDetailsWithQuantity(false,addressBook,0,new Shipping_Method__c(),addressIdWithShippingMethodId.get(addressBook.Id)));
            }
            else
            {
                shippingAddressesWithQuantity.add(new ShippingAddressDetailsWithQuantity(false,addressBook,0,new Shipping_Method__c(),''));
            }
            allAddressBookList = shippingAddressesWithQuantity;
            
        }
        system.debug('allAddressBookList---->'+allAddressBookList.size());
        
        
        //Added by  VB, JP, RM on 01.06.2020
        //Ref: CR No: DFV-03-Jun-1
        //Aim: To get the list of address based on pagination index
        for(Integer i=recordStartIndex==null?0:recordStartIndex;i<=recordStartIndex+99;i++)
        {
            if(i<shippingAddressesWithQuantity.size())
                paginatedShippingAddressesWithQuantity.add(shippingAddressesWithQuantity[i]);
            
        }
        
        for(ShippingAddressDetailsWithQuantity eachShippingAddressWithQuantity:paginatedShippingAddressesWithQuantity)
        {
            if(selectedAddresses_Map.containsKey(eachShippingAddressWithQuantity.selectedAddress.Id))
            {
                shippingAddressesWithQuantity_Selected.add(selectedAddresses_Map.get(eachShippingAddressWithQuantity.selectedAddress.Id));   
            }
            else
            {
                shippingAddressesWithQuantity_Selected.add(eachShippingAddressWithQuantity);
            }
            
        }
        System.debug('shippingAddressesWithQuantity-->'+shippingAddressesWithQuantity_Selected);
        
        //Added by  VB, JP, RM on 01.06.2020
        //Ref: CR No: DFV-03-Jun-1
        //To form the result for front end
        shippingAddressesDetailsWithTotalSize.shippingAddressWithQtyDetails = shippingAddressesWithQuantity_Selected;
        shippingAddressesDetailsWithTotalSize.totalShippingAddressSize = shippingAddressesWithQuantity.size();
        shippingAddressesDetailsWithTotalSize.allAddresses = allAddressBookList;
        
        
        return shippingAddressesDetailsWithTotalSize;
    }**/
    
     @AuraEnabled
    public static ShippingAddressDetailsWithPagination loadUserAddressBookList(String selectedAddresses,String posItemsListWithCart,String selectedRadioType, Integer recordStartIndex )
    {
        // System.debug(selectedAddresses);
        objAccount=getAccount();
        User user=getUserDetails();
        Set<Id> allPosItemIds=new Set<Id> ();
        Map<Id,Integer> addressIdWithCount=new Map<Id,Integer> ();
        Map<Id,String> addressIdWithShippingMethodId=new Map<Id,String> ();
        Set<Id> userStateIds=new Set<Id> ();
        Map<Id,ShippingAddressDetailsWithQuantity> selectedAddresses_Map = new Map<Id,ShippingAddressDetailsWithQuantity>();
        
        
        //Added by  VB, JP, RM on 01.06.2020 
        //Ref: CR No: DFV-03-Jun-1 
        //Aim: To hold the list of pagination addresses.
        List<ShippingAddressDetailsWithQuantity> paginatedShippingAddressesWithQuantity = new List<ShippingAddressDetailsWithQuantity>();
        //Added by  VB, JP, RM on 01.06.2020
        //Ref: CR No: DFV-03-Jun-1 
        //Aim: To hold list of pagination addresses, size of  all addresses and all addresses.  
        ShippingAddressDetailsWithPagination shippingAddressesDetailsWithTotalSize=new ShippingAddressDetailsWithPagination();
        
        
        if(String.isNotBlank(selectedAddresses))
        {
            //selectedAddresses_Map.putAll(selectedAddresses);  
            for(ShippingAddressDetailsWithQuantity shippingAddressDetail:(List<ShippingAddressDetailsWithQuantity>)System.JSON.deserialize(selectedAddresses, List<ShippingAddressDetailsWithQuantity>.class))
            {
                selectedAddresses_Map.put(shippingAddressDetail.selectedAddress.Id,shippingAddressDetail);
            }
        }
        System.debug(selectedAddresses_Map);
        List<ShippingAddressDetailsWithQuantity> shippingAddressesWithQuantity=new List<ShippingAddressDetailsWithQuantity> ();
        List<ShippingAddressDetailsWithQuantity> shippingAddressesWithQuantity_Selected=new List<ShippingAddressDetailsWithQuantity> ();
        for(PosItemsListWithCartDetails posItemWithCartDetail : (List<PosItemsListWithCartDetails>)System.JSON.deserialize(posItemsListWithCart, List<PosItemsListWithCartDetails>.class))
        {
            allPosItemIds.add(posItemWithCartDetail.posItem.Id);
            for(ShippingAddressDetailsWithQuantity shippingAddressDetail : posItemWithCartDetail.selectedAddressWithQtyDetails)
            {
                if(!addressIdWithCount.containsKey(shippingAddressDetail.selectedAddress.Id))
                    addressIdWithCount.put(shippingAddressDetail.selectedAddress.Id,1);
                else
                {
                    Integer quantity=addressIdWithCount.get(shippingAddressDetail.selectedAddress.Id);
                    if(quantity == null)
                        quantity=0;
                    quantity=quantity+1;
                    addressIdWithCount.put(shippingAddressDetail.selectedAddress.Id,quantity);
                }
                
                if(!addressIdWithShippingMethodId.containsKey(shippingAddressDetail.selectedAddress.Id))
                    addressIdWithShippingMethodId.put(shippingAddressDetail.selectedAddress.Id,shippingAddressDetail.selectedShippingMethodId);
            }
        }
        
        if(selectedRadioType == 'ALL' || selectedRadioType == 'DOMESTIC')
            for(States_Territory__c stateTerritory : [SELECT ID, Name, State__c FROM States_Territory__c WHERE State__r.Country__r.Is_It_International_Country__c=false AND Territory__c IN ( SELECT Territory__c FROM Users_Territory__c WHERE (User__c =:UserInfo.getUserId()))])
            userStateIds.add(stateTerritory.State__c);
        if((selectedRadioType == 'INTERNATIONAL' || selectedRadioType == 'ALL' ) && user.International_Address_Accessible__c)
            for(State__c state : [SELECT Id FROM State__c WHERE Country__r.Is_It_International_Country__c=true])
            userStateIds.add(state.Id);
        
        for(AddressBook__c addressBook : [SELECT Id, Name,City__c, Destination_Name__c, Shipto_Company__c, Shipto_Name__c, State__c, State__r.State_Name__c, Address__c, Division__r.Territory_Name__c, Active__c,State__r.Country__r.Country_Code__c,State__r.Country__r.Country_Name__c  FROM AddressBook__c 
                                          WHERE Account__C = :objAccount.ID AND Active__c=True AND (State__c IN :userStateIds) ORDER BY Destination_Name__c ASC])
        {
            if(addressIdWithCount.containsKey(addressBook.Id))
            {
                if(addressIdWithCount.get(addressBook.Id) == allPosItemIds.size())
                    shippingAddressesWithQuantity.add(new ShippingAddressDetailsWithQuantity(true,addressBook,0,new Shipping_Method__c(),addressIdWithShippingMethodId.get(addressBook.Id)));
                else
                    shippingAddressesWithQuantity.add(new ShippingAddressDetailsWithQuantity(false,addressBook,0,new Shipping_Method__c(),addressIdWithShippingMethodId.get(addressBook.Id)));
            }
            else
            {
                shippingAddressesWithQuantity.add(new ShippingAddressDetailsWithQuantity(false,addressBook,0,new Shipping_Method__c(),''));
            }
            allAddressBookList = shippingAddressesWithQuantity;
            
        }
        system.debug('allAddressBookList---->'+allAddressBookList.size());
        
        
        //Added by  VB, JP, RM on 01.06.2020
        //Ref: CR No: DFV-03-Jun-1
        //Aim: To get the list of address based on pagination index
        for(Integer i=recordStartIndex==null?0:recordStartIndex;i<=recordStartIndex+99;i++)
        {
            if(i<shippingAddressesWithQuantity.size())
                paginatedShippingAddressesWithQuantity.add(shippingAddressesWithQuantity[i]);
            
        }
        //Authors : NK,SN,TP,VB date: 16-06-2020.
        //Ref: CR No: DFV-03-Jun-1 
        //commenting the below lines since, according to the analysis the below lines do not play any role in this method
     /**   for(ShippingAddressDetailsWithQuantity eachShippingAddressWithQuantity:paginatedShippingAddressesWithQuantity)
        {
            if(selectedAddresses_Map.containsKey(eachShippingAddressWithQuantity.selectedAddress.Id))
            {
                shippingAddressesWithQuantity_Selected.add(selectedAddresses_Map.get(eachShippingAddressWithQuantity.selectedAddress.Id));   
            }
            else
            {
                shippingAddressesWithQuantity_Selected.add(eachShippingAddressWithQuantity);
            }
            
        }**/
      //  System.debug('shippingAddressesWithQuantity-->'+shippingAddressesWithQuantity_Selected);
        
        //Added by  VB, JP, RM on 01.06.2020
        //Ref: CR No: DFV-03-Jun-1
        //To form the result for front end
        shippingAddressesDetailsWithTotalSize.shippingAddressWithQtyDetails = paginatedShippingAddressesWithQuantity;
        shippingAddressesDetailsWithTotalSize.totalShippingAddressSize = shippingAddressesWithQuantity.size();
        shippingAddressesDetailsWithTotalSize.allAddresses = allAddressBookList;
        
        
        return shippingAddressesDetailsWithTotalSize;
    }
    
   /** @AuraEnabled
    public static ShippingAddressDetailsWithPagination loadPosItemUserAddressBookList(String selectedAddresses,String selectedPosItemDetails,String selectedRadioType, Integer recordStartIndex)
    {
        objAccount=getAccount();
        User user=getUserDetails();
        Set<Id> userStateIds=new Set<Id> ();
        Set<Id> allExistingAddressBookIds=new Set<Id> ();
        Map<Id,String> addressIdWithShippingMethodId=new Map<Id,String> ();
        List<ShippingAddressDetailsWithQuantity> shippingAddressesWithQuantity=new List<ShippingAddressDetailsWithQuantity> ();
        
        
        
        //Added by  VB, JP, RM on 01.06.2020
        //Ref: CR No: DFV-03-Jun-1
        //Aim: To hold the list of address based on pagination index
        List<ShippingAddressDetailsWithQuantity> paginatedShippingAddressesWithQuantity = new List<ShippingAddressDetailsWithQuantity>();
        //Added by  VB, JP, RM on 01.06.2020 
        //Ref: CR No: DFV-03-Jun-1
        //Aim: To hold list of address with pagination details
        ShippingAddressDetailsWithPagination shippingAddressesDetailsWithTotalSize=new ShippingAddressDetailsWithPagination();
        
        List<ShippingAddressDetailsWithQuantity> shippingAddressesWithQuantity_Selected=new List<ShippingAddressDetailsWithQuantity> ();
        Map<Id,ShippingAddressDetailsWithQuantity> selectedAddresses_Map=new Map<Id,ShippingAddressDetailsWithQuantity> ();
        if(String.isNotBlank(selectedAddresses))
        {
            //selectedAddresses_Map.putAll(selectedAddresses);  
            for(ShippingAddressDetailsWithQuantity shippingAddressDetail:(List<ShippingAddressDetailsWithQuantity>)System.JSON.deserialize(selectedAddresses, List<ShippingAddressDetailsWithQuantity>.class))
            {
                selectedAddresses_Map.put(shippingAddressDetail.selectedAddress.Id,shippingAddressDetail);
            }
        }
        System.debug(selectedPosItemDetails);
        for(ShippingAddressDetailsWithQuantity shippingAddressDetail : ((PosItemsListWithCartDetails)System.JSON.deserialize(selectedPosItemDetails, PosItemsListWithCartDetails.class)).selectedAddressWithQtyDetails)
        {
            allExistingAddressBookIds.add(shippingAddressDetail.selectedAddress.Id);
            if(!addressIdWithShippingMethodId.containsKey(shippingAddressDetail.selectedAddress.Id))
                addressIdWithShippingMethodId.put(shippingAddressDetail.selectedAddress.Id,shippingAddressDetail.selectedShippingMethodId);
        }
        
        if(selectedRadioType == 'ALL' || selectedRadioType == 'DOMESTIC')
            for(States_Territory__c stateTerritory : [SELECT ID, Name, State__c FROM States_Territory__c WHERE Territory__c IN ( SELECT Territory__c FROM Users_Territory__c WHERE (User__c =:UserInfo.getUserId() OR User__c='005L0000003z7qu')) ])
            userStateIds.add(stateTerritory.State__c);
        if((selectedRadioType == 'INTERNATIONAL' || selectedRadioType == 'ALL' ) && user.International_Address_Accessible__c)
            for(State__c state : [SELECT Id FROM State__c WHERE Country__r.Is_It_International_Country__c=true])
            userStateIds.add(state.Id);
        
        for(AddressBook__c addressBook : [SELECT Id, Name,City__c, Destination_Name__c, Shipto_Company__c, Shipto_Name__c, State__c, State__r.State_Name__c, Address__c, Division__r.Territory_Name__c, Active__c,State__r.Country__r.Country_Code__c,State__r.Country__r.Country_Name__c  FROM AddressBook__c 
                                          WHERE Account__C = :objAccount.ID AND Active__c=True AND (State__c IN :userStateIds) ORDER BY Destination_Name__c ASC])
        {
            if(allExistingAddressBookIds.contains(addressBook.Id))
                shippingAddressesWithQuantity.add(new ShippingAddressDetailsWithQuantity(true,addressBook,0,new Shipping_Method__c(),addressIdWithShippingMethodId.get(addressBook.Id)));
            else
                shippingAddressesWithQuantity.add(new ShippingAddressDetailsWithQuantity(false,addressBook,0,new Shipping_Method__c(),''));
            allAddressBookList = shippingAddressesWithQuantity;
        }
        
        //Added by  VB, JP, RM on 01.06.2020
        //Ref: CR No: DFV-03-Jun-1
        //Aim: To get the list of address based on pagination index
        for(Integer i=recordStartIndex==null?0:recordStartIndex;i<=recordStartIndex+99;i++)
        {
            if(i<shippingAddressesWithQuantity.size())
                paginatedShippingAddressesWithQuantity.add(shippingAddressesWithQuantity[i]);
        }
        
       
      for(ShippingAddressDetailsWithQuantity eachPaginatedShippingAddressWithQuantity:paginatedShippingAddressesWithQuantity)
        {
            if(selectedAddresses_Map.containsKey(eachPaginatedShippingAddressWithQuantity.selectedAddress.Id))
            {
                shippingAddressesWithQuantity_Selected.add(selectedAddresses_Map.get(eachPaginatedShippingAddressWithQuantity.selectedAddress.Id));   
           }
            else
           {
                shippingAddressesWithQuantity_Selected.add(eachPaginatedShippingAddressWithQuantity);
            }
            
        }
        System.debug('shippingAddressesWithQuantity-->'+shippingAddressesWithQuantity_Selected);
        
        //Added by  VB, JP, RM on 01.06.2020
        //Ref: CR No: DFV-03-Jun-1
        //To form the result for front end
        shippingAddressesDetailsWithTotalSize.shippingAddressWithQtyDetails = shippingAddressesWithQuantity_Selected;
        shippingAddressesDetailsWithTotalSize.totalShippingAddressSize = shippingAddressesWithQuantity.size();
        shippingAddressesDetailsWithTotalSize.allAddresses = allAddressBookList;
        return shippingAddressesDetailsWithTotalSize;
    }**/
    
     @AuraEnabled
    public static ShippingAddressDetailsWithPagination loadPosItemUserAddressBookList(String selectedAddresses,String selectedPosItemDetails,String selectedRadioType, Integer recordStartIndex)
    {
        objAccount=getAccount();
        User user=getUserDetails();
        Set<Id> userStateIds=new Set<Id> ();
        Set<Id> allExistingAddressBookIds=new Set<Id> ();
        Map<Id,String> addressIdWithShippingMethodId=new Map<Id,String> ();
        List<ShippingAddressDetailsWithQuantity> shippingAddressesWithQuantity=new List<ShippingAddressDetailsWithQuantity> ();
        
        
        
        //Added by  VB, JP, RM on 01.06.2020
        //Ref: CR No: DFV-03-Jun-1
        //Aim: To hold the list of address based on pagination index
        List<ShippingAddressDetailsWithQuantity> paginatedShippingAddressesWithQuantity = new List<ShippingAddressDetailsWithQuantity>();
        //Added by  VB, JP, RM on 01.06.2020 
        //Ref: CR No: DFV-03-Jun-1
        //Aim: To hold list of address with pagination details
        ShippingAddressDetailsWithPagination shippingAddressesDetailsWithTotalSize=new ShippingAddressDetailsWithPagination();
        
        List<ShippingAddressDetailsWithQuantity> shippingAddressesWithQuantity_Selected=new List<ShippingAddressDetailsWithQuantity> ();
        Map<Id,ShippingAddressDetailsWithQuantity> selectedAddresses_Map=new Map<Id,ShippingAddressDetailsWithQuantity> ();
        if(String.isNotBlank(selectedAddresses))
        {
            //selectedAddresses_Map.putAll(selectedAddresses);  
            for(ShippingAddressDetailsWithQuantity shippingAddressDetail:(List<ShippingAddressDetailsWithQuantity>)System.JSON.deserialize(selectedAddresses, List<ShippingAddressDetailsWithQuantity>.class))
            {
                selectedAddresses_Map.put(shippingAddressDetail.selectedAddress.Id,shippingAddressDetail);
            }
        }
        System.debug(selectedPosItemDetails);
        for(ShippingAddressDetailsWithQuantity shippingAddressDetail : ((PosItemsListWithCartDetails)System.JSON.deserialize(selectedPosItemDetails, PosItemsListWithCartDetails.class)).selectedAddressWithQtyDetails)
        {
            allExistingAddressBookIds.add(shippingAddressDetail.selectedAddress.Id);
            if(!addressIdWithShippingMethodId.containsKey(shippingAddressDetail.selectedAddress.Id))
                addressIdWithShippingMethodId.put(shippingAddressDetail.selectedAddress.Id,shippingAddressDetail.selectedShippingMethodId);
        }
        
        if(selectedRadioType == 'ALL' || selectedRadioType == 'DOMESTIC')
            for(States_Territory__c stateTerritory : [SELECT ID, Name, State__c FROM States_Territory__c WHERE State__r.Country__r.Is_It_International_Country__c=false AND Territory__c IN ( SELECT Territory__c FROM Users_Territory__c WHERE (User__c =:UserInfo.getUserId() OR User__c='005L0000003z7qu')) ])
            userStateIds.add(stateTerritory.State__c);
        if((selectedRadioType == 'INTERNATIONAL' || selectedRadioType == 'ALL' ) && user.International_Address_Accessible__c)
            for(State__c state : [SELECT Id FROM State__c WHERE Country__r.Is_It_International_Country__c=true])
            userStateIds.add(state.Id);
        
        for(AddressBook__c addressBook : [SELECT Id, Name,City__c, Destination_Name__c, Shipto_Company__c, Shipto_Name__c, State__c, State__r.State_Name__c, Address__c, Division__r.Territory_Name__c, Active__c,State__r.Country__r.Country_Code__c,State__r.Country__r.Country_Name__c  FROM AddressBook__c 
                                          WHERE Account__C = :objAccount.ID AND Active__c=True AND (State__c IN :userStateIds) ORDER BY Destination_Name__c ASC])
        {
            if(allExistingAddressBookIds.contains(addressBook.Id))
                shippingAddressesWithQuantity.add(new ShippingAddressDetailsWithQuantity(true,addressBook,0,new Shipping_Method__c(),addressIdWithShippingMethodId.get(addressBook.Id)));
            else
                shippingAddressesWithQuantity.add(new ShippingAddressDetailsWithQuantity(false,addressBook,0,new Shipping_Method__c(),''));
            allAddressBookList = shippingAddressesWithQuantity;
        }
        
        //Added by  VB, JP, RM on 01.06.2020
        //Ref: CR No: DFV-03-Jun-1
        //Aim: To get the list of address based on pagination index
        for(Integer i=recordStartIndex==null?0:recordStartIndex;i<=recordStartIndex+99;i++)
        {
            if(i<shippingAddressesWithQuantity.size())
                paginatedShippingAddressesWithQuantity.add(shippingAddressesWithQuantity[i]);
        }
        
       //Authors : NK,SN,TP,VB date: 16-06-2020.
        //Ref: CR No: DFV-03-Jun-1 
        //commenting the below lines since, according to the analysis the below lines do not play any role in this method
    /**  for(ShippingAddressDetailsWithQuantity eachPaginatedShippingAddressWithQuantity:paginatedShippingAddressesWithQuantity)
        {
            if(selectedAddresses_Map.containsKey(eachPaginatedShippingAddressWithQuantity.selectedAddress.Id))
            {
                shippingAddressesWithQuantity_Selected.add(selectedAddresses_Map.get(eachPaginatedShippingAddressWithQuantity.selectedAddress.Id));   
           }
            else
           {
                shippingAddressesWithQuantity_Selected.add(eachPaginatedShippingAddressWithQuantity);
            }
            
        }**/
        //System.debug('shippingAddressesWithQuantity-->'+shippingAddressesWithQuantity_Selected);
        
        //Added by  VB, JP, RM on 01.06.2020
        //Ref: CR No: DFV-03-Jun-1
        //To form the result for front end
        shippingAddressesDetailsWithTotalSize.shippingAddressWithQtyDetails = paginatedShippingAddressesWithQuantity;
        shippingAddressesDetailsWithTotalSize.totalShippingAddressSize = shippingAddressesWithQuantity.size();
        shippingAddressesDetailsWithTotalSize.allAddresses = allAddressBookList;
        return shippingAddressesDetailsWithTotalSize;
    }
    
    
    
    @AuraEnabled
    public static List<Shipping_Method__c> loadShippingMethodList()
    {
        objAccount=getAccount();
        return [SELECT Name, Shipping_Method_Name__c, Active__c, Account__c,Default__c, DisplayOrder__c, ApprovalRequired__c FROM Shipping_Method__c WHERE Account__C =:objAccount.ID AND Active__c = true ORDER BY  Default__c DESC,Shipping_Method_Name__c];
    }
    
    @AuraEnabled
    /**this method is responsible for saving the addresses for all the items in the cart */
    public static List<PosItemsListWithCartDetails> saveOrderForAllItems(String cartItemsJSONString,String selectedAddresses,String previouslySelectedAddresses)
    {
        try{
            system.debug('cartItemsJSONString'+cartItemsJSONString); 
            system.debug('selectedAddresses'+selectedAddresses); 
            system.debug('previouslySelectedAddresses'+previouslySelectedAddresses);
            
            
            objAccount=getAccount();
            User user=currentUser();
            List<PosItemsListWithCartDetails> cartItems=(List<PosItemsListWithCartDetails>)System.JSON.deserialize(cartItemsJSONString, List<PosItemsListWithCartDetails>.class);
            
            system.debug('cartItems'+cartItems);
            system.debug('cartItems size'+cartItems.size());
            List<ShippingAddressDetailsWithQuantity> userAllAddressBookList=(List<ShippingAddressDetailsWithQuantity>)System.JSON.deserialize(selectedAddresses, List<ShippingAddressDetailsWithQuantity>.class);
            
            system.debug('userAllAddressBookList'+userAllAddressBookList);
            system.debug('userAllAddressBookList size'+userAllAddressBookList.size());
            List<ShippingAddressDetailsWithQuantity> previouslySelectedAddresses_List=(List<ShippingAddressDetailsWithQuantity>)System.JSON.deserialize(previouslySelectedAddresses, List<ShippingAddressDetailsWithQuantity>.class);
            
            system.debug('previouslySelectedAddresses_List'+previouslySelectedAddresses_List);
            system.debug('previouslySelectedAddresses_List size'+previouslySelectedAddresses_List.size());
            Map<Id,ShippingAddressDetailsWithQuantity> previouslySelectedAddresses_Map = new Map<Id,ShippingAddressDetailsWithQuantity>();
            
            system.debug('previouslySelectedAddresses_Map'+previouslySelectedAddresses_Map);
            system.debug('previouslySelectedAddresses_Map size'+previouslySelectedAddresses_Map.size());
            List<Shipping_Method__c> defaultShippingMethod = new List<Shipping_Method__c> ([SELECT Id FROM Shipping_Method__c WHERE Account__c=:objAccount.Id AND Default__c=true]);
            System.debug('defaultShippingMethod--->'+defaultShippingMethod);
            System.debug('defaultShippingMethod size--->'+defaultShippingMethod.size());
            
            if(!cartItems.isEmpty())
            {
                Order__c DFVEmergeOrder=new Order__c ();
                List<OrderDestination__c> cometOrders=new List<OrderDestination__c> ();
                List<OrderDestinationItem__c> cometOrderItems=new List<OrderDestinationItem__c> ();
                
                if(String.isBlank(cartItems[0].orderId))
                {
                    //if shopping cart doesn't have Order Id cart shouldbe updated with Order Id for in relationship with order with cart items.
                    /**Saving the addresses for all the pos items of the inventory ordering by passing the parameter "Inventory", on change request
Date - 21 Jan 2020  Author - Thanvi - CR number : MMD-10-JAN-7 */
                    List<ShoppingCart__c> currentActiveShoppingCartForThisUser=[SELECT Id FROM ShoppingCart__c WHERE Active__c=true AND Account__c=:objAccount.Id AND CreatedById=:UserInfo.getUserId() AND CartStatus__c='Open' AND Inventory_Seasonal_Program__c='Inventory' ORDER BY CreatedDate];
                    DFVEmergeOrder.Account__c=objAccount.Id;
                    DFVEmergeOrder.Order_Status__c='Open';
                    DFVEmergeOrder.OwnerId=user.Id;
                    DFVEmergeOrder.Order_Date__c=System.today();
                    insert DFVEmergeOrder;
                    currentActiveShoppingCartForThisUser[0].DFV_Order_Number__c=DFVEmergeOrder.Id;
                    update currentActiveShoppingCartForThisUser[0];
                }
                else
                {
                    DFVEmergeOrder=[SELECT Id,Account__c,Order_Status__c,OwnerId,Order_Date__c FROM Order__c WHERE Id=:cartItems[0].orderId];
                }
                
                Map<Id,AddressBook__c> existingAddressBookList=new Map<Id,AddressBook__c> ([SELECT Id FROM AddressBook__c WHERE Id IN (SELECT AddressBook__c FROM OrderDestination__c WHERE Order__c=:DFVEmergeOrder.Id)]);
                Map<Id,ShippingAddressDetailsWithQuantity> addressBookIdWithSelectedAddress=new Map<Id,ShippingAddressDetailsWithQuantity> ();
                Map<Id,OrderDestination__c> addressBookIdWithCometOrder=new Map<Id,OrderDestination__c> ();
                for(OrderDestination__c cometOrder : [SELECT Id,AddressBook__c FROM OrderDestination__c WHERE Order__c=:DFVEmergeOrder.Id])
                {
                    addressBookIdWithCometOrder.put(cometOrder.AddressBook__c,cometOrder);
                }
                for(ShippingAddressDetailsWithQuantity eachShippingAddress : userAllAddressBookList)
                {
                    OrderDestination__c cometOrder=new OrderDestination__c();
                    cometOrder.Id=addressBookIdWithCometOrder.get(eachShippingAddress.selectedAddress.Id)==null?null:addressBookIdWithCometOrder.get(eachShippingAddress.selectedAddress.Id).Id;
                    cometOrder.Order__c = DFVEmergeOrder.Id;
                    cometOrder.AddressBook__c = eachShippingAddress.selectedAddress.Id;
                    cometOrder.Shipping_Method__c = String.isBlank(eachShippingAddress.selectedShippingMethodId)?defaultShippingMethod.isEmpty()?null:defaultShippingMethod[0].Id:eachShippingAddress.selectedShippingMethodId;
                    cometOrder.SelectedShippingMethod__c = String.isBlank(eachShippingAddress.selectedShippingMethodId)?defaultShippingMethod.isEmpty()?null:defaultShippingMethod[0].Id:eachShippingAddress.selectedShippingMethodId;
                    cometOrders.add(cometOrder);
                    addressBookIdWithSelectedAddress.put(eachShippingAddress.selectedAddress.Id,eachShippingAddress);
                }
                upsert cometOrders;
                system.debug('cometOrders'+cometOrders);
                system.debug('cometOrders size'+cometOrders.size());
                
                for(ShippingAddressDetailsWithQuantity eachShippingAddress : previouslySelectedAddresses_List)
                {
                    previouslySelectedAddresses_Map.put(eachShippingAddress.selectedAddress.Id,eachShippingAddress);
                }
                
                Map<Id,PosItemsListWithCartDetails> posItemIdWithDetails=new Map<Id,PosItemsListWithCartDetails > ();
                for(OrderDestination__c cometOrder : [SELECT Id,(SELECT Id,POS_Item__c FROM OrderDestinationItems__r) FROM OrderDestination__c WHERE Order__c=:DFVEmergeOrder.Id  AND AddressBook__c IN : addressBookIdWithSelectedAddress.keySet()])
                {
                    Set<Id> existingAllPosItemIds=new Set<Id> ();
                    for(OrderDestinationItem__c cometOrderItem : cometOrder.OrderDestinationItems__r)
                        existingAllPosItemIds.add(cometOrderItem.POS_Item__c);
                    for(PosItemsListWithCartDetails detailedItem : cartItems)
                    {
                        if(!posItemIdWithDetails.containsKey(detailedItem.posItem.Id))
                            posItemIdWithDetails.put(detailedItem.posItem.Id,detailedItem);
                        if(!existingAllPosItemIds.contains(detailedItem.posItem.Id))
                        {
                            OrderDestinationItem__c cometOrderItem=new OrderDestinationItem__c ();
                            cometOrderItem.OrderDestination__c = cometOrder.Id;
                            cometOrderItem.POS_Item__c = detailedItem.posItem.Id;
                            cometOrderItem.Item_Price__c = detailedItem.posItem.Price__c;
                            cometOrderItem.Quantity__c=0;
                            cometOrderItem.SelectedQuantity__c=0;
                            cometOrderItems.add(cometOrderItem);
                        }
                    }
                }
                insert cometOrderItems;
                system.debug('cometOrderItems'+cometOrderItems);
                system.debug('cometOrderItems size'+cometOrderItems.size());
                
                List<OrderDestinationItem__c> cometOrderItemsToBeDeleted=new List<OrderDestinationItem__c> ();
                for(OrderDestinationItem__c cometOrderItem : [SELECT Id,Quantity__c FROM OrderDestinationItem__c WHERE OrderDestination__r.Order__c=:DFVEmergeOrder.Id AND Pos_Item__c IN :posItemIdWithDetails.keySet() AND OrderDestination__r.AddressBook__c NOT IN :addressBookIdWithSelectedAddress.keySet() AND OrderDestination__r.AddressBook__c IN :previouslySelectedAddresses_Map.keySet()])
                {
                    if(cometOrderItem.Quantity__c<0 || cometOrderItem.Quantity__c==0)
                        cometOrderItemsToBeDeleted.add(cometOrderItem);
                }
                delete cometOrderItemsToBeDeleted;
                delete [SELECT Id FROM OrderDestination__c WHERE Order__c=:DFVEmergeOrder.Id AND Id NOT IN (SELECT OrderDestination__c FROM OrderDestinationItem__c WHERE OrderDestination__r.Order__c=:DFVEmergeOrder.Id)];
            }
        }
        catch(Exception ex)
        {
            DFVEmailNotifications.sendNotification('Removing Items To Cart',ex.getMessage()+'\n'+'Inputs are -- cartItemsJSONString-- '+JSON.serialize(cartItemsJSONString)
                                                   +'\n'+'---selectedAddresses---'+JSON.serialize(selectedAddresses)+'\n'+'---previouslySelectedAddresses---'+JSON.serialize(previouslySelectedAddresses)
                                                   +'\n'+'Class Name - DFVInventoryOrderController '+'-- Line number --'+ex.getLineNumber());
        }
        
        return loadCartItemsList();
    }
    @AuraEnabled
    /**this method is responsible for saving the addresses for all the items in the cart */
    public static List<PosItemsListWithCartDetails> saveOrderForSelectedItem(String cartItemsJSONString,String selectedAddresses)
    {
        try{
            System.debug('cartItemsJSONString--->'+cartItemsJSONString);
            objAccount=getAccount();
            User user=currentUser();
            List<PosItemsListWithCartDetails> cartItems=(List<PosItemsListWithCartDetails>)System.JSON.deserialize(cartItemsJSONString, List<PosItemsListWithCartDetails>.class);
            List<ShippingAddressDetailsWithQuantity> userAllAddressBookList=(List<ShippingAddressDetailsWithQuantity>)System.JSON.deserialize(selectedAddresses, List<ShippingAddressDetailsWithQuantity>.class);
            List<Shipping_Method__c> defaultShippingMethod=new List<Shipping_Method__c> ([SELECT Id FROM Shipping_Method__c WHERE Account__c=:objAccount.Id AND Default__c=true]);
            System.debug('defaultShippingMethod--->'+defaultShippingMethod);
            if(!cartItems.isEmpty())
            {
                Order__c DFVEmergeOrder=new Order__c ();
                List<OrderDestination__c> cometOrders=new List<OrderDestination__c> ();
                List<OrderDestinationItem__c> cometOrderItems=new List<OrderDestinationItem__c> ();
                
                if(String.isBlank(cartItems[0].orderId))
                {
                    List<ShoppingCart__c> currentActiveShoppingCartForThisUser=[SELECT Id FROM ShoppingCart__c WHERE 
                                                                                Active__c=true AND Account__c=:objAccount.Id 
                                                                                AND CreatedById=:UserInfo.getUserId() AND CartStatus__c='Open' 
                                                                                AND Inventory_Seasonal_Program__c='Inventory' ORDER BY CreatedDate];
                    DFVEmergeOrder.Account__c=objAccount.Id;
                    DFVEmergeOrder.Order_Status__c='Open';
                    DFVEmergeOrder.OwnerId=user.Id;
                    DFVEmergeOrder.Order_Date__c=System.today();
                    insert DFVEmergeOrder;
                    currentActiveShoppingCartForThisUser[0].DFV_Order_Number__c=DFVEmergeOrder.Id;
                    update currentActiveShoppingCartForThisUser[0];
                }
                else
                {
                    DFVEmergeOrder=[SELECT Id,Account__c,Order_Status__c,OwnerId,Order_Date__c FROM Order__c WHERE Id=:cartItems[0].orderId];
                }
                
                Map<Id,AddressBook__c> existingAddressBookList=new Map<Id,AddressBook__c> ([SELECT Id FROM AddressBook__c WHERE Id IN (SELECT AddressBook__c FROM OrderDestination__c WHERE Order__c=:DFVEmergeOrder.Id)]);
                Map<Id,ShippingAddressDetailsWithQuantity> addressBookIdWithSelectedAddress=new Map<Id,ShippingAddressDetailsWithQuantity> ();
                Map<Id,OrderDestination__c> addressBookIdWithCometOrder=new Map<Id,OrderDestination__c> ();
                for(OrderDestination__c cometOrder : [SELECT Id,AddressBook__c FROM OrderDestination__c WHERE Order__c=:DFVEmergeOrder.Id])
                {
                    addressBookIdWithCometOrder.put(cometOrder.AddressBook__c,cometOrder);
                }
                for(ShippingAddressDetailsWithQuantity eachShippingAddress : userAllAddressBookList)
                {
                    
                    OrderDestination__c cometOrder=new OrderDestination__c();
                    cometOrder.Id=addressBookIdWithCometOrder.get(eachShippingAddress.selectedAddress.Id)==null?null:addressBookIdWithCometOrder.get(eachShippingAddress.selectedAddress.Id).Id;
                    cometOrder.Order__c = DFVEmergeOrder.Id;
                    cometOrder.AddressBook__c = eachShippingAddress.selectedAddress.Id;
                    cometOrder.Shipping_Method__c = String.isBlank(eachShippingAddress.selectedShippingMethodId)?defaultShippingMethod.isEmpty()?null:defaultShippingMethod[0].Id:eachShippingAddress.selectedShippingMethodId;
                    cometOrder.SelectedShippingMethod__c = String.isBlank(eachShippingAddress.selectedShippingMethodId)?defaultShippingMethod.isEmpty()?null:defaultShippingMethod[0].Id:eachShippingAddress.selectedShippingMethodId;
                    cometOrders.add(cometOrder);
                    addressBookIdWithSelectedAddress.put(eachShippingAddress.selectedAddress.Id,eachShippingAddress);
                }
                upsert cometOrders;
                
                Map<Id,PosItemsListWithCartDetails> posItemIdWithDetails=new Map<Id,PosItemsListWithCartDetails > ();
                
                for(OrderDestination__c cometOrder : [SELECT Id,AddressBook__c,(SELECT Id,POS_Item__c,Quantity__c FROM OrderDestinationItems__r) FROM OrderDestination__c WHERE Order__c=:DFVEmergeOrder.Id AND AddressBook__c IN : addressBookIdWithSelectedAddress.keySet()])
                {
                    Map<Id,OrderDestinationItem__c> existingPosItemWithCometOrderItem=new Map<Id,OrderDestinationItem__c> ();
                    for(OrderDestinationItem__c cometOrderItem : cometOrder.OrderDestinationItems__r)
                        existingPosItemWithCometOrderItem.put(cometOrderItem.POS_Item__c,cometOrderItem);
                    System.debug('existingPosItemWithCometOrderItem--> '+existingPosItemWithCometOrderItem.keySet());
                    for(PosItemsListWithCartDetails detailedItem : cartItems)
                    {
                        if(!posItemIdWithDetails.containsKey(detailedItem.posItem.Id))
                            posItemIdWithDetails.put(detailedItem.posItem.Id,detailedItem);
                        OrderDestinationItem__c cometOrderItem=new OrderDestinationItem__c ();
                        System.debug(existingPosItemWithCometOrderItem.get(detailedItem.posItem.Id));
                        //cometOrderItem.Id=existingPosItemWithCometOrderItem.get(detailedItem.posItem.Id)==null?null:existingPosItemWithCometOrderItem.get(detailedItem.posItem.Id).Id;
                        
                        if(existingPosItemWithCometOrderItem.containsKey(detailedItem.posItem.Id))
                        {
                            cometOrderItem.Id=existingPosItemWithCometOrderItem.get(detailedItem.posItem.Id).Id;
                            cometOrderItem.Quantity__c=existingPosItemWithCometOrderItem.get(detailedItem.posItem.Id).Quantity__c;
                            cometOrderItem.SelectedQuantity__c=existingPosItemWithCometOrderItem.get(detailedItem.posItem.Id).Quantity__c;
                        }
                        else
                        {
                            cometOrderItem.Id=null;
                            cometOrderItem.Quantity__c=0;
                            cometOrderItem.SelectedQuantity__c=0;
                        }
                        cometOrderItem.OrderDestination__c = cometOrder.Id;
                        cometOrderItem.POS_Item__c = detailedItem.posItem.Id;
                        cometOrderItem.Item_Price__c = detailedItem.posItem.Price__c;
                        
                        cometOrderItems.add(cometOrderItem);
                    }
                }
                upsert cometOrderItems;
                
                /** delete **/
                delete [SELECT Id FROM OrderDestinationItem__c WHERE OrderDestination__r.Order__c=:DFVEmergeOrder.Id AND Pos_Item__c IN :posItemIdWithDetails.keySet() AND OrderDestination__r.AddressBook__c NOT IN :addressBookIdWithSelectedAddress.keySet()];
                delete [SELECT Id FROM OrderDestination__c WHERE Order__c=:DFVEmergeOrder.Id AND Id NOT IN (SELECT OrderDestination__c FROM OrderDestinationItem__c WHERE OrderDestination__r.Order__c=:DFVEmergeOrder.Id)];
            }
        }
        catch(Exception ex)
        {
            DFVEmailNotifications.sendNotification('Removing Items To Cart',ex.getMessage()+'\n'+'Inputs are -- cartItemsJSONString-- '+JSON.serialize(cartItemsJSONString)
                                                   +'\n'+'---selectedAddresses---'+JSON.serialize(selectedAddresses)
                                                   +'\n'+'Class Name - DFVInventoryOrderController '+'-- Line number --'+ex.getLineNumber());
        }
        
        
        return loadCartItemsList();
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
    /** public class PosItemWithQuantity
{
public POS_Item__c posItem ;
public Integer selectedQuanity ;
public PosItemWithQuantity(POS_Item__c posItem,Integer selectedQuanity)
{
this.posItem=posItem;
this.selectedQuanity=selectedQuanity;
}
}**/
    public class ShippingAddressDetails
    {
        @AuraEnabled
        public Boolean isCheckboxClicked ;
        @AuraEnabled
        public AddressBook__c addressBook ;
        @AuraEnabled 
        public Integer quantity ;
        @AuraEnabled
        public String shippingMethodId ;
        public ShippingAddressDetails(Boolean isCheckboxClicked,AddressBook__c addressBook,Integer quantity,String shippingMethodId)
        {
            this.isCheckboxClicked=isCheckboxClicked;
            this.addressBook=addressBook;
            this.quantity=quantity;
            this.shippingMethodId=shippingMethodId;
        }
    }
    
    //Added by JP, RM, VB on 01.06.2020 
    //To hold list of address with pagination details.
    public class ShippingAddressDetailsWithPagination
    {
        @AuraEnabled
        public List<ShippingAddressDetailsWithQuantity> shippingAddressWithQtyDetails;
        @AuraEnabled
        public Integer totalShippingAddressSize;
        @AuraEnabled
        public List<ShippingAddressDetailsWithQuantity> allAddresses;
        
    }
    
    
    @AuraEnabled
    public static List<OrderDestinationItem__c> loadAllComerOrders(String emergeOrderId)
    {
        system.debug('emergeOrderId---->'+emergeOrderId);
        system.debug('loadAllComerOrders---->'+[SELECT Name, Id,POS_Item__c,Quantity__c,POS_Item__r.Attachment_Id__c,POS_Item__r.Active__c, OrderDestination__r.AddressBook__r.Shipto_Name__c, OrderDestination__r.OrderName__c, OrderDestination__r.AddressBook__r.Shipto_Company__c, OrderDestination__r.AddressBook__r.Address__c, OrderDestination__r.AddressBook__r.City__c, POS_Item__r.Item_No__c, POS_Item__r.Pack_Of__c, POS_Item__r.Item_Name__c, SelectedQuantity__c,OrderDestination__r.SelectedShippingMethod__r.Shipping_Method_Name__c FROM OrderDestinationItem__c WHERE SelectedQuantity__c>0 AND OrderDestination__r.Order__r.Id =:emergeOrderId]);
        return [SELECT Name, Id,POS_Item__c,Quantity__c,POS_Item__r.Attachment_Id__c,
                POS_Item__r.Active__c, OrderDestination__r.AddressBook__r.Shipto_Name__c,
                OrderDestination__r.OrderName__c, OrderDestination__r.AddressBook__r.Shipto_Company__c,
                OrderDestination__r.AddressBook__r.Address__c, OrderDestination__r.AddressBook__r.City__c,
                POS_Item__r.Item_No__c, POS_Item__r.Pack_Of__c, POS_Item__r.Item_Name__c,
                SelectedQuantity__c,OrderDestination__r.SelectedShippingMethod__r.Shipping_Method_Name__c 
                FROM OrderDestinationItem__c 
                WHERE SelectedQuantity__c>0 
                AND OrderDestination__r.Order__r.Id =:emergeOrderId];
    }
    @AuraEnabled
    /**this method is responsible for removing the Pos item from the shopping cart */
    public static List<PosItemsListWithCartDetails> deleteCartItemFromShippingCart(String selectedCartItemDetails,String posItemsListWithCart)
    {
        try{
            List<PosItemsListWithCartDetails> cartItemsForQty=new List<PosItemsListWithCartDetails> ();
            PosItemsListWithCartDetails cartItem=(PosItemsListWithCartDetails)System.JSON.deserialize(selectedCartItemDetails, PosItemsListWithCartDetails.class);
            List<PosItemsListWithCartDetails> cartItems=(List<PosItemsListWithCartDetails>)System.JSON.deserialize(posItemsListWithCart, List<PosItemsListWithCartDetails>.class);
            
            for(PosItemsListWithCartDetails eachPosItem : cartItems)
            {
                if(cartItem.posItem.Id!=eachPosItem.posItem.Id)
                    cartItemsForQty.add(eachPosItem); 
            }
            
            objAccount=getAccount();
            /**Deleting the Pos item from the shopping cart that belongs to inventory ordering by passing the parameter "Inventory", on change request
Date - 21 Jan 2020  Author - Thanvi - CR number : MMD-10-JAN-9 */
            List<ShoppingCartItems__c> shoppingCartItem=[SELECT Id FROM ShoppingCartItems__c WHERE ShoppingCart__r.Active__c=true AND ShoppingCart__r.Account__c=:objAccount.Id AND ShoppingCart__r.CreatedById=:UserInfo.getUserId() AND ShoppingCart__r.CartStatus__c='Open' AND ShoppingCart__r.Inventory_Seasonal_Program__c='Inventory' AND POS_Item__c=:cartItem.posItem.Id];
            delete shoppingCartItem;
            List<OrderDestinationItem__c> cometOrderItems=[SELECT Id FROM OrderDestinationItem__c WHERE OrderDestination__r.Order__c=:cartItem.orderId AND POS_Item__c=:cartItem.posItem.Id];
            delete cometOrderItems;
            List<OrderDestination__c> cometOrders=[SELECT Id FROM OrderDestination__c WHERE Order__c=:cartItem.orderId AND Id NOT IN (SELECT OrderDestination__c  FROM OrderDestinationItem__c)]; 
            delete cometOrders;
            //return loadCartItemsList();
            return cartItemsForQty;
        }catch(exception ex)
        {
            DFVEmailNotifications.sendNotification('Deleting a cart item from cart',ex.getMessage()+'\n'+'Inputs are -- selectedCartItemDetails-- '+JSON.serialize(selectedCartItemDetails) +'\n'+
                                                   ' -- posItemsListWithCart -- '+JSON.serialize(posItemsListWithCart)+'\n'
                                                   +'\n'+'Class Name - DFVInventoryOrderController '+'-- Line number --'+ex.getLineNumber());
            return new List<PosItemsListWithCartDetails> ();
            
        }
    }
    @AuraEnabled
    /**this method is responsible for confirming the order upon preview */
    public static List<PosItemsListWithCartDetails> confirmOrder (String cartItemDetails)
    {
        try{
                objAccount=getAccount();
                List<ShoppingCart__c> currentActiveShoppingCartForThisUser = [SELECT Id,Active__c,
                                                                              DFV_Order_Number__c,
                                                                              Account__c,
                                                                              CreatedById,
                                                                              CartStatus__c,
                                                                              Inventory_Seasonal_Program__c
                                                                              FROM ShoppingCart__c
                                                                              WHERE 
                                                                              Active__c=true AND Account__c=:objAccount.Id 
                                                                              AND CreatedById=:UserInfo.getUserId() AND CartStatus__c='Open' 
                                                                              AND Inventory_Seasonal_Program__c='Inventory' ORDER BY CreatedDate];
                
                
                system.debug('currentActiveShoppingCartForThisUser---->'+currentActiveShoppingCartForThisUser[0]);
                
                List<PosItemsListWithCartDetails> cartItems=(List<PosItemsListWithCartDetails>)System.JSON.deserialize(cartItemDetails, List<PosItemsListWithCartDetails>.class);
                Order__c emergeOrder = [SELECT Id, Name, Order_Status__c, Order_Confirmation_Date__c FROM Order__c WHERE ID=:cartItems[0].orderId];
                emergeOrder.Order_Status__c='Send to Comet';
                update emergeOrder;
                
                if(!currentActiveShoppingCartForThisUser.isEmpty())
                {
                    currentActiveShoppingCartForThisUser[0].CartStatus__c='Closed';
                    update currentActiveShoppingCartForThisUser[0];
                }
        }
        catch(exception ex)
        {
            DFVEmailNotifications.sendNotification('Confirming an Order',ex.getMessage()+'\n'+'Inputs are -- cartItemDetails-- '+JSON.serialize(cartItemDetails)
                                                   +'\n'+'Class Name - DFVInventoryOrderController '+'-- Line number --'+ex.getLineNumber());
        }
        return loadCartItemsList();
    }
    
    @AuraEnabled
    public static List<OrderDestinationItem__c> updateQuantityForSelectedItem_Apex (String posItemId,String shaippingAddressId,String orderId,Integer quantity)
    {
        try
        {
            if(String.isNotBlank(posItemId) && String.isNotBlank(shaippingAddressId) && String.isNotBlank(orderId))
            {
                OrderDestinationItem__c cometOrderItem= [SELECT Id,Quantity__c,SelectedQuantity__c,OrderDestination__r.AddressBook__c FROM OrderDestinationItem__c WHERE OrderDestination__r.AddressBook__c=:shaippingAddressId AND POS_Item__c=:posItemId AND OrderDestination__r.Order__c=:orderId];
                
                system.debug('cometOrderItem---->'+cometOrderItem);
                cometOrderItem.Quantity__c=quantity;
                cometOrderItem.SelectedQuantity__c=quantity;
                update cometOrderItem;
            }
            return String.isNotBlank(orderId)?loadAllComerOrders(orderId):null;
        }
        catch(Exception ex)
        {
            DFVEmailNotifications.sendNotification('Updating quantity fro selected item',ex.getMessage()+'\n'+'Inputs are -- posItemId-- '+JSON.serialize(posItemId)+'\n'+
                                                   '-- shaippingAddressId --'+JSON.serialize(shaippingAddressId)+'\n'+
                                                   '-- orderId--'+JSON.serialize(orderId)+'\n'+
                                                   '-- quantity--'+JSON.serialize(quantity)
                                                   +'\n'+'Class Name - DFVInventoryOrderController '+'-- Line number --'+ex.getLineNumber());
            return null;
        }
    }
    
    /** Order Status **/
    @AuraEnabled
    public static List<OrderDestination__c> loadAllInventoryOrders (String searchKeyword,Boolean isEmergeAdmin)
    {
        String query='';
        String whereClause='';
        if(Test.isRunningTest())
        {
            Map<Id,OrderDestination__c> cometOrders_Map=new Map<Id,OrderDestination__c> ();
            query+='SELECT Order__r.Name, Order__r.Id,Order__r.Order_Date__c, Order__r.CreatedById,Order__r.Order_Status__c, OrderDestination__c.Name,';
            query+='AddressBook__r.Destination_Name__c, AddressBook__r.Shipto_Name__c, AddressBook__r.Shipto_Company__c, AddressBook__r.City__c, AddressBook__r.Address__c,ShippingMethodRejeted__c,ShipMethodApproved__c,SelectedShippingMethod__r.Shipping_Method_Name__c,Shipping_Method__r.Shipping_Method_Name__c,';
            query+='OrderName__c,SelectedShippingMethod__r.ApprovalRequired__c,(SELECT Name, Id,POS_Item__c,Quantity__c,POS_Item__r.Attachment_Id__c,POS_Item__r.Active__c, OrderDestination__r.AddressBook__r.Shipto_Name__c, OrderDestination__r.OrderName__c, OrderDestination__r.AddressBook__r.Shipto_Company__c, OrderDestination__r.AddressBook__r.Address__c, OrderDestination__r.AddressBook__r.City__c, POS_Item__r.Item_No__c, POS_Item__r.Pack_Of__c, POS_Item__r.Item_Name__c, SelectedQuantity__c ,';
            query+='POS_Item__r.Brand__r.Brand_Name__c,POS_Item__r.Type_of_Item__r.Item_Type__c,POS_Item__r.Approval_Required__c,POS_Item__r.Maximum_Order_Qty__c,POS_Item__r.Maximum_order_quantity_applicable__c,MaxOrderAppReq__c,ItemApproved__c,ItemRejected__c,MaxOrderApproved__c,MaxOrderRejected__c FROM OrderDestinationItems__r WHERE SelectedQuantity__c>0 )';
            query+=',WarehouseOrderStatus__c, WarehouseProcessingStatus__c, WarehouseSequence__c, WarehouseShippingComments__c, WarehouseShippingDate__c, WarehouseShippingStatus__c, WarehouseTransactionNo__c';
            query+=',OrdStatus__c, Carrier__c, TrackingNos__c ';
            query+='FROM OrderDestination__c';
            whereClause+=' WHERE Order__r.Program__c=null';
            whereClause+=isEmergeAdmin?' ':' AND Order__r.OwnerId =\''+UserInfo.getUserId()+'\'';
            if(String.isNotBlank(searchKeyword))
            {
                whereClause+=' AND ( OrderName__c LIKE '+'\'%'+searchKeyword+'%\' ';
                whereClause+=' OR AddressBook__r.Destination_Name__c LIKE '+'\'%'+searchKeyword+'%\' ';
                whereClause+=' OR AddressBook__r.Shipto_Name__c LIKE '+'\'%'+searchKeyword+'%\' ';
                whereClause+=' OR AddressBook__r.Shipto_Company__c LIKE '+'\'%'+searchKeyword+'%\' ';
                whereClause+=' OR AddressBook__r.City__c LIKE '+'\'%'+searchKeyword+'%\' ) ';
            }
            query=query+whereClause +' ORDER BY CreatedDate DESC';
        }
        else
        {
            objAccount=[SELECT Id, Name,Lightning_Community_URL__c FROM Account
                        WHERE Lightning_Community_Id__c=:Network.getNetworkId() LIMIT 1];
            
            Map<Id,OrderDestination__c> cometOrders_Map=new Map<Id,OrderDestination__c> ();
            query+='SELECT Order__r.Name, Order__r.Id,Order__r.Order_Date__c, Order__r.CreatedById,Order__r.Order_Status__c, OrderDestination__c.Name,';
            query+='AddressBook__r.Destination_Name__c, AddressBook__r.Shipto_Name__c, AddressBook__r.Shipto_Company__c, AddressBook__r.City__c, AddressBook__r.Address__c,ShippingMethodRejeted__c,ShipMethodApproved__c,SelectedShippingMethod__r.Shipping_Method_Name__c,Shipping_Method__r.Shipping_Method_Name__c,';
            query+='OrderName__c,SelectedShippingMethod__r.ApprovalRequired__c,(SELECT Name, Id,POS_Item__c,Quantity__c,POS_Item__r.Attachment_Id__c,POS_Item__r.Active__c, OrderDestination__r.AddressBook__r.Shipto_Name__c, OrderDestination__r.OrderName__c, OrderDestination__r.AddressBook__r.Shipto_Company__c, OrderDestination__r.AddressBook__r.Address__c, OrderDestination__r.AddressBook__r.City__c, POS_Item__r.Item_No__c, POS_Item__r.Pack_Of__c, POS_Item__r.Item_Name__c, SelectedQuantity__c ,';
            query+='POS_Item__r.Brand__r.Brand_Name__c,POS_Item__r.Type_of_Item__r.Item_Type__c,POS_Item__r.Approval_Required__c,POS_Item__r.Maximum_Order_Qty__c,POS_Item__r.Maximum_order_quantity_applicable__c,MaxOrderAppReq__c,ItemApproved__c,ItemRejected__c,MaxOrderApproved__c,MaxOrderRejected__c FROM OrderDestinationItems__r WHERE SelectedQuantity__c>0 )';
            query+=',WarehouseOrderStatus__c, WarehouseProcessingStatus__c, WarehouseSequence__c, WarehouseShippingComments__c, WarehouseShippingDate__c, WarehouseShippingStatus__c, WarehouseTransactionNo__c';
            query+=',OrdStatus__c, Carrier__c, TrackingNos__c ';
            query+='FROM OrderDestination__c';
            whereClause+=' WHERE Order__r.Account__c=\''+objAccount.Id+'\' AND Order__r.Program__c=null';
            whereClause+=isEmergeAdmin?' ':' AND Order__r.OwnerId =\''+UserInfo.getUserId()+'\'';
            if(String.isNotBlank(searchKeyword))
            {
                whereClause+=' AND ( OrderName__c LIKE '+'\'%'+searchKeyword+'%\' ';
                whereClause+=' OR AddressBook__r.Destination_Name__c LIKE '+'\'%'+searchKeyword+'%\' ';
                whereClause+=' OR AddressBook__r.Shipto_Name__c LIKE '+'\'%'+searchKeyword+'%\' ';
                whereClause+=' OR AddressBook__r.Shipto_Company__c LIKE '+'\'%'+searchKeyword+'%\' ';
                whereClause+=' OR AddressBook__r.City__c LIKE '+'\'%'+searchKeyword+'%\' ) ';
            }
            query=query+whereClause +' ORDER BY CreatedDate DESC';
            
        }
        return Database.query(query);
    }
}