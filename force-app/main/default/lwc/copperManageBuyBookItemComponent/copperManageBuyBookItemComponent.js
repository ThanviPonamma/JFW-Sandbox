/**Author:Thanvi Date:10-Aug-2021
Aim: This is the child component that is responsible for add/remove items to/for the buy book */
import { LightningElement, wire, track, api } from 'lwc';
//importing the method get buy book items from the class CopperManageBuyBookList_Apex 
import getAllBuyBookItemList from '@salesforce/apex/CopperManageBuyBookList_Apex.getBuyBookItemList_Apex'
//importing the method method from the class CopperManageBuyBookList_Apex to add item to buy book
import addPosItemToBuyBook from '@salesforce/apex/CopperManageBuyBookList_Apex.addPosItemToBuyBook_Apex'
//importing the method method from the class CopperManageBuyBookList_Apex to remove item from buy book
import removePosItemFromBuyBook from '@salesforce/apex/CopperManageBuyBookList_Apex.removePosItemFromBuyBook_Apex'
//import the toast message event
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {refreshApex} from '@salesforce/apex';
export default class CopperManageBuyBookItemComponent extends LightningElement {
    //to get buy book details from the parent component
    @api getBuyBookDetails;
    //to hold lable name fetched from  parent
    @api labelName;
    //to hold buy book detail
    @track buyBookDetail = [];
    //to hold the buy book id 
    @track buyBookId;
    //to hold the associated items of the selected buy book
    @track associatedBuyBookItems;
    //to hold the available buy book items
    @track availableBuyBookItems
    //This is theh LWC Lifecycle method and it is invoked on page load
    connectedCallback() {
        //  fetching the buy book list details from the parent
        this.buyBookDetail = JSON.parse(JSON.stringify(this.getBuyBookDetails));
        this.buyBookId = this.buyBookDetail.Id;
    }
    //to fetch pos items from apex class
    @wire(getAllBuyBookItemList, {
        buyBookId: '$buyBookId'
    }) buyBookItemList;
    //to get the list of buy book on page init 
    get getAllBuyBookItems() {

        //   check if the buyBookList has data 
        if (this.buyBookItemList.data) {
            //console.log(JSON.stringify(this.buyBookItemList.data));
            let buyBookItemListDetails = this.buyBookItemList.data;
            this.associatedBuyBookItems = buyBookItemListDetails.buyBookItemList;
            this.availableBuyBookItems = buyBookItemListDetails.availablePosItems;

        }
    }
    //to close the pop up modal and to send the value to the parent componet of the changed value
    closeModal() {
        // custom event fired to the parent component to close the pop-up modal
        const closeButton = new CustomEvent('closemodal', {
            detail: {
                isModalOpen: false,
                saveandnew: false,
                isItemModal: true,
            }
        });
        //dispatch the custom event
        this.dispatchEvent(closeButton);
    }
    //to add item to  the buy book
    addItem(event) {
        let posItem = event.target.value;
        //invoking a method addPosItemToBuyBook of the class CopperManageBuyBookList_Apex
        addPosItemToBuyBook({
            // send selected buy book details as the parameter
            buyBook: JSON.stringify(this.buyBookDetail),
            posItem: JSON.stringify(posItem)
        })
            .then(result => {
                //to hold the result from the apex method
                let resultGiven = result;
                //display the toast message as the buy book item has been added successfully
                const evt = new ShowToastEvent({
                    message: 'The item "' + posItem.Item_Name__c + '" has been ' + "added" + ' successfully.',
                    variant: 'success',
                });
                // disaptch the event
                this.dispatchEvent(evt);
                return refreshApex(this.buyBookItemList);
            })
    }
    //to remove item from the buy book
    removeItem(event) {
        let posItem = event.target.value;
        //invoking a method addPosItemToBuyBook of the class CopperManageBuyBookList_Apex
        removePosItemFromBuyBook({
            // send selected buy book details as the parameter
            buyBook: JSON.stringify(this.buyBookDetail),
            posItem: JSON.stringify(posItem)
        })
            .then(result => {
                //to hold the result from the apex method
                let resultGiven = result;
                //display the toast message as the buy book item has been removed successfully
                const evt = new ShowToastEvent({
                    message: 'The item "' + posItem.Item_Name__c + '" has been ' + "removed" + ' successfully.',
                    variant: 'success',
                });
                // disaptch the event
                this.dispatchEvent(evt);
                refreshApex(this.buyBookItemList);
            })
    }
}