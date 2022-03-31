/**Authors : Sanjana
* Date : 08/11/2021
* Aim : To fetch inventory pos items, to add pos item to the cart, to remove pos item from the cart and to check and create shopping cart for the user */



public class InfiniumInventoryPosItemToCart_Apex 
{
    //variable hold the account Id, name and lightning community URL of the account.
    public static Account objAccount;
    
    //method to fetch the account details. the return expected is of the type sObject Account
    @AuraEnabled(cacheable=true)   
    public static Account getAccount() { 
        //for testing purpose
        if(Test.isRunningTest())
        {
            //fetch Id, name from the account sObject
            objAccount=[SELECT Id, Name FROM Account
                        WHERE Name LIKE '%Infinium Spirits%' LIMIT 1];
        }
        else
        {
            //hold the account Id, name and lightning community URL of the account. the result is given to the variable objAccount.
            objAccount=[SELECT Id, Name,Lightning_Community_URL__c FROM Account
                        WHERE Lightning_Community_Id__c=:Network.getNetworkId() LIMIT 1];
        }
        return objAccount;
    }
    
    //method to fetch details of the sObject Brand
    @AuraEnabled(cacheable=true)
    public static List<Brand__c> getBrandList()
    {
        //variable to hold the account details
        objAccount=getAccount();
        //to fetch the list of Id and brand name from the sObject Brand that belongs to the account Infinium Spirits and the list is ordered according to the brand name. the result is stored in the 
        //variable brandList
        List<Brand__c> brandList = [SELECT Id,Brand_Name__c FROM Brand__c WHERE Account__c=:objAccount.Id ORDER BY Brand_Name__c ];
        system.debug('brandList'+brandList);
        //return the variable brandList
        Return brandList;
    }
    
    //method to fetch details of the sObject item type
    @AuraEnabled(cacheable=true)
    public static List<Item_Type__c> getItemTypeList()
    {
        //variable to hold the account details
        objAccount=getAccount();
        //to fetch the list of Id and item type name from the sObject Item type that belongs to the account Infinium Spirits and the list is ordered according to the item type names.
        //store the result in the variable itemTypeList
        List<Item_Type__c> itemTypeList = [SELECT Id, Item_Type__c FROM Item_Type__c WHERE Account__c=:objAccount.Id ORDER BY Item_Type__c];
        system.debug('itemTypeList'+itemTypeList);
        //return the variable itemTypeList
        Return itemTypeList;
    }
    
    
    @AuraEnabled
    /** This method is used to create a record in the shopping cart to a user if the user doesn't have a shopping cart already */
    public static String createInventoryShoppingCart()
    {
        try{
            //variable to hold the account details
            objAccount=getAccount();
            //fetch the Id from the sObject shopping cart that is active, belong to Infinium Spirits, created by the logged in user, order status is open.the result is stored 
            //in the variable currentActiveShoppingCartForThisUser of type List of sObject shopping cart
            List<ShoppingCart__c> currentActiveShoppingCartForThisUser=[SELECT Id FROM ShoppingCart__c WHERE Active__c=true AND Account__c=:objAccount.Id AND CreatedById=:UserInfo.getUserId() AND CartStatus__c='Open' AND Inventory_Seasonal_Program__c='Inventory' ORDER BY CreatedDate];
            //to check if the variable currentActiveShoppingCartForThisUser is empty
            if(currentActiveShoppingCartForThisUser.isEmpty())
            {
                //create an instance of sObject shopping cart and store it in the variable shoppingCart
                ShoppingCart__c shoppingCart=new ShoppingCart__c();
                //make the shopping cart active
                shoppingCart.Active__c=true;
                //make the cart status open
                shoppingCart.CartStatus__c='Open';
                //assign Infinium Spirits acount to the shopping cart
                shoppingCart.Account__c=objAccount.Id;
                //assign the cart to type "inventory"
                shoppingCart.Inventory_Seasonal_Program__c='Inventory';
                //insert shopping record in the sObject shopping cart
                system.debug('shoppingCart---->'+shoppingCart);
                insert shoppingCart;
                //return the string 'new Cart is created'
                return 'new Cart is created';
                
            }
            //if the variable currentActiveShoppingCartForThisUser is not empty
            else
            {
                //return the string 'Cart already exists'
                return 'Cart already exists';
            }
        }
        //email is sent if any exception is encountered
        catch(exception ex)
        {
            InfiniumEmailNotifications.sendNotification('Creating a cart',ex.getMessage()+'\n' +'\n'+'Class Name - InfiniumPosItemToCart_Apex '+'-- Line number --'+ex.getLineNumber());
            //return the string 'Not Done'
            return 'Not Done';
        }
        
    }
    public class PosItem_DetailsWrapper
    {
        @AuraEnabled
        public Boolean isItemAddedToCart ;  
        @AuraEnabled
        public POS_Item__c posItem;
        @AuraEnabled
        public String poItemImageURL;
        public PosItem_DetailsWrapper(Boolean isItemAddedToCart,POS_Item__c posItem,String poItemImageURL)
        {
            this.isItemAddedToCart=isItemAddedToCart;
            this.posItem=posItem;
            this.poItemImageURL = poItemImageURL;
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
    
    //method to fetch the list of pos items based on user filters like brand, item type, searchKeyword, sort by id and pos item index.
    @AuraEnabled(cacheable=true)    
    public static PosItem_DetailsListWrapper getInventoryPosItemList (String searchedPosItem,String chosenBrandId,
                                                                      String chosenItemTypeId,String sortById,Integer recordStartIndex)
    {
        
        System.debug('entered getinventory'+recordStartIndex);
        //variable to hold the account details
        objAccount=getAccount();
        //instance of set of Ids is created and store it in the variable posItemIdsInCart
        Set<Id> posItemIdsInCart=new Set<Id> ();
        //instance of the sObject pos item is created and store it in the variable posItems
        List<POS_Item__c> posItems=new List<POS_Item__c> ();
        //instance of wrapper class PosItem_DetailsWrapper is created and is stored in the variable posItemDetails
        List<PosItem_DetailsWrapper> posItemDetails=new List<PosItem_DetailsWrapper> ();
        
        String Inventory= 'Inventory';
        String Both= 'Both';
        //for the sObject shopping cart items held by the variable shoppingCartItem, fetch pos item from shopping cart items which is active, belongs to Infinium Spirits, created by the logged in user and with cart status open
        for(ShoppingCartItems__c shoppingCartItem : [SELECT POS_Item__c FROM ShoppingCartItems__c WHERE ShoppingCart__r.Active__c=true AND ShoppingCart__r.Account__c=:objAccount.Id AND ShoppingCart__r.CreatedById=:UserInfo.getUserId() AND 
                                                     ShoppingCart__r.Inventory_Seasonal_Program__c='Inventory' AND ShoppingCart__r.CartStatus__c='Open'])
            // system.debug('shoppingCartItem--->' +shoppingCartItem);
            posItemIdsInCart.add(shoppingCartItem.POS_Item__c);
        system.debug('posItemIdsInCart---->'+posItemIdsInCart);
        //Only the items whose logical inventory is greater than 0 is displayed 
        //variable of type string that contains soql query to fetch the details of the sObject pos item
        String getAllPosItems = 'SELECT Id,Attachment_Id__c,Item_Descrption__c,Active__c,Item_Name__c,Item_No__c,Pack_Of__c,Logical_Invenory_Stock__c,Brand__r.Brand_Name__c,Approval_Required__c,Maximum_Order_Qty__c,Maximum_order_quantity_applicable__c,Marketing_Only__c,Price__c,Type_of_Item__r.Item_Type__c,Inventory_Seasonal_Program__c';
        
        //to fetch id, name from profile and store it in a variable profileName of type string
        String profileName=[Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
        
        //to check if the profile is InfiniumSalesManager
        if(profileName == 'Infinium Sales Manager') {
            //fetching the details of all the pos items whose marketing only condition is false and logical inventory is greater than 0 and active from the sObject pos item by attaching a string to the variable getAllPosItems
            getAllPosItems=getAllPosItems+' FROM POS_Item__c WHERE Account__c=\''+objAccount.Id+'\' AND Marketing_Only__c=false AND Active__c=true AND Logical_Invenory_Stock__c>0 AND ( Inventory_Seasonal_Program__c=\''+Inventory+'\' OR  Inventory_Seasonal_Program__c=\''+Both+'\')';
        }
        //if the profile is not InfiniumSalesManager
        else {
            //fetching the details of all the pos items from the sObject pos item whose logical inventory is greater than 0 and actie by attaching a string to the variable getAllPosItems
            getAllPosItems=getAllPosItems+' FROM POS_Item__c WHERE Account__c=\''+objAccount.Id+'\' AND Active__c=true AND Logical_Invenory_Stock__c>0 AND ( Inventory_Seasonal_Program__c=\''+Inventory+'\' OR  Inventory_Seasonal_Program__c=\''+Both+'\')';
        }
        
        //declare an empty variable whereCondition of type string 
        String whereCondition=''; 
        //declare an empty variable sortByOption of type string 
        String sortByOption='';
        //not required
        //declare an empty variable offsetValue of type string 
        String offsetValue='';
        //check if the variable searchedPosItem is not blank
        if(String.isNotBlank(searchedPosItem))
        {
            //assign the incoming search keyword entered by the user to the variable searchedPosItem
            searchedPosItem='%'+searchedPosItem+'%';
            //find the item type name and item number using the variable searchedPosItem and assign it to the variable whereCondition
            whereCondition=whereCondition+' AND (Item_Name__c LIKE : searchedPosItem OR Item_No__c LIKE : searchedPosItem) ';
        }
        //check if the variable chosenBrandId is not empty
        if(String.isNotBlank(chosenBrandId))
            //fetch the brand using the variable chosenBrandId nd assign it to the variable whereCondition
            whereCondition=whereCondition+' AND Brand__c =:chosenBrandId ';
        //check if the variable chosenItemTypeId is not empty
        if(String.isNotBlank(chosenItemTypeId))
            //fetch the brand using the variable chosenItemTypeId nd assign it to the variable whereCondition
            whereCondition=whereCondition+' AND Type_of_Item__c =:chosenItemTypeId ';
        //check if the variable sortById is not empty
        if(String.isNotBlank(sortById))
        {
            //check if the variable sortById contains the string value LAST_N_DAYS
            if(sortById=='LAST_N_DAYS')
                //fetch the pos items whose created date matches the string LAST_N_DAYS
                whereCondition=whereCondition+' AND CreatedDate = LAST_N_DAYS:10 ORDER BY CreatedDate DESC ';
            
            else
            {
                if(sortById != 'RECENT_ADDED_CARTITEMS')
                    //sort pos items according to sortById
                    sortByOption=' ORDER BY '+sortById;
            }
        }
        //if the variable sortById is empty
        else
            //assign the string 'ORDER BY Item_Name__c ' to the variable sortByOption
            sortByOption=' ORDER BY Item_Name__c ';
        System.debug('sortByOption'+sortByOption);
        //create and instance of the sObject pos item called posItemsByFilters and assign the method Database.query to the variable
        List<POS_Item__c> posItemsByFilters=Database.query(getAllPosItems+whereCondition+sortByOption);
        System.debug('posItemsByFilters'+posItemsByFilters);
        System.debug('posItemsByFilters Size'+posItemsByFilters.size());
        //check if the variable sortById contains the string value RECENT_ADDED_CARTITEMS
        if(sortById == 'RECENT_ADDED_CARTITEMS')
        {
            //create an instance of sObject pos item and store it in a variable called items
            List<POS_Item__C> items=new List<POS_Item__C> ();  
            //create an instance of sObject pos item and store it in a variable called cartItems which holds the details of the pos item which exists in shopping cart items whose status is open
            List<POS_Item__C> cartItems=[SELECT Id,Item_Name__c,Attachment_Id__c,Active__c,Item_No__c,Pack_Of__c,Logical_Invenory_Stock__c,Brand__r.Brand_Name__c,Approval_Required__c,Item_Descrption__c,
                                         Maximum_Order_Qty__c,Maximum_order_quantity_applicable__c,Type_of_Item__r.Item_Type__c              
                                         FROM POS_Item__c WHERE (Inventory_Seasonal_Program__c='Inventory' OR Inventory_Seasonal_Program__c='Both') AND Account__c=:objAccount.Id AND Id IN :posItemsByFilters 
                                         AND Id IN (SELECT POS_Item__c FROM ShoppingCartItems__c WHERE ShoppingCart__r.Active__c=true AND ShoppingCart__r.Account__c=:objAccount.Id AND ShoppingCart__r.CreatedById=:UserInfo.getUserId() AND ShoppingCart__r.CartStatus__c='Open') 
                                         ORDER BY Item_Name__c];
            //create an instance of sObject pos item and store it in a variable called nonCartItems which holds the details of the pos item which does not exists in shopping cart items whose status is open
            List<POS_Item__C> nonCartItems=[SELECT Id,Item_Name__c,Attachment_Id__c,Active__c,Item_No__c,Pack_Of__c,Logical_Invenory_Stock__c,Brand__r.Brand_Name__c,Approval_Required__c,Item_Descrption__c,
                                            Maximum_Order_Qty__c,Maximum_order_quantity_applicable__c,Type_of_Item__r.Item_Type__c
                                            FROM POS_Item__c WHERE (Inventory_Seasonal_Program__c='Inventory' OR Inventory_Seasonal_Program__c='Both') AND  Account__c=:objAccount.Id AND Id IN :posItemsByFilters 
                                            AND Id NOT IN (SELECT POS_Item__c FROM ShoppingCartItems__c WHERE ShoppingCart__r.Active__c=true AND ShoppingCart__r.Account__c=:objAccount.Id AND ShoppingCart__r.CreatedById=:UserInfo.getUserId() AND ShoppingCart__r.CartStatus__c='Open' ) ORDER BY Item_Name__c];
            //add all data held by the variable cartItems to the variable items
            items.addAll(cartItems);
            //add all data held by the variable nonCartItems to the variable items
            items.addAll(nonCartItems);
            System.debug('items'+items);
            System.debug('items Size'+items.size());
            //for all the variable recordStartIndex from 0 to 11
            for(Integer i=recordStartIndex==null?0:recordStartIndex;i<=recordStartIndex+11;i++)
            {
                //check if the value of the variable recordStartIndex is lesser than the size of the variable items
                if(i<items.size())
                    //add the respective pos item in the variable items to the variable posItems
                    posItems.add(items[i]);
                
            } 
        }
        else
        {
            //for all the variable recordStartIndex from 0 to 11
            for(Integer i=recordStartIndex==null?0:recordStartIndex;i<=recordStartIndex+11;i++)
            {
                //check if the value of the variable recordStartIndex is lesser than the size of the variable posItemsByFilters
                if(i<posItemsByFilters.size())
                    //add the respective pos item in the varible posItemsByFilters to the variable posItems
                    posItems.add(posItemsByFilters[i]);
            }
            // System.debug('posItems'+posItems);
        }
        //for all the sObject pos item held by the variable posItem
        for(POS_Item__c posItem :posItems)
            //add the boolean condition if the item exists in the cart, list of pos items and pos item image URL to the wrapper class PosItem_DetailsWrapper 
            posItemDetails.add(new PosItem_DetailsWrapper(posItemIdsInCart.contains(posItem.Id),posItem,String.isBlank(posItem.Attachment_Id__c)?'':objAccount.Lightning_Community_URL__c+'/servlet/servlet.FileDownload?file='+posItem.Attachment_Id__c));
        // System.debug('posItemDetails'+posItemDetails.size());
        //add the size of the variable posItemsByFilters and the size of the variable posItemIdsInCart to the wrapper class PosItem_DetailsListWrapper and return the wrapper class
        system.debug('posItemDetails---->'+posItemDetails);
        system.debug('posItemsByFilters size---->'+posItemsByFilters.size());
        system.debug('posItemIdsInCart size---->'+posItemIdsInCart.size());
        return new PosItem_DetailsListWrapper(posItemDetails,posItemsByFilters.size(),posItemIdsInCart.size());
    }
    
    @AuraEnabled
    /**this method is responsible for adding the selected pos item for inventory ordering**/
    public static String addInventoryPosItemToCart(String selectedPosItemId)
    {
        try{
            //responsible to hold the account details
            objAccount=getAccount();
            //decalaring a variable currentActiveShoppingCartForThisUser of type sObject shopping cart to hold the details of the sObject shopping cart whose 
            //cart status is open
            List<ShoppingCart__c> currentActiveShoppingCartForThisUser=[SELECT Id FROM ShoppingCart__c 
                                                                        WHERE Active__c=true 
                                                                        AND Account__c=:objAccount.Id 
                                                                        AND CreatedById=:UserInfo.getUserId()
                                                                        AND CartStatus__c='Open' 
                                                                        AND Inventory_Seasonal_Program__c='Inventory' 
                                                                        ORDER BY CreatedDate];
            system.debug('currentActiveShoppingCartForThisUser--->'+currentActiveShoppingCartForThisUser);
            //if the shopping cart doesnt not exists
            if(currentActiveShoppingCartForThisUser.isEmpty())
            {
                //creating the instance of sObject shopping cart and storing it in the variable shoppingCart
                ShoppingCart__c shoppingCart=new ShoppingCart__c();
                //make the shopping cart active
                shoppingCart.Active__c=true;
                //make the shopping cart status open
                shoppingCart.CartStatus__c='Open';
                //shopping cart account should be Infinium Spirits
                shoppingCart.Account__c=objAccount.Id;
                //the condition inventory/seaonal program is assigned  inventory
                shoppingCart.Inventory_Seasonal_Program__c = 'Inventory';
                //inserting the variable shoppingCart and inserting a new record in the sObject shopping cart
                system.debug('shoppingCart---->'+shoppingCart);
                insert shoppingCart;
                //creating the instance of sObject shopping cart item and storing it in the variable shoppingCartItem
                ShoppingCartItems__c shoppingCartItem=new ShoppingCartItems__c();
                //make the shopping cart item active
                shoppingCartItem.Active__c=true;
                //pos item of the shopping cart item is the value of the vriable selectedPosItemId
                shoppingCartItem.POS_Item__c=selectedPosItemId;
                //assigning the Id of the newly created shopping cart Id to the shopping cart item
                shoppingCartItem.ShoppingCart__c=shoppingCart.Id;
                //inserting the variable shoppingCartItem and creating the a new record in the sObject shopping cart item 
                system.debug('shoppingCartItem--->'+shoppingCartItem);
                insert shoppingCartItem;
            }
            
            else
            {
                //if the shopping cart already exists
                if([SELECT Id FROM POS_Item__c WHERE Id=:selectedPosItemId AND Id IN (SELECT POS_Item__c FROM ShoppingCartItems__c WHERE ShoppingCart__c=:currentActiveShoppingCartForThisUser[0].Id)].isEmpty())
                {
                    //creating the instance of sObject shopping cart item and storing it in the variable shoppingCartItem
                    ShoppingCartItems__c shoppingCartItem=new ShoppingCartItems__c();
                    //make the shopping cart active
                    shoppingCartItem.Active__c=true;
                    //pos item of the shopping cart item is the value of the vriable selectedPosItemId
                    shoppingCartItem.POS_Item__c=selectedPosItemId;
                    //assigning the Id of the existing shopping cart Id to the shopping cart item
                    shoppingCartItem.ShoppingCart__c=currentActiveShoppingCartForThisUser[0].Id;
                    //inserting the variable shoppingCartItem and creating the a new record in the sObject shopping cart item
                    system.debug('shoppingCartItem--->'+shoppingCartItem);
                    insert shoppingCartItem;
                }
                
            }
            //returning the string 
            return 'done';
        }catch(Exception ex)
        {
            //if any exception is encountered, an email will be received 
            InfiniumEmailNotifications.sendNotification('Adding Item To Cart',ex.getMessage()+'\n'+'Inputs are -- selectedPosItemId-- '+JSON.serialize(selectedPosItemId)
                                                      +'\n'+'Class Name - InfiniumPosItemToCart_Apex '+'-- Line number --'+ex.getLineNumber());
            return 'Not done'; 
        }
        //return getInventoryPosItemList();
    }
    
    @AuraEnabled
    /**this method is responsible for removing the selected pos item for inventory ordering**/
    public static String removeInventoryPosItemFromCart (String selectedPosItemId)
    {
        try{
            //responsible to hold the account details
            objAccount=getAccount();
            //decalaring a variable currentActiveShoppingCartForThisUser of type sObject shopping cart to hold the details of the sObject shopping cart whose 
            //cart status is open
            
            List<ShoppingCart__c> currentActiveShoppingCartForThisUser=[SELECT Id,Infinium_Spirits_Order_Number__c 
                                                                        FROM ShoppingCart__c 
                                                                        WHERE Active__c=true 
                                                                        AND Account__c=:objAccount.Id 
                                                                        AND CreatedById=:UserInfo.getUserId() 
                                                                        AND CartStatus__c='Open' 
                                                                        AND Inventory_Seasonal_Program__c='Inventory' 
                                                                        ORDER BY CreatedDate];
            system.debug('currentActiveShoppingCartForThisUser--->'+currentActiveShoppingCartForThisUser);
            //deleted the selected pos item from the shopping cart item record
            delete [SELECT Id 
                    FROM ShoppingCartItems__c 
                    WHERE POS_Item__c=:selectedPosItemId 
                    AND ShoppingCart__c=:currentActiveShoppingCartForThisUser[0].Id];
            //declaring a variable cometOrderItems of type sObject order destination item which contains the order destination item Id that belongs to the Infinium Spirits and selected pos item id
            List<OrderDestinationItem__c> cometOrderItems=[SELECT Id FROM OrderDestinationItem__c WHERE OrderDestination__r.Order__c=:currentActiveShoppingCartForThisUser[0].Infinium_Spirits_Order_Number__c AND POS_Item__c=:selectedPosItemId];
            system.debug('cometOrderItems--->'+cometOrderItems);
            //delete the respective order destination item 
            delete cometOrderItems;
            //declaring a variable cometOrders of type sObject order destination item which contains the order destination item Id that belongs to the Infinium Spirits and that doesnot have any order destination items
            List<OrderDestination__c> cometOrders=[SELECT Id FROM OrderDestination__c WHERE Order__c=:currentActiveShoppingCartForThisUser[0].Infinium_Spirits_Order_Number__c AND Id NOT IN (SELECT OrderDestination__c  FROM OrderDestinationItem__c)]; 
            //deleting the order destinations
            system.debug('cometOrders--->'+cometOrders);
            delete cometOrders;
            //returing a string
            return 'done';
        }
        
        
        catch(Exception ex)
        {
            //if any exception is encountered, an email will be received 
            InfiniumEmailNotifications.sendNotification('Removing Items To Cart',ex.getMessage()+'\n'+'Inputs are -- selectedPosItemId-- '+JSON.serialize(selectedPosItemId)
                                                      +'\n'+'Class Name - InfiniumPosItemToCart_Apex '+'-- Line number --'+ex.getLineNumber());
            return 'not done';
        }
        
        
    }
    
    
}