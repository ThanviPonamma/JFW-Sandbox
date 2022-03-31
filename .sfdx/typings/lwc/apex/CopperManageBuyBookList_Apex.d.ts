declare module "@salesforce/apex/CopperManageBuyBookList_Apex.getAccount" {
  export default function getAccount(): Promise<any>;
}
declare module "@salesforce/apex/CopperManageBuyBookList_Apex.getBuyBooksList_Apex" {
  export default function getBuyBooksList_Apex(): Promise<any>;
}
declare module "@salesforce/apex/CopperManageBuyBookList_Apex.saveBuyBook_Apex" {
  export default function saveBuyBook_Apex(param: {buybook: any, imageBlobData: any, fileName: any, ContentType: any, selectedButtonName: any}): Promise<any>;
}
declare module "@salesforce/apex/CopperManageBuyBookList_Apex.createChairBudget_Apex" {
  export default function createChairBudget_Apex(param: {buybook: any}): Promise<any>;
}
declare module "@salesforce/apex/CopperManageBuyBookList_Apex.deactivateBuyBook_Apex" {
  export default function deactivateBuyBook_Apex(param: {buybook: any}): Promise<any>;
}
declare module "@salesforce/apex/CopperManageBuyBookList_Apex.addPosItemToBuyBook_Apex" {
  export default function addPosItemToBuyBook_Apex(param: {buyBook: any, posItem: any}): Promise<any>;
}
declare module "@salesforce/apex/CopperManageBuyBookList_Apex.removePosItemFromBuyBook_Apex" {
  export default function removePosItemFromBuyBook_Apex(param: {buyBook: any, posItem: any}): Promise<any>;
}
declare module "@salesforce/apex/CopperManageBuyBookList_Apex.getBuyBookItemList_Apex" {
  export default function getBuyBookItemList_Apex(param: {buyBookId: any}): Promise<any>;
}
