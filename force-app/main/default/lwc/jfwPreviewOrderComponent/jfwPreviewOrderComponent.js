//Author: SN,VB
//Date: 9th October 2020
//Aim : To hold functionality of breadcrumb , edit ,confirm buttons

import { LightningElement,api,track } from 'lwc';
import confirmOrder from '@salesforce/apex/JFWInventoryPreviewOrder_Apex.confirmOrder'
import pubsub from 'c/pubsub' ; // To add publish and subscribe model

export default class JfwPreviewOrderComponent extends LightningElement {
    @api emergeOrderId;

//Aim:This method is responsible for calling the order status page on click of confirm order button
//This method calls the order status page along with the order Id
confirmOrderEvent(event){
confirmOrder({orderId:this.emergeOrderId})
    .then(result => {
        let resultGiven = result;
        if(resultGiven == "done"){
        pubsub.fire('orderstatusevent', 'orderstatus');
        }
    })
    .catch(error => {
        this.error = error;
        console.log('ERROR', this.error);
    });

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