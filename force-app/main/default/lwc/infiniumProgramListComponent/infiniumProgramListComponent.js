/**Author:Sanjana Date:21-09-2021
Aim: This is the child component that is responsible for displaying Program table */

import {LightningElement,wire,track,api} from 'lwc';
import getAllProgramList from '@salesforce/apex/InfiniumManageProgramList_Apex.getProgramsList_Apex'
import deactivateSelectedProgram from '@salesforce/apex/InfiniumManageProgramList_Apex.deactivateProgram_Apex'
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {refreshApex} from '@salesforce/apex';
// to display no image
import noImage from '@salesforce/resourceUrl/noimageavailable';

export default class InfiniumManageProgramList extends LightningElement {
    // no image variable
    NoImageURL = noImage;
    //holds the data coming from the apex method getAllProgramList()
    @track allProgramList;
    // holds only the list of Program details
    @track programs;
    //to hold programNameForValidation coming from apex class
    @api programNameForValidation;
    //boolean value to open Program edit/create pop-up
    @track openEditModal = false;
    //to hold the type of button selected by the user
    @api selectedButtonName;
    //to know if the button clicked is create or edit
    @track isEditClicked;
    //to hold the name of the Program as label 
    @api labelName;
    //boolean value to open item modal pop-up
    @track openItemModal
    //to know if the button clicked is 'save and new'
    @api saveandnew;
    //boolean value to open edit/create
    @api isModalOpen;
    //to diplay the toast message to add budget to the Program
    @track isOpenModalForToastMessage = false;
    @wire(getAllProgramList) programList;

    // To display the message if no data is found in the Program
    @track programNotFound = false;

    //to get the list of Program on page init 
    get getAllProgram() {

        //   check if the programList has data 
        if (this.programList.data) {
            // add the data received to the variable allProgramList
            this.allProgramList = this.programList.data;
            //console.log('The data from back end---->',JSON.stringify(this.allProgramList));
            // holds only the list of Program details
            this.programs = this.allProgramList.programList;
            // to hold programNameForValidation coming from apex class
            this.programNameForValidation = this.allProgramList.programNamesForValidation;
            // to check if the programs has data or not
            if (this.programs.length == 0) {
                this.programNotFound = false;
            } else {
                this.programNotFound = true;
            }

        }
    }


    //to deactivate a Program on click of toggle button
    deactivateProgram(event) {
        // to hold the name of the selected Program
        let selectedProgram = event.target.name;
        deactivateSelectedProgram({
            // to hold the variable Program and sending to the apex method as parameter
            program: JSON.stringify(selectedProgram)
        })
            .then(result => {
                // to hold the result returned by the apex method
                let resultGiven = result;
                // if the result is success display the toast message
                if (resultGiven) {
                    const evt = new ShowToastEvent({
                        message: 'The Program"' + JSON.stringify(selectedProgram.Name__c) + '" has been deactivated successfully.',
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);

                }
                // refresh the Program list
                return refreshApex(this.programList);
            })
    }

    //to open create Program modal 
    onCreateProgram(event) {
        // to hold the list of Program to be sent to the grand child
        let temp = {
            "program": {
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
            "programImageURL": ""
        }
        this.selectedProgramDetails = temp;
        //  open the pop-up modal
        this.openEditModal = true;
        //  giving false value to the variable isEditClicked which means that the edit icon is not clicked
        this.isEditClicked = false;
        //send an empty string in the variable labelName
        this.labelName = '';
        //To hold the type of button clicked by the user
        this.selectedButtonName = 'CREATE';
    }

    //to open edit Program modal
    openEditPopUp(event) {
        //To hold the type of button clicked by the user
        this.selectedButtonName = 'EDIT';
        // open the pop-up modal
        this.openEditModal = true;
        // giving true value to the variable isEditClicked which means that the edit icon is clicked
        this.isEditClicked = true;
        // To hold the details of the selected Program
        let programDetails = event.target.name;
        // to hold the list of Programs to be sent to the grand child
        this.selectedProgramDetails = programDetails;
        // to hold the name of the Program as label 
        this.labelName = programDetails.program.Name__c;

    }
    addOrRemoveItems(event) {
        // open the pop-up modal
        this.openItemModal = true;
        // To hold the details of the selected Program
        let programDetails = event.target.name;
        // to hold the list of Programs to be sent to the grand child
        this.selectedProgramDetails = programDetails;
        // to hold the name of the Program as label 
        this.labelName = programDetails.Name__c;
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
            // invoke the method onCreateProgram
            this.onCreateProgram();
        }
        if(isItemModal){
            this.openItemModal = false;
        }
        if(this.selectedButtonName=='CREATE' && issaveAndNew == false){
            this.isOpenModalForToastMessage = true;
        }
        // refresh the Program list
        return refreshApex(this.programList);
    }
    //to close the toast mesage pop-up
    closeMessageModel(event){
        this.isOpenModalForToastMessage = false;
    }
}