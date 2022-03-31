public class DFVItemDetailsWithTotalQuantity 
{
       @AuraEnabled
       public string PosItemId {get;set;}
       @AuraEnabled
       public string PosItemNumber {get;set;}
       @AuraEnabled
       public string PosItemName {get;set;}
       @AuraEnabled
       public string Brand {get;set;}
       @AuraEnabled
       public string ItemType {get;set;}
       @AuraEnabled
       public string ProgramName {get;set;}
       @AuraEnabled
       public decimal Price {get;set;}
       @AuraEnabled
       public decimal PackOf {get;set;}
       @AuraEnabled
       public decimal TotalQuantity {get;set;}
       @AuraEnabled
       public decimal TotalAmount {get;set;}
       @AuraEnabled
       public decimal TotalPiecesOrdered {get;set;}
              
       
}