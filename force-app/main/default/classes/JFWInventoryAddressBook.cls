//Authors: TP, VB, JP, VP
//Date: 12 October 2020
//Aim : To fetch address details, deactivate the address and get all states
public with sharing class JFWInventoryAddressBook
{
    //global variable to hold the account details
    public static Account objAccount;
    //Aim: To get the details of current user
    @AuraEnabled
    public static User currentUser()
    {
        //fetch Id from the user sObject
        return [SELECT Id FROM User WHERE Id=:UserInfo.getUserId()];
    }
    //Aim; to get the account details
    @AuraEnabled
    public static Account getAccount()
    {
        //used by the test classes
        if(Test.isRunningTest())
        {
            objAccount=[SELECT Id, Name FROM Account
                        WHERE Name LIKE '%JFW%' LIMIT 1];
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
    //Author: VP , JP OCT 12 2020.
    //To get list of address for the logged in user based on search with pagination.
    @AuraEnabled(cacheable=true)
    public static AddressBookListWithSizeWrapper LoadAddressBookListWithSearch (String searchKeyword,Integer recordStartIndex)
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
    //Author: VP , JP OCT 13 2020.
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
            JFWEmailNotifications.sendNotification('Deactivate Address',ex.getMessage()+'\n'+'Inputs are -- selectedAddressBook-- '+JSON.serialize(selectedAddressBook)+'Class Name - jfwInventoryAddressBook '+'-- Line number --'+ex.getLineNumber());
        }
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
            JFWEmailNotifications.sendNotification('Add Address',ex.getMessage()+'\n'+'Inputs are -- selectedAddressBook-- '+JSON.serialize(selectedAddressBook) +'Class Name - jfwInventoryAddressBook '+'-- Line number --'+ex.getLineNumber());
        }
        
        return 'Done';
    }
    
}