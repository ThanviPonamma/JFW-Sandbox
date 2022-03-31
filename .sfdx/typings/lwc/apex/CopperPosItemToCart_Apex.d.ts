declare module "@salesforce/apex/CopperPosItemToCart_Apex.getPosItems_Apex" {
  export default function getPosItems_Apex(param: {searchPosItemKeyword: any, chosenBrandId: any, chosenItemTypeId: any, sortById: any, selectedBuyBookId: any, recordStartIndex: any}): Promise<any>;
}
declare module "@salesforce/apex/CopperPosItemToCart_Apex.getBrands_Apex" {
  export default function getBrands_Apex(): Promise<any>;
}
declare module "@salesforce/apex/CopperPosItemToCart_Apex.getItemTypes_Apex" {
  export default function getItemTypes_Apex(): Promise<any>;
}
declare module "@salesforce/apex/CopperPosItemToCart_Apex.createSeasonalShoppingCart_Apex" {
  export default function createSeasonalShoppingCart_Apex(param: {selectedBuyBookId: any}): Promise<any>;
}
declare module "@salesforce/apex/CopperPosItemToCart_Apex.addAllPosItemsToCart_Apex" {
  export default function addAllPosItemsToCart_Apex(param: {searchPosItemKeyword: any, chosenBrandId: any, chosenItemTypeId: any, cartId: any, sortById: any, selectedBuyBookId: any}): Promise<any>;
}
declare module "@salesforce/apex/CopperPosItemToCart_Apex.addPosItemToCart_Apex" {
  export default function addPosItemToCart_Apex(param: {selectedBuyBookId: any, posItemId: any}): Promise<any>;
}
declare module "@salesforce/apex/CopperPosItemToCart_Apex.removePosItemFromCart_Apex" {
  export default function removePosItemFromCart_Apex(param: {selectedBuyBookId: any, posItemId: any}): Promise<any>;
}
