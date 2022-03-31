// Author : Sanjana; Date : 20-09-2021

//Aim: To display the list of of shipping method details and opne/close the pop-up modal .

import { LightningElement,track,wire,api} from 'lwc';
// to import the shipping method list from the apex class "InfiniumManageShippingMethod_Apex" with the method "getShippingMethodList"
import getShippingMethodList from '@salesforce/apex/InfiniumManageShippingMethod_Apex.getShippingMethodList'

// import method to deactivate the shipping method
import deactivateShippingMethod from '@salesforce/apex/InfiniumManageShippingMethod_Apex.deactivateShippingMethod'

// Import method refresh the page
import { refreshApex } from '@salesforce/apex';

//to display Toast Message
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class InfiniumManageShippingMethodListComponent extends LightningElement {
    // To hold the total shipping method list data sent from backend
@track shippingMethodtotalData;

// To hold the shipping method list
@track shippingMethodList;

// Boolean porperty to open/close the popup
@track isOpenModal;

// to sent the shipping method for validation in create and edit popup
@api shippingMethodNamesForValidation;

// global property to send the selected shipping method to edit to child component
@api shippingMethodToChange;

// This property is used to open of close the edit popup modal on click of edit button
@api  isEditClicked;

// to save the modal and open the create popup modal to users
@track isSaveAndNewOpen;

// to store the shipping method name on deactivate 
@track deactivateShippingMethodName;

// to display the table only data is present in table
@track shippingMethodFound=false;

// @wire property is to get the import method and send to the variable
@wire(getShippingMethodList)
getShippingMethodListToDisplay;

// get method which acts as the init method on page load
get shippingMethod(){ 
    if(this.getShippingMethodListToDisplay.data){
      this.shippingMethodtotalData = this.getShippingMethodListToDisplay.data;
        this.shippingMethodList =this.shippingMethodtotalData.shippingMethodList;
        this.shippingMethodNamesForValidation = this.shippingMethodtotalData.shippingMethodNamesForValidation;
        if(this.shippingMethodList.length==0){
            this.shippingMethodFound=false;
        }
        else{
            this.shippingMethodFound=true;
        }
        return refreshApex(this.getShippingMethodListToDisplay);
    }
}


// to open the popup modal on click of edit icon
openEditModal(event){
    var selectedShippingMethod = event.target.name;
    this.shippingMethodToChange =selectedShippingMethod;
    this.isOpenModal= true;
    this.isEditClicked=true;
    this.labelName = selectedShippingMethod.Shipping_Method_Name__c;
}


// to open the popup modal on click of create Shipping method button
openCreateModal(){
    this.shippingMethodToChange ={};
    this.isOpenModal= true;
    this.isEditClicked=false;
    this.labelName ='';
   }


// On click of the toggle button the method is called here and the shipping method to be deactivated
handleChangeDeactivateShippingeMethods(event){
    let deactivatedShippingMethod = event.target.name;
    this.deactivateShippingMethodName = deactivatedShippingMethod.Shipping_Method_Name__c;
        deactivateShippingMethod({  
            selectedShippingMethod :deactivatedShippingMethod
            })
            .then(result => {
                let resultGiven = result;
                if(resultGiven=="done"){
                    const evt = new ShowToastEvent({
                      message: 'The Shipping Method "'+this.deactivateShippingMethodName +'" has been deactivated successfully.',
                      variant: 'success',
                    });
                    this.dispatchEvent(evt);
                  }
                return refreshApex(this.getShippingMethodListToDisplay);
            })
}


// To close the modal the custom event is sent from child component and received in the parent component
closeModal(event){
    this.isOpenModal=event.detail.modalopen;
    this.isSaveAndNewOpen = event.detail.saveandnew;
    //check if the save and new option is created and invoke the createTerrioty method
    if(this.isSaveAndNewOpen){
        this.isOpenModal=false; 
        this.openCreateModal();
    }
    return refreshApex(this.getShippingMethodListToDisplay);
}
}