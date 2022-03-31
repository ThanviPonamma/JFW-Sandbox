public class UserOrderSummary {
     //Created on: 05.05.2020 
     //Created by: VB,JP,SM 
    
     //Aim 1 :To get the program List
     //Aim 2: To get the list of User order details with budget information for a program.
    
    //Aim of Method:  
    //Step 1 : To get the list of programs.(For the front end- User program select  dropdown)
    @AuraEnabled(cacheable=true)
    public static List<Program__c> getProgramList()
    { 
         //Step 1 : Get the list of programs 
         List<Program__c> programList = [SELECT Id,Name__c FROM Program__c];
         system.debug('programList---->'+programList);
         return programList; 
    }
    
    //Aim 2 :To get the list of User order details with budget information for a program.
    @AuraEnabled(cacheable=true)
    public static List<UserOrderDetails> ReportWithUserOrders(string programId)
    {
        
        //Step 1 : To get a chair name , chair user name , budget allocated , budget available
        // from chair budget table and stored it in 'ProgramChairBudget'
           List<Chair_Budget__c> ProgramChairBudget = [SELECT Allocated_Budget_Updated__c,
                                                              Available_Chair_Budget__c,
                                                              Consumed_Budget__c,
                                                              Shared_Budget__c,
                                                              Chair_User_Name__c,
                                                              Chair__r.Chair_Name__c,
                                                              Program__r.Name__c
                                                        FROM Chair_Budget__c 
                                                        WHERE ((Program__c = :programId) AND (Chair__r.Chair_Name__c != null) )];
            system.debug('ProgramChairBudget'+ ProgramChairBudget);
           system.debug('ProgramChairBudget'+ ProgramChairBudget.size());
        

          //Step 2 : To hold the list of Ordered by ,
          // order name , order created date , order status , Total Order Amount , 
          //Program name and Program Id.
          //and stored it in 'orderDestinationList'
           List<OrderDestination__c> orderDestinationList = [SELECT Order_Amount__c,
                                                                    ProgramName__c,
                                                                    OrderName__c,
                                                                    OrdStatus__c,
                                                                    Order_owner__c,
                                                                    Order__r.Program__r.Id,
                                                                    Order_Date__c
                                                              FROM OrderDestination__c 
                                                              WHERE ((Order__r.Program__c = :programId))];
        system.debug('OrderDestinations'+ orderDestinationList);
        system.debug('OrderDestinations'+ orderDestinationList.size());

        List<UserOrderDetails> userOrderDetailsSummaryList = new List<UserOrderDetails>();
        
        
       
        //Step 3: Compare ProgramChairBudget and orderDestinationList and 
        //match the order details with user chair details using user name.
         for(Chair_Budget__c chairUser : ProgramChairBudget)
         {
              for(OrderDestination__c orderDetails : orderDestinationList)
              {
                  UserOrderDetails userOrderDetailsSummary = new UserOrderDetails();
                  system.debug('owner name =' +orderDetails.Order_owner__c);
                  system.debug('chair user name =' +chairUser.Chair_User_Name__c);
                  if((chairUser.Chair_User_Name__c == orderDetails.Order_owner__c))
                  {
                     userOrderDetailsSummary.ChairName = chairUser.Chair__r.Chair_Name__c;
                     userOrderDetailsSummary.ChairUserName = chairUser.Chair_User_Name__c;
                     userOrderDetailsSummary.BudgetAllocated = chairUser.Allocated_Budget_Updated__c;
                     userOrderDetailsSummary.BudgetAvailable = chairUser.Available_Chair_Budget__c; 
                     userOrderDetailsSummary.OrderName = orderDetails.OrderName__c;
                     userOrderDetailsSummary.OrdStatus = orderDetails.OrdStatus__c;
                     userOrderDetailsSummary.TotalOrderAmount = orderDetails.Order_Amount__c;
                     userOrderDetailsSummary.OrderDate = orderDetails.Order_Date__c; 
                     userOrderDetailsSummary.programName = orderDetails.ProgramName__c; 
                     
                    
                     userOrderDetailsSummaryList.Add(userOrderDetailsSummary);
                    
                     
                  } 
               }
         }
        
        system.debug('userOrderDetailsSummaryList'+userOrderDetailsSummaryList.size());
        return userOrderDetailsSummaryList;
    
      } 
    
 public class UserOrderDetails 
 {  
    @AuraEnabled
    public String ChairName {get;set;}
    @AuraEnabled
    public String programName {get;set;}
    @AuraEnabled
    public String ChairUserName {get;set;}
    @AuraEnabled
    public Decimal BudgetAllocated {get;set;}
    @AuraEnabled
    public Decimal BudgetAvailable {get;set;}
    @AuraEnabled
    public String OrderName {get;set;}
    @AuraEnabled
    public String OrdStatus {get;set;}
    @AuraEnabled
    public Decimal TotalOrderAmount {get;set;}
    @AuraEnabled
    public Date OrderDate {get;set;}
  }
}