/** Author : Sanjana; Date : 21-09-2021

* Aim : To fetch pos items , add/update the pos item , deactivate the pos item , find pos items based on the search and brand /item type filters **/

public class InfiniumManagePosItems_Apex {
    
    //Global variable which holds the account
    public static Account objAccount;
    //To fetch account details
    public static Account getAccount() { 
        // for the test class
        if(Test.isRunningTest())
        {
            // fetching the Id, lightning community Id ad name from the sObject Account and storing it in the variable objAccount
            objAccount=[SELECT Id, Name FROM Account
                        WHERE Name LIKE '%Infinium Spirits%' LIMIT 1];
        }
        else
        {
            // fetching the Id, lightning community Id ad name from the sObject Account and storing it in the variable objAccount of type sObject Account
            objAccount=[SELECT Id, Lightning_Community_URL__c, Name FROM Account
                        WHERE Lightning_Community_Id__c=:Network.getNetworkId() LIMIT 1];
        }
        //system.debug('objAccount------>'+objAccount);
        return objAccount;
    }
    
   
    
    
    @AuraEnabled
    public static String addOrEditPOSItem_Apex(POS_Item__c posItem,String imageBlobData,String fileName,String ContentType,List<string> states) 
    {
        try{
            system.debug('entered');
            system.debug('posItem---->' +posItem);
            system.debug('imageBlobData---->' +imageBlobData);
            system.debug('fileName---->' +fileName);
            system.debug('ContentType---->' +ContentType);
            //  hold the account details in the variable objAccount of type sObject Account
            objAccount=getAccount();
            // to fetch the pos item attachment from the sObject Attachment whose parent is the incoming pos item Id
            List<Attachment> currentAttachment=[SELECT Id,Body,ContentType,BodyLength,Name FROM Attachment WHERE parentId=:posItem.Id];
            // if Low_inventory_level_applicable__c doesnot exist, make it null
            if(!posItem.Low_inventory_level_applicable__c)
                posItem.Low_Inventory_Level__c=null;
            // if ExpirationDateRequired__c doesnot exist, make it null
            if(!posItem.ExpirationDateRequired__c)
                posItem.Expiration_Date__c=null;
            // if Maximum_order_quantity_applicable__c doesnot exist, make it null
            if(!posItem.Maximum_order_quantity_applicable__c)
                posItem.Maximum_Order_Qty__c=null;
            // assigning the Infinium account id to the account field of pos item
            posItem.Account__c = objAccount.Id;
            system.debug('posItem-------->'+posItem);
            //create a new record or update the existing record in the pos item table
            upsert posItem;
            
            // check if imageBlobData is blank
            if(String.isNotBlank(imageBlobData))
            {
                // fetch the imageBlobData URL
                imageBlobData = EncodingUtil.urlDecode(imageBlobData, 'UTF-8');
                // create a new instance of the sObject Attachment and store it in the variable attach
                Attachment attach = new Attachment();
                // assign pos Item id
                attach.parentId = posItem.Id;
                //set the imageBlobData to the body of the Attachment
                attach.Body = EncodingUtil.base64Decode(imageBlobData);
                // assign fileName to the Attachment name
                attach.Name = fileName;
                // assign contentType to the Attachment contentType
                attach.ContentType = contentType;
                Insert attach; 
                posItem.Attachment_Id__c=attach.Id;
                //update the pos item record
                system.debug('posItem-------->'+posItem);
                update posItem;
                
            }
           
            //Aim:To populate the junction object POSItem_States__c with pos item Id and states
            //creating an instance of the junction object POSItem_States__c
            List<POSItem_States__c> posItemStates = new List<POSItem_States__c>();
            //fetch the existing states for a selected pos item
            Map<Id,State__c> existingPosItemState=new Map<Id,State__c> ([SELECT Id FROM State__c WHERE Id IN :states AND Id IN 
                                                                         (SELECT State__c FROM POSItem_States__c WHERE POS_Item__c=:posItem.Id)]);
            //for all the states obtained from the frontend
            for(string state: states){
                //check if an state is already existing
                if(!existingPosItemState.containsKey(state)){
                    //if not, create an instance of POSItem_States__c
                    POSItem_States__c posItemState = new POSItem_States__c();
                    //update positem field with the posItemId
                    posItemState.POS_Item__c = posItem.Id;
                    //update the state with obtained state
                    posItemState.State__c = state;
                    //add posItemState to a variable posItemStates
                    posItemStates.add(posItemState);
                }
            }
            //upsert posItemStates
            upsert posItemStates;
            //delete the POSItem_States__c which if the state is not associated with the pos item id
            delete [SELECT Id FROM POSItem_States__c WHERE POS_Item__c=:posItem.Id AND State__c NOT IN :states];
            system.debug('posItemStates----->'+posItemStates);
            // return the string 'done'
            return 'done';
            
        }
        catch(Exception ex){
            // incase of any exceptions, send email to notify
            InfiniumEmailNotifications.sendNotification('Adding Pos Item',ex.getMessage()+'\n'+'Inputs are -- posItem-- '+JSON.serialize(posItem)+'\n'+'---imageBlobData---'+JSON.serialize(imageBlobData)
                                                      +'\n'+'---fileName---'+JSON.serialize(fileName)+'\n'+'---ContentType---'+JSON.serialize(ContentType)+'\n'+'Class Name - InfiniumManagePosItems_Apex '+'-- Line number --'+ex.getLineNumber());
            // return the string 'not done'                                       
            return 'not done';                                        
        }     
    }
    
    
    //Aim:To fetch all states from the object State__c
    @AuraEnabled(cacheable = true)
    public static List<DualListWrapper> getAllState(){
        //creating an instance of the wrapper class DualListWrapper
        List<DualListWrapper> allStates = new List<DualListWrapper>(); 
        //for all the states , fetch Id, state name and store it in a variable allStates
        for(State__c state: [SELECT Id,State_Name__c FROM State__c WHERE Country__r.Country_Code__c = 'US' ORDER BY State_Name__c]){
            allStates.add(new DualListWrapper(state.State_Name__c,state.Id));
        }
        system.debug('allStates---->'+allStates);
        //return the variable allstates
        return allStates;
    }
    
    
   
    //Aim:To fetch the selected and unselected states from the object POSItem_States__c
    @AuraEnabled(cacheable = true)
    public static stateListForEdit getAllAndSelectedStates(String posItemId){
        system.debug('posItemId----->'+posItemId);
        List<DualListWrapper> allStates = new List<DualListWrapper>();
        List<Id> selectedStates = new List<Id>();
        Map<Id,State__c> posItemState = new Map<Id,State__c>([SELECT ID, State_Name__c FROM State__c st  WHERE st.Id IN (
            SELECT State__c FROM POSItem_States__c stdiv WHERE stdiv.POS_Item__c = :posItemId)
                                                              ORDER BY st.State_Name__c]);
        system.debug('posItemState---->'+posItemState);
        
        
        selectedStates.addAll(posItemState.keySet());
        for(State__c state :[SELECT ID,State_Name__c FROM State__c st 
                             ORDER BY st.State_Name__c]){
                                 allStates.add(new DualListWrapper(state.State_Name__c,state.Id));
                             }
        system.debug('allStates---->'+allStates);
        system.debug('selectedStates---->'+selectedStates);
        
        return new stateListForEdit(allStates,selectedStates);
    }
    
    
    
    public class stateListForEdit{
        @AuraEnabled
        public List<DualListWrapper> allStates;
        @AuraEnabled
        public List<String> selectedStates;
        public stateListForEdit(List<DualListWrapper> allStates, List<String> selectedStates){
            this.allStates = allStates;
            this.selectedStates = selectedStates;
        }
    }
    
    public class DualListWrapper 
    {
        //to hold the name of the territory
        @AuraEnabled
        public String label;
        //to hold the Id of the territory
        @AuraEnabled
        public String value;
        public DualListWrapper(String label,String value)
        {
            this.label=label;
            this.value=value;
        }
    }
    
    
    
    
    
    @AuraEnabled(cacheable = true)
    //to fetch the list of brands that belong to the account Infinium
    public static List<Brand__c> getBrandList_Apex() {
        //to fetch the account details
        objAccount=getAccount();
        //to create a variable brandList of type sObject List<Brand__c>
        List<Brand__c> brandList = new List<Brand__c>();
        //to fetch the details of the custom objects Brand__c and store it in the variable  brandList
        brandList = [SELECT Id, Brand_Name__c, Account__c, Active__c FROM Brand__c
                     WHERE Account__c=:objAccount.Id  AND Active__c=true ORDER BY Brand_Name__c];
        //return the variable brandList
        system.debug('brandList------->'+brandList);
        return brandList; 
    }
    
    @AuraEnabled(cacheable = true)
    // to fetch the list of item types that belong to the account Infinium
    public static List<Item_Type__c> getItemTypeList_Apex() {
        //to fetch the account details
        objAccount=getAccount();
        // to create a variable itemTypeList of type sObject List<Item_Type__c>
        List<Item_Type__c> itemTypeList = new List<Item_Type__c>();
        // to fetch the details of the custom objects Item_Type__c and store it in the variable  itemTypeList
        itemTypeList = [SELECT Name, Item_Type__c, Active__c, Account__c FROM Item_Type__c 
                        WHERE Account__c=:objAccount.Id  AND Active__c=true ORDER BY Item_Type__c];
        // return the variable itemTypeList
        system.debug('itemTypeList------->'+itemTypeList);
        return itemTypeList;
    }
    
    
    @AuraEnabled(cacheable = true)
    // to fetch the pos item based on filters
    public static PosItemListWithNames searchPOSItem_Apex(String searchText,String selectedBrand, String selectedItemType,Integer recordStartIndex) {
        system.debug('entered backend');
        system.debug('searchText---->'+searchText);
        system.debug('selectedBrand---->'+selectedBrand);
        system.debug('selectedItemType---->'+selectedItemType);
        objAccount=getAccount();
        //to hold the pos item image URL
        List<PosItemListWithNameAndImageURL> posItemURLList = new List<PosItemListWithNameAndImageURL>();
        //to hold the list of pos itms of type List<POS_Item__c>
        List<POS_Item__c> posItemList = new List<POS_Item__c>();
          //to hold the list of pos itms of type List<POS_Item__c>
          List<POS_Item__c> posItemListBySearch = new List<POS_Item__c>();
        //This variable is used to perform validations in the front end
        List<String> posItemNamesForValidation=new List<String> ();
        //This variable is used to perform validations in the front end
        List<String> posItemStockNumbersForValidation=new List<String> ();
        //variable of type string to hold the complete string of the query
        String completeQry = '';
        //variable of type string to hold the list of pos item details to be fetched
        String selectList = '';
        //variable of type string to hold the conditions to fetch the pos item
        String whereClauseText = '';
        //variable of type string to hold the value of the user selected filters 
        String whereClausedropDown ='';
        //variable of type string to hold the account condition
        String whereClauseTenant ='';
        //variable of type string to hold the Id of the account
        String accountId = '';
        //check if the account is not null
        if( objAccount  != null)
        {
            //assign the account Id to the variable accountId
            accountId = objAccount.ID;
            //assign the accountId condition to the variable whereClauseTenant
            whereClauseTenant = whereClauseTenant+' (Account__c =\''+accountId+'\' ) ';
        }
        //check if the selectedBrand is not blank
        if(String.isNotBlank(selectedBrand))
            //assign the selectedBrand condition to the variable whereClausedropDown
            whereClausedropDown = whereClausedropDown+' AND (Brand__c= \''+selectedBrand+'\') ';
        //check if the selectedBrand is not blank
        if (String.isNotBlank(selectedItemType))
            //assign the selectedItemType condition to the variable whereClausedropDown
            whereClausedropDown = whereClausedropDown+' AND (Type_of_Item__c=\''+selectedItemType+'\') ';
        //variable of type string to hold the search text entered by the user
        String tempSearchText = '%'+searchText+'%';
        //to fetch the list of pos items along with filter conditions and of those that belong to the account Infinium
        selectList = 'SELECT Id,Item_No__c,Coupon_Attachment_Id__c,Attachment_Id__c,Logical_Invenory_Stock__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id, ';
        selectList=selectList+' Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Expiration_Date__c,ExpirationDateRequired__c,Item_Descrption__c, ';
        selectList=selectList+' LotNumberRequired__c, Account__c, Active__c ,Vendor__c,Image_of_Item__c,Length__c,Width__c,Height__c,Weight__c,Low_inventory_level_applicable__c, ';
        selectList=selectList+' Low_Inventory_Level__c,Maximum_order_quantity_applicable__c,Maximum_Order_Qty__c,Marketing_Only__c,Inventory_Seasonal_Program__c,Available_Stock__c,HarmonizationCode__c FROM POS_Item__c ';
        if(String.isNotBlank(searchText))
            whereClauseText = ' AND ((Type_of_Item__r.Item_Type__c LIKE \''+tempSearchText+'\') OR (Item_Name__c LIKE \''+tempSearchText+'\') OR (Item_No__c LIKE \''+tempSearchText+'\') OR (Brand__r.Brand_Name__c LIKE \''+tempSearchText+'\'))';
        completeQry = selectList+' WHERE ('+whereClauseTenant+' '+whereClauseText+' '+whereClausedropDown + ') ORDER BY Item_Name__c ';
        posItemListBySearch = Database.query(completeQry);
        for(Integer i=recordStartIndex==null?0:recordStartIndex;i<=recordStartIndex+49;i++)
            {
                if(i<posItemListBySearch.size())
                posItemList.add(posItemListBySearch[i]);
            }
        //for all the posItemList held by the variable posItem of type sObject POS_Item__c
        for(POS_Item__c posItem : posItemList)
        {
            // coverting the pos item name to the upper case,remove the white spaces between the words and storing it in the variable posItemNamesForValidation which is of type String
            posItemNamesForValidation.add(posItem.Item_Name__c.remove(' ').trim().toUppercase());
            // coverting the pos item number to the upper case,remove the white spaces between the words and storing it in the variable posItemNamesForValidation which is of type String
            posItemStockNumbersForValidation.add(posItem.Item_No__c.remove(' ').trim().toUppercase());
            // declare a variable of type string to hold the attachment Id of the pos item
            String attachmentURL = String.isBlank(posItem.Attachment_Id__c)?'':objAccount.Lightning_Community_URL__c+'/servlet/servlet.FileDownload?file='+posItem.Attachment_Id__c;
            // adding pos items along with its image to the wrapper class PosItemListWithNameAndImageURL
            posItemURLList.add(new PosItemListWithNameAndImageURL(posItem,attachmentURL));
        }
        system.debug('posItemURLList----->'+posItemURLList);
        system.debug('posItemNamesForValidation----->'+posItemNamesForValidation);
        system.debug('posItemStockNumbersForValidation----->'+posItemStockNumbersForValidation);
        //return the wrapper class which has the list of pos items , pos items with validations and pos items with stock validations.
        return new PosItemListWithNames(posItemURLList,posItemNamesForValidation,posItemStockNumbersForValidation,posItemListBySearch.size());
    }
    
    
    @AuraEnabled
    //to deactivate the selected pos item
    public static String deactivateSelectedItem(POS_Item__c posItem)
    { 
        try{
            //assigning the value false to the pos item
            posItem.Active__c=false;
            //update the pos item record
            update posItem;
            //return the string 'done'
            return 'done';
        }
        catch(Exception ex){
            // incase of any exceptions, send email to notify
            InfiniumEmailNotifications.sendNotification('Adding Pos Item',ex.getMessage()+'\n'+'Inputs are -- posItem-- '+JSON.serialize(posItem)
                                                      +'\n'+'Class Name - InfiniumManagePosItems_Apex '+'-- Line number --'+ex.getLineNumber());
            // return the string 'not done'     
            return 'not done';                                       
        }  
        
        
    } 
    
    public class PosItemListWithNames
    {
        //to hold the image URL of the Pos item which is of the type List<PosItemListWithNameAndImageURL>
        @AuraEnabled
        public List<PosItemListWithNameAndImageURL> posItemList ;
        //to hold the pos item names needed for validation in the front end
        @AuraEnabled
        public List<String> posItemNamesForValidation ;
        // to hold the pos item numbers needed for validation in the front end
        @AuraEnabled
        public List<String> posItemStockNumbersForValidation;
        @AuraEnabled
        public Integer totalPosItemsSize;

        public PosItemListWithNames (List<PosItemListWithNameAndImageURL> posItemList,List<String> posItemNamesForValidation,List<String> posItemStockNumbersForValidation,Integer totalPosItemsSize)
        {
            this.posItemList=posItemList;
            this.posItemNamesForValidation=posItemNamesForValidation;
            this.posItemStockNumbersForValidation=posItemStockNumbersForValidation; 
            this.totalPosItemsSize=totalPosItemsSize;
            
        }
    } 
    
    public class PosItemListWithNameAndImageURL
    {
        // to hold the list of pos items
        @AuraEnabled
        public POS_Item__c posItemList ;
        //to hold the pos item image URL
        @AuraEnabled
        public String posItemImageURL;
        public PosItemListWithNameAndImageURL (POS_Item__c posItemList, String posItemImageURL)
        {
            this.posItemList=posItemList;
            this.posItemImageURL = posItemImageURL;
        }
    }
    
    
}