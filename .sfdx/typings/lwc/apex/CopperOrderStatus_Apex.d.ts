declare module "@salesforce/apex/CopperOrderStatus_Apex.getAccount" {
  export default function getAccount(): Promise<any>;
}
declare module "@salesforce/apex/CopperOrderStatus_Apex.getBuyBook_Apex" {
  export default function getBuyBook_Apex(): Promise<any>;
}
declare module "@salesforce/apex/CopperOrderStatus_Apex.loadOrdersForSelectedProgram_Apex" {
  export default function loadOrdersForSelectedProgram_Apex(param: {searchKeyword: any, isEmergeAdmin: any, selectedBuyBookId: any}): Promise<any>;
}
declare module "@salesforce/apex/CopperOrderStatus_Apex.saveEditedOrder_Apex" {
  export default function saveEditedOrder_Apex(param: {seasonalOrderItems: any, orderAmount: any, cometOrderId: any, chairBudget: any}): Promise<any>;
}
