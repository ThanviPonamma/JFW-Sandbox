// Author : Sanjana; Date : 20-09-2021


import {LightningElement,wire,api,track} from 'lwc';
// importing the method getCurrentBrandMangerList from the class InfiniumManageBrandList_Apex
import getCurrentBrandUserList from '@salesforce/apex/InfiniumManageBrandList_Apex.getCurrentBrandMangerList';
//importing the method addUserToBrandManager from the class InfiniumManageBrandList_Apex
import addUserToBrand from '@salesforce/apex/InfiniumManageBrandList_Apex.addUserToBrandManager';
// importing the refresh apex event
import {refreshApex} from '@salesforce/apex';
// importing the toast event
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class InfiniumManageBrandUsersComponent extends LightningElement {
    //to hold the value of the brand for add/remove user from the parent component 
    @api brand;
    //to hold the selected brand Id
    @track selectedBrandId;
    //to display the available user list
    @track availableUserList;
    //to display the assign user list
    @track assignedUserList;
    //to hold the user to be update for the selected brand
    @track userListTobeAssigned;
    //to disable the save button when the pop-up is opened initially
    @track isSaveDisabled = true;
    //to hold brand name
    @api labelName;
    // This is the LWC Lifecycle method and it is invoked on page load
    connectedCallback() {
        //to capture the selected brand id and to get the user list for the id
        var selectedBrand = JSON.parse(JSON.stringify(this.brand));
        // fetch the Id from the variable selectedBrand
        this.selectedBrandId = selectedBrand.Id;
    }

    // fetching the return data from the method getCurrentBrandUserList and storing it i the variable getUserList on init event
    @wire(getCurrentBrandUserList, {
        brandId: '$selectedBrandId'
    })
    getUserList;

    //to get the list of users on page init
    get currentBrandUsers() {
        // check if there are users
        if (this.getUserList.data) {
            // give the list of users to the local variable userOptions
            let userOptions = this.getUserList.data;
            //store the list of available users in the variable availableUserList
            this.availableUserList = userOptions.allUsers;
            //store the list of selected users in the variable assignedUserList
            this.assignedUserList = userOptions.selectedUsers;

        }
    }

    //to close the pop-up modal and to send the changed value to the parent
    closeModal() {
        //To set the modal vale to false and send the value to parent , as the parent needs to know the value changed
        this.isAddOrRemoveUserListModalOpen = false;
        //create and fire a custom event to close the pop-up modal
        const closeButton = new CustomEvent('closeuserpopupmodal', {
            detail: this.isAddOrRemoveUserListModalOpen
        })
        this.dispatchEvent(closeButton);
    }

    //to assign the user to the brand
    theUserListToBeAssigned(event) {
        // disable the save button
        this.isSaveDisabled = false;
        //hold the user id of the user that is to be assigned
        this.userListTobeAssigned = event.target.value;
    }

    //to save the user list to the selected brand
    saveBrandUser(event) {
        // invoke the method addUserToBrand with the parameters selected user Id and Brand Id
        addUserToBrand({
            selectedUserIds: JSON.stringify(this.userListTobeAssigned),
            brandId: this.selectedBrandId
        })
            .then(result => {
                let resultGiven = result;
                //To set the modal vale to false and send the value to parent , as the parent needs to know the value changed
                // fire the toast message upon assigning/removing the user
                const evt = new ShowToastEvent({
                    message: 'The Brand Manager(s) for the Brand "' + this.labelName + '" is successfully updated.',
                    variant: 'success',
                });
                this.dispatchEvent(evt);
                //close the pop-up modal
                this.isAddOrRemoveUserListModalOpen = false;
                //fire the custom event to the parent to close the opo-up modal
                const closeButton = new CustomEvent('closeuserpopupmodal', {
                    detail: this.isAddOrRemoveUserListModalOpen
                })
                this.dispatchEvent(closeButton);
                //   refresh the user list
                refreshApex(this.getUserList);
            })
    }
}