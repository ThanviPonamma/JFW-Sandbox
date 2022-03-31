public with sharing class dfvOrderSummaryExportCSV {
    public class ContactWrapper{  
        @AuraEnabled 
        public string contactName;  
        @AuraEnabled  
        public string contactEmail;  
        public ContactWrapper(OrderDestinationItem__c contactObj){  
          this.contactName = contactObj.OrderDestination__r.ProgramName__c;  
          this.contactEmail = contactObj.POS_Item__r.Brand__r.Brand_Name__c;  
        }  
      }  
      @AuraEnabled  (cacheable=true)
      public static List<ContactWrapper> getContacts(string programId, string userId){  
        List<ContactWrapper> contactWrapperList = new List<ContactWrapper>();  
        for(OrderDestinationItem__c cwObj :
        [SELECT OrderDestination__r.ProgramName__c,
                                                 POS_Item__r.Brand__r.Brand_Name__c,
                                                OrderDestination__r.OrderName__c,
                                                OrderDestination__r.User__c,
                                                 POS_Item__r.Vendor__c,
                                                 POS_Item__r.Type_of_Item__r.Item_Type__c,
                                                 POS_Item__r.Item_No__c,
                                                POSItemName__c,
                                                 POS_Item__r.Item_Descrption__c,
                                                POS_Item__r.Pack_Of__c,
                                                 Quantity__c,
                                                 POS_Item__r.Price__c,
                                                 Total_Line_Amount__c,
                                                 OrderDestination__r.ShipToName__c,
                                                 OrderDestination__r.ShipToCompany__c,
                                                 OrderDestination__r.AddressBook__r.Address__c,
                                                 OrderDestination__r.ShipToCity__c,
                                                 OrderDestination__r.AddressBook__r.StateCode__c,
                                                 OrderDestination__r.AddressBook__r.Zip__c,
                                                 OrderDestination__r.AddressBook__r.Phone__c,
                                                 OrderDestination__r.AddressBook__r.Email__c,
                                                OrderDestination__r.OrdStatus__c,
                                                CreatedDate
                                                FROM OrderDestinationItem__c 
                                                WHERE ( (OrderDestination__r.Order__r.Program__c = :programId) AND 
                                                        (CreatedBy.Id = :userId) AND
                                                        (OrderDestination__r.OrdStatus__c != 'OPEN') )] ){  
          contactWrapperList.add(new ContactWrapper(cwObj));  
        }  
        return contactWrapperList;  
      }  
}