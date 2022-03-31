/** 
    Class Name:  ProgramControllerExt
    Purpose: This Class is used to handle Add or Edit functionalities of Seasonal Program.
*/
public class Admin_Program_PlaybookController{   
    public List<POS_Item__c> posItems{get; set; } 
    
    public Admin_Program_PlaybookController(ApexPages.StandardController controller) {
        String programId=controller.getId();
        posItems= [SELECT Name,Item_No__c, Item_Name__c,Attachment_Id__c, Image_of_Item__c,Brand__c, Brand__r.Brand_Name__c,Item_Descrption__c, Pack_Of__c, Price__c, Maximum_Order_Qty__c, Type_of_Item__c, Type_of_Item__r.Item_Type__c, Active__c, Dimension__c,Vendor__c FROM POS_Item__c item
                WHERE item.Id IN (
                    SELECT prgitem.POS_Item__c From Program_Item__c prgitem WHERE prgitem.Program__c = :programId             
                )
                ORDER BY Brand__r.Brand_Name__c,Item_Name__c,Type_of_Item__r.Item_Type__c 
            ];
    } 
    
}