declare module "@salesforce/apex/JFWInventoryShoppingCart_Apex.getUserDetails" {
  export default function getUserDetails(): Promise<any>;
}
declare module "@salesforce/apex/JFWInventoryShoppingCart_Apex.getAccount" {
  export default function getAccount(): Promise<any>;
}
declare module "@salesforce/apex/JFWInventoryShoppingCart_Apex.getCartItemsList" {
  export default function getCartItemsList(): Promise<any>;
}
declare module "@salesforce/apex/JFWInventoryShoppingCart_Apex.getSelectedUserAddressBookListForAllItems" {
  export default function getSelectedUserAddressBookListForAllItems(param: {posItemsListWithCart: any}): Promise<any>;
}
declare module "@salesforce/apex/JFWInventoryShoppingCart_Apex.getSelectedAddressesForPosItem" {
  export default function getSelectedAddressesForPosItem(param: {selectedPosItemDetails: any}): Promise<any>;
}
declare module "@salesforce/apex/JFWInventoryShoppingCart_Apex.getUserAddressBookList" {
  export default function getUserAddressBookList(param: {posItemsListWithCart: any, selectedRadioType: any, recordStartIndex: any}): Promise<any>;
}
declare module "@salesforce/apex/JFWInventoryShoppingCart_Apex.getPosItemUserAddressBookList" {
  export default function getPosItemUserAddressBookList(param: {selectedPosItemDetails: any, selectedRadioType: any, recordStartIndex: any}): Promise<any>;
}
declare module "@salesforce/apex/JFWInventoryShoppingCart_Apex.getShippingMethodList" {
  export default function getShippingMethodList(): Promise<any>;
}
declare module "@salesforce/apex/JFWInventoryShoppingCart_Apex.saveAddressForAllOrderedItems" {
  export default function saveAddressForAllOrderedItems(param: {cartItemsJSONString: any, selectedAddresses: any, previouslySelectedAddresses: any}): Promise<any>;
}
declare module "@salesforce/apex/JFWInventoryShoppingCart_Apex.saveAddressForSelectedItem" {
  export default function saveAddressForSelectedItem(param: {cartItemsJSONString: any, selectedAddresses: any}): Promise<any>;
}
declare module "@salesforce/apex/JFWInventoryShoppingCart_Apex.updateQuantityForSelectedItem" {
  export default function updateQuantityForSelectedItem(param: {posItemId: any, shippingAddressId: any, orderId: any, quantity: any}): Promise<any>;
}
declare module "@salesforce/apex/JFWInventoryShoppingCart_Apex.deleteCartItemFromShippingCart" {
  export default function deleteCartItemFromShippingCart(param: {selectedCartItemDetails: any, posItemsListWithCart: any}): Promise<any>;
}
