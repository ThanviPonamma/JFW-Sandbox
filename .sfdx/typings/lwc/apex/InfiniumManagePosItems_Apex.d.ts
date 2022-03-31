declare module "@salesforce/apex/InfiniumManagePosItems_Apex.addOrEditPOSItem_Apex" {
  export default function addOrEditPOSItem_Apex(param: {posItem: any, imageBlobData: any, fileName: any, ContentType: any, states: any}): Promise<any>;
}
declare module "@salesforce/apex/InfiniumManagePosItems_Apex.getAllState" {
  export default function getAllState(): Promise<any>;
}
declare module "@salesforce/apex/InfiniumManagePosItems_Apex.getAllAndSelectedStates" {
  export default function getAllAndSelectedStates(param: {posItemId: any}): Promise<any>;
}
declare module "@salesforce/apex/InfiniumManagePosItems_Apex.getBrandList_Apex" {
  export default function getBrandList_Apex(): Promise<any>;
}
declare module "@salesforce/apex/InfiniumManagePosItems_Apex.getItemTypeList_Apex" {
  export default function getItemTypeList_Apex(): Promise<any>;
}
declare module "@salesforce/apex/InfiniumManagePosItems_Apex.searchPOSItem_Apex" {
  export default function searchPOSItem_Apex(param: {searchText: any, selectedBrand: any, selectedItemType: any, recordStartIndex: any}): Promise<any>;
}
declare module "@salesforce/apex/InfiniumManagePosItems_Apex.deactivateSelectedItem" {
  export default function deactivateSelectedItem(param: {posItem: any}): Promise<any>;
}
