public with sharing class DFVAddressListCmpController {
    public static Account objAccount;
    @AuraEnabled
    public static User currentUser()
    {
        return [SELECT Id FROM User WHERE Id=:UserInfo.getUserId()];
    }
    @AuraEnabled
    public static Account getAccount()
    {
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
    public class AddressBookListWithSizeWrapper
    {
        @AuraEnabled
        public List<AddressBook__c> AddressBookList;
        @AuraEnabled
        public Integer totalAddressBookSize;
        public AddressBookListWithSizeWrapper ( List<AddressBook__c> AddressBookList,Integer totalAddressBookSize)
        {
            this.AddressBookList=AddressBookList;
            this.totalAddressBookSize=totalAddressBookSize;
        }
        
    }
    
    @AuraEnabled
    public static AddressBookListWithSizeWrapper loadAndSearchAddressBook_Apex (String searchKeyword,Integer recordStartIndex)
    {
        objAccount=getAccount();
        Set<Id> userStateIds=new Set<Id> ();
        List<AddressBook__c> addressBookList = new List<AddressBook__c>();
        List<State__c> stateList = new List<State__c>();
        List<States_Territory__c> states = new List<States_Territory__c>();
        List<State__c> stateLists = new List<State__c>();
        List<Territory__c> territoryList = new List<Territory__c>();
        List<AddressBook__c> userTerritoryAddress = new List<AddressBook__c>();
        List<AddressBook__c> userTerritoryAddressList = new List<AddressBook__c>();
        territoryList = [SELECT ID,Territory_Name__c FROM  Territory__c WHERE Active__c=true AND ID IN (SELECT Territory__c FROM Users_Territory__c WHERE User__c=:UserInfo.getUserId())];
        System.debug('territoryList---->'+territoryList.size());
        for(Territory__c territory:territoryList) {
            states = [SELECT State__c FROM States_Territory__c WHERE Territory__c =:territory.Id];
            
            for(States_Territory__c state:states) {
                stateList=  [SELECT State_Code__c, State_Name__c
                             FROM State__c 
                             WHERE ID=:state.State__c
                             ORDER BY State_Name__c];
                stateLists.addAll(stateList);
            }
            
        }
        System.debug('stateLists---->'+stateLists.size());
        System.debug(stateLists);
        String searchText='%'+searchKeyword+'%';
        if(String.isNotBlank(searchText))
        {
            System.debug('searchKeyword--->'+searchText);
            
            addressBookList=[SELECT Id, Name, Account__c, Destination_Name__c, Shipto_Name__c,  
                             Shipto_Company__c, City__c, Email__c, Phone__c, Fax__c, Zip__c, Address__c, 
                             State__r.Id, State__c, State__r.State_Name__c, Active__c FROM AddressBook__c 
                             WHERE Account__c = :objAccount.ID
                             AND (Shipto_Company__c LIKE :searchText OR State__r.State_Name__c LIKE :searchText OR 
                                  Shipto_Name__c LIKE :searchText OR Destination_Name__c LIKE :searchText OR City__c LIKE :searchText)
                             ORDER BY Destination_Name__c ASC];
        }
        else {
            addressBookList=[SELECT Id, Name, Account__c, Destination_Name__c, Shipto_Name__c,  
                             Shipto_Company__c, City__c, Email__c, Phone__c, Fax__c, Zip__c, Address__c, 
                             State__r.Id, State__c, State__r.State_Name__c, Active__c FROM AddressBook__c WHERE Account__c=:objAccount.Id ORDER BY Destination_Name__c ASC];
            
        }
        System.debug('addressBookList--->'+addressBookList);
        System.debug('addressBookList Size--->'+addressBookList.size());
        for(AddressBook__c addressBook : addressBookList) {
            for(State__c state:stateLists) {
                if(state.Id == addressBook.State__c) 
                {
                    userTerritoryAddress.add(addressBook);
                }
            }
        }
        System.debug('userTerritoryAddress---->'+userTerritoryAddress);
        for(Integer i=recordStartIndex==null?0:recordStartIndex;i<=recordStartIndex+99;i++)
        {
            if(i<userTerritoryAddress.size())
                userTerritoryAddressList.add(userTerritoryAddress[i]);
        }
        System.debug('addressBookList-->'+addressBookList);
        return new AddressBookListWithSizeWrapper(userTerritoryAddressList,userTerritoryAddress.size());
    }
    
    
    
    
    
    // Cr Number: DFV-19-Feb-04 Author: Sanjana Date: 20-02-2020
    //To allow the useer to create a address during the order flow
    @AuraEnabled
    // to fetch the list of states for the user
    public static List<State__c> getAllStates() {
        objAccount=getAccount();
        List<States_Territory__c> states = new List<States_Territory__c>();
        List<State__c> stateList = new List<State__c>();
        List<State__c> stateLists = new List<State__c>();
        List<Territory__c> territoryList = new List<Territory__c>();
        territoryList = [SELECT ID,Territory_Name__c FROM  Territory__c WHERE Active__c=true AND ID IN (SELECT Territory__c FROM Users_Territory__c WHERE User__c=:UserInfo.getUserId())];
        for(Territory__c territory:territoryList) {
            states = [SELECT State__c FROM States_Territory__c WHERE Territory__c =:territory.Id];
            
            for(States_Territory__c state:states) {
                stateList=  [SELECT State_Code__c, State_Name__c
                             FROM State__c 
                             WHERE ID=:state.State__c
                             ORDER BY State_Name__c];
                stateLists.addAll(stateList);
            }
            //System.debug('stateList'+stateList);
        }
        stateLists.sort();
        return stateLists;
    }
    @AuraEnabled
    public static List<AddressBook__c> getAddressBookList() {
        objAccount=getAccount();
        Set<Id> userStateIds=new Set<Id> ();
        
        for(States_Territory__c stateTerritory : [SELECT ID, Name, State__c FROM States_Territory__c WHERE Territory__c IN ( SELECT Territory__c FROM Users_Territory__c WHERE User__c =:UserInfo.getUserId())])
            userStateIds.add(stateTerritory.State__c);
        
        
        List<AddressBook__c> addressBookList = new List<AddressBook__c>();
        addressBookList = [SELECT Id, Name, Account__c, Destination_Name__c, Shipto_Name__c,  
                           Shipto_Company__c, City__c, Email__c, Phone__c, Fax__c, Zip__c, Address__c, 
                           State__r.Id, State__c, State__r.State_Name__c, Active__c FROM AddressBook__c WHERE Account__c=:objAccount.Id AND (State__c IN :userStateIds) ORDER BY Destination_Name__c ASC];
        return addressBookList;
        
    }
    
    @AuraEnabled
    public static List<AddressBook__c> addAddressBook(AddressBook__c selectedAddressBook,String searchText) {
        try{
            objAccount=getAccount();
            AddressBook__c addressBook = selectedAddressBook;
            addressBook.Account__c=objAccount.Id;
            upsert addressBook;
        }
        catch(Exception ex){
            DFVEmailNotifications.sendNotification('Add Address',ex.getMessage()+'\n'+'Inputs are -- selectedAddressBook-- '+JSON.serialize(selectedAddressBook)
                                                   +'\n'+'-- searchText-- '+JSON.serialize(searchText)+'\n'+'Class Name - DFVAddressListCmpController '+'-- Line number --'+ex.getLineNumber());
        }
        
        return searchAddressBook(searchText);
    }
    @AuraEnabled
    public static List<AddressBook__c> deactivateAddressBookApex(AddressBook__c selectedAddressBook,String searchText) {
        try {
            
            objAccount=getAccount();
            AddressBook__c addressBook = selectedAddressBook;
            addressBook.Active__c=false;
            update addressBook;
        }
        catch(Exception ex) {
            DFVEmailNotifications.sendNotification('Deactivate Address',ex.getMessage()+'\n'+'Inputs are -- selectedAddressBook-- '+JSON.serialize(selectedAddressBook)
                                                   +'\n'+'-- searchText-- '+JSON.serialize(searchText)+'\n'+'Class Name - DFVAddressListCmpController '+'-- Line number --'+ex.getLineNumber());
        }
        return searchAddressBook(searchText);
    }
    @AuraEnabled
    public static List<AddressBook__c> searchAddressBook(String searchText)
    {
        objAccount=getAccount();
        Set<Id> userStateIds=new Set<Id> ();
        List<AddressBook__c> addressBookList=new List<AddressBook__c> ();
        if(String.isBlank(searchText))
            addressBookList=getAddressBookList();
        else
        {
            for(States_Territory__c stateTerritory : [SELECT ID, Name, State__c FROM States_Territory__c WHERE Territory__c IN ( SELECT Territory__c FROM Users_Territory__c WHERE User__c =:UserInfo.getUserId())])
                userStateIds.add(stateTerritory.State__c);
            
            String searchKeyword='%'+searchText+'%';
            // System.debug(searchKeyword);
            addressBookList=[SELECT Id, Name, Account__c, Destination_Name__c, Shipto_Name__c,  
                             Shipto_Company__c, City__c, Email__c, Phone__c, Fax__c, Zip__c, Address__c, 
                             State__r.Id, State__c, State__r.State_Name__c, Active__c FROM AddressBook__c 
                             WHERE Account__C = :objAccount.ID AND (State__c IN :userStateIds) 
                             AND (Shipto_Company__c LIKE :searchKeyword OR State__r.State_Name__c LIKE :searchKeyword OR Shipto_Name__c LIKE :searchKeyword OR Destination_Name__c LIKE :searchKeyword OR City__c LIKE :searchKeyword) ORDER BY Destination_Name__c ASC];
            // System.debug(addressBookList.size());
        }
        return addressBookList;
    }
    @AuraEnabled
    
    public static String synchronizeAddressBookApex()
    {
        System.debug('entered');
        objAccount=getAccount();
        List<AddressBook__c> addressesList=new List<AddressBook__c> ();
        Map<Id,List<Users_Territory__c>> stateIdWithUTList=new Map<Id,List<Users_Territory__c>> ();
        Set<Id> allStateIds=new Set<Id> ();
        Map<Id,Set<Id>> territoryIdWithStateIds=new Map<Id,Set<Id>> ();
        // Get List of all Addresses need to be synchronized
        if (objAccount  != null)
            addressesList = [SELECT id, name, Destination_Name__c, Shipto_Company__c, Shipto_Name__c, State__c, State__r.State_Name__c, Address__c, Division__r.Territory_Name__c, Active__c, City__c, Zip__c, Email__c, Phone__c, Fax__c, State__r.State_Code__c, Needs_to_be_synchronised__c FROM AddressBook__c WHERE Account__C = :objAccount.ID AND Active__c= True AND Needs_to_be_synchronised__c= True LIMIT 100];
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String body = '';
        HttpResponse res = new HttpResponse();
        
        String resBody ='';
        
        
        String strMessage='';
        String strUsername='';
        String strFirstName='';
        String strLastName='';
        List<User> usersAvailable = new List<User>();
        List<Territory__c> terrList = new List<Territory__c>();
        List<AddressBook__c> addrList = new List<AddressBook__c>();
        List<State__c> states = new List<State__c>();
        states = [select ID,Name, State_Code__c from State__c];
        
        List<Users_Territory__c> utList = new List<Users_Territory__c>();
        Map<string, List<String>> mapStateUsers;        
        mapStateUsers  = new Map<string, List<String>>();
        
        Map<string, string> mapStateUserFirstName;        
        mapStateUserFirstName  = new Map<string, string>();
        Map<string, string> mapStateUserLastName;        
        mapStateUserLastName  = new Map<string, string>();
        
        List<String> sfusernames = new List<String>();
        
        
        // Get List of all users for which Address need to be synchronized
        if (objAccount  != null)
            usersAvailable = [SELECT ID, Email, Username, FirstName, LastName  FROM User usr WHERE usr.AccountId =: objAccount.ID];
        if(Test.isRunningTest()) 
            usersAvailable = [SELECT ID, Email, Username, FirstName, LastName  FROM User usr WHERE usr.Email='standarduser@testorg.com'];
        
        for (Integer i = 0; i< usersAvailable.size(); i++)
        {
            mapStateUserFirstName.put(usersAvailable[i].Username, usersAvailable[i].FirstName);
            mapStateUserLastName.put(usersAvailable[i].Username, usersAvailable[i].LastName);
        }
        
        List<string> usersEmails = new List<string>();
        
        if (objAccount  != null)
        {
            for (Integer i = 0; i< states.size(); i++)
            {
                usersEmails = new List<string>();
                utList = [ SELECT User__c, User__r.email, User__r.UserName, User__r.FirstName, User__r.LastName FROM Users_Territory__c WHERE (Territory__r.Account__C =:objAccount.ID ) AND Territory__c IN (SELECT Territory__c FROM States_Territory__c WHERE State__C =: states[i].id)];
                for (Integer j = 0; j< utList.size(); j++)
                {
                    usersEmails.add(utList[j].User__r.UserName+'#emerge#'+utList[j].User__r.FirstName+'#emerge#'+utList[j].User__r.LastName);
                }
                if (usersEmails.size() >0 )
                {
                    mapStateUsers.put(states[i].State_Code__C, usersEmails);
                }
            }
        }
        
        
        
        
        // Get List of first 50 Addresses that needs to be synchronized
        if (objAccount  != null)
            addressesList = [SELECT id, name, Destination_Name__c, Shipto_Company__c, Shipto_Name__c, State__c, State__r.State_Name__c, Address__c, Division__r.Territory_Name__c, Active__c, City__c, Zip__c, Email__c, Phone__c, Fax__c, State__r.State_Code__c, Needs_to_be_synchronised__c, ShipToFirstName__c, ShipToLastName__c from AddressBook__c WHERE Account__C = :objAccount.ID AND Active__c=True AND Needs_to_be_synchronised__c= True LIMIT 100];
        
        System.debug(addressesList);
        for (Integer a = 0; a< addressesList.size(); a++)
        {
            if(mapStateUsers.get(addressesList[a].State__r.State_Code__c) != null)
                strMessage += addressesList[a].State__r.State_Code__c+' has  ' +mapStateUsers.get(addressesList[a].State__r.State_Code__c).size()+ ' no of users +<br/> ';
            
            req = new HttpRequest();
            res = new HttpResponse();
            req.setTimeout(120000);
            
            body = 'Destination_Name='+EncodingUtil.urlEncode(addressesList[a].Destination_Name__c == null ? '': addressesList[a].Destination_Name__c, 'UTF-8')
                +'&ShipToName='+EncodingUtil.urlEncode(addressesList[a].Shipto_Name__c == null ? '': addressesList[a].Shipto_Name__c, 'UTF-8')
                +'&ShipToCompany='+EncodingUtil.urlEncode(addressesList[a].Shipto_Company__c == null ? '': addressesList[a].Shipto_Company__c, 'UTF-8')
                +'&Address='+EncodingUtil.urlEncode(addressesList[a].Address__c == null ? '':addressesList[a].Address__c, 'UTF-8')
                +'&City='+EncodingUtil.urlEncode(addressesList[a].City__c == null ? '':addressesList[a].City__c, 'UTF-8')
                +'&State='+EncodingUtil.urlEncode(addressesList[a].State__r.State_Name__c == null ? '':addressesList[a].State__r.State_Name__c, 'UTF-8')
                +'&Zip='+EncodingUtil.urlEncode(addressesList[a].Zip__c == null ? '': addressesList[a].Zip__c, 'UTF-8')        
                +'&Email='+EncodingUtil.urlEncode(addressesList[a].Email__c == null ? '': addressesList[a].Email__c, 'UTF-8')
                +'&Phone='+EncodingUtil.urlEncode(addressesList[a].Phone__c  == null ? '': addressesList[a].Phone__c, 'UTF-8')
                +'&Fax__c='+EncodingUtil.urlEncode(addressesList[a].Fax__c  == null ? '': addressesList[a].Fax__c, 'UTF-8')
                +'&Emerge_address_id='+EncodingUtil.urlEncode(addressesList[a].Name == null ? '':addressesList[a].Name , 'UTF-8')
                +'&ShipToFirstName='+EncodingUtil.urlEncode(addressesList[a].ShipToFirstName__c == null ? '':addressesList[a].ShipToFirstName__c , 'UTF-8')
                +'&ShipToLastName='+EncodingUtil.urlEncode(addressesList[a].ShipToLastName__c == null ? '':addressesList[a].ShipToLastName__c , 'UTF-8')
                +'&salesforce_record_id='+EncodingUtil.urlEncode(addressesList[a].id == null ? '':addressesList[a].id , 'UTF-8');
            sfusernames = mapStateUsers.get(addressesList[a].State__r.State_Code__C);
            if (sfusernames != NULL)
            {
                for (Integer k = 0; k< sfusernames.size(); k++)
                    body  += '&EmergeLoginUserName[]='+EncodingUtil.urlEncode(sfusernames[k], 'UTF-8');
                req.setEndpoint('https://www.smwepod.com/smweAddressUpload.php');
                req.setMethod('POST');
                req.setBody(body);  
                
                if(!Test.isRunningTest())          
                    res = http.send(req);
                resBody  = res.getBody();
                strMessage += resBody+'<br/><br/>';
                
                if ( resBody.contains('inserted successfully'))
                {
                    addressesList[a].Needs_to_be_synchronised__c = False;
                }
                if ( resBody.contains('Updated successfully'))
                {
                    addressesList[a].Needs_to_be_synchronised__c = False;
                }
            }
        }
        Update addressesList;
        
        return 'Synchronized';
    }
}