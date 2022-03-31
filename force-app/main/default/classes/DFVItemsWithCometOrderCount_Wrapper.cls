//Authors : NK, SN, TP, VB ; Date: 24-06-2020
//Aim of this class : To hold pos item, size of the sent orders and size of the remaining orders given by DFVWaveOrders_Apex.loadAvailableItems()

public class DFVItemsWithCometOrderCount_Wrapper {

    //to hold posItem Id, positem name, posItem number, price and pack_of of one pos item
     @AuraEnabled
    public POS_Item__c posItem;
    
    //to hold the size of the sent orders for a pos item
      @AuraEnabled
    public Integer sentOrdersItemSize;
    
    //to hold the size of the remaining orders for a pos item
      @AuraEnabled
    public Integer remainingOrdersItemSize;
    
    
    //Commented by JP , VP, VM On june 25 2020 
    //To be dicussed
    
    //Creating a constructor with the parameters posItem, sentOrdersItemSize and remainingOrdersItemSize
    /**public DFVItemsWithCometOrderCount_Wrapper(POS_Item__c posItem, Integer sentOrdersItemSize, Integer remainingOrdersItemSize){
        
        this.posItem = posItem;
        this.sentOrdersItemSize = sentOrdersItemSize;
        this.remainingOrdersItemSize = remainingOrdersItemSize;
    }**/
    
    
}