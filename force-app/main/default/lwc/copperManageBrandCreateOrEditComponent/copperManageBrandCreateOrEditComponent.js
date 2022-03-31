import {LightningElement,wire,track,api} from 'lwc';
//importing the method addBrand method from the class CopperManageBrandList_Apex to update a brand
import updateBrandOnEdit from '@salesforce/apex/CopperManageBrandList_Apex.addBrand'
//import the toast message event
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class CopperManageBrandCreateOrEditComponent extends LightningElement {
  //to get brand details from the parent component
  @api getBrandDetails;
  //to get a boolean value from parent
  @api isEditClicked;
  //to hold lable name fetched from  parent
  @api labelName;
  //to hold brand details
  @track brandDetails = [];
  //to hold boolean value to dislay error message
  @track showErrorMessage = true;
  //to hold boolean value to open the modal
  @api isModalOpen = false;
  //to hold brandNameForValidation from parent
  @api brandNameForValidation;
  //to hold boolean value to check of the button clicked is 'save and new'
  @api saveandnew = false;



  //This is theh LWC Lifecycle method and it is invoked on page load
  connectedCallback() {
    //  fetching the brand list details from the parent
    this.brandDetails = JSON.parse(JSON.stringify(this.getBrandDetails));
    // check if the brand list from the parent exists
    if (this.brandDetails.length > 0) {
      //enable the save, save and new button
      this.showErrorMessage = false;
    }
  }

  //to close the pop up modal and to send the value to the parent componet of the changed value
  closeModal() {
    // custom event fired to the parent component to close the pop-up modal
    const closeButton = new CustomEvent('closemodal', {
      detail: {
        isModalOpen: false,
        saveandnew: false,
      }
    });
    //dispatch the custom event
    this.dispatchEvent(closeButton);
  }

  //to validate brand name entered by the user.
  //Validation 1 : The brand name should not be repeated
  //Validation 2: The name should greater than 3 letters in length
  validateBrandName(event) {
    //fetch the value of the brand name field
    let brandNameInputField = this.template.querySelector(".brandNameValidation");
    //store the value of the variable brandNameInputField in the variable brandName
    let brandName = brandNameInputField.value;
    //do not let the user enter space in the beginning
    if (brandName.startsWith(' '))
      brandName = brandName.trim();
    // assign the variable brandName to the field Brand_Name__c of the object Brand__c
    this.brandDetails.Brand_Name__c = brandName;
    //check if the brand name entered already exists by comparing the variables brandName and brandNameForValidation by converting both of them to upper case
    if (this.brandNameForValidation.includes(brandName.replace(/\s/g, '').toUpperCase().trim()) && brandName.replace(/\s/g, '').toUpperCase().trim() != this.labelName.replace(/\s/g, '').toUpperCase().trim()) {
      //display the custom error message if the brand name already exists
      brandNameInputField.setCustomValidity("Brand name exists. Please check and enter again.");
    } else {
      brandNameInputField.setCustomValidity("");
    }
    //donot let the user enter brand name whose length is lesser than 3 letters
    if (brandName.length < 3) {
      brandNameInputField.setCustomValidity("Please enter a Brand name of at least 4 characters.");
    }
    //donot let the user enter brand name whose length is equal to 3 letters
    if (brandName.length == 3) {
      if (brandName.endsWith(' '))
        brandNameInputField.setCustomValidity("Please enter a Brand name of at least 4 characters.");
    }
    //report validity
    brandNameInputField.reportValidity();
    //the validation doesnot meet, disable the save and save and new buttons else enable them
    if (!brandNameInputField.checkValidity())
      this.showErrorMessage = true;
    else
      this.showErrorMessage = false;
  }

  //to the active status of the brand
  handleChangeActive(event) {
    //disable the "Save" and "Save and New" buttons
    this.showErrorMessage = false;
    //validate the entered inputs by invoking the method validateBrandName
    this.validateBrandName();
    //assign the true value to the field Active__c field of the brand if the user checks the checkbox
    this.brandDetails.Active__c = event.target.checked;

  }



  //to save the brand
  saveBrand(event) {
    //invoking a method updateBrandOnEdit of the class WilsonManageBrandList_Apex
    updateBrandOnEdit({

      // send selected brand details as the parameter
      selectedBrand: JSON.stringify(this.brandDetails)
    })
      .then(result => {
        //to hold the result from the apex method
        let resultGiven = result;
        // check if the user is trying to edit a brand
        if (this.isEditClicked) {
          //display the toast message as the brand has been updated successfully
          const evt = new ShowToastEvent({
            message: 'The Brand "' + this.labelName + '" has been updated successfully.',
            variant: 'success',
          });
          // disaptch the event
          this.dispatchEvent(evt);
        }
        //to check if the save is for the create pop-up and show the toast message as the brand is created successfully
        else {
          const evt = new ShowToastEvent({
            title: 'Success',
            message: 'The Brand has been created successfully.',
            variant: 'success',
          });
          // disaptch the event
          this.dispatchEvent(evt);
        }


        //To set the modal vale to false and send the value to parent , as the parent needs to know the value changed
        const closeButton = new CustomEvent('closemodal', {
          detail: {
            isModalOpen: false,
            saveandnew: false,
          }
        });
        // disaptch the event
        this.dispatchEvent(closeButton);
      })
  }
  // used to disconnect the callback from the parent and change the value of the variables once the user clicks on the button "Save and New"
  disconnectedCallback() {
    //make the variable brandDetails emnpty
    this.brandDetails = {};
    //enable the "save" and "save and new" button
    this.showErrorMessage = true;

  }
  //To save and create a new brand
  saveAndNewBrand() {
    //invoking a method updateBrandOnEdit of the class WilsonManageBrandList_Apex
    updateBrandOnEdit({
      // send selected brand details as the parameter
      selectedBrand: JSON.stringify(this.brandDetails)
    })
      .then(result => {
        let resultGiven = result;
        //invoking disconnectedCallback method
        this.disconnectedCallback();
        // check if the user is trying to edit a brand
        if (this.isEditClicked) {
          //display the toast message as the brand has been updated successfully
          const evt = new ShowToastEvent({
            message: 'The Brand "' + this.labelName + '" has been updated successfully.',
            variant: 'success',
          });
          this.dispatchEvent(evt);
        }
        //to check if the save is for the create pop-up and show the toast message as the brand is created successfully
        else {
          const evt = new ShowToastEvent({
            message: 'The Brand has been created successfully.',
            variant: 'success',
          });
          this.dispatchEvent(evt);
        }
        //keep the input fields of the new empty
        this.brandDetails.Brand_Name__c = '';
        //keep the checkbox of the new pop-up unchecked
        this.brandDetails.Active__c = false;
        //To set the modal vale to false and send the value to parent , as the parent needs to know the value changed
        const closeButton = new CustomEvent('closemodal', {
          detail: {
            isModalOpen: true,
            saveandnew: true,
          }
        });
        this.dispatchEvent(closeButton);
      })
  }
}