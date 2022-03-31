public class TFEInventoryOrderReport {
    

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
        CreatedDate
   FROM OrderDestinationItem__c 
   WHERE OrderDestination__r.Order__r.Program__c = NULL AND Account_Name__c='DFV'];
      
        map<string, List<OrderDestinationItem__c>> posItemOrderDestinationItemList = new map<string, List<OrderDestinationItem__c>>();
        for(OrderDestinationItem__c orderdestinationItem : orderDestinationItemsList)
        {
            //Step 2.1: For each order Destination Items get the pos Item number
            string posItemNumber = orderdestinationItem.POS_Item__r.Item_No__c;
            
            //Step 2.2: Check if this pos item is in the posItemOrderDestinationItemList 
            if(posItemOrderDestinationItemList.keySet().contains(posItemNumber))
            {
                //Step 2.2.1: If yes, Add that order destination item to the map as a value under that pos item.
                posItemOrderDestinationItemList.get(posItemNumber).add(orderdestinationItem);
            }
            else 
            {
                //Step 2.2.2: Else create a new key for the  pos item number and add that order destination item to the map under positem.
                posItemOrderDestinationItemList.put(posItemNumber, new List<OrderDestinationItem__c>{orderdestinationItem});
            }
        }
        system.debug('posItemOrderDestinationItemList----->'+posItemOrderDestinationItemList);
        system.debug('posItemOrderDestinationItemList----->'+posItemOrderDestinationItemList.size());
        
        
        
        
        //Step 3 : Now for each pos item calculate the total Quantity ,
        //Total amount and Total pices Ordered to form the result
        List<ItemDetailsWithTotalQuantity> dfvItemDetailsWithTotalQuantities = new List<ItemDetailsWithTotalQuantity>();
        
        
        //For each pos item get the list of order destination items 
        //Result - list of order destinations for each pos item.
        for(List<OrderDestinationItem__c> ordDestItems : posItemOrderDestinationItemList.values())
        {
            Integer totalQuantity = 0;
            decimal totalAmount = 0.0;
            Integer totalPiecesOrdered = 0;
            
            //For each order destinations calculate the total Quantity , Total amount and Total pieces Ordered  
            for(OrderDestinationItem__c ordDestItem :ordDestItems)
            {
                totalQuantity += Integer.valueOf(ordDestItem.Quantity__c);
            }
            //To calculate Total Amount = Price of * Total Quantity Ordered
            totalAmount = totalQuantity * ordDestItems[0].POS_Item__r.Price__c;
            //To calculate TotalPiecesOrdered= Pack Of * Total Quantity Ordered
            totalPiecesOrdered = totalQuantity * Integer.valueOf(ordDestItems[0].POS_Item__r.Pack_Of__c);
            
            
            ItemDetailsWithTotalQuantity dfvItemDetailsWithTotalQuantity = new ItemDetailsWithTotalQuantity();
            //Add the ordered items details to the dfvItemDetailsWithTotalQuantities
            dfvItemDetailsWithTotalQuantity.PosItemId = ordDestItems[0].POS_Item_ID__c;
            dfvItemDetailsWithTotalQuantity.PosItemNumber = ordDestItems[0].POS_Item__r.Item_No__c;
            dfvItemDetailsWithTotalQuantity.PosItemName = ordDestItems[0].POSItemName__c;
            dfvItemDetailsWithTotalQuantity.Brand = ordDestItems[0].POS_Item__r.Brand__r.Brand_Name__c;
            dfvItemDetailsWithTotalQuantity.ItemType = ordDestItems[0].POS_Item__r.Type_of_Item__r.Item_Type__c;
            dfvItemDetailsWithTotalQuantity.Price = ordDestItems[0].POS_Item__r.Price__c;
            dfvItemDetailsWithTotalQuantity.PackOf = ordDestItems[0].POS_Item__r.Pack_Of__c;
            dfvItemDetailsWithTotalQuantity.TotalQuantity = totalQuantity;
            dfvItemDetailsWithTotalQuantity.TotalAmount = totalAmount;
            dfvItemDetailsWithTotalQuantity.TotalPiecesOrdered = totalPiecesOrdered;
            
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
        public decimal TotalPiecesOrdered {get;set;}
           
    } 

    
}