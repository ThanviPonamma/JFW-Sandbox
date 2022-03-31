declare module "@salesforce/apex/JFWInventoryAddressBook.currentUser" {
  export default function currentUser(): Promise<any>;
}
declare module "@salesforce/apex/JFWInventoryAddressBook.getAccount" {
  export default function getAccount(): Promise<any>;
}
declare module "@salesforce/apex/JFWInventoryAddressBook.LoadAddressBookListWithSearch" {
  export default function LoadAddressBookListWithSearch(param: {searchKeyword: any, recordStartIndex: any}): Promise<any>;
}
declare module "@salesforce/apex/JFWInventoryAddressBook.deactivateAddressBook" {
  export default function deactivateAddressBook(param: {selectedAddressBook: any}): Promise<any>;
}
declare module "@salesforce/apex/JFWInventoryAddressBook.getAllStates" {
  export default function getAllStates(): Promise<any>;
}
declare module "@salesforce/apex/JFWInventoryAddressBook.updateAddressBook" {
  export default function updateAddressBook(param: {selectedAddressBook: any}): Promise<any>;
}
