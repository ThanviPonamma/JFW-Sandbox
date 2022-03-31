// The Apex Class Controller For Manage Brand Component
public class DFVBrandListCmpController {
    public static Account objAccount;
    
    //To fetch data about Mionetto from Standard object Account.
    public static Account getAccount() {  
        
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
        return objAccount; // objAccount object contains data about Mionetto.
    }
    
    // To get the List of Brands From Custom object Brand__C
    @AuraEnabled
    public static BrandListWithNames getBrandList() {
        objAccount=getAccount();
        List<Brand__c> brandList = new List<Brand__c>();
        List<String> brandNamesForValidation = new List<String>();
        for(Brand__c brand : [SELECT Id, Brand_Name__c, Account__c, Active__c FROM Brand__c
                              WHERE Account__c=:objAccount.Id ORDER BY Brand_Name__c])
        {
            brandList.add(brand);
            brandNamesForValidation.add(brand.Brand_Name__c.remove(' ').toUpperCase().trim());
        }
        
        return new BrandListWithNames(brandList,brandNamesForValidation); // brandList object contains data about List Of Brands.
        
    }
    
    // To add the Brand into the Brand list on Click of Save Button for Create Brand in the lightning Component
    @AuraEnabled
    public static BrandListWithNames addBrand(Brand__c selectedBrand) { // to create a component we require brandid,brandName and  Brand Active value from the client-side
        
        try{
            objAccount=getAccount();
            Brand__c brand = selectedBrand;
            brand.Account__c = objAccount.Id;
            upsert selectedBrand;
        }
        catch(Exception ex)
        {
            DFVEmailNotifications.sendNotification('Inserting a Brand',ex.getMessage()+'\n'+'Inputs are -- selectedBrand -- '+JSON.serialize(selectedBrand)
                                                   +'\n'+'Class Name - DFVBrandListCmpController '+'-- Line number --'+ex.getLineNumber());
        }
        return getBrandList();
    }
    
    @AuraEnabled 
    public static BrandListWithNames deactivateBrandApex(Brand__c selectedBrand)
    {
        try{
            objAccount=getAccount();
            selectedBrand.Active__c=false;
            update selectedBrand;
        }
        catch(Exception ex)
        {
            DFVEmailNotifications.sendNotification('Deactivating a Brand',ex.getMessage()+'\n'+'Inputs are -- selectedBrand -- '+JSON.serialize(selectedBrand)
                                                   +'\n'+'Class Name - DFVBrandListCmpController '+'-- Line number --'+ex.getLineNumber());
        }
        return getBrandList();
    }
    
    // To fetch Brand Manager List for a paricular Brand Id 
    @AuraEnabled
    public static userOptionsListWrapper getCurrentBrandMangerList(String brandId)
    {
        objAccount=getAccount();
        Map<Id,User> usersInBrand= new Map<Id,User> ([SELECT ID, Name, Email, Username  FROM User usr WHERE usr.AccountId =: objAccount.ID
                                                      AND usr.Id IN (
                                                          SELECT User__C  FROM Brand_Manager__c usrbrand WHERE usrbrand.Brand__c = :brandId)
                                                      ORDER BY usr.Username]);
        List<Id> selectedUsers=new List<Id> ();
        List<userWrapper> allUsers=new List<userWrapper> ();
        selectedUsers.addAll(usersInBrand.keySet());
        for(User user: [SELECT ID, Name, Email, Username  FROM User usr WHERE usr.AccountId =: objAccount.ID
                        ORDER BY usr.Name])
        {
            allUsers.add(new userWrapper(user.Name,user.Id));
        }
        
        return new userOptionsListWrapper(allUsers,selectedUsers);  //userList object contains data about Users in the List Of Brands.
    }
    
    // To Update The Users for a particular Brand Manager
    @AuraEnabled 
    public static String addUserToBrandManager(List<String> selectedUserIds, String brandId) { // We require Selected User Id and Brand Id to Update the list of users from the client-side controller
        try{
            objAccount=getAccount();
            Map<Id,User> existingbrandManagersMap=new Map<Id,User> ([SELECT Id FROM User WHERE Id IN :selectedUserIds
                                                                     AND Id IN (SELECT User__c FROM Brand_Manager__c WHERE Brand__c=:brandId)]);
            List<Brand_Manager__c> brandManagerList=new List<Brand_Manager__c> ();
            for(String userId:selectedUserIds)
            {
                if(!existingbrandManagersMap.containsKey(userId))
                {
                    Brand_Manager__c brandManager=new Brand_Manager__c();
                    brandManager.User__c=userId;
                    brandManager.Brand__c=brandId;
                    brandManagerList.add(brandManager);
                }
            }
            insert brandManagerList;
            //System.debug('selectedUserIds---->'+selectedUserIds);
            delete [SELECT Id FROM Brand_Manager__c WHERE User__c NOT IN :selectedUserIds AND Brand__c=:brandId];
        }catch(Exception ex)
        {
            DFVEmailNotifications.sendNotification('Inserting a Brand Manager List',ex.getMessage()+'\n'+'Inputs are -->'+'\n'+'selectedUserIds -- '+JSON.serialize(selectedUserIds)+'\n'+'brandId -- '+JSON.serialize(brandId)
                                                   +'\n'+'Class Name - DFVBrandListCmpController '+'-- Line number --'+ex.getLineNumber());
        }
        return 'Successful';
    } 
    
    
    public class BrandListWithNames
    {
        @AuraEnabled
        public List<Brand__c> brandList ;
        @AuraEnabled
        public List<String> brandNamesForValidation ;
        public BrandListWithNames (List<Brand__c> brandList,List<String> brandNamesForValidation)
        {
            this.brandList=brandList;
            this.brandNamesForValidation=brandNamesForValidation;
        }
    }
    
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