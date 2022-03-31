public with sharing class CometJobs
{
    
    public Account objAccount { get; set;}
    public List<Account> objAccountList {get;set;}
    
    public Decimal availableQty{get; set;}
    public string itemNo{get; set;}
    
    public string cometUser{get; set;}
    public string cometPasword{get; set;}
    public string cometJobNo{get; set;}
    public string customer{get; set;}
    public Boolean hasCometdets {get;set;}
    
    
    public static string OPEN ='Open';
    public static string PENDAPPSHIPMETH ='Awaiting approval - shipment method';
    public static string INPROCESS ='In Process';
    public static string PENDAPPROVAL ='PendApproval';
    public static string CONFIRMED ='Confirmed';
    public static string SUBMITTED ='Submitted';
    
    public static string PENDAPPREQAPP ='Awaiting approval - Item Required Approval';
    public static string PENDAPPMAXORDQTY ='Awaiting approval - max order quantity';
    public static string PENDAPPMAXORDQTYORAPPREQ ='Awaiting approval - max order quantity or Item Approval';
    public decimal budRuleNo{ get; set;}
    
    
    public static List<Order__c> currOrderList {get;set;}
    public static List<OrderDestination__c> currOrderDestList {get;set;}
    
    Order__c O;
    public Order__c getO() {
        if (O == null) O = new Order__c();
        return O;
    }
    public CometJobs ()
    {
        objAccountList  = [SELECT ID, Name, CometJobNo__c, CometUsername__c, CometPassword__c, hasCometConfiguration__c FROM Account WHERE hasCometConfiguration__c = true ];
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////
    // GetLatestStock from Coment
    /////////////////////////////////////////////////////////////////////////////////////////
    
    @future(callout=true)
    public static void GetLatestStockAndNotifyMissingStock()
    {
        System.debug('enetered GetLatestStockAndNotifyMissingStock');
        complemarCom.CometERPWSSoap stub = new complemarCom.CometERPWSSoap();
        stub.timeout_x = 90000;
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> sendTo = new List<String>();
        List<String> ccTo = new List<String>();
        String body='';
        
        List<POS_Item__c> invToUpdate  = new List<POS_Item__c>();
        POS_Item__c currItem = new POS_Item__c();
        List<Account> objAccountList  = [SELECT ID, Name, CometJobNo__c, CometUsername__c, CometPassword__c, hasCometConfiguration__c FROM Account WHERE hasCometConfiguration__c = true];
        System.debug('objAccountList'+objAccountList);
        Boolean stockUpdated= false;
        String newStockNo='';
        String missingStockNoAtComet='';
        for (Account objAccount: objAccountList)
        {
            newStockNo='';
            missingStockNoAtComet='';
            system.debug('Processing Stock for :'+objAccount.Name);
            List<POS_Item__c> invList ;
            if(objAccount.hasCometConfiguration__c == true)
            {
                complemarCom.ArrayOfProductInventoryStatus oS= new complemarCom.ArrayOfProductInventoryStatus();
                if(!test.isRunningTest())
                    oS = stub.AvailableBalances(objAccount.CometUsername__c, objAccount.CometPassword__c, '') ;
                //Authors: AK,NK,SN,TP Date:12-05-2020 CR :DFV-12-May-14 
                //Reason: apex time out limit and the stock needs to be fetched if the item belongs to invetory or both
                //invList =  [Select  Id,  Available_Stock__c,  Item_No__c From POS_Item__c  WHERE Discontinued__c = false AND Account__C =:objAccount.ID ];
                
                invList =[Select Id, Available_Stock__c, Item_No__c From POS_Item__c WHERE Discontinued__c = false AND Account__C =:objAccount.ID AND (Inventory_Seasonal_Program__c='Inventory' OR Inventory_Seasonal_Program__c='Both')];
                
                if(invList != null)
                {
                    try{
                        for (complemarCom.ProductInventoryStatus osL : oS.ProductInventoryStatus)
                        {
                            //absList.add(osL.Available + ':' + oSL.JobNumber + ':' + osL.StockNumber + ':' +osL.SystemMnemonic);
                            stockUpdated= false;
                            for (Integer a = 0; a< invList.size(); a++)
                            {
                                if (invList[a].Item_No__c == osL.StockNumber)
                                {
                                    invList[a].Available_Stock__c = osL.Available;
                                    stockUpdated= true;
                                }
                            }
                            if( stockUpdated == false)
                                newStockNo =newStockNo+'Item No <b>'+osL.StockNumber+'</b> with quantity :'+osL.Available+' for Cutomer <b>'+objAccount.Name +'</b> is available at Comet <br/>\n';
                        }
                    }
                    catch (Exception e) {
                        System.debug('Error in updating Stock '+e);
                    }
                    
                    
                    Boolean itemExists= false;
                    for (Integer a = 0; a< invList.size(); a++)
                    {
                        itemExists= false;
                        if(oS != null)
                        {
                            if( oS.ProductInventoryStatus != null)
                            {
                                for (complemarCom.ProductInventoryStatus osL : oS.ProductInventoryStatus)
                                {
                                    if (invList[a].Item_No__c == osL.StockNumber)
                                        itemExists= true;
                                }
                                if(itemExists== false)
                                {
                                    invList[a].Available_Stock__c = -1; // Item is not Available at Comet
                                    missingStockNoAtComet =missingStockNoAtComet+'Item No <b>'+invList[a].Item_No__c+'</b> for Cutomer <b>'+objAccount.Name +'</b> does not exists at Comet <br/>\n';
                                }
                            }
                        }
                    }
                    
                    if(invList != null)
                        invToUpdate.addAll(invList);
                    system.debug('Size of invToUpdate after added items of  :'+objAccount.Name +'is ' + invToUpdate.size());
                    
                }
            }
            
            // Create two mail for each Account and add them to Mails
            mail = new Messaging.SingleEmailMessage();
            sendTo = new List<String>();
            //Authors : AK,SM,SN,TP  Date: 13-05-2020 
            //CR NO : DFV-13-May-14
            //The below line is commented and the email is changed to nachappa@uxltechnologies.net
            //sendTo.add('uday@uxlconsulting.com');
            
            sendTo.add('nachappa@uxltechnologies.net');
            
            mail.setToAddresses(sendTo);
            
            //Authors : AK,SM,SN,TP  Date: 13-05-2020 
            //CR NO : DFV-13-May-14
            //The below line is commented and the email is changed to nachappa@uxltechnologies.net
            //mail.setReplyTo('uday@uxlconsulting.com');
            mail.setReplyTo('nachappa@uxltechnologies.net');
            
            //Authors : AK,SM,SN,TP  Date: 13-05-2020 
            //CR NO : DFV-13-May-14
            //The below line is commented and the DisplayName is changed to Nachappa
            //mail.setSenderDisplayName('Uday');
            
            mail.setSenderDisplayName('Nachappa');
            
            ccTo = new List<String>();
            //Authors : AK,SM,SN,TP  Date: 13-05-2020 
            //CR NO : DFV-13-May-14
            //The below line is commented and the email is changed to notifications@uxltechnologies.net
            //ccTo.add('karanbir@uxlconsulting.com');
            
            ccTo.add('notifications@uxltechnologies.net');
            
            mail.setCcAddresses(ccTo);
            
            mail.setSubject(objAccount.Name+': Notification to Add Items in Emerge');
            body = 'Hello, <br/>';
            body += 'Please find items that exists in Comet System but not in Emerge system.<br/><br/>';
            body += newStockNo;
            
            body += '<br/> Thanks <br/>Emerge Admin';
            mail.setHtmlBody(body);
            mails.add(mail);
            
            
            mail = new Messaging.SingleEmailMessage();
            sendTo = new List<String>();
            //Authors : AK,SM,SN,TP  Date: 13-05-2020 
            //CR NO : DFV-13-May-14
            //The below line is commented and the email is changed to nachappa@uxltechnologies.net
            //sendTo.add('uday@uxlconsulting.com');
            
            sendTo.add('nachappa@uxltechnologies.net');
            mail.setToAddresses(sendTo);
            //Authors : AK,SM,SN,TP  Date: 13-05-2020 
            //CR NO : DFV-13-May-14
            //The below line is commented and the email is changed to nachappa@uxltechnologies.net
            //mail.setReplyTo('uday@uxlconsulting.com');
            
            mail.setReplyTo('nachappa@uxltechnologies.net');
            
            //Authors : AK,SM,SN,TP  Date: 13-05-2020 
            //CR NO : DFV-13-May-14
            //The below line is commented and the DisplayName is changed to Nachappa
            // mail.setSenderDisplayName('Uday');
            mail.setSenderDisplayName('Nachappa');
            
            ccTo = new List<String>();
            //Authors : AK,SM,SN,TP  Date: 13-05-2020 
            //CR NO : DFV-13-May-14
            //The below line is commented and the email is changed to notifications@uxltechnologies.net
            //ccTo.add('karanbir@uxlconsulting.com');
            
            ccTo.add('notifications@uxltechnologies.net');
            mail.setCcAddresses(ccTo);
            
            mail.setSubject(objAccount.Name+': Items missing at Comet');
            body = 'Hello, <br/>';
            body += '<br/><br/>Please find items that exists in Emerge but not in Comet.<br/><br/>';
            body += missingStockNoAtComet;          
            body += '<br/> Thanks <br/>Emerge Admin'; 
            mail.setHtmlBody(body);
            mails.add(mail);
            
        }
        if (invToUpdate != null)
            update invToUpdate;
        // Send Mail with List of Items that are not in Emerge System
        
        Messaging.sendEmail(mails);
    }
    
    @future(callout=true)
    public static void GetLatestStock()
    {
        complemarCom.CometERPWSSoap stub = new complemarCom.CometERPWSSoap();
        stub.timeout_x = 120000;
        List<POS_Item__c> invToUpdate  = new List<POS_Item__c>();
        POS_Item__c currItem = new POS_Item__c();
        List<Account> objAccountList  = [SELECT ID, Name, CometJobNo__c, CometUsername__c, CometPassword__c, hasCometConfiguration__c FROM Account WHERE hasCometConfiguration__c = true AND ((Name = 'DFV' )OR  (Name = 'JFW' ) OR  (Name = 'Wilson Daniels' ))];
        for (Account objAccount: objAccountList)
        {    
            system.debug('Processing Stock for :'+objAccount.Name);
            List<POS_Item__c> invList ;
            if(objAccount.hasCometConfiguration__c == true)
            {
                complemarCom.ArrayOfProductInventoryStatus oS= new complemarCom.ArrayOfProductInventoryStatus();
                if(!test.isRunningTest())
                    oS = stub.AvailableBalances(objAccount.CometUsername__c, objAccount.CometPassword__c, '') ;
                //Authors: AK,NK,SN,TP Date:12-05-2020 CR :DFV-12-May-14 
                //Reason: apex time out limit and the stock needs to be fetched if the item belongs to invetory or both
                //invList =  [Select  Id,  Available_Stock__c,  Item_No__c From POS_Item__c  WHERE Discontinued__c = false AND Account__C =:objAccount.ID ];
                
                invList =[Select Id, Available_Stock__c, Item_No__c From POS_Item__c WHERE Discontinued__c = false AND Account__C =:objAccount.ID AND (Inventory_Seasonal_Program__c='Inventory' OR Inventory_Seasonal_Program__c='Both')];
                
                //Authors: AK,NK,SN,SM,TP Date:12-05-2020 CR :DFV-12-May-14
                /** The below is commented **/
                //invList =[Select Id, Available_Stock__c, Item_No__c From POS_Item__c WHERE Discontinued__c = false AND Account__C =:objAccount.ID AND Inventory_Seasonal_Program__c='Both' ];
                //Authors: AK,NK,SN,SM,TP Date:12-05-2020 CR :DFV-12-May-14
                /** The below is commented **/
                //invList =[Select Id, Available_Stock__c, Item_No__c From POS_Item__c WHERE Discontinued__c = false AND Account__C =:objAccount.ID AND Inventory_Seasonal_Program__c='Inventory' ];
                System.debug('invList---->'+invList.size());
                if(invList != null)
                {
                    try{
                        for (complemarCom.ProductInventoryStatus osL : oS.ProductInventoryStatus)
                        {
                            for (Integer a = 0; a< invList.size(); a++)
                            {
                                if (invList[a].Item_No__c == osL.StockNumber)
                                    invList[a].Available_Stock__c = osL.Available;
                            }
                        }
                    }
                    catch (Exception e) {
                        System.debug('Error in updating Stock '+e);
                    }
                    Boolean itemExists= false;
                    for (Integer a = 0; a< invList.size(); a++)
                    {
                        itemExists= false;
                        if(oS != null)
                        {
                            if( oS.ProductInventoryStatus != null)
                            {
                                for (complemarCom.ProductInventoryStatus osL : oS.ProductInventoryStatus)
                                {
                                    if (invList[a].Item_No__c == osL.StockNumber)
                                        itemExists= true;
                                }
                                if(itemExists== false)
                                {
                                    invList[a].Available_Stock__c = -1; // Item is not Available at Comet
                                }
                            }
                        }
                    }
                    
                    if(invList != null)
                        invToUpdate.addAll(invList);
                    system.debug('Size of invToUpdate after added items of  :'+objAccount.Name +'is ' + invToUpdate.size());
                }
            }
        }
        if (invToUpdate != null)
            update invToUpdate;
    }
    
    // 
    
    @future(callout=true)
    public static void GetLatestStockWithInProcessInv(String AcctName)
    {
        complemarCom.CometERPWSSoap stub = new complemarCom.CometERPWSSoap();
        stub.timeout_x = 90000;
        List<POS_Item__c> invToUpdate  = new List<POS_Item__c>();
        POS_Item__c currItem = new POS_Item__c();
        List<Account> objAccountList  = [SELECT ID, Name, CometJobNo__c, CometUsername__c, CometPassword__c, hasCometConfiguration__c FROM Account WHERE hasCometConfiguration__c = true AND (Name =: AcctName) ];
        for (Account objAccount: objAccountList)
        {
            system.debug('Processing Stock for :'+objAccount.Name);
            List<POS_Item__c> invList ;
            if(objAccount.hasCometConfiguration__c == true)
            {
                complemarCom.ArrayOfProductInventoryStatus oS= new complemarCom.ArrayOfProductInventoryStatus();
                if(!test.isRunningTest())
                    oS = stub.AvailableBalances(objAccount.CometUsername__c, objAccount.CometPassword__c, '') ;
                //Authors: AK,NK,SN,TP Date:12-05-2020 CR :DFV-12-May-14 
                //Reason: apex time out limit and the stock needs to be fetched if the item belongs to invetory or both
                //invList =  [Select  Id,  Available_Stock__c,  Item_No__c From POS_Item__c  WHERE Discontinued__c = false AND Account__C =:objAccount.ID ];
                
                invList =[Select Id, Available_Stock__c, Item_No__c From POS_Item__c WHERE Discontinued__c = false AND Account__C =:objAccount.ID AND (Inventory_Seasonal_Program__c='Inventory' OR Inventory_Seasonal_Program__c='Both')];
                
                if(invList != null)
                {
                    try{
                        for (complemarCom.ProductInventoryStatus osL : oS.ProductInventoryStatus)
                        {
                            for (Integer a = 0; a< invList.size(); a++)
                            {
                                if (invList[a].Item_No__c == osL.StockNumber)
                                    invList[a].Available_Stock__c = osL.Available;
                            }
                        }
                    }
                    catch (Exception e) {
                        System.debug('Error in updating Stock '+e);
                    }
                    Boolean itemExists= false;
                    for (Integer a = 0; a< invList.size(); a++)
                    {
                        itemExists= false;
                        if(oS != null)
                        {
                            if( oS.ProductInventoryStatus != null)
                            {
                                for (complemarCom.ProductInventoryStatus osL : oS.ProductInventoryStatus)
                                {
                                    if (invList[a].Item_No__c == osL.StockNumber)
                                        itemExists= true;
                                }
                                if(itemExists== false)
                                {
                                    invList[a].Available_Stock__c = -1; // Item is not Available at Comet
                                }
                            }
                        }
                    }
                    
                    if(invList != null)
                        invToUpdate.addAll(invList);
                    system.debug('Size of invToUpdate after added items of  :'+objAccount.Name +'is ' + invToUpdate.size());
                }
            }
        }
        if (invToUpdate != null)
            update invToUpdate;
        
        /* Logic to update Inprocess Count in POS item InProcess_Inventory_Stock__c */
        Map<Id, Integer> itemsQtyWaitingForApproval = new Map<Id, Integer>();
        // Retreive Sum of items that needs approval in all Inventory Orders
        AggregateResult[] inProcessCountResults
            = [SELECT  POS_Item__r.Id itemid, POS_Item__r.Item_No__c itemno, SUM(Quantity__c) inprocesscnt
               FROM OrderDestinationItem__c
               WHERE Account_Name__c =:AcctName
               AND OrderDestination__r.Comet_Order_Status__c  = 'Needs Approval'
               AND OrderDestination__r.Order__r.Program__C = NULL
               GROUP BY POS_Item__r.Id, POS_Item__r.Item_No__c];
        for (AggregateResult ar : inProcessCountResults)
        {
            itemsQtyWaitingForApproval.put(Id.ValueOf((String)ar.get('itemid')), Integer.ValueOf(ar.get('inprocesscnt')));
            //System.debug('Item ID' + ar.get('itemid'));
            //System.debug('ItemNo' + ar.get('itemno'));
            //System.debug('InProcess Count' + ar.get('inprocesscnt'));
        }
        
        List<POS_Item__c> posItemsList;
        /**posItemsList = [SELECT ID, Name,Item_Name__c,Item_No__c, InProcess_Inventory_Stock__c
FROM POS_Item__c 
WHERE Account__r.Name = :AcctName AND (Inventory_Seasonal_Program__c <> 'Seasonal Program') AND Active__c = true];
**/
        // added by Pradeep kumar -Inprocess inventory is calculated for both active and inactive items.
        posItemsList = [SELECT ID, Name,Item_Name__c,Item_No__c, InProcess_Inventory_Stock__c
                        FROM POS_Item__c 
                        WHERE Account__r.Name = :AcctName AND (Inventory_Seasonal_Program__c <> 'Seasonal Program') AND InProcess_Inventory_Stock__c>0];
        
        for (Integer a = 0; a< posItemsList.size(); a++)
        {
            if(itemsQtyWaitingForApproval.get(posItemsList[a].ID) >0)
            {
                //System.debug('Item ID : ' + posItemsList[a].ID);
                //System.debug('ItemNo : ' + posItemsList[a].Item_No__c);
                //System.debug('InProcess cnt is : ' + posItemsList[a].InProcess_Inventory_Stock__c);
                //System.debug('count in orders is :'+ itemsQtyWaitingForApproval.get(posItemsList[a].ID));
                posItemsList[a].InProcess_Inventory_Stock__c =itemsQtyWaitingForApproval.get(posItemsList[a].ID);
            }
            else
            {
                //System.debug('Updating InProcess_Inventory_Stock__c to 0 for item'+posItemsList[a].Item_No__c);
                posItemsList[a].InProcess_Inventory_Stock__c =0;
            }
        } 
        if ( posItemsList != null)
            update posItemsList;
        /* End of updating   InProcess_Inventory_Stock__c  */         
    }
    /*
@future(callout=true)
public static void GetLatestStock1()
{
complemarCom.CometERPWSSoap stub = new complemarCom.CometERPWSSoap();
stub.timeout_x = 90000;
List<POS_Item__c> invToUpdate  = new List<POS_Item__c>();
POS_Item__c currItem = new POS_Item__c();
List<Account> objAccountList  = [SELECT ID, Name, CometJobNo__c, CometUsername__c, CometPassword__c, hasCometConfiguration__c FROM Account WHERE hasCometConfiguration__c = true AND ((Name != 'MMD') AND (Name != 'Mionetto') AND (Name != 'Bogle Vineyards')) ];
for (Account objAccount: objAccountList)
{
system.debug('Processing Stock for :'+objAccount.Name);
List<POS_Item__c> invList ;
if(objAccount.hasCometConfiguration__c == true)
{
invList =  [Select  Id,  Available_Stock__c,  Item_No__c From POS_Item__c  WHERE Active__C = true AND Account__C =:objAccount.ID ];
if(invList != null)
{
for (Integer a = 0; a< invList.size(); a++)
{
try{
invList[a].Available_Stock__c = stub.AvailableBalance(invList[a].Item_No__c, objAccount.CometUsername__c, objAccount.CometPassword__c, '');
}
catch (Exception e) {
invList[a].Available_Stock__c = -1;
system.debug('Error :' + e);
}
}
if(invList != null)
invToUpdate.addAll(invList);
system.debug('Size of invToUpdate after added items of  :'+objAccount.Name +'is ' + invToUpdate.size());
}
}
}
if (invToUpdate != null)
update invToUpdate;

}
*/
    
    
    /////////////////////////////////////////////////////////////////////////////////////////
    // Notification For Low Level Inventory
    /////////////////////////////////////////////////////////////////////////////////////////
    public void NotificationForLowLevelInventory()
    {
        complemarCom.CometERPWSSoap stub = new complemarCom.CometERPWSSoap();
        stub.timeout_x = 90000;
        List<POS_Item__c> invToUpdate ;
        POS_Item__c currItem = new POS_Item__c();
        EmailTemplate templateId;
        
        if(test.isRunningTest())
            templateId = [Select id from EmailTemplate Limit 1];
        else
            templateId = [Select id from EmailTemplate where name = 'Low inventory level'  Limit 1];
        for (Account objAccount: objAccountList)
        {
            if(objAccount.hasCometConfiguration__c == true)
            {
                hasCometdets = true;
                cometUser = objAccount.CometUsername__c;
                cometPasword = objAccount.CometPassword__c;
                customer ='';
            }
            try
            {
                if (objAccount.Name == 'MMD')
                {
                    Contact targetId = [SELECT ID,Name, Email from contact WHERE Name = 'Admin MMD' Limit 1]; // this has to be updated
                    invToUpdate =  [Select  Id,  Available_Stock__c,  Item_No__c, Low_inventory_level_applicable__c, Low_Inventory_Level__c From POS_Item__c WHERE (Active__C = true) AND (Low_inventory_level_applicable__c = true) AND Account__C =:objAccount.ID ];
                    if(invToUpdate != null)
                    {
                        for (Integer a = 0; a< invToUpdate.size(); a++)
                        {
                            try{
                                if (invToUpdate[a].Available_Stock__c < invToUpdate[a].Low_Inventory_Level__c )
                                {
                                    // Send Email to user
                                    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                                    // Step 1: Create a new Email
                                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                    
                                    mail.setTemplateID(templateId.Id); 
                                    mail.setWhatId(invToUpdate[a].id); 
                                    mail.setTargetObjectId(targetId.id);
                                    mails.add(mail);
                                    Messaging.sendEmail(mails);
                                }
                            }
                            catch (Exception e) {
                                system.debug('Error :' + e);
                            }
                            
                        }
                    }
                }
            }
            catch (Exception e) {
                system.debug('Error :' + e);
            }
        }
    }
    
    // Submit Orders that are processed by approvals
    @future(callout=true)
    public static void SubmitInprocessOrders_Ver1()
    {
        
        System.debug('SubmitInprocessOrders-1');
        
        currOrderList = new List<Order__c>();
        currOrderDestList = new List<OrderDestination__c>();
        
        List<Order__c> OrdList = new List<Order__c>();
        List<OrderDestination__c> shipMethAppReqDestinations = new List<OrderDestination__c>();
        List<OrderDestinationItem__c> OdiList;
        
        Boolean hasCometdets_curr = false;
        String cometUser_curr = '';
        String cometPasword_curr = '';
        String customer_curr ='';
        Decimal  budRuleNo_curr = 0;
        String cometJobNo_curr ='';
        
        complemarCom.CometERPWSSoap stub = new complemarCom.CometERPWSSoap();
        stub.timeout_x = 90000;
        List<Account> objAccountList_curr = [SELECT ID, Name, CometJobNo__c, CometUsername__c, CometPassword__c, hasCometConfiguration__c, BudgetRuleNo__c FROM Account WHERE hasCometConfiguration__c = true ];
        for (Account objAccount: objAccountList_curr)
        {
            System.debug('SubmitInprocessOrders-2 Account name: '+objAccount.Name);
            
            if(objAccount.hasCometConfiguration__c == true)
            {
                System.debug('SubmitInprocessOrders-3 Coment Username: '+objAccount.CometUsername__c);
                hasCometdets_curr = true;
                cometUser_curr = objAccount.CometUsername__c;
                cometPasword_curr = objAccount.CometPassword__c;
                customer_curr ='';
                budRuleNo_curr =objAccount.BudgetRuleNo__c;
                cometJobNo_curr =  objAccount.CometJobNo__c;
            }
            try
            {
                // Submit order for current Customer if all approvals are processed
                
                OrdList = [SELECT ID, Name, Order_Status__c  from Order__c WHERE (Order_Status__c != 'OPEN') AND (Order_Status__c != 'Submitted') AND (Account__C =: objAccount.id)]; //'001L000000olO77IAE' -Bogle
                
                System.debug('SubmitInprocessOrders-4 Order to get submitted if approved size : '+OrdList.size());
                
                for (Integer a = 0; a< OrdList.size(); a++)
                {
                    //shipMethAppReqDestinations= [SELECT Id, Name from OrderDestination__c WHERE Id In (Select OrderDestination__c from OrderDestinationItem__c) AND Shipping_Method__c IN (SELECT ID  FROM Shipping_Method__c WHERE ApprovalRequired__c = true AND Account__C =:objAccount.ID  ) AND Order__C =: OrdList[a].Id ];
                    Order__C Ord = [SELECT Id, Name, Order_Status__c, Order_Date__c from Order__c WHERE ID =:OrdList[a].Id LIMIT 1];   
                    //if(shipMethAppReqDestinations.size() ==0)
                    // {
                    OdiList = [SELECT ID,Name, OrderDestination__r.ShipMethAppReq__c, OrderDestination__r.ShipMethodApproved__c,
                               MaxOrderAppReq__c, MaxOrderApproved__c, ItemAppReq__c, ItemApproved__c, OrderDestination__r.Order__r.id ,OrderDestination__r.OrderName__c
                               FROM OrderDestinationItem__c
                               WHERE (Quantity__c > 0) AND ( ( (OrderDestination__r.ShipMethAppReq__c = true) AND (OrderDestination__r.ShipMethodApproved__c = false))
                                                            OR  ( (MaxOrderAppReq__c = true) AND (MaxOrderApproved__c = false))
                                                            OR  ( (ItemAppReq__c = true)  AND ( (ItemApproved__c = false) AND (ItemRejected__c = false) ))
                                                           ) AND (OrderDestination__r.Order__r.id =: OrdList[a].Id)];
                    
                    if( (OdiList == null) || (OdiList.size()==0) )
                    {
                        
                        System.debug('Order status before Submitig ordeto compamer: '+Ord.Order_Status__c);
                        //SubmtOder orderid to Comet
                        updateOrderStatus_Ver1(INPROCESS, hasCometdets_curr, cometUser_curr,cometPasword_curr,customer_curr, cometJobNo_curr, Ord, budRuleNo_curr);
                        
                    }
                    //else
                    // {
                    //     updateOrderStatus(PENDAPPMAXORDQTYORAPPREQ, hasCometdets_curr, cometUser_curr,cometPasword_curr,customer_curr ,cometJobNo_curr, Ord, budRuleNo_curr);
                    //}
                    //}
                }
            }
            catch (Exception e) {
                system.debug('Error :' + e);
            }
        }
        
        System.debug('size of currOrderList in SubmitInprocessOrders is '+currOrderList.size());
        System.debug('size of currOrderDestList in SubmitInprocessOrders is '+currOrderDestList.size());
        //Update currOrderList;
        
        Update currOrderList;
        Update currOrderDestList;
        
    }
    
    public static void updateOrderStatus_Ver1(String status, Boolean hasCometdets_curr, String cometUser_curr,String cometPasword_curr, String customer_curr, String cometJobNo_curr, Order__C Ord, Decimal budRuleNo_curr )
    {
        String currStatus = Ord.Order_Status__c;
        Ord.Order_Status__c = status;
        
        //System.debug('updateOrderStatus-1 status passsed is' +status);
        //System.debug('updateOrderStatus-2 current status is' +currStatus);
        //System.debug('updateOrderStatus-3 ORder' +Ord.Name);
        if (status == INPROCESS)
            SubmitOrdertoComet_Ver1(hasCometdets_curr, cometUser_curr,cometPasword_curr,customer_curr,cometJobNo_curr, Ord);
        else if ( (status == PENDAPPROVAL) || (status == SUBMITTED) || (status == PENDAPPSHIPMETH)  || (status == PENDAPPMAXORDQTYORAPPREQ) )
        {
            Ord.Order_Submission_Date__c = datetime.now();
            Ord.Order_Status__c = status;
            //update Ord;
            currOrderList.add(Ord);
        }
        
        
        String strOName = Ord.Name;
        if (budRuleNo_curr==1) // This is for MMD
        {
            if ( ((currStatus == OPEN) || (status == PENDAPPSHIPMETH)  || (status == PENDAPPMAXORDQTYORAPPREQ) ) && (status == INPROCESS)) 
            {
                // Adjust Budgets for Inventory Order
                String UserId;
                //UserId = userinfo.getUserId();
                UserId = Ord.CreatedBy.ID;
                Users_Territory__c usrter;
                usrter = [select Territory__c from Users_Territory__c where User__c =: UserId  LIMIT 1];
                String BrandId;
                List<OrderDestination__c> objODList = [Select id,Name FROM OrderDestination__c WHERE Order__c = :Ord.Id];
                for(OrderDestination__c objOD : objODList)
                {
                    List <OrderDestinationItem__c> objODIList = [Select id,POS_Item__r.Item_No__c, Quantity__c FROM OrderDestinationItem__c 
                                                                 WHERE OrderDestination__c = :objOD.Id AND Quantity__c >0];
                    for(OrderDestinationItem__c objODI: objODIList)
                    {
                        POS_Item__c item = [Select ID,Name, Brand__c, Price__c FROM POS_Item__c  Where ID = :objODI.POS_Item__r.id    LIMIT 1];
                        BrandId = item.Brand__c;
                        List<Brand_Territory_Budget__c> budList; 
                        budList = [SELECT ID, Name, Remaining_Budget__c,Utilized_Budget__c FROM Brand_Territory_Budget__c WHERE Territory__c =:usrter.Territory__c AND Brand__c = :BrandId  Limit 1];
                        budList[0].Utilized_Budget__c = budList[0].Utilized_Budget__c+objODI.Quantity__c * item.Price__c;
                        update budList;
                    }  
                }
            }
        }// End of BudgetRule
        
    }
    
    public static void SubmitOrdertoComet_Ver1(Boolean hasCometdets_curr, String cometUser_curr,String cometPasword_curr, String customer_curr, String cometJobNo_curr, Order__c Ord )
    {
        System.debug('IN SubmitOrdertoComet');
        // Submit Order to Comet
        complemarCom.CometERPWSSoap stub = new complemarCom.CometERPWSSoap();
        complemarCom.OrderRequest oReq= new complemarCom.OrderRequest();
        complemarCom.OrderRequest oRet= new complemarCom.OrderRequest();
        
        // System.debug('Transaction_x'+ oReq.Transaction_x);
        oReq.UpdateAction = 'Update'; //String
        complemarCom.ArrayOfOrderRequestItem Items = new complemarCom.ArrayOfOrderRequestItem();
        complemarCom.OrderRequestItem [] aoItem = new List<complemarCom.OrderRequestItem>();
        complemarCom.OrderRequestItem oItem=new complemarCom.OrderRequestItem();
        
        complemarCom.OrderedByRequest OrderedBy = new complemarCom.OrderedByRequest();
        complemarCom.ShipToRequest[] ShipTo = new List<complemarCom.ShipToRequest>();
        complemarCom.ShipToRequest ShipToD = new complemarCom.ShipToRequest();
        complemarCom.AddressRequest[] Addresses =new List<complemarCom.AddressRequest>();
        complemarCom.AddressRequest AddressesD =new complemarCom.AddressRequest();
        
        complemarCom.PhoneNumberRequest[] phones = new List<complemarCom.PhoneNumberRequest>();
        complemarCom.PhoneNumberRequest phone = new complemarCom.PhoneNumberRequest();
        
        complemarCom.ShippingRequest ShippingSpec = new  complemarCom.ShippingRequest();
        
        //oItem.CustomerID = 'IRG-MMD';
        //oItem.Name = 'TestProduct1';
        
        string CurrOrderName='';
        Integer destcnt=0;
        // Get Items List 
        List<OrderDestination__c> objODList = [Select id,Name ,AddressBook__r.Address__c, AddressBook__r.City__c, AddressBook__r.Country__c, AddressBook__r.Destination_Name__c, AddressBook__r.Email__c,AddressBook__r.Fax__c, AddressBook__r.Phone__c, AddressBook__r.Shipto_Company__c, AddressBook__r.Shipto_Name__c,AddressBook__r.State__c,  AddressBook__r.StateCode__c, AddressBook__r.Zip__c, CreatedBy.name,CreatedBy.email, Shipping_Method__r.Shipping_Method_Name__c, OrderName__c, OrderDest_Status__c FROM OrderDestination__c WHERE Order__c = :ord.Id AND OrderDest_Status__c ='OPEN'];
        for (Integer a = 0; a< objODList.size(); a++)
        {
            Items = new complemarCom.ArrayOfOrderRequestItem();
            aoItem = new List<complemarCom.OrderRequestItem>();
            oItem=new complemarCom.OrderRequestItem();
            
            OrderedBy = new complemarCom.OrderedByRequest();
            ShipTo = new List<complemarCom.ShipToRequest>();
            ShipToD = new complemarCom.ShipToRequest();
            Addresses =new List<complemarCom.AddressRequest>();
            AddressesD =new complemarCom.AddressRequest();
            
            phones = new List<complemarCom.PhoneNumberRequest>();
            phone = new complemarCom.PhoneNumberRequest();
            
            ShippingSpec = new  complemarCom.ShippingRequest();
            
            OrderDestination__c objOD;
            objOD = objODList[a];
            String currOrdDestid='';
            if (objOD != null)
                currOrdDestid = objOD.id;
            
            Boolean hasItemsinOrder = false;
            System.debug('currOrdDestid  :'+ currOrdDestid );
            
            List <OrderDestinationItem__c> objODIList = [Select id,POS_Item__r.Item_No__c, Quantity__c FROM OrderDestinationItem__c 
                                                         WHERE  ( (OrderDestination__c = :currOrdDestid)  AND (Quantity__c >0) )];
            hasItemsinOrder = false;
            for(OrderDestinationItem__c objODI: objODIList)
            {
                hasItemsinOrder = true;
                oItem=new complemarCom.OrderRequestItem();
                POS_Item__c item = [Select ID,Name, Brand__c, Price__c,Item_No__c FROM POS_Item__c  Where ID = :objODI.POS_Item__r.id    LIMIT 1];
                oItem.UpdateAction = 'Update';
                oItem.JobNumber = 0;
                oItem.Transaction_x=0;
                oItem.Sequence=0;
                oItem.Line=0;
                oItem.ItemJobNumber =0;
                oItem.StockNumber = item.Item_No__c; //'TestProduct1';
                oItem.Quantity = Integer.valueOf(objODI.Quantity__c);
                oItem.ShipQuantity =  Integer.valueOf(objODI.Quantity__c);
                oItem.BackOrderQuantity=0;
                oItem.ReturnQuantity=0;
                aoItem.add(oItem);
            }  
            
            Items.OrderRequestItem = aoItem;
            oReq.Items = Items;
            
            oReq.REC_NUM =0; // Integer Blank
            oReq.JobNumber= integer.valueof(cometJobNo_curr); //76885; // Integer try 1
            oReq.Transaction_x=0;
            oReq.Sequence=0; //Integer
            oReq.METHOD=0; // blank
            oReq.WarehouseID=0; //  Integer try 1
            oReq.OrderName=  objOD.OrderName__c; //'EIO_731_1262'; // unique String
            oReq.CustReference= objOD.OrderName__c; //'EIO_731_1262'; // sOrderName;String
            CurrOrderName = objOD.OrderName__c;
            oReq.OrderPrefix= 'WC';//String
            oReq.TType = 'StandardOrder';  //StandardOrder  String
            oReq.OrderOrigination = 'Web'; //Web  String
            oReq.Status='Open'; // Return value
            oReq.OrderApprovalStatus='Approved'; // blank
            
            Datetime currDateTime = Datetime.now();
            oReq.CreatedDate = Ord.Order_Date__c == null ? currDateTime: Ord.Order_Date__c;
            oReq.LastModDate = Ord.Order_Date__c == null ? currDateTime: Ord.Order_Date__c;
            OrderedBy = new complemarCom.OrderedByRequest();
            ShipTo = new List<complemarCom.ShipToRequest>();
            ShipToD = new complemarCom.ShipToRequest();
            Addresses =new List<complemarCom.AddressRequest>();
            AddressesD =new complemarCom.AddressRequest();
            //AddressesD.CustomerID = 'IRG-MMD';
            
            AddressesD.Name = objOD.AddressBook__r.Destination_Name__c == null ? '': (objOD.AddressBook__r.Destination_Name__c).LEFT(8);
            AddressesD.UpdateAction = 'Update';
            AddressesD.StreetAddress1 = objOD.AddressBook__r.Address__c == null ? '': objOD.AddressBook__r.Address__c;
            AddressesD.City = objOD.AddressBook__r.City__c == null ? '': objOD.AddressBook__r.City__c;
            AddressesD.State =objOD.AddressBook__r.StateCode__c == null ? '':objOD.AddressBook__r.StateCode__c ;
            AddressesD.ZipCode = objOD.AddressBook__r.Zip__c == null ? '0':objOD.AddressBook__r.Zip__c;
            //AddressesD.CountryCode= '1';
            AddressesD.Country = 'United States';
            
            phones = new List<complemarCom.PhoneNumberRequest>();
            phone = new complemarCom.PhoneNumberRequest();
            
            phone.Name = 'Distributor';
            phone.UpdateAction = 'Update';
            phone.AddressID =  '00000000-0000-0000-0000-000000000000';
            phone.Number_x = objOD.AddressBook__r.Phone__c == null ? '0': objOD.AddressBook__r.Phone__c ;
            phones.add(phone);
            
            AddressesD.phones = phones;
            Addresses.add(AddressesD); 
            
            OrderedBy.CustomerID = 'anonymous-10525';
            OrderedBy.UpdateAction='Update';
            OrderedBy.UserID = '00000000-0000-0000-0000-000000000000';
            OrderedBy.JobNumber = 0;
            
            OrderedBy.FirstName = objOD.CreatedBy.name == null ? '': objOD.CreatedBy.name;
            OrderedBy.MidInitial =1; 
            OrderedBy.LastName = '';
            OrderedBy.Title = 't'; 
            Datetime cDT = System.now();
            OrderedBy.LastModDate = cDT; //DateTime.valueOf('2016-02-02 01:00:00');
            OrderedBy.Email = objOD.CreatedBy.email;
            OrderedBy.EmailPreference = 'HTML';
            
            OrderedBy.Addresses = Addresses;
            OrderedBy.phones = phones;
            OrderedBy.Company = 'IRG';
            OrderedBy.Owner = '00000000-0000-0000-0000-000000000000';
            OrderedBy.Creator = '00000000-0000-0000-0000-000000000000';
            OrderedBy.ApprovalNeeded = False;
            oReq.OrderedBy = OrderedBy;
            
            ShipToD.CustomerID = 'anonymous-10525';
            ShipToD.UpdateAction = 'Update';
            ShipToD.UserID = '00000000-0000-0000-0000-000000000000';
            ShipToD.JobNumber = 0;
            ShipToD.FirstName = objOD.AddressBook__r.Shipto_Name__c == null ? '': (objOD.AddressBook__r.Shipto_Name__c);
                ShipToD.MidInitial=0;
            ShipToD.LastName = '';
            ShipToD.Title = 't';
            ShipToD.Company = objOD.AddressBook__r.Shipto_Company__c == null ? '': (objOD.AddressBook__r.Shipto_Company__c).LEFT(8);
            ShipToD.LastModDate = cDT;
            ShipToD.Email = '';
            ShipToD.EmailPreference = 'HTML';
            ShipToD.Addresses = Addresses;
            shipToD.phones = phones;
            ShipToD.Owner = '00000000-0000-0000-0000-000000000000';
            ShipToD.Creator = '00000000-0000-0000-0000-000000000000';
            ShiptoD.ApprovalNeeded = false;
            //ShipToD.ShippingSpecID = 1;
            ShipTo.add(ShipToD);
            oReq.ShipTo = ShipTo;
            
            ShippingSpec = new  complemarCom.ShippingRequest();
            //ShippingSpec.CustomerID = 'IRG-MMD';
            //ShippingSpec.Name = 'IRG-MMD';
            ShippingSpec.UpdateAction= 'Update';
            //DateTime myDT = DateTime.newInstance(2016, 2, 2, 10, 7, 12);
            //ShippingSpec.ArriveByDate = ''; // DateTime.valueOf('2016-02-02 01:00:00');
            //ShippingSpec.ShipByDate = ''; //DateTime.valueOf('2016-02-4 01:00:00');
            ShippingSpec.Carrier = 'Unknown';
            ShippingSpec.ServiceLevel= objOD.Shipping_Method__r.Shipping_Method_Name__c == null ? '': (objOD.Shipping_Method__r.Shipping_Method_Name__c);
                ShippingSpec.Rush = false;
            //ShippingSpec.ShipInstructions = 'USPS Priority Mail' ;
            ShippingSpec.ShipReference1 = '';
            ShippingSpec.RCODE = 1;
            oReq.ShippingSpec =ShippingSpec;
            
            oReq.TotalSale=0.0; 
            oReq.Tax=0.0;
            oReq.ShippingCharge=0.0;
            oReq.ShippingCost=0.0;
            oReq.DiscountCode=0;
            oReq.DiscountPercentage=0.0;
            oReq.Discount=0.0;
            oReq.AmountDue=0.0;
            oReq.AmountReceived=0.0;
            oReq.ScriptAmount=0.0;
            oReq.CreditCardAmount=0.0;
            oReq.WriteOff = 0.0;
            oReq.Refund = 0.0;
            oReq.UsageCode=0;
            //oReq.CustomerOrderType = 'Web';  // blank
            
            try{
                if (hasItemsinOrder== true)
                {
                    system.debug('Order Submitted: '+CurrOrderName);
                    system.debug('oReq: '+oReq);
                    oRet = stub.CreateOrder(oReq, cometUser_curr,cometPasword_curr);
                }
            }      
            catch (Exception e) {
                System.debug('Exception While createing Order stub.CreateOrder   getStackTraceString() is: '+ e.getStackTraceString());
                System.debug('Exception : this can be ignored if that is for transaction no'+ e);
                String errmsg = e.getMessage();
                if (errmsg.contains('Apex type not found for element Transaction'))
                {
                    System.debug('Updaing OrderDest status to Submitted for order dest '+objODList[a].Name);
                    objODList[a].OrderDest_Status__c = 'Submitted';
                }
                
            }
            
            System.debug('size of currOrderDestList before adding od  is '+currOrderDestList.size());
            
            currOrderDestList.add(objODList[a]);
            System.debug('size of currOrderDestList after adding od  is '+currOrderDestList.size());
            Ord.Order_Submission_Date__c = datetime.now();
            System.debug('size of currOrderList before adding od  is '+currOrderList.size());
            
            Boolean existingOrder = false;
            for (Integer i = 0; i< currOrderList.size(); i++)
            {
                existingOrder = false;
                string cOrdId=currOrderList[i].id;
                if (cOrdId == Ord.id)
                {
                    currOrderList[i].Order_Submission_Date__c= Ord.Order_Submission_Date__c;
                    existingOrder = true;
                }
            }
            if (existingOrder == false)
                currOrderList.add(Ord);
            System.debug('size of currOrderList After adding od  is '+currOrderList.size());
            
            /*

system.debug('order Submitted: and Response from  CreateOrder is '+oRet);
Integer tranNo=0;
stub = new complemarCom.CometERPWSSoap();
stub.timeout_x = 90000;
complemarCom.ArrayOfOrderStatus oSA= new complemarCom.ArrayOfOrderStatus();
complemarCom.OrderStatus os = new complemarCom.OrderStatus();
Datetime myDT = Datetime.now();
Datetime endDate = myDT.addMinutes(-300);
Datetime startDate = myDT.addMinutes(-400); //  310 325 350 400 500 1000

String warehouseStatus='';
String warehouseProcessStatus='';
Integer warehouseSequence=0;
String warehouseShippingStatus='';

try {
//System.debug('cometUser_curr  : '+cometUser_curr);
//System.debug('cometPasword_curr  : '+cometPasword_curr);
stub.timeout_x = 90000;
oSA = stub.GetOrderStatusList(startDate, endDate, cometUser_curr,cometPasword_curr);
//System.debug(' oSA : '+oSA);
for (complemarCom.OrderStatus os1 : oSA.OrderStatus)
{
//System.debug(' os1 : '+os1);
System.debug(' CurrOrderName : '+CurrOrderName);
if (os1 != null)
{
if (CurrOrderName == os1.CustomerID)
{
System.debug(' tranNo : '+tranNo);
tranNo =os1.Transaction_x;
warehouseStatus = os1.Status;
warehouseProcessStatus = os1.ProcessStatus;
warehouseSequence = os1.Sequence;
}
}
}
} catch (Exception e)
{
System.debug(' Exception while updating TransactionNo: ' + e);
}

if(tranNo >0 )
{
destcnt++;
objOD.WarehouseTransactionNo__c = string.valueof(tranNo);
objODList[a].WarehouseTransactionNo__c = string.valueof(tranNo);
objODList[a].WarehouseOrderStatus__c =warehouseStatus;
objODList[a].WarehouseProcessingStatus__c =warehouseProcessStatus;
objODList[a].WarehouseSequence__c =string.valueof(warehouseSequence);

currOrderDestList.add(objODList[a]);
}*/
        }  
        /*
//Update objODList;
if(objODList.size() == destcnt )
Ord.Order_Status__c ='Submitted';
Ord.Order_Submission_Date__c = datetime.now();
//Update Ord;
currOrderList.add(Ord);


*/
    }
    // End of SubmitOrdertoComet function
    
    @future(callout=true)
    public static void UpdateTransactionNumbers(Integer dayspan,String accountName)
    {
        currOrderList = new List<Order__c>();
        currOrderDestList = new List<OrderDestination__c>();
        List<OrderDestination__c> objODList =new List<OrderDestination__c>();
        
        Boolean hasCometdets_curr = false;
        String cometUser_curr = '';
        String cometPasword_curr = '';
        String customer_curr ='';
        Decimal  budRuleNo_curr = 0;
        String cometJobNo_curr ='';
        String CurrOrderName ='';
        
        Integer tranNo=0;
        Datetime myDT = Datetime.now();
        Datetime endDate = myDT.addMinutes(-300);
        Datetime startDate = myDT.addMinutes(-1000); //  310 325 350 400 500 1000
        if (dayspan >0)
            startDate = myDT.addDays(dayspan*(-1));
        
        String warehouseStatus='';
        String warehouseProcessStatus='';
        Integer warehouseSequence=0;
        String warehouseShippingStatus='';
        
        
        complemarCom.CometERPWSSoap stub = new complemarCom.CometERPWSSoap();
        stub.timeout_x = 120000;
        complemarCom.ArrayOfOrderStatus oSA= new complemarCom.ArrayOfOrderStatus();
        complemarCom.OrderStatus os = new complemarCom.OrderStatus();
        
        List<Account> objAccountList_curr = [SELECT ID, Name, CometJobNo__c, CometUsername__c, CometPassword__c, hasCometConfiguration__c, BudgetRuleNo__c FROM Account WHERE hasCometConfiguration__c = true AND Name =:accountName ];
        for (Account objAccount: objAccountList_curr)
        {
            if(objAccount.hasCometConfiguration__c == true)
            {
                //System.debug('UpdateWarehouseOrderStatuses-3 Coment Username: '+objAccount.CometUsername__c);
                hasCometdets_curr = true;
                cometUser_curr = objAccount.CometUsername__c;
                cometPasword_curr = objAccount.CometPassword__c;
                customer_curr ='';
                budRuleNo_curr =objAccount.BudgetRuleNo__c;
                cometJobNo_curr =  objAccount.CometJobNo__c;
                
                objODList = [Select id,Name ,AddressBook__r.Address__c, AddressBook__r.City__c, AddressBook__r.Country__c, AddressBook__r.Destination_Name__c, AddressBook__r.Email__c,AddressBook__r.Fax__c, AddressBook__r.Phone__c, AddressBook__r.Shipto_Company__c, AddressBook__r.Shipto_Name__c,AddressBook__r.State__c,  AddressBook__r.StateCode__c, AddressBook__r.Zip__c, CreatedBy.name,CreatedBy.email, Shipping_Method__r.Shipping_Method_Name__c, OrderName__c, OrderDest_Status__c FROM OrderDestination__c WHERE ((WarehouseTransactionNo__c =NULL) OR (WarehouseTransactionNo__c ='0')) AND OrderDest_Status__c ='Submitted' AND  (Order__r.Account__c =: objAccount.id) ];
                for (Integer a = 0; a< objODList.size(); a++)
                {
                    CurrOrderName = objODList[a].OrderName__c;
                    stub = new complemarCom.CometERPWSSoap();
                    stub.timeout_x = 90000;
                    oSA= new complemarCom.ArrayOfOrderStatus();
                    os = new complemarCom.OrderStatus();
                    
                    warehouseStatus='';
                    warehouseProcessStatus='';
                    warehouseSequence=0;
                    warehouseShippingStatus='';
                    tranNo =0;
                    
                    try {
                        stub.timeout_x = 90000;
                        oSA = stub.GetOrderStatusList(startDate, endDate, cometUser_curr,cometPasword_curr);
                        for (complemarCom.OrderStatus os1 : oSA.OrderStatus)
                        {
                            if (os1 != null)
                            {
                                if (CurrOrderName == os1.CustomerID)
                                {
                                    tranNo =os1.Transaction_x;
                                    warehouseStatus = os1.Status;
                                    warehouseProcessStatus = os1.ProcessStatus;
                                    warehouseSequence = os1.Sequence;
                                }
                            }
                        }
                    } catch (Exception e)
                    {
                        System.debug(' Exception while updating TransactionNo: ' + e);
                    }
                    
                    if(tranNo >0 )
                    {
                        objODList[a].WarehouseTransactionNo__c = string.valueof(tranNo);
                        objODList[a].WarehouseOrderStatus__c =warehouseStatus;
                        objODList[a].WarehouseProcessingStatus__c =warehouseProcessStatus;
                        objODList[a].WarehouseSequence__c =string.valueof(warehouseSequence);
                        currOrderDestList.add(objODList[a]);
                    }
                }
                
            }
        }
        
        Update currOrderDestList;
        // Update Order Status in Order Object
        List<Order__c> OrdList = new List<Order__c>();
        OrdList = [SELECT ID, Name, Order_Status__c  from Order__c WHERE (Order_Status__c != 'OPEN') AND (Order_Status__c != 'Submitted') AND (Program__C = NULL)];
        for (Integer a = 0; a< OrdList.size(); a++)
        {
            string cOrdId=OrdList[a].id;
            objODList = [Select id, Name, OrderName__c, OrderDest_Status__c FROM OrderDestination__c WHERE (Order__c =: cOrdId) AND  (OrderDest_Status__c='OPEN')];
            if(objODList.size() == 0 )
                OrdList[a].Order_Status__c= 'Submitted';
        }
        update OrdList;
    }
    
    public Integer getTransactionNo(string orderName, String cometUser_curr, String cometPasword_curr)
    {
        Integer transNo=0;
        complemarCom.CometERPWSSoap stub = new complemarCom.CometERPWSSoap();
        stub.timeout_x = 90000;
        complemarCom.ArrayOfOrderStatus oSA= new complemarCom.ArrayOfOrderStatus();
        complemarCom.OrderStatus os = new complemarCom.OrderStatus();
        Datetime myDT = Datetime.now();
        Datetime endDate = myDT.addMinutes(-300);
        Datetime startDate = myDT.addMinutes(-310); //  310 325 350 400 500 1000
        try{
            oSA = stub.GetOrderStatusList(startDate, endDate, cometUser_curr,cometPasword_curr);
            for (complemarCom.OrderStatus os1 : oSA.OrderStatus)
            {
                if (os1!=null)
                {
                    if (orderName == os1.CustomerID)
                        transNo =os1.Transaction_x;
                }
            }
        }      
        catch (Exception e) {
            System.debug('getTransactionNo exception :  Order not Found ' + e);
        }
        system.debug('Current Transaction No in Comet for this order  is : '+transNo);
        return transNo;
    }
    // End of getTransactionNo
    
    // Update Warehouse Order status for orders
    @future(callout=true)
    public static void UpdateWarehouseOrderStatuses()
    {
        System.debug('UpdateWarehouseOrderStatuses-1');
        
        List<Order__c> OrdList = new List<Order__c>();
        List<OrderDestination__c> OdList;
        List<OrderDestination__c> shipMethAppReqDestinations = new List<OrderDestination__c>();
        List<OrderDestinationItem__c> OdiList;
        
        
        List<OrderDestination__c> OdCompleteList = new List<OrderDestination__c>();
        
        Boolean hasCometdets_curr = false;
        String cometUser_curr = '';
        String cometPasword_curr = '';
        String customer_curr ='';
        Decimal  budRuleNo_curr = 0;
        String cometJobNo_curr ='';
        
        complemarCom.CometERPWSSoap stub = new complemarCom.CometERPWSSoap();
        stub.timeout_x = 90000;
        complemarCom.ArrayOfOrderStatus oSA= new complemarCom.ArrayOfOrderStatus();
        complemarCom.OrderStatus os = new complemarCom.OrderStatus();
        
        List<Account> objAccountList_curr = [SELECT ID, Name, CometJobNo__c, CometUsername__c, CometPassword__c, hasCometConfiguration__c, BudgetRuleNo__c FROM Account WHERE hasCometConfiguration__c = true ];
        for (Account objAccount: objAccountList_curr)
        {
            //System.debug('UpdateWarehouseOrderStatuses-2 Account name: '+objAccount.Name);
            
            if(objAccount.hasCometConfiguration__c == true)
            {
                //System.debug('UpdateWarehouseOrderStatuses-3 Coment Username: '+objAccount.CometUsername__c);
                hasCometdets_curr = true;
                cometUser_curr = objAccount.CometUsername__c;
                cometPasword_curr = objAccount.CometPassword__c;
                customer_curr ='';
                budRuleNo_curr =objAccount.BudgetRuleNo__c;
                cometJobNo_curr =  objAccount.CometJobNo__c;
            }
            //try
            // {
            // Update Warehouse Order statuses if not shipped
            Integer tranNo=0;
            Datetime myDT = Datetime.now();
            Datetime endDate = myDT.addMinutes(-300);
            Datetime startDate = myDT.addMinutes(-1000); //  310 325 350 400 500 1000
            String warehouseStatus='';
            String warehouseProcessStatus='';
            Integer warehouseSequence=0;
            String warehouseShippingStatus='';
            System.debug('cometUser_curr  : '+cometUser_curr);
            System.debug('cometPasword_curr  : '+cometPasword_curr);
            OdList = [Select ID, Name, OrderName__C, WarehouseOrderStatus__c, WarehouseProcessingStatus__c, WarehouseSequence__c, WarehouseShippingComments__c, WarehouseShippingDate__c, WarehouseShippingStatus__c, WarehouseTransactionNo__c, Carrier__c, TrackingNos__c FROM OrderDestination__c WHERE Order__r.Account__c =: objAccount.id AND WarehouseTransactionNo__c !=NULL AND WarehouseTransactionNo__c !='0' AND WarehouseShippingDate__c = NULL AND WarehouseShippingStatus__c = NULL ORDER BY WarehouseResponseDate__c DESC LIMIT 25];
            for (Integer a = 0; a< OdList.size(); a++)
            {
                try {
                    OdList[a].WarehouseResponseDate__c = System.Now();
                    os = stub.GetOrderStatus(Integer.valueOf(OdList[a].WarehouseTransactionNo__c), 0, cometUser_curr,cometPasword_curr);
                    System.debug(' os is '+os);
                    //OdList[a].WarehouseOrderStatus__c = os.Status;
                    OdList[a].WarehouseProcessingStatus__c = os.ProcessStatus;
                    if ( os.ShippingStatus != null)
                    {
                        System.debug(' os shipping statuy is not null');
                        OdList[a].WarehouseShippingStatus__c ='Shipped';
                        OdList[a].WarehouseShippingDate__c = os.ShippingStatus.ShipDate;
                        String TrackingNumbers='';
                        String TrackingNumbersLinks='';
                        for(String str : os.ShippingStatus.TrackingNumbers.string_x)
                        {
                            TrackingNumbers += str + ',' ;
                            if((os.ShippingStatus.Carrier).contains('FedEx'))
                            {
                                //TrackingNumbersLinks += '<a href="https://www.fedex.com/fedextrack/?tracknumbers='+str+' target="Blank">'+str+'</a><br/>';
                                System.debug('Tracking No Link is '+'<a href="https://www.fedex.com/fedextrack/?tracknumbers='+str+'" target="Blank">'+str+'</a>');
                                TrackingNumbersLinks += str+', ';
                            }
                            else
                                TrackingNumbersLinks += str+', ';
                        }
                        // remove last additional comma from string
                        if(TrackingNumbers.length() >0)
                            TrackingNumbers = TrackingNumbers.subString(0,TrackingNumbers.length()-1);
                        OdList[a].WarehouseShippingComments__c = 'Carrier : ' + os.ShippingStatus.Carrier + ' ShipmentNumber : ' + os.ShippingStatus.ShipmentNumber + ' Method : ' + os.ShippingStatus.Method + ' TrackingNumbers : ' + TrackingNumbers;
                        OdList[a].Carrier__c = os.ShippingStatus.Carrier;
                        OdList[a].TrackingNos__c = TrackingNumbersLinks;
                        // Send Mail for Orderer
                    }
                }
                catch (Exception e)
                {
                    System.debug('Update Order status for '+OdList[a].Name+' Reason: ' + e);
                }
            }
            if (OdCompleteList != null)
                OdCompleteList.addAll(OdList);
            //}
            //catch (Exception e) {
            //    system.debug('Error :' + e);
            // }
        }
        
        if(OdCompleteList != null)
            Update OdCompleteList;
    }
    // End of UpdateWarehouseOrderStatuses
    
    
    
    // Bridge Implementation
    
    // Submit Orders that are processed by approvals
    @future(callout=true)
    public static void SubmitInprocessOrders()
    {
        
        System.debug('SubmitInprocessOrders-1');
        
        currOrderList = new List<Order__c>();
        currOrderDestList = new List<OrderDestination__c>();
        
        List<Order__c> OrdList = new List<Order__c>();
        List<OrderDestination__c> shipMethAppReqDestinations = new List<OrderDestination__c>();
        List<OrderDestinationItem__c> OdiList;
        
        Boolean hasCometdets_curr = false;
        String cometUser_curr = '';
        String cometPasword_curr = '';
        String customer_curr ='';
        Decimal  budRuleNo_curr = 0;
        String cometJobNo_curr ='';
        
        complemarCom.CometERPWSSoap stub = new complemarCom.CometERPWSSoap();
        stub.timeout_x = 90000;
        List<Account> objAccountList_curr = [SELECT ID, Name, CometJobNo__c, CometUsername__c, CometPassword__c, hasCometConfiguration__c, BudgetRuleNo__c FROM Account WHERE hasCometConfiguration__c = true ];
        for (Account objAccount: objAccountList_curr)
        {
            System.debug('SubmitInprocessOrders-2 Account name: '+objAccount.Name);
            
            if(objAccount.hasCometConfiguration__c == true)
            {
                System.debug('SubmitInprocessOrders-3 Coment Username: '+objAccount.CometUsername__c);
                hasCometdets_curr = true;
                cometUser_curr = objAccount.CometUsername__c;
                cometPasword_curr = objAccount.CometPassword__c;
                customer_curr =objAccount.Name;//'';
                budRuleNo_curr =objAccount.BudgetRuleNo__c;
                cometJobNo_curr =  objAccount.CometJobNo__c;
            }
            try
            {
                // Submit order for current Customer if all approvals are processed
                
                OrdList = [SELECT ID, Name, Order_Status__c  from Order__c WHERE (Order_Status__c != 'OPEN') AND (Order_Status__c != 'Submitted') AND (Account__C =: objAccount.id) AND (Program__C = NULL) ORDER BY Name DESC LIMIT 50 ]; //'001L000000olO77IAE' -Bogle
                
                System.debug('SubmitInprocessOrders-4 Order to get submitted if approved size : '+OrdList.size());
                
                for (Integer a = 0; a< OrdList.size(); a++)
                {
                    //shipMethAppReqDestinations= [SELECT Id, Name from OrderDestination__c WHERE Id In (Select OrderDestination__c from OrderDestinationItem__c) AND Shipping_Method__c IN (SELECT ID  FROM Shipping_Method__c WHERE ApprovalRequired__c = true AND Account__C =:objAccount.ID  ) AND Order__C =: OrdList[a].Id ];
                    Order__C Ord = [SELECT Id, Name, Order_Status__c, Order_Date__c from Order__c WHERE (ID =:OrdList[a].Id) AND (Program__C = NULL) LIMIT 1];   
                    //if(shipMethAppReqDestinations.size() ==0)
                    // {
                    OdiList = [SELECT ID,Name, OrderDestination__r.ShipMethAppReq__c, OrderDestination__r.ShipMethodApproved__c,
                               MaxOrderAppReq__c, MaxOrderApproved__c, ItemAppReq__c, ItemApproved__c, OrderDestination__r.Order__r.id ,OrderDestination__r.OrderName__c
                               FROM OrderDestinationItem__c
                               WHERE (Quantity__c > 0) AND ( ( (OrderDestination__r.ShipMethAppReq__c = true) AND (OrderDestination__r.ShipMethodApproved__c = false))
                                                            OR  ( (MaxOrderAppReq__c = true) AND (MaxOrderApproved__c = false))
                                                            OR  ( (ItemAppReq__c = true)  AND ( (ItemApproved__c = false) AND (ItemRejected__c = false) ))
                                                           ) AND (OrderDestination__r.Order__r.id =: OrdList[a].Id)];
                    
                    if( (OdiList == null) || (OdiList.size()==0) )
                    {
                        
                        System.debug('Order status before Submitig ordeto compamer: '+Ord.Order_Status__c);
                        //SubmtOder orderid to Comet
                        updateOrderStatus(INPROCESS, hasCometdets_curr, cometUser_curr,cometPasword_curr,customer_curr, cometJobNo_curr, Ord, budRuleNo_curr);
                        
                    }
                    //else
                    // {
                    //     updateOrderStatus(PENDAPPMAXORDQTYORAPPREQ, hasCometdets_curr, cometUser_curr,cometPasword_curr,customer_curr ,cometJobNo_curr, Ord, budRuleNo_curr);
                    //}
                    //}
                }
            }
            catch (Exception e) {
                system.debug('Error :' + e);
            }
        }
        
        System.debug('size of currOrderList in SubmitInprocessOrders is '+currOrderList.size());
        System.debug('size of currOrderDestList in SubmitInprocessOrders is '+currOrderDestList.size());
        //Update currOrderList;
        
        Update currOrderList;
        Update currOrderDestList;
        
    }
    
    @future(callout=true)
    public static void SubmitInprocessOrdersWithLimit(Integer OrdCnt)
    {
        
        System.debug('SubmitInprocessOrders-1');
        
        currOrderList = new List<Order__c>();
        currOrderDestList = new List<OrderDestination__c>();
        
        List<Order__c> OrdList = new List<Order__c>();
        List<OrderDestination__c> shipMethAppReqDestinations = new List<OrderDestination__c>();
        List<OrderDestinationItem__c> OdiList;
        
        Boolean hasCometdets_curr = false;
        String cometUser_curr = '';
        String cometPasword_curr = '';
        String customer_curr ='';
        Decimal  budRuleNo_curr = 0;
        String cometJobNo_curr ='';
        
        complemarCom.CometERPWSSoap stub = new complemarCom.CometERPWSSoap();
        stub.timeout_x = 90000;
        List<Account> objAccountList_curr = [SELECT ID, Name, CometJobNo__c, CometUsername__c, CometPassword__c, hasCometConfiguration__c, BudgetRuleNo__c FROM Account WHERE hasCometConfiguration__c = true ];
        for (Account objAccount: objAccountList_curr)
        {
            System.debug('SubmitInprocessOrders-2 Account name: '+objAccount.Name);
            
            if(objAccount.hasCometConfiguration__c == true)
            {
                System.debug('SubmitInprocessOrders-3 Coment Username: '+objAccount.CometUsername__c);
                hasCometdets_curr = true;
                cometUser_curr = objAccount.CometUsername__c;
                cometPasword_curr = objAccount.CometPassword__c;
                customer_curr =objAccount.Name;//'';
                budRuleNo_curr =objAccount.BudgetRuleNo__c;
                cometJobNo_curr =  objAccount.CometJobNo__c;
            }
            try
            {
                // Submit order for current Customer if all approvals are processed
                
                OrdList = [SELECT ID, Name, Order_Status__c  from Order__c WHERE (Order_Status__c != 'OPEN') AND (Order_Status__c != 'Submitted') AND (Account__C =: objAccount.id) AND (Program__C = NULL) LIMIT :OrdCnt ]; //'001L000000olO77IAE' -Bogle
                
                System.debug('SubmitInprocessOrders-4 Order to get submitted if approved size : '+OrdList.size());
                
                for (Integer a = 0; a< OrdList.size(); a++)
                {
                    //shipMethAppReqDestinations= [SELECT Id, Name from OrderDestination__c WHERE Id In (Select OrderDestination__c from OrderDestinationItem__c) AND Shipping_Method__c IN (SELECT ID  FROM Shipping_Method__c WHERE ApprovalRequired__c = true AND Account__C =:objAccount.ID  ) AND Order__C =: OrdList[a].Id ];
                    Order__C Ord = [SELECT Id, Name, Order_Status__c, Order_Date__c from Order__c WHERE (ID =:OrdList[a].Id) AND (Program__C = NULL) LIMIT 1];   
                    //if(shipMethAppReqDestinations.size() ==0)
                    // {
                    OdiList = [SELECT ID,Name, OrderDestination__r.ShipMethAppReq__c, OrderDestination__r.ShipMethodApproved__c,
                               MaxOrderAppReq__c, MaxOrderApproved__c, ItemAppReq__c, ItemApproved__c, OrderDestination__r.Order__r.id ,OrderDestination__r.OrderName__c
                               FROM OrderDestinationItem__c
                               WHERE (Quantity__c > 0) AND ( ( (OrderDestination__r.ShipMethAppReq__c = true) AND (OrderDestination__r.ShipMethodApproved__c = false))
                                                            OR  ( (MaxOrderAppReq__c = true) AND (MaxOrderApproved__c = false))
                                                            OR  ( (ItemAppReq__c = true)  AND ( (ItemApproved__c = false) AND (ItemRejected__c = false) ))
                                                           ) AND (OrderDestination__r.Order__r.id =: OrdList[a].Id)];
                    
                    if( (OdiList == null) || (OdiList.size()==0) )
                    {
                        
                        System.debug('Order status before Submitig ordeto compamer: '+Ord.Order_Status__c);
                        //SubmtOder orderid to Comet
                        updateOrderStatus(INPROCESS, hasCometdets_curr, cometUser_curr,cometPasword_curr,customer_curr, cometJobNo_curr, Ord, budRuleNo_curr);
                        
                    }
                    //else
                    // {
                    //     updateOrderStatus(PENDAPPMAXORDQTYORAPPREQ, hasCometdets_curr, cometUser_curr,cometPasword_curr,customer_curr ,cometJobNo_curr, Ord, budRuleNo_curr);
                    //}
                    //}
                }
            }
            catch (Exception e) {
                system.debug('Error :' + e);
            }
        }
        
        System.debug('size of currOrderList in SubmitInprocessOrders is '+currOrderList.size());
        System.debug('size of currOrderDestList in SubmitInprocessOrders is '+currOrderDestList.size());
        //Update currOrderList;
        
        Update currOrderList;
        Update currOrderDestList;
        
    }
    
    public static void updateOrderStatus(String status, Boolean hasCometdets_curr, String cometUser_curr,String cometPasword_curr, String customer_curr, String cometJobNo_curr, Order__C Ord, Decimal budRuleNo_curr )
    {
        String currStatus = Ord.Order_Status__c;
        Ord.Order_Status__c = status;
        
        //System.debug('updateOrderStatus-1 status passsed is' +status);
        //System.debug('updateOrderStatus-2 current status is' +currStatus);
        //System.debug('updateOrderStatus-3 ORder' +Ord.Name);
        if (status == INPROCESS)
            SubmitOrdertoComet(hasCometdets_curr, cometUser_curr,cometPasword_curr,customer_curr,cometJobNo_curr, Ord);
        else if ( (status == PENDAPPROVAL) || (status == SUBMITTED) || (status == PENDAPPSHIPMETH)  || (status == PENDAPPMAXORDQTYORAPPREQ) )
        {
            Ord.Order_Submission_Date__c = datetime.now();
            Ord.Order_Status__c = status;
            //update Ord;
            currOrderList.add(Ord);
        }
        
        
        String strOName = Ord.Name;
        if (budRuleNo_curr==1) // This is for MMD
        {
            if ( ((currStatus == OPEN) || (status == PENDAPPSHIPMETH)  || (status == PENDAPPMAXORDQTYORAPPREQ) ) && (status == INPROCESS)) 
            {
                // Adjust Budgets for Inventory Order
                String UserId;
                //UserId = userinfo.getUserId();
                UserId = Ord.CreatedBy.ID;
                Users_Territory__c usrter;
                usrter = [select Territory__c from Users_Territory__c where User__c =: UserId  LIMIT 1];
                String BrandId;
                List<OrderDestination__c> objODList = [Select id,Name FROM OrderDestination__c WHERE Order__c = :Ord.Id];
                for(OrderDestination__c objOD : objODList)
                {
                    List <OrderDestinationItem__c> objODIList = [Select id,POS_Item__r.Item_No__c, Quantity__c FROM OrderDestinationItem__c 
                                                                 WHERE OrderDestination__c = :objOD.Id AND Quantity__c >0];
                    for(OrderDestinationItem__c objODI: objODIList)
                    {
                        POS_Item__c item = [Select ID,Name, Brand__c, Price__c FROM POS_Item__c  Where ID = :objODI.POS_Item__r.id    LIMIT 1];
                        BrandId = item.Brand__c;
                        List<Brand_Territory_Budget__c> budList; 
                        budList = [SELECT ID, Name, Remaining_Budget__c,Utilized_Budget__c FROM Brand_Territory_Budget__c WHERE Territory__c =:usrter.Territory__c AND Brand__c = :BrandId  Limit 1];
                        budList[0].Utilized_Budget__c = budList[0].Utilized_Budget__c+objODI.Quantity__c * item.Price__c;
                        update budList;
                    }  
                }
            }
        }// End of BudgetRule
        
    }
    
    
    public static void SubmitOrdertoComet(Boolean hasCometdets_curr, String cometUser_curr,String cometPasword_curr, String customer_curr, String cometJobNo_curr, Order__c Ord )
    {
        System.debug('IN SubmitOrdertoComet');
        // Submit Order to Comet
        string CurrOrderName='';
        Integer destcnt=0;
        
        String strCustName =customer_curr;//'MMD';//Bogle Vineyards
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        String body = '';
        String resBody ='';
        req.setTimeout(120000);
        
        List<OrderDestination__c> objODList = [Select id,Name ,AddressBook__r.Address__c, AddressBook__r.City__c, AddressBook__r.Country__c, AddressBook__r.Destination_Name__c, AddressBook__r.Email__c,AddressBook__r.Fax__c, AddressBook__r.Phone__c, AddressBook__r.Shipto_Company__c, AddressBook__r.Shipto_Name__c,AddressBook__r.State__c,  AddressBook__r.StateCode__c, AddressBook__r.Zip__c, CreatedBy.name,CreatedBy.email, Shipping_Method__r.Shipping_Method_Name__c, OrderName__c, OrderDest_Status__c FROM OrderDestination__c WHERE Order__c = :ord.Id AND OrderDest_Status__c ='OPEN' ];
        for (Integer a = 0; a< objODList.size(); a++)
        {
            OrderDestination__c objOD;
            objOD = objODList[a];
            String currOrdDestid='';
            if (objOD != null)
                currOrdDestid = objOD.id;
            
            Boolean hasItemsinOrder = false;
            System.debug('currOrdDestid  :'+ currOrdDestid );
            
            body = 'OrderName='+EncodingUtil.urlEncode(objOD.OrderName__c == null ? '': objOD.OrderName__c, 'UTF-8')
                +'&OrderedByFirstName='+EncodingUtil.urlEncode(objOD.CreatedBy.Name == null ? '': objOD.CreatedBy.Name, 'UTF-8')
                +'&ShipToFirstName='+EncodingUtil.urlEncode(objOD.AddressBook__r.Shipto_Name__c == null ? '': objOD.AddressBook__r.Shipto_Name__c, 'UTF-8')
                +'&Address1='+EncodingUtil.urlEncode(objOD.AddressBook__r.Address__c == null ? '': objOD.AddressBook__r.Address__c, 'UTF-8')
                +'&City='+EncodingUtil.urlEncode(objOD.AddressBook__r.City__c == null ? '':objOD.AddressBook__r.City__c, 'UTF-8')
                +'&State='+EncodingUtil.urlEncode(objOD.AddressBook__r.StateCode__c == null ? '':objOD.AddressBook__r.StateCode__c, 'UTF-8')
                +'&Zip='+EncodingUtil.urlEncode(objOD.AddressBook__r.Zip__c == null ? '': objOD.AddressBook__r.Zip__c, 'UTF-8')        
                +'&shipping_instruction='+EncodingUtil.urlEncode(objOD.Shipping_Method__r.Shipping_Method_Name__c == null ? '': objOD.Shipping_Method__r.Shipping_Method_Name__c, 'UTF-8')
                +'&CustName='+EncodingUtil.urlEncode(strCustName == null ? '': strCustName, 'UTF-8');   
            
            
            List <OrderDestinationItem__c> objODIList = [Select id,POS_Item__r.Item_No__c, Quantity__c FROM OrderDestinationItem__c 
                                                         WHERE  ( (OrderDestination__c = :currOrdDestid)  AND (Quantity__c >0) )];
            hasItemsinOrder = false;
            for(OrderDestinationItem__c objODI: objODIList)
            {
                System.debug('Item is '+objODI.POS_Item__r.Item_No__c +' and Quantity is '+objODI.Quantity__c);
                hasItemsinOrder = true;
                body  += '&OrdItmQty='+EncodingUtil.urlEncode(objODI.POS_Item__r.Item_No__c +'#emerge#'+objODI.Quantity__c, 'UTF-8');
                
            }
            try {
                req.setEndpoint('http://bridge.ambood.com/SFOrders/SaveOrder.aspx');
                req.setMethod('POST');
                req.setBody(body); 
                
                res = http.send(req);
                resBody  = res.getBody();
                system.debug('Response from Server : '+resBody);
                objODList[a].OrderDest_Status__c = 'Submitted';
                destcnt++;
            }
            catch (Exception e) {
                system.debug('Unable to Submit Order : '+objOD.OrderName__c +' to Bridge' );
            }
            currOrderDestList.add(objODList[a]);
        }
        
        Ord.Order_Submission_Date__c = datetime.now();
        Ord.Order_Status__c ='Submitted';
        Boolean existingOrder = false;
        for (Integer i = 0; i< currOrderList.size(); i++)
        {
            existingOrder = false;
            string cOrdId=currOrderList[i].id;
            if (cOrdId == Ord.id)
            {
                currOrderList[i].Order_Submission_Date__c= Ord.Order_Submission_Date__c;
                existingOrder = true;
            }
        }
        if (existingOrder == false)
            currOrderList.add(Ord);
    }
    // End of SubmitOrdertoComet function
    
    
    @future(callout=true)
    public static void UpdateTransactionNumbers()
    {
        currOrderList = new List<Order__c>();
        currOrderDestList = new List<OrderDestination__c>();
        List<OrderDestination__c> objODList =new List<OrderDestination__c>();
        
        Integer tranNo=0;
        String strCustName ='';//'MMD';//Bogle Vineyards
        String CurrOrderName ='';
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        String body = '';
        String resBody ='';
        req.setTimeout(120000);
        
        List<Account> objAccountList_curr = [SELECT ID, Name, CometJobNo__c, CometUsername__c, CometPassword__c, hasCometConfiguration__c, BudgetRuleNo__c FROM Account WHERE hasCometConfiguration__c = true ];
        for (Account objAccount: objAccountList_curr)
        {
            if(objAccount.hasCometConfiguration__c == true)
            {
                //System.debug('UpdateWarehouseOrderStatuses-3 Coment Username: '+objAccount.CometUsername__c);
                strCustName =objAccount.Name;
                
                objODList = [Select id,Name ,AddressBook__r.Address__c, AddressBook__r.City__c, AddressBook__r.Country__c, AddressBook__r.Destination_Name__c, AddressBook__r.Email__c,AddressBook__r.Fax__c, AddressBook__r.Phone__c, AddressBook__r.Shipto_Company__c, AddressBook__r.Shipto_Name__c,AddressBook__r.State__c,  AddressBook__r.StateCode__c, AddressBook__r.Zip__c, CreatedBy.name,CreatedBy.email, Shipping_Method__r.Shipping_Method_Name__c, OrderName__c, OrderDest_Status__c FROM OrderDestination__c WHERE ((WarehouseTransactionNo__c =NULL) OR (WarehouseTransactionNo__c ='0')) AND OrderDest_Status__c ='Submitted' AND  (Order__r.Account__c =: objAccount.id) ORDER BY Name DESC LIMIT 50 ];
                for (Integer a = 0; a< objODList.size(); a++)
                {
                    CurrOrderName = objODList[a].OrderName__c;
                    tranNo =0;
                    body = 'OrderName='+EncodingUtil.urlEncode(CurrOrderName  == null ? '': CurrOrderName, 'UTF-8')
                        +'&CustName='+EncodingUtil.urlEncode(strCustName == null ? '': strCustName, 'UTF-8');   
                    
                    try {
                        req.setEndpoint('http://bridge.ambood.com/SFOrders/GetTranNo.aspx');
                        req.setMethod('POST');
                        req.setBody(body); 
                        
                        res = http.send(req);
                        resBody  = res.getBody();
                        system.debug('Response from Server : '+resBody);
                        if (!resBody.Contains('EXCEPTION'))
                        {
                            if (!resBody.Contains('NOSUCHORDER'))
                            {
                                if (resBody.Contains('SUCESS'))
                                {
                                    List<String> parts = resBody.split('#Emerge#');
                                    tranNo= integer.valueof(parts[1]);
                                    objODList[a].WarehouseTransactionNo__c = parts[1];
                                }
                            }
                            else
                            {
                                objODList[a].WarehouseTransactionNo__c = '0';
                            } 
                        }
                        else
                        {
                            objODList[a].WarehouseTransactionNo__c = '0';
                        }
                        
                    } catch (Exception e)
                    {
                        System.debug(' Exception while updating TransactionNo: ' + e);
                    }
                    
                    if(tranNo >0 )
                    {
                        currOrderDestList.add(objODList[a]);
                    }
                }
            }
        }
        
        Update currOrderDestList;
        // Update Order Status in Order Object
        List<Order__c> OrdList = new List<Order__c>();
        OrdList = [SELECT ID, Name, Order_Status__c  from Order__c WHERE (Order_Status__c != 'OPEN') AND (Order_Status__c != 'Submitted') AND (Order_Status__C !='This Order has been processed') AND (Program__C = NULL)  ORDER BY Name DESC Limit 50 ];
        for (Integer a = 0; a< OrdList.size(); a++)
        {
            string cOrdId=OrdList[a].id;
            objODList = [Select id, Name, OrderName__c, OrderDest_Status__c FROM OrderDestination__c WHERE (Order__c =: cOrdId) AND  (OrderDest_Status__c='OPEN')];
            if(objODList.size() == 0 )
                OrdList[a].Order_Status__c= 'Submitted';
        }
        update OrdList;
    }
    // End of Bridge Implementations
    
}