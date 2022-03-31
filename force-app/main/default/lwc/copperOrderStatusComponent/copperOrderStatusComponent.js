// Authors:Sanjana      Date:16-09-2021
//Aim:To hold the functinalities of  breadcrumb and call the child component responsible for showing table data-->

import { LightningElement,track,api,wire } from 'lwc';
import pubsub from 'c/pubsub' ;


export default class CopperOrderStatusComponent extends LightningElement {
    //Aim: The event is fired when the there the home link in the breadcrumb is clicked
    navigateToHomePage(event){
       //The home page is called using pubsub model.
        pubsub.fire('homeevent', 'home' );
       
    }

}