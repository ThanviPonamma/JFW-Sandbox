//Author : VM , NK, VB
//Date : 03-03-2021
//Aim:To synchronize the addresses marked as "Needs to be syncronized" checkbox field under the Object AddressBook__c
//    with the POD on click of ''Synchronize Address Book with POD site''  button under Manage Address Book feature for an Admin 

public class WilsonAddressBookSyncApex {

    //To hold the account data in objAccount variable    
    public static Account objAccount;

    Set<String> stateIds = new Set<String>();
    

    
    //Aim: To get the account data
    @AuraEnabled(cacheable=true)
    public static Account getAccount() { 
        if(Test.isRunningTest())
        {
            objAccount=[SELECT Id, Name,Lightning_Community_URL__c FROM Account
                        WHERE Name LIKE '%Wilson Daniels%' LIMIT 1];
        }
        else
        {
            
            objAccount=[SELECT Id, Name,Lightning_Community_URL__c FROM Account
            WHERE Lightning_Community_Id__c=:Network.getNetworkId() LIMIT 1];
        }
        return objAccount;
    }

     
    //Aim : To synchronise newly added addresses to the Pod site on click of 'Synchronise all addresses' button 
    @AuraEnabled(cacheable=true)
    public static String synchronizeAddressBook()
    {
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
        
        //responsible to holds the user name and first name of the user.
       // Map<string, string> mapStateUserFirstName;   
       // mapStateUserFirstName  = new Map<string, string>();
        
        //responsible to holds the user name and last name of the user.
       // Map<string, string> mapStateUserLastName; 
       // mapStateUserLastName  = new Map<string, string>();
        
        //instance of type list that holds string elements that holds user names
        List<String> sfusernames = new List<String>();
        
        //holds the list of Id,Name and state code from the table State__c
        
        
        //Date: 10-04-2020 Authors - GJ, NK, JP, SN
        //temporary fix---> decided to filter the state based on country US
        //CR - SMWE-13-Apr-3
        //Reason - to address governer limit issue
        states = [SELECT ID,Name, State_Code__c FROM State__c WHERE Country__c= :'a010v000003s9jL'];
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
                
                
                
               //User id updated to sync addresses for Erik Harshfield on 01-03-2021, Author : NK
                 
                utList = [ SELECT User__c, User__r.email, User__r.UserName, User__r.FirstName, User__r.LastName FROM Users_Territory__c
                          WHERE Territory__c IN (SELECT Territory__c FROM States_Territory__c WHERE State__C =: states[i].id)];

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
            /**if (sfusernames != NULL)
            {
                //for all the number state codes
                for (Integer k = 0; k< sfusernames.size(); k++)
                    
                    //add emerge login user name to the request body
                    body  += '&EmergeLoginUserName[]='+EncodingUtil.urlEncode(sfusernames[k], 'UTF-8');
                
                //responsible to hold the end point URL
                req.setEndpoint('');
                
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
            }**/
        }
        //responsible to update the addressList
        //Update addressesList;
        
        return 'Synchronized';
    }



}