import { LightningElement, wire, track, api } from 'lwc';
//importing the method addOrUpdateDesignation_Apex method from the class CopperManageDesignationList_Apex to add and update designation
import addOrUpdateDesignation from '@salesforce/apex/CopperManageDesignationList_Apex.addOrUpdateDesignation_Apex'
//import the toast message event
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CopperManageDesignationCreateEditComponent extends LightningElement {
    //to get designation details from the parent component
    @api getDesignationDetails;
    //to get a boolean value from parent
    @api isEditClicked;
    //to hold lable name fetched from  parent
    @api labelName;
    //to hold designation details
    @track designationDetail = [];
    //to hold boolean value to dislay error message
    @track showErrorMessage = true;
    //to hold boolean value to open the modal
    @api isModalOpen = false;
    //to hold designationNamesForValidation from parent
    @api designationNamesForValidation;
    //to hold boolean value to check of the button clicked is 'save and new'
    @api saveandnew = false;
    //to hold level picklist
    @track designationLevelListToDisplay;
    //This is theh LWC Lifecycle method and it is invoked on page load
    connectedCallback() {
        //  fetching the designation list details from the parent
        this.designationDetail = JSON.parse(JSON.stringify(this.getDesignationDetails));


        // check if the designation list from the parent exists
        if (this.designationDetail.length > 0) {
            this.value = this.designationDetail.Level__c;
            //enable the save, save and new button
            this.showErrorMessage = false;
        }
    }
    get designationLevelOptions() {
        return [
            { value: '', label: 'Select Level of Designation' },
            { value: '1', label: '1' },
            { value: '2', label: '2' },
            { value: '3', label: '3' }
        ];
    }
    //to validate designation name entered by the user.
    //Validation 1 : The designation name should not be repeated
    //Validation 2: The name should greater than 3 letters in length
    validateDesignationName(event) {
        //fetch the value of the designation name field
        let designationNameInputField = this.template.querySelector(".designationNameValidationInputFiled");
        //store the value of the variable designationNameInputField in the variable designationName
        let designationName = designationNameInputField.value;
        //do not let the user enter space in the beginning
        if (designationName.startsWith(' '))
            designationName = designationName.trim();
        // assign the variable designationName to the field Name__c of the object Program__c
        this.designationDetail.Chair_Name__c = designationName;
        //check if the Designation Name entered already exists by comparing the variables designationName and designationNamesForValidation by converting both of them to upper case
        if (this.designationNamesForValidation.includes(designationName.replace(/\s/g, '').toUpperCase().trim()) && designationName.replace(/\s/g, '').toUpperCase().trim() != this.labelName.replace(/\s/g, '').toUpperCase().trim()) {
            //display the custom error message if the Designation Name already exists
            designationNameInputField.setCustomValidity("Designation Name exists. Please check and enter again.");
        } else {
            designationNameInputField.setCustomValidity("");
        }
        //donot let the user enter Designation Name whose length is lesser than 3 letters
        if (designationName.length < 3) {
            designationNameInputField.setCustomValidity("Please enter a Designation Name of at least 4 characters.");
        }
        //donot let the user enter Designation Name whose length is equal to 3 letters
        if (designationName.length == 3) {
            if (designationName.endsWith(' '))
                designationNameInputField.setCustomValidity("Please enter a Designation Name of at least 4 characters.");
        }
        //report validity
        designationNameInputField.reportValidity();
        //the validation doesnot meet, disable the save and save and new buttons else enable them
        if (!designationNameInputField.checkValidity()) {
            this.showErrorMessage = true;
        }

        else {
            this.showErrorMessage = false;
            this.handleChangeForDesignationLevel();
        }
    }

    //Capture the value for designation level
    handleChangeForDesignationLevel(event) {
        this.designationDetail.Level__c = event.detail.value;
        //fetch the value of the designation name field
        let designationLevelInputField = this.template.querySelector(".designationLevelInputFiled");
        if (!designationLevelInputField.checkValidity()) {
            this.showErrorMessage = true;
        }

        else {
            this.showErrorMessage = false;
            this.validateDesignationName();
        }


    }
    //to the active status of the buy book
    handleChangeActive(event) {
        //disable the "Save" and "Save and New" buttons
        this.showErrorMessage = false;
        //assign the true value to the field Active__c field of the buy book if the user checks the checkbox
        this.designationDetail.Active__c = event.target.checked;
        //invoke the method validateDesignationName
        this.validateDesignationName();
        this.handleChangeForDesignationLevel();
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

    //to the active status of the designation
    handleChangeActive(event) {
        //assign the true value to the field Active__c field of the designation if the user checks the checkbox
        this.designationDetail.Active__c = event.target.checked;
        //validate the entered inputs by invoking the method validateDesignationName
        this.validateDesignationName();

    }



    //to save the designation
    saveDesignation(event) {
        //invoking a method addOrUpdateDesignation of the class CopperManageDesignationList_Apex
        addOrUpdateDesignation({

            // send selected designation details as the parameter
            selectedDesignation: JSON.stringify(this.designationDetail)
        })
            .then(result => {
                //to hold the result from the apex method
                let resultGiven = result;
                // check if the user is trying to edit a designation
                if (this.isEditClicked) {
                    //display the toast message as the designation has been updated successfully
                    const evt = new ShowToastEvent({
                        message: 'The Designation "' + this.labelName + '" has been updated successfully.',
                        variant: 'success',
                    });
                    // disaptch the event
                    this.dispatchEvent(evt);
                }
                //to check if the save is for the create pop-up and show the toast message as the designation is created successfully
                else {
                    const evt = new ShowToastEvent({
                        title: 'Success',
                        message: 'The Designation has been created successfully.',
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
        //make the variable designationDetails emnpty
        this.designationDetail = {};
        //enable the "save" and "save and new" button
        this.showErrorMessage = true;

    }
    //To save and create a new designation
    saveAndNewDesignation() {
        //invoking a method addOrUpdateDesignation of the class CopperManageDesignationList_Apex
        addOrUpdateDesignation({
            // send selected designation details as the parameter
            selectedDesignation: JSON.stringify(this.designationDetail)
        })
            .then(result => {
                let resultGiven = result;
                //invoking disconnectedCallback method
                this.disconnectedCallback();
                // check if the user is trying to edit a Designation
                if (this.isEditClicked) {
                    //display the toast message as the Designation has been updated successfully
                    const evt = new ShowToastEvent({
                        message: 'The Designation "' + this.labelName + '" has been updated successfully.',
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);
                }
                //to check if the save is for the create pop-up and show the toast message as the designation is created successfully
                else {
                    const evt = new ShowToastEvent({
                        message: 'The Designation has been created successfully.',
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);
                }
                //keep the input fields of the new empty
                this.designationDetail.Chair_Name__c = '';
                //keep the checkbox of the new pop-up unchecked
                this.designationDetail.Active__c = false;
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