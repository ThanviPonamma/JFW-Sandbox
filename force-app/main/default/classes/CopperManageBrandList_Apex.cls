/** Author : Thanvi
    Date:06/Aug/2021
    Aim:To load brands ,to create a brand ,to edit a brand and to deactivate a brand.
 */
public class CopperManageBrandList_Apex {
    //To hold Copper Cane Account deatails
    public static Account objAccount;
    
    //To fetch data about Copper Cane from Standard object Account.
    @AuraEnabled(cacheable=true)
    public static Account getAccount() {  
        
        if(Test.isRunningTest())
        {
            objAccount=[SELECT Id, Name FROM Account
                        WHERE Name LIKE '%Copper Cane%' LIMIT 1];
        }
        else
        {
           objAccount=[SELECT Id, Name,Lightning_Community_URL__c FROM Account
                        WHERE Lightning_Community_Id__c=:Network.getNetworkId() LIMIT 1];
        }
        return objAccount; // objAccount object contains data about Copper Cane.
    }
    
    // To get the List of Brands From Custom object Brand__C
    @AuraEnabled(cacheable=true)
    public static BrandListWithNames getBrandList() {
        //Fetch account details for Copper Cane
        objAccount=getAccount();
        //Declare a variable brandList to hold the list of brands of type sObject Brand__c
        List<Brand__c> brandList = new List<Brand__c>();
        //Declare a variable brandNamesForValidation to hold the list of brands with the form suitable for validation of type String
        List<String> brandNamesForValidation = new List<String>();
        //Fetch brand id , brand name , account , active status from sObject Brand__c where the account is Copper Cane 
        for(Brand__c brand : [SELECT Id, Brand_Name__c, Account__c, Active__c FROM Brand__c
                              WHERE Account__c=:objAccount.Id ORDER BY Brand_Name__c])
        {
            //for every record fetched , add the incoming brand to the brandList variable
            brandList.add(brand);
            //add the brand names with no space and uppercase to the variable brandNamesForValidation
            brandNamesForValidation.add(brand.Brand_Name__c.remove(' ').toUpperCase().trim());
        }
        //for testing
        System.debug('brandList---->'+brandList);
        System.debug('brandNamesForValidation---->'+brandNamesForValidation);
        //return BrandListWithNames wrapper class where it holds fetched brandList and brandNamesForValidation
        return new BrandListWithNames(brandList,brandNamesForValidation); // brandList object contains data about List Of Brands.
        
    }


    //Aim:To deactivate a brand
    //Parameter : selectedBrand: This variable contains the brand that is to be deactivated
    @AuraEnabled
    public static String deactivateBrandApex(Brand__c selectedBrand)
    {
        try{
            //For the incoming brand , the active status must be set to false to make it inactive
            selectedBrand.Active__c=false;
            //update the brand in the database
            System.debug('deactivated brand'+selectedBrand);
            update selectedBrand;
        }
        //if there is an error while updating the brand , notify the admin by mail
        catch(Exception ex)
        {
            CopperEmailNotifications.sendNotification('Deactivating a Brand',ex.getMessage()+'\n'+'Inputs are -- selectedBrand -- '+JSON.serialize(selectedBrand)
                                                   +'\n'+'Class Name - CopperManageBrandList_Apex '+'-- Line number --'+ex.getLineNumber());
            //return not done                                       
            return 'not done';                                        
        }
        //return the done to the fron end , if there is no error while updating the brand
        return 'done';
    }


     //Aim:To hold the list of brands and the brand names in a form suitable for the brand name validation
    public class BrandListWithNames
    {
        @AuraEnabled
        //To hold the list of brands
        public List<Brand__c> brandList ;
        @AuraEnabled
        //To hold the brand names in a form suitable for the brand name validation
        public List<String> brandNamesForValidation ;
        public BrandListWithNames (List<Brand__c> brandList,List<String> brandNamesForValidation)
        {
            this.brandList=brandList;
            this.brandNamesForValidation=brandNamesForValidation;
        }
    }

       
   // To update the brand managers for the selected brand 
   /**Parameters used : selectedUserIds:  user ids selected as the brand managers for the selected brand id 
                      : brandId : selected brand id for which the brand manager is to be updated.*/
    @AuraEnabled
    public static String addUserToBrandManager(List<String> selectedUserIds, String brandId) { // We require Selected User Id and Brand Id to Update the list of users from the client-side controller
        try{
            ////Fetch account details for Copper Cane
            objAccount=getAccount();
            //Declare a variable existingbrandManagersMap of type map which contains id and User details 
            //fetch user id from the incoming userids list and user ids of brand managers for the incoming brand id and store it in existingbrandManagersMap
            Map<Id,User> existingbrandManagersMap=new Map<Id,User> ([SELECT Id FROM User WHERE Id IN :selectedUserIds
                                                                     AND Id IN (SELECT User__c FROM Brand_Manager__c WHERE Brand__c=:brandId)]);
            //Declare a list variable brandManagerList of type Brand_Manager__c                                                          
            List<Brand_Manager__c> brandManagerList=new List<Brand_Manager__c> ();
            //for each selected user ids from the incoming paramater selectedUserIds 
            for(String userId:selectedUserIds)
            {
                //check if the existingbrandManagersMap doesn't have the user id
                if(!existingbrandManagersMap.containsKey(userId))
                {
                    //if yes create a Brand_Manager__c instance brandManager , add the incoming userId to the User__c field of brand manager and assign incoming brand to the bradn of brand manager
                    Brand_Manager__c brandManager=new Brand_Manager__c();
                    brandManager.User__c=userId;
                    brandManager.Brand__c=brandId;
                    //add the brandManager to the list brandManagerList
                    brandManagerList.add(brandManager);
                }
            }
            System.debug('brand managers list for brand-->' +brandManagerList);
            //insert the brandManagerList to the database
            insert brandManagerList;
            //System.debug('selectedUserIds---->'+selectedUserIds);
            //remove the brand managers who are not in selectedUserIds parameter and for incoming brand id
            delete [SELECT Id FROM Brand_Manager__c WHERE User__c NOT IN :selectedUserIds AND Brand__c=:brandId];

        }
        //if there are any error in the above step notify admin with the brand and brand manager details
        catch(Exception ex)
        {
            CopperEmailNotifications.sendNotification('Inserting a Brand Manager List',ex.getMessage()+'\n'+'Inputs are -->'+'\n'+'selectedUserIds -- '+JSON.serialize(selectedUserIds)+'\n'+'brandId -- '+JSON.serialize(brandId)
                                                   +'\n'+'Class Name - CopperManageBrandList_Apex '+'-- Line number --'+ex.getLineNumber());
            //return unsucessful if any error
            return 'unsucessful';                                         
        }
        //return Sucessful if the brand manager is assigned to a brand
        return 'Successful';
    } 
    
    
    // To add the Brand into the Brand list on Click of Save Button for Create Brand/edit brand in the lightning Component
    //Parameter Used:selectedBrand:This variable contains the brand that is to be added or updated
    @AuraEnabled
    public static String addBrand(Brand__c selectedBrand) { // to create a component we require brandid,brandName and  Brand Active value from the client-side
        
        try{
             //Fetch account details for Copper Cane
            objAccount=getAccount();
           
            //Create an instance of sObject Brand__c 'brand' and assign the incoming brand object to it.
            Brand__c brand = selectedBrand;
            //assign the brand instance account data with the Copper Cane
            brand.Account__c = objAccount.Id;

            System.debug('brand added/updated-->' +brand);
            //update the database with the new/updated brand
            upsert selectedBrand;
        }
        //if there is an error while creating or updating the brand , notify admin by mail with the brand details
        catch(Exception ex)
        {
            CopperEmailNotifications.sendNotification('Inserting a Brand',ex.getMessage()+'\n'+'Inputs are -- selectedBrand -- '+JSON.serialize(selectedBrand)
                                                   +'\n'+'Class Name - CopperManageBrandList_Apex '+'-- Line number --'+ex.getLineNumber());
            //return not done if error
            return 'not done';                                       
        }
        //return done if no errors 
        
        return 'done';
    }
    
  
    
    // To fetch Brand Manager List for a selected Brand Id 
    @AuraEnabled(cacheable=true) 
    public static userOptionsListWrapper getCurrentBrandMangerList(String brandId)
    {
        System.debug('brandId---->'+brandId);
         //Fetch account details for Copper Cane
        objAccount=getAccount();
        //Decalre a variable usersInBrand of type map which contains User id and user details( name , email and username ) for the account Copper Cane and in the list of brand managers for the selected brand
        Map<Id,User> usersInBrand= new Map<Id,User> ([SELECT ID, Name, Email, Username  FROM User usr WHERE usr.AccountId =: objAccount.ID
                                                      AND usr.Id IN (
                                                          SELECT User__C  FROM Brand_Manager__c usrbrand WHERE usrbrand.Brand__c = :brandId)
                                                      ORDER BY usr.Username]);
        // Declare a variable selectedUsers of type list that can hold user Ids                                             
        List<Id> selectedUsers=new List<Id> ();
        //Declare a list variable allUsers of type wrapper class 'userWrapper' which holds label and value
        List<userWrapper> allUsers=new List<userWrapper> ();
        //add all the user ids stored in usersInBrand to the list selectedUsers
        selectedUsers.addAll(usersInBrand.keySet());
        //fetch user details from user for the account Copper Cane , for every user , add the user name and id to the variable allUsers
        for(User user: [SELECT ID, Name, Email, Username  FROM User usr WHERE usr.AccountId =: objAccount.ID
                        ORDER BY usr.Name])
        {
            allUsers.add(new userWrapper(user.Name,user.Id));
        }
        System.debug('allUsers--->'+allUsers);
        System.debug('selectedUsers--->'+selectedUsers);

        //return the wrapper class userOptionsListWrapper which contains the list of users for Copper Cane and the list of brand managers for the selected brand id
        return new userOptionsListWrapper(allUsers,selectedUsers);  //userList object contains data about Users in the List Of Brands.
    }
    
   
   
    //AIm:To hold the list of users who are not assigned to the brand and the brand managers
    public class userOptionsListWrapper
    {
        @AuraEnabled
        public List<userWrapper> allUsers;
        @AuraEnabled
        public List<String> selectedUsers;
        public userOptionsListWrapper (List<userWrapper> allUsers,List<String> selectedUsers)
        {
            this.allUsers=allUsers;
            this.selectedUsers=selectedUsers;
        }
    }
    //Aim:To hold lable and value of the user
    public class userWrapper 
    {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
        public userWrapper(String label,String value)
        {
            this.label=label;
            this.value=value;
        }
    }
}