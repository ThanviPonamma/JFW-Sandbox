public class TFEInventoryOrderReportApex {
    

    @AuraEnabled(cacheable=true)
    public static list<ItemDetailsWithTotalQuantity> ReportWithTotalQuantity()
    {
        system.debug('Class Reched----->');
      
        //Step 1:Get the list of order Destination Items for the program - Start here
        List<OrderDestinationItem__c> orderDestinationItemsList = [SELECT  OrderDestination__r.ProgramName__c,
        POS_Item__r.Brand__r.Brand_Name__c,
        OrderDestination__r.Id,
        Id,    
        POS_Item__r.Item_No__c,
        Quantity__c,
        POSItemName__c,
        POS_Item_ID__c,
        POS_Item__r.Type_of_Item__r.Item_Type__c,
        POS_Item__r.Pack_Of__c,
        POS_Item__r.Price__c,
        OrderDestination__r.AddressBook__r.Shipto_Name__c,
        OrderDestination__r.AddressBook__r.Shipto_Company__c,
        OrderDestination__r.AddressBook__r.Address__c,
        OrderDestination__r.AddressBook__r.City__c,
        OrderDestination__r.AddressBook__r.Zip__c,
        OrderDestination__r.AddressBook__r.State__r.State_Name__c,
        OrderDestination__r.AddressBook__r.Email__c,
        OrderDestination__r.AddressBook__r.Phone__c,
        OrderDestination__r.TrackingNos__c,
        OrderDestination__r.Shipping_Method__r.Shipping_Method_Name__c,
        OrdStatus__c,
        OrderName__c,
        Total_Line_Amount__c,
        CreatedDate,
        CreatedBy.Name
   FROM OrderDestinationItem__c 
   WHERE OrderDestination__r.Order__r.Program__c = NULL AND Account_Name__c='DFV' AND CreatedBy.Id
   =:UserInfo.getUserId()];
        //Total amount and Total pices Ordered to form the result
        List<ItemDetailsWithTotalQuantity> dfvItemDetailsWithTotalQuantities = new List<ItemDetailsWithTotalQuantity>();
        
        
        //For each pos item get the list of order destination items 
        //Result - list of order destinations for each pos item.
        for(OrderDestinationItem__c ordDestItems : orderDestinationItemsList)
        {
            Integer totalQuantity = 0;
            decimal totalAmount = 0.0;
            Integer totalPiecesOrdered = 0;
            
            //For each order destinations calculate the total Quantity , Total amount and Total pieces Ordered  
           // for(OrderDestinationItem__c ordDestItem :ordDestItems)
           // {
                totalQuantity += Integer.valueOf(ordDestItems.Quantity__c);
           // }
            //To calculate Total Amount = Price of * Total Quantity Ordered
            totalAmount = totalQuantity * ordDestItems.POS_Item__r.Price__c;
            //To calculate TotalPiecesOrdered= Pack Of * Total Quantity Ordered
            totalPiecesOrdered = totalQuantity * Integer.valueOf(ordDestItems.POS_Item__r.Pack_Of__c);
            
            
            ItemDetailsWithTotalQuantity dfvItemDetailsWithTotalQuantity = new ItemDetailsWithTotalQuantity();
            //Add the ordered items details to the dfvItemDetailsWithTotalQuantities
            dfvItemDetailsWithTotalQuantity.PosItemId = ordDestItems.POS_Item_ID__c;
            dfvItemDetailsWithTotalQuantity.PosItemNumber = ordDestItems.POS_Item__r.Item_No__c;
            dfvItemDetailsWithTotalQuantity.PosItemName = ordDestItems.POSItemName__c;
            dfvItemDetailsWithTotalQuantity.Brand = ordDestItems.POS_Item__r.Brand__r.Brand_Name__c;
            dfvItemDetailsWithTotalQuantity.ItemType = ordDestItems.POS_Item__r.Type_of_Item__r.Item_Type__c;
            dfvItemDetailsWithTotalQuantity.Price = ordDestItems.POS_Item__r.Price__c;
            dfvItemDetailsWithTotalQuantity.PackOf = ordDestItems.POS_Item__r.Pack_Of__c;
            dfvItemDetailsWithTotalQuantity.TotalQuantity = totalQuantity;
            dfvItemDetailsWithTotalQuantity.TotalAmount = totalAmount;
            dfvItemDetailsWithTotalQuantity.OrderName = ordDestItems.OrderName__c;
            dfvItemDetailsWithTotalQuantity.OrderStatus = ordDestItems.OrdStatus__c;
            dfvItemDetailsWithTotalQuantity.ShipToName = ordDestItems.OrderDestination__r.AddressBook__r.Shipto_Name__c;
            dfvItemDetailsWithTotalQuantity.ShipToCompany = ordDestItems.OrderDestination__r.AddressBook__r.Shipto_Company__c;
            dfvItemDetailsWithTotalQuantity.Address = ordDestItems.OrderDestination__r.AddressBook__r.Address__c;
            dfvItemDetailsWithTotalQuantity.City = ordDestItems.OrderDestination__r.AddressBook__r.City__c;
            dfvItemDetailsWithTotalQuantity.Zip = ordDestItems.OrderDestination__r.AddressBook__r.Zip__c;
            dfvItemDetailsWithTotalQuantity.State = ordDestItems.OrderDestination__r.AddressBook__r.State__r.State_Name__c;
            dfvItemDetailsWithTotalQuantity.ShippingMethod = ordDestItems.OrderDestination__r.Shipping_Method__r.Shipping_Method_Name__c;
            dfvItemDetailsWithTotalQuantity.Email = ordDestItems.OrderDestination__r.AddressBook__r.Email__c;
            dfvItemDetailsWithTotalQuantity.Phone = ordDestItems.OrderDestination__r.AddressBook__r.Phone__c;  
            dfvItemDetailsWithTotalQuantity.OrderedBy = ordDestItems.CreatedBy.Name;
            dfvItemDetailsWithTotalQuantity.TrackingNumber = ordDestItems.OrderDestination__r.TrackingNos__c;
            dfvItemDetailsWithTotalQuantity.CreatedDate = ordDestItems.CreatedDate;
            //Add each dfvItemDetailsWithTotalQuantity to the dfvItemDetailsWithTotalQuantities list
            dfvItemDetailsWithTotalQuantities.add(dfvItemDetailsWithTotalQuantity);
       }
       system.debug('DFVItemDetailsWithTotalQuantities----->'+dfvItemDetailsWithTotalQuantities);
       system.debug('DFVItemDetailsWithTotalQuantities Size----->'+dfvItemDetailsWithTotalQuantities.size());
       //Return to the front end
       return dfvItemDetailsWithTotalQuantities;
   //Newly Add by JP , RM , VB on May 12 , 2020. Because to reduce the Apex CUP Time Limit for handling bulk data**/
  } 
    
    public class ItemDetailsWithTotalQuantity
    {
        @AuraEnabled
        public string OrderName{get;set;}
        @AuraEnabled
        public string OrderStatus{get;set;}
        @AuraEnabled
        public string ShipToName{get;set;}
        @AuraEnabled
        public string ShipToCompany{get;set;}
        @AuraEnabled
        public string Address{get;set;}
        @AuraEnabled
        public string City{get;set;}
        @AuraEnabled
        public string Zip{get;set;}
        @AuraEnabled
        public string State{get;set;}
        @AuraEnabled
        public string ShippingMethod{get;set;}
        @AuraEnabled
        public string Email{get;set;}
        @AuraEnabled
        public string Phone{get;set;}
        @AuraEnabled
        public string PosItemId {get;set;}
        @AuraEnabled
        public string PosItemNumber {get;set;}
        @AuraEnabled
        public string PosItemName {get;set;}
        @AuraEnabled
        public string Brand {get;set;}
        @AuraEnabled
        public string ItemType {get;set;}
        @AuraEnabled
        public decimal Price {get;set;}
        @AuraEnabled
        public decimal PackOf {get;set;}
        @AuraEnabled
        public decimal TotalQuantity {get;set;}
        @AuraEnabled
        public decimal TotalAmount {get;set;}
        @AuraEnabled
        public string OrderedBy {get;set;}
        @AuraEnabled
        public string TrackingNumber {get;set;}
        @AuraEnabled
        public DateTime CreatedDate {get;set;}
           
    } 

    
}