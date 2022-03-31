declare module "@salesforce/apex/InfiniumManageBrandList_Apex.getAccount" {
  export default function getAccount(): Promise<any>;
}
declare module "@salesforce/apex/InfiniumManageBrandList_Apex.getBrandList" {
  export default function getBrandList(): Promise<any>;
}
declare module "@salesforce/apex/InfiniumManageBrandList_Apex.deactivateBrandApex" {
  export default function deactivateBrandApex(param: {selectedBrand: any}): Promise<any>;
}
declare module "@salesforce/apex/InfiniumManageBrandList_Apex.addUserToBrandManager" {
  export default function addUserToBrandManager(param: {selectedUserIds: any, brandId: any}): Promise<any>;
}
declare module "@salesforce/apex/InfiniumManageBrandList_Apex.addBrand" {
  export default function addBrand(param: {selectedBrand: any}): Promise<any>;
}
declare module "@salesforce/apex/InfiniumManageBrandList_Apex.getCurrentBrandMangerList" {
  export default function getCurrentBrandMangerList(param: {brandId: any}): Promise<any>;
}
