// Authors: Sanjana
// Date: 05-11-2021
// Aim: to fetch the account, list of advance shipment notice, and search advance shipment notice

public class InfiniumGetASNList_Apex {
    //declare a global variable of type sObject Account 
    public static Account objAccount;
    //method to fetch the account details
    public static Account getAccount() { 
        //used by the test classes
        if(Test.isRunningTest())
        {
            objAccount=[SELECT Id, Name FROM Account
                        WHERE Name LIKE '%Infinium Spirits%' LIMIT 1];
        }
        else
        {
            //objAccount=[SELECT Id, Name FROM Account
            // WHERE Lightning_Community_Id__c=:Network.getNetworkId() LIMIT 1];
            objAccount=[SELECT Id, Name FROM Account
                        WHERE Name LIKE '%Infinium Spirits%' LIMIT 1];
        }
        system.debug('objAccount----->'+objAccount);
        return objAccount;
    }
    
    // wrapper class to hold an ASN record with the boolean value 
    public class advanceShipmentNotice_Wrapper{
        //variable of type custom object Advance_Shipment_Notice__c
        @AuraEnabled
        public Advance_Shipment_Notice__c asn;
        // to hold the boolean value to the front end so that the view button is displayed
        // instead of edit button for all the ASN whose emerge status is "submitted"
        @AuraEnabled
        public Boolean emergeOrderStatusButton;
        //calling the constructor of this class with all the variables as parameters
        public advanceShipmentNotice_Wrapper(Advance_Shipment_Notice__c asn,Boolean emergeOrderStatusButton)
        {
            this.asn=asn;
            this.emergeOrderStatusButton=emergeOrderStatusButton;
        }
    }
    
    
    @AuraEnabled(cacheable=true)
    // to fetch the list of advance shipment notice that belong to the account Infinium Spirits and search ASN
    public static List<advanceShipmentNotice_Wrapper> searchASN(String searchKeyword) {
        system.debug('entered---->');
        // variable hold the instance of the wrapper class list of advanceShipmentNotice_Wrapper
        List<advanceShipmentNotice_Wrapper> advanceShipmentNotice = new List<advanceShipmentNotice_Wrapper>();
        //hold account details
        objAccount=getAccount();
        // to fetch the list of ASN in a string
        String query='';
        //  to fetch the list of ASN in a string for a searchKeyword
        String completeQuery='';
        //variable of type list of Advance_Shipment_Notice__c to hold the search result
        List<Advance_Shipment_Notice__c> searchASN_List =new List<Advance_Shipment_Notice__c> ();
        //variable of type list of Advance_Shipment_Notice__c to the list of ASN which belongs to the account Infinium Spirits
        List<Advance_Shipment_Notice__c> ASN_List =new List <Advance_Shipment_Notice__c> ();
        // Set<Id> totalASN_ListIds=new Set<Id> ();
        //    to match the searchKeyword with the ASN name and emerge status
        String whereClauseText = '';
        if(String.isBlank(searchKeyword))
            searchKeyword='';
        //to hold the searchKeyword by removing the spaces
        String tempSearchText='%'+searchKeyword.trim()+'%';
        // to fetch the list of ASN in a string
        query= 'SELECT Id,Account__r.Name,ASN_Comet_Response_On__c,ASN_Comet_Response__c,ASN_Submission_Response_On__c,ASN_Submission_Response__c,CreatedBy.Name,'
            +'CreatedDate,Emerge_Status__c,Expected_Date__c,Name,Package_Count__c,Pallet_Count__c,Purchase_Order_Number__c,Tracking_Number__c,Vendor__c,'
            +'Warehouse_ASN_Id__c,Warehouse_Status__c,Carrier__c FROM Advance_Shipment_Notice__c WHERE Account__c=\''+objAccount.Id+'\' ';
        if(!String.isBlank(searchKeyword))
        {
            tempSearchText=tempSearchText.trim();
            // to match the searchKeyword with the ASN name and emerge status
            whereClauseText = ' AND ((Name LIKE :tempSearchText) OR (Emerge_Status__c  LIKE :tempSearchText)) ';                  
        }
        // to fetch the list of ASN in a string for a searchKeyword
        completeQuery= query+ whereClauseText+'  ORDER BY Name DESC';
        
        //variable of type list of Advance_Shipment_Notice__c to hold the search result
        searchASN_List=Database.query(completeQuery);
        System.debug('searchASN_List'+searchASN_List);
        // for(Advance_Shipment_Notice__c ASN : searchASN_List)
        //     totalASN_ListIds.add(ASN.Id);
        //variable of type list of Advance_Shipment_Notice__c to the list of ASN which belongs to the account Infinium Spirits
        ASN_List = [SELECT Id,Account__r.Name,ASN_Comet_Response_On__c,ASN_Comet_Response__c,ASN_Submission_Response_On__c,ASN_Submission_Response__c,CreatedBy.Name,
                    CreatedDate,Emerge_Status__c,Expected_Date__c,Name,Package_Count__c,Pallet_Count__c,Purchase_Order_Number__c,Tracking_Number__c,Vendor__c,
                    Warehouse_ASN_Id__c,Warehouse_Status__c,Carrier__c FROM Advance_Shipment_Notice__c WHERE Id IN :searchASN_List ORDER BY Name DESC]; 
        // the below code is written to send the boolean value to the front end so that the view button is displayed
        // instead of edit button for all the ASN whose emerge status is "submitted"
        for(Advance_Shipment_Notice__c asn : searchASN_List){
            //                 to hold the boolean value to the front end so that the view button is displayed
            // instead of edit button for all the ASN whose emerge status is "submitted"
            Boolean emergeOrderStatusButton=false;
            
            if(asn.Emerge_Status__c=='Submitted'){
                emergeOrderStatusButton = true;
                advanceShipmentNotice.add(new advanceShipmentNotice_Wrapper(asn,emergeOrderStatusButton));
            }
            else{
                emergeOrderStatusButton = false;
                advanceShipmentNotice.add(new advanceShipmentNotice_Wrapper(asn,emergeOrderStatusButton));
            }
        }
        system.debug('advanceShipmentNotice----->'+advanceShipmentNotice);
        //return the list of asn along with the boolean value for the front end
        
        return advanceShipmentNotice;
    }
    
}