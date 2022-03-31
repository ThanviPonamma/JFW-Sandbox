declare module "@salesforce/apex/JFWInventoryPOSCatalog_Apex.getAccount" {
  export default function getAccount(): Promise<any>;
}
declare module "@salesforce/apex/JFWInventoryPOSCatalog_Apex.getPOSItemList" {
  export default function getPOSItemList(): Promise<any>;
}
declare module "@salesforce/apex/JFWInventoryPOSCatalog_Apex.getBrandList" {
  export default function getBrandList(): Promise<any>;
}
declare module "@salesforce/apex/JFWInventoryPOSCatalog_Apex.getItemTypeList" {
  export default function getItemTypeList(): Promise<any>;
}
declare module "@salesforce/apex/JFWInventoryPOSCatalog_Apex.searchPOSItem" {
  export default function searchPOSItem(param: {searchText: any, selectedBrandId: any, selectedItemTypeId: any}): Promise<any>;
}
