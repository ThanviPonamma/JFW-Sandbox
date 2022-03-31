/** Author : Thanvi
Date:09/Aug/2021
Aim:To load buy book ,to create a brand ,to buy book a brand and to add/remove buy book items.
*/
public class CopperManageBuyBookList_Apex {
    //To hold Copper Cane Account deatails
    public static Account objAccount;
    //To fetch data about Copper Cane from Standard object Account.
    @AuraEnabled(cacheable=true)
    public static Account getAccount() {  
        
        if(Test.isRunningTest())
        {
            objAccount=[SELECT Id, Name FROM Account
                        WHERE Name LIKE '%Copper Cane%' LIMIT 1];
        }
        else
        {
            objAccount=[SELECT Id, Name,Lightning_Community_URL__c FROM Account
                        WHERE Lightning_Community_Id__c=:Network.getNetworkId() LIMIT 1];
        }
        return objAccount; // objAccount object contains data about Copper Cane.
    }
    
    // To get the List of Buy Book From Custom object Program__c
    @AuraEnabled(cacheable=true)
    public static BuyBookListWithNames getBuyBooksList_Apex()
    {
        //Fetch account details for Copper Cane
        objAccount=getAccount();
        List<BuyBookListWithNameAndImageURL> buyBookList=new List<BuyBookListWithNameAndImageURL> ();
        //Declare a variable buyBookNamesForValidation to hold the list of buy book with the form suitable for validation of type String
        List<String> buyBookNamesForValidation=new List<String> ();
        //Fetch buy book objects fields  from sObject Program__c where the account is Copper Cane 
        //for every record fetched
        for(Program__c program: [SELECT Name, Name__c,Account__c, Description__c, Start_Date__c, Closing_Date__c, In_Market_Date__c, Image_of_Program__c, Active__c,Attachment_Id__c,Program_Budget__c FROM Program__c  WHERE Account__C =:objAccount.ID ORDER BY Name__c ASC ]) {
            //for every record fetched , add the incoming buy book to the buy book List variable along with the attachement url
            String attachmentURL = String.isBlank(program.Attachment_Id__c)?'':objAccount.Lightning_Community_URL__c+'/servlet/servlet.FileDownload?file='+program.Attachment_Id__c;
            // adding buy book data along with its image to the wrapper class BuyBookListWithNameAndImageURL
            buyBookList.add(new BuyBookListWithNameAndImageURL(program,attachmentURL));
            //add the buy book names with no space and uppercase to the variable buyBookNamesForValidation
            buyBookNamesForValidation.add(program.Name__c.remove(' ').toUpperCase().trim());
            
        }
        System.debug('buyBookList--->'+buyBookList);
        System.debug('buyBookNamesForValidation--->'+buyBookNamesForValidation);
        
        return new BuyBookListWithNames(buyBookList,buyBookNamesForValidation); // buy bookList object contains data about List Of buy book.
    }
    
    // To add the buy book into the buy book list on Click of Save Button for Create Brand/edit buy book in the lightning Component
    /**Parameter Used:
* buybook:This variable contains the buy book that is to be added or updated
* imageBlobData: image to be associated with the buy book
* fileName: image-name of the file 
* ContentType - type of the image
* selectedButtonName - if the button selected is EDIT /CREATE**/
    @AuraEnabled
    public static BuyBookListWithNames saveBuyBook_Apex(Program__c buybook,String imageBlobData,String fileName,String ContentType,String selectedButtonName)
    {
        try{
            //to check if the slected button name by the user is edit
            if(selectedButtonName=='EDIT') {
                //to hold the total value Marketing Budget Allocated to Level 1 chair
                List<AggregateResult>  totalL1MarketingBudgetAllocated = new List<AggregateResult>();
                totalL1MarketingBudgetAllocated= [SELECT SUM(Allocated_Budget__c) TotalL1AllocatedBudget FROM Chair_Budget__c WHERE Chair__r.Level__c='1' AND Program__c=:buybook.Id];
                Decimal totalL1Budget = (Decimal) totalL1MarketingBudgetAllocated[0].get('TotalL1AllocatedBudget');
                totalL1Budget=totalL1Budget==null?0:totalL1Budget;
                System.debug('totalL1Budget--->'+totalL1Budget);
                //to hold the budget allocated to the Program.
                Decimal buyBookBudget = buybook.Program_Budget__c;
                buyBookBudget=buyBookBudget==null?0:buyBookBudget;
                System.debug('buyBookBudget--->'+buyBookBudget);
                //to check the the total budget is less than or equal to buy book budget.
                if(buyBookBudget>=totalL1Budget)    {
                    update buybook;
                } 
                else {
                    return getBuyBooksList_Apex();
                }     
            }
            //Fetch account details for Copper Cane
            objAccount=getAccount();
            //to hold the orgranizarion chart details of Copper cane which is active.
            Organiztaion_Chart__c orgChart= [SELECT Id FROM Organiztaion_Chart__c WHERE Account__c=:objAccount.Id AND Checkbox__c=true];
            //to add the account id for creating a Buy Book. 
            buybook.Account__c=objAccount.Id;
            //to add the org chart id for craeting a Buy Book.
            buybook.Organizataion_Chart_ID__c=orgChart.Id;
            //add/update the Buy Book.
            upsert buybook;
            
            //check if the image is associated to a Buy Book.
            if(String.isNotBlank(imageBlobData))
            {
                imageBlobData = EncodingUtil.urlDecode(imageBlobData, 'UTF-8');
                
                Attachment attach = new Attachment();
                attach.parentId = buybook.Id;
                attach.Body = EncodingUtil.base64Decode(imageBlobData);
                attach.Name = fileName;
                attach.ContentType = contentType;
                Insert attach; 
                buybook.Attachment_Id__c=attach.Id;
                System.debug('image'+buybook);  
                update buybook;
            }
            if(selectedButtonName=='CREATE') {
                createChairBudget_Apex(buybook);
            }
        }
        catch(Exception ex){
            //if there is an error while creating/editing the Buy Book. , notify the admin by mail
            CopperEmailNotifications.sendNotification('Adding  Buy Book.',ex.getMessage()+'\n'+'Inputs are -- Buy Book-- '+JSON.serialize(buybook)+'\n'+'---imageBlobData---'+JSON.serialize(imageBlobData)+'\n'+'---fileName---'+JSON.serialize(fileName)+'\n'+'---ContentType---'+JSON.serialize(ContentType)+'\n'+'Class Name - CopperManageBuyBookList_Apex '+'-- Line number --'+ex.getLineNumber());
        }  
        return getBuyBooksList_Apex();
    }
    //Aim: to create a chiar budget when a program is created.
    @AuraEnabled
    public static string createChairBudget_Apex(Program__c buybook){
        //to hold the orgranizarion chart details of Copper cane which is active.
        Organiztaion_Chart__c orgChart= [SELECT Id,Checkbox__c FROM Organiztaion_Chart__c WHERE Account__c=:objAccount.Id AND Checkbox__c=true];
        //to gold the list of chairs for the org chart
        List<Chair__c> chairList = new List<Chair__c>();
        List<Chair_Budget__c> chairBudgetList = new List<Chair_Budget__c>();
        chairList = [SELECT Id,	Chair_Name__c FROM Chair__c WHERE Id IN (SELECT Chair__c FROM Fixed_Position__c WHERE Organizataion_Chart__c=:orgchart.Id)];
        // for each chair in the org chart create a chair budget with allocated budget 0.
        for(Chair__c chair: chairList) {
            chairBudgetList.add(new Chair_Budget__c(Program__c=buybook.Id,Chair__c=chair.Id,Allocated_Budget__c=0));
        }
        insert chairBudgetList;
        return '';
    }
    /**Aim:To deactivate a buy book
* Parameter passed are
* buybook: This variable contains the buy book that is to be deactivated */
    @AuraEnabled 
    public static BuyBookListWithNames deactivateBuyBook_Apex(Program__c buybook)
    {
        try{
            //For the incoming buy book , the active status must be set to false to make it inactive
            buybook.Active__c=false;
            //update the buy book in the database
            update buybook;
        }
        catch(Exception ex){
            //if there is an error while updating the buy book , notify the admin by mail
            CopperEmailNotifications.sendNotification('Deactivating Buy Book',ex.getMessage()+'\n'+'Inputs are -- Buy Book-- '+JSON.serialize(buybook)+'\n'+'Class Name - CopperManageBuyBookList_Apex '+'-- Line number --'+ex.getLineNumber());
        }  
        return getBuyBooksList_Apex();
    }
    /**Aim: To add a pos item to the buy book
* Parameters passed are -
* buybook: holds the buy book details of type Program__c
* positem: the item to be added to the buy book of type POS_Item__c
*/
    @AuraEnabled
    public static BuyBookItemListWrapper addPosItemToBuyBook_Apex(Program__c buyBook,POS_Item__c posItem)
    {
        try{
            //to fetch the program items for the selected pos item and the selected buy book
            List<Program_Item__c> prgItems = [Select Id,Name From Program_Item__c where Program__c = :buyBook.id AND POS_Item__c = :posItem.Id]; 
            // If its empty then insert or update the buy book item in database
            if(prgItems.isEmpty())
            {
                Program_Item__c programItem= new Program_Item__c(Program__c = buyBook.id,   POS_Item__c = posItem.Id);
                upsert programItem;
            }
        }
        catch(Exception ex){
            //if there is an error while adding the item from the buy book , notify the admin by mail
            CopperEmailNotifications.sendNotification('Adding a POS Item to Buy Book',ex.getMessage()+'\n'+'Inputs are -- Buy Book-- '+JSON.serialize(buyBook)+'\n'+'---posItem---'+JSON.serialize(posItem)+'\n'+'Class Name - CopperManageBuyBookList_Apex '+'-- Line number --'+ex.getLineNumber());
        } 
        return getBuyBookItemList_Apex (buyBook.Id);
    }
    /**Aim:To remove a pos item from the buy book
* Parameters passed are -
*  buybook: holds the buy book details of type Program__c
* positem: the item to be removed from the buy book of type POS_Item__c */
    @AuraEnabled
    public static BuyBookItemListWrapper removePosItemFromBuyBook_Apex(Program__c buyBook,POS_Item__c posItem)
    {
        System.debug(buyBook.Id);
        try{
            //to fetch the program items for the selected pos item and the selected buy book
            List<Program_Item__c> prgItems = [Select Id,Name From Program_Item__c where Program__c = :buyBook.Id AND POS_Item__c = :posItem.Id]; 
            //delete the buy book item from the buy book
            delete prgItems ;
        }
        catch(Exception ex){
            //if there is an error while removing the item from the buy book , notify the admin by mail
            CopperEmailNotifications.sendNotification('Removing a POS Item from Buy Book',ex.getMessage()+'\n'+'Inputs are -- buy Book-- '+JSON.serialize(buyBook)+'\n'+'---posItem---'+JSON.serialize(posItem)+'\n'+'Class Name - CopperManageBuyBookList_Apex '+'-- Line number --'+ex.getLineNumber());
        } 
        System.debug(buyBook.Id);
        return getBuyBookItemList_Apex (buyBook.Id);
    }
    /**Aim:To fetch the buy book items
* Parameters passed are -
*  buybook: holds the buy book details of type Program__c */
    @AuraEnabled(cacheable=true)
    public static BuyBookItemListWrapper getBuyBookItemList_Apex (string buyBookId)
    {
        System.debug('buyBook'+buyBookId);
        //Fetch account details for Copper Cane
        objAccount=getAccount();
        // to hold the buy book items associated with the buy book
        List<POS_Item__c> buyBookItemList =[SELECT Name,Item_No__c, Item_Name__c, Image_of_Item__c,Brand__c, Brand__r.Brand_Name__c, Pack_Of__c, Price__c, Maximum_Order_Qty__c, Type_of_Item__c, Type_of_Item__r.Item_Type__c, Active__c, Dimension__c FROM POS_Item__c item
                                            WHERE item.Id IN (
                                                SELECT prgitem.POS_Item__c From Program_Item__c prgitem WHERE prgitem.Program__c = :buyBookId)          
                                            ORDER BY Item_Name__c 
                                           ];
        // to hold the pos items available for the buy book
        List<POS_Item__c>  availablePosItems =  [SELECT Name,Item_No__c, Item_Name__c, Image_of_Item__c,Brand__c, Brand__r.Brand_Name__c, Pack_Of__c, Price__c, Maximum_Order_Qty__c, Type_of_Item__c, Type_of_Item__r.Item_Type__c, Active__c, Dimension__c FROM POS_Item__c item
                                                 WHERE item.Id NOT IN (
                                                     SELECT prgitem.POS_Item__c From Program_Item__c prgitem WHERE prgitem.Program__c = :buyBookId
                                                 )
                                                 AND (Inventory_Seasonal_Program__c = 'Seasonal Program' OR Inventory_Seasonal_Program__c = 'Both')
                                                 AND POS_Item__c.Account__C =:objAccount.ID
                                                 ORDER BY Item_Name__c
                                                ];
        System.debug('availablePosItems'+availablePosItems);
        return new BuyBookItemListWrapper(buyBookItemList,availablePosItems);
    } 
    
    
    //Aim:To hold the list of buy book and the buy book names in a form suitable for the buy book name validation
    public class BuyBookListWithNames
    {
        @AuraEnabled
        //To hold the list of buy book
        public List<BuyBookListWithNameAndImageURL> buyBookList ;
        @AuraEnabled
        //To hold the buy book names in a form suitable for the buy book name validation
        public List<String> buyBookNamesForValidation ;
        public BuyBookListWithNames(List<BuyBookListWithNameAndImageURL> buyBookList,List<String> buyBookNamesForValidation )
        {
            this.buyBookList=buyBookList;
            this.buyBookNamesForValidation =buyBookNamesForValidation ;
        }
    }
    public class BuyBookListWithNameAndImageURL
    {
        // to hold the buyBook
        @AuraEnabled
        public Program__c buyBook ;
        //to hold the buy Book image URL
        @AuraEnabled
        public String buyBookImageURL;
        public BuyBookListWithNameAndImageURL (Program__c buyBook, String buyBookImageURL)
        {
            this.buyBook=buyBook;
            this.buyBookImageURL = buyBookImageURL;
        }
    }
    //Aim:To hold the items associated and available with the buy book
    public class BuyBookItemListWrapper
    {
        @AuraEnabled
        //To hold the list of assocaited buy book items
        public List<POS_Item__c> buyBookItemList ;
        @AuraEnabled
        //To hold the list of available buy book items
        public List<POS_Item__c> availablePosItems;
        public BuyBookItemListWrapper(List<POS_Item__c> buyBookItemList,List<POS_Item__c> availablePosItems )
        {
            this.buyBookItemList=buyBookItemList;
            this.availablePosItems =availablePosItems ;
        }
    }
}