/**Authors:Sanjana, Date: 10-08-2021
Aim: This is the child component that is responsible for displaying brand table */


import {LightningElement,wire,track,api} from 'lwc';
import getAllBrandList from '@salesforce/apex/CopperManageBrandList_Apex.getBrandList'
import deactivateSelectedBrand from '@salesforce/apex/CopperManageBrandList_Apex.deactivateBrandApex'
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {refreshApex} from '@salesforce/apex';

export default class CopperManageBrandComponent extends LightningElement {
    //holds the data coming from the apex method getBrandList()
    @track allBrandList;
    // holds only the list of brand details
    @track brands;
    //to hold the selected brand details
    @api brand;
    //to hold the selected brand Id
    @track brandId;
    //boolean value to open brand edit/create pop-up
    @track openEditModal = false;
    //to hold the list of brands to be sent to the child
    @track brandListToBeSent;
    //to know if the button clicked is create or edit
    @track isEditClicked;
    //to hold the name of the brand as label 
    @api labelName;
    //to hold brandNameForValidation coming from apex class
    @api brandNameForValidation;
    //to know if the button clicked is 'save and new'
    @api saveandnew;
    //boolean value to open edit/create
    @api isModalOpen;
    //boolean value to open brand users pop-up
    @api isAddOrRemoveUserListModalOpen = false;

    @wire(getAllBrandList) brandList;

    // To display the message if no data is found in the brand
    @track brandNotFound = false;

    //to get the list of brands on page init 
    get getAllBrands() {

        //   check if the brandList has data 
        if (this.brandList.data) {
            // add the data received to the variable allBrandList
            this.allBrandList = this.brandList.data;
            // holds only the list of brand details
            this.brands = this.allBrandList.brandList;
            // to hold brandNameForValidation coming from apex class
            this.brandNameForValidation = this.allBrandList.brandNamesForValidation;
            // to check if the brandlist has data or not
            if (this.brands.length == 0) {
                this.brandNotFound = false;
            } else {
                this.brandNotFound = true;
            }

        }
    }

    //to open edit brand modal
    openEditPopUp(event) {
        // open the pop-up modal
        this.openEditModal = true;
        // giving true value to the variable isEditClicked which means that the edit icon is clicked
        this.isEditClicked = true;
        // To hold the details of the selected brand
        let brandDetails = event.target.name;
        // to hold the list of brands to be sent to the grand child
        this.brandListToBeSent = JSON.stringify(brandDetails);
        // to hold the list of brands to be sent to the grand child
        this.selectedBrandDetails = JSON.parse(this.brandListToBeSent);
        // to hold the name of the brand as label 
        this.labelName = brandDetails.Brand_Name__c;

    }

    //to deactivate a brand on click of toggle button
    deactivateBrand(event) {
        // to hold the name of the selected brand
        let brand = event.target.name;
        deactivateSelectedBrand({
                // to hold the variable brand and sending to the apex method as parameter
                selectedBrand: JSON.stringify(brand)
            })
            .then(result => {
                // to hold the result returned by the apex method
                let resultGiven = result;
                // if the result is success display the toast message
                if (resultGiven) {
                    const evt = new ShowToastEvent({
                        message: 'The Brand"' + JSON.stringify(brand.Brand_Name__c) + '" has been deactivated successfully.',
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);

                }
                // refresh the brand list
                return refreshApex(this.brandList);
            })
    }

    //to open create brand modal 
    onCreatebrand(event) {
        // to hold the list of brands to be sent to the grand child
        this.selectedBrandDetails = {};
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
            // invoke the method onCreatebrand
            this.onCreatebrand();
        }
        // refresh the brand list
        return refreshApex(this.brandList);
    }

    //to add or remove users to the brand on selection of the user
    addOrRemoveUserToBrand(event) {
        // to hold the selected brand details
        var selectedBrand = event.target.value;
        // To hold the details of the selected brand
        let brandDetails = event.target.value;
        // to hold the name of the brand as label 
        this.labelName = brandDetails.Brand_Name__c;
        // to hold the name of the selected brand
        this.brand = selectedBrand;
        // boolean value to open brand users pop-up
        this.isAddOrRemoveUserListModalOpen = true;
    }

    //to close brand user modal pop-up
    closeUserPopUpModal(event) {
        // boolean value to open brand users pop-up
        this.isAddOrRemoveUserListModalOpen = false;
        // refresh the brand list
        return refreshApex(this.brandList);
    }
}