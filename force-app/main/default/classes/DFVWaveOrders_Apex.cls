//Authors : SN, TP, VB ; Date: 19-06-2020
//Aim: The class DFVWaveOrders_Apex is responsible for DFV manage ordered items page

public class DFVWaveOrders_Apex {
    
//Authors : SN, TP, VB ; Date: 19-06-2020
//Aim: Declaring a variable objAccount of type sObject Account
    public static Account objAccount;
    
//Authors : SN, TP, VB ; Date: 19-06-2020
//Aim: The method getAccount() is responsible to fetch the Id, Name and Lightning_Community_URL__c of the account
    @AuraEnabled(cacheable=true)
    public static Account getAccount() { 
        
        //For the test class to identify the account
        if(Test.isRunningTest())
        {
            objAccount=[SELECT Id, Name,Lightning_Community_URL__c FROM Account
                        WHERE Name LIKE '%DFV%' LIMIT 1];
        }
        else
        {
            //To fetch the Id, Name and Lightning_Community_URL__c of the account through the network Id.
            objAccount=[SELECT Id, Name,Lightning_Community_URL__c FROM Account
                        WHERE Lightning_Community_Id__c=:Network.getNetworkId() LIMIT 1];
        }
        return objAccount;
    }
    
//Authors : SN, TP, VB ; Date: 19-06-2020
//Aim: The method loadProgramList() is responsible to fetch the active and closed programs from the sObject Program__c
    @AuraEnabled(cacheable=true)
    public static List<Program__c> loadProgramList(){
        //to fetch the account details from getAccount()
        objAccount=getAccount();
        
        //declaring a variable programlist of type List that holds the elements of the sObject Program__c
        List<Program__c> programList = new List<Program__c>();
        
        //the variable programList holds the result of the SOQL query
        programList = [SELECT Id, Name__c, Active__c, Program_Status__c
                       FROM Program__c 
                       WHERE Active__c = true AND Account__c =:objAccount.id AND Program_Status__c = 'Window Closed'];
        
        System.debug('programList--->'+programList);
        
        //returning the variable programList to the front end actor
        return programList;
    }
    
    
    
    //Authors : SN, TP, VB ; Date: 25-06-2020
//Aim: The method loadBrandList() is responsible to fetch the active brands from the sObject Brand__c
    @AuraEnabled(cacheable=true)
    public static List<Brand__c> loadBrandList(){
        //to fetch the account details from getAccount()
        objAccount=getAccount();
        
        //declaring a variable brandList of type List that holds the elements of the sObject Brand__c
        List<Brand__c> brandList = new List<Brand__c>();
        
        //the variable brandList holds the result of the SOQL query
        brandList = [SELECT Id, Brand_Name__c
                     FROM Brand__c 
                     WHERE Active__c = true AND Account__c =:objAccount.id];
        
        System.debug('brandList--->'+brandList);
        
        //returning the variable brandList to the front end actor
        return brandList;
    }
    
    
    
    
//Authors : SN, TP, VB ; Date: 24-06-2020
//Aim: To get the list of pos items which belongs to an incoming program Id and brand Id and where the On_Hold__c condition is true from program item table and store it in a variable called withheldPosItemsList of data type list .
    @AuraEnabled(cacheable=true)
    public static List<POS_Item__c> loadWithheldItems(String selectedProgramId, String selectedBrandId){
        system.debug('selectedBrandId---->'+selectedBrandId);
        //to declare a variable withheldPosItemsList of the type List that holds the elements of the sObject POS_Item__c
        List<POS_Item__c> withheldPosItemsList = new List<POS_Item__c>();
        
        //check if the selectedBrandId is not null. If the selectedBrandId has a value,
        if(String.isNotBlank(selectedBrandId)){
            //fetch the list of POS_Item__c details that belongs to an incoming program Id, brand Id and where the On_Hold__c condition is true from 
        //program item table and store it in a variable called withheldPosItemsList of data type list
       withheldPosItemsList  = [SELECT Item_No__c, Item_Name__c, Brand__r.Brand_Name__c, Pack_Of__c, Price__c FROM POS_Item__c													
								WHERE  Brand__c = : selectedBrandId AND Id IN 												
								(SELECT POS_Item__c From Program_Item__c 
                                WHERE Program__c = :selectedProgramId AND On_Hold__c=true)																										
								ORDER BY Item_Name__c];		
        }
        else
        {
            //fetch the list of POS_Item__c details that belongs to an incoming program Id and where the On_Hold__c condition is true from 
        //program item table and store it in a variable called withheldPosItemsList of data type list
            withheldPosItemsList  = [SELECT Item_No__c, Item_Name__c, Brand__r.Brand_Name__c, Pack_Of__c, Price__c FROM POS_Item__c													
								WHERE Id IN 												
								(SELECT POS_Item__c From Program_Item__c 
                                WHERE Program__c = :selectedProgramId AND On_Hold__c=true)																										
								ORDER BY Item_Name__c];
        }
        
        											
        
                   //return the variable withheldPosItemsList
                   return withheldPosItemsList;
    			}
    
    //Authors : SN, TP, VB ; Date: 24-06-2020
   //Aim: To get the list of pos items which belongs to an incoming program Id brand Id and where the On_Hold__c condition is true from 
  //program item table and store it in a variable called availablePosItemsList of data type list .
    @AuraEnabled(cacheable=true)
    public static List<DFVItemsWithCometOrderCount_Wrapper> loadAvailableItems(String selectedProgramId, String selectedBrandId){
        system.debug('selectedBrandId----->'+selectedBrandId);
        system.debug('selectedProgramId----->'+selectedProgramId);

        //to declare a variable availablePosItemsList of the type List that holds the elements of the sObject POS_Item__c
        List<POS_Item__c> availablePosItemsList = new List<POS_Item__c>();
        
        List<DFVItemsWithCometOrderCount_Wrapper>  cometItemsWithOrderCount = new List<DFVItemsWithCometOrderCount_Wrapper>();
        
        //fetch the list of POS_Item__c details that belongs to an incoming program Id brand Id and where the On_Hold__c condition is false from program item table 
        //and store it in a variable called availablePosItemsList of data type list
        availablePosItemsList = [SELECT Id,Item_No__c, Item_Name__c, Brand__r.Brand_Name__c, Pack_Of__c, Price__c FROM POS_Item__c													
								WHERE Brand__c = : selectedBrandId AND Id IN 
                                (SELECT POS_Item__c From Program_Item__c WHERE Program__c = :selectedProgramId AND On_Hold__c=false)											
								ORDER BY Item_Name__c];	
        system.debug('availablePosItemsList Befor Assigining'+availablePosItemsList.size());
        //To send the list of pos items fetched held in the variable availablePosItemsList to the data member 
        //avaliableItemsList of the class DFVCalculateSentAndAvailableOrders_Apex
      //  availablePosItemsList = DFVCalculateSentAndAvailableOrders_Apex.availablePosItems;
        //system.debug('availablePosItemsList After Assigining'+availablePosItemsList.size());
        //To send the selected program Id held in the variable selectedProgramId to the data member 
        //selectedProgramId of the class DFVCalculateSentAndAvailableOrders_Apex
       // selectedProgramId = DFVCalculateSentAndAvailableOrders_Apex.selectedProgramId;
        
        //To invoke the class DFVCalculateSentAndAvailableOrders_Apex  and a method inside that class calculateSentAndRemainingOrdersForPosItem()for calculating sent and remaining order for the available pos item
        cometItemsWithOrderCount = DFVCalculateSentAndAvailableOrders_Apex.calculateSentAndRemainingOrdersForPosItem(availablePosItemsList,selectedProgramId);
        
        //return cometItemsWithOrderCount containg the pos item and its sent and remaining orders size given by 
        //DFVCalculateSentAndAvailableOrders_Apex.calculateSentAndRemainingOrdersForPosItem() 
        return cometItemsWithOrderCount;
        
																		       
    }
            
}