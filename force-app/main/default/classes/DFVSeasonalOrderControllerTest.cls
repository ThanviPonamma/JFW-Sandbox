@isTest
public class DFVSeasonalOrderControllerTest{
    
    @isTest
    private static void posItemMenuCmpTest()
    {
        Test.startTest();
        List<DFVSeasonalOrderController.Program_ChairBudget_Details> programDetails=DFVSeasonalOrderController.getProgram_ChairBudgetList_Apex();
        
        List<Brand__c> brands=DFVSeasonalOrderController.getBrands_Apex();
        List<Item_Type__c> itemTypes=DFVSeasonalOrderController.getItemTypes_Apex();
        
        DFVSeasonalOrderController.PosItem_DetailsListWrapper posItems=DFVSeasonalOrderController.getPosItems_Apex('Test',brands[0].Id,itemTypes[0].Id,'LAST_N_DAYS',programDetails[0].program_chairBudget.Program__c,0);
        Program__c prog = [SELECT Id FROM Program__c];
        List<Program_Item__c> prgItem = [SELECT Id FROM Program_Item__c];
        DFVSeasonalOrderController.addPosItemToCart_Apex('','','','',prog.Id,0,prgItem[0].Id);
        // System.debug('posItems---------->'+posItemsTest);
        Delete [SELECT Id FROM ShoppingCart__c];
        DFVSeasonalOrderController.getPosItems_Apex('','','','',programDetails[0].program_chairBudget.Program__c,0);
        DFVSeasonalOrderController.createSeasonalShoppingCart_Apex(programDetails[0].program_chairBudget.Program__c);
        DFVSeasonalOrderController.addPosItemToCart_Apex('','','','',prog.Id,0,prgItem[0].Id);
        DFVSeasonalOrderController.removePosItemFromCart_Apex('','','','Item_Name__c',prog.Id,0,prgItem[0].Id);
        ShoppingCart__c shippingCart=DFVSeasonalOrderController.createSeasonalShoppingCart_Apex(prog.Id);
        DFVSeasonalOrderController.addAllPosItemsToCart_Apex('','','',shippingCart.Id,'',prog.Id);
        DFVSeasonalOrderController.addAllPosItemsToCart_Apex('Test','','',shippingCart.Id,'',prog.Id);
        DFVSeasonalOrderController.addAllPosItemsToCart_Apex('','Test1','',shippingCart.Id,'',prog.Id);
        DFVSeasonalOrderController.addAllPosItemsToCart_Apex('Test','Test1','',shippingCart.Id,'',prog.Id);
        
        
        // exceptions
        DFVSeasonalOrderController.addPosItemToCart_Apex('','','','RECENT_ADDED_CARTITEMS',prog.Id,0,'1234');
        DFVSeasonalOrderController.removePosItemFromCart_Apex('','','','RECENT_ADDED_CARTITEMS',prog.Id,0,'');
        DFVSeasonalOrderController.createSeasonalShoppingCart_Apex('1234');
        Test.stopTest();
    }
    @isTest
    private static void shoppingCartCmpTest()
    {
           Program__c prog = [SELECT Id FROM Program__c];
        List<POS_Item__c> prgItem = [SELECT Id FROM POS_Item__c];
        List<AddressBook__c> addressBook = [SELECT Id FROM AddressBook__c];

        List<DFVSeasonalOrderController.Program_ChairBudget_Details> programDetails=DFVSeasonalOrderController.getProgram_ChairBudgetList_Apex();
        DFVSeasonalOrderController.createSeasonalShoppingCart_Apex(prog.Id);
        List<Brand__c> brands=DFVSeasonalOrderController.getBrands_Apex();
        List<Item_Type__c> itemTypes=DFVSeasonalOrderController.getItemTypes_Apex();
        DFVSeasonalOrderController.PosItem_DetailsListWrapper posItems=DFVSeasonalOrderController.getPosItems_Apex('Test',brands[0].Id,itemTypes[0].Id,'LAST_N_DAYS',prog.Id,0);
        DFVSeasonalOrderController.addPosItemToCart_Apex('','','','',programDetails[0].program_chairBudget.Program__c,0,prgItem[0].Id);
        List<DFVSeasonalOrderController.AddressBook_QtyWrapper> addressesWithQty=DFVSeasonalOrderController.searchShippingAddresses_Apex('','[]');
        DFVSeasonalOrderController.ShoppingCartDetails_EmergeOrderId shoppingCartDetails=DFVSeasonalOrderController.saveShippingAddresses_Apex('',prgItem[0].Id,programDetails[0].program_chairBudget.Program__c,JSON.serialize(addressesWithQty));
        Test.startTest();
        DFVSeasonalOrderController.ShoppingCartDetails_EmergeOrderId cartDetails=DFVSeasonalOrderController.getCartItems_Apex(programDetails[0].program_chairBudget.Program__c);
        Chair_Budget__c chairBudget=DFVSeasonalOrderController.getChairBudgetDetails_Apex(programDetails[0].program_chairBudget.Id);
        DFVSeasonalOrderController.updateQuantityForItem_Apex(prgItem[0].Id,shoppingCartDetails.cartDetails[0].addressBook_Qty_List[0].addressBook.Id,shoppingCartDetails.emergeOrderId,10);
        DFVSeasonalOrderController.deleteItemFromCart_Apex(prgItem[0].Id,programDetails[0].program_chairBudget.Program__c,shoppingCartDetails.emergeOrderId);
        Test.stopTest();
    }
    @isTest
    private static void shippingAllAddressCmpTest ()
    {
         Program__c prog = [SELECT Id FROM Program__c];
        List<POS_Item__c> prgItem = [SELECT Id FROM POS_Item__c];
        
        List<DFVSeasonalOrderController.Program_ChairBudget_Details> programDetails=DFVSeasonalOrderController.getProgram_ChairBudgetList_Apex();
        DFVSeasonalOrderController.createSeasonalShoppingCart_Apex(programDetails[0].program_chairBudget.Program__c);
        List<Brand__c> brands=DFVSeasonalOrderController.getBrands_Apex();
        List<Item_Type__c> itemTypes=DFVSeasonalOrderController.getItemTypes_Apex();
        DFVSeasonalOrderController.PosItem_DetailsListWrapper posItems=DFVSeasonalOrderController.getPosItems_Apex('Test',brands[0].Id,itemTypes[0].Id,'LAST_N_DAYS',programDetails[0].program_chairBudget.Program__c,0);
        DFVSeasonalOrderController.addPosItemToCart_Apex('','','','RECENT_ADDED_CARTITEMS',programDetails[0].program_chairBudget.Program__c,0,prgItem[0].Id);
        Test.startTest();
        DFVSeasonalOrderController.ShippingAddress_ShippingMethodWrapper shippingAddress=DFVSeasonalOrderController.getShippingAddresses_Apex('',programDetails[0].program_chairBudget.Program__c,'');
        List<DFVSeasonalOrderController.AddressBook_QtyWrapper> addressesWithQty=DFVSeasonalOrderController.searchShippingAddresses_Apex('','[]');
        List<DFVSeasonalOrderController.AddressBook_QtyWrapper> addressesWithQty2=DFVSeasonalOrderController.searchShippingAddresses_Apex('shipToCompany','[]');
        String selectedShippingAddresses=JSON.serialize(addressesWithQty2);
        DFVSeasonalOrderController.saveShippingAddresses_Apex('',prgItem[0].Id,programDetails[0].program_chairBudget.Program__c,selectedShippingAddresses);
        DFVSeasonalOrderController.saveShippingAddresses_Apex('','',programDetails[0].program_chairBudget.Program__c,selectedShippingAddresses);
        Test.stopTest();
    }
    @isTest
    private static void previewOrderCmpTest ()
    {
        Program__c prog = [SELECT Id FROM Program__c];
        List<POS_Item__c> prgItem = [SELECT Id FROM POS_Item__c];
        
        List<DFVSeasonalOrderController.Program_ChairBudget_Details> programDetails=DFVSeasonalOrderController.getProgram_ChairBudgetList_Apex();
        DFVSeasonalOrderController.createSeasonalShoppingCart_Apex(programDetails[0].program_chairBudget.Program__c);
        List<Brand__c> brands=DFVSeasonalOrderController.getBrands_Apex();
        List<Item_Type__c> itemTypes=DFVSeasonalOrderController.getItemTypes_Apex();
        DFVSeasonalOrderController.PosItem_DetailsListWrapper posItems=DFVSeasonalOrderController.getPosItems_Apex('Test',brands[0].Id,itemTypes[0].Id,'LAST_N_DAYS',programDetails[0].program_chairBudget.Program__c,0);
        DFVSeasonalOrderController.addPosItemToCart_Apex('','','','RECENT_ADDED_CARTITEMS',programDetails[0].program_chairBudget.Program__c,0,prgItem[0].Id);
        List<DFVSeasonalOrderController.AddressBook_QtyWrapper> addressesWithQty=DFVSeasonalOrderController.searchShippingAddresses_Apex('','[]');
        DFVSeasonalOrderController.ShoppingCartDetails_EmergeOrderId shoppingCartDetails=DFVSeasonalOrderController.saveShippingAddresses_Apex('',prgItem[0].Id,programDetails[0].program_chairBudget.Program__c,JSON.serialize(addressesWithQty));
        Test.startTest();
        DFVSeasonalOrderController.getCometOrderItems_Apex(shoppingCartDetails.emergeOrderId);
        DFVSeasonalOrderController.confirmOrder_Apex(shoppingCartDetails.emergeOrderId,programDetails[0].program_chairBudget.Program__c);
        Test.stopTest();
    }
    @isTest
    private static void OrderStatusCmpTest ()
    {
         Program__c prog = [SELECT Id FROM Program__c];
        List<POS_Item__c> prgItem = [SELECT Id FROM POS_Item__c];
        
        List<DFVSeasonalOrderController.Program_ChairBudget_Details> programDetails=DFVSeasonalOrderController.getProgram_ChairBudgetList_Apex();
        DFVSeasonalOrderController.createSeasonalShoppingCart_Apex(programDetails[0].program_chairBudget.Program__c);
        List<Brand__c> brands=DFVSeasonalOrderController.getBrands_Apex();
        List<Item_Type__c> itemTypes=DFVSeasonalOrderController.getItemTypes_Apex();
        DFVSeasonalOrderController.PosItem_DetailsListWrapper posItems=DFVSeasonalOrderController.getPosItems_Apex('Test',brands[0].Id,itemTypes[0].Id,'LAST_N_DAYS',programDetails[0].program_chairBudget.Program__c,0);
        DFVSeasonalOrderController.addPosItemToCart_Apex('','','','RECENT_ADDED_CARTITEMS',programDetails[0].program_chairBudget.Program__c,0,prgItem[0].Id);
        List<DFVSeasonalOrderController.AddressBook_QtyWrapper> addressesWithQty=DFVSeasonalOrderController.searchShippingAddresses_Apex('','[]');
        DFVSeasonalOrderController.ShoppingCartDetails_EmergeOrderId shoppingCartDetails=DFVSeasonalOrderController.saveShippingAddresses_Apex('',prgItem[0].Id,programDetails[0].program_chairBudget.Program__c,JSON.serialize(addressesWithQty));
        
        Test.startTest();
        List<Program__c> programs=DFVSeasonalOrderController.getAllPrograms_Apex();
        List<DFVSeasonalOrderController.Program_ChairBudget_CometOrder> programOrders=DFVSeasonalOrderController.loadOrdersForSelectedProgram_Apex('',false,programDetails[0].program_chairBudget.Program__c);
        List<DFVSeasonalOrderController.Program_ChairBudget_CometOrder> programOrders2=DFVSeasonalOrderController.loadOrdersForSelectedProgram_Apex('shipToCompany',false,programDetails[0].program_chairBudget.Program__c);  
        Test.stopTest();
    }
    @isTest
    private static void ReviewOrdersCmpTest ()
    {
         Program__c prog = [SELECT Id FROM Program__c];
        List<POS_Item__c> prgItem = [SELECT Id FROM POS_Item__c];
        
        List<DFVSeasonalOrderController.Program_ChairBudget_Details> programDetails=DFVSeasonalOrderController.getProgram_ChairBudgetList_Apex();
        DFVSeasonalOrderController.createSeasonalShoppingCart_Apex(programDetails[0].program_chairBudget.Program__c);
        List<Brand__c> brands=DFVSeasonalOrderController.getBrands_Apex();
        List<Item_Type__c> itemTypes=DFVSeasonalOrderController.getItemTypes_Apex();
        DFVSeasonalOrderController.PosItem_DetailsListWrapper posItems=DFVSeasonalOrderController.getPosItems_Apex('Test',brands[0].Id,itemTypes[0].Id,'LAST_N_DAYS',programDetails[0].program_chairBudget.Program__c,0);
        DFVSeasonalOrderController.addPosItemToCart_Apex('','','','RECENT_ADDED_CARTITEMS',programDetails[0].program_chairBudget.Program__c,0,prgItem[0].Id);
        List<DFVSeasonalOrderController.AddressBook_QtyWrapper> addressesWithQty=DFVSeasonalOrderController.searchShippingAddresses_Apex('','[]');
        DFVSeasonalOrderController.ShoppingCartDetails_EmergeOrderId shoppingCartDetails=DFVSeasonalOrderController.saveShippingAddresses_Apex('',prgItem[0].Id,programDetails[0].program_chairBudget.Program__c,JSON.serialize(addressesWithQty));
        Test.startTest();
        List<Schema.User> users= DFVSeasonalOrderController.getUsers_Apex('S');
        List<DFVSeasonalOrderController.CometOrder_ChairBudget>  cometOrders=DFVSeasonalOrderController.loadOrdersForSelectedProgramAndUser_Apex('',programDetails[0].program_chairBudget.Program__c);
        DFVSeasonalOrderController.saveEditedOrder_Apex(cometOrders.isEmpty()?'[]':JSON.serialize(cometOrders[0].orderedItems),
                                                              's',programDetails[0].program_chairBudget.Program__c,100,
                                                              cometOrders.isEmpty()?'':cometOrders[0].cometOrder.Id,
                                                              cometOrders.isEmpty()? programDetails[0].program_chairBudget : cometOrders[0].chairBudget);
        Test.stopTest();
    }
    @testSetup static void setupData() {
        List<Account> testAccts = new List<Account>();
        Account acct = new Account(Name='DFV');
        insert acct ;
        Contact contact=new Contact(LastName='Testing',AccountId=acct.Id);
        insert contact;
        Profile profile=[SELECT Name FROM Profile WHERE Name='Customer Community Plus User' LIMIT 1];
        Schema.User communityUser = new Schema.User(Alias = 'standt', Email='standarduser@testorg.com', 
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
        
        List<Brand__c> brandList=new List<Brand__c> ();
        Brand__c brand = new Brand__c (Brand_Name__c='BrandNameSelect',Active__c=true,Account__c=acct.Id);
        Brand__c brand1 = new Brand__c (Brand_Name__c='BrandNameSelect1',Active__c=true,Account__c=acct.Id);
        brandList.add(brand);
        brandList.add(brand1);
        insert brandList;
        
        List<Item_Type__c> itemTypeList=new List<Item_Type__c> ();
        Item_Type__c itemType= new Item_Type__c(Item_Type__c='itemTypeSelect',Active__c=true,Account__c=acct.Id);
        Item_Type__c itemType1 = new Item_Type__c(Item_Type__c='itemTypeSelect1',Active__c=true,Account__c=acct.Id);
        itemTypeList.add(itemType);
        itemTypeList.add(itemType1);
        insert itemTypeList;
        
        List<POS_Item__c> posItemList=new List<POS_Item__c> ();
        POS_Item__c posItem= new POS_Item__c (Item_No__c='Test-No-01',Item_Name__c='testPosItemName',Account__c=acct.Id,Brand__c=brandList[0].Id,Type_of_Item__c=itemTypeList[0].Id,Active__c=true,Price__c=10.0);
        POS_Item__c posItem2= new POS_Item__c (Item_No__c='Test-No-02',Item_Name__c='testPosItemName',Available_Stock__c=0,Account__c=acct.Id,Brand__c=brandList[0].Id,Type_of_Item__c=itemTypeList[0].Id,Active__c=true,Price__c=10.0);
        posItemList.add(posItem);
        posItemList.add(posItem2);
        insert posItemList;
        
        List<Shipping_Method__c> shippingMethodList=new List<Shipping_Method__c> ();
        Shipping_Method__c shippingMethod = new Shipping_Method__c(Account__c=acct.Id , Active__c=true , ApprovalRequired__c=true , Shipping_Method_Name__c='shippingMethod1');
        shippingMethodList.add(shippingMethod);
        Shipping_Method__c shippingMethod2 = new Shipping_Method__c(Account__c=acct.Id , Active__c=true , ApprovalRequired__c=false , Default__c=true , Shipping_Method_Name__c='shippingMethod2');
        shippingMethodList.add(shippingMethod2);
        insert shippingMethodList;
        
        List<AddressBook__c> addressBookList=new List<AddressBook__c> ();
        AddressBook__c addressBook = new AddressBook__c(Account__c=acct.Id , Destination_Name__c='destinationName' , Shipto_Company__c='shipToCompany', State__c=state.Id) ;
        addressBookList.add(addressBook);
        AddressBook__c addressBook2 = new AddressBook__c(Account__c=acct.Id , Destination_Name__c='destinationName2' , Shipto_Company__c='shipToCompany2', State__c=state.Id) ;
        addressBookList.add(addressBook2);
        insert addressBookList;
        /*Organiztaion_Chart__c orgChart=new Organiztaion_Chart__c (Account__c=acct.Id,Checkbox__c=true,Effective_End_Date_of_Org_Chart__c=System.today().addDays(+100),
Effective_Start_Date_of_Org_Chart__c=System.today().addDays(-100),
Organization_Chart_Name__c='FreixenetOrganization1');
insert orgChart;  */
        
        Program__c program=new Program__c (Name__c='Testing',Account__c=acct.Id,Start_Date__c=System.today().addDays(-10),
                                           Closing_Date__c=System.today().addDays(+10),
                                           In_Market_Date__c=System.today().addDays(+20));
        insert program;
        List<Program_Item__c> programItems=new List<Program_Item__c> ();
        programItems.add(new Program_Item__c (POS_Item__c=posItem.Id,Program__c=program.Id));
        programItems.add(new Program_Item__c (POS_Item__c=posItem2.Id,Program__c=program.Id));  
        insert programItems;                                 
        Chair__c chair=new Chair__c (Chair_Name__c='Test',Level__c='1',User__c=UserInfo.getUserId(),Active__c=true);
        insert chair;
        Chair_Budget__c chairBudget=new Chair_Budget__c (Allocated_Budget__c=1000,Shared_Budget__c=200,
                                                         Chair__c=chair.Id,Program__c=program.Id);
        insert chairBudget;
        
    }
}