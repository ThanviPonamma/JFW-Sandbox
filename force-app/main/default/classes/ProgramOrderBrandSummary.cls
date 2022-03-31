public class ProgramOrderBrandSummary 
{
    //Created on: 01.05.2020 4.30PM
    //Created by: VB,JP,SM 
    //Aim 1: To get the list of Program Brands and it's item Total Order Amount.
    //Aim 2 :To get the program List
    
    //Aim of Method: To get the list of program.
    @AuraEnabled(cacheable=true)
    public static List<Program__c> getProgramList()
    { 
         //Step 1 : Get the list of programs 
         List<Program__c> programList = [SELECT Program__c.Id,Name__c FROM Program__c];
         system.debug('programList---->'+programList);
         return programList; 
    }
    
    
    //Aim of Method: To get the list of Program Brands and it's item Total Order Amount.
    @AuraEnabled(cacheable=true)
    public static list<ProgramBrandTotalAmount> ReportWithTotalBrandOrder(string programId)
    {
        System.debug('Programidreached' +programId);
      //Step 1: Get List of brand from program positem table - start Here 
        list<Program_Item__c> programBrandList =[SELECT Brand_Name__c 
                                                 FROM Program_Item__c 
                                                 WHERE Program_Item__c.Program__c = :programId];
        //System.debug('Brandlist---' +programBrandList);
      //Step 1: Get List of brand from program positem table - End here



      //Step2: programbrandList will have same brand so we converting into set - START HERE
        string uniqueBrandName;
        set<string> uniqueBrandNameSet = new set<string>();
        
        //For each brand from programBrand List get the brand name and add it to the set variable.
        for (Program_Item__c brandList: programBrandList)
        {         
            uniqueBrandName = brandList.Brand_Name__c;
            uniqueBrandNameSet.add(uniqueBrandName);
        }
        //System.debug('BrandList---->'+ uniqueBrandNameSet);
      //Step2: programbrandList will have same brand so we converting into set - END HERE




      //Step3: Get List of order destination items for the  program with total line amount - START HERE
        List<OrderDestinationItem__c> orderDestinationItemsList =   [SELECT  OrderDestination__r.ProgramName__c,
                                                                     POS_Item__r.Brand__r.Brand_Name__c,  
                                                                     Total_Line_Amount__c
                                                                     FROM OrderDestinationItem__c 
                                                                     WHERE ((OrderDestination__r.Order__r.Program__c = :programId AND OrderDestination__r.OrdStatus__c = 'Confirmed'))];
        System.debug('OrderBasedonBrand---->'+orderDestinationItemsList);
      //Step3: Get List of order destination items for the  program with total line amount - END HERE




     //Step 4: Compare two variable 'orderDestinationItemsList' and 'uniqueBrandNameSet' will get the Item total order amount for the brand - START HERE
        list<ProgramBrandTotalAmount> itemstotalAmountListforAllBrandList = new list<ProgramBrandTotalAmount>();
        decimal totalBrandAmount =0;

        for(string brandName : uniqueBrandNameSet)
        {
            ProgramBrandTotalAmount itemstotalAmountListforBrand = new ProgramBrandTotalAmount();
            for(OrderDestinationItem__c orderdestinationItem :orderDestinationItemsList)
            {
                 
                if(brandName == orderdestinationItem.POS_Item__r.Brand__r.Brand_Name__c)
                {
                    totalBrandAmount += orderdestinationItem.Total_Line_Amount__c;
                    itemstotalAmountListforBrand.ProgramName = orderdestinationItem.OrderDestination__r.ProgramName__c;
                    itemstotalAmountListforBrand.BrandName = brandName;
                    itemstotalAmountListforBrand.ItemTotalAmountForBrand = totalBrandAmount;
                }
               
            }
            if(itemstotalAmountListforBrand.BrandName != null ){
                 
                itemstotalAmountListforAllBrandList.add(itemstotalAmountListforBrand);
            }
           
            totalBrandAmount =0;
         }
      //Step 4: Compare two variable 'orderDestinationItemsList' and 'uniqueBrandNameSet' will get the Item total order amount for the brand - END HERE 
      
         system.debug('brandtotalAmountList'+ itemstotalAmountListforAllBrandList);
         //RETURN THE LIST TO FRONT END
         return itemstotalAmountListforAllBrandList;

    }
   //fUNCTION ENDs HERE
    
    
    
    public class ProgramBrandTotalAmount
    {
        @AuraEnabled
        public string BrandName {get;set;}
        @AuraEnabled
        public string ProgramName {get;set;}
        @AuraEnabled
        public decimal ItemTotalAmountForBrand {get;set;}
    }
    
}