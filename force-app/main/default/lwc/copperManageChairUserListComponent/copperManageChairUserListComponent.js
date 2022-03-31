import {LightningElement,wire,track,api} from 'lwc';
import LoadChairList from '@salesforce/apex/CopperChairUser_Apex.loadChairList_Apex'
import { refreshApex } from '@salesforce/apex';

export default class CopperManageChairUserListComponent extends LightningElement {
    //to hold all the chair fetched from apex class
    @track allChairs;
    //to hide or display the table
    @track displayTable = false;
    //to close.open pop-up modal
    @track openPopUpModal = false;
    //to hold the chair details to be sent to the child
    @track chairDetailsToBeSent;
    // to hold the selected chair details
    @api selectedChairDetails;
    // to hold the label name
    @api labelName;
    //to open/close pop-up modal
    @api isModalOpen = false;

    //to fetch the list of fixed positions from the method getFixedPositionList
    @wire(LoadChairList)
    loadChairs;


    //load chair list
    get getChairList() {
        if (this.loadChairs.data) {
            this.allChairs = this.loadChairs.data;
        }
        //check if the list is not empty
        if (this.loadChairs.length != 0) {
            this.displayTable = true;
        }
        else {
            this.displayTable = false;
        }
    }

    //open pop-up modal to assign users
    openEditModal(event) {
        //set the value to true
        this.openPopUpModal = true;
        //to hold the details of the fixed position selected by the user
        let chairDetails = event.target.name;
        //To hold the selected fixed position details to be sent to the pop-up modal
        this.chairDetailsToBeSent = JSON.stringify(chairDetails);
        //To hold the selected fixed position details to be sent to the pop-up modal
        this.selectedChairDetails = JSON.parse(this.chairDetailsToBeSent);
        //To hold the label name to be sent to the pop-up modal
        this.labelName = selectedChairDetails.chair.Chair_Name__c;
    }

    //to close the assign designation modal
    closeModal(event) {
        //fetching the value from the child and giving it to the variable openEditModal
        this.openPopUpModal = event.detail.isModalOpen;
        // refresh the fixed chair list
        return refreshApex(this.loadChairs);
    }
}