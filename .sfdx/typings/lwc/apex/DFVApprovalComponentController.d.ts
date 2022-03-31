declare module "@salesforce/apex/DFVApprovalComponentController.getAccount" {
  export default function getAccount(): Promise<any>;
}
declare module "@salesforce/apex/DFVApprovalComponentController.loadAllCometApprovalOrders" {
  export default function loadAllCometApprovalOrders(): Promise<any>;
}
declare module "@salesforce/apex/DFVApprovalComponentController.loadShippingMethodList" {
  export default function loadShippingMethodList(): Promise<any>;
}
declare module "@salesforce/apex/DFVApprovalComponentController.approveShippingMethod" {
  export default function approveShippingMethod(param: {cometOrder: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVApprovalComponentController.rejectShippingMethod" {
  export default function rejectShippingMethod(param: {cometOrder: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVApprovalComponentController.approveOrderedItem" {
  export default function approveOrderedItem(param: {cometOrderItem: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVApprovalComponentController.rejectOrderedItem" {
  export default function rejectOrderedItem(param: {cometOrderItem: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVApprovalComponentController.approveMaximumOrderQuantity" {
  export default function approveMaximumOrderQuantity(param: {cometOrderItem: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVApprovalComponentController.rejectMaximumOrderQuantity" {
  export default function rejectMaximumOrderQuantity(param: {cometOrderItem: any}): Promise<any>;
}
