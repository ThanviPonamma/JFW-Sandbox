declare module "@salesforce/apex/DFVBrandListCmpController.getBrandList" {
  export default function getBrandList(): Promise<any>;
}
declare module "@salesforce/apex/DFVBrandListCmpController.addBrand" {
  export default function addBrand(param: {selectedBrand: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVBrandListCmpController.deactivateBrandApex" {
  export default function deactivateBrandApex(param: {selectedBrand: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVBrandListCmpController.getCurrentBrandMangerList" {
  export default function getCurrentBrandMangerList(param: {brandId: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVBrandListCmpController.addUserToBrandManager" {
  export default function addUserToBrandManager(param: {selectedUserIds: any, brandId: any}): Promise<any>;
}
