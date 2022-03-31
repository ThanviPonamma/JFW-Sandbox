public class ProgramChairBudgetForUserWithNoOrder 
{
    
    @AuraEnabled(cacheable=true)
    public static List<Program__c> getProgramList()
    { 
         //Step 1 : Get the list of programs 
         List<Program__c> programList = [SELECT Id,Name__c FROM Program__c];
         system.debug('programList---->'+programList);
         return programList; 
    }
    
    @AuraEnabled(cacheable=true)
    public static List<UserChairBudgetDetailsWithNoOrder> UserReportWithNoOrders(string programId)
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
                                                    FROM   Chair_Budget__c 
                                                    WHERE ((Program__c = :programId)
                                                           AND (Chair__r.Chair_Name__c != null) 
                                                           AND (Chair_User_Name__c != null))];
        
        system.debug('ProgramChairBudget'+ ProgramChairBudget);
        system.debug('ProgramChairBudget'+ ProgramChairBudget.size());
        
        
        //Step 2 : To get the list of Order_owner__c for the program from order destination.
        //and stored it in 'orderDestinationList'
        List<OrderDestination__c> orderDestinationList = [SELECT Order_owner__c
                                                          FROM   OrderDestination__c 
                                                          WHERE  ((Order__r.Program__c = :programId))];
        system.debug('OrderDestinations'+ orderDestinationList);
        system.debug('OrderDestinations'+ orderDestinationList.size());
        
        
        
        //Step 3:To get unique user name who placed order from the "orderDestinationList" and save it in "userListWithOrders"
        set<string> userListWithOrders = new set<string>();
        for(OrderDestination__c OrdDestination :orderDestinationList )
        {
            userListWithOrders.Add(OrdDestination.Order_owner__c);
        }
        system.debug('userListWithOrders'+ userListWithOrders.size());
        
        
        //Step 4:To get all users for the program from the chair budget table and save it in "programUsersListWithBudget" 
        set<string> programUsersListWithBudget = new set<string>();
        for(Chair_Budget__c chairBudget :ProgramChairBudget )
        {
            programUsersListWithBudget.Add(chairBudget.Chair_User_Name__c);
        }
        system.debug('allUsers'+ programUsersListWithBudget.size());
        set<string> usersListWithNoOrder = programUsersListWithBudget;
        
        
        
        //Step 5: To find the set of users with no orders by comparing the  userListWithOrders and  programUsersListWithBudget Variables 
        //and save it in usersListWithNoOrder
        for(string userWithOrder : userListWithOrders)
        {
            for(string programUser: usersListWithNoOrder)
            {
                if(programUser == userWithOrder)
                {
                    usersListWithNoOrder.remove(programUser);
                }
                
            }
        }
        system.debug('programUsersWithNoOrder'+ usersListWithNoOrder.size());
        
        
       
        
        //Step 6: For each user set has no order get chair budget information from ProgramChairBudget variable , set order status to "Not Started" 
        //        and save it in "userChairBudgetDetailsList".
        List<UserChairBudgetDetailsWithNoOrder> userChairBudgetDetailsList = new List<UserChairBudgetDetailsWithNoOrder>();
        for(string userHasNoUser : usersListWithNoOrder)
        {
            for(Chair_Budget__c chairBudget : ProgramChairBudget)
            {       
                UserChairBudgetDetailsWithNoOrder userChairBudgetDetails = new UserChairBudgetDetailsWithNoOrder();
                  
                if(userHasNoUser == chairBudget.Chair_User_Name__c)
                {
                   
                    userChairBudgetDetails.ChairName = chairBudget.Chair__r.Chair_Name__c;
                    userChairBudgetDetails.ChairUserName = chairBudget.Chair_User_Name__c;
                    userChairBudgetDetails.BudgetAvailable = chairBudget.Available_Chair_Budget__c; 
                    userChairBudgetDetails.programName = chairBudget.Program__r.Name__c; 
                    userChairBudgetDetails.OrdStatus ='Not Started';
                    
                    userChairBudgetDetailsList.Add(userChairBudgetDetails);
                    
                }
            }
        }
        
        system.debug('userChairBudgetDetailsSummaryList'+ userChairBudgetDetailsList.size());
        system.debug('userChairBudgetDetailsSummaryList'+ userChairBudgetDetailsList);
        return userChairBudgetDetailsList;
        
    }
       
        
  public class UserChairBudgetDetailsWithNoOrder
  {  
      @AuraEnabled
      public String ChairName {get;set;}
      @AuraEnabled
      public String programName {get;set;}
      @AuraEnabled
      public String ChairUserName {get;set;}
      @AuraEnabled
      public Decimal BudgetAvailable {get;set;}
      @AuraEnabled
      public String OrdStatus {get;set;}
      
  }

}