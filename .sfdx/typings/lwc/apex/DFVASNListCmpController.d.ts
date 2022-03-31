declare module "@salesforce/apex/DFVASNListCmpController.getAdvanceShipmentList" {
  export default function getAdvanceShipmentList(): Promise<any>;
}
declare module "@salesforce/apex/DFVASNListCmpController.getUnSelected_PosItemsList" {
  export default function getUnSelected_PosItemsList(): Promise<any>;
}
declare module "@salesforce/apex/DFVASNListCmpController.getUnSavedASN_PosItemsList" {
  export default function getUnSavedASN_PosItemsList(): Promise<any>;
}
declare module "@salesforce/apex/DFVASNListCmpController.getSubmittedASNPosItemsList" {
  export default function getSubmittedASNPosItemsList(param: {existingId: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVASNListCmpController.searchASN" {
  export default function searchASN(param: {searchKeyword: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVASNListCmpController.loadPosItemList" {
  export default function loadPosItemList(param: {selectedASNId: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVASNListCmpController.saveAdvanceShipmentNotice" {
  export default function saveAdvanceShipmentNotice(param: {advanceShipmentNotice: any, selectedPosItemList: any, actionType: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVASNListCmpController.searchPosItems" {
  export default function searchPosItems(param: {searchKeyWord: any, unSelectedTotalPosItemList: any}): Promise<any>;
}
