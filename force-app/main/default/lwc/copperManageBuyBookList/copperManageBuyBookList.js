/**Author:Thanvi Date:09-Aug-2021
Aim: This is the child component that is responsible for displaying Buy Book table */

import {LightningElement,wire,track,api} from 'lwc';
import getAllBuyBookList from '@salesforce/apex/CopperManageBuyBookList_Apex.getBuyBooksList_Apex'
import deactivateSelectedBuyBook from '@salesforce/apex/CopperManageBuyBookList_Apex.deactivateBuyBook_Apex'
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {refreshApex} from '@salesforce/apex';
// to display no image
import noImage from '@salesforce/resourceUrl/noimageavailable';

export default class CopperManageBuyBookList extends LightningElement {
    // no image variable
    NoImageURL = noImage;
    //holds the data coming from the apex method getAllBuyBookList()
    @track allBuyBookList;
    // holds only the list of buy book details
    @track buyBooks;
    //to hold buyBookNameForValidation coming from apex class
    @api buyBookNameForValidation;
    //boolean value to open buy book edit/create pop-up
    @track openEditModal = false;
    //to hold the type of button selected by the user
    @api selectedButtonName;
    //to know if the button clicked is create or edit
    @track isEditClicked;
    //to hold the name of the buy book as label 
    @api labelName;
    //boolean value to open item modal pop-up
    @track openItemModal
    //to know if the button clicked is 'save and new'
    @api saveandnew;
    //boolean value to open edit/create
    @api isModalOpen;
    //to diplay the toast message to add budget to the buy book
    @track isOpenModalForToastMessage = false;
    @wire(getAllBuyBookList) buyBookList;

    // To display the message if no data is found in the buy book
    @track buyBookNotFound = false;

    //to get the list of buy book on page init 
    get getAllBuyBook() {

        //   check if the buyBookList has data 
        if (this.buyBookList.data) {
            // add the data received to the variable allBuyBookList
            this.allBuyBookList = this.buyBookList.data;
            // holds only the list of buy book details
            this.buyBooks = this.allBuyBookList.buyBookList;
            // to hold buyBookNameForValidation coming from apex class
            this.buyBookNameForValidation = this.allBuyBookList.buyBookNamesForValidation;
            // to check if the buyBooks has data or not
            if (this.buyBooks.length == 0) {
                this.buyBookNotFound = false;
            } else {
                this.buyBookNotFound = true;
            }

        }
    }


    //to deactivate a buy book on click of toggle button
    deactivateBuyBook(event) {
        // to hold the name of the selected buy book
        let selectedbuyBook = event.target.name;
        deactivateSelectedBuyBook({
            // to hold the variable buy book and sending to the apex method as parameter
            buybook: JSON.stringify(selectedbuyBook)
        })
            .then(result => {
                // to hold the result returned by the apex method
                let resultGiven = result;
                // if the result is success display the toast message
                if (resultGiven) {
                    const evt = new ShowToastEvent({
                        message: 'The Buy Book"' + JSON.stringify(selectedbuyBook.Name__c) + '" has been deactivated successfully.',
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);

                }
                // refresh the buy book list
                return refreshApex(this.buyBookList);
            })
    }

    //to open create buy book modal 
    onCreateBuyBook(event) {
        // to hold the list of buy book to be sent to the grand child
        let temp = {
            "buyBook": {
                "Name__c": "",
                "Closing_Date__c": "",
                "Account__c": "",
                "Program_Budget__c": '',
                "In_Market_Date__c": "",
                "Name": "",
                "Start_Date__c": "",
                "Active__c": true,
                "Attachment_Id__c": ''
            },
            "buyBookImageURL": ""
        }
        this.selectedBuyBookDetails = temp;
        //  open the pop-up modal
        this.openEditModal = true;
        //  giving false value to the variable isEditClicked which means that the edit icon is not clicked
        this.isEditClicked = false;
        //send an empty string in the variable labelName
        this.labelName = '';
        //To hold the type of button clicked by the user
        this.selectedButtonName = 'CREATE';
    }

    //to open edit buy book modal
    openEditPopUp(event) {
        //To hold the type of button clicked by the user
        this.selectedButtonName = 'EDIT';
        // open the pop-up modal
        this.openEditModal = true;
        // giving true value to the variable isEditClicked which means that the edit icon is clicked
        this.isEditClicked = true;
        // To hold the details of the selected buy book
        let buyBookDetails = event.target.name;
        // to hold the list of buy books to be sent to the grand child
        this.selectedBuyBookDetails = buyBookDetails;
        // to hold the name of the buy book as label 
        this.labelName = buyBookDetails.buyBook.Name__c;

    }
    addOrRemoveItems(event) {
        // open the pop-up modal
        this.openItemModal = true;
        // To hold the details of the selected buy book
        let buyBookDetails = event.target.name;
        // to hold the list of buy books to be sent to the grand child
        this.selectedBuyBookDetails = buyBookDetails;
        // to hold the name of the buy book as label 
        this.labelName = buyBookDetails.Name__c;
    }
    //to close the edit/create modal
    closeModal(event) {
        //fetching the value from the child and giving it to the variable openEditModal
        this.openEditModal = event.detail.isModalOpen;
        //fetching the value from the child and giving it to the variable issaveAndNew
        let issaveAndNew = event.detail.saveandnew;
         //fetching the value from the child and giving it to the variable isItemModal
        let isItemModal = event.detail.isItemModal;
        //    check if the button clicked is "save and new"
        if (issaveAndNew) {
            // close the pop-up modal
            this.openEditModal = false;
            // invoke the method onCreateBuyBook
            this.onCreateBuyBook();
        }
        if(isItemModal){
            this.openItemModal = false;
        }
        if(this.selectedButtonName=='CREATE' && issaveAndNew == false){
            this.isOpenModalForToastMessage = true;
        }
        // refresh the buy book list
        return refreshApex(this.buyBookList);
    }
    //to close the toast mesage pop-up
    closeMessageModel(event){
        this.isOpenModalForToastMessage = false;
    }
}