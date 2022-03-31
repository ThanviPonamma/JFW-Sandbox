public class DFVProgramCmpController {
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
    @AuraEnabled
    public static ProgramListWithNames getProgramsList_Apex()
    {
        objAccount=getAccount();
        List<Program__c> programList=new List<Program__c> ();
        List<String> programNamesForValidation=new List<String> ();
        for(Program__c program: [SELECT Name, Name__c,Account__c, Description__c, Start_Date__c, Closing_Date__c, In_Market_Date__c, Image_of_Program__c, Active__c,Attachment_Id__c,Program_Budget__c,Program_Account__r.Account_Number__c FROM Program__c  WHERE Account__C =:objAccount.ID ]) {
            programList.add(program);
            programNamesForValidation.add(program.Name__c.remove(' ').toUpperCase().trim());
        }
        
        return new ProgramListWithNames(programList,programNamesForValidation); // brandList object contains data about List Of Brands.
    }
     @AuraEnabled
    public static List<Program_Account__c> getProgramAccountsList_Apex()
    {
        objAccount=getAccount();
        return [SELECT  Account_Name__c,Account_Number__c,Id FROM Program_Account__c];
    }
    @AuraEnabled
    public static ProgramListWithNames saveProgram_Apex(Program__c program,String imageBlobData,String fileName,String ContentType,String selectedButttonName)
    {
        try{
            if(selectedButttonName=='EDIT') {
                List<AggregateResult>  totalL1MarketingBudgetAllocated = new List<AggregateResult>();
                totalL1MarketingBudgetAllocated= [SELECT SUM(Allocated_Budget__c) TotalL1AllocatedBudget FROM Chair_Budget__c WHERE Chair__r.Level__c='1' AND Program__c=:program.Id];
                Decimal totalL1Budget = (Decimal) totalL1MarketingBudgetAllocated[0].get('TotalL1AllocatedBudget');
                Decimal programBudget = program.Program_Budget__c;
                System.debug('programBudget'+programBudget);
                System.debug('totalL1Budget'+totalL1Budget);  
                if(programBudget>=totalL1Budget)    {
                    update program;
                } 
                else {
                    return getProgramsList_Apex();
                }     
            }
            objAccount=getAccount();
             //Author: Thanvi Date:Thanvi  
             // CR No : DFV-18-Feb-1 
            Organiztaion_Chart__c orgChart= [SELECT Id FROM Organiztaion_Chart__c WHERE Account__c=:objAccount.Id AND Checkbox__c=true];
            program.Account__c=objAccount.Id;
             //Author: Thanvi Date:Thanvi  
             // CR No : DFV-18-Feb-1 
            program.Organizataion_Chart_ID__c=orgChart.Id;
            upsert program;
            
            if(String.isNotBlank(imageBlobData))
            {
                imageBlobData = EncodingUtil.urlDecode(imageBlobData, 'UTF-8');
                
                    Attachment attach = new Attachment();
                    attach.parentId = program.Id;
                    attach.Body = EncodingUtil.base64Decode(imageBlobData);
                    attach.Name = fileName;
                    attach.ContentType = contentType;
                    Insert attach; 
                    program.Attachment_Id__c=attach.Id;
                    update program;
            }
           
           // System.debug('program---->'+program);
           // System.debug('selectedButttonName--->'+selectedButttonName);
             //Author: Thanvi Date:Thanvi  
             // CR No : DFV-18-Feb-1 
            if(selectedButttonName=='CREATE') {
              //  System.debug('selectedButttonName inside if-->'+selectedButttonName);
               createChairBudget_Apex(program);
            }
        }
        catch(Exception ex){
          DFVEmailNotifications.sendNotification('Adding Program',ex.getMessage()+'\n'+'Inputs are -- program-- '+JSON.serialize(program)+'\n'+'---imageBlobData---'+JSON.serialize(imageBlobData)
                                                        +'\n'+'---fileName---'+JSON.serialize(fileName)+'\n'+'---ContentType---'+JSON.serialize(ContentType)
                                                        +'\n'+'Class Name - DFVPOSItemListCmpController '+'-- Line number --'+ex.getLineNumber());
        }  
        return getProgramsList_Apex();
    }
    //Author: Thanvi Date:Thanvi  
    // CR No : DFV-18-Feb-1 
    // TO create the chair budget for the chairs in the fixed positions of the org chart
    @AuraEnabled
    public static string createChairBudget_Apex(Program__c program){
        //System.debug('program for chair budget---->'+program);
        Organiztaion_Chart__c orgChart= [SELECT Id,Checkbox__c FROM Organiztaion_Chart__c WHERE Account__c=:objAccount.Id AND Checkbox__c=true];
        List<Chair__c> chairList = new List<Chair__c>();
        List<Chair_Budget__c> chairBudgetList = new List<Chair_Budget__c>();
        chairList = [SELECT Id,	Chair_Name__c FROM Chair__c WHERE Id IN (SELECT Chair__c FROM Fixed_Position__c WHERE Organizataion_Chart__c=:orgchart.Id)];
        //System.debug('chairList for chair budget---->'+chairList);
        for(Chair__c chair: chairList) {
            chairBudgetList.add(new Chair_Budget__c(Program__c=program.Id,Chair__c=chair.Id,Allocated_Budget__c=0));
        }
        insert chairBudgetList;
        //System.debug('chairBudgetList---->'+chairBudgetList);
        return '';
    }
    @AuraEnabled 
    public static ProgramListWithNames deactivateProgram_Apex(Program__c program)
    {
        try{
            program.Active__c=false;
            update program;
        }
        catch(Exception ex){
          DFVEmailNotifications.sendNotification('Deactivating Program',ex.getMessage()+'\n'+'Inputs are -- program-- '+JSON.serialize(program)
                                                        +'\n'+'Class Name - DFVPOSItemListCmpController '+'-- Line number --'+ex.getLineNumber());
        }  
        return getProgramsList_Apex();
    }
    
    @AuraEnabled
    public static ProgramItemListWrapper addPosItemToProgram_Apex(Program__c program,POS_Item__c posItem)
    {
        try{
            List<Program_Item__c> prgItems = [Select Id,Name From Program_Item__c where Program__c = :program.id AND POS_Item__c = :posItem.Id]; 
            if(prgItems.isEmpty())
            {
                Program_Item__c programItem= new   Program_Item__c(Program__c = program.id,   POS_Item__c = posItem.Id);
                upsert programItem;
            }
        }
        catch(Exception ex){
          DFVEmailNotifications.sendNotification('Adding a POS Item to Program',ex.getMessage()+'\n'+'Inputs are -- program-- '+JSON.serialize(program)
                                                        +'\n'+'---posItem---'+JSON.serialize(posItem)
                                                        +'\n'+'Class Name - DFVPOSItemListCmpController '+'-- Line number --'+ex.getLineNumber());
        } 
        return getProgramItemList_Apex (program);
    }
    @AuraEnabled
    public static ProgramItemListWrapper removePosItemFromProgram_Apex(Program__c program,POS_Item__c posItem)
    {
        try{
            List<Program_Item__c> prgItems = [Select Id,Name From Program_Item__c where Program__c = :program.Id AND POS_Item__c = :posItem.Id]; 
            delete prgItems ;
        }
        catch(Exception ex){
          DFVEmailNotifications.sendNotification('Adding a POS Item to Program',ex.getMessage()+'\n'+'Inputs are -- program-- '+JSON.serialize(program)
                                                        +'\n'+'---posItem---'+JSON.serialize(posItem)
                                                        +'\n'+'Class Name - DFVPOSItemListCmpController '+'-- Line number --'+ex.getLineNumber());
        } 
        return getProgramItemList_Apex (program);
    }
   //Authors : NP, SN, TP, VB ; Date:01-07-2020
   //CR - DFV-30-Jun-20 
   //commenting the below lines since there was a need to make a change in query held by the variable itemsAvailableForPrg. 
   //Removing item.Active__c = true in the WHERE condition
   
  /**  @AuraEnabled 
    public static ProgramItemListWrapper getProgramItemList_Apex (Program__c program)
    {
        objAccount=getAccount();
        List<POS_Item__c> programItemList =[SELECT Name,Item_No__c, Item_Name__c, Image_of_Item__c,Brand__c, Brand__r.Brand_Name__c, Pack_Of__c, Price__c, Maximum_Order_Qty__c, Type_of_Item__c, Type_of_Item__r.Item_Type__c, Active__c, Dimension__c FROM POS_Item__c item
            WHERE item.Id IN (
                SELECT prgitem.POS_Item__c From Program_Item__c prgitem WHERE prgitem.Program__c = :program.Id 
                
            )          
            ORDER BY Item_Name__c 
        ];
        List<POS_Item__c>  itemsAvailableForPrg =  [SELECT Name,Item_No__c, Item_Name__c, Image_of_Item__c,Brand__c, Brand__r.Brand_Name__c, Pack_Of__c, Price__c, Maximum_Order_Qty__c, Type_of_Item__c, Type_of_Item__r.Item_Type__c, Active__c, Dimension__c FROM POS_Item__c item
            WHERE item.Id NOT IN (
                SELECT prgitem.POS_Item__c From Program_Item__c prgitem WHERE prgitem.Program__c = :program.Id
            )
            AND item.Active__c = true
            AND (Inventory_Seasonal_Program__c = 'Seasonal Program' OR Inventory_Seasonal_Program__c = 'Both')
            AND POS_Item__c.Account__C =:objAccount.ID
            ORDER BY Item_Name__c
        ];
        return new ProgramItemListWrapper(programItemList,itemsAvailableForPrg );
    }  **/ 
    
    @AuraEnabled 
    public static ProgramItemListWrapper getProgramItemList_Apex (Program__c program)
    {
        objAccount=getAccount();
        List<POS_Item__c> programItemList =[SELECT Name,Item_No__c, Item_Name__c, Image_of_Item__c,Brand__c, Brand__r.Brand_Name__c, Pack_Of__c, Price__c, Maximum_Order_Qty__c, Type_of_Item__c, Type_of_Item__r.Item_Type__c, Active__c, Dimension__c FROM POS_Item__c item
            WHERE item.Id IN (
                SELECT prgitem.POS_Item__c From Program_Item__c prgitem WHERE prgitem.Program__c = :program.Id 
                
            )          
            ORDER BY Item_Name__c 
        ];
        List<POS_Item__c>  itemsAvailableForPrg =  [SELECT Name,Item_No__c, Item_Name__c, Image_of_Item__c,Brand__c, Brand__r.Brand_Name__c, Pack_Of__c, Price__c, Maximum_Order_Qty__c, Type_of_Item__c, Type_of_Item__r.Item_Type__c, Active__c, Dimension__c FROM POS_Item__c item
            WHERE item.Id NOT IN (
                SELECT prgitem.POS_Item__c From Program_Item__c prgitem WHERE prgitem.Program__c = :program.Id
            )
            AND (Inventory_Seasonal_Program__c = 'Seasonal Program' OR Inventory_Seasonal_Program__c = 'Both')
            AND POS_Item__c.Account__C =:objAccount.ID
            ORDER BY Item_Name__c
        ];
        return new ProgramItemListWrapper(programItemList,itemsAvailableForPrg );
    } 
    
    
    
    public class ProgramListWithNames
    {
        @AuraEnabled
        public List<Program__c> programList ;
        @AuraEnabled
        public List<String> programNamesForValidation ;
        public ProgramListWithNames(List<Program__c> programList,List<String> programNamesForValidation )
        {
            this.programList=programList;
            this.programNamesForValidation =programNamesForValidation ;
        }
    }
    public class ProgramItemListWrapper
    {
        @AuraEnabled
        public List<POS_Item__c> programItemList ;
        @AuraEnabled
        public List<POS_Item__c> availablePosItems;
        public ProgramItemListWrapper(List<POS_Item__c> programItemList,List<POS_Item__c> availablePosItems )
        {
            this.programItemList=programItemList;
            this.availablePosItems =availablePosItems ;
        }
    }
}