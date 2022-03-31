//Created on: 11.05.2020 
     //Created by: VB,JP
    
     //Aim 1:To get the list of programs. (For the front end- User program select  dropdown)
     //Aim 2:To get all chair name , chair user name, budget allocated, budget available, Program Name, Program ID from chair budget table
     // and all Ordered by , order name, order created date, order status, Total Order Amount , Program name and Program Id from Order destination table for a program.
     //Aim 3:Compare the  Chair budget list and order destination list to get the list of users with no orders and send the Chair name, the user associated with the chair, and the budget allocated to the chair for the program and send it to the front end with Order Status Marked ‘Not Started’.

    
public class DFVProgramChairBudgetForUserWithNoOrder 
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
    public static List<UserChairBudgetDetails> UserReportWithNoOrders(string programId)
    {
        
        //Step 1 : To get a chair name , chair user name , budget allocated , budget available
        // from chair budget table for the program and stored it in 'ProgramChairBudget'
        // Condition: 1. Get the Chair budget has chair name and user
        //            2. Get the Chair budget for the program
        List<Chair_Budget__c> ProgramChairBudget = [SELECT Allocated_Budget_Updated__c,
                                                    Available_Chair_Budget__c,
                                                    Consumed_Budget__c,
                                                    Shared_Budget__c,
                                                    Chair_User_Name__c,
                                                    Chair__r.Chair_Name__c,
                                                    Program__r.Name__c
                                                    FROM   Chair_Budget__c 
                                                    WHERE  ((Program__c = :programId)  AND (Chair__r.Chair_Name__c != null) AND (Chair_User_Name__c != null))];
        
        system.debug('ProgramChairBudget'+ ProgramChairBudget);
        system.debug('ProgramChairBudget'+ ProgramChairBudget.size());
        
        
        //Step 2 : To get the list of User who placed order for the program
        //and stored it in 'orderDestinationList'
        List<OrderDestination__c> orderDestinationList = [SELECT  Order_owner__c
                                                          FROM    OrderDestination__c 
                                                          WHERE  ((Order__r.Program__c = :programId))];
        
        system.debug('OrderDestinations'+ orderDestinationList);
        system.debug('OrderDestinations'+ orderDestinationList.size());
        
        
        //Step 2.1: from step 2 we will get list user is possible of duplicate user because one user can place many orders
        set<string> programOrderdestinationUserSet = new set<string>(); 
        for(OrderDestination__c OrdDestination :orderDestinationList )
        {
            programOrderdestinationUserSet.Add(OrdDestination.Order_owner__c);
        }
        system.debug('programOrderdestinationUserSet'+programOrderdestinationUserSet.size());
        
        
        
        //Step 3: Get the All user list who has the chair budget from programChairBudgetList and Stored it in allProgramUsersList 
        set<string> allProgramUsersList = new set<string>();
        for(Chair_Budget__c chairBudget :ProgramChairBudget )
        {
            allProgramUsersList.Add(chairBudget.Chair_User_Name__c);
        }
        system.debug('allProgramUsersList'+ allProgramUsersList.size());
        
        
        
        //Step 4 :Compare the two variables(programOrderdestinationUserSet, allProgramUsersList) and remove the users who have placed the orders
        //to get the users who are yet to start the order for the Program and Store in the Variable 'programUsersWithNoOrder'.
        set<string> programUsersWithNoOrder = allProgramUsersList;
        for(string userWithOrder : programOrderdestinationUserSet)
        {
            for(string user: programUsersWithNoOrder)
            {
                if(user == userWithOrder)
                {
                    programUsersWithNoOrder.remove(user);
                }
            }
        }
        system.debug('programUsersWithNoOrder'+ programUsersWithNoOrder.size());
        
        //step 5 : For each programUsersWithNoOrder get the chair budget details from programChairBudgetList 
        //and store it in userChairBudgetDetailsSummaryList
        List<UserChairBudgetDetails> userChairBudgetDetailsSummaryList = new List<UserChairBudgetDetails>();
        
        for(string userWithNoUser : programUsersWithNoOrder)
        {
            for(Chair_Budget__c chairBudget : ProgramChairBudget)
            {       
                UserChairBudgetDetails userChairBudgetDetailsSummary = new UserChairBudgetDetails();
                if(userWithNoUser == chairBudget.Chair_User_Name__c)
                {
                    userChairBudgetDetailsSummary.ChairName = chairBudget.Chair__r.Chair_Name__c;
                    userChairBudgetDetailsSummary.ChairUserName = chairBudget.Chair_User_Name__c;
                    userChairBudgetDetailsSummary.BudgetAllocated = chairBudget.Allocated_Budget_Updated__c;
                    userChairBudgetDetailsSummary.BudgetAvailable = chairBudget.Available_Chair_Budget__c; 
                    userChairBudgetDetailsSummary.OrdStatus ='Not Started';
                    
                    userChairBudgetDetailsSummaryList.Add(userChairBudgetDetailsSummary);
                }
            }
        }
        
        system.debug('userChairBudgetDetailsSummaryList'+ userChairBudgetDetailsSummaryList.size());
        system.debug('userChairBudgetDetailsSummaryList'+ userChairBudgetDetailsSummaryList);
        for(UserChairBudgetDetails UserChairBudgetDetail : userChairBudgetDetailsSummaryList )
        {
            system.debug('UserChairBudgetDetail'+ UserChairBudgetDetail);
        }
        return userChairBudgetDetailsSummaryList;
    }
               
        
    public class UserChairBudgetDetails 
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
        public String OrdStatus {get;set;}
    }
        
}