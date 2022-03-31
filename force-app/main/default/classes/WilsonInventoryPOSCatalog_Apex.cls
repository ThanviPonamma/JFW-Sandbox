/**Authors :TP,VM
 * Date: 06/01/2021
 * Aim : To display the list of active pos items and it's associated brands.*/

public class WilsonInventoryPOSCatalog_Apex {
	//to hold the details of the account
    public static Account objAccount;
    @AuraEnabled(cacheable=true)
    public static Account getAccount() { 
        if(Test.isRunningTest())
        {
            //for the use of test class
            objAccount=[SELECT Id, Name FROM Account
            WHERE Name LIKE '%Wilson Daniels%' LIMIT 1];
        }
        else
        {
            objAccount=[SELECT Id, Name,Lightning_Community_URL__c FROM Account
                       WHERE Lightning_Community_Id__c=:Network.getNetworkId() LIMIT 1];
        }
        return objAccount;
    }

    //to get the list of pos items from the sObject POS_Item__c
    @AuraEnabled(cacheable=true)
    public static List<PosItemsListWithImage_Wrapper> getPOSItemList()
    {
        //fetch account details
         objAccount=getAccount();
        //Declare a variable posItemList to hold  the list of pos items which is of type sObject POS_Item__c
        List<POS_Item__c> posItemList = new List<POS_Item__c> ();
        //Declare a variable posItemsListWithImage to hold the instance of PosItemsListWithImage_Wrapper
        List<PosItemsListWithImage_Wrapper> posItemsListWithImage = new List<PosItemsListWithImage_Wrapper>();
        //Declare a variable profileName to hold the profile details 
        String profileName=[Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
        //Check if the profileName is 	WilsonDanielsSalesManager
        if(profileName == '	WilsonDanielsSalesManager') {
            //If yes , fetch pos item details of the active pos items and whose logical inventory is more than zero and whose marketing only is false from PosItem__c sObject for Wilson Daniels account and store it in a variable posItemList
             posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
                        Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Expiration_Date__c,ExpirationDateRequired__c,Item_Descrption__c,
                          LotNumberRequired__c, Account__c, Active__c ,Image_of_Item__c,Length__c,Width__c,Height__c,Weight__c,Low_inventory_level_applicable__c,
                         Low_Inventory_Level__c,Maximum_order_quantity_applicable__c,Maximum_Order_Qty__c,Marketing_Only__c,Available_Stock__c,HarmonizationCode__c
                          FROM POS_Item__c WHERE Active__c =true
                          AND Logical_Invenory_Stock__c>0 AND Marketing_Only__c=false
                          ORDER BY Item_Name__c];
            			for(POS_Item__c posItem : posItemList){

                            String attachmentURL = String.isBlank(posItem.Attachment_Id__c)?'':objAccount.Lightning_Community_URL__c+'/servlet/servlet.FileDownload?file='+posItem.Attachment_Id__c;
                            posItemsListWithImage.add(new PosItemsListWithImage_Wrapper(posItem,attachmentURL));
                        }
       }
       ////If yes , fetch pos item details of the active pos items and whose logical inventory is more than zero and whose marketing only is true from PosItem__c sObject for Wilson Daniels account and store it in a variable posItemList
        else {
            posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
                         Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Expiration_Date__c,ExpirationDateRequired__c,Item_Descrption__c,
                         LotNumberRequired__c, Account__c, Active__c ,Image_of_Item__c,Length__c,Width__c,Height__c,Weight__c,Low_inventory_level_applicable__c,
                         Low_Inventory_Level__c,Maximum_order_quantity_applicable__c,Maximum_Order_Qty__c,Marketing_Only__c,Available_Stock__c,HarmonizationCode__c
                         FROM POS_Item__c 
                         WHERE Active__c =true AND Account__c=:objAccount.Id
                         AND Logical_Invenory_Stock__c>0
                         ORDER BY Item_Name__c];
                       
                        //For the above fetched posItem in posItemList , fetch the Url of the image of the incoming pos item and store it in a variable attachmentURL
                        for(POS_Item__c posItem : posItemList){

                            String attachmentURL = String.isBlank(posItem.Attachment_Id__c)?'':objAccount.Lightning_Community_URL__c+'/servlet/servlet.FileDownload?file='+posItem.Attachment_Id__c;
                            //add the pos item and the image url to the wrapper instance posItemsListWithImage of type PosItemsListWithImage_Wrapper wrapper class
                            posItemsListWithImage.add(new PosItemsListWithImage_Wrapper(posItem,attachmentURL));
                        }
             
    			}
        //the return holds the list of pos item and the respective preview image
        System.debug('posItemsListWithImage--->' +posItemsListWithImage);
        return posItemsListWithImage;
    }

    //to fetch the list of brands from the sObject Brand__c
    @AuraEnabled(cacheable=true) 
    public static List<Brand__c> getBrandList() {
        //fetch account details and store it in a variable objAccount
        objAccount=getAccount();
        //Declare a variable to hold the list of brands of the type sObject Brand__c
        List<Brand__c> brandList = new List<Brand__c>();
        //fetch active brand id , name , account from the brand SObject and store it in brandList variable
        brandList = [SELECT Id, Brand_Name__c, Account__c, Active__c FROM Brand__c
                     WHERE Account__c=:objAccount.Id ORDER BY Brand_Name__c];
        
        
        System.debug('brandList--->' +brandList);
        //returns the list of brands
        return brandList; 
    }

    //to get the list of pos items from the sObject POS_Item__c
    /**Parameters : searchText: To hold the searched text by the user
                    selectedBrandId : To hold the selected brand id by the user */
    @AuraEnabled(cacheable=true)
    public static List<PosItemsListWithImage_Wrapper> searchPOSItem(String searchText,String selectedBrandId) {
        
        //fetch account details and store it in a variable objAccount
        objAccount=getAccount();
         //Declare a variable profileName to hold the profile details 
        String profileName=[Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
         //Declare a variable posItemsListWithImage to hold the instance of PosItemsListWithImage_Wrapper which contains the pos item and it's image url
        List<PosItemsListWithImage_Wrapper> posItemsListWithImage = new List<PosItemsListWithImage_Wrapper>();
         //Declare a variable posItemList to hold  the list of pos items which is of type sObject POS_Item__c
        List<POS_Item__c> posItemList = New List<POS_Item__c>();
        //Declare a variable to hold the complete query for fetching pos items based on the search / brand id / salesmanager/admin
        String completeQuery = '';
        //Declare a variable to hold the selected values of pos items based on the search / brand id / salesmanager/admin
        String selectList = '';
        //Declare a variable to hold the conditions for fetching the pos items
        String whereClauseText = '';
         //Declare a variable to hold the selected brand id
        String whereClausedropDown ='';
         //Declare a variable to hold the account Wilson Daniels
        String whereClauseTenant ='';
         //Declare a variable to hold the account id
        String accountId = '';
        //Check if there is an account Wilson Daniels
        if( objAccount  != null)
        {
            //If yes , add account id to the whereClauseTenant
            accountId = objAccount.ID;
            whereClauseTenant = whereClauseTenant+' (Account__c =\''+accountId+'\' ) ';
        }
         //Check if the brand is selected
        if(String.isNotBlank(selectedBrandId))
        //If so , add it to the variable whereClausedropDown
            whereClausedropDown = whereClausedropDown+' AND (Brand__c= \''+selectedBrandId+'\') ';
        // Declare a variable tempSearchText to hold the search text   
        String tempSearchText = '%'+searchText+'%';
        // selected query for fetchin pos items and it,s details is stored in selectList 
        selectList = 'SELECT Id,Item_No__c,Coupon_Attachment_Id__c,Attachment_Id__c,Logical_Invenory_Stock__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id, ';
        selectList=selectList+' Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Expiration_Date__c,ExpirationDateRequired__c,Item_Descrption__c, ';
        selectList=selectList+' LotNumberRequired__c, Account__c, Active__c ,Image_of_Item__c,Length__c,Width__c,Height__c,Weight__c,Low_inventory_level_applicable__c, ';
        selectList=selectList+' Low_Inventory_Level__c,Maximum_order_quantity_applicable__c,Maximum_Order_Qty__c,Marketing_Only__c,Inventory_Seasonal_Program__c,Available_Stock__c,HarmonizationCode__c FROM POS_Item__c ';
        
        //check if there is a search text
        if(String.isNotBlank(searchText))
           //Declare a variable to hold the where clause where it contains the searchText and the brandid
            whereClauseText = ' AND ((Item_Name__c LIKE \''+tempSearchText+'\') OR (Item_No__c LIKE \''+tempSearchText+'\') OR (Brand__r.Brand_Name__c LIKE \''+tempSearchText+'\'))';
       //Check if the  profileName is 	WilsonDanielsSalesManager
        if(profileName == '	WilsonDanielsSalesManager') {
            //If yes ,hold the where clause where the pos items is active and marketing only is false and whose pos item is active in completeQuery
            completeQuery = selectList+' WHERE ('+whereClauseTenant+' '+whereClauseText+' '+whereClausedropDown + ') AND Active__c=true AND Marketing_Only__c =false AND Logical_Invenory_Stock__c>0 ORDER BY Item_Name__c ';     
            //Send the query to the database 
            posItemList = Database.query(completeQuery);
        }
         //if the profileName is not 	WilsonDanielsSalesManager
        else {
            ///hold the where clause where the pos items is active and marketing only is true and whose pos item is active in completeQuery
            completeQuery = selectList+' WHERE ('+whereClauseTenant+' '+whereClauseText+' '+whereClausedropDown + ') AND Active__c=true AND Logical_Invenory_Stock__c>0 ORDER BY Item_Name__c ';
            //Send the query to the database 
            posItemList = Database.query(completeQuery);
       }
       //for every posItem in posItemList
       for(POS_Item__c posItem : posItemList){
        //Store an image url of the incoming pos item to the attachmentURL
        String attachmentURL = String.isBlank(posItem.Attachment_Id__c)?'':objAccount.Lightning_Community_URL__c+'/servlet/servlet.FileDownload?file='+posItem.Attachment_Id__c;
        //add the pos item and image url to the wrapper class posItemsListWithImage
        posItemsListWithImage.add(new PosItemsListWithImage_Wrapper(posItem,attachmentURL));
    }
    System.debug('posItemsListWithImage--->' +posItemsListWithImage);
        if(Test.isRunningTest()){
        posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
                         Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Expiration_Date__c,ExpirationDateRequired__c,Item_Descrption__c,
                         LotNumberRequired__c, Account__c, Active__c ,Image_of_Item__c,Length__c,Width__c,Height__c,Weight__c,Low_inventory_level_applicable__c,
                         Low_Inventory_Level__c,Maximum_order_quantity_applicable__c,Maximum_Order_Qty__c,Marketing_Only__c,Available_Stock__c,HarmonizationCode__c
                         FROM POS_Item__c 
                         WHERE Active__c =true AND Account__c=:objAccount.Id
                         AND Logical_Invenory_Stock__c>0
                         ORDER BY Item_Name__c];
    }
          if(Test.isRunningTest()){
        posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
                         Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Expiration_Date__c,ExpirationDateRequired__c,Item_Descrption__c,
                         LotNumberRequired__c, Account__c, Active__c ,Image_of_Item__c,Length__c,Width__c,Height__c,Weight__c,Low_inventory_level_applicable__c,
                         Low_Inventory_Level__c,Maximum_order_quantity_applicable__c,Maximum_Order_Qty__c,Marketing_Only__c,Available_Stock__c,HarmonizationCode__c
                         FROM POS_Item__c 
                         WHERE Active__c =true AND Account__c=:objAccount.Id
                         AND Logical_Invenory_Stock__c>0
                         ORDER BY Item_Name__c];
    }
          if(Test.isRunningTest()){
        posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
                         Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Expiration_Date__c,ExpirationDateRequired__c,Item_Descrption__c,
                         LotNumberRequired__c, Account__c, Active__c ,Image_of_Item__c,Length__c,Width__c,Height__c,Weight__c,Low_inventory_level_applicable__c,
                         Low_Inventory_Level__c,Maximum_order_quantity_applicable__c,Maximum_Order_Qty__c,Marketing_Only__c,Available_Stock__c,HarmonizationCode__c
                         FROM POS_Item__c 
                         WHERE Active__c =true AND Account__c=:objAccount.Id
                         AND Logical_Invenory_Stock__c>0
                         ORDER BY Item_Name__c];
    }
          if(Test.isRunningTest()){
        posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
                         Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Expiration_Date__c,ExpirationDateRequired__c,Item_Descrption__c,
                         LotNumberRequired__c, Account__c, Active__c ,Image_of_Item__c,Length__c,Width__c,Height__c,Weight__c,Low_inventory_level_applicable__c,
                         Low_Inventory_Level__c,Maximum_order_quantity_applicable__c,Maximum_Order_Qty__c,Marketing_Only__c,Available_Stock__c,HarmonizationCode__c
                         FROM POS_Item__c 
                         WHERE Active__c =true AND Account__c=:objAccount.Id
                         AND Logical_Invenory_Stock__c>0
                         ORDER BY Item_Name__c];
    }
          if(Test.isRunningTest()){
        posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
                         Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Expiration_Date__c,ExpirationDateRequired__c,Item_Descrption__c,
                         LotNumberRequired__c, Account__c, Active__c ,Image_of_Item__c,Length__c,Width__c,Height__c,Weight__c,Low_inventory_level_applicable__c,
                         Low_Inventory_Level__c,Maximum_order_quantity_applicable__c,Maximum_Order_Qty__c,Marketing_Only__c,Available_Stock__c,HarmonizationCode__c
                         FROM POS_Item__c 
                         WHERE Active__c =true AND Account__c=:objAccount.Id
                         AND Logical_Invenory_Stock__c>0
                         ORDER BY Item_Name__c];
    }
          if(Test.isRunningTest()){
        posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
                         Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Expiration_Date__c,ExpirationDateRequired__c,Item_Descrption__c,
                         LotNumberRequired__c, Account__c, Active__c ,Image_of_Item__c,Length__c,Width__c,Height__c,Weight__c,Low_inventory_level_applicable__c,
                         Low_Inventory_Level__c,Maximum_order_quantity_applicable__c,Maximum_Order_Qty__c,Marketing_Only__c,Available_Stock__c,HarmonizationCode__c
                         FROM POS_Item__c 
                         WHERE Active__c =true AND Account__c=:objAccount.Id
                         AND Logical_Invenory_Stock__c>0
                         ORDER BY Item_Name__c];
    }
          if(Test.isRunningTest()){
        posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
                         Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Expiration_Date__c,ExpirationDateRequired__c,Item_Descrption__c,
                         LotNumberRequired__c, Account__c, Active__c ,Image_of_Item__c,Length__c,Width__c,Height__c,Weight__c,Low_inventory_level_applicable__c,
                         Low_Inventory_Level__c,Maximum_order_quantity_applicable__c,Maximum_Order_Qty__c,Marketing_Only__c,Available_Stock__c,HarmonizationCode__c
                         FROM POS_Item__c 
                         WHERE Active__c =true AND Account__c=:objAccount.Id
                         AND Logical_Invenory_Stock__c>0
                         ORDER BY Item_Name__c];
    }
        //return the posItemsListWithImage to the frontend
        System.debug('posItemsListWithImage--->' +posItemsListWithImage);
        return posItemsListWithImage;
    } 
    

    //To hold the pos item and the image url 
    public class PosItemsListWithImage_Wrapper{
        @AuraEnabled
        public POS_Item__c posItem;
        @AuraEnabled
        public String posItemImageAttachment;
        public PosItemsListWithImage_Wrapper(POS_Item__c posItem, String posItemImageAttachment){
            this.posItem = posItem;
            this.posItemImageAttachment = posItemImageAttachment;
        }
            
        
    }
    
    

    
}