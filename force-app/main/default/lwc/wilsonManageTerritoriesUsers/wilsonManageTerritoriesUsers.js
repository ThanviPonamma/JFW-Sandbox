import { LightningElement,wire, api, track } from 'lwc';
// To  get the Current Territory User List from the Apex class WilsonMangeTerritoryUsers_Apex using the method getCurrentTerritoryUserList
import getCurrentTerritoryUserList from '@salesforce/apex/WilsonMangeTerritoryUsers_Apex.getCurrentTerritoryUserList';
// To  add the user Territory from the Apex class WilsonMangeTerritoryUsers_Apex using the method addUserToTerritory
import addUserToTerritory from '@salesforce/apex/WilsonMangeTerritoryUsers_Apex.addUserToTerritory';
//to display toast message
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// Import method refresh the page
import { refreshApex } from '@salesforce/apex';


export default class WilsonManageTerritoriesUsers extends LightningElement {
    
    //to hold the value of the territory for add/remove user from the parent component 
    @api territory;
    //to hold the label name for display
    @api labelName;
    //to hold the selected territory Id
    @track selectedTerritoryId;
    //to display the available user list
    @track availableUserList;
    //to display the assign user list
    @track assignedUserList;
    //to hold the user to be update for the selected territory
    @track userListTobeAssigned;
    //to disable the save button when the pop-up is opened initially
    @track isSaveDisabled = true;

    
    
    connectedCallback(){
        //to capture the selected territory id and to get the user list for the id
        var selectedTerritory = JSON.parse(JSON.stringify(this.territory));
        this.selectedTerritoryId = selectedTerritory.Id;
        // console.log('selectedTerritoryId--->',this.selectedTerritoryId)
    }


    @wire(getCurrentTerritoryUserList,{territoryId:'$selectedTerritoryId'})
    getUserList;

    get currentTerritoryUserList(){
        if(this.getUserList.data){
        //to hold the data from apex
        let userOptionsListWrapper = this.getUserList.data;
        //to hold available state list
        this.availableUserList = userOptionsListWrapper.allUsers;
        //to hold assigned state list
        this.assignedUserList = userOptionsListWrapper.selectedUsers;

        }
    }

     //to close the pop-up modal and to send the changed value to the parent
     closeModal(){
        //To set the modal vale to false and send the value to parent , as the parent needs to know the value changed
        this.isAddOrRemoveUserListModalOpen=false;
        const closeButton = new CustomEvent('closeuserpopupmodal', {detail:this.isAddOrRemoveUserListModalOpen})
        this.dispatchEvent(closeButton);
    }
    //to save the users list to the selected territory
    theUserListToBeAssigned(event){
        this.isSaveDisabled = false;
        this.userListTobeAssigned = event.target.value;
    }

    //to save the user list to the selected territory
    saveTerritoryUser(event){
        addUserToTerritory({  
            territoryId : this.selectedTerritoryId,
            selectedUserIds:JSON.stringify(this.userListTobeAssigned)
          })
          .then(result => {
              let resultGiven = result;
              //To refresh the users list
              refreshApex(this.getUserList);
              //To display toast message
              const evt = new ShowToastEvent({
                title: 'Success',
                message: 'The Territory Manager(s) for the territory "'+this.labelName +'" is successfully updated.',
                variant: 'success',
            });
            this.dispatchEvent(evt);
              //To set the modal vale to false and send the value to parent , as the parent needs to know the value changed
              this.isAddOrRemoveUserListModalOpen=false;
              const closeButton = new CustomEvent('closeuserpopupmodal', {detail:this.isAddOrRemoveUserListModalOpen})
              this.dispatchEvent(closeButton);
          })
         }



}