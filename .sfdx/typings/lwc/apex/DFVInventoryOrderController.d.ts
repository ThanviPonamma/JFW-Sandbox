declare module "@salesforce/apex/DFVInventoryOrderController.getUserDetails" {
  export default function getUserDetails(): Promise<any>;
}
declare module "@salesforce/apex/DFVInventoryOrderController.getCurrentUserSessionIdApex" {
  export default function getCurrentUserSessionIdApex(): Promise<any>;
}
declare module "@salesforce/apex/DFVInventoryOrderController.currentUser" {
  export default function currentUser(): Promise<any>;
}
declare module "@salesforce/apex/DFVInventoryOrderController.getAccount" {
  export default function getAccount(): Promise<any>;
}
declare module "@salesforce/apex/DFVInventoryOrderController.loadBrandsList" {
  export default function loadBrandsList(): Promise<any>;
}
declare module "@salesforce/apex/DFVInventoryOrderController.loadItemTypesList" {
  export default function loadItemTypesList(): Promise<any>;
}
declare module "@salesforce/apex/DFVInventoryOrderController.loadPosItemsQueryList" {
  export default function loadPosItemsQueryList(param: {searchPosItemKeyword: any, chosenBrandId: any, chosenItemTypeId: any, sortById: any, recordStartIndex: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVInventoryOrderController.addItemToCart" {
  export default function addItemToCart(param: {selectedPosItemId: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVInventoryOrderController.removeItemFromCart" {
  export default function removeItemFromCart(param: {selectedPosItemId: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVInventoryOrderController.addItemsToCart" {
  export default function addItemsToCart(param: {posItemsListWithCart: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVInventoryOrderController.createInventoryShoppingCart_Apex" {
  export default function createInventoryShoppingCart_Apex(): Promise<any>;
}
declare module "@salesforce/apex/DFVInventoryOrderController.loadCartItemsList" {
  export default function loadCartItemsList(): Promise<any>;
}
declare module "@salesforce/apex/DFVInventoryOrderController.loadUserAddressBookList" {
  export default function loadUserAddressBookList(param: {selectedAddresses: any, posItemsListWithCart: any, selectedRadioType: any, recordStartIndex: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVInventoryOrderController.loadPosItemUserAddressBookList" {
  export default function loadPosItemUserAddressBookList(param: {selectedAddresses: any, selectedPosItemDetails: any, selectedRadioType: any, recordStartIndex: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVInventoryOrderController.loadShippingMethodList" {
  export default function loadShippingMethodList(): Promise<any>;
}
declare module "@salesforce/apex/DFVInventoryOrderController.saveOrderForAllItems" {
  export default function saveOrderForAllItems(param: {cartItemsJSONString: any, selectedAddresses: any, previouslySelectedAddresses: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVInventoryOrderController.saveOrderForSelectedItem" {
  export default function saveOrderForSelectedItem(param: {cartItemsJSONString: any, selectedAddresses: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVInventoryOrderController.loadAllComerOrders" {
  export default function loadAllComerOrders(param: {emergeOrderId: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVInventoryOrderController.deleteCartItemFromShippingCart" {
  export default function deleteCartItemFromShippingCart(param: {selectedCartItemDetails: any, posItemsListWithCart: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVInventoryOrderController.confirmOrder" {
  export default function confirmOrder(param: {cartItemDetails: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVInventoryOrderController.updateQuantityForSelectedItem_Apex" {
  export default function updateQuantityForSelectedItem_Apex(param: {posItemId: any, shaippingAddressId: any, orderId: any, quantity: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVInventoryOrderController.loadAllInventoryOrders" {
  export default function loadAllInventoryOrders(param: {searchKeyword: any, isEmergeAdmin: any}): Promise<any>;
}
