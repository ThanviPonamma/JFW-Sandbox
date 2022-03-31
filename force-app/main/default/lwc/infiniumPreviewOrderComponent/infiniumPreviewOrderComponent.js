//Author:Thanvi;Date:20-SEP-2021
//Aim : To hold functionality of breadcrumb , edit ,confirm buttons

import { LightningElement,api,track } from 'lwc';
import confirmOrder from '@salesforce/apex/InfiniumPreviewOrder_Apex.confirmOrder_Apex'
import pubsub from 'c/pubsub' ; // To add publish and subscribe model

export default class InfiniumPreviewOrderComponent extends LightningElement {
    @api emergeOrderId;
    @api programId;

    //Aim:This method is responsible for calling the order status page on click of confirm order button
    //This method calls the order status page along with the order Id
    confirmOrderEvent(event){
        
    confirmOrder({emergeOrderId:this.emergeOrderId,
        selectedProgramId:this.programId})
        .then(result => {
            let resultGiven = result;
            if(resultGiven == "Done"){
            pubsub.fire('manageinventoryorderstatusevent', 'manageinventoryorderstatus');
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