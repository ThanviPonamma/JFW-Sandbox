@isTest
//Authors:TP
//Date: 10/01/2020
//Aim : To test DFVWaveOrdersAddOrRemovePosItems_Apex class
private class InfiniumWaveOrdersAddOrRemove_ApexTest
{
    @isTest
    private static void testController ()
    {
        Account acct = new Account(Name='Infinium Spirits');
        insert acct ;
        
        Program__c program=new Program__c (Name__c='Testing',Account__c=acct.Id,Start_Date__c=System.today().addDays(-10),
                                           Closing_Date__c=System.today().addDays(-5),
                                           In_Market_Date__c=System.today());
        insert program;
        
        Program__c program1 = new Program__c (Name__c='Spring2020',Account__c=acct.Id,Start_Date__c=System.today().addDays(-10),
                                              Closing_Date__c=System.today().addDays(+10),
                                              In_Market_Date__c=System.today().addDays(+20));
        insert program1;
        
        Brand__c brand = new Brand__c(Brand_Name__c = 'Bota box',Account__c =acct.Id,Active__c = true); 
        insert brand;
        Brand__c brand1 = new Brand__c(Brand_Name__c = 'BlackStalion',Account__c =acct.Id,Active__c = true); 
        insert brand1;
        
        Item_Type__c itemType= new Item_Type__c(Item_Type__c='itemTypeSelect',Active__c=true,Account__c=acct.Id);
        insert itemType;
        
        POS_Item__c posItem = new POS_Item__c (Item_No__c='Test-No-01',Item_Name__c='testPosItemName',Pack_Of__c = 2, Price__c = 25,Account__c=acct.Id,Brand__c=brand.Id,Type_of_Item__c=itemType.Id);
        insert posItem;
        
        POS_Item__c posItem1 = new POS_Item__c (Item_No__c='Test-No-02',Item_Name__c='testPosItemName01',Pack_Of__c = 2, Price__c = 25,Account__c=acct.Id,Brand__c=brand.Id,Type_of_Item__c=itemType.Id);
        insert posItem1;
        
        Program_Item__c programPosItem = new Program_Item__c(POS_Item__c = posItem.Id,Program__c = program.Id,On_Hold__c = true);
        insert programPosItem;
        Program_Item__c programPosItem1 = new Program_Item__c(POS_Item__c = posItem1.Id,Program__c = program.Id,On_Hold__c = false);
        insert programPosItem1;
        
        Country__c country=new Country__c(Active__c=true , Country_Code__c='countryCode' , Country_Name__c='countryName');
        insert country;
        
        State__c state = new State__c(State_Name__c='testState', Active__c = true, Country__c=country.id ,State_Code__c='stateCode');
        insert state ;
        
        
        AddressBook__c addressBook = new AddressBook__c(Account__c=acct.Id , Destination_Name__c='destinationName', 
                                                        Shipto_Company__c='shipToCompany', State__c=state.Id);
        insert addressBook;
        
        AddressBook__c addressBook2 = new AddressBook__c(Account__c=acct.Id , Destination_Name__c='destinationName2', 
                                                         Shipto_Company__c='shipToCompany2', State__c=state.Id);
        insert addressBook2;
        
        Order__c order = new Order__c(Account__c = acct.Id, Order_Date__c = system.today() , Order_Status__c = 'open',Program__c = program.Id );
        insert order;
        
        OrderDestination__c orderDestination = new OrderDestination__c(Order__c = order.Id, AddressBook__c =addressBook.Id, OrderDest_Status__c='open',Comet_Order_Status__c='open');
        insert orderDestination;
        
        OrderDestinationItem__c orderDestinationItems = new OrderDestinationItem__c(OrderDestination__c =orderDestination.Id, POS_Item__c = posItem.Id, Quantity__c = 1,On_Hold__c = true,Order_Destination_Item_Status__c='Open',
                                                                                    Sent_To_Warehouse__c=false,
                                                                                    Ready_To_Be_Sent__c=false ,
                                                                                    Wave_Order_Number__c=null, 
                                                                                    Warehouse_Transaction_Number__c=null);
        insert orderDestinationItems;
        
        OrderDestinationItem__c orderDestinationItems1 = new OrderDestinationItem__c(OrderDestination__c =orderDestination.Id, POS_Item__c = posItem1.Id, Quantity__c = 1,On_Hold__c = false,Order_Destination_Item_Status__c='Open',
                                                                                     Sent_To_Warehouse__c=false,
                                                                                     Ready_To_Be_Sent__c=false ,
                                                                                     Wave_Order_Number__c=null, 
                                                                                     Warehouse_Transaction_Number__c=null);
        insert orderDestinationItems1;
        
        
        
        Test.startTest();       
        InfiniumWaveOrdersAddOrRemovePos_Apex.getAccount();
        InfiniumWaveOrdersAddOrRemovePos_Apex.addItemToWithheldItems(program.Id, posItem1.Id);
        InfiniumWaveOrdersAddOrRemovePos_Apex.removeItemFromWithheldItems(program.Id, posItem.Id);
        Test.stopTest();  
    }
    
}