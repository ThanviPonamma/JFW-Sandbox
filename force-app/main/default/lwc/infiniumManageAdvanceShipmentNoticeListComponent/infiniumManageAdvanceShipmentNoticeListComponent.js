// Authors:Sanjana   Date:05-11-2021
// Aim: This is the child component that is responsible for getting ASN details and to capture & store the values to be sent to the child component
import {LightningElement,wire,api,track
} from 'lwc';
//To get the Asn list to be displayed
import searchASN from '@salesforce/apex/InfiniumGetASNList_Apex.searchASN'
//To refresh the Apex 
import {refreshApex} from '@salesforce/apex';

export default class InfiniumManageAdvanceShipmentNoticeListComponent extends LightningElement {

    //To dispaly the ASN details in the tabled
    @track allASNToDisplay;
    //To open the child compoennt to create/edit
    @track isModalopen = false;
    //To open the child compoennt to view
    @track isViewModal = false;
    //To check iof edit/create button is clicked
    @api isEditClicked;
    //To hold the ASN details to be sent to the child
    @api asnDetailsToBeSent;
    //To hold the search key
    @track searchKeyword = '';
    //To hold the if the asn details is found or not
    @track asnListFound = false;

    @wire(searchASN, {
        searchKeyword: '$searchKeyword'
    }) allASN;
    // To get the ASN details to be displayed
    get getAllASNList() {
        console.log('entered')
        if (this.allASN.data) {
            // To hold the ASN details to be dispalyed
            this.allASNToDisplay = this.allASN.data;
            console.log('this.allASNToDisplay--->',JSON.stringify(this.allASNToDisplay))
            //To set to false if ASN exists else to true
            
            if (this.allASNToDisplay.length == 0) {
                this.asnListFound = false;
            } else {
                this.asnListFound = true;
            }
        }
    }
     // Method is invoked on click of create button
     openCreateModal(event) {
        //To store the value to 'asnDetailsToBeSent' to send to child component  
        this.asnDetailsToBeSent = {};
         //To set the value to true to open the child popup
        this.isModalopen = true;
        //To set the value to false, since the cretae button is clicked
        this.isEditClicked = false;
        //To set the value to false
        this.isViewModal = false;


    }
    // Method is invoked on click of edit button
    openEditModal(event) {
        //To store the value to 'asnDetailsToBeSent' to send to child component  
        this.asnDetailsToBeSent = event.target.name;
        //To set the value to true to open the child popup
        this.isModalopen = true;
        //To set the value to true, since the edit button is clicked
        this.isEditClicked = true;
        //To set the value to false 
        this.isViewModal = false;
    }
   //To close the pop and refresh the list
    closeModal(event) {
        // to set the values to false
        this.isModalopen = event.detail.isModalOpen;
        this.isViewModal = event.detail.isViewModal;
        //to refresh the ASN details in the table
        return refreshApex(this.allASN);
    }
     // Method is invoked on click of view button
     openViewDetailsModal(event) { 
        this.asnDetailsToBeSent = event.target.name;
         //To set the value to false 
        this.isModalopen = false;
         //To set the value to false
        this.isEditClicked = false;
         //To set the value to true to open the child popup
        this.isViewModal = true;
    }
    // Method is invoke when the searchkey is entered and refresh the ASN to be displayed
    handleSearchFilter(event) {
        // To capture the search keyword through the event
        this.searchKeyword = event.target.value;
        // console.log('searchKeyword----->', this.searchKeyword);
        if (this.searchKeyword == null || this.searchKeyword == '') {
            this.searchKeyword = '';
            refreshApex(this.allASN);
        }
    }

}