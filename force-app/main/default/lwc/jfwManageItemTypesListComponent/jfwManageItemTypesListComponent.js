//Author:VM,VB
//Date:19th October 2020
//Aim: To display the list of of item types and to open and close create/edit popup.

import { LightningElement,wire,track,api } from 'lwc';
import getItemTypes from '@salesforce/apex/JFWManageItemTypes_Apex.getItemTypeList'
import deactivateSelectedItemType from '@salesforce/apex/JFWManageItemTypes_Apex.deactivateItemType'
// Import method refresh the page
import { refreshApex } from '@salesforce/apex';

//to display Toast Message
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class JfwManageItemTypesListComponent extends LightningElement {

    //declaration of global variables
    // to store the item type deatils given from apex method
    @track itemTypeListData;
    // to store item type list to display in the table
    @track itemTypeToBeDisplayedData;
    // to open edit popup modal
    @track isEditModalOpen = false;
    // to open popup modal
    @track isModelOpen;
    // to open the popup modal for create whne this is checked
    @track isSaveAndNew;
    //To display the item type name in toats message
    @track deactivatedItemType;

    //public property(An ownwer component will have the access to it) 
    @api labelName;
    // to send item details to grandchild
    @api itemTypeDetails;
    // to send validation to grand child
    @api itemTypeNameForValidation;
    // to check if item type is present or not
    @track itemTypeListFound=false;
    //network call to invoke apex method getItemTypeList
    @wire(getItemTypes) itemTypeListToBeDisplayed;
 
    //To fetch the item types from the backend 
    get itemTypeList(){
        if(this.itemTypeListToBeDisplayed.data){
           
           this.itemTypeToBeDisplayedData = this.itemTypeListToBeDisplayed.data;
        //    console.log('The item type list---->',JSON.stringify(this.itemTypeToBeDisplayedData))
           //extracting item type list from the returned object result and storing in a variable itemTypeListData
           this.itemTypeListData = this.itemTypeToBeDisplayedData.itemTypeList;
            //extracting item type list with validation from the returned object result and storing in a variable itemTypeListData
           this.itemTypeNameForValidation = this.itemTypeToBeDisplayedData.itemTypeNamesForValidation;
           if(this.itemTypeListData.length==0){
            this.itemTypeListFound=false;
        }
        else{
            this.itemTypeListFound=true;
        }
        refreshApex(this.itemTypeListToBeDisplayed);
        } 
    }

    //Aim:To take action when on click of deativate icon for a selected item type .
    handleChangeDeactivateItemtype(event){
      // The varaiable deactivateItemType is responsible for holding the item type data which has to be deactivated.
        let deactivateItemType = event.target.name;      
        this.deactivatedItemType = deactivateItemType.Item_Type__c;
         deactivateSelectedItemType({  
             //The selected item type data is sent to the backend as a parameter
            selectedItemType :JSON.stringify(deactivateItemType)
            })
            .then(result => {
                let resultGiven = result;
                if(resultGiven == 'done'){
                    const evt = new ShowToastEvent({
                        title: 'Success',
                        message: 'The item type "'+this.deactivatedItemType +'" has been deactivated successfully.',
                        variant: 'success',
                      });
                      this.dispatchEvent(evt);
                }
                //refresh function is called to load the updated result
                 refreshApex(this.itemTypeListToBeDisplayed);
            })
    }

    //To open the create modal on click of create button.
    openCreateModal(){
        
        this.itemTypeDetails = {};
        this.isModelOpen = true;
        this.isEditModalOpen = false;
        this.labelName = '';


    }

    //To open the edit modal on click of edit button.
    openEditModal(event){
         let selectedItemType = event.target.name;
         this.isModelOpen = true;
         this.isEditModalOpen = true;
         this.itemTypeDetails = selectedItemType;
         this.labelName = selectedItemType.Item_Type__c
         

    }

   //To close the create/edit modal on click of close or cancel button.
    closeModal(event){
        
        this.isModelOpen=event.detail.ismodelclose;
        this.isSaveAndNew = event.detail.issaveandnew;
        //check if the save and new option is created and invoke the createTerrioty method
        
         if(this.isSaveAndNew){
            this.isModalOpen=false;
            this.openCreateModal();
      
         }
         refreshApex(this.itemTypeListToBeDisplayed);

    }
}