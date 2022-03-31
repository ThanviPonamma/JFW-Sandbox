/** Author:Sanjana Date:21-09-2021
Aim:To load Program ,to create a brand ,to Program a brand and to add/remove Program items.
*/
public class InfiniumManageProgramList_Apex {
    //To hold Infinium Cane Account deatails
    public static Account objAccount;
    //To fetch data about Infinium Cane from Standard object Account.
    @AuraEnabled(cacheable=true)
    public static Account getAccount() {  
        
        if(Test.isRunningTest())
        {
            objAccount=[SELECT Id, Name FROM Account
                        WHERE Name LIKE '%Infinium Spirits%' LIMIT 1];
        }
        else
        {
            objAccount=[SELECT Id, Name,Lightning_Community_URL__c FROM Account
                        WHERE Lightning_Community_Id__c=:Network.getNetworkId() LIMIT 1];
        }
        return objAccount; // objAccount object contains data about Infinium Cane.
    }
    
    // To get the List of program From Custom object Program__c
    @AuraEnabled(cacheable=true)
    public static ProgramListWithNames getProgramsList_Apex()
    {
        //Fetch account details for Infinium Cane
        objAccount=getAccount();
        List<ProgramListWithNameAndImageURL> programList=new List<ProgramListWithNameAndImageURL> ();
        //Declare a variable programNamesForValidation to hold the list of program with the form suitable for validation of type String
        List<String> programNamesForValidation=new List<String> ();
        //Fetch program objects fields  from sObject Program__c where the account is Infinium Cane 
        //for every record fetched
        for(Program__c program: [SELECT Name, Name__c,Account__c, Description__c, Start_Date__c, Closing_Date__c, In_Market_Date__c, Image_of_Program__c, Active__c,Attachment_Id__c,Program_Budget__c FROM Program__c  WHERE Account__C =:objAccount.ID ]) {
            //for every record fetched , add the incoming program to the program List variable along with the attachement url
            String attachmentURL = String.isBlank(program.Attachment_Id__c)?'':objAccount.Lightning_Community_URL__c+'/servlet/servlet.FileDownload?file='+program.Attachment_Id__c;
            // adding program data along with its image to the wrapper class ProgramListWithNameAndImageURL
            programList.add(new ProgramListWithNameAndImageURL(program,attachmentURL));
            //add the program names with no space and uppercase to the variable programNamesForValidation
            programNamesForValidation.add(program.Name__c.remove(' ').toUpperCase().trim());
            
        }
        System.debug('programList--->'+programList);
        System.debug('programNamesForValidation--->'+programNamesForValidation);
        return new ProgramListWithNames(programList,programNamesForValidation); // programList object contains data about List Of program.
    }
    
   
    @AuraEnabled
    public static ProgramListWithNames saveProgram_Apex(Program__c program,String imageBlobData,String fileName,String ContentType,String selectedButtonName)
    {
        try{
            System.debug('program'+program);  
            System.debug('imageBlobData'+imageBlobData);  
            System.debug('fileName'+fileName);  
            System.debug('ContentType'+ContentType);  
            System.debug('selectedButtonName'+selectedButtonName);  

            //to check if the slected button name by the user is edit
            if(selectedButtonName=='EDIT') {
                //to hold the total value Marketing Budget Allocated to Level 1 chair
                List<AggregateResult>  totalL1MarketingBudgetAllocated = new List<AggregateResult>();
                totalL1MarketingBudgetAllocated= [SELECT SUM(Allocated_Budget__c) TotalL1AllocatedBudget FROM Chair_Budget__c WHERE Chair__r.Level__c='1' AND Program__c=:program.Id];
                 
               Decimal totalL1Budget = (Decimal) totalL1MarketingBudgetAllocated[0].get('TotalL1AllocatedBudget');
               totalL1Budget=totalL1Budget==null?0:totalL1Budget;
                System.debug('totalL1Budget--->'+totalL1Budget);
                //to hold the budget allocated to the Program.
                Decimal programBudget = program.Program_Budget__c;
                programBudget=programBudget==null?0:programBudget;
                System.debug('programBudget--->'+programBudget);

                //to check the the total budget is less than or equal to Program budget.
                if(programBudget>=totalL1Budget)    {
                    System.debug('program--->'+program);
                    update program;
                } 
                else {
                    return getProgramsList_Apex();
                }     
            }
            //Fetch account details for Infinium Cane
            objAccount=getAccount();
            //to hold the orgranizarion chart details of Infinium cane which is active.
            Organiztaion_Chart__c orgChart= [SELECT Id FROM Organiztaion_Chart__c WHERE Account__c=:objAccount.Id AND Checkbox__c=true];

            System.debug('orgChart--->'+orgChart);
            //to add the account id for creating a Program. 
            program.Account__c=objAccount.Id;
            //to add the org chart id for craeting a Program.
            program.Organizataion_Chart_ID__c=orgChart.Id;
            //add/update the Program.
            System.debug('program at 95'+program);  

            upsert program;
            
            //check if the image is associated to a Program.
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
                System.debug('image'+program);  
                update program;
            }
            if(selectedButtonName=='CREATE') {
                System.debug('selectedButtonName--->'+selectedButtonName);
               createChairBudget_Apex(program);
            }
        }
        catch(Exception ex){
            //if there is an error while creating/editing the Program. , notify the admin by mail
            InfiniumEmailNotifications.sendNotification('Adding  Program.',ex.getMessage()+'\n'+'Inputs are -- Program-- '+JSON.serialize(program)+'\n'+'---imageBlobData---'+JSON.serialize(imageBlobData)+'\n'+'---fileName---'+JSON.serialize(fileName)+'\n'+'---ContentType---'+JSON.serialize(ContentType)+'\n'+'Class Name - InfiniumManageProgramList_Apex '+'-- Line number --'+ex.getLineNumber());
        }  

        return getProgramsList_Apex();
    }
    //Aim: to create a chiar budget when a program is created.
    @AuraEnabled
    public static string createChairBudget_Apex(Program__c program){
        //to hold the orgranizarion chart details of Infinium cane which is active.
        Organiztaion_Chart__c orgChart= [SELECT Id,Checkbox__c FROM Organiztaion_Chart__c WHERE Account__c=:objAccount.Id AND Checkbox__c=true];
        //to gold the list of chairs for the org chart
        List<Chair__c> chairList = new List<Chair__c>();
        List<Chair_Budget__c> chairBudgetList = new List<Chair_Budget__c>();
        chairList = [SELECT Id,	Chair_Name__c FROM Chair__c WHERE Id IN (SELECT Chair__c FROM Fixed_Position__c WHERE Organizataion_Chart__c=:orgchart.Id)];
        // for each chair in the org chart create a chair budget with allocated budget 0.
        for(Chair__c chair: chairList) {
            chairBudgetList.add(new Chair_Budget__c(Program__c=program.Id,Chair__c=chair.Id,Allocated_Budget__c=0));
        }
        System.debug('chairBudgetList--->'+chairBudgetList);
        insert chairBudgetList;
        return '';
    }
    /**Aim:To deactivate a program
    * Parameter passed are
    * program: This variable contains the program that is to be deactivated */
    @AuraEnabled 
    public static ProgramListWithNames deactivateProgram_Apex(Program__c program)
    {
        try{
            //For the incoming program , the active status must be set to false to make it inactive
            program.Active__c=false;
            //update the program in the database
            update program;
        }
        catch(Exception ex){
            //if there is an error while updating the program , notify the admin by mail
            InfiniumEmailNotifications.sendNotification('Deactivating Program',ex.getMessage()+'\n'+'Inputs are -- program-- '+JSON.serialize(program)+'\n'+'Class Name - InfiniumManageProgramList_Apex '+'-- Line number --'+ex.getLineNumber());
        }  
        return getProgramsList_Apex();
    }
    /**Aim: To add a pos item to the program
    * Parameters passed are -
    * program: holds the program details of type Program__c
    * positem: the item to be added to the program of type POS_Item__c
    */
    @AuraEnabled
    public static ProgramItemListWrapper addPosItemToProgram_Apex(Program__c program,POS_Item__c posItem)
    {
        try{
            //to fetch the program items for the selected pos item and the selected Program
            List<Program_Item__c> prgItems = [Select Id,Name From Program_Item__c where Program__c = :program.id AND POS_Item__c = :posItem.Id]; 
            // If its empty then insert or update the Program item in database
            if(prgItems.isEmpty())
            {
                Program_Item__c programItem= new Program_Item__c(Program__c = program.id,   POS_Item__c = posItem.Id);
                upsert programItem;
            }
        }
        catch(Exception ex){
            //if there is an error while adding the item from the Program , notify the admin by mail
            InfiniumEmailNotifications.sendNotification('Adding a POS Item to Program',ex.getMessage()+'\n'+'Inputs are -- Program-- '+JSON.serialize(program)+'\n'+'---posItem---'+JSON.serialize(posItem)+'\n'+'Class Name - InfiniumManageProgramList_Apex '+'-- Line number --'+ex.getLineNumber());
        } 
        return getProgramItemList_Apex (program.Id);
    }
    /**Aim:To remove a pos item from the Program
* Parameters passed are -
*  program: holds the Program details of type Program__c
* positem: the item to be removed from the Program of type POS_Item__c */
    @AuraEnabled
    public static ProgramItemListWrapper removePosItemFromProgram_Apex(Program__c program,POS_Item__c posItem)
    {
        System.debug(program.Id);
        try{
            //to fetch the program items for the selected pos item and the selected Program
            List<Program_Item__c> prgItems = [Select Id,Name From Program_Item__c where Program__c = :program.Id AND POS_Item__c = :posItem.Id]; 
            //delete the Program item from the Program
            delete prgItems ;
        }
        catch(Exception ex){
            //if there is an error while removing the item from the Program , notify the admin by mail
            InfiniumEmailNotifications.sendNotification('Removing a POS Item from Program',ex.getMessage()+'\n'+'Inputs are -- Program-- '+JSON.serialize(program)+'\n'+'---posItem---'+JSON.serialize(posItem)+'\n'+'Class Name - InfiniumManageProgramList_Apex '+'-- Line number --'+ex.getLineNumber());
        } 
        System.debug(program.Id);
        return getProgramItemList_Apex (program.Id);
    }
    /**Aim:To fetch the Program items
* Parameters passed are -
*  program: holds the Program details of type Program__c */
    @AuraEnabled(cacheable=true)
    public static ProgramItemListWrapper getProgramItemList_Apex (string programId)
    {
        System.debug('program'+programId);
        //Fetch account details for Infinium Cane
        objAccount=getAccount();
        // to hold the Program items associated with the Program
        List<POS_Item__c> programItemList =[SELECT Name,Item_No__c, Item_Name__c, Image_of_Item__c,Brand__c, Brand__r.Brand_Name__c, Pack_Of__c, Price__c, Maximum_Order_Qty__c, Type_of_Item__c, Type_of_Item__r.Item_Type__c, Active__c, Dimension__c FROM POS_Item__c item
                                            WHERE item.Id IN (
                                                SELECT prgitem.POS_Item__c From Program_Item__c prgitem WHERE prgitem.Program__c = :programId)          
                                            ORDER BY Item_Name__c 
                                           ];
        // to hold the pos items available for the Program
        List<POS_Item__c>  availablePosItems =  [SELECT Name,Item_No__c, Item_Name__c, Image_of_Item__c,Brand__c, Brand__r.Brand_Name__c, Pack_Of__c, Price__c, Maximum_Order_Qty__c, Type_of_Item__c, Type_of_Item__r.Item_Type__c, Active__c, Dimension__c FROM POS_Item__c item
                                                 WHERE item.Id NOT IN (
                                                     SELECT prgitem.POS_Item__c From Program_Item__c prgitem WHERE prgitem.Program__c = :programId
                                                 )
                                                 AND (Inventory_Seasonal_Program__c = 'Seasonal Program' OR Inventory_Seasonal_Program__c = 'Both')
                                                 AND POS_Item__c.Account__C =:objAccount.ID
                                                 ORDER BY Item_Name__c
                                                ];
        System.debug('availablePosItems'+availablePosItems);
        return new ProgramItemListWrapper(programItemList,availablePosItems);
    } 
    
    
    //Aim:To hold the list of Program and the Program names in a form suitable for the Program name validation
    public class ProgramListWithNames
    {
        @AuraEnabled
        //To hold the list of Program
        public List<ProgramListWithNameAndImageURL> programList ;
        @AuraEnabled
        //To hold the Program names in a form suitable for the Program name validation
        public List<String> programNamesForValidation ;
        public ProgramListWithNames(List<ProgramListWithNameAndImageURL> programList,List<String> programNamesForValidation )
        {
            this.programList=programList;
            this.programNamesForValidation =programNamesForValidation ;
        }
    }
    public class ProgramListWithNameAndImageURL
    {
        // to hold the program
        @AuraEnabled
        public Program__c program ;
        //to hold the Program image URL
        @AuraEnabled
        public String programImageURL;
        public ProgramListWithNameAndImageURL (Program__c program, String programImageURL)
        {
            this.program=program;
            this.programImageURL = programImageURL;
        }
    }
    //Aim:To hold the items associated and available with the Program
    public class ProgramItemListWrapper
    {
        @AuraEnabled
        //To hold the list of assocaited Program items
        public List<POS_Item__c> programItemList ;
        @AuraEnabled
        //To hold the list of available Program items
        public List<POS_Item__c> availablePosItems;
        public ProgramItemListWrapper(List<POS_Item__c> programItemList,List<POS_Item__c> availablePosItems )
        {
            this.programItemList=programItemList;
            this.availablePosItems =availablePosItems ;
        }
    }
}