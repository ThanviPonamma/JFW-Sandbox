/** Author : Thanvi
Date:20/SEP/2021
Aim:To Add/remove pos item from the selected program in seasonal order.
*/
public class InfiniumPosItemToCart_Apex {
    //Global variable which holds the account
    public static Account objAccount;
    public static Boolean isTest = false;
    
    // to fetch the account information and store the details in objAccount variable.
    public static Account getAccount() {
        if(Test.isRunningTest())
        {
            //fetch Id, name from the account sObject
            objAccount=[SELECT Id, Name,Lightning_Community_URL__c FROM Account
                        WHERE Name LIKE '%Infinium Spirits%' LIMIT 1];
        }
        else
        {
            objAccount=[SELECT Id, Name,Lightning_Community_URL__c FROM Account
                        WHERE Lightning_Community_Id__c=:Network.getNetworkId() LIMIT 1];
        }
        return objAccount;
    }
    
    /***** InfiniumPosItemToCart_Apex -- START -- *****/
    public class PosItem_Details
    {
        @AuraEnabled
        public Boolean isItemAddedToCart ;   
        @AuraEnabled
        public POS_Item__c posItem; 
        @AuraEnabled
        public String posItemImageURL; 
        public PosItem_Details(Boolean isItemAddedToCart,POS_Item__c posItem,String posItemImageURL)
        {
            this.isItemAddedToCart=isItemAddedToCart;
            this.posItem=posItem;
            this.posItemImageURL=posItemImageURL;
        }
    }
    
    public class PosItem_DetailsListWrapper
    {
        @AuraEnabled
        public List<PosItem_Details> PosItemDetails;
        @AuraEnabled
        public Integer totalPosItemsSize;
        @AuraEnabled
        public Integer totalCartItemsSize;
        public PosItem_DetailsListWrapper (List<PosItem_Details> PosItemDetails,Integer totalPosItemsSize,
                                           Integer totalCartItemsSize)
        {
            this.PosItemDetails=PosItemDetails;
            this.totalPosItemsSize=totalPosItemsSize;
            this.totalCartItemsSize=totalCartItemsSize;
        }
        
    }
    
    @AuraEnabled(cacheable=true)
    public static PosItem_DetailsListWrapper getPosItems_Apex (String searchPosItemKeyword,String chosenBrandId,String chosenItemTypeId,String sortById,String selectedProgramId,Integer recordStartIndex)
    {
        objAccount=getAccount();
        Set<Id> posItemIdsInCart=new Set<Id> ();
        List<POS_Item__c> posItems=new List<POS_Item__c> ();
        List<PosItem_Details> posItemDetails=new List<PosItem_Details> ();
        for(ShoppingCartItems__c shoppingCartItem : [SELECT POS_Item__c FROM ShoppingCartItems__c WHERE ShoppingCart__r.Active__c=true AND ShoppingCart__r.Account__c=:objAccount.Id AND ShoppingCart__r.CreatedById=:UserInfo.getUserId() AND ShoppingCart__r.CartStatus__c='Open' AND 
                                                     ShoppingCart__r.Inventory_Seasonal_Program__c='Seasonal Program' AND ShoppingCart__r.Program__c=:selectedProgramId ])
            posItemIdsInCart.add(shoppingCartItem.POS_Item__c);
        System.debug('posItemIdsInCart-->'+posItemIdsInCart);
        system.debug('selectedProgramId-->'+selectedProgramId);
        String query='SELECT Id,Attachment_Id__c,Item_Descrption__c,Coupon_Attachment_Id__c,Active__c,Item_Name__c,Item_No__c,Pack_Of__c,Logical_Invenory_Stock__c,Brand__r.Brand_Name__c,Approval_Required__c,Maximum_Order_Qty__c,Maximum_order_quantity_applicable__c,Price__c,Type_of_Item__r.Item_Type__c';
        query=query+' FROM POS_Item__c WHERE Account__c=\''+objAccount.Id+'\' AND Id IN (SELECT POS_Item__c FROM Program_Item__c WHERE Program__c=\''+selectedProgramId+'\')';
        String whereCondition=''; 
        String sortByOption='';
        String offsetValue='';
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
        List<POS_Item__c> posItems_bySearch=Database.query(query+whereCondition+sortByOption);
        System.debug('posItems_bySearch--->'+posItems_bySearch);
        if(sortById == 'RECENT_ADDED_CARTITEMS')
        {
            List<POS_Item__C> items=new List<POS_Item__C> ();  
            List<POS_Item__C> cartItems=[SELECT Id,Item_Name__c,Attachment_Id__c,Item_Descrption__c,Coupon_Attachment_Id__c,Active__c,Item_No__c,Pack_Of__c,Logical_Invenory_Stock__c,Brand__r.Brand_Name__c,Approval_Required__c,
                                         Maximum_Order_Qty__c,Maximum_order_quantity_applicable__c,Type_of_Item__r.Item_Type__c              
                                         FROM POS_Item__c WHERE Account__c=:objAccount.Id AND Id IN :posItems_bySearch AND Id IN (SELECT POS_Item__c FROM Program_Item__c WHERE Program__c=:selectedProgramId)
                                         AND Id IN (SELECT POS_Item__c FROM ShoppingCartItems__c WHERE ShoppingCart__r.Active__c=true AND ShoppingCart__r.Account__c=:objAccount.Id AND ShoppingCart__r.CreatedById=:UserInfo.getUserId() AND ShoppingCart__r.CartStatus__c='Open' AND ShoppingCart__r.Program__c=:selectedProgramId)
                                         ORDER BY Item_Name__c];
            List<POS_Item__C> nonCartItems=[SELECT Id,Item_Name__c,Attachment_Id__c,Item_Descrption__c,Coupon_Attachment_Id__c,Active__c,Item_No__c,Pack_Of__c,Logical_Invenory_Stock__c,Brand__r.Brand_Name__c,Approval_Required__c,
                                            Maximum_Order_Qty__c,Maximum_order_quantity_applicable__c,Type_of_Item__r.Item_Type__c
                                            FROM POS_Item__c WHERE Account__c=:objAccount.Id AND Id IN :posItems_bySearch AND Id IN (SELECT POS_Item__c FROM Program_Item__c WHERE Program__c=:selectedProgramId)
                                            AND Id NOT IN (SELECT POS_Item__c FROM ShoppingCartItems__c WHERE ShoppingCart__r.Active__c=true AND ShoppingCart__r.Account__c=:objAccount.Id AND ShoppingCart__r.CreatedById=:UserInfo.getUserId() AND ShoppingCart__r.CartStatus__c='Open'  AND ShoppingCart__r.Program__c=:selectedProgramId) ORDER BY Item_Name__c];
            items.addAll(cartItems);
            items.addAll(nonCartItems);
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
        }
        for(POS_Item__c posItem :posItems)
        {
            String attachmentURL = String.isBlank(posItem.Attachment_Id__c)?'':objAccount.Lightning_Community_URL__c+'/servlet/servlet.FileDownload?file='+posItem.Attachment_Id__c;
            posItemDetails.add(new PosItem_Details(posItemIdsInCart.contains(posItem.Id),posItem,attachmentURL));
            
        }
        
        System.debug('posItemDetails-->'+posItemDetails);
        return new PosItem_DetailsListWrapper(posItemDetails,posItems_bySearch.size(),posItemIdsInCart.size());
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<Brand__c> getBrands_Apex()
    {
        objAccount=getAccount();
        return [SELECT Id,Brand_Name__c FROM Brand__c WHERE Account__c=:objAccount.Id ORDER BY Brand_Name__c ];
    }
    @AuraEnabled(cacheable=true)
    public static List<Item_Type__c> getItemTypes_Apex()
    {
        objAccount=getAccount();
        return [SELECT Id,Item_Type__c FROM Item_Type__c WHERE Account__c=:objAccount.Id ORDER BY Item_Type__c];
    }
    
    @AuraEnabled
    
    /** This method is used to create a record in the shopping cart to a user if the user doesn't have a shopping cart already */
    public static ShoppingCart__c createSeasonalShoppingCart_Apex(String selectedProgramId)
    {
        try{
            objAccount=getAccount();
            List<ShoppingCart__c> currentActiveShoppingCartForThisUser=[SELECT Id FROM ShoppingCart__c WHERE Active__c=true AND Account__c=:objAccount.Id AND CreatedById=:UserInfo.getUserId() AND CartStatus__c='Open' AND Program__c=:selectedProgramId ORDER BY CreatedDate];
            if(currentActiveShoppingCartForThisUser.isEmpty())
            {
                ShoppingCart__c shoppingCart=new ShoppingCart__c();
                shoppingCart.Active__c=true;
                shoppingCart.CartStatus__c='Open';
                shoppingCart.Account__c=objAccount.Id;
                shoppingCart.Inventory_Seasonal_Program__c = 'Seasonal Program';
                shoppingCart.Program__c=selectedProgramId;
                System.debug(shoppingCart);
                insert shoppingCart;
                return shoppingCart;
            }
            else
            {
                return currentActiveShoppingCartForThisUser[0];
            }
        }
        catch(exception ex)
        {
            InfiniumEmailNotifications.sendNotification('Inserting a Cart',ex.getMessage()+'\n'+'Class Name - InfiniumPosItemToCart_Apex '+'-- Line number --'+ex.getLineNumber());
            return new ShoppingCart__c ();
        }
        
    }
    
    @AuraEnabled
    public static Integer addAllPosItemsToCart_Apex (String searchPosItemKeyword,String chosenBrandId,
                                                     String chosenItemTypeId,String cartId,String sortById,String selectedProgramId)
    {
        system.debug('searchPosItemKeyword----->'+searchPosItemKeyword);
        system.debug('chosenBrandId----->'+chosenBrandId);
        system.debug('chosenItemTypeId----->'+chosenItemTypeId);
        system.debug('cartId----->'+cartId);
        system.debug('selectedProgramId----->'+selectedProgramId);
        system.debug('sortById----->'+sortById);
        objAccount=getAccount();
        Map<Id,POS_Item__c> posItems_Map=new Map<Id,POS_Item__c> ([SELECT Id FROM POS_Item__c WHERE Id IN (SELECT POS_Item__c FROM ShoppingCartItems__c WHERE ShoppingCart__c=:cartId)]);
        List<POS_Item__c> posItems=new List<POS_Item__c> ();
        List<ShoppingCartItems__c> shoppingCartItems=new List<ShoppingCartItems__c> ();
        if(String.isNotBlank(searchPosItemKeyword) || String.isNotBlank(chosenBrandId) || String.isNotBlank(chosenItemTypeId) || String.isNotBlank(sortById))
        { 
            String query='SELECT Id FROM POS_Item__c WHERE Account__c=\''+objAccount.Id+'\'';
            if(String.isNotBlank(searchPosItemKeyword))
            {
                searchPosItemKeyword='%'+searchPosItemKeyword+'%';
                query+=' AND (Item_Name__c LIKE : searchPosItemKeyword OR Item_No__c LIKE : searchPosItemKeyword) ';
            }
            if(String.isNotBlank(chosenBrandId))
            {
                query+=' AND Brand__c =:chosenBrandId ';
            }
            if(String.isNotBlank(chosenItemTypeId))
            {
                query+=' AND Type_of_Item__c =:chosenItemTypeId ';
            }
            if(sortById == 'LAST_N_DAYS')
            {
                query+=' AND CreatedDate = LAST_N_DAYS:10 ';
            }
            posItems=[SELECT Id FROM POS_Item__c WHERE Id IN :Database.query(query) AND Id NOT IN :posItems_Map.keySet() AND Id IN (SELECT POS_Item__c FROM Program_Item__c WHERE Program__c=:selectedProgramId)];
        }
        else
        {
            posItems=[SELECT Id FROM POS_Item__c WHERE Account__c=:objAccount.Id  AND Id NOT IN :posItems_Map.keySet() AND Id IN (SELECT POS_Item__c FROM Program_Item__c WHERE Program__c=:selectedProgramId)];
        }
        
        for(POS_Item__c posItem : posItems)
        {
            ShoppingCartItems__c shoppingCartItem=new ShoppingCartItems__c ();
            shoppingCartItem.Active__c=true;
            shoppingCartItem.POS_Item__c=posItem.Id;
            shoppingCartItem.ShoppingCart__c=cartId;
            shoppingCartItems.add(shoppingCartItem);
        }
        insert shoppingCartItems;
        return posItems_Map.keySet().size()+shoppingCartItems.size();
    }
    
    @AuraEnabled
    public static String addPosItemToCart_Apex (String selectedProgramId,String posItemId)
    {
        system.debug('selectedProgramId----->'+selectedProgramId);
        system.debug('posItemId----->'+posItemId);
        try{
            objAccount=getAccount();
            List<ShoppingCart__c> currentActiveShoppingCartForThisUser=[SELECT Id FROM ShoppingCart__c
                                                                        WHERE Active__c=true AND Account__c=:objAccount.Id AND CreatedById=:UserInfo.getUserId() AND CartStatus__c='Open' AND Inventory_Seasonal_Program__c = 'Seasonal Program' AND Program__c=:selectedProgramId ORDER BY CreatedDate];
            System.debug('currentActiveShoppingCartForThisUser'+currentActiveShoppingCartForThisUser);
            if(currentActiveShoppingCartForThisUser.isEmpty())
            {
               ShoppingCart__c shoppingCart = createSeasonalShoppingCart_Apex(selectedProgramId); 
                ShoppingCartItems__c shoppingCartItem=new ShoppingCartItems__c();
                shoppingCartItem.Active__c=true;
                shoppingCartItem.POS_Item__c=posItemId;
                shoppingCartItem.ShoppingCart__c=shoppingCart.Id;
                insert shoppingCartItem;
            }
            else
            {
                if([SELECT Id FROM POS_Item__c WHERE Id=:posItemId AND Id IN (SELECT POS_Item__c FROM ShoppingCartItems__c WHERE ShoppingCart__c=:currentActiveShoppingCartForThisUser[0].Id)].isEmpty())
                {
                    ShoppingCartItems__c shoppingCartItem=new ShoppingCartItems__c();
                    shoppingCartItem.Active__c=true;
                    shoppingCartItem.POS_Item__c=posItemId;
                    shoppingCartItem.ShoppingCart__c=currentActiveShoppingCartForThisUser[0].Id;
                    insert shoppingCartItem;
                    System.debug('shoppingCartItem'+shoppingCartItem);
                }
            }
            return 'done';
        }catch(Exception ex)
        {
            InfiniumEmailNotifications.sendNotification('Adding Item To Cart',ex.getMessage()+'\n'+'Inputs are -- selectedPosItemId-- '+JSON.serialize(posItemId) +'\n'+'Class Name - InfiniumPosItemToCart_Apex '+'-- Line number --'+ex.getLineNumber());
            return 'not done';
        }
    }
    
    @AuraEnabled
    public static String removePosItemFromCart_Apex(String selectedProgramId,String posItemId)
    {
        try{
            objAccount=getAccount();
            List<ShoppingCart__c> currentActiveShoppingCartForThisUser=[SELECT Id,Order__c FROM ShoppingCart__c WHERE Active__c=true AND Account__c=:objAccount.Id AND CreatedById=:UserInfo.getUserId() AND CartStatus__c='Open' AND Inventory_Seasonal_Program__c = 'Seasonal Program' AND Program__c=:selectedProgramId ORDER BY CreatedDate];
            delete [SELECT Id FROM ShoppingCartItems__c WHERE POS_Item__c=:posItemId AND ShoppingCart__c=:currentActiveShoppingCartForThisUser[0].Id];
            List<OrderDestinationItem__c> cometOrderItems=[SELECT Id FROM OrderDestinationItem__c WHERE OrderDestination__r.Order__c=:currentActiveShoppingCartForThisUser[0].Order__c AND POS_Item__c=:posItemId];
            delete cometOrderItems;
            List<OrderDestination__c> cometOrders=[SELECT Id FROM OrderDestination__c WHERE Order__c=:currentActiveShoppingCartForThisUser[0].Order__c AND Id NOT IN (SELECT OrderDestination__c  FROM OrderDestinationItem__c)]; 
            delete cometOrders;
            return 'done';
        }
        catch(Exception ex)
        {
            InfiniumEmailNotifications.sendNotification('Removing Items To Cart',ex.getMessage()+'\n'+'Inputs are -- selectedPosItemId-- '+JSON.serialize(posItemId)+'\n'+'Class Name - InfiniumPosItemToCart_Apex '+'-- Line number --'+ex.getLineNumber());
            return 'not done';
        }
    }
    
}