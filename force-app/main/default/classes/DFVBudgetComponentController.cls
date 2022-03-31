public class DFVBudgetComponentController {
public static Account objAccount;
    
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
        return objAccount; 
    }
    /** Author: NP,TP
     *  Date:05-Aug-2021 
     *  CR No : DFV-08-AUG-30 
     * Aim: To assign the Account to designation*/
    @AuraEnabled
    public static List<Program__c> loadPrograms_Apex ()
    {
        objAccount=getAccount();
        return [SELECT Id,Active__c,Name__c FROM Program__c
                WHERE Organizataion_Chart_ID__c IN (SELECT ID FROM Organiztaion_Chart__c  WHERE Checkbox__c = true
                AND Account__c=:objAccount.Id ) ];
    }
    @AuraEnabled
     public static String saveProgramBudget_Apex (String programId,Decimal totalMarketingBudget)
     {
         if(String.isNotBlank(programId))
         {
             Program__c program=new Program__c (Id=programId,Program_Budget__c=totalMarketingBudget);
        	update program;
         }
        
         return 'Done';
    }
    @AuraEnabled
    public static List<ChairBudget_FixedPosition> saveChairBudgetList_Apex (String chairBudgetList,String programId)
    {
        List<Chair_Budget__c> chairBudgets=new List<Chair_Budget__c> ();
        for(ChairBudget_FixedPosition eachChairBudget : (List<ChairBudget_FixedPosition>)JSON.deserialize(chairBudgetList, List<ChairBudget_FixedPosition>.class))
        {
            chairBudgets.add(eachChairBudget.chairBudget);
        }
        update chairBudgets;
        return loadChairBudgetList_Apex(programId);
    }

    //Author:Aiyappa Date:14-02-2020
    //The Consumed_Budget__c is introduced to get the consumed budget of the users
   @AuraEnabled
    public static List<ChairBudget_FixedPosition> loadChairBudgetList_Apex(String programId)
    {
        List<ChairBudget_FixedPosition> chairBudgetFixedPosition=new List<ChairBudget_FixedPosition> ();
        List<ChairBudget_FixedPosition> chairBudgetFixedPosition_1=new List<ChairBudget_FixedPosition> ();
        List<ChairBudget_FixedPosition> chairBudgetFixedPosition_2=new List<ChairBudget_FixedPosition> ();
        Map<Id,Fixed_Position__c> Chair_FixedPositionMap=new Map<Id,Fixed_Position__c> ();
        Map<Id,Chair_Budget__c> chairWithChairBudget_Map=new Map<Id,Chair_Budget__c> ();
        Map<Id,Chair_Budget__c> chairBudget_Map=new Map<Id,Chair_Budget__c> ([SELECT Id,Program__r.Program_Budget__c,Allocated_Budget__c,Available_Budget__c,Shared_Budget__c,Chair__r.Chair_Name__c,Chair__r.User__r.Name,Chair__r.Active__c,Program__r.Name__c,
        Chair__r.Level__c,Available_Chair_Budget__c,Consumed_Budget__c 
        FROM Chair_Budget__c WHERE Program__c=:programId]);
        for(Chair_Budget__c Chairbudget : chairBudget_Map.values())
        {
                    chairWithChairBudget_Map.put(ChairBudget.Chair__c,chairBudget);
        }                                                        
        for(Fixed_Position__c fixedPosition : [SELECT Id,Fixed_Position_Name__c,Chair__c FROM Fixed_Position__c
                                              WHERE (Organizataion_Chart__c IN  (SELECT Organizataion_Chart_ID__c FROM Program__c WHERE Id=:programId))
                                              AND (Chair__c IN (SELECT Chair__c FROM Chair_Budget__c WHERE Program__c=:programId))
                                             ORDER BY Fixed_Position_Name__c ])
        {
           Chair_FixedPositionMap.put(fixedPosition.Chair__c,fixedPosition);
               chairBudgetFixedPosition_1.add(new ChairBudget_FixedPosition(chairWithChairBudget_Map.get(fixedPosition.Chair__c),fixedPosition));
        }
        for(Chair_Budget__c chairBudget : chairBudget_Map.values())
        {
            if(!Chair_FixedPositionMap.containsKey(chairBudget.Chair__c))
                 chairBudgetFixedPosition_2.add(new ChairBudget_FixedPosition(chairBudget,new Fixed_Position__c ()));
               
        }
        chairBudgetFixedPosition.addAll(chairBudgetFixedPosition_1);
        chairBudgetFixedPosition.addAll(chairBudgetFixedPosition_2);
        return chairBudgetFixedPosition;
    }
    public class ChairBudget_FixedPosition
    {
        @AuraEnabled
        public Chair_Budget__c chairBudget;
        @AuraEnabled
        public Fixed_Position__c fixedPosition;
        public ChairBudget_FixedPosition (Chair_Budget__c chairBudget,Fixed_Position__c fixedPosition)
        {
            this.chairBudget=chairBudget;
            this.fixedPosition=fixedPosition;
        }
    }
    //Author  - Thanvi ; Date - 15/02/2020
    //The job of checkAndValidateAllocatedChairBudget_Apex() is to calculate if the user has increased or decreased if at all there is difference in the old amount and the amount entered. This actor inturn calls ReduceBudget() and IncreaseBudget() actors.
    @AuraEnabled
    public static String checkAndValidateAllocatedChairBudget_Apex(String programId,String chairBudgetId,Decimal newAllocatedBudgetValue){
        //Fetch account details for DFV
        objAccount=getAccount();
        Chair_Budget__c chairBudget = [SELECT Id,Program__r.Program_Budget__c,Allocated_Budget__c,Available_Budget__c,Shared_Budget__c,Chair__r.Chair_Name__c,Chair__r.User__r.Name,Chair__r.Active__c,Program__r.Name__c,Chair__r.Level__c,Available_Chair_Budget__c,Consumed_Budget__c,Program__r.Id
        FROM Chair_Budget__c WHERE  Chair__r.Account__c =:objAccount.Id AND Id=:chairBudgetId];
        
        System.debug('newAllocatedBudgetValue------'+newAllocatedBudgetValue);
        System.debug('Available------'+chairBudget.Available_Budget__c);
        System.debug('AllocatedBudgetValue------'+chairBudget.Allocated_Budget__c);
        Decimal differenceAmout  = chairBudget.Allocated_Budget__c - newAllocatedBudgetValue;
        System.debug('differenceAmout'+differenceAmout);
        String message = '';
        if(differenceAmout>0) {
            message = 'USER reduced the Available budget by----> ' + differenceAmout;
            Decimal amountToReduce = differenceAmout;
            message = ReduceBudget(programId, chairBudgetId, amountToReduce);
            
        }
        if(differenceAmout<0){
            System.debug('differenceAmount is negative --->'+differenceAmout);
            message = 'USER increased the Available budget by----> ' +(-1*differenceAmout);
            Decimal amountToIncrease = -1 * differenceAmout;
            System.debug('amountToIncrease --->'+amountToIncrease);
            message = IncreaseBudget(programId, chairBudgetId, amountToIncrease);
        }

        return message;
    }

//Author  - Thanvi ; Date - 15/02/2020
//The job of IncreaseBudget() actor is to determine if the user can increase the budget or not based on certain conditions.
    @AuraEnabled
    public static String IncreaseBudget(String programId,String chairBudgetId,Decimal amountToIncrease) {
          //Fetch account details for DFV
          objAccount=getAccount();
        List<AggregateResult>  totalL1MarketingBudgetAllocated = new List<AggregateResult>();

        Chair_Budget__c chairBudget = [SELECT Id,Program__r.Program_Budget__c,Allocated_Budget__c,Available_Budget__c,Shared_Budget__c,Chair__r.Chair_Name__c,Chair__r.User__r.Name,Chair__r.Active__c,Program__r.Name__c,Chair__r.Level__c,Available_Chair_Budget__c,Consumed_Budget__c,Program__r.Id
        FROM Chair_Budget__c WHERE Chair__r.Account__c =:objAccount.Id AND Id=:chairBudgetId];

        Fixed_Position__c fixedPosition = [SELECT Id,Level__c,Fixed_Position_Name__c,Chair__c FROM Fixed_Position__c WHERE Organizataion_Chart__r.Account__c=:objAccount.Id AND Chair__c IN  (SELECT Chair__c FROM Chair_Budget__c WHERE Id=:chairBudgetId)];

        Program__c selectedProgram = [SELECT Id,Program_Budget__c FROM Program__c WHERE Id=:programId];

        switch on fixedPosition.Level__c {
            when '1' {		
                totalL1MarketingBudgetAllocated= [SELECT SUM(Allocated_Budget__c) TotalL1AllocatedBudget FROM Chair_Budget__c WHERE Chair__r.Level__c='1' AND Program__c=:programId];
               // System.debug('totalL1MarketingBudgetAllocated--->'+totalL1MarketingBudgetAllocated);
                Decimal programBudget = selectedProgram.Program_Budget__c;
               // System.debug('programBudget--->'+programBudget);
                Decimal totalL1Budget = (Decimal) totalL1MarketingBudgetAllocated[0].get('TotalL1AllocatedBudget');
               // System.debug('totalL1Budget--->'+totalL1Budget);
                Decimal remainingMarketingBudget = programBudget - totalL1Budget;
                System.debug('remainingMarketingBudget--->'+remainingMarketingBudget);
                // Check if the Remaining budget is > the difference coming from the client (Previous allocated and newly allocated)
                // If yes go ahead and save, else throw an error 
                if (remainingMarketingBudget >= amountToIncrease)
                {
                    chairBudget.Allocated_Budget__c = chairBudget.Allocated_Budget__c + amountToIncrease;
                    update chairBudget;
                    // Increase available budget, formula field
                   // chairBudget.AvailableBudget = chairBudget.AvailableBudget + amountToIncrease;
                }
                else
                {
                    return 'The budget cannot be increased';
                }
            }	
            when '2' {	
                String incomingFixedPosition = fixedPosition.Fixed_Position_Name__c;
                String parentFixedPosition = incomingFixedPosition.substring(0, incomingFixedPosition.length()-2);
                Fixed_Position__c parentChairOfFixedPosition = [SELECT Chair__c FROM Fixed_Position__c WHERE Organizataion_Chart__r.Account__c=:objAccount.Id AND Fixed_Position_Name__c=:parentFixedPosition];
                Chair_Budget__c parentBudget = [SELECT Available_Budget__c,Shared_Budget__c FROM Chair_Budget__c WHERE Chair__c=:parentChairOfFixedPosition.Chair__c AND    Program__c=:programId];
                if(parentBudget.Available_Budget__c>=amountToIncrease) {
                    chairBudget.Allocated_Budget__c = chairBudget.Allocated_Budget__c + amountToIncrease;
                    update chairBudget;
                    parentBudget.Shared_Budget__c =  parentBudget.Shared_Budget__c+amountToIncrease;
                    update parentBudget;
                }
                else
                {
                    return 'The budget cannot be increased';
                }

            }
            when '3' {
                String incomingFixedPosition = fixedPosition.Fixed_Position_Name__c;
                String parentFixedPosition = incomingFixedPosition.substring(0, incomingFixedPosition.length()-2);
                Fixed_Position__c parentChairOfFixedPosition = [SELECT Chair__c FROM Fixed_Position__c WHERE Organizataion_Chart__r.Account__c=:objAccount.Id AND Fixed_Position_Name__c=:parentFixedPosition];
                Chair_Budget__c parentBudget = [SELECT Available_Budget__c,Shared_Budget__c FROM Chair_Budget__c WHERE Chair__c=:parentChairOfFixedPosition.Chair__c AND    Program__c=:programId];
                if(parentBudget.Available_Budget__c>=amountToIncrease) {
                    chairBudget.Allocated_Budget__c = chairBudget.Allocated_Budget__c + amountToIncrease;
                    update chairBudget;
                    parentBudget.Shared_Budget__c =  parentBudget.Shared_Budget__c+amountToIncrease;
                    update parentBudget;
                }
                else
                {
                    return 'The budget cannot be increased';
                }
            }
        }

        return 'Budget was increased successfully';
    }

//Author  - Thanvi ; Date - 15/02/2020
//The job of ReduceBudget() actor is to determine if the user can decrease the budget or not based on certain conditions.
    @AuraEnabled
    public static string ReduceBudget(String programId,String chairBudgetId,Decimal amountToReduce) {
        List<AggregateResult>  totalMarketingBudgetAllocated = new List<AggregateResult>();
        //Fetch account details for DFV
         objAccount=getAccount();
        Chair_Budget__c chairBudget = [SELECT Id,Program__r.Program_Budget__c,Allocated_Budget__c,Available_Budget__c,Shared_Budget__c,Chair__r.Chair_Name__c,Chair__r.User__r.Name,Chair__r.Active__c,Program__r.Name__c,Chair__r.Level__c,Available_Chair_Budget__c,Consumed_Budget__c,Program__r.Id
                                       FROM Chair_Budget__c WHERE Chair__r.Account__c=:objAccount.Id AND Id=:chairBudgetId];
        
        Fixed_Position__c fixedPosition = [SELECT Id,Level__c,Fixed_Position_Name__c,Chair__c FROM Fixed_Position__c WHERE Organizataion_Chart__r.Account__c=:objAccount.Id AND Chair__c IN  (SELECT Chair__c FROM Chair_Budget__c WHERE Id=:chairBudgetId)];

        Program__c selectedProgram = [SELECT Id,Program_Budget__c FROM Program__c WHERE Id=:programId];
        switch on fixedPosition.Level__c {
            when '1' {
                if(chairBudget.Available_Budget__c>=amountToReduce) {
                    chairBudget.Allocated_Budget__c= chairBudget.Allocated_Budget__c - amountToReduce;
                    update chairBudget;
                }
                else {
                    return 'The budget cannot be decreased';
                }

                }
               
      
            when '2' {	
                String incomingFixedPosition = fixedPosition.Fixed_Position_Name__c;
                String parentFixedPosition = incomingFixedPosition.substring(0, incomingFixedPosition.length()-2);
                Fixed_Position__c parentChairOfFixedPosition = [SELECT Chair__c FROM Fixed_Position__c WHERE
                Organizataion_Chart__r.Account__c=:objAccount.Id AND  Fixed_Position_Name__c=:parentFixedPosition];
                Chair_Budget__c parentBudget = [SELECT Available_Budget__c,Shared_Budget__c FROM Chair_Budget__c WHERE Chair__c=:parentChairOfFixedPosition.Chair__c AND    Program__c=:programId];
                if(chairBudget.Available_Budget__c>=amountToReduce) {
                    chairBudget.Allocated_Budget__c = chairBudget.Allocated_Budget__c - amountToReduce;
                    update chairBudget;
                    parentBudget.Shared_Budget__c =  parentBudget.Shared_Budget__c - amountToReduce;
                    update parentBudget;
                }
                else
                {
                    return 'The budget cannot be decreased';
                }

            }
            when '3' {
                String incomingFixedPosition = fixedPosition.Fixed_Position_Name__c;
                String parentFixedPosition = incomingFixedPosition.substring(0, incomingFixedPosition.length()-2);
                Fixed_Position__c parentChairOfFixedPosition = [SELECT Chair__c FROM Fixed_Position__c WHERE 
                Organizataion_Chart__r.Account__c=:objAccount.Id AND Fixed_Position_Name__c=:parentFixedPosition];
                Chair_Budget__c parentBudget = [SELECT Available_Budget__c,Shared_Budget__c FROM Chair_Budget__c WHERE Chair__c=:parentChairOfFixedPosition.Chair__c AND    Program__c=:programId];
                if(chairBudget.Available_Budget__c>=amountToReduce) {
                    chairBudget.Allocated_Budget__c = chairBudget.Allocated_Budget__c - amountToReduce;
                    update chairBudget;
                    parentBudget.Shared_Budget__c =  parentBudget.Shared_Budget__c - amountToReduce;
                    update parentBudget;
                }
                else
                {
                    return 'The budget cannot be decreased';
                }
            }
        }

    
        return 'Budget was decreased successfully';
    }
}