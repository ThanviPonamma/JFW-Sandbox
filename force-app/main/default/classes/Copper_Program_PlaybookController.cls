/** 
Class Name:  Copper_Program_PlaybookController
Purpose: This Class is used tofetch the buy book item details for selected buy book id
*/
public class Copper_Program_PlaybookController{   
    //Declare a variable which can hold pos items
    public List<POS_Item__c> posItemList{get; set; } 
    public Copper_Program_PlaybookController(ApexPages.StandardController controller) {
        //store the selected buy book id in a variable buyBookId of type string
        String buyBookId=controller.getId();
        posItemList= [SELECT Name,Item_No__c, Item_Name__c,Attachment_Id__c, Image_of_Item__c,Brand__c, Brand__r.Brand_Name__c,Item_Descrption__c, Pack_Of__c, Price__c, Maximum_Order_Qty__c, Type_of_Item__c, Type_of_Item__r.Item_Type__c, Active__c, Dimension__c FROM POS_Item__c item
                      WHERE item.Id IN (
                          SELECT prgitem.POS_Item__c From Program_Item__c prgitem WHERE prgitem.Program__c = :buyBookId             
                      )
                      ORDER BY Brand__r.Brand_Name__c,Item_Name__c,Type_of_Item__r.Item_Type__c 
                     ];
        System.debug('posItemList--->'+posItemList.size());
    } 
    
}