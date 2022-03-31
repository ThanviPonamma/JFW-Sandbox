declare module "@salesforce/apex/InfiniumShoppingCartItem_Apex.getUserDetails_Apex" {
  export default function getUserDetails_Apex(): Promise<any>;
}
declare module "@salesforce/apex/InfiniumShoppingCartItem_Apex.getAccount" {
  export default function getAccount(): Promise<any>;
}
declare module "@salesforce/apex/InfiniumShoppingCartItem_Apex.getCartItemsList_Apex" {
  export default function getCartItemsList_Apex(param: {selectedProgramId: any}): Promise<any>;
}
declare module "@salesforce/apex/InfiniumShoppingCartItem_Apex.getSelectedUserAddressBookListForAllItems_Apex" {
  export default function getSelectedUserAddressBookListForAllItems_Apex(param: {posItemsListWithCart: any}): Promise<any>;
}
declare module "@salesforce/apex/InfiniumShoppingCartItem_Apex.getUserAddressBookList" {
  export default function getUserAddressBookList(param: {posItemsListWithCart: any, selectedRadioType: any, recordStartIndex: any}): Promise<any>;
}
declare module "@salesforce/apex/InfiniumShoppingCartItem_Apex.getPosItemUserAddressBookList" {
  export default function getPosItemUserAddressBookList(param: {selectedPosItemDetails: any, selectedRadioType: any, recordStartIndex: any}): Promise<any>;
}
declare module "@salesforce/apex/InfiniumShoppingCartItem_Apex.saveAddressForAllOrderedItems" {
  export default function saveAddressForAllOrderedItems(param: {cartItemsJSONString: any, selectedAddresses: any, previouslySelectedAddresses: any, selectedProgramId: any}): Promise<any>;
}
declare module "@salesforce/apex/InfiniumShoppingCartItem_Apex.updateQuantityForSelectedItem_Apex" {
  export default function updateQuantityForSelectedItem_Apex(param: {posItemId: any, shippingAddressId: any, orderId: any, quantity: any}): Promise<any>;
}
declare module "@salesforce/apex/InfiniumShoppingCartItem_Apex.deleteCartItemFromShippingCart_Apex" {
  export default function deleteCartItemFromShippingCart_Apex(param: {selectedCartItemDetails: any, posItemsListWithCart: any}): Promise<any>;
}
