//Author: SN,VB
//Date: 9th October 2020
//Aim : To hold functionality of fetching preview orders from the backend on init 

import { LightningElement,wire,track,api } from 'lwc';
// to get the all the preview order list from the parent component
import getAllCometOrders from '@salesforce/apex/JFWInventoryPreviewOrder_Apex.getAllCometOrders'
// to ge the no image from the static resource
import noImage from '@salesforce/resourceUrl/noimageavailable';
// Import method to refresh the apex class
import { refreshApex } from '@salesforce/apex';

export default class JfwPreviewOrderDetailsComponent extends LightningElement {

    // variable to store preview order details from apex method
    @track allCometOrders;
    // to get the emerge order id given from the parent component
    @api emergeOrderId;
    // to store the static resource image
    NoImageURL = noImage;

    // @wire property to get all the preview order details from apex method and store it in the variable "allCometOrdersToBeDisplayed" by passing emerge order id as parameter
    @wire (getAllCometOrders , {emergeOrderId: '$emergeOrderId'})
     allCometOrdersToBeDisplayed;

//To hold the fetched preview orders from the backend
    get cometOrders() {
        
    if (this.allCometOrdersToBeDisplayed.data) {
    this.allCometOrders = this.allCometOrdersToBeDisplayed.data;
    }
    refreshApex(this.allCometOrdersToBeDisplayed);
    }  

}