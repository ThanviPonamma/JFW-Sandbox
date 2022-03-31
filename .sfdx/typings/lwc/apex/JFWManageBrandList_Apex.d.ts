declare module "@salesforce/apex/JFWManageBrandList_Apex.getAccount" {
  export default function getAccount(): Promise<any>;
}
declare module "@salesforce/apex/JFWManageBrandList_Apex.getBrandList" {
  export default function getBrandList(): Promise<any>;
}
declare module "@salesforce/apex/JFWManageBrandList_Apex.deactivateBrandApex" {
  export default function deactivateBrandApex(param: {selectedBrand: any}): Promise<any>;
}
declare module "@salesforce/apex/JFWManageBrandList_Apex.addUserToBrandManager" {
  export default function addUserToBrandManager(param: {selectedUserIds: any, brandId: any}): Promise<any>;
}
declare module "@salesforce/apex/JFWManageBrandList_Apex.addBrand" {
  export default function addBrand(param: {selectedBrand: any}): Promise<any>;
}
declare module "@salesforce/apex/JFWManageBrandList_Apex.getCurrentBrandMangerList" {
  export default function getCurrentBrandMangerList(param: {brandId: any}): Promise<any>;
}
