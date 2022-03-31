declare module "@salesforce/apex/CopperManageBuyBookBudget_Apex.getAccount" {
  export default function getAccount(): Promise<any>;
}
declare module "@salesforce/apex/CopperManageBuyBookBudget_Apex.loadBuyBookList_Apex" {
  export default function loadBuyBookList_Apex(): Promise<any>;
}
declare module "@salesforce/apex/CopperManageBuyBookBudget_Apex.loadChairBudgetList_Apex" {
  export default function loadChairBudgetList_Apex(param: {buyBookId: any}): Promise<any>;
}
declare module "@salesforce/apex/CopperManageBuyBookBudget_Apex.checkAndValidateAllocatedChairBudget_Apex" {
  export default function checkAndValidateAllocatedChairBudget_Apex(param: {buyBookId: any, chairBudgetId: any, newAllocatedBudgetValue: any}): Promise<any>;
}
declare module "@salesforce/apex/CopperManageBuyBookBudget_Apex.IncreaseBudget" {
  export default function IncreaseBudget(param: {buyBookId: any, chairBudgetId: any, amountToIncrease: any}): Promise<any>;
}
declare module "@salesforce/apex/CopperManageBuyBookBudget_Apex.ReduceBudget" {
  export default function ReduceBudget(param: {buyBookId: any, chairBudgetId: any, amountToReduce: any}): Promise<any>;
}
