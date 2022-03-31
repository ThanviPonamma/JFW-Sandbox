declare module "@salesforce/apex/InfiniumManageProgramBudget_Apex.getAccount" {
  export default function getAccount(): Promise<any>;
}
declare module "@salesforce/apex/InfiniumManageProgramBudget_Apex.loadProgramList_Apex" {
  export default function loadProgramList_Apex(): Promise<any>;
}
declare module "@salesforce/apex/InfiniumManageProgramBudget_Apex.loadChairBudgetList_Apex" {
  export default function loadChairBudgetList_Apex(param: {programId: any}): Promise<any>;
}
declare module "@salesforce/apex/InfiniumManageProgramBudget_Apex.checkAndValidateAllocatedChairBudget_Apex" {
  export default function checkAndValidateAllocatedChairBudget_Apex(param: {programId: any, chairBudgetId: any, newAllocatedBudgetValue: any}): Promise<any>;
}
declare module "@salesforce/apex/InfiniumManageProgramBudget_Apex.IncreaseBudget" {
  export default function IncreaseBudget(param: {programId: any, chairBudgetId: any, amountToIncrease: any}): Promise<any>;
}
declare module "@salesforce/apex/InfiniumManageProgramBudget_Apex.ReduceBudget" {
  export default function ReduceBudget(param: {programId: any, chairBudgetId: any, amountToReduce: any}): Promise<any>;
}
