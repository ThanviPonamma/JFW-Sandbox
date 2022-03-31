@isTest
public class InfiniumShoppingCartItem_ApexTest {
    @isTest
    private static void shoppingCartCmpTest(){
        Account acct = new Account(Name='Infinium Spirits');
        insert acct ;
        Contact contact=new Contact(LastName='Testing',AccountId=acct.Id);
        insert contact;
        Profile profile=[SELECT Name FROM Profile WHERE Name='Customer Community Plus User' LIMIT 1];
        Schema.User communityUser = new Schema.User(Alias = 'standt', Email='standarduser@testorg.com', 
                                                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                                    LocaleSidKey='en_US', ProfileId = profile.Id, 
                                                    TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com',ContactId=contact.Id);
        
        insert communityUser;
        
        
        
        Program__c program = new Program__c(Account__c=acct.Id,Name__c='test',Closing_Date__c= date.newInstance(2023, 12, 15),Start_Date__c=date.newInstance(2014, 12, 15),In_Market_Date__c=date.newInstance(2024, 12, 15),Attachment_Id__c='00P0v0000063gnqEAA');
        insert program;
        
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
        Infinium_Spirits_Email_Notifications__c InfiniumSpiritsCustomSetting=new Infinium_Spirits_Email_Notifications__c(Name='InfiniumSpirits',Cc_Addresses_List__c='vanditha@uxltechnologies.net');
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
        
        
        ShoppingCart__c shoppingCart = new ShoppingCart__c(Account__c = acct.Id, CartStatus__c = 'open',Program__c=program.Id,Inventory_Seasonal_Program__c='Seasonal Program');
        insert shoppingCart;
        

        ShoppingCartItems__c shoppingCartItem = new ShoppingCartItems__c(ShoppingCart__c = shoppingCart.Id , POS_Item__c = posItem.Id);
        insert shoppingCartItem;
        
        ShoppingCartItems__c shoppingCartItem1 = new ShoppingCartItems__c(ShoppingCart__c = shoppingCart.Id , POS_Item__c = posItem2.Id);
        insert shoppingCartItem1;
        
        List<ShoppingCartItems__c> shoppingCartItem2 = new List<ShoppingCartItems__c>();
        shoppingCartItem2.Add(shoppingCartItem);
        shoppingCartItem2.Add(shoppingCartItem1);
        
        Shipping_Method__c shippingMethod = new Shipping_Method__c(Account__c=acct.Id , Active__c=true , Default__c=true, ApprovalRequired__c=true , Shipping_Method_Name__c='shippingMethod1');
        insert shippingMethod;
        
        Shipping_Method__c shippingMethod2 = new Shipping_Method__c(Account__c=acct.Id , Active__c=true , ApprovalRequired__c=false , Default__c=true , Shipping_Method_Name__c='shippingMethod2', DisplayOrder__c = 1);
        insert shippingMethod2;
        
        
        AddressBook__c addressBook = new AddressBook__c(Account__c=acct.Id , Destination_Name__c='destinationName', 
                                                        Shipto_Company__c='shipToCompany', State__c=state.Id);
        insert addressBook;
        
        Order__c order = new Order__c(Account__c = acct.Id, Order_Date__c = system.today(), Order_Status__c = 'open');
        insert order;
        
        shoppingCart.Infinium_Spirits_Order_Number__c=order.Id;
        update shoppingCart;
        
        OrderDestination__c orderDestination = new OrderDestination__c(Order__c = order.Id, AddressBook__c =addressBook.Id, OrderDest_Status__c='open',Comet_Order_Status__c='open',Shipping_Method__c=shippingMethod.Id);
        insert orderDestination;
        
        OrderDestinationItem__c orderDestinationItems = new OrderDestinationItem__c(OrderDestination__c =orderDestination.Id, POS_Item__c = posItem.Id, Quantity__c = 1);
        insert orderDestinationItems;
        
        POSItem_States__c posItemStates = new POSItem_States__c(POS_Item__c=posItem.Id,State__c=state.Id);
        insert posItemStates;
        Test.startTest();
        InfiniumShoppingCartItem_Apex.getUserDetails_Apex();
        InfiniumShoppingCartItem_Apex.getAccount();
        List<InfiniumShoppingCartItem_Apex.PosItemsListWithCartDetails_Wrapper> posItemWithListWithCartWrapper = InfiniumShoppingCartItem_Apex.getCartItemsList_Apex(program.Id);
        InfiniumShoppingCartItem_Apex.getSelectedUserAddressBookListForAllItems_Apex(JSON.serialize(posItemWithListWithCartWrapper));
        InfiniumShoppingCartItem_Apex.ShippingAddressDetailsWithPagination_Wrapper shippingAddressesWithPagination = InfiniumShoppingCartItem_Apex.getUserAddressBookList(JSON.serialize(posItemWithListWithCartWrapper),'DOMESTIC',1);
        InfiniumShoppingCartItem_Apex.ShippingAddressDetailsWithPagination_Wrapper shippingAddressesWithPagination1 = InfiniumShoppingCartItem_Apex.getUserAddressBookList(JSON.serialize(posItemWithListWithCartWrapper),'INTERNATIONAL',1);
        InfiniumShoppingCartItem_Apex.ShippingAddressDetailsWithPagination_Wrapper shippingAddressWithPagination = InfiniumShoppingCartItem_Apex.getPosItemUserAddressBookList(JSON.serialize(new ShoppingCartItems__c(ShoppingCart__c = shoppingCart.Id , POS_Item__c = posItem.Id)),'DOMESTIC',1);
        InfiniumShoppingCartItem_Apex.ShippingAddressDetailsWithPagination_Wrapper shippingAddressWithPagination1 = InfiniumShoppingCartItem_Apex.getPosItemUserAddressBookList(JSON.serialize(new ShoppingCartItems__c(ShoppingCart__c = shoppingCart.Id , POS_Item__c = posItem.Id)),'INTERNATIONAL',1);
        InfiniumShoppingCartItem_Apex.saveAddressForAllOrderedItems(JSON.serialize(posItemWithListWithCartWrapper),
                                                                    JSON.serialize(shippingAddressesWithPagination.allAddresses),
                                                                    JSON.serialize(shippingAddressesWithPagination.allAddresses),program.Id);
        InfiniumShoppingCartItem_Apex.saveAddressForAllOrderedItems(JSON.serialize(new ShoppingCartItems__c(ShoppingCart__c = shoppingCart.Id , POS_Item__c = posItem.Id)),
                                                                    JSON.serialize(shippingAddressesWithPagination.allAddresses),
                                                                    JSON.serialize(shippingAddressesWithPagination.allAddresses),program.Id);
        InfiniumShoppingCartItem_Apex.updateQuantityForSelectedItem_Apex(posItem.Id,addressBook.Id,order.Id,10);
        InfiniumShoppingCartItem_Apex.deleteCartItemFromShippingCart_Apex(JSON.serialize(new ShoppingCartItems__c(ShoppingCart__c = shoppingCart.Id , POS_Item__c = posItem.Id)),JSON.serialize(shoppingCartItem2));
        
        //exceptions
        InfiniumShoppingCartItem_Apex.saveAddressForAllOrderedItems(null,null,null,null);
        InfiniumShoppingCartItem_Apex.getCartItemsList_Apex(null);
        InfiniumShoppingCartItem_Apex.deleteCartItemFromShippingCart_Apex('','');
        InfiniumShoppingCartItem_Apex.updateQuantityForSelectedItem_Apex(null,null,null,null);
        Test.stopTest();
    }
}