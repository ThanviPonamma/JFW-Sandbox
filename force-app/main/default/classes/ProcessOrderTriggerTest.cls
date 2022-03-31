@isTest
private class ProcessOrderTriggerTest
{
    @isTest
    private static void emergeOrderTest()
    {
        Account acct=new Account(Name='DFV',Is_Comet_Rest_Api__c=true); 
        insert acct;
        
        Brand__c brand=new Brand__c(Account__c=acct.Id,Active__c=true,Brand_Name__c='TestBrand');
        insert brand;
        
         Item_Type__c itemType=new Item_Type__c(Account__c=acct.Id,Active__c=true,Item_Type__c='Other Pos Items');
        insert itemType;
        
         List<Pos_Item__c> posItems=new List<Pos_Item__c> ();
        Pos_Item__c posItem1=new Pos_Item__c(Account__c=acct.Id,Active__c=true,Available_Stock__c=100,Brand__c=brand.Id,Pack_Of__c=1,Price__c=10,Item_Name__c='Maisons MaxOrdQty',Item_No__c='StaticProductABC',Type_of_Item__c=itemType.Id,DisplayOrder__c=40000);
        Pos_Item__c posItem2=new Pos_Item__c(Account__c=acct.Id,Active__c=true,Available_Stock__c=100,Brand__c=brand.Id,Pack_Of__c=1,Price__c=10,Item_Name__c='Item2',Item_No__c='Item2',Type_of_Item__c=itemType.Id,DisplayOrder__c=40000,Approval_Required__c=true,Maximum_order_quantity_applicable__c=true,Maximum_Order_Qty__c=2);
        Pos_Item__c posItem3=new Pos_Item__c(Account__c=acct.Id,Active__c=true,Available_Stock__c=100,Brand__c=brand.Id,Pack_Of__c=1,Price__c=10,Item_Name__c='Item3',Item_No__c='Item3',Type_of_Item__c=itemType.Id,DisplayOrder__c=40000,Approval_Required__c=false,Maximum_order_quantity_applicable__c=true,Maximum_Order_Qty__c=2);
        Pos_Item__c posItem4=new Pos_Item__c(Account__c=acct.Id,Active__c=true,Available_Stock__c=100,Brand__c=brand.Id,Pack_Of__c=1,Price__c=10,Item_Name__c='Item4',Item_No__c='Item4',Type_of_Item__c=itemType.Id,DisplayOrder__c=40000,Approval_Required__c=true,Maximum_order_quantity_applicable__c=false,Maximum_Order_Qty__c=0);
        posItems.add(posItem1);posItems.add(posItem2);posItems.add(posItem3);posItems.add(posItem4);
        insert posItems;
        
        List<Shipping_Method__c> smList=new List<Shipping_Method__c > ();
        
        Shipping_Method__c sm1=new Shipping_Method__c(ApprovalRequired__c=false,Account__c=acct.Id,Active__c=true,Shipping_Method_Name__c='Fed Ex Ground',DisplayOrder__c=10,Order__c=99);
        Shipping_Method__c sm2=new Shipping_Method__c(ApprovalRequired__c=true,Account__c=acct.Id,Active__c=true,Shipping_Method_Name__c='Fed Ex International',DisplayOrder__c=10,Order__c=99);
        smList.add(sm1);smList.add(sm2);
        insert smList;
        Country__c country=new Country__c (Active__c=true,Country_Code__c='IN',Country_Name__c='India');
        insert country;
        State__c state=new State__c(Active__c=true,State_Code__c='BE',State_Name__c='Banglore',Country__c=country.Id);
        insert state;
        
        List<AddressBook__c> addressBooks=new List<AddressBook__c > ();
        AddressBook__c ab=new AddressBook__c (Account__c=acct.Id,Destination_Name__c='UXL Consulting',Shipto_Company__c='UXL Consulting',State__c=state.Id,Active__c=true,Address__c='UXL Consulting,Banglore',City__c='Banglore',Email__c='Pradeep@Uxlconsulting.com',Shipto_Name__c='Pradeep Kumar',Zip__c='560078');
        //insert ab;
        AddressBook__c ab2=new AddressBook__c (Account__c=acct.Id,Destination_Name__c='Test',Shipto_Company__c='Test',State__c=state.Id,Active__c=true,Address__c='Test,Banglore',City__c='Hyderabad',Email__c='Nanda@Uxlconsulting.com',Shipto_Name__c='Nanda Kumar',Zip__c='50000');
        AddressBook__c ab3=new AddressBook__c (Account__c=acct.Id,Destination_Name__c='Sterling Tompkins',Shipto_Company__c='RNDC',State__c=state.Id,Active__c=true,Address__c='341 Pitkin Iron Road',City__c='Aspen',Email__c='ranjith@Uxlconsulting.com',Shipto_Name__c='Ranjith Kumar',Zip__c='50002');
        //insert ab2;
        //insert ab3;
        addressBooks.add(ab);addressBooks.add(ab2);addressBooks.add(ab3);
        insert addressBooks;
        
       
        
       
        
       
        
        Order__c order=new Order__c(Account__c=acct.Id,Order_Status__c='OPEN',Order_Date__c=System.today());
        insert order;
        
        List<OrderDestination__c> cometOrders=new List<OrderDestination__c> ();
        OrderDestination__c cometOrderNoApproval=new OrderDestination__c(Order__c=order.Id,AddressBook__c=ab.Id,SelectedShippingMethod__c=sm1.Id,Shipping_Method__c=sm1.Id,Comet_Order_Status__c='OPEN');
        OrderDestination__c cometOrderNeedsApproval=new OrderDestination__c(Order__c=order.Id,AddressBook__c=ab2.Id,SelectedShippingMethod__c=sm2.Id,Shipping_Method__c=sm1.Id,Comet_Order_Status__c='OPEN');
        OrderDestination__c emptyCometOrder=new OrderDestination__c(Order__c=order.Id,AddressBook__c=ab3.Id,SelectedShippingMethod__c=sm2.Id,Shipping_Method__c=sm1.Id,Comet_Order_Status__c='OPEN');
        cometOrders.add(cometOrderNoApproval);cometOrders.add(cometOrderNeedsApproval);cometOrders.add(emptyCometOrder);
        insert cometOrders;
        List<OrderDestinationItem__c> cometOrderItems=new List<OrderDestinationItem__c> ();
        OrderDestinationItem__c cometOrderItem1=new OrderDestinationItem__c(OrderDestination__c=cometOrderNoApproval.Id,POS_Item__c=posItem1.Id,SelectedQuantity__c=3,Quantity__c=3);
        OrderDestinationItem__c cometOrderItem2=new OrderDestinationItem__c(OrderDestination__c=cometOrderNeedsApproval.Id,POS_Item__c=posItem1.Id,SelectedQuantity__c=3,Quantity__c=3);
        OrderDestinationItem__c cometOrderItem3=new OrderDestinationItem__c(OrderDestination__c=emptyCometOrder.Id,POS_Item__c=posItem1.Id,SelectedQuantity__c=0,Quantity__c=0);
        OrderDestinationItem__c cometOrderItem4=new OrderDestinationItem__c(OrderDestination__c=cometOrderNeedsApproval.Id,POS_Item__c=posItem2.Id,SelectedQuantity__c=4,Quantity__c=4);
        cometOrderItems.add(cometOrderItem1);cometOrderItems.add(cometOrderItem2);cometOrderItems.add(cometOrderItem3);cometOrderItems.add(cometOrderItem4);
        insert cometOrderItems;
        
        order.Order_Status__c='Send to Comet';
        //update order;       
        Test.startTest();
        Test.setMock(HttpCalloutMock.class,new CometOrderResponseTest());          
        Test.stopTest(); 
    }
}