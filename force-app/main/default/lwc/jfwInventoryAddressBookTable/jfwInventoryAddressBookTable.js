import {
    LightningElement,
    track,
    wire,
    api
} from 'lwc';
//To get the address list from the apex class "JFWInventoryAddressBook" with the method "LoadAddressBookListWithSearch"
import getAddressList from '@salesforce/apex/JFWInventoryAddressBook.LoadAddressBookListWithSearch'

// To get the deactive method from the apex class "JFWInventoryAddressBook" to deactivate the address
import deactivateAddressBook from '@salesforce/apex/JFWInventoryAddressBook.deactivateAddressBook'

// To get the state list from the apex class "JFWInventoryAddressBook" along with the method "getAllStates"
import getStates from '@salesforce/apex/JFWInventoryAddressBook.getAllStates'

// Import method refresh the page
import {
    refreshApex
} from '@salesforce/apex';
//to display toast message
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

export default class JfwInventoryAddressBookTable extends LightningElement {

    //To hold the search value
    @api getSearchValue = '';
    //to hold the address list to display
    @track addressList;
    //to hold the selected addres to be sent to the child component
    @api selectAddressBook;
    //to hold the modal open/close value
    @track isModalOpen = false;
    //to hold the state list to display
    @api stateListToDisplay;
    //to hold edit clcik value
    @api isEditClicked;
    //to hold label name
    @api labelName;

    // pagination
    //to hold total address size
    @track totalAddressListSize;
    //to hold pagination details
    @track navigationItems;
    //to hold start index value
    @track startIndex;
    //to hold last index value
    @track lastIndex;
    //to hold selected page number
    @track selectedIndex;
    //to hold reacord start index for pagination
    @track recordStartIndex;
    //to hold if the last navigation button should be be displayed
    @track isItLastNavigationItem = false;
    //to hold if the first navigation button should be be displayed
    @track isItFirstNavigationItem = false;
    @track adrressFound = false;

    connectedCallback(){
        this.doInit();
    }
    //init method to set pagination values
    @api
    doInit() {
        this.recordStartIndex = 0;
        this.startIndex = 1;
        this.lastIndex = 5;
        this.selectedIndex = 1;
    }
    // To get the list with address by giving search as the parameter from Import method with the help of wire property.
    @wire(getAddressList, {
        searchKeyword: '$getSearchValue',
        recordStartIndex: '$recordStartIndex'
    })
    getAddresssBookListwithSearch;


    // To retreive the list of address from @wire property using get method
    get addressBookToBeDisplayed() {
        if (this.getAddresssBookListwithSearch.data) {
            //   console.log("entered",JSON.stringify(this.getAddresssBookListwithSearch.data));
            //To hold the address details from the apex method
            let addressBookDetailsWrapper = this.getAddresssBookListwithSearch.data;
            //to hold the addresses to be displaed
            this.addressList = addressBookDetailsWrapper.AddressBookList;
            // console.log('addressList-->',JSON.stringify(this.addressList));
            //to check if the address list is greater than 0
            if (this.addressList.length == 0) {
                this.adrressFound = false;
            } else {
                this.adrressFound = true;
            }
            //to hold the address list size
            this.totalAddressListSize = addressBookDetailsWrapper.totalAddressBookSize;
            // console.log('totalAddressListSize-->',JSON.stringify(this.totalAddressListSize));
            //to invoke the pagination
            this.setNavigationItems(this.startIndex, this.lastIndex);
            //to set that pagination is required
            this.isPagination = true;
            //to refresh the address list
            refreshApex(this.getAddresssBookListwithSearch);
        }
    }

    // To get the state list from the "getStates" method from import 
    @wire(getStates)
    getStateList({
        data,
        error
    }) {
        if (data) {

            this.stateListToDisplay = [{
                value: '',
                label: 'Select'
            }];
            // for each program
            data.forEach(element => {
                const state = {};

                state.label = element.State_Name__c;

                state.value = element.Id;

                this.stateListToDisplay.push(state);
            });
        } else if (error) {

        }
    }

    // To close the popup modal
    closeModal() {
        this.isModalOpen = false;
        // console.log("Reached Modal closed");
        refreshApex(this.getAddresssBookListwithSearch);
    }

    // To open the popup modal on click of the button
    openEditPopUp(event) {
        this.isModalOpen = true;
        this.isEditClicked = true;
        this.selectAddressBook = event.target.name;
        this.labelName = this.selectAddressBook.Destination_Name__c;

    }

    // On click of the toggle to deactivate the address
    deactivateAddress(event) {
        let addressBook = event.target.name;
        // console.log('addressBook-->',JSON.stringify(addressBook));
        deactivateAddressBook({
                selectedAddressBook: JSON.stringify(addressBook)
            })
            .then(result => {
                let resultGiven = result;
                const evt = new ShowToastEvent({
                    title: 'Success',
                    message: 'The "' + addressBook.Destination_Name__c + '" has been deactivated successfully.',
                    variant: 'success',
                });
                this.dispatchEvent(evt);
                return refreshApex(this.getAddresssBookListwithSearch);
            })
    }


    //To add the pagination to the addresss

    setNavigationItems(startnumber, lastnumber) {
        //each page 100 addresses are displayed
        let totalNavigationItems = Math.ceil(this.totalAddressListSize / 100);
        let navigationItemList = [];
        for (let i = startnumber; i <= lastnumber; i++) {
            let recordStartIndex = (i - 1) * 100;
            let recordLastIndex = recordStartIndex + 99;
            let navigationItem = {
                "index": i, //too display page numbers
                "recordStartIndex": recordStartIndex, //to display start index number
                "recordLastIndex": recordLastIndex,
                "isRecordExisted": i <= totalNavigationItems, //to check if the address existing
                "isIndexSelected": i == this.selectedIndex //to check the page number
            };
            navigationItemList.push(navigationItem);
        }
        if (navigationItemList.length != 0) {
            let lastNavigationIndex = navigationItemList[navigationItemList.length - 1].index;
            if (lastNavigationIndex == totalNavigationItems || lastNavigationIndex > totalNavigationItems) {
                this.isItLastNavigationItem = true;
            } else {
                this.isItLastNavigationItem = false;
            }
            if (navigationItemList[0].index == 1) {
                this.isItFirstNavigationItem = true;
            } else {
                this.isItFirstNavigationItem = false;
            }
        }

        this.navigationItems = navigationItemList;
        // console.log("REACHED navigationItems",JSON.stringify(this.navigationItems));
    }

    // Onclick of first button in the page this method should invoked to display the addressses
    firstNavigationButton() {
        this.startIndex = 1;
        this.lastIndex = 5;
        this.selectedIndex = 1;
        this.recordStartIndex = 0;
        return refreshApex(this.getAddresssBookListwithSearch);
    }
    // on click of previous navigation button
    previousNavigationButton() {
        if (this.navigationItems[0].recordStartIndex > 0) {
            this.startIndex = this.navigationItems[0].index - 5;
            this.lastIndex = this.startIndex + 4;
            this.selectedIndex = this.navigationItems[0].index - 5;
            this.recordStartIndex = this.navigationItems[0].recordStartIndex - 500;
            return refreshApex(this.getAddresssBookListwithSearch);
        } else {
            this.isItFirstNavigationItem = true;
        }
    }

    // on click of next navigation button
    nextNavigationButton() {
        if (this.navigationItems[4].isRecordExisted == true) {
            this.startIndex = this.navigationItems[0].index + 5;
            this.lastIndex = this.startIndex + 4;
            this.selectedIndex = this.navigationItems[4].index + 1;
            this.recordStartIndex = this.navigationItems[4].recordLastIndex + 1;
            return refreshApex(this.getAddresssBookListwithSearch)
        }
    }
    // on click of last naogation
    lastNavigationButton() {
        this.lastIndex = Math.ceil(Math.ceil(this.totalAddressListSize / 100) / 5) * 5;;
        this.startIndex = this.lastIndex - 4;
        this.selectedIndex = this.lastIndex - 4;
        this.recordStartIndex = (this.startIndex - 1) * 100;
        return refreshApex(this.getAddresssBookListwithSearch)
    }

    // On click of each index the list of addresses for each button to be diplayed
    getAddressListByIndex(event) {
        let selectedPageNumber = event.target.value;
        this.selectedIndex = selectedPageNumber.index;
        this.recordStartIndex = selectedPageNumber.recordStartIndex;
        this.isPagination = true;
        return refreshApex(this.getAddresssBookListwithSearch)

    }

}