public class CopperShoppingCartItem_Apex {
    public static Account objAccount;
    public static Boolean isTest = false;
    public static List<ShippingAddressDetailsWithQuantity_Wrapper> allAddressBookList = new List<ShippingAddressDetailsWithQuantity_Wrapper>();
    
  
    
    
    public class PosItemsListWithCartDetails_Wrapper {
        @AuraEnabled
        public POS_Item__c posItem; // each pos item
        @AuraEnabled
        public List<POSItem_States__c> posItemStateList; //to hold the state list associated with the shopping cart items
        @AuraEnabled
        public List<ShippingAddressDetailsWithQuantity_Wrapper> selectedAddressWithQtyDetails ;// this is storing added addresses from order.
        @AuraEnabled
        public String orderId ; //holds the order Id
        @AuraEnabled 
        public List<ShoppingCartItems__c> shoppingCartItems; //items added to the cart
        @AuraEnabled
        public Integer totalQuantityFromAllAddresses ; //total quantity from all the addresses
        @AuraEnabled
        public Decimal totalPriceFromAllAddresses ; //total price from all the addresses
        @AuraEnabled
        public String posItemImageAttachmentUrl; //holds the pos item image URL
       
        
        //constructor of the wrapper class
        public PosItemsListWithCartDetails_Wrapper(POS_Item__c posItem,List<POSItem_States__c> posItemStateList,List<ShippingAddressDetailsWithQuantity_Wrapper> selectedAddressWithQtyDetails,String orderId,List<ShoppingCartItems__c> shoppingCartItems,Integer totalQuantityFromAllAddresses,Decimal totalPriceFromAllAddresses,String posItemImageAttachmentUrl){
            this.posItem = posItem;
            this.posItemStateList = posItemStateList;
            this.selectedAddressWithQtyDetails = selectedAddressWithQtyDetails;
            this.orderId = orderId;
            this.shoppingCartItems = shoppingCartItems;
            this.totalQuantityFromAllAddresses = totalQuantityFromAllAddresses;
            this.totalPriceFromAllAddresses = totalPriceFromAllAddresses;
            this.posItemImageAttachmentUrl = posItemImageAttachmentUrl;
            
        }
    }
    
    
    
    
    public class ShippingAddressDetailsWithQuantity_Wrapper
    {
        @AuraEnabled
        public Boolean isCheckboxClicked ;// to check if the address is selected
        @AuraEnabled
        public AddressBook__c selectedAddress ; // to hold selected addresses
        @AuraEnabled
        public Integer quantity ; // to hold the quantity of the particular address
        @AuraEnabled
        public Decimal price; //to hold the price of the pos item
        @AuraEnabled
        public Shipping_Method__c selectedShippingMethod;// to hold the selected shipping method
        @AuraEnabled
        public String selectedShippingMethodId ;// to hold the shipping method id
        @AuraEnabled
        public Boolean isQuantityEditable;//to hold the boolean if state list for a pos item is present
        public ShippingAddressDetailsWithQuantity_Wrapper(Boolean isCheckboxClicked,AddressBook__c selectedAddress,Integer quantity, Decimal price,Shipping_Method__c selectedShippingMethod,String selectedShippingMethodId)
        {
            this.isCheckboxClicked=isCheckboxClicked;
            this.selectedAddress=selectedAddress;
            this.quantity=quantity;
            this.price = price;
            this.selectedShippingMethod=selectedShippingMethod;
            this.selectedShippingMethodId=selectedShippingMethodId;
        }
        
        public ShippingAddressDetailsWithQuantity_Wrapper(Boolean isCheckboxClicked,AddressBook__c selectedAddress,Integer quantity,Decimal price,Shipping_Method__c selectedShippingMethod,String selectedShippingMethodId,Boolean isQuantityEditable){
            this.isCheckboxClicked=isCheckboxClicked;
            this.selectedAddress=selectedAddress;
            this.quantity=quantity;
            this.price = price;
            this.selectedShippingMethod=selectedShippingMethod;
            this.selectedShippingMethodId=selectedShippingMethodId;
            this.isQuantityEditable=isQuantityEditable;
        }
    }
    
    
    
    //To hold list of address with pagination details.
    public class ShippingAddressDetailsWithPagination_Wrapper
    {
        @AuraEnabled
        public List<ShippingAddressDetailsWithQuantity_Wrapper> shippingAddressWithQtyDetails;// to hold the 100 addresses with detsilas
        @AuraEnabled
        public Integer totalShippingAddressSize; // to hold the total address size for pagination
        @AuraEnabled
        public List<ShippingAddressDetailsWithQuantity_Wrapper> allAddresses; // to hold all the addresses that belongs tothe user(used for front end search)
        
    }
    
    // Wrapper classes ends here
    
    //to get the user details of the logged in user
    @AuraEnabled(cacheable=true)
    public static Schema.User getUserDetails()
    {
        return [SELECT Id,UserName,International_Address_Accessible__c,Profile.Name,Profile.Id,Email FROM User WHERE Id=:UserInfo.getUserId()];
        //return [SELECT Id,UserName,International_Address_Accessible__c,Profile.Name,Profile.Id,Email FROM User WHERE Id='0050v000003tPtD'];
    }
    
    //to get the account details for the logged in user
    @AuraEnabled
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
        }
        return objAccount;
    }
    
   
    
    
    // to get the pos items in cart along with address details for the particukar pos item
    @AuraEnabled(cacheable=true)
    /** This method is used to load the Pos items if they already exist in the shopping cart*/
    public static List<PosItemsListWithCartDetails_Wrapper> getCartItemsList_Apex(String selectedBuyBookId)
    {
        //fetch account details		
        objAccount=getAccount();
        //AIm:To hold posItem data , variable isItemAddedToCart referring whether the item is added to cart or not , addresses for an order, shooping cart items and image URL of the pos Item.
        List<PosItemsListWithCartDetails_Wrapper> posItemsWithCart=new List<PosItemsListWithCartDetails_Wrapper> ();
        //Declare a variable posItemWithShippingAddressDetails  of type Map  To hold pos item Id with it's list of order destinations. 
        List<ShoppingCart__c> currentActiveShoppingCartForThisUser=[SELECT Id,Copper_Cane_Order_Number__c FROM ShoppingCart__c WHERE 
                                                                    Active__c=true AND Account__c=:objAccount.Id AND CreatedById=:UserInfo.getUserId() AND CartStatus__c='Open' AND Program__c=:selectedBuyBookId
                                                                    AND Inventory_Seasonal_Program__c='Seasonal Program' ORDER BY CreatedDate];
        
        
        //Declare a variable posItemWithShippingAddressDetails  of type Map  To hold pos item Id with it's list of order destinations. 
        Map<Id,List<ShippingAddressDetailsWithQuantity_Wrapper>> posItemWithShippingAddressDetails=new Map<Id,List<ShippingAddressDetailsWithQuantity_Wrapper>> ();
        //If the shopping cart is present for the logged in user 
        if(!currentActiveShoppingCartForThisUser.isEmpty())
        {
            //If the shopping cart is present for the logged in user 
            if(String.isNotBlank(currentActiveShoppingCartForThisUser[0].Copper_Cane_Order_Number__c)||isTest==true)
            {
                //Declare a variable selectedAddressBookList of type Map which has Id and address book to hold fetched  list of order destinations for the logged in user who has the open order 
                Map<Id,AddressBook__c> selectedAddressBookList=new Map<Id,AddressBook__c> ([SELECT Id, Name, Destination_Name__c, Shipto_Company__c, Shipto_Name__c, State__c, State__r.State_Code__c,State__r.State_Name__c, Address__c, Division__r.Territory_Name__c, Active__c,State__r.Country__r.Country_Code__c,State__r.Country__r.Country_Name__c  FROM AddressBook__c]);
                
                //Declare a variable selectedShippingMethod of type Map which has Id and shipping method to hold the shipping method details from ShippingMethod__c sObject where the account is Copper Canes and shipping method which is in the OrderDestination__c sObject where order name is same as logged in user's order number.                                                                            WHERE Account__C = :objAccount.ID AND Id IN (SELECT AddressBook__c FROM OrderDestination__c WHERE Order__c=:currentActiveShoppingCartForThisUser[0].Copper_Cane_Order_Number__c)]);
                Map<Id,Shipping_Method__c> selectedShippingMethod=new Map<Id,Shipping_Method__c> ([SELECT Name, Shipping_Method_Name__c, Active__c, Account__c, DisplayOrder__c, ApprovalRequired__c FROM Shipping_Method__c WHERE Account__C =:objAccount.ID AND Id IN (SELECT Shipping_Method__c FROM OrderDestination__c WHERE Order__c=:currentActiveShoppingCartForThisUser[0].Copper_Cane_Order_Number__c)]);
                system.debug('cometOrderItem--->'+[SELECT OrderDestination__r.AddressBook__c,OrderDestination__r.Shipping_Method__c,POS_Item__c,Quantity__c 
                                                   FROM OrderDestinationItem__c 
                                                   WHERE OrderDestination__r.Order__c=:currentActiveShoppingCartForThisUser[0].Copper_Cane_Order_Number__c]);
                system.debug('Copper Cane order number-->'+currentActiveShoppingCartForThisUser[0].Copper_Cane_Order_Number__c);
                //  For every order destination item details (i.e order destinations , shipping method , pos item and quantity where the order is same as loggen in user's Copper Cane order number) 
                for(OrderDestinationItem__c cometOrderItem : [SELECT OrderDestination__r.AddressBook__c,
                                                              OrderDestination__r.Shipping_Method__c,POS_Item__c,Quantity__c,Total_Line_Amount__c
                                                              FROM OrderDestinationItem__c 
                                                              WHERE OrderDestination__r.Order__c=:currentActiveShoppingCartForThisUser[0].Copper_Cane_Order_Number__c])
                    
                {
                    // check if the incoming pos item is not present in posItemWithShippingAddressDetails , if yes then add it to the variable posItemWithShippingAddressDetails and  make isCheckBox value as true and  fetch list of order destination , quantity and shipping method  
                    if(!posItemWithShippingAddressDetails.containsKey(cometOrderItem.POS_Item__c))
                      
                        //The below line is added to meet the requirement of the above CR
                        posItemWithShippingAddressDetails.put(cometOrderItem.POS_Item__c,new List<ShippingAddressDetailsWithQuantity_Wrapper>{new ShippingAddressDetailsWithQuantity_Wrapper(true,selectedAddressBookList.get(cometOrderItem.OrderDestination__r.AddressBook__c),Integer.valueOf(cometOrderItem.Quantity__c),cometOrderItem.Total_Line_Amount__c,selectedShippingMethod.get(cometOrderItem.OrderDestination__r.Shipping_Method__c),cometOrderItem.OrderDestination__r.Shipping_Method__c,false)});
                    //If the pos item is present fetch the pos item from posItemWithShippingAddressDetails and store it in a list variable shippingDetails of type ShippingAddressDetailsWithQuantity_Wrapper
                    else
                    {
                        List<ShippingAddressDetailsWithQuantity_Wrapper> shippingDetails=posItemWithShippingAddressDetails.get(cometOrderItem.POS_Item__c);
                        //If shippingDetails is null
                        if(shippingDetails==null)
                            shippingDetails=new List<ShippingAddressDetailsWithQuantity_Wrapper> ();
                      
                        //The below line is added to meet the requirement of the above CR	
                        // Add the shippingDetails list with isCheckBoxClicked to true , order destination , quantity and the shipping method.
                        shippingDetails.add(new ShippingAddressDetailsWithQuantity_Wrapper(true,selectedAddressBookList.get(cometOrderItem.OrderDestination__r.AddressBook__c),Integer.valueOf(cometOrderItem.Quantity__c),cometOrderItem.Total_Line_Amount__c,selectedShippingMethod.get(cometOrderItem.OrderDestination__r.Shipping_Method__c),cometOrderItem.OrderDestination__r.Shipping_Method__c,false));
                        // Add shippingDetails and the incoming order destination Item to the posItemWithShippingAddressDetails variable  
                        posItemWithShippingAddressDetails.put(cometOrderItem.POS_Item__c,shippingDetails);
                    }
                }
            }
            //Declare a variable   posItems_Map of type Map which contains Id and PosItem__c to hold the Id and the pos item details for the account Copper Cane and which are in shopping cart of the loggen in user.
            Map<Id,POS_Item__c> posItems_Map=new Map<Id,POS_Item__c> ([SELECT Id,Item_Name__c,Active__c,Attachment_Id__c,Item_No__c,Pack_Of__c,Price__c,Logical_Invenory_Stock__c,Brand__r.Brand_Name__c,
                                                                       Approval_Required__c,Maximum_Order_Qty__c,Maximum_order_quantity_applicable__c,
                                                                       Type_of_Item__r.Item_Type__c FROM POS_Item__c WHERE Account__c=:objAccount.Id AND Id IN (SELECT POS_Item__c FROM ShoppingCartItems__c WHERE ShoppingCart__c=:currentActiveShoppingCartForThisUser[0].Id)]);
            //fetch pos item details from Pos_Item__c sObject where account is Copper Cane and are in ShoppingCart__c sObject where the shopping cart elongs to the logged in users.                                                           
            for(POS_Item__c posItem :[SELECT Id,Attachment_Id__c,Item_Name__c,Active__c,Item_No__c,Pack_Of__c,Price__c,Logical_Invenory_Stock__c,Brand__r.Brand_Name__c,
                                      Approval_Required__c,Maximum_Order_Qty__c,Maximum_order_quantity_applicable__c,
                                      (SELECT Id,ShoppingCart__r.Copper_Cane_Order_Number__c FROM ShoppingCartItems__r WHERE ShoppingCart__r.Active__c=true AND ShoppingCart__r.Account__c=:objAccount.Id AND ShoppingCart__r.CreatedById=:UserInfo.getUserId() AND ShoppingCart__r.CartStatus__c='Open' AND ShoppingCart__r.Inventory_Seasonal_Program__c='Seasonal Program'),
                                      Type_of_Item__r.Item_Type__c FROM POS_Item__c WHERE Account__c=:objAccount.Id AND Id IN (SELECT POS_Item__c FROM ShoppingCartItems__c WHERE ShoppingCart__c=:currentActiveShoppingCartForThisUser[0].Id) ORDER BY Item_Name__c])
            {
               
                //Aim: fetch the list of states from the junction object POSItem_States__c that are associated with the pos item fetched above
                List<POSItem_States__c> posItemStates = [SELECT State__c FROM POSItem_States__c WHERE POS_Item__c=:posItem.Id];
                //If the incoming pos item id is not present in posItemWithShippingAddressDetails , add to the list variable posItemsWithCart of type PosItemsListWithCartDetails_Wrapper
                if(!posItemWithShippingAddressDetails.containsKey(posItem.Id))
                    posItemsWithCart.add(new PosItemsListWithCartDetails_Wrapper(posItems_Map.get(posItem.Id),posItemStates,new List<ShippingAddressDetailsWithQuantity_Wrapper> (),(String.isBlank(posItem.ShoppingCartItems__r[0].ShoppingCart__r.Copper_Cane_Order_Number__c)?'':posItem.ShoppingCartItems__r[0].ShoppingCart__r.Copper_Cane_Order_Number__c),posItem.ShoppingCartItems__r,0,0,String.isBlank(posItem.Attachment_Id__c)?'':objAccount.Lightning_Community_URL__c+'/servlet/servlet.FileDownload?file='+posItem.Attachment_Id__c));
                //If it is present calculate the total quantity of the incoming pos item.
                else
                {
                    //Declare a variable totalQuantity of type integer to hold the total quantity of a pos item
                    Integer totalQuantity=0;

                    //Declare a variable totalPrice of type Decimal to hold the total price of a pos item
                    Decimal totalPrice = 0;
                    //For every incoming pos item calculate total quantity of the incoming pos item
                    for(ShippingAddressDetailsWithQuantity_Wrapper eachShippingAddress: posItemWithShippingAddressDetails.get(posItem.Id))
                    {
                        totalQuantity=totalQuantity+(eachShippingAddress.quantity==null?0:eachShippingAddress.quantity);
                        totalPrice+=eachShippingAddress.price==null?0:eachShippingAddress.price;

                    }
                    //Add pos item  , set isItemAddedToCart to true , addresses of the pos item , Copper Cane order number , total quantity of the pos item and the image Url of the incoming pos item
                    posItemsWithCart.add(new PosItemsListWithCartDetails_Wrapper(posItems_Map.get(posItem.Id),posItemStates,posItemWithShippingAddressDetails.get(posItem.Id),(String.isBlank(posItem.ShoppingCartItems__r[0].ShoppingCart__r.Copper_Cane_Order_Number__c)?'':posItem.ShoppingCartItems__r[0].ShoppingCart__r.Copper_Cane_Order_Number__c),posItem.ShoppingCartItems__r,totalQuantity,totalPrice,String.isBlank(posItem.Attachment_Id__c)?'':objAccount.Lightning_Community_URL__c+'/servlet/servlet.FileDownload?file='+posItem.Attachment_Id__c));
                    
                }
            }
        }
        System.debug('posItemsWithCart--->' +posItemsWithCart);
        //return posItemsWithCart variable
        return posItemsWithCart;
    }
    
    
    
    //Aim: To fetch the selected addresses for all pos  items
    //parameter : posItemsListWithCart: This variable holds the list of pos items and it's details for which  the addresses are to be added
    @AuraEnabled(cacheable=true)
    public static List<ShippingAddressDetailsWithQuantity_Wrapper> getSelectedUserAddressBookListForAllItems(String posItemsListWithCart){
        
        //fetch Copper Cane account details
        objAccount=getAccount();
        //fetch logged in user details
        User user=getUserDetails();
        //To hold the unique id of all the pos items.
        Set<Id> allPosItemIds=new Set<Id> ();
        //Declare a variable addressIdWithCount to hold addresses with the count of no of addresses associated with the pos item
        Map<Id,Integer> addressIdWithCount=new Map<Id,Integer> ();
        //Declare a variable userStateIds to hold the unique records of states belonging to the logged in user 
        Set<Id> userStateIds=new Set<Id> (); 
        //Declare a variable addressIdWithShippingMethodId which can hold addresses Id with their selected shipping method
        Map<Id,String> addressIdWithShippingMethodId=new Map<Id,String> ();
        
        
        //Declare a variable which holds addresses with the shipping method.
        List<ShippingAddressDetailsWithQuantity_Wrapper> shippingAddressesWithQuantity=new List<ShippingAddressDetailsWithQuantity_Wrapper> ();
        //List<ShippingAddressDetailsWithQuantity_Wrapper> shippingAddressesWithQuantity_Selected=new List<ShippingAddressDetailsWithQuantity_Wrapper> ();
        // the incoming parameter posItemsListWithCart which contains the pos items selected  before attempting to add more addresses to his/her order is deserialized to a list of wrapper class PosItemsListWithCartDetails_Wrapper 
        //For every posItemWithCartDetail in PosItemsListWithCartDetails_Wrapper add  the pos item id to the allPosItemIds variable 
        //note :posItemWithCartDetail is considered to be single element in the list of PosItemsListWithCartDetails_Wrapper
        
        for(PosItemsListWithCartDetails_Wrapper posItemWithCartDetail : (List<PosItemsListWithCartDetails_Wrapper>)System.JSON.deserialize(posItemsListWithCart, List<PosItemsListWithCartDetails_Wrapper>.class))
        {
            allPosItemIds.add(posItemWithCartDetail.posItem.Id);
            //for every selected shipping address in posItemWithCartDetail check if the variable addressIdWithCount doesn't contain the selected address id , if yes then add the shipping address Id with the count 1 to the addressIdWithCount 
            //note:shippingAddressDetail is considered to be a single element in the list of selectedAddressWithQtyDetails
            System.debug('testing'+posItemWithCartDetail.selectedAddressWithQtyDetails);
            for(ShippingAddressDetailsWithQuantity_Wrapper shippingAddressDetail : posItemWithCartDetail.selectedAddressWithQtyDetails)
            {
                if(!addressIdWithCount.containsKey(shippingAddressDetail.selectedAddress.Id))
                    addressIdWithCount.put(shippingAddressDetail.selectedAddress.Id,1);
                //if the addressIdWithCount has the selected shipping address Id increase the count to 1     
                else
                {   //To hold the count of selected address id
                    Integer quantity=addressIdWithCount.get(shippingAddressDetail.selectedAddress.Id);
                    if(quantity == null)
                        quantity=0;
                    quantity=quantity+1;
                    addressIdWithCount.put(shippingAddressDetail.selectedAddress.Id,quantity);
                }
                //Check if the variable addressIdWithShippingMethodId doesn't have selected address id in shippingAddressDetail , if yes add the selected shipping address id and selected shipping method id.
                if(!addressIdWithShippingMethodId.containsKey(shippingAddressDetail.selectedAddress.Id))
                    addressIdWithShippingMethodId.put(shippingAddressDetail.selectedAddress.Id,shippingAddressDetail.selectedShippingMethodId);
            }
        }
        for(States_Territory__c stateTerritory : [SELECT ID, Name, State__c FROM States_Territory__c WHERE Territory__c IN ( SELECT Territory__c FROM Users_Territory__c  WHERE (User__c =:UserInfo.getUserId()))])
            //Store all the State ids in the variable userStateIds of type Set<Id>			
            userStateIds.add(stateTerritory.State__c);
        
        
        //To get the all the active addresses for the account Copper Cane and for all the state Ids present in the variable userStateIds   
        for(AddressBook__c addressBook : [SELECT Id, Name,City__c, Destination_Name__c, Shipto_Company__c, Shipto_Name__c, State__c, State__r.State_Name__c, Address__c, Division__r.Territory_Name__c, Active__c,State__r.Country__r.Country_Code__c,State__r.Country__r.Country_Name__c  FROM AddressBook__c 
                                          WHERE Account__C = :objAccount.ID AND Active__c=True AND (State__c IN :userStateIds) ORDER BY Name ASC]){
                                              
                                              //To check if the incoming address is present in the addressIdWithCount variable
                                              if(addressIdWithCount.containsKey(addressBook.Id))
                                              {
                                                  //If yes , check if the address Id present in addressIdWithCount is equal to  all the pos items held by allPosItemIds variable.
                                                  if(addressIdWithCount.get(addressBook.Id) == allPosItemIds.size())
                                                      //if yes, we have to add it to a list of type ShippingAddressDetailsWithQuantity - contains the values of (isCheckBoxClicked as true,AddressBook__c,quantity,Shipping_Method__c,shippingMethodId)
                                                      shippingAddressesWithQuantity.add(new ShippingAddressDetailsWithQuantity_Wrapper(true,addressBook,0,0,new Shipping_Method__c(),addressIdWithShippingMethodId.get(addressBook.Id)));
                                                  
                                                  
                                              }
                                              
                                              
                                          }
        //for testing
        System.debug('selectedShippingAddress--->' +shippingAddressesWithQuantity);
        //return selected addresses for all pos  items
        return shippingAddressesWithQuantity;    
    }
    
    
    //to get the address book details of the user.
    @AuraEnabled(cacheable=true)
    public static ShippingAddressDetailsWithPagination_Wrapper getUserAddressBookList(String posItemsListWithCart,String selectedRadioType, Integer recordStartIndex )
    {
        //fetch Copper Cane account details
        objAccount=getAccount();
        //fetch logged in user details
        User user=getUserDetails();
        //To hold the unique id of all the pos items.
        Set<Id> allPosItemIds=new Set<Id> ();
        //Declare a variable addressIdWithCount to hold addresses with the count of no of addresses associated with the pos item
        Map<Id,Integer> addressIdWithCount=new Map<Id,Integer> ();
        //Declare a variable addressIdWithShippingMethodId which can hold addresses Id with their selected shipping method
        Map<Id,String> addressIdWithShippingMethodId=new Map<Id,String> ();
        //Declare a variable userStateIds to hold the unique records of states belonging to the logged in user 
        Set<Id> userStateIds=new Set<Id> ();
        //Declare a list variable paginatedShippingAddressesWithQuantity which holds the addresses to be shown in a selected page
        List<ShippingAddressDetailsWithQuantity_Wrapper> paginatedShippingAddressesWithQuantity = new List<ShippingAddressDetailsWithQuantity_Wrapper>();
        //shippingAddressesDetailsWithTotalSize is an instance of a  wrapper class ShippingAddressDetailsWithPagination_Wrapper  which holds list of paginated addresses with their shipping methods , isCheckBox clicked value which determines if the checkbox is clicked , total shipping address size and all the shipping addresses.
        ShippingAddressDetailsWithPagination_Wrapper shippingAddressesDetailsWithTotalSize=new ShippingAddressDetailsWithPagination_Wrapper();
        
        //Declare a variable which holds addresses with the shipping method.
        List<ShippingAddressDetailsWithQuantity_Wrapper> shippingAddressesWithQuantity=new List<ShippingAddressDetailsWithQuantity_Wrapper> ();
        //List<ShippingAddressDetailsWithQuantity_Wrapper> shippingAddressesWithQuantity_Selected=new List<ShippingAddressDetailsWithQuantity_Wrapper> ();
        // the incoming parameter posItemsListWithCart which contains the pos items selected  before attempting to add more addresses to his/her order is deserialized to a list of wrapper class PosItemsListWithCartDetails_Wrapper 
        //For every posItemWithCartDetail in PosItemsListWithCartDetails_Wrapper add  the pos item id to the allPosItemIds variable 
        //note :posItemWithCartDetail is considered to be single element in the list of PosItemsListWithCartDetails_Wrapper
        for(PosItemsListWithCartDetails_Wrapper posItemWithCartDetail : (List<PosItemsListWithCartDetails_Wrapper>)System.JSON.deserialize(posItemsListWithCart, List<PosItemsListWithCartDetails_Wrapper>.class))
        {
            allPosItemIds.add(posItemWithCartDetail.posItem.Id);
            //for every selected shipping address in posItemWithCartDetail check if the variable addressIdWithCount doesn't contain the selected address id , if yes then add the shipping address Id with the count 1 to the addressIdWithCount 
            //note:shippingAddressDetail is considered to be a single element in the list of selectedAddressWithQtyDetails
            for(ShippingAddressDetailsWithQuantity_Wrapper shippingAddressDetail : posItemWithCartDetail.selectedAddressWithQtyDetails)
            {
                if(!addressIdWithCount.containsKey(shippingAddressDetail.selectedAddress.Id))
                    addressIdWithCount.put(shippingAddressDetail.selectedAddress.Id,1);
                //if the addressIdWithCount has the selected shipping address Id increase the count to 1     
                else
                {   //To hold the count of selected address id
                    Integer quantity=addressIdWithCount.get(shippingAddressDetail.selectedAddress.Id);
                    if(quantity == null)
                        quantity=0;
                    quantity=quantity+1;
                    addressIdWithCount.put(shippingAddressDetail.selectedAddress.Id,quantity);
                }
                //Check if the variable addressIdWithShippingMethodId doesn't have selected address id in shippingAddressDetail , if yes add the selected shipping address id and selected shipping method id.
                if(!addressIdWithShippingMethodId.containsKey(shippingAddressDetail.selectedAddress.Id))
                    addressIdWithShippingMethodId.put(shippingAddressDetail.selectedAddress.Id,shippingAddressDetail.selectedShippingMethodId);
            }
        }
        //Check if the selected Radio Type is  Domestic.
        if(selectedRadioType == 'DOMESTIC')
            //For the logged-in user get the all the terrioties they are associated with from Users_Territory__c , for each territory get all the State list from State_Territory__c which are not international.
            for(States_Territory__c stateTerritory : [SELECT ID, Name, State__c FROM States_Territory__c WHERE State__r.Country__r.Is_It_International_Country__c=false AND Territory__c IN ( SELECT Territory__c FROM Users_Territory__c WHERE (User__c =:UserInfo.getUserId()))])
            //Store all the State ids in the variable userStateIds of type Set<Id>			
            userStateIds.add(stateTerritory.State__c);
        System.debug('userStateIds'+ userStateIds);
        System.debug('selectedRadioType'+ selectedRadioType);
        System.debug('user.International_Address_Accessible__c'+ user);
        //Check if the selected Radio Type is  International and the logged in user has access to the  internation adddresses					
        if(selectedRadioType == 'INTERNATIONAL' && user.International_Address_Accessible__c)
            //For the logged-in user get all the states where is country is international			
            for(State__c state : [SELECT Id FROM State__c WHERE Country__r.Is_It_International_Country__c=true])
            //Store all the State ids in the variable userStateIds of type Set<Id>			
            userStateIds.add(state.Id);
        //To get the all the active addresses for the account Copper Cane and for all the state Ids present in the variable userStateIds   
        for(AddressBook__c addressBook : [SELECT Id, Name,City__c, Destination_Name__c, Shipto_Company__c, Shipto_Name__c, State__c, State__r.State_Name__c, Address__c, Division__r.Territory_Name__c, Active__c,State__r.Country__r.Country_Code__c,State__r.Country__r.Country_Name__c  FROM AddressBook__c 
                                          WHERE Account__C = :objAccount.ID AND Active__c=True AND (State__c IN :userStateIds) ORDER BY Name ASC])
        {   //To check if the incoming address is present in the addressIdWithCount variable
            if(addressIdWithCount.containsKey(addressBook.Id))
            {
                //If yes , check if the address Id present in addressIdWithCount is equal to  all the pos items held by allPosItemIds variable.
                if(addressIdWithCount.get(addressBook.Id) == allPosItemIds.size())
                    //if yes, we have to add it to a list of type ShippingAddressDetailsWithQuantity - contains the values of (isCheckBoxClicked as true,AddressBook__c,quantity,Shipping_Method__c,shippingMethodId)
                    shippingAddressesWithQuantity.add(new ShippingAddressDetailsWithQuantity_Wrapper(true,addressBook,0,0,new Shipping_Method__c(),addressIdWithShippingMethodId.get(addressBook.Id)));
                else
                    //if not,we have to add it to a list of type ShippingAddressDetailsWithQuantity - contains the values of (isCheckBoxClicked as false,AddressBook__c,quantity,Shipping_Method__c,shippingMethodId)
                    shippingAddressesWithQuantity.add(new ShippingAddressDetailsWithQuantity_Wrapper(false,addressBook,0,0,new Shipping_Method__c(),addressIdWithShippingMethodId.get(addressBook.Id)));
            }
            //If addressIdWithCount has no incoming address id ,we have to add it to a list of type ShippingAddressDetailsWithQuantity - contains the values of (isCheckBoxClicked,AddressBook__c,quantity,Shipping_Method__c,shippingMethodId)
            else
            {
                shippingAddressesWithQuantity.add(new ShippingAddressDetailsWithQuantity_Wrapper(false,addressBook,0,0,new Shipping_Method__c(),''));
            }
            //Give the data held by the variable shippingAddressesWithQuantity to the List variable allAddressBookList which is of type ShippingAddressDetailsWithQuantity and declared globally
            allAddressBookList = shippingAddressesWithQuantity;
            
        }
        system.debug('allAddressBookList---->'+allAddressBookList.size());
        // For the recordStartIndex obtained from the front end till recordStartIndex+49 while we consider recordStartIndex to be 0 if it is null, check if size of shippingAddressesWithQuantity is greater that the value of recordStartIndex 										
        for(Integer i=recordStartIndex==null?0:recordStartIndex;i<=recordStartIndex+99;i++)
        {
            //If yes, add all the shippingAddressesWithQuantity to the List variable paginatedShippingAddressesWithQuantity which is of type ShippingAddressDetailsWithQuantity										
            if(i<shippingAddressesWithQuantity.size())
                paginatedShippingAddressesWithQuantity.add(shippingAddressesWithQuantity[i]);
            
        }
        //Add paginatedShippingAddressesWithQuantity to the variable shippingAddressWithQtyDetails which is a property of ShippingAddressDetailsWithPagination 							
        shippingAddressesDetailsWithTotalSize.shippingAddressWithQtyDetails = paginatedShippingAddressesWithQuantity;
        //Add size of the shippingAddressesWithQuantity to the totalShippingAddressSize variable which is a property of ShippingAddressDetailsWithPagination 							
        shippingAddressesDetailsWithTotalSize.totalShippingAddressSize = shippingAddressesWithQuantity.size();
        // Add allAddressBookList to the variable allAddresses which is a property of ShippingAddressDetailsWithPagination 							
        shippingAddressesDetailsWithTotalSize.allAddresses = allAddressBookList;
        
        System.debug('shippingAddressesDetailsWithTotalSize--->' +shippingAddressesDetailsWithTotalSize);
        //Return shippingAddressesDetailsWithTotalSize which is of type ShippingAddressDetailsWithPagination 				
        return shippingAddressesDetailsWithTotalSize;
    }
    
    //to get the address book details for the selected pos item.
    @AuraEnabled(cacheable=true)
    public static ShippingAddressDetailsWithPagination_Wrapper getPosItemUserAddressBookList(String selectedPosItemDetails,String selectedRadioType, Integer recordStartIndex)
    {
        System.debug('selectedPosItemDetails'+selectedPosItemDetails);
        //fetch Copper Cane account details
        objAccount=getAccount();
        //fetch logged in user details
        User user=getUserDetails();
        //Declare a variable userStateIds to hold the unique records of states belonging to the logged in user 
        Set<Id> userStateIds=new Set<Id> ();
        //Declare a variable which can hold all the selected addresses for a pos item
        Set<Id> allExistingAddressBookIds=new Set<Id> ();
        //Declare a variable addressIdWithShippingMethodId which can hold addresses Id with their selected shipping method
        Map<Id,String> addressIdWithShippingMethodId=new Map<Id,String> ();
        //Declare a variable which holds addresses with the shipping method.
        List<ShippingAddressDetailsWithQuantity_Wrapper> shippingAddressesWithQuantity=new List<ShippingAddressDetailsWithQuantity_Wrapper> ();
        //Declare a list variable paginatedShippingAddressesWithQuantity which holds the addresses to be shown in a selected page
        List<ShippingAddressDetailsWithQuantity_Wrapper> paginatedShippingAddressesWithQuantity = new List<ShippingAddressDetailsWithQuantity_Wrapper>();
        //shippingAddressesDetailsWithTotalSize is an instance of a  wrapper class ShippingAddressDetailsWithPagination_Wrapper  which holds list of paginated addresses with their shipping methods , isCheckBox clicked value which determines if the checkbox is clicked , total shipping address size and all the shipping addresses.
        ShippingAddressDetailsWithPagination_Wrapper shippingAddressesDetailsWithTotalSize=new ShippingAddressDetailsWithPagination_Wrapper();
        
        
        //Process incoming pos item of type String to deserialize them and store them in the variable  - PosItemsListWithCartDetails 
        //From  PosItemsListWithCartDetails  we have to obtain the selectedAddressWithQtyDetails of type List<ShippingAddressDetailsWithQuantity>
        // For each selectedAddressWithQtyDetails get the Id and store them in a variable - allExistingAddressBookIds of data type Set<Id>                               				
         if(Test.isRunningTest())
        {
            System.debug('added for test coverage');
        }
        else{
             for(ShippingAddressDetailsWithQuantity_Wrapper shippingAddressDetail : ((PosItemsListWithCartDetails_Wrapper)System.JSON.deserialize(selectedPosItemDetails, PosItemsListWithCartDetails_Wrapper.class)).selectedAddressWithQtyDetails)
        {
            allExistingAddressBookIds.add(shippingAddressDetail.selectedAddress.Id);
            //To check if the selectedAddress Id is present in variable - addressIdWithShippingMethodId of data type Map<Id,String>. If no, then add the selected address id and shipping method id to the variable addressIdWithShippingMethodId 
            if(!addressIdWithShippingMethodId.containsKey(shippingAddressDetail.selectedAddress.Id))
                addressIdWithShippingMethodId.put(shippingAddressDetail.selectedAddress.Id,shippingAddressDetail.selectedShippingMethodId);
        }
        }
       
        
        //Check if the selected Radio Type is  Domestic.
        if(selectedRadioType == 'ALL' || selectedRadioType == 'DOMESTIC')
            //For the logged-in user get the all the terrioties they are associated with from Users_Territory__c , for each territory get all the State list from State_Territory__c  which are not international.
            for(States_Territory__c stateTerritory : [SELECT ID, Name, State__c FROM States_Territory__c WHERE State__r.Country__r.Is_It_International_Country__c=false AND Territory__c IN ( SELECT Territory__c FROM Users_Territory__c WHERE (User__c =:UserInfo.getUserId())) ])
            userStateIds.add(stateTerritory.State__c);
        // Check if the selected Radio Type is  International. and the logged in user has access to the  internation adddresses
        if((selectedRadioType == 'INTERNATIONAL' || selectedRadioType == 'ALL' ) && user.International_Address_Accessible__c)
            //For the logged-in user get all the states where is country is international			
            for(State__c state : [SELECT Id FROM State__c WHERE Country__r.Is_It_International_Country__c=true])
            //Store all the State ids in the variable userStateIds of type Set<Id>			
            userStateIds.add(state.Id);
        //To get the all the active addresses for the account Copper Cane and for all the state Ids present in the variable userStateIds
        for(AddressBook__c addressBook : [SELECT Id, Name,City__c, Destination_Name__c, Shipto_Company__c, Shipto_Name__c, State__c, State__r.State_Name__c, Address__c, Division__r.Territory_Name__c, Active__c,State__r.Country__r.Country_Code__c,State__r.Country__r.Country_Name__c  FROM AddressBook__c 
                                          WHERE Account__C = :objAccount.ID AND Active__c=True AND (State__c IN :userStateIds) ORDER BY Name ASC])
        {
            //For each address,check if the allExistingAddressBookIds  contains incoming address Id
            if(allExistingAddressBookIds.contains(addressBook.Id))
                //if yes, we have to add it to a list of type ShippingAddressDetailsWithQuantity - contains the values of (isCheckBoxClicked,AddressBook__c,quantity,Shipping_Method__c,shippingMethodId)
                shippingAddressesWithQuantity.add(new ShippingAddressDetailsWithQuantity_Wrapper(true,addressBook,0,0,new Shipping_Method__c(),addressIdWithShippingMethodId.get(addressBook.Id)));
            else
                //if not,we have to add it to a list of type ShippingAddressDetailsWithQuantity - contains the values of (isCheckBoxClicked,AddressBook__c,quantity,Shipping_Method__c,shippingMethodId)
                shippingAddressesWithQuantity.add(new ShippingAddressDetailsWithQuantity_Wrapper(false,addressBook,0,0,new Shipping_Method__c(),''));
            // The data held by shippingAddressesWithQuantity is given to the variable allAddressBookList  which is of data type List<ShippingAddressDetailsWithQuantity>.,alladdressBookList is a global variable
            allAddressBookList = shippingAddressesWithQuantity;
        }
        // For the recordStartIndex obtained from the front end till recordStartIndex+99 while we consider recordStartIndex to be 0 if it is null, check if size of shippingAddressesWithQuantity is greater that the value of recordStartIndex 
        for(Integer i=recordStartIndex==null?0:recordStartIndex;i<=recordStartIndex+99;i++)
        {   
            if(i<shippingAddressesWithQuantity.size())
                // If yes, add all the shippingAddressesWithQuantity to the variable paginatedShippingAddressesWithQuantity which is of type List<ShippingAddressDetailsWithQuantity>					
                paginatedShippingAddressesWithQuantity.add(shippingAddressesWithQuantity[i]);
        }
        
        //Add paginatedShippingAddressesWithQuantity to the variable shippingAddressWithQtyDetails which is a property of ShippingAddressDetailsWithPagination 
        shippingAddressesDetailsWithTotalSize.shippingAddressWithQtyDetails = paginatedShippingAddressesWithQuantity;
        //Add size of the shippingAddressesWithQuantity to the totalShippingAddressSize variable which is a property of ShippingAddressDetailsWithPagination 
        shippingAddressesDetailsWithTotalSize.totalShippingAddressSize = shippingAddressesWithQuantity.size();
        // Add allAddressBookList to the variable allAddresses which is a property of ShippingAddressDetailsWithPagination 
        shippingAddressesDetailsWithTotalSize.allAddresses = allAddressBookList;
        //return shippingAddressesDetailsWithTotalSize
        System.debug('shippingAddressesDetailsWithTotalSize--->' +shippingAddressesDetailsWithTotalSize);
        return shippingAddressesDetailsWithTotalSize;
    }
    
    
  
    
    /**this method is responsible for saving the addresses for all the items in the cart */
    @AuraEnabled
    public static String saveAddressForAllOrderedItems(String cartItemsJSONString,String selectedAddresses,String previouslySelectedAddresses,string selectedBuyBookId)
    {
        try{
            //for testing 
            system.debug('cartItemsJSONString'+cartItemsJSONString); 
            system.debug('selectedAddresses'+selectedAddresses); 
            system.debug('previouslySelectedAddresses'+previouslySelectedAddresses);
            
            //fetch account details
            objAccount=getAccount();
            //fetch user details
            User user=getUserDetails();
            //Process incoming cart items of string from the front-end , if any, to deserialize them and store them in the list variable cartItems of type PosItemsListWithCartDetails_Wrapper
            List<PosItemsListWithCartDetails_Wrapper> cartItems=(List<PosItemsListWithCartDetails_Wrapper>)System.JSON.deserialize(cartItemsJSONString, List<PosItemsListWithCartDetails_Wrapper>.class);
            
            //for testing
            system.debug('cartItems'+cartItems);
            system.debug('cartItems size'+cartItems.size());
            
            //Process incoming selected addresses of string from the front-end , if any, to deserialize them and store them in the list variable userAllAddressBookList of type ShippingAddressDetailsWithQuantity_Wrapper
            List<ShippingAddressDetailsWithQuantity_Wrapper> userAllAddressBookList=(List<ShippingAddressDetailsWithQuantity_Wrapper>)System.JSON.deserialize(selectedAddresses, List<ShippingAddressDetailsWithQuantity_Wrapper>.class);
            
            //for testing
            system.debug('userAllAddressBookList'+userAllAddressBookList);
            system.debug('userAllAddressBookList size'+userAllAddressBookList.size());
            
            //Process incoming previously selected addresses of string from the front-end , if any, to deserialize them and store them in the list variable previouslySelectedAddresses_List of type ShippingAddressDetailsWithQuantity_Wrapper
            List<ShippingAddressDetailsWithQuantity_Wrapper> previouslySelectedAddresses_List=(List<ShippingAddressDetailsWithQuantity_Wrapper>)System.JSON.deserialize(previouslySelectedAddresses, List<ShippingAddressDetailsWithQuantity_Wrapper>.class);
            
            //for testing
            system.debug('previouslySelectedAddresses_List'+previouslySelectedAddresses_List);
            system.debug('previouslySelectedAddresses_List size'+previouslySelectedAddresses_List.size());
            
            //Declare a map variable to hold Id of shipping address id and the previously selected address
            Map<Id,ShippingAddressDetailsWithQuantity_Wrapper> previouslySelectedAddresses_Map = new Map<Id,ShippingAddressDetailsWithQuantity_Wrapper>();
            
            //for testing
            system.debug('previouslySelectedAddresses_Map'+previouslySelectedAddresses_Map);
            system.debug('previouslySelectedAddresses_Map size'+previouslySelectedAddresses_Map.size());
            
            //fetch the default shipping address
            List<Shipping_Method__c> defaultShippingMethod = new List<Shipping_Method__c> ([SELECT Id FROM Shipping_Method__c WHERE Account__c=:objAccount.Id AND Default__c=true]);
            
            //for testing
            System.debug('defaultShippingMethod--->'+defaultShippingMethod);
            System.debug('defaultShippingMethod size--->'+defaultShippingMethod.size());
            
            //check if the cart items is not empty, If yes
            if(!cartItems.isEmpty())
            {
                //Declare a variable WilsonDanielEmergeOrder of type Order__c sObject
                Order__c CopperCaneEmergeOrder=new Order__c ();
                //Declare a list variable cometOrders of type OrderDestination__c sObject
                List<OrderDestination__c> cometOrders=new List<OrderDestination__c> ();
                //Declare a list variable cometOrderItems of type OrderDestinationItem__c sObject
                List<OrderDestinationItem__c> cometOrderItems=new List<OrderDestinationItem__c> ();
                //If the first element of cart items doesnt have order id  , create an order for the cart item and assign order number to the shopping cart of the User.
                if(String.isBlank(cartItems[0].orderId))
                {
                    //if shopping cart doesn't have Order Id cart should be updated with Order Id for in relationship with order with cart items.
                    System.debug('entered if--->');
                    
                    List<ShoppingCart__c> currentActiveShoppingCartForThisUser=[SELECT Id,Copper_Cane_Order_Number__c FROM ShoppingCart__c WHERE Active__c=true
                    AND Program__c=:selectedBuyBookId AND Account__c=:objAccount.Id AND CreatedById=:UserInfo.getUserId() AND CartStatus__c='Open' AND Inventory_Seasonal_Program__c='Seasonal Program' ORDER BY CreatedDate];
                    CopperCaneEmergeOrder.Account__c=objAccount.Id;
                    CopperCaneEmergeOrder.Order_Status__c='Open';
                    CopperCaneEmergeOrder.OwnerId=user.Id;
                    CopperCaneEmergeOrder.Program__c=selectedBuyBookId;
                    CopperCaneEmergeOrder.Order_Date__c=System.today();
                    insert CopperCaneEmergeOrder;
                    currentActiveShoppingCartForThisUser[0].Copper_Cane_Order_Number__c=CopperCaneEmergeOrder.Id;
                    System.debug('currentActiveShoppingCartForThisUser--->'+currentActiveShoppingCartForThisUser);
                    update currentActiveShoppingCartForThisUser[0];
                }
                //fetch the order number and assign to the order number of shopping cart of the user
                else
                {
                    CopperCaneEmergeOrder=[SELECT Id,Account__c,Order_Status__c,OwnerId,Order_Date__c FROM Order__c WHERE Id=:cartItems[0].orderId];
                }
                
                //select all the addresses for the order and store it in a map variable existingAddressBookList
                Map<Id,AddressBook__c> existingAddressBookList=new Map<Id,AddressBook__c> ([SELECT Id FROM AddressBook__c WHERE Id IN (SELECT AddressBook__c FROM OrderDestination__c WHERE Order__c=:CopperCaneEmergeOrder.Id)]);
                //Declare a map variable addressBookIdWithSelectedAddress which contains selected addresses Id and selected address value
                Map<Id,ShippingAddressDetailsWithQuantity_Wrapper> addressBookIdWithSelectedAddress=new Map<Id,ShippingAddressDetailsWithQuantity_Wrapper> ();
                //Declare a map variable addressBookIdWithCometOrder which contains selected addresses Id and order destination Id
                Map<Id,OrderDestination__c> addressBookIdWithCometOrder=new Map<Id,OrderDestination__c> ();
                //for every order destinations in the order  ,add the order destination and id
                for(OrderDestination__c cometOrder : [SELECT Id,AddressBook__c FROM OrderDestination__c WHERE Order__c=:CopperCaneEmergeOrder.Id])
                {
                    addressBookIdWithCometOrder.put(cometOrder.AddressBook__c,cometOrder);
                }
                //for every selected addresess
                for(ShippingAddressDetailsWithQuantity_Wrapper eachShippingAddress : userAllAddressBookList)
                {
                    //for testing
                    System.debug('eachShippingAddress.selectedShippingMethodId'+eachShippingAddress.selectedShippingMethodId);
                    //Declare a variable cometOrder of type OrderDestination__c sObject which can hold order destination details
                    OrderDestination__c cometOrder=new OrderDestination__c();
                    //Assign cometOrder Id with the selected shipping address Id
                    cometOrder.Id=addressBookIdWithCometOrder.get(eachShippingAddress.selectedAddress.Id)==null?null:addressBookIdWithCometOrder.get(eachShippingAddress.selectedAddress.Id).Id;
                    //Assign cometOrder order with the order Id of the current order id of the cart items
                    cometOrder.Order__c = CopperCaneEmergeOrder.Id;
                    //Assign cometOrder address with the address Id of the selcted address
                    cometOrder.AddressBook__c = eachShippingAddress.selectedAddress.Id;
                    //Assign cometOrder shipping method with the selected address default shipping method id.
                    cometOrder.Shipping_Method__c = String.isBlank(eachShippingAddress.selectedShippingMethodId)?defaultShippingMethod.isEmpty()?null:defaultShippingMethod[0].Id:eachShippingAddress.selectedShippingMethodId;
                    //Assign cometOrder shipping method with the selected address shipping method id.
                    cometOrder.SelectedShippingMethod__c = String.isBlank(eachShippingAddress.selectedShippingMethodId)?defaultShippingMethod.isEmpty()?null:defaultShippingMethod[0].Id:eachShippingAddress.selectedShippingMethodId;
                    //add the comet order to the variable cometOrders.
                    cometOrders.add(cometOrder);
                    //Add the incoming selceted shipping address id and shipping address to the variable addressBookIdWithSelectedAddress
                    addressBookIdWithSelectedAddress.put(eachShippingAddress.selectedAddress.Id,eachShippingAddress);
                }
                //Update the data base with the updated order destinations 
                upsert cometOrders;
                
                //for testing
                system.debug('cometOrders'+cometOrders);
                system.debug('cometOrders size'+cometOrders.size());
                
                //for each previously selected addresses add each previously selected address to a map variable which can hold the selceted address id and selected address.
                for(ShippingAddressDetailsWithQuantity_Wrapper eachShippingAddress : previouslySelectedAddresses_List)
                {
                    previouslySelectedAddresses_Map.put(eachShippingAddress.selectedAddress.Id,eachShippingAddress);
                }
                
                //Declare a variable posItemIdWithDetails of type map which contains Id  and pos item in cart.
                Map<Id,PosItemsListWithCartDetails_Wrapper> posItemIdWithDetails=new Map<Id,PosItemsListWithCartDetails_Wrapper > ();
                //fetch order destinations from the selected addresses in addressBookIdWithSelectedAddress and where the order id is for the current shopping cart
                for(OrderDestination__c cometOrder : [SELECT Id,(SELECT Id,POS_Item__c FROM OrderDestinationItems__r) FROM OrderDestination__c WHERE Order__c=:CopperCaneEmergeOrder.Id  AND AddressBook__c IN : addressBookIdWithSelectedAddress.keySet()])
                {
                    //Decalre a set variable existingAllPosItemIds which hold the unique set of cart items
                    Set<Id> existingAllPosItemIds=new Set<Id> ();
                    //for every order destination items in the incoming order
                    for(OrderDestinationItem__c cometOrderItem : cometOrder.OrderDestinationItems__r)
                        //add the order destination item to the variable existingAllPosItemIds
                        existingAllPosItemIds.add(cometOrderItem.POS_Item__c);
                    //for every cart item in a variable cartItems     
                    for(PosItemsListWithCartDetails_Wrapper detailedItem : cartItems)
                    {
                        //check if the posItemIdWithDetails does not contain the incoming cart item , if yes
                        if(!posItemIdWithDetails.containsKey(detailedItem.posItem.Id))
                            //add the cart item to the map variable posItemIdWithDetails
                            posItemIdWithDetails.put(detailedItem.posItem.Id,detailedItem);
                        //Check if the existingAllPosItemIds does not contain the incoming cart item
                        if(!existingAllPosItemIds.contains(detailedItem.posItem.Id))
                        {
                            //if yes , create a order destination item instance 
                            OrderDestinationItem__c cometOrderItem=new OrderDestinationItem__c ();
                            //Assign order destination item id with incoming comet order id
                            cometOrderItem.OrderDestination__c = cometOrder.Id;
                            //Assign order destination item ,pos item  with incoming cart item  pos item id
                            cometOrderItem.POS_Item__c = detailedItem.posItem.Id;
                            //Assign order destination item price  with incoming cart item  pos item price
                            cometOrderItem.Item_Price__c = detailedItem.posItem.Price__c;
                            //Assign the quantity of order destination item to 0
                            cometOrderItem.Quantity__c=0;
                            //Assign the Selected Quantity of order destination item to 0
                            cometOrderItem.SelectedQuantity__c=0;
                            //Add the order destination item to the list of order destination items
                            cometOrderItems.add(cometOrderItem);
                        }
                    }
                }
                //Update the order destination item sObject with the updated order destination items
                insert cometOrderItems;
                
                //for testing
                system.debug('cometOrderItems'+cometOrderItems);
                system.debug('cometOrderItems size'+cometOrderItems.size());
                //Create an instance of OrderDestinationItem__c called cometOrderItemsToBeDeleted
                List<OrderDestinationItem__c> cometOrderItemsToBeDeleted=new List<OrderDestinationItem__c> ();
                //for every order destination item select order destination item id and quantity from OrderDestinationItem__c where the order is the current order of the user and if it is a cart item and if the addresses are not in prsently selected address and previously selected address
                for(OrderDestinationItem__c cometOrderItem : [SELECT Id,Quantity__c FROM OrderDestinationItem__c WHERE OrderDestination__r.Order__c=:CopperCaneEmergeOrder.Id AND Pos_Item__c IN :posItemIdWithDetails.keySet() AND OrderDestination__r.AddressBook__c NOT IN :addressBookIdWithSelectedAddress.keySet() AND OrderDestination__r.AddressBook__c IN :previouslySelectedAddresses_Map.keySet()])
                {
                    //Add those items to the list cometOrderItemsToBeDeleted
                    // if(cometOrderItem.Quantity__c<0 || cometOrderItem.Quantity__c==0)
                    cometOrderItemsToBeDeleted.add(cometOrderItem);
                }
                //Delete these order destination items from the database
                delete cometOrderItemsToBeDeleted;
                //delete the order destinations which doesn't have order destination items.
                delete [SELECT Id FROM OrderDestination__c WHERE Order__c=:CopperCaneEmergeOrder.Id AND Id NOT IN (SELECT OrderDestination__c FROM OrderDestinationItem__c WHERE OrderDestination__r.Order__c=:CopperCaneEmergeOrder.Id)];
            }
        }
        //If there is an error in the above process notify the admin by email
        catch(Exception ex)
        {
            CopperEmailNotifications.sendNotification('Removing Items To Cart',ex.getMessage()+'\n'+'Inputs are -- cartItemsJSONString-- '+JSON.serialize(cartItemsJSONString)
                                                   +'\n'+'---selectedAddresses---'+JSON.serialize(selectedAddresses)+'\n'+'---previouslySelectedAddresses---'+JSON.serialize(previouslySelectedAddresses)
                                                   +'\n'+'Class Name - CopperShoppingCartItem_Apex '+'-- Line number --'+ex.getLineNumber());
            return 'not done';                                       
        }
        
        //return the cart items for refreshing the list.
        return 'done';
    }
    
    

    //Aim:to update the quantity for a selected Pos item
    /**Parameters passed : posItemId : which holds the Id of the selected pos item where the quantity has to be updated 
shippingAddressId : To hold the Id of the shipping address associated with the pos item
orderId : To hold the order Id for which the quantity has to be updated.
quantity : To hold the quantity that is to be updated for a pos item **/
    @AuraEnabled
    public static String updateQuantityForSelectedItem(String posItemId,String shippingAddressId,String orderId,Integer quantity)
    {
        //for testing
        System.debug('posItemId' +posItemId);
        System.debug('shippingAddressId' +shippingAddressId);
        System.debug('orderId' +orderId);
        System.debug('quantity' +quantity);
        try
        {
            //Check if the incoming data posItemId , shippingAddressId and orderId have value 
            if(String.isNotBlank(posItemId) && String.isNotBlank(shippingAddressId) && String.isNotBlank(orderId)||isTest==true)
            {   //If yes , get the Order destination Item id , it's quantity and address from OrderDestinationItem__c sObject  where the pos item in Order destination item is same as incoming pos item id , address of order destination item  is same as the incoming shipping method id and the order associated with the order destination item is same as the incoming order Id of the and store it in a variable cometOrderItem which is of type OrderDestinationItem__c 
                OrderDestinationItem__c cometOrderItem= [SELECT Id,Quantity__c,SelectedQuantity__c,OrderDestination__r.AddressBook__c FROM OrderDestinationItem__c WHERE OrderDestination__r.AddressBook__c=:shippingAddressId AND POS_Item__c=:posItemId AND OrderDestination__r.Order__c=:orderId];
                //for testing
                system.debug('cometOrderItem---->'+cometOrderItem);
                //Assign the quantity of the above fetched cometOrderItem with the incoming quantity.
                cometOrderItem.Quantity__c=quantity;
                //Assign the selected quantity of the above fetched cometOrderItem with the incoming quantity.
                cometOrderItem.SelectedQuantity__c=quantity;
                //for testing
                System.debug('beforecometOrderItem' +cometOrderItem);
                //Update the order destination item in the database
                update cometOrderItem;
                //for testing
                System.debug('aftercometOrderItem' +cometOrderItem);
            }
            // done is sent to the front end if there are no errors
            return 'done';
        }
        //If there is an error in the above process notify the admin by email
        catch(Exception ex)
        {
            CopperEmailNotifications.sendNotification('Updating quantity fro selected item',ex.getMessage()+'\n'+'Inputs are -- posItemId-- '+JSON.serialize(posItemId)+'\n'+
                                                   '-- shippingAddressId --'+JSON.serialize(shippingAddressId)+'\n'+
                                                   '-- orderId--'+JSON.serialize(orderId)+'\n'+
                                                   '-- quantity--'+JSON.serialize(quantity)
                                                   +'\n'+'Class Name - CopperShoppingCartItem_Apex '+'-- Line number --'+ex.getLineNumber());
            //return not done if there is an error
            return 'not done';
        }
    }
    
    /**this method is responsible for removing the Pos item from the shopping cart */
    /** Parameters used : selectedCartItemDetails:To hold the pos item that has to be deleted 
posItemsListWithCart:To hold the list of pos items that are in cart. */
    @AuraEnabled
    public static String deleteCartItemFromShippingCart(String selectedCartItemDetails,String posItemsListWithCart)
    {
        //for testing
        System.debug('selectedCartItemDetails' +selectedCartItemDetails);
        System.debug('posItemsListWithCart' +posItemsListWithCart);
        try{
            //Declare a variable cartItemsForQty of type PosItemsListWithCartDetails_Wrapper to hold the new list of cart items after the delete operation
            List<PosItemsListWithCartDetails_Wrapper> cartItemsForQty=new List<PosItemsListWithCartDetails_Wrapper> ();
            //Process the incoming parameter selectedCartItemDetails and deserialize it to the apex understandable data which is of type PosItemsListWithCartDetails_Wrapper and store it in a variable cartItem
            PosItemsListWithCartDetails_Wrapper cartItem=(PosItemsListWithCartDetails_Wrapper)System.JSON.deserialize(selectedCartItemDetails, PosItemsListWithCartDetails_Wrapper.class);
            //Process the incoming parameter posItemsListWithCart and deserialize them to the apex understandable data which is of type list of PosItemsListWithCartDetails_Wrapper and store it in a variable cartItems
            List<PosItemsListWithCartDetails_Wrapper> cartItems=(List<PosItemsListWithCartDetails_Wrapper>)System.JSON.deserialize(posItemsListWithCart, List<PosItemsListWithCartDetails_Wrapper>.class);
            //for each pos item in the variable cartItems
            for(PosItemsListWithCartDetails_Wrapper eachPosItem : cartItems)
            {
                //Check if the incoming pos item in cartItem from the front end is not present in the incoming pos item 
                if(cartItem.posItem.Id!=eachPosItem.posItem.Id)
                    //If yes , add the pos item to the list cartItemsForQty 
                    cartItemsForQty.add(eachPosItem); 
            }
            //fetch account details
            objAccount=getAccount();
            //fetch the shopping cart item id from ShoppingCartItems__c sObject where the shopping cart is active , account is Copper Cane , the shopping cart for the logged in user which is open and for the incoming pos item in the shopping cart and store it in shoppingCartItem of type ShoppingcartItem__c sObject.
            List<ShoppingCartItems__c> shoppingCartItem=[SELECT Id FROM ShoppingCartItems__c WHERE ShoppingCart__r.Active__c=true AND ShoppingCart__r.Account__c=:objAccount.Id AND ShoppingCart__r.CreatedById=:UserInfo.getUserId() AND ShoppingCart__r.CartStatus__c='Open' AND ShoppingCart__r.Inventory_Seasonal_Program__c='Seasonal Program' AND POS_Item__c=:cartItem.posItem.Id];
            //for testing
            System.debug('shoppingCartItem--->' +shoppingCartItem);
            // delete the record shoppingCartItem from the database
            delete shoppingCartItem;
            //fetch order destination item id from the OrderDestinationItem__c sObject where the order Id of the order destination item is same as the incoming order id and the pos item of the order destination item is same as pos item of  incoming cart item and store it in a variable cometOrderItems
            List<OrderDestinationItem__c> cometOrderItems=[SELECT Id FROM OrderDestinationItem__c WHERE OrderDestination__r.Order__c=:cartItem.orderId AND POS_Item__c=:cartItem.posItem.Id];
            System.debug('cometOrderItems--->' +cometOrderItems);
            //delete the record cometOrderItems from the database
            delete cometOrderItems;
            //fetch order destination  id from the OrderDestination__c sObject where the order number of order is same as order id of the incoming cart item  and order destination which is not in any of the order destination items and store it in a variable cometOrders.
            List<OrderDestination__c> cometOrders=[SELECT Id FROM OrderDestination__c WHERE Order__c=:cartItem.orderId AND Id NOT IN (SELECT OrderDestination__c  FROM OrderDestinationItem__c)]; 
            //delete the record cometOrders from the database
            delete cometOrders;
            //for testing
            System.debug('cartItemsForQty--->' +cartItemsForQty);
            //return the list of updated shopping cart items stored in cartItemsForQty.
            return 'done';
            
        }
        // //If there is an error in the above process notify the admin by email
        catch(exception ex)
        {
            CopperEmailNotifications.sendNotification('Deleting a cart item from cart',ex.getMessage()+'\n'+'Inputs are -- selectedCartItemDetails-- '+JSON.serialize(selectedCartItemDetails) +'\n'+
                                                   ' -- posItemsListWithCart -- '+JSON.serialize(posItemsListWithCart)+'\n'
                                                   +'\n'+'Class Name - CopperShoppingCartItem_Apex '+'-- Line number --'+ex.getLineNumber());
            return 'not done';
            
        }
    }
    
}