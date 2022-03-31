declare module "@salesforce/apex/DFVSeasonalOrderController.getUserDetails" {
  export default function getUserDetails(): Promise<any>;
}
declare module "@salesforce/apex/DFVSeasonalOrderController.getCurrentUserSessionIdApex" {
  export default function getCurrentUserSessionIdApex(): Promise<any>;
}
declare module "@salesforce/apex/DFVSeasonalOrderController.currentUser" {
  export default function currentUser(): Promise<any>;
}
declare module "@salesforce/apex/DFVSeasonalOrderController.getAccount" {
  export default function getAccount(): Promise<any>;
}
declare module "@salesforce/apex/DFVSeasonalOrderController.getProgram_ChairBudgetList_Apex" {
  export default function getProgram_ChairBudgetList_Apex(): Promise<any>;
}
declare module "@salesforce/apex/DFVSeasonalOrderController.getPosItems_Apex" {
  export default function getPosItems_Apex(param: {searchPosItemKeyword: any, chosenBrandId: any, chosenItemTypeId: any, sortById: any, selectedProgramId: any, recordStartIndex: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVSeasonalOrderController.getBrands_Apex" {
  export default function getBrands_Apex(): Promise<any>;
}
declare module "@salesforce/apex/DFVSeasonalOrderController.getItemTypes_Apex" {
  export default function getItemTypes_Apex(): Promise<any>;
}
declare module "@salesforce/apex/DFVSeasonalOrderController.createSeasonalShoppingCart_Apex" {
  export default function createSeasonalShoppingCart_Apex(param: {selectedProgramId: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVSeasonalOrderController.addAllPosItemsToCart_Apex" {
  export default function addAllPosItemsToCart_Apex(param: {searchPosItemKeyword: any, chosenBrandId: any, chosenItemTypeId: any, cartId: any, sortById: any, selectedProgramId: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVSeasonalOrderController.addPosItemToCart_Apex" {
  export default function addPosItemToCart_Apex(param: {searchPosItemKeyword: any, chosenBrandId: any, chosenItemTypeId: any, sortById: any, selectedProgramId: any, recordStartIndex: any, posItemId: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVSeasonalOrderController.removePosItemFromCart_Apex" {
  export default function removePosItemFromCart_Apex(param: {searchPosItemKeyword: any, chosenBrandId: any, chosenItemTypeId: any, sortById: any, selectedProgramId: any, recordStartIndex: any, posItemId: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVSeasonalOrderController.getCartItems_Apex" {
  export default function getCartItems_Apex(param: {selectedProgramId: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVSeasonalOrderController.getChairBudgetDetails_Apex" {
  export default function getChairBudgetDetails_Apex(param: {selectedChairBudgetId: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVSeasonalOrderController.updateQuantityForItem_Apex" {
  export default function updateQuantityForItem_Apex(param: {posItemId: any, shippingAddressId: any, emergeOrderId: any, quantity: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVSeasonalOrderController.deleteItemFromCart_Apex" {
  export default function deleteItemFromCart_Apex(param: {posItemId: any, selectedProgramId: any, emergeOrderId: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVSeasonalOrderController.getShippingAddresses_Apex" {
  export default function getShippingAddresses_Apex(param: {posItemId: any, selectedProgramId: any, emergeOrderId: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVSeasonalOrderController.searchShippingAddresses_Apex" {
  export default function searchShippingAddresses_Apex(param: {searchKeyWord: any, selectedShippingAddresses: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVSeasonalOrderController.loadShippingMethodList" {
  export default function loadShippingMethodList(): Promise<any>;
}
declare module "@salesforce/apex/DFVSeasonalOrderController.saveShippingAddresses_Apex" {
  export default function saveShippingAddresses_Apex(param: {emergeOrderId: any, posItemId: any, selectedProgramId: any, selectedShippingAddresses: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVSeasonalOrderController.getCometOrderItems_Apex" {
  export default function getCometOrderItems_Apex(param: {emergeOrderId: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVSeasonalOrderController.confirmOrder_Apex" {
  export default function confirmOrder_Apex(param: {emergeOrderId: any, selectedProgramId: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVSeasonalOrderController.getAllPrograms_Apex" {
  export default function getAllPrograms_Apex(): Promise<any>;
}
declare module "@salesforce/apex/DFVSeasonalOrderController.loadOrdersForSelectedProgram_Apex" {
  export default function loadOrdersForSelectedProgram_Apex(param: {searchKeyword: any, isEmergeAdmin: any, selectedProgramId: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVSeasonalOrderController.getUsers_Apex" {
  export default function getUsers_Apex(param: {searchWord: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVSeasonalOrderController.loadOrdersForSelectedProgramAndUser_Apex" {
  export default function loadOrdersForSelectedProgramAndUser_Apex(param: {searchUserWord: any, selectedProgramId: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVSeasonalOrderController.saveEditedOrder_Apex" {
  export default function saveEditedOrder_Apex(param: {seasonalOrderItems: any, searchUserWord: any, selectedProgramId: any, orderAmount: any, cometOrderId: any, chairBudget: any}): Promise<any>;
}
