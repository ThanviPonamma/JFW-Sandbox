//Authors:Sanjana Date: 15-09-2021
//Aim : To hold functionality of breadcrumb , edit ,confirm buttons

import { LightningElement,api,track } from 'lwc';
import confirmOrder from '@salesforce/apex/CopperPreviewOrder_Apex.confirmOrder_Apex'
import pubsub from 'c/pubsub' ; // To add publish and subscribe model

export default class CopperPreviewOrderComponent extends LightningElement {
    @api emergeOrderId;
    @api buyBookId;

    //Aim:This method is responsible for calling the order status page on click of confirm order button
    //This method calls the order status page along with the order Id
    confirmOrderEvent(event){
        
    confirmOrder({emergeOrderId:this.emergeOrderId,
        selectedProgramId:this.buyBookId})
        .then(result => {
            let resultGiven = result;
            if(resultGiven == "Done"){
            pubsub.fire('manageorderstatusevent', 'manageorderstatus');
            }
        })
    
    }

    //Aim : This method is responsible for calling shopping cart page for the selected order on click of edit order. 
    editOrderEvent(event){
        pubsub.fire('shoppingcartevent', 'shoppingcart' );
    
    }
    
    //Aim: The event is fired when the there the home link in the breadcrumb is clicked
    navigateToHomePage(event){
        //The home page is called using pubsub model.
         pubsub.fire('homeevent', 'home' );
        
     }
}