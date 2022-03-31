import {LightningElement,track,wire,api} from 'lwc';
// To import the "getAllStates" method from the apex class "JFWInventoryAddressBook"
import getStates from '@salesforce/apex/JFWInventoryAddressBook.getAllStates'


export default class JfwInventoryCreateAndSearchAddressBook extends LightningElement {

    // The variable to hold the search keyword entered by the users
    @track searchedKeyword = '';

    // Boolean variable to open the child component
    @track isModalOpen = false;

    // Using @api global property to get the list of all address from child component
    @api selectAddressBook;

    // @api property to send the state list to child component
    @api stateListToDisplay;
    //to hold the if the button clciked is edit /create.
    @api isEditClicked;


    // To get the list of all the states from import method
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
                //to hold the state list to the child component
                this.stateListToDisplay.push(state);
            });
        } else if (error) {

        }

    }

    // To close the modal on click of save/cancel button
    closeModal() {
        this.isModalOpen = false;
    }

    // To open the modal on click of Create Address button
    openCreatePopUp() {
        //to open the pop-up modal
        this.isModalOpen = true;
        //the list is sent empty to capture the value for while creating the address
        this.selectAddressBook = {};
        //the button clicked is create, so set to false
        this.isEditClicked = false;
    }


    //  To hold the user searched values
    searchAddressBook(event) {
        this.searchedKeyword = event.detail.value;
        //the value is sent to parent to load the addreses without a search key
        if (this.searchedKeyword == '' || this.searchedKeyword == null) {
            // custom event "sendsearchdatatoavailable" is called in the parent html. This event holds the searchKeyword
            const searchvent = new CustomEvent('sendsearchdatatoparent', {
                detail: this.searchedKeyword
            });
            this.dispatchEvent(searchvent);
        }
    }


    // To search the value on click of button
    searchEvent(event) {

        if (this.searchedKeyword != '' || this.searchedKeyword != null) {

            // custom event "sendsearchdatatoavailable" is called in the parent html. This event holds the searchKeyword
            const searchvent = new CustomEvent('sendsearchdatatoparent', {
                detail: this.searchedKeyword
            });
            this.dispatchEvent(searchvent);
        }
    }
}