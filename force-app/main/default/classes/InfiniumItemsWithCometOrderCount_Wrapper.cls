//Authors:Sanjana    Date:09-11-2021
//Aim of this class : To hold pos item, size of the sent orders and size of the remaining orders given by InfiniumWaveOrders_Apex.loadAvailableItems()

public class InfiniumItemsWithCometOrderCount_Wrapper {

    //to hold posItem Id, positem name, posItem number, price and pack_of of one pos item
     @AuraEnabled
    public POS_Item__c posItem;
    
    //to hold the size of the sent orders for a pos item
      @AuraEnabled
    public Integer sentOrdersItemSize;
    
    //to hold the size of the remaining orders for a pos item
      @AuraEnabled
    public Integer remainingOrdersItemSize;
    
}