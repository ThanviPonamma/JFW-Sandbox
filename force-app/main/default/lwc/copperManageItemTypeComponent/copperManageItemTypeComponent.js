// Authors: Sanjana
// Date: 10-08-2021
//Aim: To hold the functionality of breadcrumb of manage item type page. 
import { LightningElement } from 'lwc';
// pubsub import method to navigate to home component
import pubsub from 'c/pubsub' ;
export default class CopperManageItemTypeComponent extends LightningElement {
   //Aim: The event is fired when the there the home link in the breadcrumb is clicked
   navigateToHomePage(event) {
      //The home page is called using pubsub model.
      pubsub.fire('homeevent', 'home');
   }
}