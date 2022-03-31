declare module "@salesforce/apex/CopperShoppingCartItem_Apex.getUserDetails" {
  export default function getUserDetails(): Promise<any>;
}
declare module "@salesforce/apex/CopperShoppingCartItem_Apex.getAccount" {
  export default function getAccount(): Promise<any>;
}
declare module "@salesforce/apex/CopperShoppingCartItem_Apex.getCartItemsList_Apex" {
  export default function getCartItemsList_Apex(param: {selectedBuyBookId: any}): Promise<any>;
}
declare module "@salesforce/apex/CopperShoppingCartItem_Apex.getSelectedUserAddressBookListForAllItems" {
  export default function getSelectedUserAddressBookListForAllItems(param: {posItemsListWithCart: any}): Promise<any>;
}
declare module "@salesforce/apex/CopperShoppingCartItem_Apex.getUserAddressBookList" {
  export default function getUserAddressBookList(param: {posItemsListWithCart: any, selectedRadioType: any, recordStartIndex: any}): Promise<any>;
}
declare module "@salesforce/apex/CopperShoppingCartItem_Apex.getPosItemUserAddressBookList" {
  export default function getPosItemUserAddressBookList(param: {selectedPosItemDetails: any, selectedRadioType: any, recordStartIndex: any}): Promise<any>;
}
declare module "@salesforce/apex/CopperShoppingCartItem_Apex.saveAddressForAllOrderedItems" {
  export default function saveAddressForAllOrderedItems(param: {cartItemsJSONString: any, selectedAddresses: any, previouslySelectedAddresses: any, selectedBuyBookId: any}): Promise<any>;
}
declare module "@salesforce/apex/CopperShoppingCartItem_Apex.updateQuantityForSelectedItem" {
  export default function updateQuantityForSelectedItem(param: {posItemId: any, shippingAddressId: any, orderId: any, quantity: any}): Promise<any>;
}
declare module "@salesforce/apex/CopperShoppingCartItem_Apex.deleteCartItemFromShippingCart" {
  export default function deleteCartItemFromShippingCart(param: {selectedCartItemDetails: any, posItemsListWithCart: any}): Promise<any>;
}
