//Author:Thanvi;Date:20-SEP-2021
//Aim:To hold the functinalities of  breadcrumb and call the child component responsible for showing table data-->

import { LightningElement,track,api,wire } from 'lwc';
// pubsub import method to navigate to home component
import pubsub from 'c/pubsub' ;
export default class InfiniumOrderStatusComponent extends LightningElement {
   //Aim: The event is fired when the there the home link in the breadcrumb is clicked
   navigateToHomePage(event) {
    //The home page is called using pubsub model.
    pubsub.fire('homeevent', 'home');
 }
}