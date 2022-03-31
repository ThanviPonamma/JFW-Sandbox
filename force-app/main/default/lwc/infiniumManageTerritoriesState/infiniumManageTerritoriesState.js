import { LightningElement,api,track,wire } from 'lwc';
//To get the avaialble and assigned state list
import getCurrentTerritoryStateList from '@salesforce/apex/InfiniumManageTerritoriesStates_Apex.getCurrentTerritoryStateList';
//To save the assigned state list to the territory
import addStateToTerritoryApex from '@salesforce/apex/InfiniumManageTerritoriesStates_Apex.addStateToTerritory';
//to display toast message
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// Import method refresh the page
import { refreshApex } from '@salesforce/apex';
export default class InfiniumManageTerritoriesState extends LightningElement {
    //to hold the value of the territory for add/remove state from the parent component 
    @api territory;
    //to hold the selected territory Id
    @track selectedTerritoryId;
    //to display the available state list
    @track availableStateList;
    //to display the assign state list
    @track assignedStateList;
    //to hold the state to be update for the selected territory
    @track StateListTobeAssigned;
    //to disable the save button when the pop-up is opened initially
    @track isSaveDisabled = true;
    //to hold the label name for display
    @api labelName;
    
    connectedCallback(){
        //to capture the selected territory id and to get the state list for the id
        var selectedTerritory = JSON.parse(JSON.stringify(this.territory));
        this.selectedTerritoryId = selectedTerritory.Id;
    }

    @wire(getCurrentTerritoryStateList,{territoryId:'$selectedTerritoryId'})
    getstateList;

    //To get the assigned and available state list to be displayed for the selected territory Id
    get currentTerritoryStateList(){
        if(this.getstateList.data){
            //to hold the data from apex
        let StateOptionsListWrapper = this.getstateList.data;
        //to hold available state list
        this.availableStateList = StateOptionsListWrapper.allStates;
        //to hold assigned state list
        this.assignedStateList = StateOptionsListWrapper.selectedStates;
        }
    }
    //to close the pop-up modal and to send the changed value to the parent
    closeModal(){
        //To set the modal vale to false and send the value to parent , as the parent needs to know the value changed
        this.isAddOrRemoveStateListModalOpen=false;
        const closeButton = new CustomEvent('closestatepopupmodal', {detail:this.isAddOrRemoveStateListModalOpen})
        this.dispatchEvent(closeButton);
    }
    //to hold the values of the states during the add/remove of the state in the duallist box
    theStateListToBeAssigned(event){
        this.isSaveDisabled = false;
        this.StateListTobeAssigned = event.target.value;
    }
    //to save the state list to the selected territory
    saveTerritoryState(event){
    addStateToTerritoryApex({  
        territoryId : this.selectedTerritoryId,
        selectedStateIds:JSON.stringify(this.StateListTobeAssigned)
      })
      .then(result => {
          let resultGiven = result;
        //To refresh the state list
          refreshApex(this.getstateList);
          //to display toast message
          const evt = new ShowToastEvent({
            title: 'Success',
            message: 'The State(s) for the territory "'+this.labelName +'" is successfully updated.',
            variant: 'success',
        });
        this.dispatchEvent(evt);
          //To set the modal vale to false and send the value to parent , as the parent needs to know the value changed
          this.isAddOrRemoveStateListModalOpen=false;
          const closeButton = new CustomEvent('closestatepopupmodal', {detail:this.isAddOrRemoveStateListModalOpen})
          this.dispatchEvent(closeButton);
      })
     }
}