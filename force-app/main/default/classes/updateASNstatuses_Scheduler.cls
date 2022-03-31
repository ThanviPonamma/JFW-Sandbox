/***
Class Name : updateASNstatuses_Scheduler 
Version : 001
Author : Pradeep Kumar
Description : this is used to schedule the updateAdvanceShipmentNoticeStatuses every 30 mins.
***/
global class updateASNstatuses_Scheduler implements Schedulable
{
    global String ASN_Query ;
    global Integer batchSize;
    
    /**
Method: updateASNstatuses_Scheduler
Purpose: this constructor is giving dynamic query and size of the batch
Parameters: records are processed here based on query.
Returns: none
*/
    
    global updateASNstatuses_Scheduler(String ASN_Query,Integer batchSize)
    {
        this.ASN_Query =ASN_Query ;
        this.batchSize=batchSize;
    }
    
    /**
Method: execute
Purpose: this method is used to execute the batch class.
Parameters: sc interface
Returns: none
*/
    
    global void execute(SchedulableContext sc)
    {
        /***
Database.executeBatch(new updateAdvanceShipmentNoticeStatuses('SELECT Id,Emerge_Status__c,Account__r.Comet_API_Key__c,Warehouse_Status__c,Warehouse_ASN_Id__c,Account__r.Warehouse_Code__c FROM Advance_Shipment_Notice__c WHERE Account__r.Warehouse_Code__c!=NULL AND Account__r.Warehouse_Code__c!=\'\' AND Emerge_Status__c=\'Submitted\' AND Warehouse_Status__c!=\'Cancelled\'  AND Warehouse_Status__c!=\'Delivered \'  AND Warehouse_Status__c!=\'Open\'  AND  Warehouse_Status__c!=\'Failed to submit to warehouse\' AND   Warehouse_ASN_Id__c!=\'\'') ,10);
Query must be like this 'SELECT Id,Emerge_Status__c,Account__r.Comet_API_Key__c,Warehouse_Status__c,Warehouse_ASN_Id__c,Account__r.Warehouse_Code__c FROM Advance_Shipment_Notice__c WHERE Account__r.Warehouse_Code__c!=NULL AND Account__r.Warehouse_Code__c!=\'\' AND Emerge_Status__c=\'Submitted\' AND Warehouse_Status__c!=\'Cancelled\'  AND Warehouse_Status__c!=\'Delivered \'  AND Warehouse_Status__c!=\'Open\'  AND  Warehouse_Status__c!=\'Failed to submit to warehouse\' AND   Warehouse_ASN_Id__c!=\'\'';
****/
        Database.executeBatch(new updateAdvanceShipmentNoticeStatuses(ASN_Query),batchSize);
    }
}