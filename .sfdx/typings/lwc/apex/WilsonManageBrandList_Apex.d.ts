declare module "@salesforce/apex/WilsonManageBrandList_Apex.getAccount" {
  export default function getAccount(): Promise<any>;
}
declare module "@salesforce/apex/WilsonManageBrandList_Apex.getBrandList" {
  export default function getBrandList(): Promise<any>;
}
declare module "@salesforce/apex/WilsonManageBrandList_Apex.deactivateBrandApex" {
  export default function deactivateBrandApex(param: {selectedBrand: any}): Promise<any>;
}
declare module "@salesforce/apex/WilsonManageBrandList_Apex.addUserToBrandManager" {
  export default function addUserToBrandManager(param: {selectedUserIds: any, brandId: any}): Promise<any>;
}
declare module "@salesforce/apex/WilsonManageBrandList_Apex.addBrand" {
  export default function addBrand(param: {selectedBrand: any}): Promise<any>;
}
declare module "@salesforce/apex/WilsonManageBrandList_Apex.getCurrentBrandMangerList" {
  export default function getCurrentBrandMangerList(param: {brandId: any}): Promise<any>;
}
