declare module "@salesforce/apex/InfiniumWaveOrders_Apex.getAccount" {
  export default function getAccount(): Promise<any>;
}
declare module "@salesforce/apex/InfiniumWaveOrders_Apex.loadProgramList" {
  export default function loadProgramList(): Promise<any>;
}
declare module "@salesforce/apex/InfiniumWaveOrders_Apex.loadBrandList" {
  export default function loadBrandList(): Promise<any>;
}
declare module "@salesforce/apex/InfiniumWaveOrders_Apex.loadWithheldItems" {
  export default function loadWithheldItems(param: {selectedProgramId: any, selectedBrandId: any}): Promise<any>;
}
declare module "@salesforce/apex/InfiniumWaveOrders_Apex.loadAvailableItems" {
  export default function loadAvailableItems(param: {selectedProgramId: any, selectedBrandId: any}): Promise<any>;
}
