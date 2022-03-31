declare module "@salesforce/apex/DFVBudgetComponentController.loadPrograms_Apex" {
  export default function loadPrograms_Apex(): Promise<any>;
}
declare module "@salesforce/apex/DFVBudgetComponentController.saveProgramBudget_Apex" {
  export default function saveProgramBudget_Apex(param: {programId: any, totalMarketingBudget: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVBudgetComponentController.saveChairBudgetList_Apex" {
  export default function saveChairBudgetList_Apex(param: {chairBudgetList: any, programId: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVBudgetComponentController.loadChairBudgetList_Apex" {
  export default function loadChairBudgetList_Apex(param: {programId: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVBudgetComponentController.checkAndValidateAllocatedChairBudget_Apex" {
  export default function checkAndValidateAllocatedChairBudget_Apex(param: {programId: any, chairBudgetId: any, newAllocatedBudgetValue: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVBudgetComponentController.IncreaseBudget" {
  export default function IncreaseBudget(param: {programId: any, chairBudgetId: any, amountToIncrease: any}): Promise<any>;
}
declare module "@salesforce/apex/DFVBudgetComponentController.ReduceBudget" {
  export default function ReduceBudget(param: {programId: any, chairBudgetId: any, amountToReduce: any}): Promise<any>;
}
