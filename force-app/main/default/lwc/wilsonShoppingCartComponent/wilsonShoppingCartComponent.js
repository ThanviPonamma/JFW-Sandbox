// Authors:Vanditha,Thanvi      Date:07-01-2021
// To add the functionality for the breadcrumb home button and to call the preview page using pubsub modal when its invoked from child component
import {LightningElement,track,api} from 'lwc';
// To add publish and subscribe model
import pubsub from 'c/pubsub';

export default class WilsonShoppingCartComponent extends LightningElement {
  //to hold the order Id given by the child component
  @api orderId;

  //custom event from the child component is handled
  openPreviewComponent(event) {
      // to hold the order id sent from the child component
      this.orderId = event.detail;
      //to navigate to the preview page
      pubsub.fire('previeworderevent', 'previeworder');
      //to hold the orderId
      pubsub.fire('previeworderId', this.orderId);
  }

  //Aim: The event is fired when the home link in the breadcrumb is clicked
  navigateToHomePage(event) {
      //The home page is called using pubsub model.
      pubsub.fire('homeevent', 'home');

  }
}