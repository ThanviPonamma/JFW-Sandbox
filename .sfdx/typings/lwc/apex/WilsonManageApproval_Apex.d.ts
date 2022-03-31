declare module "@salesforce/apex/WilsonManageApproval_Apex.getAccount" {
  export default function getAccount(): Promise<any>;
}
declare module "@salesforce/apex/WilsonManageApproval_Apex.loadAllCometApprovalOrders" {
  export default function loadAllCometApprovalOrders(): Promise<any>;
}
declare module "@salesforce/apex/WilsonManageApproval_Apex.loadShippingMethodList" {
  export default function loadShippingMethodList(): Promise<any>;
}
declare module "@salesforce/apex/WilsonManageApproval_Apex.approveShippingMethod" {
  export default function approveShippingMethod(param: {cometOrder: any}): Promise<any>;
}
declare module "@salesforce/apex/WilsonManageApproval_Apex.rejectShippingMethod" {
  export default function rejectShippingMethod(param: {cometOrder: any}): Promise<any>;
}
declare module "@salesforce/apex/WilsonManageApproval_Apex.approveOrderedItem" {
  export default function approveOrderedItem(param: {cometOrderItem: any}): Promise<any>;
}
declare module "@salesforce/apex/WilsonManageApproval_Apex.rejectOrderedItem" {
  export default function rejectOrderedItem(param: {cometOrderItem: any}): Promise<any>;
}
declare module "@salesforce/apex/WilsonManageApproval_Apex.approveMaximumOrderQuantity" {
  export default function approveMaximumOrderQuantity(param: {cometOrderItem: any}): Promise<any>;
}
declare module "@salesforce/apex/WilsonManageApproval_Apex.rejectMaximumOrderQuantity" {
  export default function rejectMaximumOrderQuantity(param: {cometOrderItem: any}): Promise<any>;
}
