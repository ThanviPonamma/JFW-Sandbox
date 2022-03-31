/**Author: Thanvi;Date: 12-Aug-2021
 * Aim: This component is responsible to display the list of designation that belongs to copper cane
 * To call the child component to create/edit the designation */

import {LightningElement,wire,track,api} from 'lwc';
//to get the list of designation from the apex class CopperManageDesignationList_Apex
import getDesignationList from '@salesforce/apex/CopperManageDesignationList_Apex.getDesignationList_Apex'
//to get the deactivate the designation from the apex class CopperManageDesignationList_Apex
import deactivateDesignation from '@salesforce/apex/CopperManageDesignationList_Apex.deactivateDesignation_Apex'
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {refreshApex} from '@salesforce/apex';

export default class CopperManageDesignationListComponent extends LightningElement {
    // holds only the list of designation details
    @track designations;
    //boolean value to open designation edit/create pop-up
    @track openEditModal = false;
    //to know if the button clicked is create or edit
    @track isEditClicked;
    //to hold the name of the designation as label 
    @api labelName;
    //to know if the button clicked is 'save and new'
    @api saveandnew;
    //boolean value to open edit/create
    @api isModalOpen;
    //to hold searckey word
    @api searchedKeyword = '';
    //to hold designationNameForValidation coming from apex class
    @api designationNamesForValidation;

    @wire(getDesignationList, { searchKey: '$searchedKeyword' }) designationList;
    // To display the message if no data is found in the designation
    @track designationNotFound = false;

    //to get the list of designations on page init 
    get getAllDesignations() {

        //   check if the designationList has data 
        if (this.designationList.data) {
            //holds only the list of  designation details
            this.designations = (this.designationList.data).designationList;
            //to hold the designation names for validations
            this.designationNamesForValidation = (this.designationList.data).designationNamesForValidation
            //to check if the designationList has data or not
            if (this.designations.length == 0) {
                this.designationNotFound = false;
            } else {
                this.designationNotFound = true;
            }

        }
    }
    handleDesignationSearchFilter(event) {
        this.searchedKeyword = event.target.value;
    }
    //to open edit  designation modal
    openEditPopUp(event) {
        // open the pop-up modal
        this.openEditModal = true;
        // giving true value to the variable isEditClicked which means that the edit icon is clicked
        this.isEditClicked = true;
        // To hold the details of the selected  designation
        let designationDetails = event.target.name;
        // to hold the list of designations to be sent to the grand child
        this.selectedDesignationDetails = designationDetails;
        // to hold the name of the designation as label 
        this.labelName = designationDetails.Chair_Name__c;

    }

    //to deactivate a  designation on click of toggle button
    deactivateDesignation(event) {
        // to hold the name of the selected  designation
        let designation = event.target.name;
        deactivateDesignation({
            // to hold the variable designation and sending to the apex method as parameter
            selectedDesignation: JSON.stringify(designation),
            searchKey: this.searchedKeyword
        })
            .then(result => {
                // to hold the result returned by the apex method
                let resultGiven = result;
                // if the result is success display the toast message
                if (resultGiven) {
                    const evt = new ShowToastEvent({
                        message: 'The Designation"' + JSON.stringify(designation.Chair_Name__c) + '" has been deactivated successfully.',
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);

                }
                // refresh the designation list
                return refreshApex(this.designationList);
            })
    }

    //to open create designation modal 
    onCreateDesignation(event) {
        // to hold the list of designations to be sent to the grand child
        this.selectedDesignationDetails = {};
        //  open the pop-up modal
        this.openEditModal = true;
        //  giving false value to the variable isEditClicked which means that the edit icon is not clicked
        this.isEditClicked = false;
        //send an empty string in the variable labelName
        this.labelName = '';
    }

    //to close the edit/create modal
    closeModal(event) {
        //fetching the value from the child and giving it to the variable openEditModal
        this.openEditModal = event.detail.isModalOpen;
        //fetching the value from the child and giving it to the variable issaveAndNew
        this.issaveAndNew = event.detail.saveandnew;
        //    check if the button clicked is "save and new"
        if (this.issaveAndNew) {
            // close the pop-up modal
            this.openEditModal = false;
            // invoke the method onCreateDesignation
            this.onCreateDesignation();
        }
        // refresh the designation list
        return refreshApex(this.designationList);
    }
}