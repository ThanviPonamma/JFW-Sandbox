@isTest
private class SubmitOrderToCometTriggerTest
{
    @isTest
    private static void emergeOrderTest()
    {
        Account acct1=new Account(Name='DFV',BudgetRuleNo__c =1,Is_Comet_Rest_Api__c=true); 
        Account acct2=new Account(Name='JFW',BudgetRuleNo__c =1,Is_Comet_Rest_Api__c=true);
        Account acct3=new Account(Name='Wilson Daniels',BudgetRuleNo__c =1,Is_Comet_Rest_Api__c=true);
        Account acct4=new Account(Name='Infinium Spirits',BudgetRuleNo__c =1,Is_Comet_Rest_Api__c=true);
        List<Account> accountList=new List<Account> {acct1,acct2,acct3};
            insert accountList;
        Daily_Inventory_Creation__c dailyInv=new Daily_Inventory_Creation__c(Name='Trigger flag',Trigger_Active_Flag__c=false);
        Insert dailyInv;
        List<Send_To_Comet_Order_Specifications__c> cometOrderSpecifications=new List<Send_To_Comet_Order_Specifications__c> ();
        cometOrderSpecifications.add(new Send_To_Comet_Order_Specifications__c(Name='DFV',Account_Name__c='DFV',Inventory_Order_Trigger_Flag__c=true,Seasonal_Order_Trigger_Flag__c=true));
        cometOrderSpecifications.add(new Send_To_Comet_Order_Specifications__c(Name='JFW',Account_Name__c='JFW',Inventory_Order_Trigger_Flag__c=true,Seasonal_Order_Trigger_Flag__c=false));
        cometOrderSpecifications.add(new Send_To_Comet_Order_Specifications__c(Name='Wilson Daniels',Account_Name__c='Wilson Daniels',Inventory_Order_Trigger_Flag__c=true,Seasonal_Order_Trigger_Flag__c=false));
        cometOrderSpecifications.add(new Send_To_Comet_Order_Specifications__c(Name='Infinium Spirits',Account_Name__c='Infinium Spirits',Inventory_Order_Trigger_Flag__c=true,Seasonal_Order_Trigger_Flag__c=false));
        insert cometOrderSpecifications;
        
        Territory__c DFVterritory=new Territory__c(Account__c=acct1.Id,Active__c=true,Territory_Name__c='Corporate');
        insert DFVterritory;
        Territory__c JFWterritory=new Territory__c(Account__c=acct2.Id,Active__c=true,Territory_Name__c='Central');
        insert JFWterritory;
        Territory__c WilsonDanielterritory=new Territory__c(Account__c=acct3.Id,Active__c=true,Territory_Name__c='North');
        insert WilsonDanielterritory;
        
        Users_Territory__c userTerritoryDFV=new Users_Territory__c(User__c=UserInfo.getUserId(),Territory__c=DFVterritory.Id);
        insert userTerritoryDFV;
        Users_Territory__c userTerritoryJFW=new Users_Territory__c(User__c=UserInfo.getUserId(),Territory__c=JFWterritory.Id);
        insert userTerritoryJFW;
        Users_Territory__c userTerritoryWilson=new Users_Territory__c(User__c=UserInfo.getUserId(),Territory__c=WilsonDanielterritory.Id);
        insert userTerritoryWilson;
        List<Shipping_Method__c> smList=new List<Shipping_Method__c > ();
        Shipping_Method__c dfvShippingMethod = new Shipping_Method__c(ApprovalRequired__c=false,Account__c=acct1.Id,Active__c=true,Shipping_Method_Name__c='Fed Ex Ground',DisplayOrder__c=10,Order__c=99);
        Shipping_Method__c dfvShippingMethodApproval = new Shipping_Method__c(ApprovalRequired__c=true,Account__c=acct1.Id,Active__c=true,Shipping_Method_Name__c='Fed Ex International',DisplayOrder__c=10,Order__c=99);
        Shipping_Method__c jfwShippingMethod = new Shipping_Method__c(ApprovalRequired__c=false,Account__c=acct2.Id,Active__c=true,Shipping_Method_Name__c='Fed Ex Ground',DisplayOrder__c=10,Order__c=99);
        Shipping_Method__c wilsonShippingMethod = new Shipping_Method__c(ApprovalRequired__c=False,Account__c=acct3.Id,Active__c=true,Shipping_Method_Name__c='Fed Ex International',DisplayOrder__c=10,Order__c=99);
        
        smList.add(dfvShippingMethod);smList.add(dfvShippingMethodApproval); smList.add(jfwShippingMethod); smList.add(wilsonShippingMethod);
        insert smList;
        Country__c country=new Country__c (Active__c=true,Country_Code__c='IN',Country_Name__c='India');
        insert country;
        State__c state=new State__c(Active__c=true,State_Code__c='BA',State_Name__c='Banglore',Country__c=country.Id);
        insert state;
        List<AddressBook__c> addressBooks=new List<AddressBook__c > ();
        AddressBook__c ab=new AddressBook__c (Account__c=acct1.Id,Phone__c='+919493908910',Destination_Name__c='UXL',Shipto_Company__c='UXL',State__c=state.Id,Active__c=true,Address__c='UXL Teachnologies,Banglore',City__c='Banglore',Email__c='varsha@Uxlconsulting.com',Shipto_Name__c='Varsha',Zip__c='560078');
        AddressBook__c ab2=new AddressBook__c (Account__c=acct2.Id,Phone__c='+919493908910',Destination_Name__c='Test',Shipto_Company__c='Test',State__c=state.Id,Active__c=true,Address__c='Test,Banglore',City__c='Hyderabad',Email__c='vanditha@Uxlconsulting.com',Shipto_Name__c='Nanda Kumar',Zip__c='500001');
        AddressBook__c ab3=new AddressBook__c (Account__c=acct3.Id,Phone__c='+919493908910',Destination_Name__c='Sterling Tompkins',Shipto_Company__c='RNDC',State__c=state.Id,Active__c=true,Address__c='341 Pitkin Iron Road',City__c='Aspen',Email__c='sanjana@Uxlconsulting.com',Shipto_Name__c='Sanjana',Zip__c='500012');
        addressBooks.add(ab);addressBooks.add(ab2);addressBooks.add(ab3);
        insert addressBooks;
        
        Brand__c dfvBrand=new Brand__c(Account__c=acct1.Id,Active__c=true,Brand_Name__c='testbrand');
        insert dfvBrand;
        Brand__c jfwBrand=new Brand__c(Account__c=acct2.Id,Active__c=true,Brand_Name__c='testbrand');
        insert jfwBrand;
        Brand__c wilsonBrand=new Brand__c(Account__c=acct3.Id,Active__c=true,Brand_Name__c='testbrand');
        insert wilsonBrand;
        
        Item_Type__c dfvItemType=new Item_Type__c(Account__c=acct1.Id,Active__c=true,Item_Type__c='Other Pos Items');
        insert dfvItemType;
        Item_Type__c jfwItemType=new Item_Type__c(Account__c=acct2.Id,Active__c=true,Item_Type__c='Other Pos Items');
        insert jfwItemType;
        Item_Type__c wilsonItemType=new Item_Type__c(Account__c=acct3.Id,Active__c=true,Item_Type__c='Other Pos Items');
        insert wilsonItemType;
        
        List<Pos_Item__c> posItems=new List<Pos_Item__c> ();
        Pos_Item__c dfvPosItem1=new Pos_Item__c(Account__c=acct1.Id,Active__c=true,Available_Stock__c=100,Brand__c=dfvBrand.Id,Pack_Of__c=1,Price__c=10,Item_Name__c='Maisons MaxOrdQty',Item_No__c='StaticProductABC',Type_of_Item__c=dfvItemType.Id,DisplayOrder__c=40000);
        Pos_Item__c dfvPosItem2=new Pos_Item__c(Account__c=acct1.Id,Active__c=true,Available_Stock__c=100,Brand__c=dfvBrand.Id,Pack_Of__c=1,Price__c=10,Item_Name__c='Item2',Item_No__c='Item2',Type_of_Item__c=dfvItemType.Id,DisplayOrder__c=40000,Approval_Required__c=true,Maximum_order_quantity_applicable__c=true,Maximum_Order_Qty__c=2);
        Pos_Item__c jfwPosItem=new Pos_Item__c(Account__c=acct2.Id,Active__c=true,Available_Stock__c=100,Brand__c=jfwBrand.Id,Pack_Of__c=1,Price__c=10,Item_Name__c='Item3',Item_No__c='Item3',Type_of_Item__c=jfwItemType.Id,DisplayOrder__c=40000,Approval_Required__c=false,Maximum_order_quantity_applicable__c=true,Maximum_Order_Qty__c=2);
        Pos_Item__c wilsonPosItem=new Pos_Item__c(Account__c=acct3.Id,Active__c=true,Available_Stock__c=100,Brand__c=wilsonBrand.Id,Pack_Of__c=1,Price__c=10,Item_Name__c='Item4',Item_No__c='Item4',Type_of_Item__c=wilsonItemType.Id,DisplayOrder__c=40000,Approval_Required__c=true,Maximum_order_quantity_applicable__c=false,Maximum_Order_Qty__c=0);
        posItems.add(dfvPosItem1);posItems.add(dfvPosItem2);posItems.add(jfwPosItem);posItems.add(wilsonPosItem);
        insert posItems;
        
        ProgramWindow__c programWindow=new ProgramWindow__c(Account__c=acct1.Id,ProgramWindow_Name__c='TestWindow');
        insert programWindow;
        Program__c program=new Program__c(Account__c=acct1.Id,ProgramWindow__c=programWindow.Id,Closing_Date__c=Date.newInstance(2018, 04, 30),In_Market_Date__c=Date.newInstance(2018,05,15),Name__c='TestProgram',Start_Date__c=Date.newInstance(2018,04,01));
        insert program;
        
        Order__c order=new Order__c(Account__c=acct1.Id,Order_Status__c='Send To Comet',Order_Date__c=System.today());
        insert order;
        Order__c jfwOrder=new Order__c(Account__c=acct2.Id,Order_Status__c='Send To Comet',Order_Date__c=System.today());
        insert jfwOrder;
        Order__c wilsonOrder=new Order__c(Account__c=acct3.Id,Order_Status__c='Send To Comet',Order_Date__c=System.today());
        insert wilsonOrder;
        
        List<OrderDestination__c> cometOrders=new List<OrderDestination__c> ();
        OrderDestination__c cometOrderNoApproval=new OrderDestination__c(Order__c=order.Id,AddressBook__c=ab.Id,SelectedShippingMethod__c=dfvShippingMethod.Id,Shipping_Method__c=dfvShippingMethod.Id,Comet_Order_Status__c='OPEN');
        OrderDestination__c jfwcometOrderNoApproval=new OrderDestination__c(Order__c=jfworder.Id,AddressBook__c=ab.Id,SelectedShippingMethod__c=jfwShippingMethod.Id,Shipping_Method__c=jfwShippingMethod.Id,Comet_Order_Status__c='OPEN');
        OrderDestination__c cometOrderNeedsApproval=new OrderDestination__c(Order__c=order.Id,AddressBook__c=ab2.Id,SelectedShippingMethod__c=dfvShippingMethodApproval.Id,Shipping_Method__c=dfvShippingMethodApproval.Id,Comet_Order_Status__c='OPEN');
        OrderDestination__c wilsonCometOrderNoApproval=new OrderDestination__c(Order__c=wilsonOrder.Id,AddressBook__c=ab2.Id,SelectedShippingMethod__c=wilsonShippingMethod.Id,Shipping_Method__c=wilsonShippingMethod.Id,Comet_Order_Status__c='OPEN');
        cometOrders.add(cometOrderNoApproval);cometOrders.add(cometOrderNeedsApproval);cometOrders.add(jfwcometOrderNoApproval);cometOrders.add(wilsonCometOrderNoApproval);
        insert cometOrders;
        
        List<OrderDestinationItem__c> cometOrderItems=new List<OrderDestinationItem__c> ();
        OrderDestinationItem__c cometOrderItem1=new OrderDestinationItem__c(OrderDestination__c=cometOrderNoApproval.Id,POS_Item__c=dfvPosItem1.Id,SelectedQuantity__c=3,Quantity__c=3);
        OrderDestinationItem__c jfwcometOrderItem=new OrderDestinationItem__c(OrderDestination__c=jfwcometOrderNoApproval.Id,POS_Item__c=jfwPosItem.Id,SelectedQuantity__c=3,Quantity__c=3);
        OrderDestinationItem__c cometOrderItem2=new OrderDestinationItem__c(OrderDestination__c=cometOrderNeedsApproval.Id,POS_Item__c=dfvPosItem1.Id,SelectedQuantity__c=3,Quantity__c=3);
        OrderDestinationItem__c wilsoncometOrderItem=new OrderDestinationItem__c(OrderDestination__c=wilsonCometOrderNoApproval.Id,POS_Item__c=jfwPosItem.Id,SelectedQuantity__c=3,Quantity__c=3);
        OrderDestinationItem__c cometOrderItem3=new OrderDestinationItem__c(OrderDestination__c=cometOrderNeedsApproval.Id,POS_Item__c=dfvPosItem2.Id,SelectedQuantity__c=4,Quantity__c=4);
        cometOrderItems.add(cometOrderItem1);cometOrderItems.add(jfwcometOrderItem);cometOrderItems.add(cometOrderItem2);cometOrderItems.add(cometOrderItem3);cometOrderItems.add(wilsoncometOrderItem);
        insert cometOrderItems;       
        
        Order__c seasonalOrderForDFV=new Order__c(Account__c=acct1.Id,Order_Status__c='OPEN',Order_Date__c=System.today(),Program__c=program.Id);
        insert seasonalOrderForDFV;
        OrderDestination__c seasonalCometOrderForDFV=new OrderDestination__c(Order__c=seasonalOrderForDFV.Id,AddressBook__c=ab.Id,SelectedShippingMethod__c=dfvShippingMethod.Id,Shipping_Method__c=dfvShippingMethod.Id,Comet_Order_Status__c='OPEN');
        insert seasonalCometOrderForDFV;
        OrderDestinationItem__c seasonalCometOrderForDFVItem=new OrderDestinationItem__c(OrderDestination__c=seasonalCometOrderForDFV.Id,POS_Item__c=dfvPosItem1.Id,SelectedQuantity__c=3,Quantity__c=3,Ready_To_Be_Sent__c=true,Order_Destination_Item_Status__c='Sending to Warehouse',Wave_Order_Number__c ='Test1234');
        insert seasonalCometOrderForDFVItem;
        seasonalCometOrderForDFV.Comet_Order_Status__c='Send To Comet';
        update seasonalCometOrderForDFV;
        cometOrderNoApproval.Comet_Order_Status__c='Send To Comet';
        update cometOrderNoApproval;
        jfwcometOrderNoApproval.Comet_Order_Status__c='Send To Comet';
        update jfwcometOrderNoApproval;
        wilsonCometOrderNoApproval.Comet_Order_Status__c='Send To Comet';
        update wilsonCometOrderNoApproval;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class,new CometOrderResponseTest());                
        Test.stopTest(); 
    }
}