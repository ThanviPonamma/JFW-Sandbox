@isTest
public class InfiniumInventoryShoppingCart_ApexTest {
    
    @isTest
    
    private static void addressBookTestMethod ()
        
    {
        Brand__c testBrand=[SELECT Id FROM Brand__c LIMIT 1];
        Item_Type__c testItemtype=[SELECT Id FROM Item_Type__c LIMIT 1];
        List<POS_Item__c> testPosItems=[SELECT Id FROM POS_Item__c];
        List<AddressBook__c> addressBookList=[SELECT Id FROM AddressBook__c];
        Order__c order=[SELECT Id FROM Order__c LIMIT 1];
        Test.startTest();
        
        InfiniumInventoryShoppingCart_Apex.getAccount();
        InfiniumInventoryShoppingCart_Apex.getUserDetails();
        InfiniumInventoryPosItemToCart_Apex.addInventoryPosItemToCart(testPosItems[0].Id);
        InfiniumInventoryPosItemToCart_Apex.addInventoryPosItemToCart(testPosItems[1].Id);
        List<InfiniumInventoryShoppingCart_Apex.PosItemsListWithCartDetails_Wrapper> posItemDetailsList = InfiniumInventoryShoppingCart_Apex.getCartItemsList();
        InfiniumInventoryShoppingCart_Apex.getSelectedUserAddressBookListForAllItems(JSON.serialize(posItemDetailsList));
        InfiniumInventoryShoppingCart_Apex.getSelectedAddressesForPosItem(JSON.serialize(posItemDetailsList[1]));
        InfiniumInventoryShoppingCart_Apex.ShippingAddressDetailsWithPagination_Wrapper shippingAddressesWithPagination = InfiniumInventoryShoppingCart_Apex.getUserAddressBookList(JSON.serialize(posItemDetailsList),'DOMESTIC',1);
        InfiniumInventoryShoppingCart_Apex.ShippingAddressDetailsWithPagination_Wrapper shippingAddressWithPagination = InfiniumInventoryShoppingCart_Apex.getPosItemUserAddressBookList(JSON.serialize(posItemDetailsList[1]),'DOMESTIC',1);
        InfiniumInventoryShoppingCart_Apex.getShippingMethodList();
        
        InfiniumInventoryShoppingCart_Apex.saveAddressForAllOrderedItems(JSON.serialize(posItemDetailsList),
                                                                       JSON.serialize(shippingAddressesWithPagination.allAddresses),
                                                                       JSON.serialize(shippingAddressesWithPagination.allAddresses) );
        List<InfiniumInventoryShoppingCart_Apex.PosItemsListWithCartDetails_Wrapper> cartItemsJSONString = InfiniumInventoryShoppingCart_Apex.getCartItemsList();
        
        InfiniumInventoryShoppingCart_Apex.saveAddressForSelectedItem(JSON.serialize(cartItemsJSONString),
                                                                    JSON.serialize(shippingAddressWithPagination.allAddresses));
        InfiniumInventoryShoppingCart_Apex.updateQuantityForSelectedItem(testPosItems[1].Id,addressBookList[0].Id,cartItemsJSONString[0].orderId,10);
        InfiniumInventoryShoppingCart_Apex.getSelectedUserAddressBookListForAllItems(JSON.serialize(posItemDetailsList));
        InfiniumInventoryShoppingCart_Apex.getSelectedAddressesForPosItem(JSON.serialize(posItemDetailsList[1]));
        InfiniumInventoryShoppingCart_Apex.ShippingAddressDetailsWithPagination_Wrapper shippingAddressesWithPaginationDetails = InfiniumInventoryShoppingCart_Apex.getUserAddressBookList(JSON.serialize(posItemDetailsList),'INTERNATIONAL',1);
        InfiniumInventoryShoppingCart_Apex.getPosItemUserAddressBookList(JSON.serialize(posItemDetailsList[1]),'INTERNATIONAL',1);
        InfiniumInventoryShoppingCart_Apex.deleteCartItemFromShippingCart(JSON.serialize(posItemDetailsList[1]),JSON.serialize(posItemDetailsList));
        //exception
        InfiniumInventoryShoppingCart_Apex.saveAddressForAllOrderedItems(null,null,null);
        InfiniumInventoryShoppingCart_Apex.saveAddressForSelectedItem(null,null);
        InfiniumInventoryShoppingCart_Apex.deleteCartItemFromShippingCart(null,null);
        InfiniumInventoryShoppingCart_Apex.updateQuantityForSelectedItem(null,null,null,null);
        Test.stopTest();
        
        
        
    }
    
    @testSetup static void setupData() {
        
        List<Account> testAccts = new List<Account>();
        Account acct = new Account(Name='Infinium Spirits');
        insert acct ;
        Contact contact=new Contact(LastName='Testing',AccountId=acct.Id);
        insert contact;
        Daily_Inventory_Creation__c customSetting=new Daily_Inventory_Creation__c(Trigger_Active_Flag__c=false,Name='Trigger flag');
        insert customSetting;
        Profile profile=[SELECT Name FROM Profile WHERE Name='Customer Community Plus User' LIMIT 1];
        
        User communityUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                      LocaleSidKey='en_US', ProfileId = profile.Id, 
                                      TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com',ContactId=contact.Id,
                                      International_Address_Accessible__c=true);
        
        insert communityUser;
        List<Country__c> countryList = new List<Country__c>();
        Country__c countryUSA=new Country__c(Active__c=true , Country_Code__c='countryCode' , Country_Name__c='USA');
        insert countryUSA;
        Country__c countryInternational=new Country__c(Active__c=true , Country_Code__c='CA' , Country_Name__c='Canada',Is_It_International_Country__c=true);
        insert countryInternational;
        List<State__c> stateList = new List<State__c>();
        State__c state = new State__c(State_Name__c='testState', Active__c = true, Country__c=countryUSA.id ,State_Code__c='stateCode');
        insert state ;
        State__c stateInternational= new State__c(State_Name__c='testState', Active__c = true, Country__c=countryInternational.id ,State_Code__c='LA');
        insert stateInternational ;
        Territory__c territory = new Territory__c (Territory_Name__c='testTerritory',Active__c=true,Account__c=acct.Id);
        insert territory;
        States_Territory__c stateTerritory = new States_Territory__c (State__c = state.Id,Territory__c= territory.Id);
        insert stateTerritory;
        Users_Territory__c usersTerritory = new Users_Territory__c (Territory__c= territory.Id,User__c=UserInfo.getUserId());
        insert usersTerritory;
        Infinium_Spirits_Email_Notifications__c InfiniumSpiritsCustomSetting=new Infinium_Spirits_Email_Notifications__c(Name='Infinium Spirits',Cc_Addresses_List__c='vanditha@uxltechnologies.net');
        insert InfiniumSpiritsCustomSetting;
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
        
        
        ShoppingCart__c shoppingCart = new ShoppingCart__c(Account__c = acct.Id, CartStatus__c = 'open');
        insert shoppingCart;
        
        ShoppingCartItems__c shoppingCartItem = new ShoppingCartItems__c(ShoppingCart__c = shoppingCart.Id , POS_Item__c = posItem.Id);
        insert shoppingCartItem;
        
        Shipping_Method__c shippingMethod = new Shipping_Method__c(Account__c=acct.Id , Active__c=true , Default__c=true, ApprovalRequired__c=true , Shipping_Method_Name__c='shippingMethod1');
        insert shippingMethod;
        
        Shipping_Method__c shippingMethod2 = new Shipping_Method__c(Account__c=acct.Id , Active__c=true , ApprovalRequired__c=false , Default__c=true , Shipping_Method_Name__c='shippingMethod2', DisplayOrder__c = 1);
        insert shippingMethod2;
        
        
        AddressBook__c addressBook = new AddressBook__c(Account__c=acct.Id , Destination_Name__c='destinationName' , 
                                                        Shipto_Company__c='shipToCompany', State__c=state.Id) ;
        insert addressBook;
        
        Order__c order = new Order__c(Account__c = acct.Id, Order_Date__c = system.today(), Order_Status__c = 'open');
        insert order;
        
        OrderDestination__c orderDestination = new OrderDestination__c(Order__c = order.Id, AddressBook__c =addressBook.Id, OrderDest_Status__c='open',Comet_Order_Status__c='open',Shipping_Method__c=shippingMethod.Id);
        insert orderDestination;
        
        OrderDestinationItem__c orderDestinationItems = new OrderDestinationItem__c(OrderDestination__c =orderDestination.Id, POS_Item__c = posItem.Id, Quantity__c = 1);
        insert orderDestinationItems;
        
        POSItem_States__c posItemStates = new POSItem_States__c(POS_Item__c=posItem.Id,State__c=state.Id);
        insert posItemStates;
        
    }
}