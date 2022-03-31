@isTest
public with sharing class WilsonASNPOSItemsList_ApexTest 
{
    @isTest
    private static void testController ()
    {
        Account acct = new Account(Name='Wilson Daniels');
        insert acct ;
        
        Daily_Inventory_Creation__c customSetting=new Daily_Inventory_Creation__c(Trigger_Active_Flag__c=true,Name='Trigger flag');
        insert customSetting;
        
        Wilson_Daniel_Email_Notifications__c WilsonDanielCustomSetting=new Wilson_Daniel_Email_Notifications__c(Name='WILSON',Cc_Addresses_List__c='thanvi@uxltechnologies.net');
        insert WilsonDanielCustomSetting;
        
        Brand__c brand = new Brand__c (Brand_Name__c='testBrandName',Active__c=true,Account__c=acct.Id);
        insert brand;
        
        Item_Type__c itemType= new Item_Type__c(Item_Type__c='testItemTypeName',Active__c=true,Account__c=acct.Id);
        insert itemType;
        
        POS_Item__c posItem= new POS_Item__c (Item_No__c='Test-No-01',Item_Name__c='testPosItemName',Available_Stock__c=0,Account__c=acct.Id,Brand__c=brand.Id,Type_of_Item__c=itemType.Id);
        insert posItem;
        
        Test.startTest();
        Advance_Shipment_Notice__c asnData = new Advance_Shipment_Notice__c(Account__c=acct.Id,Emerge_Status__c='Not Submitted',Expected_Date__c=System.now().addDays(5));
        insert asnData;
        ASN_POS_Item__c aSNPOSItem = new ASN_POS_Item__c(Quantity__c=1 ,POS_Item__c=posItem.Id,Advance_Shipment_Notice__c=asnData.Id);
        insert aSNPOSItem; 
        /** WilsonGetAdvanceShipmentNoticeList_Apex **/
        WilsonGetAdvanceShipmentNoticeList_Apex.getAccount();
        WilsonGetAdvanceShipmentNoticeList_Apex.searchASN(''); 
        WilsonGetAdvanceShipmentNoticeList_Apex.searchASN('Submitted');
        /** WilsonHandleASNPOSItemsList_Apex **/
        WilsonHandleASNPOSItemsList_Apex.getAccount();
        WilsonHandleASNPOSItemsList_Apex.saveAdvanceShipmentNotice(new Advance_Shipment_Notice__c(Account__c=acct.Id , Expected_Date__c=System.now().addDays(5), Emerge_Status__c='asnEmergeStatus')
                                                                   ,new List<ASN_POS_Item__c> {aSNPOSItem}, 'SAVE');
        WilsonHandleASNPOSItemsList_Apex.saveAdvanceShipmentNotice(new Advance_Shipment_Notice__c(Account__c=acct.Id , Expected_Date__c=System.now().addDays(5), Emerge_Status__c='asnEmergeStatus')
                                                                   ,new List<ASN_POS_Item__c> {aSNPOSItem}, 'SAVE_AND_SUBMIT');
        List<WilsonGetAdvanceShipmentNoticeList_Apex.advanceShipmentNotice_Wrapper> asnList = WilsonGetAdvanceShipmentNoticeList_Apex.searchASN(''); 
        System.debug('asnList test-->'+asnList[0].asn.Id);
        WilsonHandleASNPOSItemsList_Apex.loadPosItemList(asnList[0].asn.Id);
        WilsonHandleASNPOSItemsList_Apex.loadPosItemList(null);
        //exceptions
        WilsonHandleASNPOSItemsList_Apex.saveAdvanceShipmentNotice(new Advance_Shipment_Notice__c(Account__c=acct.Id , Expected_Date__c=null, Emerge_Status__c='asnEmergeStatus')
                                                                   ,new List<ASN_POS_Item__c> {aSNPOSItem}, 'SAVE');
        /** WilsonGetSubmittedASNList_Apex**/
        WilsonGetSubmittedASNList_Apex.getAccount();
        List<WilsonGetAdvanceShipmentNoticeList_Apex.advanceShipmentNotice_Wrapper> asnDetails = WilsonGetAdvanceShipmentNoticeList_Apex.searchASN(''); 
        System.debug('asnList test-->'+asnDetails[0].asn.Id);
        WilsonGetSubmittedASNList_Apex.getSubmittedASNPosItemsList(asnDetails[0].asn.Id); 
        
        
        Test.stopTest();
        
    }
}