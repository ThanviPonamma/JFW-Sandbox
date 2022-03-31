/**Author : Sanjana; Date : 21-09-2021

* Aim : To fetch address details,get all states,deactivate the address and add/update and address*/

public with sharing class InfiniumManageAddressBook_Apex
{
    //global variable to hold the account details
    public static Account objAccount;
    //global variable to hold the state ids 
    Set<String> stateIds = new Set<String>();
    //Aim: To get the details of current user
    @AuraEnabled
    public static User currentUser()
    {
        //fetch Id from the user sObject -0050v000003vKsv
        return [SELECT Id FROM User WHERE Id=:UserInfo.getUserId()];
    }

    @AuraEnabled(cacheable=true)
    public static String getProfile(){
       Id profileId = userinfo.getProfileId();
       String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
       return profileName;
    }

    //Aim; to get the account details
    @AuraEnabled
    public static Account getAccount()
    {
        //used by the test classes
        if(Test.isRunningTest())
        {
            //fetch Id, name from the account sObject
            objAccount=[SELECT Id, Name FROM Account
                        WHERE Name LIKE '%Infinium Spirits%' LIMIT 1];
        }
        else
        {
            objAccount=[SELECT Id, Name FROM Account
                        WHERE Lightning_Community_Id__c=:Network.getNetworkId() LIMIT 1];
        }
        return objAccount;
    }
    //Aim : wrapper class to hold variables of type list of AddressBook__c and Integer
    public class AddressBookListWithSizeWrapper
    {
        //variable of type List of AddressBook__c to hold the list of address book
        @AuraEnabled
        public List<AddressBook__c> AddressBookList;
        //variable of type Integer to hold the total size of the address book
        @AuraEnabled
        public Integer totalAddressBookSize;
        public AddressBookListWithSizeWrapper ( List<AddressBook__c> AddressBookList,Integer totalAddressBookSize)
        {
            this.AddressBookList=AddressBookList;
            this.totalAddressBookSize=totalAddressBookSize;
        }
        
    }
    //To get list of address for the logged in user based on search with pagination.
    @AuraEnabled(cacheable=true)
    public static AddressBookListWithSizeWrapper loadAddressBookListWithSearch (String searchKeyword,Integer recordStartIndex)
    {
        //to hold account details
        objAccount=getAccount();
        //to hold user Ids
        Set<Id> userStateIds=new Set<Id> ();
        //variable of type list of the sObject AddressBook__c to hold the list of addresses
        List<AddressBook__c> addressBookList = new List<AddressBook__c>();
        //variable of type List of custom object to hold the list of states
        List<State__c> stateList = new List<State__c>();
        //variable of type list of state territories to hold the list of states from the custom object state territories
        List<States_Territory__c> states = new List<States_Territory__c>();
        //variable of type List of custom object to hold the list of states
        List<State__c> stateLists = new List<State__c>();
        //variable of type list of custom object territories to hold the list of territories
        List<Territory__c> territoryList = new List<Territory__c>();
        //to hold the list of addresses of the user
        List<AddressBook__c> userTerritoryAddress = new List<AddressBook__c>();
        //to hold the list of addresses of the user
        List<AddressBook__c> userTerritoryAddressList = new List<AddressBook__c>();
        //fetch the list of Id and territory name from the custom object territory
        territoryList = [SELECT ID,Territory_Name__c FROM  Territory__c WHERE Active__c=true AND ID IN (SELECT Territory__c FROM Users_Territory__c WHERE User__c=:UserInfo.getUserId())];
        // territoryList = [SELECT ID,Territory_Name__c FROM  Territory__c WHERE Active__c=true AND ID IN (SELECT Territory__c FROM Users_Territory__c WHERE User__c='0050v000003tPtD')];
        System.debug('territoryList---->'+territoryList.size());
        //for all the territories
        for(Territory__c territory:territoryList) {
            //fetch the list of states from state territories
            states = [SELECT State__c FROM States_Territory__c WHERE Territory__c =:territory.Id];
            //for all the state territories, fetch the state code and state name from the sObject state
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
        //string to hold search text entered by the user
        String searchText='%'+searchKeyword+'%';
        //if searchText is not blank
        if(String.isNotBlank(searchKeyword))
        {
            System.debug('searchKeyword--->'+searchText);
            //fetch the address list whose ship to company, state, ship to name, destination name or the city that matches the searched text
            addressBookList=[SELECT Id, Name, Account__c, Destination_Name__c, Shipto_Name__c,  
                             Shipto_Company__c, City__c, Email__c, Phone__c, Fax__c, Zip__c, Address__c, 
                             State__r.Id, State__c, State__r.State_Name__c, Active__c FROM AddressBook__c 
                             WHERE Account__c = :objAccount.ID
                             AND (Shipto_Company__c LIKE :searchText OR State__r.State_Name__c LIKE :searchText OR 
                                  Shipto_Name__c LIKE :searchText OR Destination_Name__c LIKE :searchText OR City__c LIKE :searchText)
                             ORDER BY Destination_Name__c ASC];
        }
        else {
            //if the searchText is blank, fetch all the addresses from custom object Address book
            addressBookList=[SELECT Id, Name, Account__c, Destination_Name__c, Shipto_Name__c,  
                             Shipto_Company__c, City__c, Email__c, Phone__c, Fax__c, Zip__c, Address__c, 
                             State__r.Id, State__c, State__r.State_Name__c, Active__c FROM AddressBook__c 
                             WHERE Account__c=:objAccount.Id ORDER BY Destination_Name__c ASC];
            
        }
        System.debug('addressBookList--->'+addressBookList);
        System.debug('addressBookList Size--->'+addressBookList.size());
        //for all the address book fetch above
        for(AddressBook__c addressBook : addressBookList) {
            //for all the states fetched
            for(State__c state:stateLists) {
                //compare the state in the object State__c and the state in the object address book
                if(state.Id == addressBook.State__c) 
                {
                    //add the list of addressbook to a variable userTerritoryAddress
                    userTerritoryAddress.add(addressBook);
                }
            }
        }
        System.debug('userTerritoryAddress---->'+userTerritoryAddress);
        //fetch the first 100 addresses to display for a page and store it in the variable userTerritoryAddressList
        for(Integer i=recordStartIndex==null?0:recordStartIndex;i<=recordStartIndex+99;i++)
        {
            
            if(i<userTerritoryAddress.size())
                userTerritoryAddressList.add(userTerritoryAddress[i]);
        }
        System.debug('addressBookList-->'+userTerritoryAddressList);
        System.debug('addressBookList-->'+userTerritoryAddress.size());
        //give the address book list and the total address book size to the wrapper class AddressBookListWithSizeWrapper
        return new AddressBookListWithSizeWrapper(userTerritoryAddressList,userTerritoryAddress.size());
        
    }
    //To deactivate the selected address.
    @AuraEnabled
    public static String deactivateAddressBook(AddressBook__c selectedAddressBook) {
        try { 
            //hold the address book in a variable of type custom object AddressBook__c
            AddressBook__c addressBook = selectedAddressBook;
            System.debug('SelecteAddress--->'+addressBook);
            //deactivate the selected addressbook by assigning the value "false" to the address book
            addressBook.Active__c=false;
            //update the address book record
            update addressBook;
        }
        catch(Exception ex) {
            //send the email notification with the error description incase of an exception
            InfiniumEmailNotifications.sendNotification('Deactivate Address',ex.getMessage()+'\n'+
            'Inputs are -- selectedAddressBook-- '+JSON.serialize(selectedAddressBook) +'Class Name - InfiniumManageAddressBook_Apex '+'-- Line number --'+ex.getLineNumber());        }
        return 'Done';
    }
    
    //To allow the useer to create a address during the order flow
    @AuraEnabled(cacheable=true)
    // to fetch the list of states for the user
    public static List<State__c> getAllStates() {
        //variable of type List of state territories to hold the list of states from the custom object States_Territory__c
        List<States_Territory__c> states = new List<States_Territory__c>();
        //variable of type List of custom object State__c to hold the details of the state
        List<State__c> stateList = new List<State__c>();
        //variable of type List of custom object State__c to hold the details of the multiple state records
        List<State__c> stateLists = new List<State__c>();
        //variable of type List of Territory__c to fetch the details of the territory for the logged in user
        List<Territory__c> territoryList = new List<Territory__c>();
        // fetch the list of Id and territory name from the custom object territory
        territoryList = [SELECT ID,Territory_Name__c FROM  Territory__c WHERE Active__c=true AND ID IN (SELECT Territory__c FROM Users_Territory__c WHERE User__c=:UserInfo.getUserId())];
        //for all the territory
        for(Territory__c territory:territoryList) {
            //fetch the states from state territories
            states = [SELECT State__c FROM States_Territory__c WHERE Territory__c =:territory.Id];
            //for all the state from state territories
            for(States_Territory__c state:states) {
                //fetch all the details of the states from the object state
                stateList=  [SELECT State_Code__c, State_Name__c
                             FROM State__c 
                             WHERE ID=:state.State__c
                             ORDER BY State_Name__c];
                
                stateLists.addAll(stateList);
            }
            //System.debug('stateList'+stateList);
        }
        //sort the list of states
        stateLists.sort();
        System.debug('stateList'+stateLists);
        //return the state list
        return stateLists;
    }
    //to update the address book with selected address book
    @AuraEnabled
    public static String updateAddressBook(AddressBook__c selectedAddressBook) 
    {
        try
        {
            //to hold the account details
            objAccount=getAccount();
            //hold the address book in a variable of type custom object AddressBook__c
            AddressBook__c addressBook = selectedAddressBook;
            //to assign the account field in the address book with the current account
            addressBook.Account__c=objAccount.Id;
            System.debug('Selected Address Book---->'+addressBook);
            //update the address book record
            upsert addressBook;
        }
        catch(Exception ex)
        {
            //send the email notification with the error description incase of an exception
            InfiniumEmailNotifications.sendNotification('Add Address',ex.getMessage()+'\n'+
            'Inputs are -- selectedAddressBook-- '+JSON.serialize(selectedAddressBook) +'Class Name - InfiniumManageAddressBook_Apex '+'-- Line number --'+ex.getLineNumber());
        }
        
        return 'Done';
    }
    //Aim : To synchronise newly added addresses to the Pod site on click of 'Synchronise all addresses' button 
    @AuraEnabled
    public static String synchronizeAddressBook()
    {
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        System.debug('entered');
         //To hold the account details
        objAccount=getAccount();
        //instance of sObject AddressBook__c
        List<AddressBook__c> addressesList=new List<AddressBook__c> ();
        //instance of all state Ids, Set<Id> is an unordred collection that doesnot contain duplicate values.
        Set<Id> allStateIds=new Set<Id> ();
        //Instantiate a new HTTP request 
        Http http = new Http();
        //instance of HttpRequest
        HttpRequest req = new HttpRequest();
        //responsible to hold the request body
        String body = '';
        //Instantiate a new HTTP response 
        HttpResponse res = new HttpResponse();
        //responsible to hold the response body
        String resBody ='';
        //responsible to hold a message which says the number users for an address.
        String strMessage='';
        //responsible to hold user name
        //String strUsername='';
        
        //responsible to hold user first name
        String strFirstName='';
        
        //responsible to hold user last name
        String strLastName='';
     
        //instance of sObject User of type list
        // List<User> usersAvailable = new List<User>();
        
        //instance of sObject Territory__c of type list
        // List<Territory__c> terrList = new List<Territory__c>();
        
        //instance of sObject AddressBook__c of type list
        // List<AddressBook__c> addrList = new List<AddressBook__c>();
     
        //instance of sObject State__c of type list
        List<State__c> states = new List<State__c>();
        
        //instance of sObject Users_Territory__c of type list
        List<Users_Territory__c> utList = new List<Users_Territory__c>();
        
        //responsible to hold state code with user emails.
        Map<string, List<String>> mapStateUsers;        
        mapStateUsers  = new Map<string, List<String>>();
     
     
        //instance of type list that holds string elements that holds user names
        List<String> sfusernames = new List<String>();
        
        //holds the list of Id,Name and state code from the table State__c
        //temporary fix---> decided to filter the state based on country US
        //Reason - to address governer limit issue
        //fetch states for the country US
        states = [SELECT ID,Name, State_Code__c FROM State__c WHERE Country__c= :'a036g00000B4uHW'];
        System.debug('states----->'+states);
         //instance of type list that holds user email elements of type string.
        List<string> usersEmails = new List<string>();
     
        //if account exists
        if (objAccount  != null)
        {
            //for all the number of states obtained
            for (Integer i = 0; i< states.size(); i++)
            {
                
                usersEmails = new List<string>();
                
                //responsible to hold user details from Users_Territory__c table where the territory is present in state territory for the incoming 
                //state and the account belongs to Smwe
                
                
                
                //reducing the number of users in utList to enable the transfer of addresses from POS site to POD site as a temporary measure. 
                //utList = [ SELECT User__c, User__r.email, User__r.UserName, User__r.FirstName, User__r.LastName FROM Users_Territory__c
                        //  WHERE (Territory__r.Account__C =:objAccount.ID ) AND Territory__c IN (SELECT Territory__c FROM States_Territory__c WHERE State__C =: states[i].id)];
                
                
                
                //To get the list of user territories for the fetched states of the country US
                
                utList = [ SELECT User__c, User__r.email, User__r.UserName, User__r.FirstName, User__r.LastName FROM Users_Territory__c
                        WHERE (Territory__r.Account__C =:objAccount.ID ) AND Territory__c IN (SELECT Territory__c FROM States_Territory__c WHERE State__C =: states[i].id)];

                System.debug('utList-------->'+utList);
                
                //for all the number of user list obtained
                for (Integer j = 0; j< utList.size(); j++)
                {
                    //responsible to hold the user name, user first name and user last name
                    usersEmails.add(utList[j].User__r.UserName+'#emerge#'+utList[j].User__r.FirstName+'#emerge#'+utList[j].User__r.LastName);
                }
                
                //if usersEmails exists
                if (usersEmails.size() >0 )
                {
                    //responsible to hold state code with user emails.
                    mapStateUsers.put(states[i].State_Code__C, usersEmails);
                }
            }
        }
        //if account exists
        if (objAccount  != null)
            
            // Get List of first 100 Addresses that needs to be synchronized
            addressesList = [SELECT id, name, Destination_Name__c, Shipto_Company__c, Shipto_Name__c, State__c, State__r.State_Name__c, Address__c,
                            Division__r.Territory_Name__c, Active__c, City__c, Zip__c, Email__c, Phone__c, Fax__c, State__r.State_Code__c, Needs_to_be_synchronised__c, 
                            ShipToFirstName__c, ShipToLastName__c from AddressBook__c WHERE Account__C = :objAccount.ID AND Active__c=True AND 
                            Needs_to_be_synchronised__c= True LIMIT 100];
                System.debug('addressesList-------->'+addressesList);
            
        // System.debug(addressesList);
        
        //for all the address list obtained
        for (Integer a = 0; a< addressesList.size(); a++)
        {
            
            //if state code is not equal to null
            if(mapStateUsers.get(addressesList[a].State__r.State_Code__c) != null)
                //responsible to hold a message which says the number users for an address.
                strMessage += addressesList[a].State__r.State_Code__c+' has  ' +mapStateUsers.get(addressesList[a].State__r.State_Code__c).size()+ ' no of users +<br/> ';
            
            req = new HttpRequest();
            res = new HttpResponse();
            
            //the http request to should be completed in 2 minutes.
            req.setTimeout(120000);
            
            //responsible to hold the request body that is destination name, ship to name, Ship To Company,Address,City,State,Zip,Email,Phone,Fax__c,Emerge_address_id,
            //ShipToFirstName,ShipToLastName,salesforce_record_id.
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
            
            //responsible to hold state code from address list
            sfusernames = mapStateUsers.get(addressesList[a].State__r.State_Code__C);
            
            //if user names exists
            if (sfusernames != NULL)
            {
                //for all the number state codes
                for (Integer k = 0; k< sfusernames.size(); k++)
                    
                    //add emerge login user name to the request body
                    body  += '&EmergeLoginUserName[]='+EncodingUtil.urlEncode(sfusernames[k], 'UTF-8');
                
                //responsible to hold the end point URL
                //req.setEndpoint('https://www.wilsondanielspos.com/wilsondanielsposAddressUpload.php');
                
                //responsible to set the request method type to 'POST'
                req.setMethod('POST');
                
                //responsible to hold the body for the request
                req.setBody(body);  
                
                //the below lines of code is responsible for test coverage in test classes
                if(!Test.isRunningTest())          
                    res = http.send(req);
                
                //responsible to hold the Http response body
                resBody  = res.getBody();
                
                //add response body to strMessage
                strMessage += resBody+'<br/><br/>';
                System.debug('resBody----->'+resBody);
                //if the response body contains 'inserted successfully'
                if ( resBody.contains('inserted successfully'))
                {
                    //the Needs_to_be_synchronised__c checkbox field will be set to false
                    addressesList[a].Needs_to_be_synchronised__c = False;
                }
                //if the response body contains 'Updated successfully'
                if ( resBody.contains('Updated successfully'))
                {
                    //the Needs_to_be_synchronised__c checkbox field will be set to false
                    addressesList[a].Needs_to_be_synchronised__c = False;
                }
            }
        }
        //responsible to update the addressList
        Update addressesList;
        
        return 'Synchronized';
    }


    
}