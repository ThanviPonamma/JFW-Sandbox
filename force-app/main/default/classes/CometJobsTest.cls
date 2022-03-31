@isTest
private class CometJobsTest {
    static testmethod void constructorTest(){
        
        Account acct = new Account(Name='testAcct', hasCometConfiguration__c =true, CometJobNo__c = '76961', CometUsername__c ='GJayaram', CometPassword__c= 'IRG123');
        insert acct ;
        Daily_Inventory_Creation__c customSetting=new Daily_Inventory_Creation__c(Trigger_Active_Flag__c=false,Name='Trigger flag');
        insert customSetting;
        
        acct = new Account(Name='JFW', hasCometConfiguration__c =true, CometJobNo__c = '76961', CometUsername__c ='GJayaram', CometPassword__c= 'IRG123', BudgetRuleNo__c =1);
        insert acct ;
        acct = new Account(Name='DFV', hasCometConfiguration__c =true, CometJobNo__c = '76961', CometUsername__c ='GJayaram', CometPassword__c= 'IRG123', BudgetRuleNo__c =1);
        insert acct ;
        
        Order__c ord = new Order__c();
        ord.Account__C = acct.id;
        ord.Order_Status__c = 'Test1';
        ord.Order_Date__c = System.today();
        insert ord;
        
        Shipping_Method__c shipmethod = new Shipping_Method__c(Shipping_Method_Name__c='testshipmethod', Active__c = true, Account__c = acct.id);
        insert shipmethod ;
        System.assertEquals('testshipmethod', shipmethod.Shipping_Method_Name__c);
        
        Country__c c = new Country__c(Country_Code__c='US', Country_Name__c ='US');
        insert c;
        State__c state = new State__c( Country__c= c.id, State_Code__c='NY',  State_Name__c='Newyork');
        insert state;
        AddressBook__c address = new AddressBook__c(Address__c='addr1', State__c= state.id, Destination_Name__c = 'Dest1', Shipto_Company__c = 'shiptocomp' , Country__c = c.id, Active__c = true, Account__c = acct.id);
        insert address;
        
        OrderDestination__c od = new OrderDestination__c();
        od.AddressBook__c = address.id;
        od.Order__c = ord.id;
        od.Shipping_Method__c = shipmethod.id;
        od.WarehouseTransactionNo__c ='123';
        
        insert od;
        
        
        
        POSItemGenericName__c genItem = new POSItemGenericName__c(GenericName__c='GenName', Active__c = true,Account__c = acct.id);
        insert genItem;
        
        ItemColor__c color = new ItemColor__C( Color__c='blue');
        insert color;
        ItemSize__c size = new ItemSize__c(size__C ='SM');
        insert size;
        
        Brand__c brand = new Brand__c(Brand_Name__c='testBrand', Active__c = true, Account__c = acct.id);
        insert brand;
        Item_Type__c itemtype = new Item_Type__c(Item_Type__c='testItemType', Active__c = true, Account__c = acct.id);
        insert itemtype;
        POS_Item__c posItem = new  POS_Item__c(Item_No__c='itm1', item_Name__c= 'Name1', Active__c = true, Brand__c = brand.Id, Type_of_Item__c = itemtype.id, Account__c = acct.id, ItemColor__c=color.id, ItemSize__c = size.id, POSItemGenericName__c = genItem.id, Low_inventory_level_applicable__c = true, Available_Stock__c = 10, Low_Inventory_Level__c = 15,Inventory_Seasonal_Program__c='Inventory');
        insert posItem ;
        System.assertEquals('itm1', posItem.Item_No__c);
        
        OrderDestinationItem__c odi = new OrderDestinationItem__c();
        odi.OrderDestination__c = od.id;
        odi.POS_Item__c = posItem.id;
        odi.Quantity__c = 100;
        insert odi;
        
        
        // set up some test data to work with
        Territory__c territory = new Territory__c(Territory_Name__c='testTerritory', Active__c = true, Account__c = acct.id);
        insert territory ;
        System.assertEquals('testTerritory', territory.Territory_Name__c);
        
        
        States_Territory__c stTer = new States_Territory__c(State__c = state.id,Territory__c = territory.id);
        insert stTer ;
       
        String UserId = userinfo.getUserId();  
        Users_Territory__c usrter;
        usrter = new Users_Territory__c(Territory__c = territory.id, User__c = UserId);
        insert usrter ;
        
        Brand_Territory_Budget__c brndTerbud = new Brand_Territory_Budget__c(Brand__c = brand.id,   Budget__c = 1000,Territory__c = territory.id, Utilized_Budget__c = 100, Year__c = 2016);
        insert brndTerbud ;
        
        
        ShoppingCart__c cart = new ShoppingCart__c(CartComments__c='Test', CartStatus__c= 'Open', Active__c = true, Account__c = acct.id);
        ShoppingCartItems__c cartitem = new ShoppingCartItems__c( ShoppingCart__c = cart.id, POS_Item__c = posItem.id, Active__c = true);
        
       
        
        List <selectOption> genitemList;
        List <selectOption> colorList;
        List <selectOption> sizeList;
        
        
        // start the test execution context
        Test.startTest();
        ApexPages.CurrentPage().getparameters().put('id', ord.id);
        CometJobs CJob = new CometJobs ();
        CJob.budRuleNo=1;
        
        //CJob.objPosItem=posItem;
        
        
        CJob.objAccount = acct;
        
        
        CometJobs.GetLatestStock();
        CometJobs.GetLatestStockWithInProcessInv('testAcct');
        CJob.NotificationForLowLevelInventory();
        CometJobs.SubmitInprocessOrders_Ver1();
        CometJobs.UpdateTransactionNumbers(1,'JFW');
        CometJobs.UpdateWarehouseOrderStatuses();
        
        ord.Order_Status__c = 'Awaiting approval - Item Required Approval';
        update ord;
        CometJobs.SubmitInprocessOrders_Ver1();

        ord = new Order__c();
        ord.Account__C = acct.id;
        ord.Order_Status__c = 'Test2';
        ord.Order_Date__c = System.today();
        insert ord;
        
        od = new OrderDestination__c();
        od.AddressBook__c = address.id;
        od.Order__c = ord.id;
        od.Shipping_Method__c = shipmethod.id;
        od.WarehouseTransactionNo__c ='1234';
        insert od;
       
        odi = new OrderDestinationItem__c();
        odi.OrderDestination__c = od.id;
        odi.POS_Item__c = posItem.id;
        odi.Quantity__c = 70;
        insert odi;
        
     
        
        cart = new ShoppingCart__c(CartComments__c='Test', CartStatus__c= 'Open', Active__c = true, Account__c = acct.id);
        cartitem = new ShoppingCartItems__c( ShoppingCart__c = cart.id, POS_Item__c = posItem.id, Active__c = true);
        
       
       
        CometJobs.SubmitInprocessOrders();
        CometJobs.SubmitInprocessOrdersWithLimit(3);
        od.WarehouseTransactionNo__c ='0';
        od.OrderDest_Status__c ='Submitted';
        update od;
        CometJobs.UpdateTransactionNumbers();
        
        
        CometJobs.GetLatestStockAndNotifyMissingStock();
        
        integer tr = CJob.getTransactionNo('orderName', 'cometUser', 'cometPasword');
    
        
        // stop the test
        Test.stopTest();
        
     
        
        
    }

}