public class ProgramOrderSummary
{
    

    public static Account objAccount;
    //To fetch data about DFV from Standard object Account.
    public static Account getAccount() {  
        
        if(Test.isRunningTest())
        {
            objAccount=[SELECT Id, Name FROM Account
                        WHERE Name LIKE '%DFV%' LIMIT 1];
        }
        else
        {
            objAccount=[SELECT Id, Name FROM Account
                        WHERE Lightning_Community_Id__c=:Network.getNetworkId() LIMIT 1];
        }
        return objAccount; // objAccount object contains data about Mionetto.
    }
    //Created on: 30.04.2020 Created by: VB,JP,SM 
    //Aim:To get the ItemId, Brandname, itemNo, ItemType, ItemName, programName, Price, PackOf, TotalQuantity for a program 
    //from the Order, OrderDestination and OrderDestinationItem,program Item table and send it to the front end.
   @AuraEnabled(cacheable=true)
   public static List<Program__c> getProgramList()
   {
    objAccount = getAccount();
     //Step 1 : Get the list of programs 
     List<Program__c> programList =  [SELECT Id,Name__c From Program__c WHERE Account__c=:objAccount.Id];       
     system.debug('programList---->'+programList);
     return programList; 
        
    }
  
    @AuraEnabled(cacheable=true)
    public static list<ItemDetailsWithTotalQuantity> ReportWithTotalQuantity(string programId)
    {
        system.debug('Class Reched----->');
        system.debug('programId----->'+ programId);
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
                                                                           POS_Item__r.Vendor__c,
                                                                           CreatedDate
                                                                      FROM OrderDestinationItem__c 
                                                                      WHERE ((OrderDestination__r.Order__r.Program__c =:programId) AND (OrdStatus__c ='Confirmed') AND (Quantity__c > 0))];
        
          //system.debug('orderDestinationItemsList----->'+orderDestinationItemsList);
          //system.debug('orderDestinationItemsList----->'+orderDestinationItemsList.size());
        //Step 1:Get the list of order Destination Items for the program - End here
        
     //Commented on May 12 , by: JP , RM , VB Because Apex CPU Time limit exceed for processing bulk data 
          
          //Step 2: Get list of items for the program - Start here
          /**list<Program_Item__c>  programPosItems  = [SELECT POS_Item_Id__c,
                                                     Item_Number__c
                                                     FROM Program_Item__c
                                                     WHERE Program_Item__c.Program__c=:ProgramId];
          system.debug('PosItemListForProgram----->'+programPosItems);
          //Step 2: Get list of items for the program - End here
          //Step 3: Calculate Total quantity for the each pos item - Start here
            List<ItemDetailsWithTotalQuantity> posItemWithTotalQuantityList = new list<ItemDetailsWithTotalQuantity>();
            decimal totalquantity = 0;
            //Step 3.1: for each program pos item compare with program order destination items.
            for (Integer i = 0; i < programPosItems.size(); i++)
            {
                Program_Item__c programPosItem = programPosItems[i];
                ItemDetailsWithTotalQuantity posItemWithTotalQuantity = new ItemDetailsWithTotalQuantity();
                for(OrderDestinationItem__c orderDestinationItem: orderDestinationItemsList)
                {
                    //Step 3.2 If program pos item is match with program order destination items, sum the quantity of all that pos item.
                    if(programPosItem.POS_Item_Id__c == orderDestinationItem.POS_Item_ID__c && programPosItem.Item_Number__c == orderDestinationItem.POS_Item__r.Item_No__c  )
                    {
                        totalquantity +=  orderDestinationItem.Quantity__c;
                        posItemWithTotalQuantity.PosItemId = orderDestinationItem.POS_Item_ID__c;
                        posItemWithTotalQuantity.PosItemName = orderDestinationItem.POSItemName__c;
                        posItemWithTotalQuantity.Price = orderDestinationItem.POS_Item__r.Price__c;
                        posItemWithTotalQuantity.Brand = orderDestinationItem.POS_Item__r.Brand__r.Brand_Name__c;
                        posItemWithTotalQuantity.PosItemNumber = orderDestinationItem.POS_Item__r.Item_No__c;
                        posItemWithTotalQuantity.ItemType = orderDestinationItem.POS_Item__r.Type_of_Item__r.Item_Type__c;
                        posItemWithTotalQuantity.ProgramName = orderDestinationItem.OrderDestination__r.ProgramName__c;
                        posItemWithTotalQuantity.PackOf = orderDestinationItem.POS_Item__r.Pack_Of__c;
                        //Newly Added by VB and JP : To calculate total amount and Total ordered Pieces on 30.04.2020 6.30PM
                        posItemWithTotalQuantity.TotalAmount = totalquantity*orderDestinationItem.POS_Item__r.Price__c ;
                        posItemWithTotalQuantity.TotalPiecesOrdered = totalquantity*orderDestinationItem.POS_Item__r.Pack_Of__c;
                        posItemWithTotalQuantity.TotalQuantity = totalquantity;
                    }
                }
                system.debug('posItemWithTotalQuantity---->'+posItemWithTotalQuantity);
                If(posItemWithTotalQuantity.PosItemId != null && posItemWithTotalQuantity.PosItemNumber != null)
                {posItemWithTotalQuantityList.add(posItemWithTotalQuantity);  }                    
                 totalquantity = 0
            }
           // Step 3: Calculate Total quantity for the each pos item - End here
            system.debug('totalquantity---->'+totalquantity);
            system.debug('posItemWithTotalQuantityList---->'+posItemWithTotalQuantityList);
            return posItemWithTotalQuantityList;**/
    //Commented on May 12 , by: JP , RM , VB Because Apex CPU Time limit exceed for processing bulk data 
   
        
    //Newly Add by JP , RM , VB on May 12 , 2020. Because to reduce the Apex CUP Time Limit for handling bulk data
        
        
        //Step 2 : We have list of program order destination items, Now we are mapping it
        //like for a positem has many order destination item and stored it in posItemOrderdetinationItemList 
        //Reference document - Link : https://docs.google.com/spreadsheets/d/107PJEvlFNV8oMBxDCq3H3AAitNgPGokvzaPhdTxT7jo/edit#gid=0
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
        //system.debug('posItemOrderDestinationItemList----->'+posItemOrderDestinationItemList);
        //system.debug('posItemOrderDestinationItemList----->'+posItemOrderDestinationItemList.size());
        
        
        
        
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
            dfvItemDetailsWithTotalQuantity.ProgramName = ordDestItems[0].OrderDestination__r.ProgramName__c;
            dfvItemDetailsWithTotalQuantity.Vendor = ordDestItems[0].POS_Item__r.Vendor__c;
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
   //Newly Add by JP , RM , VB on May 12 , 2020. Because to reduce the Apex CUP Time Limit for handling bulk data
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
        public string ProgramName {get;set;}
        @AuraEnabled
        public string Vendor {get;set;}
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