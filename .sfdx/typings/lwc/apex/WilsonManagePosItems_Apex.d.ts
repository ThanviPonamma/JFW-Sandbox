declare module "@salesforce/apex/WilsonManagePosItems_Apex.addOrEditPOSItem" {
  export default function addOrEditPOSItem(param: {posItem: any, imageBlobData: any, fileName: any, ContentType: any, states: any}): Promise<any>;
}
declare module "@salesforce/apex/WilsonManagePosItems_Apex.getAllState" {
  export default function getAllState(): Promise<any>;
}
declare module "@salesforce/apex/WilsonManagePosItems_Apex.getAllAndSelectedStates" {
  export default function getAllAndSelectedStates(param: {posItemId: any}): Promise<any>;
}
declare module "@salesforce/apex/WilsonManagePosItems_Apex.getBrandList" {
  export default function getBrandList(): Promise<any>;
}
declare module "@salesforce/apex/WilsonManagePosItems_Apex.getItemTypeList" {
  export default function getItemTypeList(): Promise<any>;
}
declare module "@salesforce/apex/WilsonManagePosItems_Apex.searchPOSItem" {
  export default function searchPOSItem(param: {searchText: any, selectedBrand: any, selectedItemType: any}): Promise<any>;
}
declare module "@salesforce/apex/WilsonManagePosItems_Apex.deactivateSelectedItem" {
  export default function deactivateSelectedItem(param: {posItem: any}): Promise<any>;
}
