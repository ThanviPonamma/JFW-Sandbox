/* Author: VB,NK,TP
Date: 07-03-22*/

public with sharing class CopperCaneTracking_Apex {
    public static Account objAccount;
    
    //To fetch data about Copper Cane from Standard object Account. 
    @AuraEnabled(cacheable=true)
    public static Account getAccount_Apex() {      
        if(Test.isRunningTest())
        {
            objAccount=[SELECT Id, Name FROM Account
                        WHERE Name LIKE '%Copper Cane%' LIMIT 1];
        }
        else
        {
            objAccount=[SELECT Id, Name FROM Account
                        WHERE Lightning_Community_Id__c=:Network.getNetworkId() LIMIT 1];
        }
        return objAccount; // objAccount object contains data about Copper Cane.
    }
    
    
    //To get all the programs
    
    @AuraEnabled(cacheable=true)
    public  static List<Program__c> getProgramList_Apex()
    {
        objAccount=getAccount_Apex();
        List<Program__c> programList = new List<Program__c>();
        programList = [SELECT Id,Name__c FROM Program__c WHERE Account__c=:objAccount.Id
                       ORDER BY Name__c];
        return programList;
    }
    
    // To get the List of Brands From Custom object Brand__C
    @AuraEnabled(cacheable=true)
    public static List<Brand__c> getBrandList() {
        //Fetch account details for Copper Cane
        objAccount=getAccount_Apex();
        //Declare a variable brandList to hold the list of brands of type sObject Brand__c
        List<Brand__c> brandList = new List<Brand__c>();
        
        //Fetch brand id , brand name , account , active status from sObject Brand__c where the account is Copper Cane 
        brandList = [SELECT Id, Brand_Name__c, Account__c, Active__c FROM Brand__c
                     WHERE Account__c=:objAccount.Id ORDER BY Brand_Name__c];
        
        return brandList;
    }
    
    //To fetch all the program pos items for a selected program and selected brand
    @AuraEnabled(cacheable=true)
    public  static List<Program_Item__c> getProgramPOSList_Apex(String selectedProgramId, String selectedBrandId)
    {
        List<Program_Item__c> programPosItemList = new List<Program_Item__c>();
        programPosItemList = [SELECT  POS_Item__r.Item_No__c, POS_Item__r.Item_Name__c FROM Program_Item__c 
                              WHERE Program__c=:selectedProgramId AND POS_Item__r.Brand__c=:selectedBrandId
                              ORDER BY POS_Item__r.Item_Name__c];
        return programPosItemList;
    }
    
    //Wrapper class
    public class CometOrderDetails_ProgramItem
    {
        @AuraEnabled
        public List<OrderDestinationItem__c> cometOderedItems;
        @AuraEnabled
        public Program_Item__c programItemDetail;
        
        public CometOrderDetails_ProgramItem(List<OrderDestinationItem__c> cometOderedItems,Program_Item__c programItemDetail)
        {
            this.cometOderedItems=cometOderedItems;
            this.programItemDetail=programItemDetail;
        }        
    }
    
    //  Author: VB
    //Aim : To get all the Pos items for the selected program
    @AuraEnabled
    public static List<CometOrderDetails_ProgramItem> getTrackingNumbersOfOrders_Apex(String accountId,String selectedProgramId,String selectedPOSItemNo){
        List<CometOrderDetails_ProgramItem> cometOrderDetailsWithProgramItemDetail=new List<CometOrderDetails_ProgramItem> ();
        List<OrderDestinationItem__c> orderDestinationItems  = new List<OrderDestinationItem__c>();
        Program_Item__c programItemDetail = new Program_Item__c();
        System.debug('accountId--->'+accountId);
        System.debug('selectedProgramId--->'+selectedProgramId);
        System.debug('selectedPOSItemNo--->'+selectedPOSItemNo);
        try{
            programItemDetail = [SELECT  POS_Item__r.Item_No__c,Tracking_File_Uploaded__c, Tracking_Synced__c 
                                 FROM Program_Item__c WHERE POS_Item__r.Item_No__c=:selectedPOSItemNo AND Program__c=:selectedProgramId];
            System.debug('programItemDetail--->'+programItemDetail);
            orderDestinationItems = [SELECT Quantity__c,Total_Line_Amount__c,Tracking_Numbers__c,Carrier__c,OrderDestination__r.OrdStatus__c,OrderDestination__r.Comet_Order_Status__c,
                                     OrderDestination__r.OrderName__c,OrderDestination__r.Order_owner__c,OrderDestination__r.AddressBook__r.Shipto_Name__c,
                                     OrderDestination__r.AddressBook__r.Shipto_Company__c,
                                     OrderDestination__r.AddressBook__r.City__c,OrderDestination__r.AddressBook__r.Zip__c,OrderDestination__r.AddressBook__r.Address__c,
                                     OrderDestination__r.AddressBook__r.State__r.State_Name__c,CreatedDate,
                                     POS_Item__r.Item_No__c, POS_Item__r.Item_Name__c, POS_Item__r.Price__c, POS_Item__r.Pack_Of__c,POS_Item__r.Brand__r.Brand_Name__c, 
                                     POS_Item__r.Type_of_Item__r.Item_Type__c,POS_Item__r.Account__c,OrderDestination__r.CreatedDate,OrderDestination__r.TrackingNos__c
                                     FROM OrderDestinationItem__c 
                                     WHERE POS_Item__r.Account__c=:accountId AND OrderDestination__r.Order__r.Program__r.Id=:selectedProgramId 
                                     AND POS_Item__r.Item_No__c=:selectedPOSItemNo
                                     AND OrderDestination__r.Comet_Order_Status__c!='Open' AND Quantity__c>0];
            System.debug('orderDestinationItems--->'+orderDestinationItems);
        }
        catch(Exception ex)
        {
            orderDestinationItems = new List<OrderDestinationItem__c>();
            CopperEmailNotifications.sendNotification('Get Tracking Number',ex.getMessage()+'\n'+'Inputs are -->'+'\n'+'accountId -- '+JSON.serialize(accountId)+'\n'+'selectedProgramId -- '+JSON.serialize(selectedProgramId)
                                                      +'\n'+'Class Name - CopperCaneTracking_Apex '+'-- Line number --'+ex.getLineNumber());
        }
        cometOrderDetailsWithProgramItemDetail.add(new CometOrderDetails_ProgramItem(orderDestinationItems,programItemDetail)); 
        return cometOrderDetailsWithProgramItemDetail;   
    }
    
    //Aim:To synchronize tracking numbers in the custom object Copper_Cane_Tracking__c  with the order destination items.
    //Author : VB, NK, TP
    //Date:24-02-2022
    @AuraEnabled
    public static List<CometOrderDetails_ProgramItem> synchronizeCopperTracking_Apex(String accountId,String selectedProgramId,String selectedPOSItemNo){
        
        //Nachappa collection
        List<Copper_Cane_Tracking__c> copperCaneTrackingNumbers = new List<Copper_Cane_Tracking__c>();
        
        copperCaneTrackingNumbers  = [SELECT Id,Order_Number__c,Ordered_By__c,Ordered_Quantity__c,Item_Name__c,Carrier__c,
                                      Item_Number__c,Shipto_Name__c,Ship_to_Company__c,Ship_to_City__c,Zip__c,Price__c,Tracking_Number__c,Phone__c,Address__c 
                                      FROM Copper_Cane_Tracking__c WHERE Account__c=:accountId AND Program_ID__c =:selectedProgramId AND Item_Number__c=:selectedPOSItemNo];
        
        System.debug('copperCaneTrackingNumbers---->'+copperCaneTrackingNumbers);
        
        //Collection to hold updated order destination items with tracking numbers
        List<OrderDestinationItem__c> orderDestinationItemsWithTracking = new List<OrderDestinationItem__c>();
        //Collection to hold updated Copper cane orders with tracking numbers
        List<Copper_Cane_Tracking__c> copperCaneTrackingNumberList = new List<Copper_Cane_Tracking__c>();
        
        List<OrderDestinationItem__c> orderDestinationItems = [SELECT Tracking_Numbers__c,Carrier__c, OrderDestination__r.OrderName__c,POS_Item__r.Item_No__c
                                                               FROM OrderDestinationItem__c 
                                                               WHERE POS_Item__r.Account__c=:accountId AND OrderDestination__r.Order__r.Program__r.Id=:selectedProgramId AND POS_Item__r.Item_No__c=:selectedPOSItemNo
                                                               AND OrderDestination__r.Comet_Order_Status__c!='Open'];
        
        //Compare both the collections and synchronize tracking numbers in order destination item table and to check synchronized checkbox.
        for (Copper_Cane_Tracking__c copperCaneTrackingNumber : copperCaneTrackingNumbers){
            for(OrderDestinationItem__c orderDestinationItem :orderDestinationItems){
                
                if((orderDestinationItem.OrderDestination__r.OrderName__c == copperCaneTrackingNumber.Order_Number__c)&&(orderDestinationItem.POS_Item__r.Item_No__c == copperCaneTrackingNumber.Item_Number__c))
                {
                    //update tracking numbers in order destination item table.
                    orderDestinationItem.Tracking_Numbers__c = copperCaneTrackingNumber.Tracking_Number__c;
                    orderDestinationItem.Carrier__c = copperCaneTrackingNumber.Carrier__c;
                    //checkbox synchronized to be checked
                    copperCaneTrackingNumber.Synchronized__c=true;
                    copperCaneTrackingNumberList.Add(copperCaneTrackingNumber);
                    orderDestinationItemsWithTracking.Add(orderDestinationItem);
                }    
            }
        }
        
        if(!copperCaneTrackingNumberList.isEmpty() && !orderDestinationItemsWithTracking.isEmpty()) {
            //dml Update operation to update copper can tracking 
            update copperCaneTrackingNumberList;
            //dml Update operation to update order destination items 
            update orderDestinationItemsWithTracking;
            
            Program_Item__c programPosItem = [SELECT  POS_Item__r.Item_No__c, Tracking_Synced__c FROM Program_Item__c WHERE POS_Item__r.Item_No__c=:selectedPOSItemNo AND Program__c=:selectedProgramId];
            programPosItem.Tracking_Synced__c=true;
            
            upsert programPosItem;
        }
        return getTrackingNumbersOfOrders_Apex(accountId,selectedProgramId,selectedPOSItemNo);   
    }
    
    //Aim:To upsert copper cane tracking numbers 
    @AuraEnabled
    public static string UploadCopperTracking_Apex(String accountId,Id contentDocumentId,String selectedProgramId,String selectedPOSItemNo) { 
        List<Copper_Cane_Tracking__c> insertCopperTrackingNumbers = new List<Copper_Cane_Tracking__c>();
        ContentVersion contentVersionObj = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =:contentDocumentId];
        
        list<String> csvRecordsList = contentVersionObj.VersionData.toString().split('\n');
        
        System.debug(csvRecordsList);
        System.debug(csvRecordsList.size());
        
        for(Integer i = 1; i < csvRecordsList.size(); i++){
            Copper_Cane_Tracking__c trackingObject = new Copper_Cane_Tracking__c();
            list<String> csvRowData = csvRecordsList[i].split(',');
            System.debug('csvRowData====> '+csvRowData);
            System.debug('selectedProgramId====> '+selectedProgramId);
            System.debug('accountId====> '+accountId);
            
            trackingObject.Account__c = accountId; 
            trackingObject.Order_Number__c = csvRowData[0];
            trackingObject.Ordered_By__c = csvRowData[1]; 
            trackingObject.Item_Number__c= csvRowData[2];
            trackingObject.Item_Name__c = csvRowData[3]; 
            trackingObject.Ordered_Quantity__c = Decimal.ValueOf(csvRowData[4]);
            trackingObject.Price__c= Decimal.ValueOf(csvRowData[5]);
            trackingObject.Shipto_Name__c = csvRowData[6]; 
            trackingObject.Ship_to_Company__c = csvRowData[7];
            trackingObject.Address__c = csvRowData[8];
            trackingObject.Ship_to_City__c= csvRowData[9];
            trackingObject.State_Code__c = csvRowData[10]; 
            trackingObject.Zip__c = csvRowData[11];	
            trackingObject.Phone__c= csvRowData[12];
            trackingObject.Carrier__c = csvRowData[13]; 
            trackingObject.Tracking_Number__c= csvRowData[14];
            trackingObject.Program_ID__c= selectedProgramId;
            insertCopperTrackingNumbers.add(trackingObject);
        }
        
        try{ 
            System.debug('insertCopperTrackingNumbers====> '+insertCopperTrackingNumbers);
            if(!insertCopperTrackingNumbers.isEmpty()) {
                upsert insertCopperTrackingNumbers;
                System.debug('entered');
                Program_Item__c programPosItem = [SELECT  POS_Item__r.Item_No__c, Tracking_File_Uploaded__c 
                                                  FROM Program_Item__c WHERE POS_Item__r.Item_No__c=:selectedPOSItemNo 
                                                  AND Program__c=:selectedProgramId];

                programPosItem.Tracking_File_Uploaded__c =true;
                upsert programPosItem;
            }
        }
        catch (Exception ex) {
            CopperEmailNotifications.sendNotification('Get Tracking Number',ex.getMessage()+'\n'+'Inputs are -->'+'\n'+'contentDocumentId -- '+JSON.serialize(contentDocumentId)+'\n'+'accountId -- '+JSON.serialize(accountId)+'\n'+'selectedProgramId -- '+JSON.serialize(selectedProgramId)+'selectedPOSItemNo -- '+JSON.serialize(selectedPOSItemNo)
                                                      +'\n'+'Class Name - CopperCaneTracking_Apex '+'-- Line number --'+ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        } 
        
        return 'done';        
    }
    
}