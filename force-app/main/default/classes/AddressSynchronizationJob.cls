public with sharing class AddressSynchronizationJob
{

    public AddressSynchronizationJob()
    {
        
    }
    
    @future(callout=true)
    public static void SyncCopperCaneAddresses()
    {
        Account objAccount = null;
        List <AddressBook__c> addressesList = null;
        Integer syncCurrent = 0;
        Integer insertModeCnt = 0;
        Integer updateModeCnt = 0;
        Integer insertCnt = 0;
        Integer updateCnt = 0;
        
        objAccount = [SELECT ID, Name FROM Account WHERE Name ='Copper Cane'];

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String body = '';
        HttpResponse res = new HttpResponse();
        String resBody ='';
        List<User> usersAvailable = new List<User>();
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
            addressesList = [SELECT id, name, Destination_Name__c, Shipto_Company__c, Shipto_Name__c, State__c, State__r.State_Name__c, Address__c, Division__r.Territory_Name__c, Active__c, City__c, Zip__c, Email__c, Phone__c, Fax__c, State__r.State_Code__c, Needs_to_be_synchronised__c, ShipToFirstName__c, ShipToLastName__c from AddressBook__c WHERE Account__C = :objAccount.ID AND Active__c=True AND Needs_to_be_synchronised__c= True LIMIT 50];
            

        for (Integer a = 0; a< addressesList.size(); a++)
        {
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
                req.setEndpoint('https://www.coppercanemarketing.com/AddressUpload.php');
                    
                req.setMethod('POST');
                req.setBody(body);  
                
                if(!Test.isRunningTest())          
                    res = http.send(req);
                resBody  = res.getBody();
                      
                if ( resBody.contains('%!INSERT!%'))
                    insertModeCnt++;
                if ( resBody.contains('%!UPDATE!%'))
                    updateModeCnt++;
                            
               if ( resBody.toUpperCase().contains('INSERTED SUCCESSFULLY'))
               {
                   insertCnt++;
                   addressesList[a].Needs_to_be_synchronised__c = False;
               }
               if ( resBody.toUpperCase().contains('UPDATED SUCCESSFULLY'))
               {
                   updateCnt++;
                   addressesList[a].Needs_to_be_synchronised__c = False;
               }
            }
            syncCurrent ++;
        }
        Update addressesList;
    }

}