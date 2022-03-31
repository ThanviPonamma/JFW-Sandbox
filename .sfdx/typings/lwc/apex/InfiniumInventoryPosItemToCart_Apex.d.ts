declare module "@salesforce/apex/InfiniumInventoryPosItemToCart_Apex.getAccount" {
  export default function getAccount(): Promise<any>;
}
declare module "@salesforce/apex/InfiniumInventoryPosItemToCart_Apex.getBrandList" {
  export default function getBrandList(): Promise<any>;
}
declare module "@salesforce/apex/InfiniumInventoryPosItemToCart_Apex.getItemTypeList" {
  export default function getItemTypeList(): Promise<any>;
}
declare module "@salesforce/apex/InfiniumInventoryPosItemToCart_Apex.createInventoryShoppingCart" {
  export default function createInventoryShoppingCart(): Promise<any>;
}
declare module "@salesforce/apex/InfiniumInventoryPosItemToCart_Apex.getInventoryPosItemList" {
  export default function getInventoryPosItemList(param: {searchedPosItem: any, chosenBrandId: any, chosenItemTypeId: any, sortById: any, recordStartIndex: any}): Promise<any>;
}
declare module "@salesforce/apex/InfiniumInventoryPosItemToCart_Apex.addInventoryPosItemToCart" {
  export default function addInventoryPosItemToCart(param: {selectedPosItemId: any}): Promise<any>;
}
declare module "@salesforce/apex/InfiniumInventoryPosItemToCart_Apex.removeInventoryPosItemFromCart" {
  export default function removeInventoryPosItemFromCart(param: {selectedPosItemId: any}): Promise<any>;
}
