declare module "@salesforce/apex/DFVSendWaveOrders_Apex.getAccount" {
  export default function getAccount(): Promise<any>;
}
declare module "@salesforce/apex/DFVSendWaveOrders_Apex.loadProgramList" {
  export default function loadProgramList(): Promise<any>;
}
declare module "@salesforce/apex/DFVSendWaveOrders_Apex.loadUserList" {
  export default function loadUserList(param: {selectedProgramId: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVSendWaveOrders_Apex.loadAvailableCometOrders" {
  export default function loadAvailableCometOrders(param: {selectedProgramId: any, selectedUserId: any, searchkeyWord: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVSendWaveOrders_Apex.loadSelectedCometOrders" {
  export default function loadSelectedCometOrders(param: {selectedProgramId: any, selectedUserId: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVSendWaveOrders_Apex.loadPosItemsForCometOrder" {
  export default function loadPosItemsForCometOrder(param: {selectedOrderDestinationId: any}): Promise<any>;
}
