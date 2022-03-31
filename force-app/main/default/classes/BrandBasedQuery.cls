public class BrandBasedQuery {
    
    
     @AuraEnabled(cacheable=true)
    public static string ReportWithTotalQuantity(string ProgramId)
    {
        
          list<Program_Item__c>  programPosItems  = [SELECT Program_Item__c.POS_Item_Id__c           
                                                     FROM Program_Item__c
                                                     WHERE Program_Item__c.Program__c=:ProgramId];
    
    
          system.debug('PosItemListForProgram----->'+programPosItems);
        
        
        
         list<Brand__c> listofBrand = [SELECT Brand_Name__c FROM Brand__c];
        
         list<finalResult> finalbrandlist = new list<finalResult>();
        for(Brand__c Brand : listofBrand)
        {
            finalResult finalbrand = new finalResult();
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
                                                                      WHERE ( (OrderDestination__r.Order__r.Program__c = : ProgramId) AND (OrderDestinationItem__c.POS_Item__r.Brand__r.Brand_Name__c = : Brand.Brand_Name__c) )];
            system.debug('OrderBasedonBrand---->'+orderDestinationItemsList);
            
            
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
                    if(programPosItem.POS_Item_Id__c == orderDestinationItem.POS_Item_ID__c)
                    {
                        totalquantity +=  orderDestinationItem.Quantity__c;
                        
                        posItemWithTotalQuantity.PosItemName = orderDestinationItem.POSItemName__c;
                        posItemWithTotalQuantity.Price = orderDestinationItem.POS_Item__r.Price__c;
                        posItemWithTotalQuantity.Brand = orderDestinationItem.POS_Item__r.Brand__r.Brand_Name__c;
                        posItemWithTotalQuantity.PosItemNumber = orderDestinationItem.POS_Item__r.Item_No__c;
                        posItemWithTotalQuantity.ItemType = orderDestinationItem.POS_Item__r.Type_of_Item__r.Item_Type__c;
                        posItemWithTotalQuantity.ProgramName = orderDestinationItem.OrderDestination__r.ProgramName__c;
                        posItemWithTotalQuantity.PackOf = orderDestinationItem.POS_Item__r.Pack_Of__c;
                        posItemWithTotalQuantity.TotalQuantity = totalquantity;
                        posItemWithTotalQuantity.PosItemId = programPosItem.POS_Item_Id__c;
                        
                        //Newly Added by VB and JP : To calculate total amount and Total ordered Pieces on 30.04.2020 6.30PM
                        posItemWithTotalQuantity.TotalAmount = totalquantity*orderDestinationItem.POS_Item__r.Price__c ;
                        posItemWithTotalQuantity.TotalPiecesOrdered = totalquantity*orderDestinationItem.POS_Item__r.Pack_Of__c;
                    }
                    
                }
                
                system.debug('posItemWithTotalQuantity---->'+posItemWithTotalQuantity);
                //Get list of brand 
              
                
                if(posItemWithTotalQuantity.PosItemNumber != null)
                {
                     posItemWithTotalQuantityList.add(posItemWithTotalQuantity);
                }
                
                
                totalquantity = 0;
            }
            //total amount for brand

            finalbrand.finalResult = posItemWithTotalQuantityList;
            finalbrand.Brandname = Brand.Brand_Name__c;
            finalbrandlist.add(finalbrand);
    }
        
        system.debug('finalbrandlist---->'+finalbrandlist);
   return 'Ok';
}
    
    public class finalResult
    {
        
        public list<ItemDetailsWithTotalQuantity> finalResult {get; set;}
        public string Brandname {get; set;}
        
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