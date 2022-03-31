declare module "@salesforce/apex/InfiniumPosItemToCart_Apex.getPosItems_Apex" {
  export default function getPosItems_Apex(param: {searchPosItemKeyword: any, chosenBrandId: any, chosenItemTypeId: any, sortById: any, selectedProgramId: any, recordStartIndex: any}): Promise<any>;
}
declare module "@salesforce/apex/InfiniumPosItemToCart_Apex.getBrands_Apex" {
  export default function getBrands_Apex(): Promise<any>;
}
declare module "@salesforce/apex/InfiniumPosItemToCart_Apex.getItemTypes_Apex" {
  export default function getItemTypes_Apex(): Promise<any>;
}
declare module "@salesforce/apex/InfiniumPosItemToCart_Apex.createSeasonalShoppingCart_Apex" {
  export default function createSeasonalShoppingCart_Apex(param: {selectedProgramId: any}): Promise<any>;
}
declare module "@salesforce/apex/InfiniumPosItemToCart_Apex.addAllPosItemsToCart_Apex" {
  export default function addAllPosItemsToCart_Apex(param: {searchPosItemKeyword: any, chosenBrandId: any, chosenItemTypeId: any, cartId: any, sortById: any, selectedProgramId: any}): Promise<any>;
}
declare module "@salesforce/apex/InfiniumPosItemToCart_Apex.addPosItemToCart_Apex" {
  export default function addPosItemToCart_Apex(param: {selectedProgramId: any, posItemId: any}): Promise<any>;
}
declare module "@salesforce/apex/InfiniumPosItemToCart_Apex.removePosItemFromCart_Apex" {
  export default function removePosItemFromCart_Apex(param: {selectedProgramId: any, posItemId: any}): Promise<any>;
}
