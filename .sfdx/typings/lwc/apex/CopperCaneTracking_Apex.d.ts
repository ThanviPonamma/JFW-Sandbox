declare module "@salesforce/apex/CopperCaneTracking_Apex.getAccount_Apex" {
  export default function getAccount_Apex(): Promise<any>;
}
declare module "@salesforce/apex/CopperCaneTracking_Apex.getProgramList_Apex" {
  export default function getProgramList_Apex(): Promise<any>;
}
declare module "@salesforce/apex/CopperCaneTracking_Apex.getBrandList" {
  export default function getBrandList(): Promise<any>;
}
declare module "@salesforce/apex/CopperCaneTracking_Apex.getProgramPOSList_Apex" {
  export default function getProgramPOSList_Apex(param: {selectedProgramId: any, selectedBrandId: any}): Promise<any>;
}
declare module "@salesforce/apex/CopperCaneTracking_Apex.getTrackingNumbersOfOrders_Apex" {
  export default function getTrackingNumbersOfOrders_Apex(param: {accountId: any, selectedProgramId: any, selectedPOSItemNo: any}): Promise<any>;
}
declare module "@salesforce/apex/CopperCaneTracking_Apex.synchronizeCopperTracking_Apex" {
  export default function synchronizeCopperTracking_Apex(param: {accountId: any, selectedProgramId: any, selectedPOSItemNo: any}): Promise<any>;
}
declare module "@salesforce/apex/CopperCaneTracking_Apex.UploadCopperTracking_Apex" {
  export default function UploadCopperTracking_Apex(param: {accountId: any, contentDocumentId: any, selectedProgramId: any, selectedPOSItemNo: any}): Promise<any>;
}
