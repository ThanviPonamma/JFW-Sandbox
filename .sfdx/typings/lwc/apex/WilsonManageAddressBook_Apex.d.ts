declare module "@salesforce/apex/WilsonManageAddressBook_Apex.currentUser" {
  export default function currentUser(): Promise<any>;
}
declare module "@salesforce/apex/WilsonManageAddressBook_Apex.getProfile" {
  export default function getProfile(): Promise<any>;
}
declare module "@salesforce/apex/WilsonManageAddressBook_Apex.getAccount" {
  export default function getAccount(): Promise<any>;
}
declare module "@salesforce/apex/WilsonManageAddressBook_Apex.loadAddressBookListWithSearch" {
  export default function loadAddressBookListWithSearch(param: {searchKeyword: any, recordStartIndex: any}): Promise<any>;
}
declare module "@salesforce/apex/WilsonManageAddressBook_Apex.deactivateAddressBook" {
  export default function deactivateAddressBook(param: {selectedAddressBook: any}): Promise<any>;
}
declare module "@salesforce/apex/WilsonManageAddressBook_Apex.getAllStates" {
  export default function getAllStates(): Promise<any>;
}
declare module "@salesforce/apex/WilsonManageAddressBook_Apex.updateAddressBook" {
  export default function updateAddressBook(param: {selectedAddressBook: any}): Promise<any>;
}
declare module "@salesforce/apex/WilsonManageAddressBook_Apex.synchronizeAddressBook" {
  export default function synchronizeAddressBook(): Promise<any>;
}
