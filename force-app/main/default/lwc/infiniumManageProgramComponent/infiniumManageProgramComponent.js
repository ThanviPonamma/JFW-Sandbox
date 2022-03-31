// Author : Sanjana; Date : 20-09-2021

import { LightningElement } from 'lwc';
import pubsub from 'c/pubsub' ;
export default class InfiniumManageBuyBookComponent extends LightningElement {
    //Aim: The event is fired when the there the home link in the breadcrumb is clicked
    navigateToHomePage(event) {
        //The home page is called using pubsub model.
        pubsub.fire('homeevent', 'home');

    }
}