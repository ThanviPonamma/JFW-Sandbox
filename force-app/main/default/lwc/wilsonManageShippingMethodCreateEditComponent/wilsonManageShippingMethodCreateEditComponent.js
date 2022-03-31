// Authors:Vanditha,Thanvi  Date:06-01-2021
//Aim: To display create/edit popup when the Create/edit button is clicked
import { LightningElement,track,api } from 'lwc';

// to save the shipping method in the backend addOrEditShippingMethod
import addOrEditShippingMethod from '@salesforce/apex/WilsonManageShippingMethods_Apex.addOrEditShippingMethod'

//to display Toast Message
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class WilsonManageShippingMethodCreateEditComponent extends LightningElement {

    // To get the shipping method to be edited
    @api shippingMethodToChange;
// To get the validation for the entred shipping method
    @api shippingMethodNamesForValidation;
    // to get the shipping method name as label name and bind it with edit shipping method header
    @api labelName;
// to check if the called popup is edit or create method
    @api isEditClicked;
// @track property to hold the shipping method to be edited
    @track shippingMethod;
    // boolean property to enable and disable save and save&new button
 @track disableSaveButton = true ;
 // boolean property to enable and disable default checkbox
 @track isDefaultDisabled=false;



//it is an lwc lifecycle get invoked automatically onpage load
// It holds the shipping method data and sends to html and helps to display on page load 
    connectedCallback(){
        this.shippingMethod = JSON.parse(JSON.stringify(this.shippingMethodToChange))
        if(this.shippingMethod.Active__c){
            this.isDefaultDisabled = true;
        }
        else{
            this.isDefaultDisabled = false;
        }
    }

    
// to cloase the popup modal and send the custom event to parent
    closeModel(event){
          
        const closeButton = new CustomEvent('closemodal', {
            detail: {
                modalopen: false,
                saveandnew:false,
            } 
          });
          this.dispatchEvent(closeButton);
    }

// Onchange event when the users change the shipping method name
handlChangeShippingMethodName(event){
 // to hold the id of the shipping method input field
 let shippingMethodInputFieldValue = this.template.querySelector(".shippingMethodValidation");
 //to hold the value in the id field
  let shippingMethodName = shippingMethodInputFieldValue.value;
   
  //if the entered shipping methods name starts with space, the trim the same and store the value.
     if (shippingMethodName.startsWith(' '))
     shippingMethodName = shippingMethodName.trim();
     this.shippingMethod.Shipping_Method_Name__c= shippingMethodName;
     var regexForSpecialCharacters = /[^a-zA-Z0-9- ]/ig;
        //donot allow special characters except for hyphen, dot and underscore
        if (regexForSpecialCharacters.test(shippingMethodName)) {
           
            shippingMethodInputFieldValue.setCustomValidity("Special characters not allowed except -");
        } else {
            if (this.shippingMethodNamesForValidation.includes(shippingMethodName.replace(/\s/g, '').toUpperCase().trim()) && shippingMethodName.replace(/\s/g, '').toUpperCase().trim() != this.labelName.replace(/\s/g, '').toUpperCase().trim()) {
                shippingMethodInputFieldValue.setCustomValidity("Shipping Method name exists. Please check and enter again.");
            } 
            else
             {
                shippingMethodInputFieldValue.setCustomValidity("");
            }
        }
     // to check if the shipping method already exist
     

      // to check if the shipping method is less than 3 letters
     if (shippingMethodName.length < 3) {
         shippingMethodInputFieldValue.setCustomValidity("Please enter shipping methods name more than 3 characters.");
     }
      // to check if the shipping method is equal to 3 letters
     if (shippingMethodName.length == 3) {
         if (shippingMethodName.endsWith(' '))
         shippingMethodInputFieldValue.setCustomValidity("Please enter shipping method name more than 3 characters.");
     }

     shippingMethodInputFieldValue.reportValidity();
     if (!shippingMethodInputFieldValue.checkValidity())
       this.disableSaveButton = true;
     else
       this.disableSaveButton = false;
    }


    // Onchange event when the users change the shipping method active status
    handleChangeActive(event){
        this.disableSaveButton = false;
        this.shippingMethod.Active__c = event.target.checked;
        if( this.shippingMethod.Active__c){
            this.isDefaultDisabled = true;
        }
        else{

            this.isDefaultDisabled = false;
        }
    }


    // Onchange event when the users change the shipping method default status
    handleChangeDefault(event){
        this.disableSaveButton = false;
        this.shippingMethod.Default__c = event.target.checked;
    }

    handleChangeApprovalRequired(event){
        this.disableSaveButton = false;
        this.shippingMethod.ApprovalRequired__c = event.target.checked;
    }
    disconnectedCallback(){
        this.shippingMethod={};
         this.disableSaveButton = true;
      }


 // On click event when the user does the changes saves the shipping method 
    saveShippingMethod(){
       
        addOrEditShippingMethod({  
            selectedShippingMethod : this.shippingMethod
            })
            .then(result => {
                let resultGiven = result;
                if(this.isEditClicked){
                    const evt = new ShowToastEvent({
                    
                      message: 'The Shipping Method "'+this.labelName +'" has been updated successfully.',
                      variant: 'success',
                    });
                    this.dispatchEvent(evt);
                  }
                  //to check if the save is for the create pop-up and show the toast message
                  else {
                    const evt = new ShowToastEvent({
                    
                      message: 'The Shipping Method has been created successfully.',
                      variant: 'success',
                    });
                    this.dispatchEvent(evt);
                  }
                 //To set the modal vale to false and send the value to parent , as the parent needs to know the value changed to open/close the popUp
                const closeButton = new CustomEvent('closemodal', {
                    detail: {
                        modalopen: false,
                        saveandnew:false,
                    } 
                  });
                  this.dispatchEvent(closeButton);
            })
    }

    
 // On click event when the user does the changes saves and clicks on "Save And New" button the shipping method 
    saveAndNewShippingMethod(){
        addOrEditShippingMethod({  
            selectedShippingMethod : this.shippingMethod
            })
            .then(result => {
                let resultGiven = result;
                this.disconnectedCallback();
                this.shippingMethod.Shipping_Method_Name__c='';
              
                this.shippingMethod.Active__c=false;
              
                this.shippingMethod.Default__c=false;
              
                if(this.isEditClicked){
                    const evt = new ShowToastEvent({
                    
                      message: 'The Shipping Method "'+this.labelName +'" has been updated successfully.',
                      variant: 'success',
                    });
                    this.dispatchEvent(evt);
                  }
                  //to check if the save is for the create pop-up and show the toast message
                  else {
                    const evt = new ShowToastEvent({
                    
                      message: 'The Shipping Method has been created successfully.',
                      variant: 'success',
                    });
                    this.dispatchEvent(evt);
                  }
                //To set the modal vale to true and send the value to parent , as the parent needs to know the value changed to open/close the popUp
                const closeButton = new CustomEvent('closemodal', {
                    detail: {
                        modalopen:true,
                        saveandnew:true,
                    } 
                  });
                  this.dispatchEvent(closeButton);
            })
    }

}