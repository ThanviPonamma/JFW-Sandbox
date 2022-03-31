@isTest
public class DFVInventoryOrderControllerTest {
    
    @isTest
    private static void addToCartFunctionalityTestMethod ()
    {
        Account testAccount=[SELECT Id FROM Account LIMIT 1];
        Brand__c testBrand=[SELECT Id FROM Brand__c LIMIT 1];
        Item_Type__c testItemtype=[SELECT Id FROM Item_Type__c LIMIT 1];
        List<POS_Item__c> testPosItems=[SELECT Id FROM POS_Item__c];
        
        Test.startTest();
        DFVInventoryOrderController.createInventoryShoppingCart_Apex();
        List<Brand__c> brandList= DFVInventoryOrderController.loadBrandsList();
        List<Item_Type__c> itemTypeList=DFVInventoryOrderController.loadItemTypesList();
        List<Shipping_Method__c> shippingMethodList=DFVInventoryOrderController.loadShippingMethodList();
        //List<DFVInventoryOrderController.PosItemsListWithCartDetails> posItemsWithCart=DFVInventoryOrderController.loadPosItemsList(); 
        DFVInventoryOrderController.PosItem_DetailsListWrapper posItemsWithCartSearch1=DFVInventoryOrderController.loadPosItemsQueryList('Test-No-01','','','LAST_N_DAYS',0);
        DFVInventoryOrderController.PosItem_DetailsListWrapper posItemsWithCartSearch2=DFVInventoryOrderController.loadPosItemsQueryList('Test-No-02','','Brand__r.Brand_Name__c','',1);
        List<DFVInventoryOrderController.PosItemsListWithCartDetails> posItemsWithCart_ADDEDItems=DFVInventoryOrderController.addItemToCart(testPosItems[0].Id);
        List<DFVInventoryOrderController.PosItemsListWithCartDetails> posItemsWithCart_ADDEDItems2=DFVInventoryOrderController.addItemToCart(testPosItems[1].Id);
        DFVInventoryOrderController.PosItem_DetailsListWrapper posItemsWithCartSearch3=DFVInventoryOrderController.loadPosItemsQueryList('Test-No-04','testBrand.Id','testItemtype.Id','RECENT_ADDED_CARTITEMS',5);
        //DFVInventoryOrderController.loadPosItemsList();
        DFVInventoryOrderController.removeItemFromCart(testPosItems[0].Id);
        DFVInventoryOrderController.addItemsToCart(JSON.serialize(posItemsWithCart_ADDEDItems));
        Test.stopTest();
    }
    
    
    @isTest
    private static void addressBookTestMethod ()
    {
        Brand__c testBrand=[SELECT Id FROM Brand__c LIMIT 1];
        Item_Type__c testItemtype=[SELECT Id FROM Item_Type__c LIMIT 1];
        List<POS_Item__c> testPosItems=[SELECT Id FROM POS_Item__c];
        List<AddressBook__c> addressBookList=[SELECT Id FROM AddressBook__c];
        
        Test.startTest();
        DFVInventoryOrderController.getCurrentUserSessionIdApex();
        DFVInventoryOrderController.currentUser();
        DFVInventoryOrderController.createInventoryShoppingCart_Apex();
        DFVInventoryOrderController.PosItem_DetailsListWrapper posItems=DFVInventoryOrderController.loadPosItemsQueryList('Test',testBrand.Id,testItemtype.Id,'LAST_N_DAYS',0);
        //DFVInventoryOrderController.PosItem_DetailsListWrapper posItemsWithCart = DFVInventoryOrderController.loadPosItemsQueryList('Test-No-02','','Brand__r.Brand_Name__c','',1);
        DFVInventoryOrderController.loadPosItemsQueryList('','','','',0);
        List<DFVInventoryOrderController.PosItemsListWithCartDetails> posItemDetails = DFVInventoryOrderController.loadCartItemsList();
        List<DFVInventoryOrderController.PosItemsListWithCartDetails> posItemsWithCart1=DFVInventoryOrderController.addItemToCart(testPosItems[1].Id);
        //List<DFVInventoryOrderController.PosItemsListWithCartDetails> posItemsWithCart2 = DFVInventoryOrderController.addItemToCart(testPosItems[1].Id);
        system.debug('posItemsWithCart1---->'+posItemsWithCart1);
        //THE Code below is commented as the search function is happening from the front end.
        //List<DFVInventoryOrderController.ShippingAddressDetailsWithQuantity> ShippingAddressList3=DFVInventoryOrderController.searchAddressesResult('','','');
        //List<DFVInventoryOrderController.ShippingAddressDetailsWithQuantity> ShippingAddressList4=DFVInventoryOrderController.searchAddressesResult('destinationName2',JSON.serialize(ShippingAddressList3),'DOMESTIC');
        //List<DFVInventoryOrderController.ShippingAddressDetailsWithQuantity> ShippingAddressList5=DFVInventoryOrderController.searchAddressesResult('destinationName',JSON.serialize(ShippingAddressList3),'DOMESTIC');
        DFVInventoryOrderController.ShippingAddressDetailsWithPagination shippingAddressesWithPagination = DFVInventoryOrderController.loadUserAddressBookList(JSON.serialize(posItemsWithCart1[0].selectedAddressWithQtyDetails),JSON.serialize(posItemsWithCart1),'DOMESTIC', 1);
        DFVInventoryOrderController.loadUserAddressBookList(JSON.serialize(posItemsWithCart1[0].selectedAddressWithQtyDetails),JSON.serialize(posItemsWithCart1),'DOMESTIC', 1);
        DFVInventoryOrderController.ShippingAddressDetailsWithPagination shippingAddressesWithPagination1 = DFVInventoryOrderController.loadPosItemUserAddressBookList(JSON.serialize(posItemsWithCart1[0].selectedAddressWithQtyDetails),JSON.serialize(posItemsWithCart1[0]),'DOMESTIC', 1);
        DFVInventoryOrderController.loadPosItemUserAddressBookList(JSON.serialize(posItemsWithCart1[0].selectedAddressWithQtyDetails),JSON.serialize(posItemsWithCart1[0]),'DOMESTIC', 1);
        
        //
        List<DFVInventoryOrderController.PosItemsListWithCartDetails> posItemsWithCart=DFVInventoryOrderController.addItemToCart(testPosItems[1].Id);
        system.debug('shippingAddressesWithPagination---->'+shippingAddressesWithPagination);
        
        DFVInventoryOrderController.saveOrderForAllItems(JSON.serialize(posItemsWithCart),
                                                         JSON.serialize(shippingAddressesWithPagination.allAddresses),
                                                         JSON.serialize(shippingAddressesWithPagination.allAddresses) );
        DFVInventoryOrderController.saveOrderForSelectedItem(JSON.serialize(posItemsWithCart),
                                                             JSON.serialize(shippingAddressesWithPagination.allAddresses));
        
        List<DFVInventoryOrderController.PosItemsListWithCartDetails> posItemDetailsList = DFVInventoryOrderController.loadCartItemsList();
        system.debug('posItemDetailsList---->'+posItemDetailsList);

        
        Order__c order=[SELECT Id FROM Order__c LIMIT 1];
        //DFVInventoryOrderController.loadAllInventoryOrders('destinationName2',false);
        //DFVInventoryOrderController.loadAllInventoryOrders('destinationName2',true);
        system.debug('testPosItems---->'+testPosItems[1].Id);
        system.debug('addressBookList---->'+addressBookList[0].Id);
        system.debug('posItemDetailsList---->'+posItemDetailsList[0].orderId);

        DFVInventoryOrderController.updateQuantityForSelectedItem_Apex(testPosItems[1].Id,addressBookList[0].Id,posItemDetailsList[0].orderId,10);

        //DFVInventoryOrderController.confirmOrder(JSON.serialize(posItemDetailsList[0]));
        DFVInventoryOrderController.deleteCartItemFromShippingCart( JSON.serialize(posItemsWithCart), JSON.serialize(posItemsWithCart));
        DFVInventoryOrderController.ShippingAddressDetails test2=new DFVInventoryOrderController.ShippingAddressDetails(true,null,null,null);
        DFVInventoryOrderController.loadAllInventoryOrders('shipToCompany2',true);
        //exception
        DFVInventoryOrderController.updateQuantityForSelectedItem_Apex(null,null,null,null);
        Test.stopTest();
    }
    
    
    @testSetup static void setupData() {
        List<Account> testAccts = new List<Account>();
        Account acct = new Account(Name='DFV');
        insert acct ;
        Contact contact=new Contact(LastName='Testing',AccountId=acct.Id);
        insert contact;
        Daily_Inventory_Creation__c customSetting=new Daily_Inventory_Creation__c(Trigger_Active_Flag__c=false,Name='Trigger flag');
        insert customSetting;
        Profile profile=[SELECT Name FROM Profile WHERE Name='Customer Community Plus User' LIMIT 1];
        
        User communityUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                      LocaleSidKey='en_US', ProfileId = profile.Id, 
                                      TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com',ContactId=contact.Id);
        
        insert communityUser;
        
        Country__c country=new Country__c(Active__c=true , Country_Code__c='countryCode' , Country_Name__c='countryName');
        insert country;
        
        State__c state = new State__c(State_Name__c='testState', Active__c = true, Country__c=country.id ,State_Code__c='stateCode');
        insert state ;
        Territory__c territory = new Territory__c (Territory_Name__c='testTerritory',Active__c=true,Account__c=acct.Id);
        insert territory;
        States_Territory__c stateTerritory = new States_Territory__c (State__c = state.Id,Territory__c= territory.Id);
        insert stateTerritory;
        Users_Territory__c usersTerritory = new Users_Territory__c (Territory__c= territory.Id,User__c=UserInfo.getUserId());
        insert usersTerritory;
        DFV_Email_Notifications__c DFVCustomSetting=new DFV_Email_Notifications__c(Name='DFV',Cc_Addresses_List__c='Pradeep@uxltechnologies.net');
        insert DFVCustomSetting;
        Brand__c brand = new Brand__c (Brand_Name__c='BrandNameSelect',Active__c=true,Account__c=acct.Id);
        insert brand;
        
        Item_Type__c itemType= new Item_Type__c(Item_Type__c='itemTypeSelect',Active__c=true,Account__c=acct.Id);
        insert itemType;
        POS_Item__c posItem= new POS_Item__c (Item_No__c='Test-No-01',Item_Name__c='testPosItemName',Available_Stock__c=10,
                                              Account__c=acct.Id,Brand__c=brand.Id,Type_of_Item__c=itemType.Id,Active__c=true);
        insert posItem;
        
        POS_Item__c posItem2= new POS_Item__c (Item_No__c='Test-No-02',Item_Name__c='testPosItemName',Available_Stock__c=10,
                                               Account__c=acct.Id,Brand__c=brand.Id,Type_of_Item__c=itemType.Id,Active__c=true);
        insert posItem2;
        
        
        //ShoppingCart__c shoppingCart = new ShoppingCart__c(Account__c = acct.Id, CartStatus__c = 'open');
        //insert shoppingCart;
        
        //ShoppingCartItems__c shoppingCartItems = new ShoppingCartItems__c(ShoppingCart__c = shoppingCart.Id , POS_Item__c = posItem.Id);
        //insert shoppingCartItems;
        
        Shipping_Method__c shippingMethod = new Shipping_Method__c(Account__c=acct.Id , Active__c=true , Default__c=true, ApprovalRequired__c=true , Shipping_Method_Name__c='shippingMethod1');
        insert shippingMethod;
        
        Shipping_Method__c shippingMethod2 = new Shipping_Method__c(Account__c=acct.Id , Active__c=true , ApprovalRequired__c=false , Default__c=true , Shipping_Method_Name__c='shippingMethod2', DisplayOrder__c = 1);
        insert shippingMethod2;
        
        
        AddressBook__c addressBook = new AddressBook__c(Account__c=acct.Id , Destination_Name__c='destinationName' , 
                                                        Shipto_Company__c='shipToCompany', State__c=state.Id) ;
        insert addressBook;
        
        AddressBook__c addressBook2 = new AddressBook__c(Account__c=acct.Id , Destination_Name__c='destinationName2' , 
                                                         Shipto_Company__c='shipToCompany2', State__c=state.Id) ;
        insert addressBook2;
        
         
        Order__c order = new Order__c(Account__c = acct.Id, Order_Date__c = system.today() , Order_Status__c = 'open');
        insert order;
        
         //shoppingCart.DFV_Order_Number__c = order.Id;
         //update shoppingCart;
        
        
        OrderDestination__c orderDestination = new OrderDestination__c(Order__c = order.Id, AddressBook__c =addressBook.Id, OrderDest_Status__c='open',Comet_Order_Status__c='open',Shipping_Method__c=shippingMethod.Id);
        insert orderDestination;
        
        OrderDestinationItem__c orderDestinationItems = new OrderDestinationItem__c(OrderDestination__c =orderDestination.Id, POS_Item__c = posItem.Id, Quantity__c = 1);
        insert orderDestinationItems;
    }
}