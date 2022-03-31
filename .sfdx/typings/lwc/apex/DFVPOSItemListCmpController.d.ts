declare module "@salesforce/apex/DFVPOSItemListCmpController.getPOSItemList" {
  export default function getPOSItemList(param: {recordStartIndex: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVPOSItemListCmpController.addPOSItem" {
  export default function addPOSItem(param: {posItem: any, imageBlobData: any, fileName: any, ContentType: any, searchKey: any, searchbrandId: any, searchPosItemTypeId: any, recordStartIndex: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVPOSItemListCmpController.getBrandAndItemTypeOptions" {
  export default function getBrandAndItemTypeOptions(param: {posItem: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVPOSItemListCmpController.getBrandList" {
  export default function getBrandList(): Promise<any>;
}
declare module "@salesforce/apex/DFVPOSItemListCmpController.getItemTypeList" {
  export default function getItemTypeList(): Promise<any>;
}
declare module "@salesforce/apex/DFVPOSItemListCmpController.searchPOSItem" {
  export default function searchPOSItem(param: {searchText: any, selBrand: any, selItemType: any, recordStartIndex: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVPOSItemListCmpController.deactivateSelectedItem" {
  export default function deactivateSelectedItem(param: {posItem: any, searchText: any, selBrand: any, selItemType: any, recordStartIndex: any}): Promise<any>;
}
