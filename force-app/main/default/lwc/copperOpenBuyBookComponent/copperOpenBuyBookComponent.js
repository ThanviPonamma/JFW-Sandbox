/**  Authors: Thanvi ; Date- 30/Aug/21
 * Aim: To hold the functionality of breadcrumb of Place Order. */
import { LightningElement } from 'lwc';
// pubsub import method to navigate to home component
import pubsub from 'c/pubsub' ;
export default class CopperOpenBuyBookComponent extends LightningElement {
   //Aim: The event is fired when the there the home link in the breadcrumb is clicked
   navigateToHomePage(event) {
      //The home page is called using pubsub model.
      pubsub.fire('homeevent', 'home');
   }
}