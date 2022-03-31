// Author : Sanjana; Date : 20-09-2021
//Aim:To validate user entered data , save, save and new , cancel popup .

import { LightningElement , track ,api } from 'lwc';
// to send the Item type to save
import sendItemTypeToSave from '@salesforce/apex/InfiniumManageItemTypes_Apex.addOrEditItemType_Apex'
//to display Toast Message
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class InfiniumManageItemTypeCreateEditComponent extends LightningElement {
  //Decalaration of global variables
  @track itemType;
  //To disable and enable the save button based on the value of disableSaveButton
  @track disableSaveButton = true;
  //public property(An ownwer component will have the access to it) 
  @api itemTypeToBeEdited;
  // to get the validation from child component
  @api itemTypeNameForValidation;
  //to get the label name from child component
  @api labelName;
  @api isEditModalOpen;

  //To close create/edit modal by calling the parent modal through custom event
  closeModal() {
    //Data is sent to the parent for performing close function.
    const closeEditModal = new CustomEvent('closemodal', {
      detail: {
        ismodelclose: false,
        issaveandnew: false,

      }
    });
    this.dispatchEvent(closeEditModal);
  }

  //To display the item type data when modal is popped up.
  connectedCallback() {
    this.itemType = JSON.parse(JSON.stringify(this.itemTypeToBeEdited));
  }

  //To accept the user entered item type name and validate the data.     
  handleItemTypeName(event) {
    // to hold the id of the item type name input field
    let itemTypeNameInputField = this.template.querySelector(".itemTypeValidator");
    //to hold the value in the id field
    let itemTypeName = itemTypeNameInputField.value;
    //if the entered item type name starts with space, the trim the same and store the value.
    if (itemTypeName.startsWith(' '))
      itemTypeName = itemTypeName.trim();
    this.itemType.Item_Type__c = itemTypeName;
    // to check if the item type name already exist
    if (this.itemTypeNameForValidation.includes(itemTypeName.replace(/\s/g, '').toUpperCase().trim()) && itemTypeName.replace(/\s/g, '').toUpperCase().trim() != this.labelName.replace(/\s/g, '').toUpperCase().trim()) {
      itemTypeNameInputField.setCustomValidity("Item type name exists. Please check and enter again.");
    } else {
      itemTypeNameInputField.setCustomValidity("");
    }
    // to check if the item type is less than 3 letters
    if (itemTypeName.length < 3) {
      itemTypeNameInputField.setCustomValidity("Please enter a Item Type name of at least 3 characters.");
    }
    // to check if the item type is equal to 3 letters
    if (itemTypeName.length == 3) {
      if (itemTypeName.endsWith(' '))
        itemTypeNameInputField.setCustomValidity("Please enter a Item Type name of at least 3 characters.");
    }

    //To check if the input fiels are validated , if yes , make disableSaveButton true , in order to disable the save button ,else enable the button.
    itemTypeNameInputField.reportValidity();
    if (!itemTypeNameInputField.checkValidity()) {
      this.showErrorMessage = true;
      this.disableSaveButton = true;
    }
    else {
      this.showErrorMessage = false;
      this.disableSaveButton = false;
    }

  }

  //To hold the active status of selected / created item type.
  handleChangeActiveStatus(event) {
    this.disableSaveButton = false;
    this.itemType.Active__c = event.target.checked;
  }

  disconnectedCallback() {
    this.itemType = {};
    this.disableSaveButton = true;
  }

  //To save a validated item type by sending it to the backend.
  saveItemType() {

    sendItemTypeToSave({
      selectedItemType: this.itemType
    })
      .then(result => {
        let resultGiven = result;

        if (this.isEditModalOpen) {
          const evt = new ShowToastEvent({
            message: 'The item type "' + this.labelName + '" has been updated successfully.',
            variant: 'success',
          });
          this.dispatchEvent(evt);
        }
        //to check if the save is for the create pop-up and show the toast message
        else {
          const evt = new ShowToastEvent({
            message: 'The item type has been created successfully.',
            variant: 'success',
          });
          this.dispatchEvent(evt);
        }
        const closeEditModal = new CustomEvent('closemodal', {
          detail: {
            ismodelclose: false,
            issaveandnew: false,
          }
        });
        this.dispatchEvent(closeEditModal);
      })
  }

  //To save a validated item type by sending it to the backend and for continuing the process of creating.
  saveAndNewItemType() {

    sendItemTypeToSave({
      selectedItemType: this.itemType
    })
      .then(result => {
        let resultGiven = result;

        this.disconnectedCallback();
        this.itemType.Item_Type__c = '';
        this.itemType.Active__c = false;
        if (this.isEditModalOpen) {
          const evt = new ShowToastEvent({
            title: 'Success',
            message: 'The item type "' + this.labelName + '" has been updated successfully.',
            variant: 'success',
          });
          this.dispatchEvent(evt);
        }
        //to check if the save is for the create pop-up and show the toast message
        else {
          const evt = new ShowToastEvent({
            title: 'Success',
            message: 'The item type has been created successfully.',
            variant: 'success',
          });
          this.dispatchEvent(evt);
        }
        const closeEditModal = new CustomEvent('closemodal', {
          detail: {
            ismodelclose: true,
            issaveandnew: true,
          }
        });
        this.dispatchEvent(closeEditModal);
      })
  }
}