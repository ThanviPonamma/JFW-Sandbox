import { LightningElement, wire, track, api } from 'lwc';
import FixedPositionList from '@salesforce/apex/InfiniumAssignDesignation_Apex.getFixedPositionList'
// Import method refresh the page
import removeSelectedChair from '@salesforce/apex/InfiniumAssignDesignation_Apex.removeChair_Apex'
import { refreshApex } from '@salesforce/apex';
//to display Toast Message
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class InfiniumAssignDesignationListComponent extends LightningElement {

    //to hold the list of fixed positions and its details
    @track allFixedPositionList;
    //to check if there are fixed positions
    @track displayTable = false;
    //to hold the list of fixed positions
    @track fixedPositionList;
    //to open pop-up modal to assign designation
    @track openAssignDesignationModal = false;
    //to hold the lable name 
    @api labelName;
    //To hold the selected fixed position details to be sent to the pop-up modal
    @api selectedFixedPositionDetails;
    //To hold the selected fixed position details to be sent to the pop-up modal
    @track selectedFixedPositionToBeSent;
    //to hold boolean value to open the modal
    @api isModalOpen = false;
    //to hold the fixed position details to remove chair
    @track selectedChairToRemove;

    //to fetch the list of fixed positions from the method getFixedPositionList
    @wire(FixedPositionList)
    fixedPositionList;

    //init method to fetch the list of fixed positions
    get getFixedPositionList() {
        if (this.fixedPositionList.data) {
            this.allFixedPositionList = this.fixedPositionList.data;
        }

        if (this.fixedPositionList.length != 0) {
            this.displayTable = true;
        }
        else {
            this.displayTable = false;
        }
    }

    //to open the pop-up to assign chair 
    openAssignDesignationPopUp(event) {
        // open the pop-up modal
        this.openAssignDesignationModal = true;
        //to hold the details of the fixed position selected by the user
        let fixedPositionDetails = event.target.name;
        //To hold the selected fixed position details to be sent to the pop-up modal
        this.selectedFixedPositionToBeSent = JSON.stringify(fixedPositionDetails);
        //To hold the selected fixed position details to be sent to the pop-up modal
        this.selectedFixedPositionDetails = JSON.parse(this.selectedFixedPositionToBeSent);
        //To hold the label name to be sent to the pop-up modal
        this.labelName = fixedPositionDetails.Fixed_Position_Name__c;
    }

    //to close the assign designation modal
    closeModal(event) {
        //fetching the value from the child and giving it to the variable openEditModal
        this.openAssignDesignationModal = event.detail.isModalOpen;
        // refresh the fixed position list
        return refreshApex(this.fixedPositionList);
    }

    //to remove the chair assigned to fixed position
    removeChair(event) {
        //fetch the chair to be removed
        const selectedChairToRemove = event.target.name;
        //to hold the chair to be removed
        this.selectedChairToRemove = selectedChairToRemove;
        removeSelectedChair({
            // send selected brand fixed as the parameter
            fixedPosition: JSON.stringify(this.selectedChairToRemove)
        })
            .then(result => {
                let resultGiven = result;
                //display the toast message as the designation has been removed successfully
                const evt = new ShowToastEvent({
                    message: 'The designation "' + this.labelName + '" has been removed successfully.',
                    variant: 'success',
                });
                this.dispatchEvent(evt);
                return refreshApex(this.fixedPositionList);

            })
    }

}