@isTest
public class DFVComponentControllerTest {
    @isTest
    private static void controllerTest()
    {
        Account addAcct = new Account(Name='DFV');
        insert addAcct ;
        Contact addContact=new Contact(LastName='Add testing',AccountId=addAcct.Id);
        insert addContact;
        Profile addprofile=[SELECT Name FROM Profile WHERE Name='Customer Community Plus User' LIMIT 1];
        User addcommunityUser = new User(Alias = 'standt', Email='standarduser1@testorg.com', 
                                         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                         LocaleSidKey='en_US', ProfileId = addprofile.Id, 
                                         TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1@testorg.com',ContactId=addContact.Id);
        
        insert addcommunityUser;
        Country__c addcountry=new Country__c(Active__c=true , Country_Code__c='countryCode1' , Country_Name__c='addcountryName');
        insert addcountry;
        State__c addstate = new State__c(State_Name__c='testState1', Active__c = true, Country__c=addcountry.id ,State_Code__c='stateCode111');
        insert addstate ;
        Territory__c addterritory = new Territory__c (Territory_Name__c='testTerritory',Active__c=true,Account__c=addAcct.Id);
        insert addterritory;
        States_Territory__c addstateTerritory = new States_Territory__c (State__c = addstate.Id,Territory__c= addterritory.Id);
        insert addstateTerritory;
        Users_Territory__c addusersTerritory = new Users_Territory__c (Territory__c= addterritory.Id,User__c=UserInfo.getUserId());
        insert addusersTerritory;
        DFV_Email_Notifications__c DFVCustomSetting=new DFV_Email_Notifications__c(Name='DFV',Cc_Addresses_List__c='Pradeep@uxltechnologies.net');
        insert DFVCustomSetting;
        Brand__c brand = new Brand__c (Brand_Name__c='BrandNameSelect',Active__c=true,Account__c=addAcct.Id);
        insert brand;
        Item_Type__c itemType= new Item_Type__c(Item_Type__c='itemTypeSelect',Active__c=true,Account__c=addAcct.Id);
        insert itemType;
        POS_Item__c posItem= new POS_Item__c (Item_No__c='Test-No-01',Item_Name__c='testPosItemName',Available_Stock__c=0,Account__c=addAcct.Id,Brand__c=brand.Id,Type_of_Item__c=itemType.Id,Active__c=true);
        insert posItem;
        
        POS_Item__c posItem2= new POS_Item__c (Item_No__c='Test-No-02',Item_Name__c='testPosItemName',Available_Stock__c=0,Account__c=addAcct.Id,Brand__c=brand.Id,Type_of_Item__c=itemType.Id,Active__c=true);
        insert posItem2;
        
        Shipping_Method__c shippingMethod = new Shipping_Method__c(Account__c=addAcct.Id , Active__c=true , ApprovalRequired__c=true , Shipping_Method_Name__c='shippingMethod1');
        insert shippingMethod;
        
        Shipping_Method__c shippingMethod2 = new Shipping_Method__c(Account__c=addAcct.Id , Active__c=true , ApprovalRequired__c=false , Default__c=true , Shipping_Method_Name__c='shippingMethod2');
        insert shippingMethod2;
        
        AddressBook__c addressBook = new AddressBook__c(Account__c=addAcct.Id , Destination_Name__c='destinationName' , Shipto_Company__c='shipToCompany', State__c=addstate.Id,Phone__c='(916) 744-1139') ;
        insert addressBook;
        
        AddressBook__c addressBook2 = new AddressBook__c(Account__c=addAcct.Id , Destination_Name__c='destinationName2' , Shipto_Company__c='shipToCompany2', State__c=addstate.Id,Phone__c='(147) 744-1139') ;
        insert addressBook2;
        Order__c order = new Order__c(Account__c=addAcct.Id);
        insert order;
        ShoppingCart__c shoppingCart = new ShoppingCart__c(Account__c=addAcct.Id ,CartStatus__c='Open',Inventory_Seasonal_Program__c='Inventory',DFV_Order_Number__c=order.Id);
        insert shoppingCart;
        
        ShoppingCartItems__c shoppingCartItems = new ShoppingCartItems__c(Active__c=true, POS_Item__c=posItem.Id,ShoppingCart__c=shoppingCart.Id);
        insert shoppingCartItems;
        
        
        
        OrderDestination__c orderDestination = new OrderDestination__c(Shipping_Method__c=shippingMethod.Id,OrderDest_Status__c='Open',AddressBook__c= addressBook2.Id,Order__c=order.Id);
        insert orderDestination;
        
        OrderDestinationItem__c orderDestinationItem = new OrderDestinationItem__c(OrderDestination__c=orderDestination.Id, POS_Item__c=posItem.Id);
        insert orderDestinationItem;
        
        Test.startTest();
        DFVComponentController.objAccount=NULL;
        System.runAs([SELECT Id FROM User WHERE Id=:UserInfo.getUserId()][0]){
            DFVComponentController.getUserDetails();
        }
        DFVComponentController.getAccount();
        DFVComponentController.loadCartItemsList();
        Test.stopTest();        
    }
    
    
}