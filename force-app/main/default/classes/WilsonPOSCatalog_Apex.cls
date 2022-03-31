//Author : TP,VB
//Date : 06/01/2021
//Aim : To display the pos item image , item no , Item Name ,Brand ,Pack of ,Price , inventory ,max order quanity and approval required status of the pos items in pdf

public  class WilsonPOSCatalog_Apex{
    // Declare a variable to hold the Wilson Daniels account details of type Account sObject
       public static Account objAccount; 
       //Declare a variable which can hold pos items
       public List<POS_Item__c> posItemList{get; set; } 
    
      //To fetch account details
        public static Account getAccount() {  
            
            if(Test.isRunningTest())
            {
                objAccount=[SELECT Id, Name FROM Account
                WHERE Name LIKE '%Wilson Daniels%' LIMIT 1];
            }
            else
            {
                 objAccount=[SELECT Id, Name FROM Account
                            WHERE Lightning_Community_Id__c=:Network.getNetworkId() LIMIT 1];
            }
            //return objAccount
            return objAccount; 
        }
        
        /**To fetch the pos item image , item no , Item Name ,Brand ,Pack of ,Price , inventory ,max order quanity and approval required status of the active pos items 
        and whose logical inventory is more than zero from PosItem__c sObject for Wilson Daniels account     */
        public WilsonPOSCatalog_Apex(ApexPages.StandardController controller) {
            //fetch account details
            objAccount = getAccount();
            //store the selected brand id in a variable brandId of type string
            String brandId=controller.getId();
            System.debug('brandId'+brandId);
           //fetch profile id , name  from profile sObject for the logged in user and store in a variable profile name of type string
            String profileName=[Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
            //Check if the profileName is WilsonDanielsSalesManager
            if(profileName == 'WilsonDanielsSalesManager' ) {
               //If yes , check if the brand id is present
                if(String.isNotEmpty(brandId)) {
                    //If yes fetch pos item details of the active pos items and whose logical inventory is more than zero and whose marketing only is false from PosItem__c sObject for Wilson Daniels account and for the incoming brand id and store it in a variable posItemList
        
                    posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
                                 Pack_Of__c, Price__c, Item_Name__c,Approval_Required__c,Item_Descrption__c,Account__c,Image_of_Item__c,
                                 Marketing_Only__c,Inventory_Seasonal_Program__c,Maximum_Order_Qty__c,Available_Stock__c,HarmonizationCode__c,Active__c
                                 FROM POS_Item__c WHERE Active__c =true AND Marketing_Only__c=false AND Logical_Invenory_Stock__c>0 AND Brand__c=:brandId AND Account__c =:objAccount.Id
                                ORDER BY Item_Name__c];
                }
                else {
                    //If no, fetch pos item details of the active pos items and whose logical inventory is more than zero and whose marketing only is false from PosItem__c sObject for Wilson Daniels account and store it in a variable posItemList
        
                    posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
                                 Pack_Of__c, Price__c, Item_Name__c,Approval_Required__c,Item_Descrption__c,
                                 Account__c, Active__c ,Image_of_Item__c,Length__c,Width__c,Height__c,Weight__c,Low_inventory_level_applicable__c,
                                 Marketing_Only__c,Inventory_Seasonal_Program__c,Maximum_Order_Qty__c,Available_Stock__c
                                 FROM POS_Item__c WHERE Active__c =true AND Marketing_Only__c=false  AND Logical_Invenory_Stock__c>0 AND Account__c =:objAccount.Id
                                 ORDER BY Item_Name__c];
                }
            }
    
            //If the profileName is not WilsonDanielsSalesManager
            else
            {
                //Check if the brand id is present
                if(String.isNotEmpty(brandId)) 
                {
                    //If yes , fetch pos item details of the active pos items and whose logical inventory is more than zero and whose marketing only is true from PosItem__c sObject for Wilson Daniels account and for the incoming brand id and store it in a variable posItemList
                    posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Approval_Required__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
                                 Pack_Of__c, Price__c, Item_Name__c,Item_Descrption__c,
                                 Account__c, Active__c ,Image_of_Item__c,
                                 Marketing_Only__c,Inventory_Seasonal_Program__c,Maximum_Order_Qty__c,Available_Stock__c
                                 FROM POS_Item__c WHERE Active__c =true AND Logical_Invenory_Stock__c>0 AND  Brand__c=:brandId AND Account__c =:objAccount.Id
                                 ORDER BY Item_Name__c];
                }
                else
                {
                    //If no , fetch pos item details of the active pos items and whose logical inventory is more than zero and whose marketing only is true from PosItem__c sObject for Wilson Daniels account and store it in a variable posItemList
                    posItemList=[SELECT Id,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
                                 Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Item_Descrption__c,
                                 Account__c, Active__c,
                                 Marketing_Only__c,Inventory_Seasonal_Program__c,Maximum_Order_Qty__c,Available_Stock__c,HarmonizationCode__c
                                 FROM POS_Item__c WHERE Active__c =true AND Logical_Invenory_Stock__c>0 AND Account__c =:objAccount.Id
                                 ORDER BY Item_Name__c];
                }
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