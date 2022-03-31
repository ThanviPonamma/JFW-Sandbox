public class DFVPOSItemListCmpController {
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
    /** Authors: Sanjana,Thanvi Date 14-05-2020 CR NO - DFV-14-May-16 
	The Vendor__c is fetched from the POS item List**/
    
    //The below line is commented  to meet the requirement specified in the CR  DFV-15-Feb-28.
    // @AuraEnabled
    // public static PosItemListWithNames getPOSItemList() {
    //     objAccount=getAccount();
    //     List<POS_Item__c> posItemList = new List<POS_Item__c>();
    //     List<String> posItemNamesForValidation=new List<String> ();
    //     List<String> posItemStockNumbersForValidation=new List<String> ();
    //     for(POS_Item__c posItem :[SELECT Id,Coupon_Attachment_Id__c,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
    //                               Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Expiration_Date__c,ExpirationDateRequired__c,Item_Descrption__c,
    //                               LotNumberRequired__c, Account__c, Active__c ,Image_of_Item__c,Length__c,Width__c,Height__c,Weight__c,Low_inventory_level_applicable__c,
    //                               Low_Inventory_Level__c,Maximum_order_quantity_applicable__c,Maximum_Order_Qty__c,Marketing_Only__c,Inventory_Seasonal_Program__c,Available_Stock__c,
    //                               HarmonizationCode__c,Vendor__c
    //                               FROM POS_Item__c
    //                               WHERE Account__c=:objAccount.Id
    //                               ORDER BY Item_Name__c])
    //     {
    //         // CR Number: DFV-19-Feb-5   Date: 20-02-2020 Author:Thanvi
    //         //Items should auto-hide and be deactivated once their quantity gets to zero (0) 
    //         if(posItem.Logical_Invenory_Stock__c<1) {
    //             posItem.Active__c=false;
    //         }
    //         else {
    //             posItem.Active__c=true;
    //         }
    //         posItemList.add(posItem);
    //         posItemNamesForValidation.add(posItem.Item_Name__c.remove(' ').trim().toUppercase());
    //         posItemStockNumbersForValidation.add(posItem.Item_No__c.remove(' ').trim().toUppercase());
    //     }
    //     return new PosItemListWithNames(posItemList,posItemNamesForValidation,posItemStockNumbersForValidation); 
    // }

//CR Number  - DFV-15-Feb-28
        //Author : TP , VB
        //Date :17-02-2021
        //The below line is code is updated to meet the requirement specified in the CR.
    @AuraEnabled
    public static PosItemListWithNames getPOSItemList(Integer recordStartIndex) {
        objAccount=getAccount();
        List<POS_Item__c> posItemList = new List<POS_Item__c>();
        List<POS_Item__c> posItemPaginationList = new List<POS_Item__c>();
        List<String> posItemNamesForValidation=new List<String> ();
        List<String> posItemStockNumbersForValidation=new List<String> ();
        for(POS_Item__c posItem :[SELECT Id,Coupon_Attachment_Id__c,Item_No__c,Logical_Invenory_Stock__c,Attachment_Id__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id,
                                  Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Expiration_Date__c,ExpirationDateRequired__c,Item_Descrption__c,
                                  LotNumberRequired__c, Account__c, Active__c ,Image_of_Item__c,Length__c,Width__c,Height__c,Weight__c,Low_inventory_level_applicable__c,
                                  Low_Inventory_Level__c,Maximum_order_quantity_applicable__c,Maximum_Order_Qty__c,Marketing_Only__c,Inventory_Seasonal_Program__c,Available_Stock__c,
                                  HarmonizationCode__c,Vendor__c
                                  FROM POS_Item__c
                                  WHERE Account__c=:objAccount.Id
                                  ORDER BY Item_Name__c])
        {
            // CR Number: DFV-19-Feb-5   Date: 20-02-2020 Author:Thanvi
            //Items should auto-hide and be deactivated once their quantity gets to zero (0) 
            if(posItem.Logical_Invenory_Stock__c<1) {
                posItem.Active__c=false;
            }
            else {
                posItem.Active__c=true;
            }
            posItemList.add(posItem);
            posItemNamesForValidation.add(posItem.Item_Name__c.remove(' ').trim().toUppercase());
            posItemStockNumbersForValidation.add(posItem.Item_No__c.remove(' ').trim().toUppercase());
        }

        for(Integer i=recordStartIndex==null?0:recordStartIndex;i<=recordStartIndex+99;i++)
        {
            if(i<posItemList.size())
            posItemPaginationList.add(posItemList[i]);
        }
        System.debug('posItemPaginationList-->'+posItemPaginationList);


        //paginated pos items with total pos items count is sent to the fron end to meet the CR DFV-15-Feb-28.
        return new PosItemListWithNames(posItemPaginationList,posItemNamesForValidation,posItemStockNumbersForValidation,posItemList.size()); 
    }


    //The below line is commented  to meet the requirement specified in the CR  DFV-15-Feb-28.
    ////Date :17-02-2021
    //Author:TP , VB

    // @AuraEnabled
    // public static PosItemListWithNames addPOSItem(POS_Item__c posItem,String imageBlobData,String fileName,String ContentType,
    //                                               String searchKey,String searchbrandId,String searchPosItemTypeId) 
    // {
    //     try{
    //         objAccount=getAccount();
    //         List<Attachment> currentAttachment=[SELECT Id,Body,ContentType,BodyLength,Name FROM Attachment WHERE parentId=:posItem.Id];
    //         if(!posItem.Low_inventory_level_applicable__c)
    //             posItem.Low_Inventory_Level__c=null;
    //         if(!posItem.ExpirationDateRequired__c)
    //             posItem.Expiration_Date__c=null;
    //         if(!posItem.Maximum_order_quantity_applicable__c)
    //             posItem.Maximum_Order_Qty__c=null;
            
    //         posItem.Account__c = objAccount.Id;
    //         // CR Number:  DFV-19-Feb-5   Date: 20-02-2020 Author:Thanvi
    //         //Items should auto-hide and be deactivated once their quantity gets to zero (0) 
    //         //Regardless of low inventory level being set
            
    //         if(posItem.Logical_Invenory_Stock__c<1) {
    //             posItem.Active__c=false;
    //         }
    //         upsert posItem;
            
    //         if(String.isNotBlank(imageBlobData))
    //         {
    //             imageBlobData = EncodingUtil.urlDecode(imageBlobData, 'UTF-8');
                
    //             Attachment attach = new Attachment();
    //             attach.parentId = posItem.Id;
    //             attach.Body = EncodingUtil.base64Decode(imageBlobData);
    //             attach.Name = fileName;
    //             attach.ContentType = contentType;
    //             Insert attach; 
    //             posItem.Attachment_Id__c=attach.Id;
    //             update posItem;
    //         }
            
    //     }
    //     catch(Exception ex){
    //         DFVEmailNotifications.sendNotification('Adding Pos Item',ex.getMessage()+'\n'+'Inputs are -- posItem-- '+JSON.serialize(posItem)+'\n'+'---imageBlobData---'+JSON.serialize(imageBlobData)
    //                                                +'\n'+'---fileName---'+JSON.serialize(fileName)+'\n'+'---ContentType---'+JSON.serialize(ContentType)+'\n'+'---searchKey---'+JSON.serialize(searchKey)
    //                                                +'\n'+'---searchbrandId---'+JSON.serialize(searchbrandId)+'\n'+'---searchPosItemTypeId---'+JSON.serialize(searchPosItemTypeId)
    //                                                +'\n'+'Class Name - DFVPOSItemListCmpController '+'-- Line number --'+ex.getLineNumber());
    //     }  
    //     return searchPOSItem(searchKey,searchbrandId,searchPosItemTypeId);   
    // }

    //CR Number  - DFV-15-Feb-28
        //Author : TP , VB
        //Date :17-02-2021
        //The below line is code is updated to meet the requirement specified in the CR.
    //Added recordStartIndex as a parameter to accept the page number based on which the paginated pos items are sent to the frontend
    @AuraEnabled
    public static PosItemListWithNames addPOSItem(POS_Item__c posItem,String imageBlobData,String fileName,String ContentType,
                                                  String searchKey,String searchbrandId,String searchPosItemTypeId , Integer recordStartIndex) 
    {
        try{
            objAccount=getAccount();
            List<Attachment> currentAttachment=[SELECT Id,Body,ContentType,BodyLength,Name FROM Attachment WHERE parentId=:posItem.Id];
            if(!posItem.Low_inventory_level_applicable__c)
                posItem.Low_Inventory_Level__c=null;
            if(!posItem.ExpirationDateRequired__c)
                posItem.Expiration_Date__c=null;
            if(!posItem.Maximum_order_quantity_applicable__c)
                posItem.Maximum_Order_Qty__c=null;
            
            posItem.Account__c = objAccount.Id;
            // CR Number:  DFV-19-Feb-5   Date: 20-02-2020 Author:Thanvi
            //Items should auto-hide and be deactivated once their quantity gets to zero (0) 
            //Regardless of low inventory level being set
            
            if(posItem.Logical_Invenory_Stock__c<1) {
                posItem.Active__c=false;
            }
            upsert posItem;
            
            if(String.isNotBlank(imageBlobData))
            {
                imageBlobData = EncodingUtil.urlDecode(imageBlobData, 'UTF-8');
                
                Attachment attach = new Attachment();
                attach.parentId = posItem.Id;
                attach.Body = EncodingUtil.base64Decode(imageBlobData);
                attach.Name = fileName;
                attach.ContentType = contentType;
                Insert attach; 
                posItem.Attachment_Id__c=attach.Id;
                update posItem;
            }
            
        }
        catch(Exception ex){
            DFVEmailNotifications.sendNotification('Adding Pos Item',ex.getMessage()+'\n'+'Inputs are -- posItem-- '+JSON.serialize(posItem)+'\n'+'---imageBlobData---'+JSON.serialize(imageBlobData)
                                                   +'\n'+'---fileName---'+JSON.serialize(fileName)+'\n'+'---ContentType---'+JSON.serialize(ContentType)+'\n'+'---searchKey---'+JSON.serialize(searchKey)
                                                   +'\n'+'---searchbrandId---'+JSON.serialize(searchbrandId)+'\n'+'---searchPosItemTypeId---'+JSON.serialize(searchPosItemTypeId)
                                                   +'\n'+'Class Name - DFVPOSItemListCmpController '+'-- Line number --'+ex.getLineNumber());
        } 
        // recordStartIndex is sent as a parameter to searchPOSItem as it accepts the page number based on which the paginated pos items are sent to the frontend 
        return searchPOSItem(searchKey,searchbrandId,searchPosItemTypeId, recordStartIndex);   
    }



    @AuraEnabled
    public static BrandAndItemTypeOptionsWrapper getBrandAndItemTypeOptions(POS_Item__c posItem)
    {
        objAccount=getAccount();
        List<Brand__c> brandOptions=new List<Brand__c> ();
        List<Item_Type__c> itemTypeOptions=new List<Item_Type__c> ();
        brandOptions=[SELECT Id, Brand_Name__c, Account__c, Active__c FROM Brand__c
                      WHERE Account__c=:objAccount.Id AND (Active__c=true OR Id=:posItem.Brand__c) ORDER BY Brand_Name__c];
        itemTypeOptions = [SELECT Name, Item_Type__c, Active__c, Account__c FROM Item_Type__c 
                           WHERE Account__c=:objAccount.Id AND (Active__c=true OR Id=:posItem.Type_of_Item__c) ORDER BY Item_Type__c];
        return new BrandAndItemTypeOptionsWrapper(brandOptions,itemTypeOptions);
    }
    @AuraEnabled 
    public static List<Brand__c> getBrandList() {
        objAccount=getAccount();
        List<Brand__c> brandList = new List<Brand__c>();
        brandList = [SELECT Id, Brand_Name__c, Account__c, Active__c FROM Brand__c
                     WHERE Account__c=:objAccount.Id ORDER BY Brand_Name__c];
        
        return brandList; 
    }
    
    @AuraEnabled
    public static List<Item_Type__c> getItemTypeList() {
        objAccount=getAccount();
        List<Item_Type__c> itemTypeList = new List<Item_Type__c>();
        itemTypeList = [SELECT Name, Item_Type__c, Active__c, Account__c FROM Item_Type__c 
                        WHERE Account__c=:objAccount.Id ORDER BY Item_Type__c];
        return itemTypeList;
    }

    /** Authors: Sanjana,Thanvi Date 14-05-2020 CR NO - DFV-14-May-16 
	The Vendor__c is fetched from the POS item List**/
    /** Authors: Sanjana,Thanvi Date 14-05-2020 CR NO - DFV-14-May-16 
	The Vendor__c is fetched from the POS item List
    //The below line is commented  to meet the requirement specified in the CR  DFV-15-Feb-28.
    @AuraEnabled
    public static PosItemListWithNames searchPOSItem(String searchText,String selBrand, String selItemType) {
        objAccount=getAccount();
        List<POS_Item__c> posItemList = New List<POS_Item__c>();
        List<String> posItemNamesForValidation=new List<String> ();
        List<String> posItemStockNumbersForValidation=new List<String> ();
        String completeQry = '';
        String selectList = '';
        String whereClauseText = '';
        String whereClausedropDown ='';
        String whereClauseTenant ='';
        String accountId = '';
        if( objAccount  != null)
        {
            accountId = objAccount.ID;
            whereClauseTenant = whereClauseTenant+' (Account__c =\''+accountId+'\' ) ';
        }
        if(String.isNotBlank(selBrand))
            whereClausedropDown = whereClausedropDown+' AND (Brand__c= \''+selBrand+'\') ';
        if (String.isNotBlank(selItemType))
            whereClausedropDown = whereClausedropDown+' AND (Type_of_Item__c=\''+selItemType+'\') ';
        String tempSearchText = '%'+searchText+'%';
        selectList = 'SELECT Id,Item_No__c,Coupon_Attachment_Id__c,Attachment_Id__c,Logical_Invenory_Stock__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id, ';
        selectList=selectList+' Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Expiration_Date__c,ExpirationDateRequired__c,Item_Descrption__c, ';
        selectList=selectList+' LotNumberRequired__c, Account__c, Active__c ,Vendor__c,Image_of_Item__c,Length__c,Width__c,Height__c,Weight__c,Low_inventory_level_applicable__c, ';
        selectList=selectList+' Low_Inventory_Level__c,Maximum_order_quantity_applicable__c,Maximum_Order_Qty__c,Marketing_Only__c,Inventory_Seasonal_Program__c,Available_Stock__c,HarmonizationCode__c FROM POS_Item__c ';
        if(String.isNotBlank(searchText))
            whereClauseText = ' AND ((Type_of_Item__r.Item_Type__c LIKE \''+tempSearchText+'\') OR (Item_Name__c LIKE \''+tempSearchText+'\') OR (Item_No__c LIKE \''+tempSearchText+'\') OR (Brand__r.Brand_Name__c LIKE \''+tempSearchText+'\'))';
        completeQry = selectList+' WHERE ('+whereClauseTenant+' '+whereClauseText+' '+whereClausedropDown + ') ORDER BY Item_Name__c ';
        posItemList = Database.query(completeQry);
        for(POS_Item__c posItem : posItemList)
        {
            posItemNamesForValidation.add(posItem.Item_Name__c.remove(' ').trim().toUppercase());
            posItemStockNumbersForValidation.add(posItem.Item_No__c.remove(' ').trim().toUppercase());
        }

        System.debug('addressBookList-->'+addressBookList);
        return new AddressBookListWithSizeWrapper(userTerritoryAddressList,userTerritoryAddress.size());

        return new PosItemListWithNames(posItem,posItemNamesForValidation,posItemStockNumbersForValidation);
    }**/

     //CR Number  - DFV-15-Feb-28
        //Author : TP , VB
        //Date :17-02-2021
        //The below line is code is updated to meet the requirement specified in the CR  DFV-15-Feb-28.
        //Added recordStartIndex as a parameter to accept the page number based on which the paginated pos items are sent to the frontend
    @AuraEnabled
    public static PosItemListWithNames searchPOSItem(String searchText,String selBrand, String selItemType , Integer recordStartIndex) {
        objAccount=getAccount();
        List<POS_Item__c> posItemList = New List<POS_Item__c>();
        List<POS_Item__c> posItemPaginationList = New List<POS_Item__c>();
        List<String> posItemNamesForValidation=new List<String> ();
        List<String> posItemStockNumbersForValidation=new List<String> ();
        String completeQry = '';
        String selectList = '';
        String whereClauseText = '';
        String whereClausedropDown ='';
        String whereClauseTenant ='';
        String accountId = '';
        if( objAccount  != null)
        {
            accountId = objAccount.ID;
            whereClauseTenant = whereClauseTenant+' (Account__c =\''+accountId+'\' ) ';
        }
        if(String.isNotBlank(selBrand))
            whereClausedropDown = whereClausedropDown+' AND (Brand__c= \''+selBrand+'\') ';
        if (String.isNotBlank(selItemType))
            whereClausedropDown = whereClausedropDown+' AND (Type_of_Item__c=\''+selItemType+'\') ';
        String tempSearchText = '%'+searchText+'%';
        selectList = 'SELECT Id,Item_No__c,Coupon_Attachment_Id__c,Attachment_Id__c,Logical_Invenory_Stock__c,Brand__r.Brand_Name__c,Brand__r.Id, Type_of_Item__r.Item_Type__c, Type_of_Item__r.Id, ';
        selectList=selectList+' Pack_Of__c, Price__c, Item_Name__c, Dimension__c,Approval_Required__c, Expiration_Date__c,ExpirationDateRequired__c,Item_Descrption__c, ';
        selectList=selectList+' LotNumberRequired__c, Account__c, Active__c ,Vendor__c,Image_of_Item__c,Length__c,Width__c,Height__c,Weight__c,Low_inventory_level_applicable__c, ';
        selectList=selectList+' Low_Inventory_Level__c,Maximum_order_quantity_applicable__c,Maximum_Order_Qty__c,Marketing_Only__c,Inventory_Seasonal_Program__c,Available_Stock__c,HarmonizationCode__c FROM POS_Item__c ';
        if(String.isNotBlank(searchText))
            whereClauseText = ' AND ((Type_of_Item__r.Item_Type__c LIKE \''+tempSearchText+'\') OR (Item_Name__c LIKE \''+tempSearchText+'\') OR (Item_No__c LIKE \''+tempSearchText+'\') OR (Brand__r.Brand_Name__c LIKE \''+tempSearchText+'\'))';
        completeQry = selectList+' WHERE ('+whereClauseTenant+' '+whereClauseText+' '+whereClausedropDown + ') ORDER BY Item_Name__c ';
        posItemList = Database.query(completeQry);
        for(POS_Item__c posItem : posItemList)
        {
            posItemNamesForValidation.add(posItem.Item_Name__c.remove(' ').trim().toUppercase());
            posItemStockNumbersForValidation.add(posItem.Item_No__c.remove(' ').trim().toUppercase());
        }

        for(Integer i=recordStartIndex==null?0:recordStartIndex;i<=recordStartIndex+99;i++)
        {
            if(i<posItemList.size())
            posItemPaginationList.add(posItemList[i]);
        }
        System.debug('posItemPaginationList-->'+posItemPaginationList);

     //paginated pos items with total pos items count is sent to the fron end to meet the CR DFV-15-Feb-28.
        return new PosItemListWithNames(posItemPaginationList,posItemNamesForValidation,posItemStockNumbersForValidation,posItemList.size());
    }
        //CR Number  - DFV-15-Feb-28
        //Author : TP , VB
        //Date :17-02-2021
    //The below line is commented  to meet the requirement specified in the CR  DFV-15-Feb-28.

    // @AuraEnabled
    // public static PosItemListWithNames deactivateSelectedItem(POS_Item__c posItem,String searchText,String selBrand, String selItemType)
    // { 
    //     try{
    //         posItem.Active__c=false;
    //         update posItem;
    //     }
    //     catch(Exception ex){
    //         DFVEmailNotifications.sendNotification('Adding Pos Item',ex.getMessage()+'\n'+'Inputs are -- posItem-- '+JSON.serialize(posItem)+'\n'+'---searchText---'+JSON.serialize(searchText)
    //                                                +'\n'+'---selBrand---'+JSON.serialize(selBrand)+'\n'+'---selItemType---'+JSON.serialize(selItemType)
    //                                                +'\n'+'Class Name - DFVPOSItemListCmpController '+'-- Line number --'+ex.getLineNumber());
    //     }  
        
    //     return searchPOSItem(searchText,selBrand,selItemType);
    // }

    //CR Number  - DFV-15-Feb-28
        //Author : TP , VB
        //The below line is code is updated to meet the requirement specified in the CR  DFV-15-Feb-28.
        //Added recordStartIndex as a parameter to accept the page number based on which the paginated pos items are sent to the frontend
    @AuraEnabled
    public static PosItemListWithNames deactivateSelectedItem(POS_Item__c posItem,String searchText,String selBrand, String selItemType ,Integer recordStartIndex )
    { 
        try{
            posItem.Active__c=false;
            update posItem;
        }
        catch(Exception ex){
            DFVEmailNotifications.sendNotification('Adding Pos Item',ex.getMessage()+'\n'+'Inputs are -- posItem-- '+JSON.serialize(posItem)+'\n'+'---searchText---'+JSON.serialize(searchText)
                                                   +'\n'+'---selBrand---'+JSON.serialize(selBrand)+'\n'+'---selItemType---'+JSON.serialize(selItemType)
                                                   +'\n'+'Class Name - DFVPOSItemListCmpController '+'-- Line number --'+ex.getLineNumber());
        }  
        
         // recordStartIndex is sent as a parameter to searchPOSItem as it accepts the page number based on which the paginated pos items are sent to the frontend 
        return searchPOSItem(searchText,selBrand,selItemType,recordStartIndex);
    }

     

    public class PosItemListWithNames
    {
        @AuraEnabled
        public List<POS_Item__c> posItemList ;
        @AuraEnabled
        public List<String> posItemNamesForValidation ;
        @AuraEnabled
        public List<String> posItemStockNumbersForValidation;
        //CR Number  - DFV-15-Feb-28
        //Author : TP , VB
        //Date :17-02-2021
        //The below line is added to meet the requirement specified in the CR.
        @AuraEnabled
        public Integer totalPosItemSize;
        public PosItemListWithNames (List<POS_Item__c> posItemList,List<String> posItemNamesForValidation,List<String> posItemStockNumbersForValidation, Integer totalPosItemSize)
        {
            this.posItemList=posItemList;
            this.posItemNamesForValidation=posItemNamesForValidation;
            this.posItemStockNumbersForValidation=posItemStockNumbersForValidation;
            this.totalPosItemSize = totalPosItemSize;
        }
    } 
    public class BrandAndItemTypeOptionsWrapper
    {
        @AuraEnabled
        public List<Brand__c> brandOptions;
        @AuraEnabled
        public List<Item_Type__c> itemTypeOptions;
        public BrandAndItemTypeOptionsWrapper(List<Brand__c> brandOptions,List<Item_Type__c> itemTypeOptions)
        {
            this.brandOptions=brandOptions;
            this.itemTypeOptions=itemTypeOptions;           
        }
    }
}