//Authors:Sanjana      Date:08-11-2021
//Aim : To hold functionality of breadcrumb , edit ,confirm buttons

import { LightningElement,api,track } from 'lwc';
import confirmOrder from '@salesforce/apex/InfiniumInventoryPreviewOrder_Apex.confirmOrder'
import pubsub from 'c/pubsub' ; // To add publish and subscribe model

export default class InfiniumInventoryPreviewOrderComponent extends LightningElement {
    @api emergeOrderId;

    //Aim:This method is responsible for calling the order status page on click of confirm order button
    //This method calls the order status page along with the order Id
    confirmOrderEvent(event){
    confirmOrder({orderId:this.emergeOrderId})
        .then(result => {
            let resultGiven = result;
            if(resultGiven == "done"){
            pubsub.fire('manageinventoryorderstatusevent', 'manageinventoryorderstatus');
            }
        })
        .catch(error => {
            this.error = error;
            // console.log('ERROR', this.error);
        });
    
    }
    
    //Aim : This method is responsible for calling shopping cart page for the selected order on click of edit order. 
    editOrderEvent(event){
        pubsub.fire('inventoryshoppingcartevent', 'inventoryshoppingcart' );
    
    }
    
    //Aim: The event is fired when the there the home link in the breadcrumb is clicked
    navigateToHomePage(event){
        //The home page is called using pubsub model.
         pubsub.fire('homeevent', 'home' );
        
     }
}