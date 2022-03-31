import { LightningElement, wire, track,api} from 'lwc';
// To  get the terrotory list from the Apex class CopperMangeTerritories_Apex using the method getTerritoryList
import getTerritoryList from '@salesforce/apex/CopperManageTerritories_Apex.getTerritoryList'
// To deactivate a territory using the Apex class CopperMangeTerritories_Apex using the method deactivateTerritoryApex
import deactivateTerritoryApex from '@salesforce/apex/CopperManageTerritories_Apex.deactivateTerritoryApex'
//to display toast message
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// Import method refresh the page
import { refreshApex } from '@salesforce/apex';
export default class CopperManageTerritoriesList extends LightningElement {
      //to hold the territory List to be displayed
  @track territoryList;
  //to hold the status of the modal is open or not for cretate/edit
  @api isModalOpen;
  //to hold the status of the modal is open or not for add/remove state list
  @api isAddOrRemoveStateListModalOpen;
  //to hold the status of the modal is open or not for add/remove state list
  @api isAddOrRemovUserListModalOpen;
  //to hold the value of the territory to the child component
  @api territory;
  //To check if the edit / create button is clicked
  @api isEditClicked;
  //To hold the label Name
  @api labelName;
  //to hold the territory name from the database
  @api territoryNamesForValidation;
  //to check if the address is save or new option selected
  @track issaveAndNew;
  // territory list not found
@track territoryListFound=false;
  @wire(getTerritoryList)
  getTerritoryList;

  //to get the territory list
  get territoriesToBeDisplayed(){
      if(this.getTerritoryList.data){
          //To hold data from the apex
          let territories = this.getTerritoryList.data;
          //To hold territoty list
          this.territoryList = territories.territoryList;
        
          //to hold territory names for validation
          this.territoryNamesForValidation = territories.territoryNamesForValidation;
          if(this.territoryList.length==0){
              this.territoryListFound=false;
          }
          else{
              this.territoryListFound=true;
          }
      }
  }
  //to deactivate the selected terrioty
  deactivateTerritory(event){
      //to hold the territoy to be deactivated
      let territory = event.target.name;
     
      deactivateTerritoryApex({  
          selectedTerritory : territory
          })
          .then(result => {
              let resultGiven = result;
              const evt = new ShowToastEvent({
                  message: 'The territory "'+territory.Territory_Name__c +'" has been deactivated successfully.',
                  variant: 'success',
                });
                this.dispatchEvent(evt);
              return refreshApex(this.getTerritoryList);
          })
  }
  //to open the edit pop-up modal
  openEditPopUp(event){
          var selectedTerritory = event.target.name;
           //to hold the territory details
          this.territory = selectedTerritory;
          //responsible to open the pop-up modal
          this.isModalOpen = true;
          this.isEditClicked = true;
           //to hold territory name
          this.labelName = selectedTerritory.Territory_Name__c;
  }
  //To create a new territory
  createTerritory(){
       //to hold the territory details
      this.territory = {};
      //responsible to open the pop-up modal
      this.isModalOpen = true;
      this.isEditClicked = false;
      //to hold the label
      this.labelName ='';
  }
  // To close the popup modal
  closeModal(event){
      this.isModalOpen=event.detail.modalopen;
      this.issaveAndNew = event.detail.saveandnew;
      refreshApex(this.getTerritoryList);
      //check if the save and new option is created and invoke the createTerrioty method
      if(this.issaveAndNew){
          this.isModalOpen=false;
          this.createTerritory();

      }
     // return refreshApex(this.getTerritoryList);
  }
  //On click of add/remove state list
  addOrRemoveTerritoryState(event){
      var selectedTerritory = event.target.value;
      //to hold territory name
      this.labelName = selectedTerritory.Territory_Name__c;
       //to hold the territory details
      this.territory = selectedTerritory;
      //responsible to open the pop-up modal
      this.isAddOrRemoveStateListModalOpen = true;
  }

   //On click of add/remove user list
   addOrRemoveTerritoryUser(event){
      var selectedTerritory = event.target.value;
      //to hold territory name
      this.labelName = selectedTerritory.Territory_Name__c;
      //to hold the territory details
      this.territory = selectedTerritory;
      //responsible to open the pop-up modal
      this.isAddOrRemovUserListModalOpen = true;
  }

  //to close the pop up modalwhen the child changes the pop-up modal value
  closeStatePopUpModal(event){
      this.isAddOrRemoveStateListModalOpen = false;
      return refreshApex(this.getTerritoryList);
  }
   //to close the pop up modalwhen the child changes the pop-up modal value
   closeUserPopUpModal(event){
      this.isAddOrRemovUserListModalOpen = false;
      return refreshApex(this.getTerritoryList);
  }
  
}