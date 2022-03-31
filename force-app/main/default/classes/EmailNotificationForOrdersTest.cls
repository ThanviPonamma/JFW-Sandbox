@isTest
public class EmailNotificationForOrdersTest
{
    @isTest
    private static void constructorTest ()
    {
        List<Account> accountList=new List<Account> ();
        Account acct = new Account(Name='DFV',Comet_API_Key__c='1234');
        accountList.add(acct);
        insert accountList;
        Daily_Inventory_Creation__c customSetting=new Daily_Inventory_Creation__c(Trigger_Active_Flag__c=false,Name='Trigger flag');
        insert customSetting;
        
        List<ProgramWindow__c> owList=new List<ProgramWindow__c> ();
        ProgramWindow__c ow = new ProgramWindow__c();
        ow.ProgramWindow_Name__c = 'Test Ordering Window';
        ow.Active__c = True;
        ow.Account__c = acct.id;
        owList.add(ow);
                   
        insert owList; 
          
          
        List<Program__c> spList=new List<Program__c> ();     
        Program__c sp = new Program__c();
        sp.Name__c	 = 'Test Program';
        sp.Start_Date__c = System.today()-3 ;
        sp.Closing_Date__c = System.today()-2 ;
        sp.In_Market_Date__c = System.today()-1 ;
        sp.ProgramWindow__c = ow.Id;
        sp.Active__c = True;
        sp.Account__c = acct.id;
        
        insert spList;
        
        List<Order__c> ordersList=new List<Order__c> ();
        Order__c ord = new Order__c();
        ord.Account__C = acct.id;
        ord.Order_Status__c = 'Open';
        ord.Order_Date__c = System.today();
        ord.Order_Confirmation_Date__c = Datetime.now().format('yyyy-MM-dd');
        ord.Program__C = sp.id;
        ordersList.add(ord);
       
        insert ordersList;
        
        List<Shipping_Method__c> shipmethodList=new List<Shipping_Method__c> ();
        Shipping_Method__c shipmethod = new Shipping_Method__c(Shipping_Method_Name__c='testshipmethod', Active__c = true, Account__c = acct.id);
        shipmethodList.add(shipmethod);
        
        insert shipmethodList;
        
        Country__c c = new Country__c(Country_Code__c='US', Country_Name__c ='United States');
        insert c;
        State__c state = new State__c( Country__c= c.id, State_Code__c='NY',  State_Name__c='Newyork');
        insert state;
        
        List<AddressBook__c> addressList=new List<AddressBook__c> ();
        AddressBook__c address = new AddressBook__c(Address__c='addr1', State__c= state.id, Destination_Name__c = 'Dest1', Shipto_Company__c = 'shiptocomp' , Country__c = c.id, Active__c = true, Account__c = acct.id, Phone__C ='(981) 130-9977', Zip__c='33449' );
        addressList.add(address);
        insert addressList;
        
        List<OrderDestination__c> odList=new List<OrderDestination__c> ();
        OrderDestination__c od = new OrderDestination__c();
        od.AddressBook__c = address.id;
        od.Order__c = ord.id;
        od.Shipping_Method__c = shipmethod.id;
        odList.add(od);

        insert odList;
                      
        POSItemGenericName__c genItem = new POSItemGenericName__c(GenericName__c='GenName', Active__c = true,Account__c = acct.id, Inventory_Seasonal_Program__c = 'Seasonal Program');
        insert genItem;
        
        ItemColor__c color = new ItemColor__C( Color__c='blue');
        insert color;
        ItemSize__c size = new ItemSize__c(size__C ='SM');
        insert size;
        
        List<Brand__c> brandList=new List<Brand__c> ();
        Brand__c brand = new Brand__c(Brand_Name__c='testBrand', Active__c = true, Account__c = acct.id);
        brandList.add(brand);
        insert brandList;
        
        List<Item_Type__c> itemtypeList=new List<Item_Type__c> ();
        Item_Type__c itemtype = new Item_Type__c(Item_Type__c='testItemType', Active__c = true, Account__c = acct.id);
        itemtypeList.add(itemtype);
        insert itemtypeList;
        
        List<POS_Item__c> posItemList=new List<POS_Item__c> ();        
        POS_Item__c posItem = new  POS_Item__c(Item_No__c='itm1', item_Name__c= 'Name1', Active__c = true, Brand__c = brand.Id, Type_of_Item__c = itemtype.id, Account__c = acct.id, ItemColor__c=color.id, ItemSize__c = size.id, POSItemGenericName__c = genItem.id);
        posItemList.add(posItem);
        insert posItemList ;
        
        
        List<OrderDestinationItem__c> odiList=new List<OrderDestinationItem__c> ();
        
        OrderDestinationItem__c odi = new OrderDestinationItem__c();
        odi.OrderDestination__c = od.id;
        odi.POS_Item__c = posItem.id;
        odi.Quantity__c = 100;
        odi.Wave_Order_Number__c='1234';
        odi.Warehouse_Transaction_Number__c='1234';
        odi.Warehouse_Order_Status__c='Closed';
        odiList.add(odi);
        
        insert odiList;
        List<Email_Notification__c> emailList=new List<Email_Notification__c> ();
        Email_Notification__c email=new Email_Notification__c(Name='DFV Submitted Order',Account_Name__c='DFV',To_Addresses_List__c='sanjana@uxltechnologies.net',Cc_Addresses_List__c='jaya.prasad@uxltechnologies.net',Active__c=true,Active_For_Record_User__c=true);
        Email_Notification__c email2=new Email_Notification__c(Name='DFV Failed Order',Account_Name__c='DFV',To_Addresses_List__c='vanditha@uxltechnologies.net',Cc_Addresses_List__c='varsha@uxltechnologies.net',Active__c=true,Active_For_Record_User__c=true);
      
        emailList.add(email);
        emailList.add(email2);
        insert emailList;
        
       
        // start the test execution context      
        Test.startTest();
            List<String> waveOrderTransactionNumbersList=new List<String> {'1234','12345'};
            EmailNotificationForOrders.sendNotificationForSubmittedWaveOrders(waveOrderTransactionNumbersList);
            odi.Warehouse_Transaction_Number__c=null;
            odi.Order_Destination_Item_Status__c ='Failed to submit';
            update odi;
            EmailNotificationForOrders.sendNotificationForFailedToSubmitWaveOrders (new List<String> {'1234','12345'});
          //  EmailNotificationForOrders.sendNotificationForFailedToSubmitWaveOrders (new List<String> {'12345'});
        Test.stopTest();
    }

}