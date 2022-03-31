public class DFVSeasonalOrderController {
    public static Account objAccount;
    @AuraEnabled
    public static User getUserDetails()
    {
        return [SELECT Id,UserName,Profile.Name,Profile.Id,Email FROM User WHERE Id=:UserInfo.getUserId()];
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
    
    
    /***** DFVOpenProgramListComponent -- START -- *****/
    /** getting all chairbudget details for current logged in user **/
    @AuraEnabled
    public static List<Program_ChairBudget_Details> getProgram_ChairBudgetList_Apex() { 
        objAccount=getAccount();
        List<Program_ChairBudget_Details> program_ChairBudgetDetails=new List<Program_ChairBudget_Details> ();
        Map<Id,Id> programIdWithEmergeOrderIds=new Map<Id,Id> ();
        for(ShoppingCart__c shoppingCart : [SELECT Order__c,Program__c FROM ShoppingCart__c WHERE Active__c=true AND Account__c=:objAccount.Id AND CreatedById=:UserInfo.getUserId() AND CartStatus__c='Open'
                                           ])
            programIdWithEmergeOrderIds.put(shoppingCart.Program__c,shoppingCart.Order__c);   
        for(Chair_Budget__c chairBudget : [SELECT Id,Allocated_Budget__c,Available_Budget__c,Consumed_Budget__c,Shared_Budget__c,Chair__r.Chair_Name__c,Chair__r.Level__c,Chair__r.Active__c,
                                           Chair__r.User__c,Program__r.Name__c,Program__r.Attachment_Id__c,
                                           Program__r.Start_Date__c,Program__r.Closing_Date__c,Program__r.In_Market_Date__c,Available_Chair_Budget__c,Chair_DFV_Department_Budget__c,Utilized_DFV_Department_Budget__c,Available_DFV_Department_Budget__c FROM Chair_Budget__c WHERE Program__r.Account__c=:objAccount.Id AND Chair__r.User__c=:UserInfo.getUserId()
                                           AND (Program__r.Start_Date__c <= :system.now().date()) AND (Program__r.Closing_Date__c  >=:system.now().date()) Order by Program__r.Name__c DESC])
        {
            program_ChairBudgetDetails.add(new Program_ChairBudget_Details(programIdWithEmergeOrderIds.containsKey(chairBudget.Program__c)?String.isBlank(programIdWithEmergeOrderIds.get(chairBudget.Program__c))?'':programIdWithEmergeOrderIds.get(chairBudget.Program__c):'',chairBudget));
        }            
        System.debug('program_ChairBudgetDetails---->'+program_ChairBudgetDetails);
        return program_ChairBudgetDetails;
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
    /***** DFVOpenProgramListComponent -- STOP -- *****/
    
    /***** DFVPOSItemMenuComponent -- START -- *****/
    public class PosItem_Details
    {
        @AuraEnabled
        public Boolean isItemAddedToCart ;   
        @AuraEnabled
        public POS_Item__c posItem; 
        @AuraEnabled
        public Boolean isItemProcessing;
        
        public PosItem_Details(Boolean isItemAddedToCart,POS_Item__c posItem,Boolean isItemProcessing)
        {
            this.isItemAddedToCart=isItemAddedToCart;
            this.posItem=posItem;
            this.isItemProcessing=isItemProcessing;
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
    
   //Authors : NP, SN, TP, VB ; Date:01-07-2020
   //CR - DFV-30-Jun-20 
   //commenting the below lines since there was a need to make a change in query held by the variable query. 
   //Removing Active__c=true in query the WHERE condition
   
   /** @AuraEnabled
    public static PosItem_DetailsListWrapper getPosItems_Apex (String searchPosItemKeyword,String chosenBrandId,
                                                               String chosenItemTypeId,String sortById,String selectedProgramId,Integer recordStartIndex)
    {
        objAccount=getAccount();
        Set<Id> posItemIdsInCart=new Set<Id> ();
        List<POS_Item__c> posItems=new List<POS_Item__c> ();
        List<PosItem_Details> posItemDetails=new List<PosItem_Details> ();
        //Autors - Thanvi,Sanjana Date - 14-02-2020
        //The condition Inventory_Seasonal_Program__c='Inventory' is introduced to fetch all the Pos items in the shopping cart that belonged to inventory
        for(ShoppingCartItems__c shoppingCartItem : [SELECT POS_Item__c FROM ShoppingCartItems__c WHERE ShoppingCart__r.Active__c=true AND ShoppingCart__r.Account__c=:objAccount.Id AND ShoppingCart__r.CreatedById=:UserInfo.getUserId() AND ShoppingCart__r.CartStatus__c='Open' AND 
        ShoppingCart__r.Inventory_Seasonal_Program__c='Seasonal Program' AND ShoppingCart__r.Program__c=:selectedProgramId ])
            posItemIdsInCart.add(shoppingCartItem.POS_Item__c);
        	System.debug('posItemIdsInCart-->'+posItemIdsInCart);
        system.debug('selectedProgramId-->'+selectedProgramId);
        String query='SELECT Id,Attachment_Id__c,Item_Descrption__c,Coupon_Attachment_Id__c,Active__c,Item_Name__c,Item_No__c,Pack_Of__c,Logical_Invenory_Stock__c,Brand__r.Brand_Name__c,Approval_Required__c,Maximum_Order_Qty__c,Maximum_order_quantity_applicable__c,Price__c,Type_of_Item__r.Item_Type__c';
        query=query+' FROM POS_Item__c WHERE Account__c=\''+objAccount.Id+'\' AND Active__c=true AND Id IN (SELECT POS_Item__c FROM Program_Item__c WHERE Program__c=\''+selectedProgramId+'\')';
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
            posItemDetails.add(new PosItem_Details(posItemIdsInCart.contains(posItem.Id),posItem,false));
        System.debug('posItemDetails-->'+posItemDetails);
        return new PosItem_DetailsListWrapper(posItemDetails,posItems_bySearch.size(),posItemIdsInCart.size());
    }**/
    

@AuraEnabled
    public static PosItem_DetailsListWrapper getPosItems_Apex (String searchPosItemKeyword,String chosenBrandId,
                                                               String chosenItemTypeId,String sortById,String selectedProgramId,Integer recordStartIndex)
    {
        objAccount=getAccount();
        Set<Id> posItemIdsInCart=new Set<Id> ();
        List<POS_Item__c> posItems=new List<POS_Item__c> ();
        List<PosItem_Details> posItemDetails=new List<PosItem_Details> ();
        //Autors - Thanvi,Sanjana Date - 14-02-2020
        //The condition Inventory_Seasonal_Program__c='Inventory' is introduced to fetch all the Pos items in the shopping cart that belonged to inventory
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
            posItemDetails.add(new PosItem_Details(posItemIdsInCart.contains(posItem.Id),posItem,false));
        System.debug('posItemDetails-->'+posItemDetails);
        return new PosItem_DetailsListWrapper(posItemDetails,posItems_bySearch.size(),posItemIdsInCart.size());
    }
    
    
    @AuraEnabled
    public static List<Brand__c> getBrands_Apex()
    {
        objAccount=getAccount();
        return [SELECT Id,Brand_Name__c FROM Brand__c WHERE Account__c=:objAccount.Id ORDER BY Brand_Name__c ];
    }
    @AuraEnabled
    public static List<Item_Type__c> getItemTypes_Apex()
    {
        objAccount=getAccount();
        return [SELECT Id,Item_Type__c FROM Item_Type__c WHERE Account__c=:objAccount.Id ORDER BY Item_Type__c];
    }
    /** Changing the actor name of the apex method createCart_Apex to createSeasonalShoppingCart_Apex  on change request.
Date - 22 Jan 2020  Author - Thanvi - CR number : DFV-20-Jan-1 **/
    @AuraEnabled 
    /** This method is used to create a record in the shopping cart to a user if the user doesn't have a shopping cart already */
    public static ShoppingCart__c createSeasonalShoppingCart_Apex(String selectedProgramId)
    {
        try{
            objAccount=getAccount();
            List<ShoppingCart__c> currentActiveShoppingCartForThisUser=[SELECT Id FROM ShoppingCart__c WHERE Active__c=true AND Account__c=:objAccount.Id
                                                                        AND CreatedById=:UserInfo.getUserId() AND CartStatus__c='Open' AND Program__c=:selectedProgramId ORDER BY CreatedDate];
            if(currentActiveShoppingCartForThisUser.isEmpty())
            {
                ShoppingCart__c shoppingCart=new ShoppingCart__c();
                shoppingCart.Active__c=true;
                shoppingCart.CartStatus__c='Open';
                shoppingCart.Account__c=objAccount.Id;
                /** to create a record in the shopping cart for Seasonal Program ordering flow by passing the value to the parameter as "Seasonal Program" on change request.
Date - 22 Jan 2020  Author - Thanvi - CR number : DFV-20-Jan-1 **/
                shoppingCart.Inventory_Seasonal_Program__c = 'Seasonal Program';
                shoppingCart.Program__c=selectedProgramId;
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
            DFVEmailNotifications.sendNotification('Inserting a Cart',ex.getMessage()+'\n'+'Class Name - DFVInventoryOrderController '+'-- Line number --'+ex.getLineNumber());
            return new ShoppingCart__c ();
        }
        
    }
    
    @AuraEnabled
    public static Integer addAllPosItemsToCart_Apex (String searchPosItemKeyword,String chosenBrandId,
                                                     String chosenItemTypeId,String cartId,String sortById,String selectedProgramId)
    {
        objAccount=getAccount();
        Map<Id,POS_Item__c> posItems_Map=new Map<Id,POS_Item__c> ([SELECT Id FROM POS_Item__c WHERE Id IN (SELECT POS_Item__c FROM ShoppingCartItems__c WHERE ShoppingCart__c=:cartId)]);
        List<POS_Item__c> posItems=new List<POS_Item__c> ();
        List<ShoppingCartItems__c> shoppingCartItems=new List<ShoppingCartItems__c> ();
        if(String.isNotBlank(searchPosItemKeyword) || String.isNotBlank(chosenBrandId) || String.isNotBlank(chosenItemTypeId) || String.isNotBlank(sortById))
        { 
            String query='SELECT Id FROM POS_Item__c WHERE Active__c=true AND Account__c=\''+objAccount.Id+'\'';
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
            posItems=[SELECT Id FROM POS_Item__c WHERE Active__c=true AND Account__c=:objAccount.Id  AND Id NOT IN :posItems_Map.keySet() AND Id IN (SELECT POS_Item__c FROM Program_Item__c WHERE Program__c=:selectedProgramId)];
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
    public static PosItem_DetailsListWrapper addPosItemToCart_Apex (String searchPosItemKeyword,String chosenBrandId,
                                                                    String chosenItemTypeId,String sortById,String selectedProgramId,Integer recordStartIndex,String posItemId)
    {
        system.debug('searchPosItemKeyword----->'+searchPosItemKeyword);
        system.debug('chosenBrandId----->'+chosenBrandId);
        system.debug('chosenItemTypeId----->'+chosenItemTypeId);
        system.debug('sortById----->'+sortById);
        system.debug('selectedProgramId----->'+selectedProgramId);
        system.debug('recordStartIndex----->'+recordStartIndex);
        system.debug('posItemId----->'+posItemId);
        try{
            objAccount=getAccount();
            List<ShoppingCart__c> currentActiveShoppingCartForThisUser=[SELECT Id FROM ShoppingCart__c
                                                                        WHERE Active__c=true AND Account__c=:objAccount.Id AND CreatedById=:UserInfo.getUserId() AND CartStatus__c='Open' AND Program__c=:selectedProgramId ORDER BY CreatedDate];
           System.debug('currentActiveShoppingCartForThisUser'+currentActiveShoppingCartForThisUser);
            if(currentActiveShoppingCartForThisUser.isEmpty())
            {
                ShoppingCart__c shoppingCart=new ShoppingCart__c();
                shoppingCart.Active__c=true;
                shoppingCart.CartStatus__c='Open';
                shoppingCart.Account__c=objAccount.Id;
                shoppingCart.Inventory_Seasonal_Program__c = 'Seasonal Program';
                shoppingCart.Program__c=selectedProgramId;
                insert shoppingCart;
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
        }catch(Exception ex)
        {
            DFVEmailNotifications.sendNotification('Adding Item To Cart',ex.getMessage()+'\n'+'Inputs are -- selectedPosItemId-- '+JSON.serialize(posItemId)
                                                   +'\n'+'Class Name - DFVSeasonalOrderController '+'-- Line number --'+ex.getLineNumber());
        }
        
        return getPosItems_Apex (searchPosItemKeyword,chosenBrandId,chosenItemTypeId,sortById,selectedProgramId,recordStartIndex);
    }
    @AuraEnabled
    public static PosItem_DetailsListWrapper removePosItemFromCart_Apex(String searchPosItemKeyword,String chosenBrandId,
                                                                        String chosenItemTypeId,String sortById,String selectedProgramId,Integer recordStartIndex,String posItemId)
    {
        try{
            objAccount=getAccount();
            List<ShoppingCart__c> currentActiveShoppingCartForThisUser=[SELECT Id,Order__c FROM ShoppingCart__c WHERE Active__c=true AND Account__c=:objAccount.Id AND CreatedById=:UserInfo.getUserId() AND CartStatus__c='Open' AND Program__c=:selectedProgramId ORDER BY CreatedDate];
            delete [SELECT Id FROM ShoppingCartItems__c WHERE POS_Item__c=:posItemId AND ShoppingCart__c=:currentActiveShoppingCartForThisUser[0].Id];
            List<OrderDestinationItem__c> cometOrderItems=[SELECT Id FROM OrderDestinationItem__c WHERE OrderDestination__r.Order__c=:currentActiveShoppingCartForThisUser[0].Order__c AND POS_Item__c=:posItemId];
            delete cometOrderItems;
            //  calculateBudget(selectedProgramId,currentActiveShoppingCartForThisUser[0].Order__c );
            List<OrderDestination__c> cometOrders=[SELECT Id FROM OrderDestination__c WHERE Order__c=:currentActiveShoppingCartForThisUser[0].Order__c AND Id NOT IN (SELECT OrderDestination__c  FROM OrderDestinationItem__c)]; 
            delete cometOrders;
        }
        catch(Exception ex)
        {
            DFVEmailNotifications.sendNotification('Removing Items To Cart',ex.getMessage()+'\n'+'Inputs are -- selectedPosItemId-- '+JSON.serialize(posItemId)
                                                   +'\n'+'Class Name - DFVInventoryOrderController '+'-- Line number --'+ex.getLineNumber());
        }
        return getPosItems_Apex (searchPosItemKeyword,chosenBrandId,chosenItemTypeId,sortById,selectedProgramId,recordStartIndex);
    }
    
    
    /***** DFVPOSItemMenuComponent -- STOP -- *****/
    /***** DFVShippingCartComponent -- START -- *****/
    
    public class AddressBook_QtyWrapper
    {
        @AuraEnabled
        public Boolean isAddressSelected;
        @AuraEnabled
        public String shippingMethodId;
        @AuraEnabled
        public AddressBook__c addressBook;
        @AuraEnabled
        public Integer itemQuantity;
        @AuraEnabled
        public Decimal itemPrice;
        public AddressBook_QtyWrapper (Boolean isAddressSelected,String shippingMethodId,AddressBook__c addressBook,Integer itemQuantity,Decimal itemPrice)
        {
            this.addressBook=addressBook;
            this.itemQuantity=itemQuantity;
            this.itemPrice=itemPrice;
            this.isAddressSelected=isAddressSelected;
            this.shippingMethodId=shippingMethodId;
        }
    }
    public class ShoppingCartDetails 
    {
        @AuraEnabled
        public POS_Item__c posItem ;
        @AuraEnabled
        public List<AddressBook_QtyWrapper> addressBook_Qty_List;
        @AuraEnabled
        public Integer itemTotalQty;
        @AuraEnabled
        public Decimal itemTotalPrice;
        public ShoppingCartDetails (POS_Item__c posItem,List<AddressBook_QtyWrapper> addressBook_Qty_List,Integer itemTotalQty,
                                    Decimal itemTotalPrice)
        {
            this.posItem=posItem;
            this.addressBook_Qty_List=addressBook_Qty_List;
            this.itemTotalQty=itemTotalQty;
            this.itemTotalPrice=itemTotalPrice;
        }
    }
    public class ShoppingCartDetails_EmergeOrderId
    {
        @AuraEnabled
        public List<ShoppingCartDetails> cartDetails;
        @AuraEnabled
        public String emergeOrderId;
        public ShoppingCartDetails_EmergeOrderId(List<ShoppingCartDetails> cartDetails,String emergeOrderId)
        {
            this.cartDetails=cartDetails;
            this.emergeOrderId=emergeOrderId;
        }
        
    }
    @AuraEnabled
    public static ShoppingCartDetails_EmergeOrderId getCartItems_Apex(String selectedProgramId) 
    {
        objAccount=getAccount();
        List<ShoppingCartDetails> cartDetails=new List<ShoppingCartDetails> ();
        List<ShoppingCart__c> currentActiveShoppingCartForThisUser=[SELECT Id,Order__c FROM ShoppingCart__c WHERE Active__c=true AND Account__c=:objAccount.Id AND CreatedById=:UserInfo.getUserId() AND CartStatus__c='Open' AND Program__c=:selectedProgramId ORDER BY CreatedDate];
        Map<Id,List<AddressBook_QtyWrapper>> posItemIdWithAddresses =new Map<Id,List<AddressBook_QtyWrapper>> ();
        Map<Id,AddressBook__c> selectedAddressBookList=new Map<Id,AddressBook__c> ([SELECT Id, Name, Destination_Name__c, City__c,Shipto_Company__c, Shipto_Name__c, State__c, State__r.State_Name__c, Address__c, Division__r.Territory_Name__c, Active__c  FROM AddressBook__c
                                                                                    WHERE Account__C = :objAccount.ID AND Id IN (SELECT AddressBook__c FROM OrderDestination__c WHERE Order__c=:currentActiveShoppingCartForThisUser[0].Order__c)]);
        
        for(OrderDestinationItem__c cometOrderItem : [SELECT Id,POS_Item__c,Quantity__c,OrderDestination__r.Shipping_Method__c,Total_Line_Amount__c,SelectedQuantity__c,OrderDestination__r.AddressBook__c FROM OrderDestinationItem__c WHERE OrderDestination__r.Order__c=:currentActiveShoppingCartForThisUser[0].Order__c AND OrderDestination__r.OrdStatus__c='Open'])
        {
            if(!posItemIdWithAddresses.containsKey(cometOrderItem.POS_Item__c))
            {
                posItemIdWithAddresses.put(cometOrderItem.POS_Item__c,new List<AddressBook_QtyWrapper> {new AddressBook_QtyWrapper(true,cometOrderItem.OrderDestination__r.Shipping_Method__c,selectedAddressBookList.get(cometOrderItem.OrderDestination__r.AddressBook__c),Integer.valueOf(cometOrderItem.SelectedQuantity__c),cometOrderItem.Total_Line_Amount__c)});
            }
            else
            {
                List<AddressBook_QtyWrapper> addresses= posItemIdWithAddresses.get(cometOrderItem.POS_Item__c);  
                if(addresses==null)
                    addresses=new List<AddressBook_QtyWrapper> (); 
                addresses.add(new AddressBook_QtyWrapper(true,cometOrderItem.OrderDestination__r.Shipping_Method__c,selectedAddressBookList.get(cometOrderItem.OrderDestination__r.AddressBook__c),Integer.valueOf(cometOrderItem.SelectedQuantity__c),cometOrderItem.Total_Line_Amount__c));
                posItemIdWithAddresses.put(cometOrderItem.POS_Item__c,addresses);
            }
        }
        
        for(POS_Item__c posItem : [SELECT Id,Item_Name__c,Active__c,Attachment_Id__c,Item_No__c,Pack_Of__c,Price__c,Logical_Invenory_Stock__c,Brand__r.Brand_Name__c,
                                   Approval_Required__c,Maximum_Order_Qty__c,Maximum_order_quantity_applicable__c,
                                   Type_of_Item__r.Item_Type__c FROM POS_Item__c WHERE Account__c=:objAccount.Id AND Id IN (SELECT POS_Item__c FROM ShoppingCartItems__c WHERE ShoppingCart__c=:currentActiveShoppingCartForThisUser[0].Id) ORDER BY Brand__r.Brand_Name__c])
        {
            Integer totalQuantity=0;
            Decimal totalPrice=0;
            if(posItemIdWithAddresses.containsKey(posItem.Id))
            {
                for(AddressBook_QtyWrapper address_Qty : posItemIdWithAddresses.get(posItem.Id))
                {
                    totalQuantity+=address_Qty.itemQuantity==null?0:address_Qty.itemQuantity;
                    totalPrice+=address_Qty.itemPrice==null?0:address_Qty.itemPrice;
                }
            }
            cartDetails.add(new ShoppingCartDetails(posItem,posItemIdWithAddresses.containsKey(posItem.Id)?posItemIdWithAddresses.get(posItem.Id):new List<AddressBook_QtyWrapper> (),totalQuantity,totalPrice));
        }
        
        
        return new ShoppingCartDetails_EmergeOrderId(cartDetails,currentActiveShoppingCartForThisUser[0].Order__c==null?'':currentActiveShoppingCartForThisUser[0].Order__c);
    }  
    @AuraEnabled
    public static Chair_Budget__c getChairBudgetDetails_Apex(String selectedChairBudgetId) { 
        return [SELECT Id,Allocated_Budget__c,Available_Budget__c,Consumed_Budget__c,
                Shared_Budget__c,Chair__r.Chair_Name__c,Chair__r.Level__c,Chair__r.Active__c,
                Chair__r.User__c,Program__r.Name__c,Program__r.Attachment_Id__c,
                Program__r.Start_Date__c,Program__r.Closing_Date__c,Program__r.In_Market_Date__c,Available_Chair_Budget__c,Chair_DFV_Department_Budget__c,Utilized_DFV_Department_Budget__c,Available_DFV_Department_Budget__c FROM Chair_Budget__c WHERE Chair__r.User__c=:UserInfo.getUserId() AND Id=:selectedChairBudgetId];
    }
    @AuraEnabled
    public static String updateQuantityForItem_Apex(String posItemId,String shippingAddressId,String emergeOrderId,Integer quantity)
    {
        try
        {
            if(String.isNotBlank(posItemId) && String.isNotBlank(shippingAddressId) && String.isNotBlank(emergeOrderId))
            {
                
                OrderDestinationItem__c cometOrderItem= [SELECT Id,Quantity__c,SelectedQuantity__c,OrderDestination__r.AddressBook__c FROM OrderDestinationItem__c WHERE OrderDestination__r.AddressBook__c=:shippingAddressId AND POS_Item__c=:posItemId AND OrderDestination__r.Order__c=:emergeOrderId];
                cometOrderItem.Quantity__c=quantity;
                cometOrderItem.SelectedQuantity__c=quantity;
                update cometOrderItem;
            }
            return 'DONE';
        }
        catch(Exception ex)
        {
            DFVEmailNotifications.sendNotification('Updating quantity fro selected item',ex.getMessage()+'\n'+'Inputs are -- posItemId-- '+JSON.serialize(posItemId)+'\n'+
                                                   '-- shaippingAddressId --'+JSON.serialize(shippingAddressId)+'\n'+
                                                   '-- emergeOrderId--'+JSON.serialize(emergeOrderId)+'\n'+
                                                   '-- quantity--'+JSON.serialize(quantity)
                                                   +'\n'+'Class Name - DFVInventoryOrderController '+'-- Line number --'+ex.getLineNumber());
            return 'Not_Done';
        }
    }
    @AuraEnabled
    public static ShoppingCartDetails_EmergeOrderId deleteItemFromCart_Apex(String posItemId,String selectedProgramId,String emergeOrderId)
    {
        try{
            objAccount=getAccount();
            List<ShoppingCartItems__c> shoppingCartItem=[SELECT Id FROM ShoppingCartItems__c WHERE ShoppingCart__r.Active__c=true AND ShoppingCart__r.Account__c=:objAccount.Id AND ShoppingCart__r.CreatedById=:UserInfo.getUserId() AND ShoppingCart__r.CartStatus__c='Open' AND POS_Item__c=:posItemId AND ShoppingCart__r.Program__c=:selectedProgramId];
            delete shoppingCartItem;
            List<OrderDestinationItem__c> cometOrderItems=[SELECT Id FROM OrderDestinationItem__c WHERE OrderDestination__r.Order__c=:emergeOrderId AND POS_Item__c=:posItemId];
            delete cometOrderItems;
            // calculateBudget(selectedProgramId,emergeOrderId);
            List<OrderDestination__c> cometOrders=[SELECT Id FROM OrderDestination__c WHERE Order__c=:emergeOrderId AND Id NOT IN (SELECT OrderDestination__c  FROM OrderDestinationItem__c WHERE OrderDestination__r.Order__c=:emergeOrderId)]; 
            delete cometOrders;
            return getCartItems_Apex(selectedProgramId);
        }catch(exception ex)
        {
            DFVEmailNotifications.sendNotification('Deleting a cart item from cart',ex.getMessage()+'\n'+'Inputs are --  '+'\n'+
                                                   ' -- posItemId -- '+posItemId+'\n'+
                                                   ' -- selectedProgramId -- '+selectedProgramId+'\n'+
                                                   ' -- emergeOrderId -- '+emergeOrderId+'\n'+
                                                   +'\n'+'Class Name - DFVInventoryOrderController '+'-- Line number --'+ex.getLineNumber());
            return getCartItems_Apex(selectedProgramId);
            
        }
    }
    /**** DFVShippingAllAddressComponent START ****/
    public class ShippingAddress_ShippingMethodWrapper
    {
        @AuraEnabled
        public List<AddressBook_QtyWrapper> shippingAddresses;
        @AuraEnabled
        public List<Shipping_Method__c> shippingMethodOptions;
        @AuraEnabled
        public List<AddressBook_QtyWrapper> selectedShippingAddresses;
        public ShippingAddress_ShippingMethodWrapper(List<AddressBook_QtyWrapper> shippingAddresses,List<Shipping_Method__c> shippingMethodOptions,List<AddressBook_QtyWrapper> selectedShippingAddresses)
        {
            this.shippingAddresses=shippingAddresses;
            this.shippingMethodOptions=shippingMethodOptions;
            this.selectedShippingAddresses=selectedShippingAddresses;
        }
    }
    @AuraEnabled
    public static ShippingAddress_ShippingMethodWrapper getShippingAddresses_Apex (String posItemId,String selectedProgramId,String emergeOrderId)
    {
        objAccount=getAccount();
        Set<Id> userStateIds=new Set<Id> ();
        List<AddressBook_QtyWrapper> shippingAddresses=new List<AddressBook_QtyWrapper> ();
        List<Shipping_Method__c> shippingMethodOptions=loadShippingMethodList();
        List<AddressBook_QtyWrapper> selectedShippingAddresses=new List<AddressBook_QtyWrapper> ();
        Map<Id,Id> addressBookIdWithShippingMethodId=new Map<Id,Id> ();
        
        for(States_Territory__c stateTerritory : [SELECT ID, Name, State__c FROM States_Territory__c WHERE Territory__c IN ( SELECT Territory__c FROM Users_Territory__c WHERE (User__c =:UserInfo.getUserId())) ])
            userStateIds.add(stateTerritory.State__c);
        if(String.isBlank(posItemId))
        {
            List<POS_Item__c> posItems=[SELECT Id FROM POS_Item__c 
                                        WHERE Id IN (SELECT POS_Item__c FROM ShoppingCartItems__c 
                                                     WHERE ShoppingCart__r.Active__c=true AND ShoppingCart__r.Account__c=:objAccount.Id
                                                     AND ShoppingCart__r.CreatedById=:UserInfo.getUserId() AND ShoppingCart__r.CartStatus__c='Open' AND ShoppingCart__r.Program__c=:selectedProgramId)];
            for(OrderDestination__c cometOrder : [SELECT Id,AddressBook__c,Shipping_Method__c,(SELECT Id FROM OrderDestinationItems__r)Shipping_Method__c FROM OrderDestination__c WHERE Order__c=:emergeOrderId])
            {
                if(posItems.size() == cometOrder.OrderDestinationItems__r.size())
                    addressBookIdWithShippingMethodId.put(cometOrder.AddressBook__c,cometOrder.Shipping_Method__c );
            }
        }
        else
        {
            for(OrderDestination__c cometOrder : [SELECT Id,AddressBook__c,Shipping_Method__c FROM OrderDestination__c
                                                  WHERE Order__c=:emergeOrderId AND Id IN (SELECT OrderDestination__c FROM OrderDestinationItem__c WHERE POS_Item__c=:posItemId)])
            {
                addressBookIdWithShippingMethodId.put(cometOrder.AddressBook__c,cometOrder.Shipping_Method__c );
            }
        }
        for(AddressBook__c addressBook : [SELECT Id, Name, Destination_Name__c,City__c, Shipto_Company__c, 
                                          State__c, State__r.State_Name__c, Address__c, Division__r.Territory_Name__c, Active__c  FROM AddressBook__c 
                                          WHERE Account__C = :objAccount.ID AND Active__c=True AND (State__c IN :userStateIds) ORDER BY Destination_Name__c ASC])
        {
            if(addressBookIdWithShippingMethodId.containsKey(addressBook.Id))
                selectedShippingAddresses.add(new AddressBook_QtyWrapper(addressBookIdWithShippingMethodId.containsKey(addressBook.Id),addressBookIdWithShippingMethodId.containsKey(addressBook.Id)?String.valueOf(addressBookIdWithShippingMethodId.get(addressBook.Id)):'',addressBook,0,0));
            shippingAddresses.add(new AddressBook_QtyWrapper(addressBookIdWithShippingMethodId.containsKey(addressBook.Id),addressBookIdWithShippingMethodId.containsKey(addressBook.Id)?String.valueOf(addressBookIdWithShippingMethodId.get(addressBook.Id)):'',addressBook,0,0));
        }                                     
        return new ShippingAddress_ShippingMethodWrapper(shippingAddresses,shippingMethodOptions,selectedShippingAddresses);
    }
    @AuraEnabled
    public static List<AddressBook_QtyWrapper> searchShippingAddresses_Apex(String searchKeyWord,String selectedShippingAddresses)
    {
        objAccount=getAccount();
        Set<Id> userStateIds=new Set<Id> ();
        List<AddressBook_QtyWrapper> shippingAddresses=new List<AddressBook_QtyWrapper> ();
        Map<Id,String> addressBookIdWithShippingMethodId=new Map<Id,String> ();
        for(AddressBook_QtyWrapper address_Qty :(List<AddressBook_QtyWrapper>)System.JSON.deserialize(selectedShippingAddresses, List<AddressBook_QtyWrapper>.class))
        {
            addressBookIdWithShippingMethodId.put(address_Qty.addressBook.Id,String.valueOf(address_Qty.shippingMethodId));
        }
        
        for(States_Territory__c stateTerritory : [SELECT ID, Name, State__c FROM States_Territory__c WHERE Territory__c IN ( SELECT Territory__c FROM Users_Territory__c WHERE User__c =:UserInfo.getUserId()) ])
            userStateIds.add(stateTerritory.State__c);
        
        if(String.isBlank(searchKeyword))
        {
            for(AddressBook__c addressBook : [SELECT Id, Name, Destination_Name__c,City__c, Shipto_Company__c, Shipto_Name__c, State__c, State__r.State_Name__c, Address__c, Division__r.Territory_Name__c, Active__c  FROM AddressBook__c 
                                              WHERE Account__C = :objAccount.ID AND Active__c=True AND (State__c IN :userStateIds) ORDER BY Destination_Name__c ASC])
            {
                shippingAddresses.add(new AddressBook_QtyWrapper(addressBookIdWithShippingMethodId.containsKey(addressBook.Id),addressBookIdWithShippingMethodId.containsKey(addressBook.Id)?String.valueOf(addressBookIdWithShippingMethodId.get(addressBook.Id)):'',addressBook,0,0));
            } 
        } 
        else
        {
            searchKeyword='%'+searchKeyword+'%';
            for(AddressBook__c addressBook : [SELECT Id, Name,City__c, Destination_Name__c, Shipto_Company__c, Shipto_Name__c, State__c, State__r.State_Name__c, Address__c, Division__r.Territory_Name__c, Active__c  FROM AddressBook__c 
                                              WHERE Account__C = :objAccount.ID AND Active__c=True AND (State__c IN :userStateIds) AND (Shipto_Company__c LIKE :searchKeyword OR Shipto_Name__c LIKE :searchKeyword OR Destination_Name__c LIKE :searchKeyword OR City__c LIKE :searchKeyword) ORDER BY Destination_Name__c ASC])
            {
                shippingAddresses.add(new AddressBook_QtyWrapper(addressBookIdWithShippingMethodId.containsKey(addressBook.Id),addressBookIdWithShippingMethodId.containsKey(addressBook.Id)?String.valueOf(addressBookIdWithShippingMethodId.get(addressBook.Id)):'',addressBook,0,0));
            } 
        }                                   
        return shippingAddresses;
    }
    @AuraEnabled
    public static List<Shipping_Method__c> loadShippingMethodList()
    {
        objAccount=getAccount();
        return [SELECT Name, Shipping_Method_Name__c, Active__c, Account__c,Default__c, DisplayOrder__c, ApprovalRequired__c FROM Shipping_Method__c WHERE Account__C =:objAccount.ID AND Active__c = true ORDER BY  Default__c DESC,Shipping_Method_Name__c];
    }  
    
    @AuraEnabled
    public static ShoppingCartDetails_EmergeOrderId saveShippingAddresses_Apex(String emergeOrderId,String posItemId,String selectedProgramId,String selectedShippingAddresses)
    {
        System.debug([SELECT Id,Quantity__c FROM OrderDestinationItem__c WHERE OrderDestination__r.Order__c=:emergeOrderId]);
        objAccount=getAccount();
        Order__c DFVEmergeOrder=new Order__c ();
        List<OrderDestination__c> DFVCometOrders=new List<OrderDestination__c> ();
        List<OrderDestinationItem__c> DFVCometOrderItems=new List<OrderDestinationItem__c> ();
        List<Shipping_Method__c> defaultShippingMethod=new List<Shipping_Method__c> ([SELECT Id FROM Shipping_Method__c WHERE Account__c=:objAccount.Id AND Default__c=true]);
        List<ShoppingCart__c> currentActiveShoppingCartForThisUser=[SELECT Id FROM ShoppingCart__c WHERE Active__c=true AND Account__c=:objAccount.Id AND CreatedById=:UserInfo.getUserId() AND CartStatus__c='Open' AND Program__c=:selectedProgramId ORDER BY CreatedDate];
        List<AddressBook_QtyWrapper> shippingAddresses=(List<AddressBook_QtyWrapper>)System.JSON.deserialize(selectedShippingAddresses, List<AddressBook_QtyWrapper>.class);
        if(String.isBlank(emergeOrderId))
        {
            DFVEmergeOrder.Account__c=objAccount.Id;
            DFVEmergeOrder.Order_Status__c='Open';
            DFVEmergeOrder.OwnerId=UserInfo.getUserId();
            DFVEmergeOrder.Order_Date__c=System.today();
            DFVEmergeOrder.Program__c=selectedProgramId;
            insert DFVEmergeOrder;
            emergeOrderId=DFVEmergeOrder.Id;
            currentActiveShoppingCartForThisUser[0].Order__c=DFVEmergeOrder.Id;
            update currentActiveShoppingCartForThisUser[0];
        }
        
        Map<Id,AddressBook__c> existingAddresses=new Map<Id,AddressBook__c> ([SELECT Id FROM AddressBook__c WHERE Id IN (SELECT AddressBook__c FROM OrderDestination__c WHERE Order__c=:emergeOrderId)]);
        Map<Id,AddressBook_QtyWrapper> addressBookIdWithQty=new Map<Id,AddressBook_QtyWrapper> ();
        Map<Id,OrderDestination__c> addressBookIdWithCometOrder=new Map<Id,OrderDestination__c> ();
        Map<Id,Set<Id>> posItemIdWithAddressBookIds=new Map<Id,Set<Id>> ();
        Map<Id,POS_Item__c> posItems=new Map<Id,POS_Item__c> ([SELECT Id,Price__c FROM POS_Item__c WHERE Id IN (SELECT POS_Item__c FROM ShoppingCartItems__c WHERE ShoppingCart__c=:currentActiveShoppingCartForThisUser[0].Id)]);
        for(AddressBook_QtyWrapper addressBook_Qty : shippingAddresses)
        {
            addressBookIdWithQty.put(addressBook_Qty.addressBook.Id,addressBook_Qty);
            if(!existingAddresses.containsKey(addressBook_Qty.addressBook.Id))
            {
                OrderDestination__c cometOrder=new OrderDestination__c();
                cometOrder.Order__c = emergeOrderId;
                cometOrder.AddressBook__c = addressBook_Qty.addressBook.Id;
                cometOrder.Shipping_Method__c = String.isBlank(addressBook_Qty.shippingMethodId)?defaultShippingMethod.isEmpty()?null:defaultShippingMethod[0].Id:addressBook_Qty.shippingMethodId;
                cometOrder.SelectedShippingMethod__c = String.isBlank(addressBook_Qty.shippingMethodId)?defaultShippingMethod.isEmpty()?null:defaultShippingMethod[0].Id:addressBook_Qty.shippingMethodId;
                DFVCometOrders.add(cometOrder);
            }
        }
        if(!DFVCometOrders.isEmpty())
            insert DFVCometOrders;
        for(OrderDestination__c cometOrder : [SELECT Id,AddressBook__c,(SELECT Id,Pos_Item__c FROM OrderDestinationItems__r) FROM OrderDestination__c WHERE Order__c=:emergeOrderId])
        {
            addressBookIdWithCometOrder.put(cometOrder.AddressBook__c,cometOrder);
            for(OrderDestinationItem__c cometOrderItem : cometOrder.OrderDestinationItems__r)
            {
                Set<Id> addressBookIds=posItemIdWithAddressBookIds.get(cometOrderItem.Pos_Item__c);
                if(addressBookIds==null)
                    addressBookIds=new Set<Id> ();
                addressBookIds.add(cometOrder.AddressBook__c);
                posItemIdWithAddressBookIds.put(cometOrderItem.Pos_Item__c,addressBookIds);
            }           
        }
        
        
        if(String.isNotBlank(posItemId))
        {
            for(AddressBook_QtyWrapper address_Qty : shippingAddresses)
            {
                Boolean isItemAddedToOrder= posItemIdWithAddressBookIds.containsKey(posItemId)?!posItemIdWithAddressBookIds.get(posItemId).contains(address_Qty.addressBook.Id):false;
                if( !posItemIdWithAddressBookIds.containsKey(posItemId) || isItemAddedToOrder)
                {
                    OrderDestinationItem__c cometOrderItem=new OrderDestinationItem__c ();
                    cometOrderItem.Id=null;
                    cometOrderItem.Quantity__c=0;
                    cometOrderItem.SelectedQuantity__c=0;
                    cometOrderItem.OrderDestination__c = addressBookIdWithCometOrder.get(address_Qty.addressBook.Id).Id;
                    cometOrderItem.POS_Item__c = posItemId;
                    cometOrderItem.Item_Price__c = posItems.get(posItemId).Price__c;
                    DFVCometOrderItems.add(cometOrderItem);
                }
            }
            if(!DFVCometOrderItems.isEmpty())
                insert DFVCometOrderItems;
            delete [SELECT Id FROM OrderDestinationItem__c WHERE OrderDestination__r.AddressBook__c NOT IN :addressBookIdWithQty.keySet() AND OrderDestination__r.Order__c=:emergeOrderId AND POS_Item__c=:posItemId ]; 
            // calculateBudget(selectedProgramId,emergeOrderId); 
            delete [SELECT Id,Order_Amount__c FROM OrderDestination__c WHERE Order__c=:emergeOrderId AND Id NOT IN (SELECT OrderDestination__c FROM OrderDestinationItem__c WHERE OrderDestination__r.Order__c=:emergeOrderId) ];
        }
        else
        {
            for(AddressBook_QtyWrapper address_Qty : shippingAddresses)
            {
                for(Id id : posItems.keySet())
                {
                    Boolean isItemAddedToOrder= posItemIdWithAddressBookIds.containsKey(id)?!posItemIdWithAddressBookIds.get(id).contains(address_Qty.addressBook.Id):false;
                    if( !posItemIdWithAddressBookIds.containsKey(id) || isItemAddedToOrder)
                    {
                        OrderDestinationItem__c cometOrderItem=new OrderDestinationItem__c ();
                        cometOrderItem.Id=null;
                        cometOrderItem.Quantity__c=0;
                        cometOrderItem.SelectedQuantity__c=0;
                        cometOrderItem.OrderDestination__c = addressBookIdWithCometOrder.get(address_Qty.addressBook.Id).Id;
                        cometOrderItem.POS_Item__c = id;
                        cometOrderItem.Item_Price__c = posItems.get(id).Price__c;
                        DFVCometOrderItems.add(cometOrderItem);
                    }
                }
            }
            if(!DFVCometOrderItems.isEmpty())
                insert DFVCometOrderItems;
            Map<Id,OrderDestination__c> cometOrders_Map=new Map<Id,OrderDestination__c> ([SELECT Id,AddressBook__c,(SELECT Id FROM OrderDestinationItems__r) FROM OrderDestination__c WHERE Order__c=:emergeOrderId]);
            Set<Id> addressBookIds=new Set<Id> ();
            Set<Id> addressBookIds_ToBeRemoved=new Set<Id> ();
            for(Id cometOrderId : cometOrders_Map.keySet())
                if(cometOrders_Map.get(cometOrderId).OrderDestinationItems__r.size() == posItems.keySet().size() )
                addressBookIds.add(cometOrders_Map.get(cometOrderId).AddressBook__c);
            
            for(Id id : addressBookIds)
                if(!addressBookIdWithQty.containsKey(id))
                addressBookIds_ToBeRemoved.add(id);
            
            delete [SELECT Id FROM OrderDestinationItem__c WHERE OrderDestination__r.Order__c=:emergeOrderId AND OrderDestination__r.AddressBook__c IN :addressBookIds_ToBeRemoved]; 
            // calculateBudget(selectedProgramId,emergeOrderId);
            delete [SELECT Id FROM OrderDestination__c WHERE Order__c=:emergeOrderId AND Id NOT IN (SELECT OrderDestination__c FROM OrderDestinationItem__c WHERE OrderDestination__r.Order__c=:emergeOrderId) ]; 
        }
        return getCartItems_Apex(selectedProgramId);
    }
    
    /**** DFVShippingAllAddressComponent STOP****/
    
    /***** DFVShippingCartComponent -- STOP -- *****/
    /***** DFVPreviewOrderComponent START *****/
    @AuraEnabled
    public static List<OrderDestinationItem__c> getCometOrderItems_Apex(String emergeOrderId)
    {
        return [SELECT Name,Item_Price__c, Id,POS_Item__c,Quantity__c,OrderDestination__r.Order__r.Program__r.Name__c,POS_Item__r.Attachment_Id__c,POS_Item__r.Active__c, OrderDestination__r.AddressBook__r.Shipto_Name__c, OrderDestination__r.OrderName__c, OrderDestination__r.AddressBook__r.Shipto_Company__c, OrderDestination__r.AddressBook__r.Address__c, OrderDestination__r.AddressBook__r.City__c, POS_Item__r.Item_No__c, POS_Item__r.Pack_Of__c, POS_Item__r.Item_Name__c, SelectedQuantity__c,OrderDestination__r.SelectedShippingMethod__r.Shipping_Method_Name__c FROM OrderDestinationItem__c WHERE SelectedQuantity__c>0 AND OrderDestination__r.Order__r.Id =:emergeOrderId];
    }
    @AuraEnabled
    public static String confirmOrder_Apex(String emergeOrderId,String selectedProgramId)
    {
        try{
            objAccount=getAccount();
            Decimal totalOrderedAmount=0;
            Decimal totalNewOrderedAmount=0;
            List<OrderDestination__c> cometOrders=new List<OrderDestination__c> ();
            List<OrderDestinationItem__c> cometOrderItems=new List<OrderDestinationItem__c> ();
            List<ShoppingCart__c> currentActiveShoppingCartForThisUser=[SELECT Id,DFV_Order_Number__c FROM ShoppingCart__c WHERE Active__c=true AND Account__c=:objAccount.Id AND CreatedById=:UserInfo.getUserId() AND CartStatus__c='Open' AND Program__c=:selectedProgramId ORDER BY CreatedDate];
            Chair_Budget__c chairbudget=[SELECT Id,Allocated_Budget__c,Available_Budget__c,Consumed_Budget__c,
                                         Shared_Budget__c,Chair__r.Chair_Name__c,Chair__r.Level__c,Chair__r.Active__c,
                                         Chair__r.User__c,Program__r.Name__c,Program__r.Attachment_Id__c,
                                         Program__r.Start_Date__c,Program__r.Closing_Date__c,Program__r.In_Market_Date__c,Available_Chair_Budget__c,Chair_DFV_Department_Budget__c,Utilized_DFV_Department_Budget__c,Available_DFV_Department_Budget__c FROM Chair_Budget__c WHERE Chair__r.User__c=:UserInfo.getUserId() AND Program__c=:selectedProgramId];
            
            
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
            update emergeOrder;
            
            delete [SELECT Id FROM OrderDestination__c WHERE Order__c=:emergeOrder.Id AND Id NOT IN (SELECT OrderDestination__c FROM OrderDestinationItem__c WHERE Quantity__c>0 AND OrderDestination__r.Order__c=:emergeOrder.Id)];
            /* List<ShoppingCart__c> currentActiveShoppingCartForThisUser=[SELECT Id,DFV_Order_Number__c FROM ShoppingCart__c WHERE Active__c=true AND Account__c=:objAccount.Id AND CreatedById=:UserInfo.getUserId() AND CartStatus__c='Open' AND Program__c=:selectedProgramId ORDER BY CreatedDate];
Order__c emergeOrder = [SELECT Id, Name,(SELECT Id,OrdStatus__c,Comet_Order_Status__c FROM OrderDestinations__r WHERE OrdStatus__c='Open' AND Comet_Order_Status__c='Open'), Order_Status__c, Order_Confirmation_Date__c from Order__c WHERE ID=:emergeOrderId LIMIT 1];
//emergeOrder.Order_Status__c='This Order has been processed' ; 
//update emergeOrder;
for(OrderDestination__c cometOrder : [SELECT Id,OrdStatus__c,Order_Amount__c,Comet_Order_Status__c,(SELECT Quantity__c,Item_Price__c,Total_Line_Amount__c,SelectedQuantity__c FROM OrderDestinationItems__r WHERE SelectedQuantity__c>0) FROM OrderDestination__c WHERE Order__c=:emergeOrder.Id AND OrdStatus__c='Open' AND Comet_Order_Status__c='Open'
AND Id IN (SELECT OrderDestination__c FROM OrderDestinationItem__c WHERE SelectedQuantity__c>0)])
{
// cometOrder.Comet_Order_Status__c='Send To Comet';
// cometOrders.add(cometOrder);

totalOrderedPrice=totalOrderedPrice+cometOrder.Order_Amount__c;
}
if(chairbudget.Consumed_Budget__c==null)
chairbudget.Consumed_Budget__c=0;
chairbudget.Consumed_Budget__c+=totalOrderedPrice;

//update cometOrders;
update chairbudget;
if(!currentActiveShoppingCartForThisUser.isEmpty())
{
//currentActiveShoppingCartForThisUser[0].CartStatus__c='Closed';
//update currentActiveShoppingCartForThisUser[0];
}*/
            return 'Done';
        }
        catch(exception ex)
        {
            DFVEmailNotifications.sendNotification('Confirming an Order',ex.getMessage()+'\n'+'Inputs are -- emergeOrderId-- '+JSON.serialize(emergeOrderId)
                                                   +'\n'+'Class Name - DFVInventoryOrderController '+'-- Line number --'+ex.getLineNumber());
            return 'Not_Done';
        }
    }
    /***** DFVPreviewOrderComponent STOP *****/
    /***** DFVOrderStatusComponent START *****/
    @AuraEnabled
    public static List<Program__c> getAllPrograms_Apex()
    {
        objAccount=getAccount();
        /** Developer:Thanvi
Shawna asked for a scenario where admin sees everyones order and salesmanager sees only the order assigned to them
**/
        String profileName=[Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
        if(profileName == 'DFV Sales Manager') {
            return [SELECT Id,Name__c FROM Program__c WHERE Account__c=:objAccount.Id AND Id IN (SELECT Program__c FROM Chair_Budget__c WHERE Chair__r.User__c=:UserInfo.getUserId())];
        }
        else{
            return [SELECT Id,Name__c FROM Program__c WHERE Account__c=:objAccount.Id];
        }
        
    }
    @AuraEnabled
    public static List<Program_ChairBudget_CometOrder> loadOrdersForSelectedProgram_Apex(String searchKeyword,Boolean isEmergeAdmin,String selectedProgramId)
    {
        objAccount=getAccount();
        List<Program_ChairBudget_CometOrder> programOrderDetails=new List<Program_ChairBudget_CometOrder> ();
        Decimal programConsumedValue=0;
        Map<Id,Chair_Budget__c> programIdWithChairBudget=new Map<Id,Chair_Budget__c> ();
        for(Chair_Budget__c chairBudget : [SELECT Id,Allocated_Budget__c,Available_Budget__c,Consumed_Budget__c,
                                           Shared_Budget__c,Chair__r.Chair_Name__c,Chair__r.Level__c,Chair__r.Active__c,
                                           Chair__r.User__c,Program__r.Name__c,Program__r.Attachment_Id__c,
                                           Program__r.Start_Date__c,Program__r.Closing_Date__c,Program__r.In_Market_Date__c,Available_Chair_Budget__c,Chair_DFV_Department_Budget__c,Utilized_DFV_Department_Budget__c,Available_DFV_Department_Budget__c,
                                           Program__r.Program_Status__c FROM Chair_Budget__c WHERE Program__r.Account__c=:objAccount.Id AND Chair__r.User__c=:UserInfo.getUserId()
                                           Order by Program__r.Name__c])
        {
            programIdWithChairBudget.put(chairBudget.Program__c,chairBudget);
        }
        String query='';
        String whereClause='';
        Map<Id,OrderDestination__c> cometOrders_Map=new Map<Id,OrderDestination__c> ();
        query+='SELECT Order__r.Name,AddressBook__r.State__r.State_Name__c,AddressBook__r.Zip__c,Order_Amount__c, Order__r.Id,Order__r.Order_Date__c, Order__r.CreatedById,Order__r.Order_Status__c, OrderDestination__c.Name,';
        query+='AddressBook__r.Destination_Name__c, AddressBook__r.Shipto_Name__c, AddressBook__r.Shipto_Company__c, AddressBook__r.City__c, AddressBook__r.Address__c,ShippingMethodRejeted__c,ShipMethodApproved__c,SelectedShippingMethod__r.Shipping_Method_Name__c,Shipping_Method__r.Shipping_Method_Name__c,';
        query+='OrderName__c,SelectedShippingMethod__r.ApprovalRequired__c,(SELECT Name,Total_Line_Amount__c, Id,POS_Item__c,Quantity__c,POS_Item__r.Attachment_Id__c,POS_Item__r.Active__c, OrderDestination__r.AddressBook__r.Shipto_Name__c, OrderDestination__r.OrderName__c, OrderDestination__r.AddressBook__r.Shipto_Company__c, OrderDestination__r.AddressBook__r.Address__c, OrderDestination__r.AddressBook__r.City__c, POS_Item__r.Item_No__c, POS_Item__r.Pack_Of__c, POS_Item__r.Item_Name__c, SelectedQuantity__c ,';
        query+='POS_Item__r.Brand__r.Brand_Name__c,POS_Item__r.Type_of_Item__r.Item_Type__c,POS_Item__r.Approval_Required__c,POS_Item__r.Price__c,POS_Item__r.Maximum_Order_Qty__c,POS_Item__r.Maximum_order_quantity_applicable__c,MaxOrderAppReq__c,ItemApproved__c,ItemRejected__c,MaxOrderApproved__c,MaxOrderRejected__c FROM OrderDestinationItems__r WHERE SelectedQuantity__c>0 )';
        query+=',WarehouseOrderStatus__c, WarehouseProcessingStatus__c, WarehouseSequence__c, WarehouseShippingComments__c, WarehouseShippingDate__c, WarehouseShippingStatus__c, WarehouseTransactionNo__c';
        query+=',OrdStatus__c, Carrier__c, TrackingNos__c, Order__r.Program__c ';
        query+='FROM OrderDestination__c';
        whereClause+=' WHERE Order__r.Account__c=\''+objAccount.Id+'\' AND Order__r.Program__c!=null';
        whereClause+=isEmergeAdmin?' ':' AND Order__r.OwnerId =\''+UserInfo.getUserId()+'\'';
        whereClause+=' AND Order__r.Program__c =\''+selectedProgramId+'\'';
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
            List<OrderedItemDetails> orderedItems=new List<OrderedItemDetails> ();
            for(OrderDestinationItem__c cometOrderItem : cometOrder.OrderDestinationItems__r  )
                orderedItems.add(new OrderedItemDetails(cometOrderItem,true));
            programOrderDetails.add(new Program_ChairBudget_CometOrder(new Program_ChairBudget_Details(cometOrder.Order__c,programIdWithChairBudget.get(cometOrder.Order__r.Program__c)),cometOrder,orderedItems,cometOrder.Order_Amount__c  ));
        }
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
        /** @AuraEnabled
public Decimal programConsumedValue;**/
        @AuraEnabled
        public List<OrderedItemDetails> orderedItems;
        /* public Program_ChairBudget_CometOrder (Program_ChairBudget_Details programChairBudgetDetails,OrderDestination__c cometOrder,Decimal totalOrderValue,
Decimal programConsumedValue,List<OrderedItemDetails> orderedItems) */
        public Program_ChairBudget_CometOrder (Program_ChairBudget_Details programChairBudgetDetails,OrderDestination__c cometOrder,List<OrderedItemDetails> orderedItems,Decimal totalOrderValue)                                      
        {
            this.programChairBudgetDetails=programChairBudgetDetails;
            this.cometOrder=cometOrder;
            this.totalOrderValue=totalOrderValue;
            // this.programConsumedValue=programConsumedValue;*/
            this.orderedItems=orderedItems;
        }
    }
    
    /***** DFVOrderStatusComponent STOP *****/
    /**** DFVReviewOrdersComponent START ****/
    public class OrderedItemDetails
    {
        @AuraEnabled
        public OrderDestinationItem__c cometOrderItem;
        @AuraEnabled
        public Boolean isQtyEditable; 
        public OrderedItemDetails(OrderDestinationItem__c cometOrderItem,Boolean isQtyEditable)
        {
            this.cometOrderItem=cometOrderItem;
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
        public Decimal programConsumedValue;
        public CometOrder_ChairBudget(OrderDestination__c cometOrder,List<OrderedItemDetails> orderedItems, Chair_Budget__c chairBudget,Decimal totalOrderValue,Decimal programConsumedValue)
        {
            this.cometOrder=cometOrder;
            this.chairBudget=chairBudget;
            this.orderedItems=orderedItems;
            this.totalOrderValue=totalOrderValue;
            this.programConsumedValue=programConsumedValue;
        }
        
    }
    @AuraEnabled
    public static List<User> getUsers_Apex (String searchWord)
    {
        objAccount=getAccount();
        if(String.isBlank(searchWord))
            searchWord='';
        searchWord='%'+searchWord+'%';    
        return [SELECT Id,Name FROM User WHERE Name LIKE :searchWord AND AccountId=:objAccount.Id ];
    }
    @AuraEnabled
    public static List<CometOrder_ChairBudget> loadOrdersForSelectedProgramAndUser_Apex(String searchUserWord,String selectedProgramId)
    {
        objAccount=getAccount();
        List<CometOrder_ChairBudget> programOrderDetails=new List<CometOrder_ChairBudget> ();
        Map<Id,Chair_Budget__c> chairIdWithChairBudget=new Map<Id,Chair_Budget__c> ();
        System.debug('testing----> '+selectedProgramId);
        if(String.isNotBlank(selectedProgramId))
        {
            if(String.isBlank(searchUserWord))
                searchUserWord='';
            if(String.isNotBlank(searchUserWord))   
            {
                searchUserWord='%'+searchUserWord+'%';
                for(Chair_Budget__c chairBudget : [SELECT Id,Allocated_Budget__c,Available_Budget__c,Consumed_Budget__c,
                                                   Shared_Budget__c,Chair__r.Chair_Name__c,Chair__r.Level__c,Chair__r.Active__c,
                                                   Chair__r.User__c,Program__r.Name__c,Program__r.Attachment_Id__c,
                                                   Program__r.Start_Date__c,Program__r.Closing_Date__c,Program__r.In_Market_Date__c,Available_Chair_Budget__c,Chair_DFV_Department_Budget__c,Utilized_DFV_Department_Budget__c,Available_DFV_Department_Budget__c,
                                                   Program__r.Program_Status__c FROM Chair_Budget__c WHERE Program__r.Account__c=:objAccount.Id AND Chair__r.User__r.Name LIKE :searchUserWord   AND Program__c=:selectedProgramId
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
                                                      FROM OrderDestination__c WHERE Order__r.Account__c=:objAccount.Id AND Order__r.Program__c!=null AND Order__r.Owner.Name LIKE :searchUserWord  AND Order__r.Program__c =:selectedProgramId])
                {
                    Decimal totalOrderValue=0;
                    List<OrderedItemDetails> orderedItems=new List<OrderedItemDetails>();
                    for(OrderDestinationItem__c cometOrderItem : cometOrder.OrderDestinationItems__r )
                    {
                        totalOrderValue+=cometOrderItem.Total_Line_Amount__c;
                        orderedItems.add(new OrderedItemDetails(cometOrderItem,true));
                    }
                    List<AggregateResult> aggregateResults=[SELECT SUM(Consumed_Budget__c) total FROM Chair_Budget__c WHERE Program__c=:selectedProgramId];
                    programOrderDetails.add(new CometOrder_ChairBudget(cometOrder,
                                                                       orderedItems, chairIdWithChairBudget.get(cometOrder.Order__r.OwnerId),totalOrderValue,aggregateResults.isEmpty()?0:(Decimal)aggregateResults[0].get('total')));
                }
            }
            else
            { 
                for(Chair_Budget__c chairBudget : [SELECT Id,Allocated_Budget__c,Available_Budget__c,Consumed_Budget__c,
                                                   Shared_Budget__c,Chair__r.Chair_Name__c,Chair__r.Level__c,Chair__r.Active__c,
                                                   Chair__r.User__c,Program__r.Name__c,Program__r.Attachment_Id__c,
                                                   Program__r.Start_Date__c,Program__r.Closing_Date__c,Program__r.In_Market_Date__c,Available_Chair_Budget__c,Chair_DFV_Department_Budget__c,Utilized_DFV_Department_Budget__c,Available_DFV_Department_Budget__c,
                                                   Program__r.Program_Status__c FROM Chair_Budget__c WHERE Program__r.Account__c=:objAccount.Id AND Program__c=:selectedProgramId
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
                                                      FROM OrderDestination__c WHERE Order__r.Account__c=:objAccount.Id AND Order__r.Program__c!=null AND Order__r.Program__c =:selectedProgramId])
                {
                    Decimal totalOrderValue=0;
                    List<OrderedItemDetails> orderedItems=new List<OrderedItemDetails>();
                    for(OrderDestinationItem__c cometOrderItem : cometOrder.OrderDestinationItems__r )
                    {
                        totalOrderValue+=cometOrderItem.Total_Line_Amount__c;
                        orderedItems.add(new OrderedItemDetails(cometOrderItem,true));
                    }
                    List<AggregateResult> aggregateResults=[SELECT SUM(Consumed_Budget__c) total FROM Chair_Budget__c WHERE Program__c=:selectedProgramId];
                    programOrderDetails.add(new CometOrder_ChairBudget(cometOrder,
                                                                       orderedItems, chairIdWithChairBudget.get(cometOrder.Order__r.OwnerId),totalOrderValue,aggregateResults.isEmpty()?0:(Decimal)aggregateResults[0].get('total')));
                }
            }
            
            
        }
        System.debug('programOrderDetails---->'+programOrderDetails);
        return programOrderDetails;
    }
    
    //Author: SN,TP,VB Date: 24/07/2020
    //Commented because of the occurance of too many soql query error which is mentioned in the CR:DFV-23-JUL-23.
    //@AuraEnabled
    /**public static List<CometOrder_ChairBudget> saveEditedOrder_Apex(String seasonalOrderItems,String searchUserWord,String selectedProgramId,Decimal orderAmount,String cometOrderId,Chair_Budget__c chairBudget)
    {
        system.debug('Entered SaveEditOrder');
        if(chairBudget.Consumed_Budget__c==null)
            chairBudget.Consumed_Budget__c=0;
        chairBudget.Consumed_Budget__c=chairBudget.Consumed_Budget__c-orderAmount;
        update chairBudget;
        system.debug('Updated Chair Budget');
        List<OrderedItemDetails> orderedItems=(List<OrderedItemDetails>)System.JSON.deserialize(seasonalOrderItems, List<OrderedItemDetails>.class);
        List<OrderDestinationItem__c> cometOrderItems = new List<OrderDestinationItem__c>();
        system.debug('Ordered Items count' +orderedItems.size());
        for(OrderedItemDetails orderedItem : orderedItems ){
            if(!orderedItem.isQtyEditable){
                cometOrderItems.add(orderedItem.cometOrderItem);
            }
        }
        
        system.debug('cometOrderItems' +cometOrderItems.size());
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
        return loadOrdersForSelectedProgramAndUser_Apex(searchUserWord,selectedProgramId);
    }**/
    
    //Author: SN,TP,VB Date: 24/07/2020
    //Aim of the updated code: To meet the CR-DFV-23-JUL-23 requirement.  
    @AuraEnabled
    public static String saveEditedOrder_Apex(String seasonalOrderItems,String searchUserWord,String selectedProgramId,Decimal orderAmount,String cometOrderId,Chair_Budget__c chairBudget)
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
    
    
    /**** DFVReviewOrdersComponent STOP ****/
    /**** calculate budget ***/
    public static void calculateBudget (String programId,String emergeOrderId)
    {
        Chair_Budget__c chairbudget=[SELECT Id,Allocated_Budget__c,Available_Budget__c,Consumed_Budget__c,
                                     Shared_Budget__c,Chair__r.Chair_Name__c,Chair__r.Level__c,Chair__r.Active__c,
                                     Chair__r.User__c,Program__r.Name__c,Program__r.Attachment_Id__c,
                                     Program__r.Start_Date__c,Program__r.Closing_Date__c,Program__r.In_Market_Date__c,Available_Chair_Budget__c,Chair_DFV_Department_Budget__c,Utilized_DFV_Department_Budget__c,Available_DFV_Department_Budget__c FROM Chair_Budget__c WHERE Chair__r.User__c=:UserInfo.getUserId() AND Program__c=:programId];
        List<OrderDestination__c> cometOrders=new List<OrderDestination__c> ();
        Decimal totalOrderValue=0;
        Decimal totalNewOrderValue=0;
        for(OrderDestination__c cometOrder : [SELECT Id,Order_Amount__c,(SELECT Id,Total_Line_Amount__c FROM OrderDestinationItems__r WHERE Quantity__c>0) FROM OrderDestination__c  WHERE Order__c=:emergeOrderId])
        {
            totalOrderValue+=cometOrder.Order_Amount__c==null?0:cometOrder.Order_Amount__c;
            Decimal orderAmount=0;
            for(OrderDestinationItem__c cometOrderItem : cometOrder.OrderDestinationItems__r )
            {
                orderAmount+=cometOrderItem.Total_Line_Amount__c;
            }
            cometOrder.Order_Amount__c=orderAmount;
            totalNewOrderValue+=orderAmount;
            cometOrders.add(cometOrder);
        }  
        update cometOrders;
        chairbudget.Consumed_Budget__c-=totalOrderValue;
        chairbudget.Consumed_Budget__c+=totalNewOrderValue;
        update chairbudget;                              
    }
}