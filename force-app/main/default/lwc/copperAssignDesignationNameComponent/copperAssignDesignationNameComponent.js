import { LightningElement,track,api,wire } from 'lwc';
import loadChairs from '@salesforce/apex/CopperAssignDesignation_Apex.loadChairs_Apex'
import saveFixedPosition from '@salesforce/apex/CopperAssignDesignation_Apex.saveFixedPosition_Apex'
//to display Toast Message
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CopperAssignDesignationNameComponent extends LightningElement {

  //to hold lable name fetched from  parent
  @api labelName;
  //to hold the details from parent
  @api getFixedPositionDetails;
  //to hold fixed position details
  @track fixedPositionDetails;
  //to hold boolean value to dislay error message
  @track showErrorMessage = true;
  //to hold boolean value to open the modal
  @api isModalOpen = false;
  //to hold the list of chairs
  @track chairListToDisplay;
  //to hold the selected fixed position ID
  @track selectedFixedPositionId;


  //This is theh LWC Lifecycle method and it is invoked on page load
  connectedCallback() {
    //  fetching the fixed position list details from the parent
    this.fixedPositionDetails = JSON.parse(JSON.stringify(this.getFixedPositionDetails));
    this.selectedFixedPositionId = this.fixedPositionDetails.Id;

  }

  //wire property to get the list of fixed positions
  @wire(loadChairs, { selectedFixedPositionId: '$selectedFixedPositionId' })
  getChairList({ data, error }) {
    if (data) {
      const propertyValues = Object.values(data.chairs);
      this.chairListToDisplay = [];
      // for each program
      propertyValues.forEach(element => {
        if (element.Level__c == this.fixedPositionDetails.Level__c) {
          const chair = {};

          chair.label = element.Chair_Name__c;

          chair.value = element.Id;


          this.chairListToDisplay.push(chair);
        }
      });
    } else if (error) {
      console.log('Error', error.body.message, 'error');
    }
  }

  //to close the pop up modal and to send the value to the parent componet of the changed value
  closeModal() {
    // custom event fired to the parent component to close the pop-up modal
    const closeButton = new CustomEvent('closemodal', {
      detail: {
        isModalOpen: false,
      }
    });
    //dispatch the custom event
    this.dispatchEvent(closeButton);
  }

  //get selected chair
  getSelectedChair(event) {
    //fetch the selected chair
    const selectedChairToAssign = event.detail.value;
    //assign the chair to the fixed position
    this.fixedPositionDetails.Chair__c = selectedChairToAssign;
    //enable save button
    this.showErrorMessage = false;
  }

  assignChairToFixedPosition(event) {
    saveFixedPosition({
      // send selected fixed poistion as the parameter
      fixedPosition: JSON.stringify(this.fixedPositionDetails)
    })
      .then(result => {
        let resultGiven = result;
        //display the toast message as the dsignation has been updated successfully
        const evt = new ShowToastEvent({
          message: 'The designation "' + this.labelName + '" has been assigned successfully.',
          variant: 'success',
        });
        this.dispatchEvent(evt);

        const closeButton = new CustomEvent('closemodal', {
          detail: {
            isModalOpen: false,
          }
        });
        this.dispatchEvent(closeButton);
      })
  }
}