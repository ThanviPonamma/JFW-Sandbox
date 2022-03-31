/**Author:Thanvi Date:10-Aug-2021
Aim: This is the child component that is responsible for add/remove items to/for the program */
import { LightningElement, wire, track, api } from 'lwc';
//importing the method get program items from the class InfiniumManageProgramList_Apex 
import getAllProgramItemList from '@salesforce/apex/InfiniumManageProgramList_Apex.getProgramItemList_Apex'
//importing the method method from the class InfiniumManageProgramList_Apex to add item to program
import addPosItemToProgram from '@salesforce/apex/InfiniumManageProgramList_Apex.addPosItemToProgram_Apex'
//importing the method method from the class InfiniumManageProgramList_Apex to remove item from program
import removePosItemFromProgram from '@salesforce/apex/InfiniumManageProgramList_Apex.removePosItemFromProgram_Apex'
//import the toast message event
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {refreshApex} from '@salesforce/apex';
export default class InfiniumManageProgramItemComponent extends LightningElement {
    //to get program details from the parent component
    @api getProgramDetails;
    //to hold lable name fetched from  parent
    @api labelName;
    //to hold program detail
    @track programDetail = [];
    //to hold the program id 
    @track programId;
    //to hold the associated items of the selected program
    @track associatedProgramItems;
    //to hold the available program items
    @track availableProgramItems
    //This is theh LWC Lifecycle method and it is invoked on page load
    connectedCallback() {
        //  fetching the program list details from the parent
        this.programDetail = JSON.parse(JSON.stringify(this.getProgramDetails));
        this.programId = this.programDetail.Id;
    }
    //to fetch pos items from apex class
    @wire(getAllProgramItemList, {
        programId: '$programId'
    }) programItemList;
    //to get the list of program on page init 
    get getAllProgramItems() {

        //   check if the programList has data 
        if (this.programItemList.data) {
            //console.log(JSON.stringify(this.programItemList.data));
            let programItemListDetails = this.programItemList.data;
            this.associatedProgramItems = programItemListDetails.programItemList;
            this.availableProgramItems = programItemListDetails.availablePosItems;

        }
    }
    //to close the pop up modal and to send the value to the parent componet of the changed value
    closeModal() {
        // custom event fired to the parent component to close the pop-up modal
        const closeButton = new CustomEvent('closemodal', {
            detail: {
                isModalOpen: false,
                saveandnew: false,
                isItemModal: true,
            }
        });
        //dispatch the custom event
        this.dispatchEvent(closeButton);
    }
    //to add item to  the program
    addItem(event) {
        let posItem = event.target.value;
        //invoking a method addPosItemToProgram of the class InfiniumManageProgramList_Apex
        addPosItemToProgram({
            // send selected program details as the parameter
            program: JSON.stringify(this.programDetail),
            posItem: JSON.stringify(posItem)
        })
            .then(result => {
                //to hold the result from the apex method
                let resultGiven = result;
                //display the toast message as the program item has been added successfully
                const evt = new ShowToastEvent({
                    message: 'The item "' + posItem.Item_Name__c + '" has been ' + "added" + ' successfully.',
                    variant: 'success',
                });
                // disaptch the event
                this.dispatchEvent(evt);
                return refreshApex(this.programItemList);
            })
    }
    //to remove item from the program
    removeItem(event) {
        let posItem = event.target.value;
        //invoking a method addPosItemToProgram of the class InfiniumManageProgramList_Apex
        removePosItemFromProgram({
            // send selected program details as the parameter
            program: JSON.stringify(this.programDetail),
            posItem: JSON.stringify(posItem)
        })
            .then(result => {
                //to hold the result from the apex method
                let resultGiven = result;
                //display the toast message as the program item has been removed successfully
                const evt = new ShowToastEvent({
                    message: 'The item "' + posItem.Item_Name__c + '" has been ' + "removed" + ' successfully.',
                    variant: 'success',
                });
                // disaptch the event
                this.dispatchEvent(evt);
                refreshApex(this.programItemList);
            })
    }
}