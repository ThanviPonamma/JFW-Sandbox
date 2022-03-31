import { LightningElement,track,api,wire } from 'lwc';
import loadChairDetails from '@salesforce/apex/InfiniumChairUser_Apex.loadChairDetails_Apex'
import saveChairUser from '@salesforce/apex/InfiniumChairUser_Apex.saveChair_Apex'

//to display Toast Message
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class InfiniumManageChairUserEditComponent extends LightningElement {

  //to hold the fetched chai details from parent
  @api getChairDetails;
  //to fetch the label name
  @api labelName;
  //to open/close the pop-up modal
  @api isModalOpen = false;
  //to hold chair details
  @track chairDetails;
  //to hold selected chair Id
  @track selectedChairId;
  //to hold user list to display
  @track userListToDisplay;
  //to enable save button
  @track showErrorMessage = true;




  //This is theh LWC Lifecycle method and it is invoked on page load
  connectedCallback() {
    //  fetching the fixed position list details from the parent
    this.chairDetails = JSON.parse(JSON.stringify(this.getChairDetails));
    //fetch chair name
    this.labelName = this.chairDetails.chair.Chair_Name__c
    //fetch selected chair Id
    this.selectedChairId = this.chairDetails.chair.Id;
  }



  //wire property to get the list of fixed positions
  @wire(loadChairDetails, { selectedChairId: '$selectedChairId' })
  getChairList({ data, error }) {

    if (data) {

      //coverting object to array
      const propertyValues = Object.values(data.usersList);

      this.userListToDisplay = [];
      // for each program
      propertyValues.forEach(element => {
        const user = {};

        user.label = element.Name;

        user.value = element.Id;

        this.userListToDisplay.push(user);
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

  getSelectedUser(event) {
    //fetch the selected chair
    const selectedChairToAssign = event.detail.value;
    //assign the chair to the fixed position
    this.chairDetails.chair.User__c = selectedChairToAssign;

    //enable save button
    this.showErrorMessage = false;


  }


  assignUserToChair(event) {
    saveChairUser({
      // send selected fixed poistion as the parameter
      chair: JSON.stringify(this.chairDetails.chair)
    })
      .then(result => {
        let resultGiven = result;
        //display the toast message as the brand has been updated successfully
        const evt = new ShowToastEvent({
          message: 'The user for "' + this.labelName + '" has been assigned successfully.',
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