declare module "@salesforce/apex/CopperManageAddressBook_Apex.currentUser" {
  export default function currentUser(): Promise<any>;
}
declare module "@salesforce/apex/CopperManageAddressBook_Apex.getProfile" {
  export default function getProfile(): Promise<any>;
}
declare module "@salesforce/apex/CopperManageAddressBook_Apex.getAccount" {
  export default function getAccount(): Promise<any>;
}
declare module "@salesforce/apex/CopperManageAddressBook_Apex.loadAddressBookListWithSearch" {
  export default function loadAddressBookListWithSearch(param: {searchKeyword: any, recordStartIndex: any}): Promise<any>;
}
declare module "@salesforce/apex/CopperManageAddressBook_Apex.deactivateAddressBook" {
  export default function deactivateAddressBook(param: {selectedAddressBook: any}): Promise<any>;
}
declare module "@salesforce/apex/CopperManageAddressBook_Apex.getAllStates" {
  export default function getAllStates(): Promise<any>;
}
declare module "@salesforce/apex/CopperManageAddressBook_Apex.updateAddressBook" {
  export default function updateAddressBook(param: {selectedAddressBook: any}): Promise<any>;
}
declare module "@salesforce/apex/CopperManageAddressBook_Apex.synchronizeAddressBook" {
  export default function synchronizeAddressBook(): Promise<any>;
}
