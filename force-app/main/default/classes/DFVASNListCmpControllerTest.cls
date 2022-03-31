@isTest
public class DFVASNListCmpControllerTest {
     @isTest
    private static void testController ()
    {
        Account acct = new Account(Name='DFV');
        insert acct ;
        
        Daily_Inventory_Creation__c customSetting=new Daily_Inventory_Creation__c(Trigger_Active_Flag__c=true,Name='Trigger flag');
        insert customSetting;
        
        DFV_Email_Notifications__c DFVCustomSetting=new DFV_Email_Notifications__c(Name='DFV',Cc_Addresses_List__c='Pradeep@uxltechnologies.net');
        insert DFVCustomSetting;
        
        Brand__c brand = new Brand__c (Brand_Name__c='testBrandName',Active__c=true,Account__c=acct.Id);
        insert brand;
        
        Item_Type__c itemType= new Item_Type__c(Item_Type__c='testItemTypeName',Active__c=true,Account__c=acct.Id);
        insert itemType;
        
       
        
        POS_Item__c posItem= new POS_Item__c (Item_No__c='Test-No-01',Item_Name__c='testPosItemName',Available_Stock__c=0,Account__c=acct.Id,Brand__c=brand.Id,Type_of_Item__c=itemType.Id);
        insert posItem;
        
        Test.startTest();
        ASN_POS_Item__c aSNPOSItem = new ASN_POS_Item__c(Quantity__c=1 ,POS_Item__c=posItem.Id);
        DFVASNListCmpController.searchPosItems('Test-No-01',new List<POS_Item__c>{posItem});
        
        DFVASNListCmpController.getUnSelected_PosItemsList();
         DFVASNListCmpController.searchASN('asnEmergeStatus');
        DFVASNListCmpController.saveAdvanceShipmentNotice(new Advance_Shipment_Notice__c(Account__c=acct.Id , Expected_Date__c=System.now().addDays(5), Emerge_Status__c='asnEmergeStatus')
                                                                       ,new List<ASN_POS_Item__c> {aSNPOSItem}, 'SAVE');
        
        DFVASNListCmpController.getUnSavedASN_PosItemsList();
        
        DFVASNListCmpController.saveAdvanceShipmentNotice(new Advance_Shipment_Notice__c(Account__c=acct.Id , Expected_Date__c=System.now().addDays(5), Emerge_Status__c='asnEmergeStatus')
                                                                       ,new List<ASN_POS_Item__c> {aSNPOSItem}, 'SAVE_AND_SUBMIT');
        
        DFVASNListCmpController.loadPosItemList(DFVASNListCmpController.getAdvanceShipmentList()[0].Id);
        DFVASNListCmpController.loadPosItemList(null);
        DFVASNListCmpController.getSubmittedASNPosItemsList(null);
        DFVASNListCmpController.searchASN('mion');
        //exception cases
        DFVASNListCmpController.saveAdvanceShipmentNotice(new Advance_Shipment_Notice__c(Account__c=acct.Id , Expected_Date__c=null, Emerge_Status__c='asnEmergeStatus')
                                                                       ,new List<ASN_POS_Item__c> {aSNPOSItem}, 'SAVE');
        DFVASNListCmpController.searchPosItems(null,new List<POS_Item__c>{posItem});
        
        Test.stopTest();
    }

}