import { LightningElement,track,api} from 'lwc';
//To save the edited or created address
import saveTerritoryApex from '@salesforce/apex/JFWMangeTerritories_Apex.addTerritory'
//to display toast message
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class JfwManageTerritoriesCreateEdit extends LightningElement {
//to hold the modal status
@track isModalOpen;
//to hold the value of the terriotyr for edit/create from the parent component 
@api territory;
//to hold the selected territory
@track selectedTerritory;
//to check if the edit button is clicked or not
@api isEditClicked;
//to hold the label name for display
@api labelName;
//to hold the territory names from the parent that is in the databse
@api territoryNamesForValidation;
//to check if the save button can be enabled or disabled
@track disableSaveButton = true ;

connectedCallback(){
  this.selectedTerritory = JSON.parse(JSON.stringify(this.territory));
  this.disableSaveButton = true;
}


//to close the pop up modal and to send the value to the parent componet of the changed value
closeModal(){
//To set the modal vale to false and send the value to parent , as the parent needs to know the value changed
  const closeButton = new CustomEvent('closemodal', {
    detail: {
        modalopen: false,
        saveandnew:false,
    } 
  });
  this.dispatchEvent(closeButton);
}
//to validate the territory name while entered in the input field
validateTerritoryName(event) {
  // to hold the id of the territoy name input field
  let territoryNameInputField = this.template.querySelector(".territoyNameValidation");
  //to hold the value in the id field
  let territoryName = territoryNameInputField.value;
  //if the entered territoy name starts with space, the trim the same and store the value.
  if (territoryName.startsWith(' '))
    territoryName = territoryName.trim();
    this.selectedTerritory.Territory_Name__c= territoryName;
// to check if the territory name already exist
  if (this.territoryNamesForValidation.includes(territoryName.replace(/\s/g, '').toUpperCase().trim()) && territoryName.replace(/\s/g, '').toUpperCase().trim() != this.labelName.replace(/\s/g, '').toUpperCase().trim()) {
    territoryNameInputField.setCustomValidity("Territory name exists. Please check and enter again.");
  } else {
    territoryNameInputField.setCustomValidity("");
  }

  if (territoryName.length < 3) {
      territoryNameInputField.setCustomValidity("Please enter a Territory name of at least 4 characters.");
  }
  if (territoryName.length == 3) {
      if (territoryName.endsWith(' '))
          territoryNameInputField.setCustomValidity("Please enter a Territory name of at least 4 characters.");
  }
  territoryNameInputField.reportValidity();
  if (!territoryNameInputField.checkValidity())
    this.disableSaveButton = true;
  else
    this.disableSaveButton = false;
}
//to hold the value of the Active__c checkbox value
onChangeActive(event){
  this.disableSaveButton = false;
  this.validateTerritoryName();
  this.selectedTerritory.Active__c = event.target.checked;
}
//to save the territory
  saveTerritory(event){
    // console.log('this.selectedTerritory--->',JSON.stringify(this.selectedTerritory))
    saveTerritoryApex({  
      selectedTerritory : this.selectedTerritory
      })
      .then(result => {
          let resultGiven = result;
          //to check if the save is for the edit pop-up and show the toast message
          if(this.isEditClicked){
            const evt = new ShowToastEvent({
              title: 'Success',
              message: 'The Territory "'+this.labelName +'" has been updated successfully.',
              variant: 'success',
            });
            this.dispatchEvent(evt);
          }
          //to check if the save is for the create pop-up and show the toast message
          else {
            const evt = new ShowToastEvent({
              title: 'Success',
              message: 'The Territory has been created successfully.',
              variant: 'success',
            });
            this.dispatchEvent(evt);
          }

          //To set the modal vale to false and send the value to parent , as the parent needs to know the value changed
          const closeButton = new CustomEvent('closemodal', {
          detail: {
          modalopen: false,
          saveandnew: false,
        } 
        });
        this.dispatchEvent(closeButton);
      })
  }
  disconnectedCallback(){
    this.selectedTerritory={};
    this.disableSaveButton = true;
  }
  //To save and create a new terrioty
  saveAndNewTerritory(){
    saveTerritoryApex({  
      selectedTerritory : this.selectedTerritory
      })
      .then(result => {
        let resultGiven = result;
        this.disconnectedCallback();
        //to check if the save and new is for the edit pop-up and show the toast message
        if(this.isEditClicked){
          const evt = new ShowToastEvent({
            title: 'Success',
            message: 'The Territory "'+this.labelName +'" has been updated successfully.',
            variant: 'success',
          });
          this.dispatchEvent(evt);
        }
        //to check if the save and new is for the create pop-up and show the toast message
        else {
          const evt = new ShowToastEvent({
            title: 'Success',
            message: 'The Territory has been created successfully.',
            variant: 'success',
          });
          this.dispatchEvent(evt);
        }
        //To set the modal vale to false and send the value to parent , as the parent needs to know the value changed
        const closeButton = new CustomEvent('closemodal', {
        detail: {
        modalopen: true,
        saveandnew: true,
        } 
      });
        this.dispatchEvent(closeButton);
      })
  }
}