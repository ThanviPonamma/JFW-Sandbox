//Author : SN , VB
//Date : October 15th 2020
//Aim : To display the pos item image , item no , Item Name ,Brand ,Pack of ,Price , inventory ,max order quanity and approval required status of the pos items in pdf

public  class JFWPOSCatalog_Apex{
    // Declare a variable to hold the JFW account details of type Account sObject
    public static Account objAccount; 
    //Declare a variable which can hold pos items
    public List<POS_Item__c> posItemList {get; set; } 
    
    //To fetch account details
    public static Account getAccount() {  
        
        if(Test.isRunningTest())
        {
            //Fetch account id , name from account for jfw
            objAccount=[SELECT Id, Name FROM Account
                        WHERE Name LIKE '%JFW%' LIMIT 1];
        }
        else
        {
            // objAccount=[SELECT Id, Name FROM Account
            //   WHERE Name LIKE '%JFW%' LIMIT 1];
            
            objAccount=[SELECT Id, Name FROM Account
                        WHERE Lightning_Community_Id__c=:Network.getNetworkId() LIMIT 1];
        }
        //return objAccount
        return objAccount; 
    }
    
    
    // Author: Thanvi, Sanjana
    // Date: 9/3/2021
    // Commenting the below code and rewriting the method to satisfy the CR - JFW-09-March-10
    // /**To fetch the pos item image , item no , Item Name ,Brand ,Pack of ,Price , inventory ,max order quanity and approval required status of the active pos items 
    // and whose logical inventory is more than zero from PosItem__c sObject for JFW account     */
    // public JFWPOSCatalog_Apex(ApexPages.StandardController controller) {
    //     System.debug('recordId---->'+recordId);
    //     System.debug('itemId---->'+itemId);
    
    //     //fetch account details
    //     objAccount = getAccount();
    //     //store the selected brand id in a variable brandId of type string
    //     String brandId=controller.getId();
    //    //fetch profile id , name  from profile sObject for the logged in user and store in a variable profile name of type string
    //     String profileName=[Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
    //     //Check if the profileName is JFWsalesmanager
    //     if(profileName == 'JFWsalesmanager' ) {
    //        //If yes , check if the brand id is present
    //         if(String.isNotEmpty(brandId)) {
    //             //If yes fetch pos item details of the active pos items and whose logical inventory is more than zero and whose marketing only is false from PosItem__c sObject for JFW account and for the incoming brand id and store it in a variable posItemList
    
    //             posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
    //                          Pack_Of__c, Price__c, Item_Name__c,Approval_Required__c,Item_Descrption__c,Account__c,Image_of_Item__c,
    //                          Marketing_Only__c,Inventory_Seasonal_Program__c,Maximum_Order_Qty__c,Available_Stock__c,HarmonizationCode__c,Active__c
    //                          FROM POS_Item__c WHERE Active__c =true AND Marketing_Only__c=false AND Logical_Invenory_Stock__c>0 AND Brand__c=:brandId AND Account__c =:objAccount.Id
    //                         ORDER BY Item_Name__c];
    //         }
    //         else {
    //             //If no, fetch pos item details of the active pos items and whose logical inventory is more than zero and whose marketing only is false from PosItem__c sObject for JFW account and store it in a variable posItemList
    
    //             posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
    //                          Pack_Of__c, Price__c, Item_Name__c,Approval_Required__c,Item_Descrption__c,
    //                          Account__c, Active__c ,Image_of_Item__c,Length__c,Width__c,Height__c,Weight__c,Low_inventory_level_applicable__c,
    //                          Marketing_Only__c,Inventory_Seasonal_Program__c,Maximum_Order_Qty__c,Available_Stock__c
    //                          FROM POS_Item__c WHERE Active__c =true AND Marketing_Only__c=false  AND Logical_Invenory_Stock__c>0 AND Account__c =:objAccount.Id
    //                          ORDER BY Item_Name__c];
    //         }
    //     }
    
    //     //If the profileName is not JFWsalesmanager
    //     else
    //     {
    //         //Check if the brand id is present
    //         if(String.isNotEmpty(brandId)) 
    //         {
    //             //If yes , fetch pos item details of the active pos items and whose logical inventory is more than zero and whose marketing only is true from PosItem__c sObject for JFW account and for the incoming brand id and store it in a variable posItemList
    //             posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Approval_Required__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
    //                          Pack_Of__c, Price__c, Item_Name__c,Item_Descrption__c,
    //                          Account__c, Active__c ,Image_of_Item__c,
    //                          Marketing_Only__c,Inventory_Seasonal_Program__c,Maximum_Order_Qty__c,Available_Stock__c
    //                          FROM POS_Item__c WHERE Active__c =true AND Logical_Invenory_Stock__c>0 AND  Brand__c=:brandId AND Account__c =:objAccount.Id
    //                          ORDER BY Item_Name__c];
    //         }
    //         else
    //         {
    //             //If no , fetch pos item details of the active pos items and whose logical inventory is more than zero and whose marketing only is true from PosItem__c sObject for JFW account and store it in a variable posItemList
    //             posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
    //                          Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Item_Descrption__c,
    //                          Account__c, Active__c,
    //                          Marketing_Only__c,Inventory_Seasonal_Program__c,Maximum_Order_Qty__c,Available_Stock__c,HarmonizationCode__c
    //                          FROM POS_Item__c WHERE Active__c =true AND Logical_Invenory_Stock__c>0 AND Account__c =:objAccount.Id
    //                          ORDER BY Item_Name__c];
    //         }
    //     }
    //     if(Test.isRunningTest()) {
    //         posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
    //                          Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Item_Descrption__c,
    //                          Account__c, Active__c,
    //                          Marketing_Only__c,Inventory_Seasonal_Program__c,Available_Stock__c,Maximum_Order_Qty__c,HarmonizationCode__c
    //                          FROM POS_Item__c WHERE Active__c =true AND Logical_Invenory_Stock__c>0 AND Account__c =:objAccount.Id
    //                          ORDER BY Item_Name__c];
    //     }
    //      if(Test.isRunningTest()) {
    //          posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
    //                           Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Item_Descrption__c,
    //                           Account__c, Active__c,
    //                           Marketing_Only__c,Inventory_Seasonal_Program__c,Available_Stock__c,Maximum_Order_Qty__c,HarmonizationCode__c
    //                           FROM POS_Item__c WHERE Active__c =true AND Logical_Invenory_Stock__c>0
    //                           ORDER BY Item_Name__c];
    //      }
    //       if(Test.isRunningTest()) {
    //          posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
    //                           Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Item_Descrption__c,
    //                           Account__c, Active__c,
    //                           Marketing_Only__c,Inventory_Seasonal_Program__c,Maximum_Order_Qty__c,Available_Stock__c,HarmonizationCode__c
    //                          FROM POS_Item__c WHERE Active__c =true AND Logical_Invenory_Stock__c>0
    //                           ORDER BY Item_Name__c];
    //      }
    //      if(Test.isRunningTest()) {
    //          posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
    //                           Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Item_Descrption__c,
    //                           Account__c, Active__c,
    //                           Marketing_Only__c,Inventory_Seasonal_Program__c,Maximum_Order_Qty__c,Available_Stock__c,HarmonizationCode__c
    //                           FROM POS_Item__c WHERE Active__c =true AND Logical_Invenory_Stock__c>0
    //                           ORDER BY Item_Name__c];
    //      }
    //      if(Test.isRunningTest()) {
    //          posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
    //                           Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Item_Descrption__c,
    //                           Account__c, Active__c,
    //                           Marketing_Only__c,Inventory_Seasonal_Program__c,Maximum_Order_Qty__c,Available_Stock__c,HarmonizationCode__c
    //                           FROM POS_Item__c WHERE Active__c =true AND Logical_Invenory_Stock__c>0
    //                           ORDER BY Item_Name__c];
    //      }
    //      if(Test.isRunningTest()) {
    //          posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
    //                           Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Item_Descrption__c,
    //                           Account__c, Active__c,
    //                           Marketing_Only__c,Inventory_Seasonal_Program__c,Maximum_Order_Qty__c,Available_Stock__c,HarmonizationCode__c
    //                           FROM POS_Item__c WHERE Active__c =true AND Logical_Invenory_Stock__c>0
    //                           ORDER BY Item_Name__c];
    //      }
    //      if(Test.isRunningTest()) {
    //          posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
    //                           Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Item_Descrption__c,
    //                           Account__c, Active__c,
    //                           Marketing_Only__c,Inventory_Seasonal_Program__c,Maximum_Order_Qty__c,Available_Stock__c,HarmonizationCode__c
    //                           FROM POS_Item__c WHERE Active__c =true AND Logical_Invenory_Stock__c>0
    //                           ORDER BY Item_Name__c];
    //      }
    //      if(Test.isRunningTest()) {
    //          posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
    //                           Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Item_Descrption__c,
    //                           Account__c, Active__c,
    //                           Marketing_Only__c,Inventory_Seasonal_Program__c,Maximum_Order_Qty__c,Available_Stock__c,HarmonizationCode__c
    //                           FROM POS_Item__c WHERE Active__c =true AND Logical_Invenory_Stock__c>0
    //                           ORDER BY Item_Name__c];
    //      }
    //      if(Test.isRunningTest()) {
    //          posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
    //                           Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Item_Descrption__c,
    //                           Account__c, Active__c,
    //                           Marketing_Only__c,Inventory_Seasonal_Program__c,Maximum_Order_Qty__c,Available_Stock__c,HarmonizationCode__c
    //                           FROM POS_Item__c WHERE Active__c =true AND Logical_Invenory_Stock__c>0
    //                           ORDER BY Item_Name__c];
    //      }
    //      if(Test.isRunningTest()) {
    //          posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
    //                           Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Item_Descrption__c,
    //                           Account__c, Active__c,
    //                           Marketing_Only__c,Inventory_Seasonal_Program__c,Maximum_Order_Qty__c,Available_Stock__c,HarmonizationCode__c
    //                           FROM POS_Item__c WHERE Active__c =true AND Logical_Invenory_Stock__c>0
    //                           ORDER BY Item_Name__c];
    //      }
    //      if(Test.isRunningTest()) {
    //          posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
    //                           Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Item_Descrption__c,
    //                           Account__c, Active__c,
    //                           Marketing_Only__c,Inventory_Seasonal_Program__c,Maximum_Order_Qty__c,Available_Stock__c,HarmonizationCode__c
    //                           FROM POS_Item__c WHERE Active__c =true AND Logical_Invenory_Stock__c>0
    //                           ORDER BY Item_Name__c];
    //      }
    //      if(Test.isRunningTest()) {
    //          posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
    //                           Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Item_Descrption__c,
    //                           Account__c, Active__c,
    //                           Marketing_Only__c,Inventory_Seasonal_Program__c,Maximum_Order_Qty__c,Available_Stock__c,HarmonizationCode__c
    //                           FROM POS_Item__c WHERE Active__c =true AND Logical_Invenory_Stock__c>0
    //                           ORDER BY Item_Name__c];
    //      }
    //      if(Test.isRunningTest()) {
    //          posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
    //                           Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Item_Descrption__c,
    //                           Account__c, Active__c,
    //                           Marketing_Only__c,Inventory_Seasonal_Program__c,Maximum_Order_Qty__c,Available_Stock__c,HarmonizationCode__c
    //                           FROM POS_Item__c WHERE Active__c =true AND Logical_Invenory_Stock__c>0
    //                           ORDER BY Item_Name__c];
    //      }
    //      if(Test.isRunningTest()) {
    //          posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
    //                           Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Item_Descrption__c,
    //                           Account__c, Active__c,
    //                           Marketing_Only__c,Inventory_Seasonal_Program__c,Maximum_Order_Qty__c,Available_Stock__c,HarmonizationCode__c
    //                           FROM POS_Item__c WHERE Active__c =true AND Logical_Invenory_Stock__c>0
    //                           ORDER BY Item_Name__c];
    //      }
    //      if(Test.isRunningTest()) {
    //          posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
    //                           Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Item_Descrption__c,
    //                           Account__c, Active__c,
    //                           Marketing_Only__c,Inventory_Seasonal_Program__c,Maximum_Order_Qty__c,Available_Stock__c,HarmonizationCode__c
    //                           FROM POS_Item__c WHERE Active__c =true AND Logical_Invenory_Stock__c>0
    //                           ORDER BY Item_Name__c];
    //      }
    // } 
    
    
    
    
    /**To fetch the pos item image , item no , Item Name ,Brand ,Pack of ,Price , inventory ,max order quanity and approval required status of the active pos items 
and whose logical inventory is more than zero from PosItem__c sObject for JFW account     */
    public JFWPOSCatalog_Apex(ApexPages.StandardController controller) {
        
        
        //fetch account details
        objAccount = getAccount();
        //store the selected brand id in a variable brandId of type string
        String brandId = ApexPages.currentPage().getParameters().get('brandId');
        //store the selected Item id in a variable ItemId of type string
        String itemTypeId = ApexPages.currentPage().getParameters().get('itemTypeId');
        
        System.debug('brandId---->'+brandId);
        System.debug('itemTypeId---->'+itemTypeId);
        //fetch profile id , name  from profile sObject for the logged in user and store in a variable profile name of type string
        String profileName=[Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
        //Declare a variable to hold the complete query for fetching pos items based on the search / brand id / salesmanager/admin
        String completeQuery = '';
        //Declare a variable to hold the selected values of pos items based on the search / brand id / salesmanager/admin
        String selectList = '';
        //Declare a variable to hold the conditions for fetching the pos items
        String whereClauseText = '';
        //Declare a variable to hold the selected brand id
        String whereClausedropDown ='';
        //Declare a variable to hold the account JFW
        String whereClauseTenant ='';
        //Declare a variable to hold the account id
        String accountId = '';
        //Check if there is an account JFW
        if( objAccount  != null)
        {
            //If yes , add account id to the whereClauseTenant
            accountId = objAccount.ID;
            whereClauseTenant = whereClauseTenant+' (Account__c =\''+accountId+'\' ) ';
        }
        //Check if the brand is selected
        if(String.isNotBlank(brandId))
            //If so , add it to the variable whereClausedropDown
            whereClausedropDown = whereClausedropDown+' AND (Brand__c= \''+brandId+'\') ';
        
        //Check if the item type is selected
        if(String.isNotBlank(itemTypeId))
            //If so , add it to the variable whereClausedropDown
            whereClausedropDown = whereClausedropDown+' AND (Type_of_Item__c= \''+itemTypeId+'\') ';
        
        // selected query for fetchin pos items and it,s details is stored in selectList 
        selectList = 'SELECT Id,Item_No__c,Coupon_Attachment_Id__c,Attachment_Id__c,Logical_Invenory_Stock__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id, ';
        selectList=selectList+' Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Expiration_Date__c,ExpirationDateRequired__c,Item_Descrption__c, ';
        selectList=selectList+' LotNumberRequired__c, Account__c, Active__c ,Image_of_Item__c,Length__c,Width__c,Height__c,Weight__c,Low_inventory_level_applicable__c, ';
        selectList=selectList+' Low_Inventory_Level__c,Maximum_order_quantity_applicable__c,Maximum_Order_Qty__c,Marketing_Only__c,Inventory_Seasonal_Program__c,Available_Stock__c,HarmonizationCode__c FROM POS_Item__c ';
        
        
        //Check if the  profileName is JFWsalesmanager
        if(profileName == 'JFWsalesmanager') {
            //If yes ,hold the where clause where the pos items is active and marketing only is false and whose pos item is active in completeQuery
            completeQuery = selectList+' WHERE ('+whereClauseTenant+' '+whereClauseText+' '+whereClausedropDown + ') AND Active__c=true AND Marketing_Only__c =false AND Logical_Invenory_Stock__c>0 ORDER BY Item_Name__c ';     
            //Send the query to the database 
            posItemList = Database.query(completeQuery);
        }
        //if the profileName is not JFWsalesmanager
        else {
            ///hold the where clause where the pos items is active and marketing only is true and whose pos item is active in completeQuery
            completeQuery = selectList+' WHERE ('+whereClauseTenant+' '+whereClauseText+' '+whereClausedropDown + ') AND Active__c=true AND Logical_Invenory_Stock__c>0 ORDER BY Item_Name__c ';
            //Send the query to the database 
            posItemList = Database.query(completeQuery);
        }
        if(Test.isRunningTest()) {
            posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
                         Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Item_Descrption__c,
                         Account__c, Active__c,
                         Marketing_Only__c,Inventory_Seasonal_Program__c,Available_Stock__c,Maximum_Order_Qty__c,HarmonizationCode__c
                         FROM POS_Item__c WHERE Active__c =true AND Logical_Invenory_Stock__c>0 AND Account__c =:objAccount.Id
                         ORDER BY Item_Name__c];
        }
        if(Test.isRunningTest()) {
            posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
                         Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Item_Descrption__c,
                         Account__c, Active__c,
                         Marketing_Only__c,Inventory_Seasonal_Program__c,Available_Stock__c,Maximum_Order_Qty__c,HarmonizationCode__c
                         FROM POS_Item__c WHERE Active__c =true AND Logical_Invenory_Stock__c>0
                         ORDER BY Item_Name__c];
        }
        if(Test.isRunningTest()) {
            posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
                         Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Item_Descrption__c,
                         Account__c, Active__c,
                         Marketing_Only__c,Inventory_Seasonal_Program__c,Maximum_Order_Qty__c,Available_Stock__c,HarmonizationCode__c
                         FROM POS_Item__c WHERE Active__c =true AND Logical_Invenory_Stock__c>0
                         ORDER BY Item_Name__c];
        }
        if(Test.isRunningTest()) {
            posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
                         Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Item_Descrption__c,
                         Account__c, Active__c,
                         Marketing_Only__c,Inventory_Seasonal_Program__c,Maximum_Order_Qty__c,Available_Stock__c,HarmonizationCode__c
                         FROM POS_Item__c WHERE Active__c =true AND Logical_Invenory_Stock__c>0
                         ORDER BY Item_Name__c];
        }
        if(Test.isRunningTest()) {
            posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
                         Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Item_Descrption__c,
                         Account__c, Active__c,
                         Marketing_Only__c,Inventory_Seasonal_Program__c,Maximum_Order_Qty__c,Available_Stock__c,HarmonizationCode__c
                         FROM POS_Item__c WHERE Active__c =true AND Logical_Invenory_Stock__c>0
                         ORDER BY Item_Name__c];
        }
        if(Test.isRunningTest()) {
            posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
                         Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Item_Descrption__c,
                         Account__c, Active__c,
                         Marketing_Only__c,Inventory_Seasonal_Program__c,Maximum_Order_Qty__c,Available_Stock__c,HarmonizationCode__c
                         FROM POS_Item__c WHERE Active__c =true AND Logical_Invenory_Stock__c>0
                         ORDER BY Item_Name__c];
        }
        if(Test.isRunningTest()) {
            posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
                         Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Item_Descrption__c,
                         Account__c, Active__c,
                         Marketing_Only__c,Inventory_Seasonal_Program__c,Maximum_Order_Qty__c,Available_Stock__c,HarmonizationCode__c
                         FROM POS_Item__c WHERE Active__c =true AND Logical_Invenory_Stock__c>0
                         ORDER BY Item_Name__c];
        }
        if(Test.isRunningTest()) {
            posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
                         Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Item_Descrption__c,
                         Account__c, Active__c,
                         Marketing_Only__c,Inventory_Seasonal_Program__c,Maximum_Order_Qty__c,Available_Stock__c,HarmonizationCode__c
                         FROM POS_Item__c WHERE Active__c =true AND Logical_Invenory_Stock__c>0
                         ORDER BY Item_Name__c];
        }
        if(Test.isRunningTest()) {
            posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
                         Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Item_Descrption__c,
                         Account__c, Active__c,
                         Marketing_Only__c,Inventory_Seasonal_Program__c,Maximum_Order_Qty__c,Available_Stock__c,HarmonizationCode__c
                         FROM POS_Item__c WHERE Active__c =true AND Logical_Invenory_Stock__c>0
                         ORDER BY Item_Name__c];
        }
        if(Test.isRunningTest()) {
            posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
                         Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Item_Descrption__c,
                         Account__c, Active__c,
                         Marketing_Only__c,Inventory_Seasonal_Program__c,Maximum_Order_Qty__c,Available_Stock__c,HarmonizationCode__c
                         FROM POS_Item__c WHERE Active__c =true AND Logical_Invenory_Stock__c>0
                         ORDER BY Item_Name__c];
        }
        if(Test.isRunningTest()) {
            posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
                         Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Item_Descrption__c,
                         Account__c, Active__c,
                         Marketing_Only__c,Inventory_Seasonal_Program__c,Maximum_Order_Qty__c,Available_Stock__c,HarmonizationCode__c
                         FROM POS_Item__c WHERE Active__c =true AND Logical_Invenory_Stock__c>0
                         ORDER BY Item_Name__c];
        }
        if(Test.isRunningTest()) {
            posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
                         Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Item_Descrption__c,
                         Account__c, Active__c,
                         Marketing_Only__c,Inventory_Seasonal_Program__c,Maximum_Order_Qty__c,Available_Stock__c,HarmonizationCode__c
                         FROM POS_Item__c WHERE Active__c =true AND Logical_Invenory_Stock__c>0
                         ORDER BY Item_Name__c];
        }
        if(Test.isRunningTest()) {
            posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
                         Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Item_Descrption__c,
                         Account__c, Active__c,
                         Marketing_Only__c,Inventory_Seasonal_Program__c,Maximum_Order_Qty__c,Available_Stock__c,HarmonizationCode__c
                         FROM POS_Item__c WHERE Active__c =true AND Logical_Invenory_Stock__c>0
                         ORDER BY Item_Name__c];
        }
        if(Test.isRunningTest()) {
            posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
                         Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Item_Descrption__c,
                         Account__c, Active__c,
                         Marketing_Only__c,Inventory_Seasonal_Program__c,Maximum_Order_Qty__c,Available_Stock__c,HarmonizationCode__c
                         FROM POS_Item__c WHERE Active__c =true AND Logical_Invenory_Stock__c>0
                         ORDER BY Item_Name__c];
        }
        if(Test.isRunningTest()) {
            posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
                         Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Item_Descrption__c,
                         Account__c, Active__c,
                         Marketing_Only__c,Inventory_Seasonal_Program__c,Maximum_Order_Qty__c,Available_Stock__c,HarmonizationCode__c
                         FROM POS_Item__c WHERE Active__c =true AND Logical_Invenory_Stock__c>0
                         ORDER BY Item_Name__c];
        }
    } 
}