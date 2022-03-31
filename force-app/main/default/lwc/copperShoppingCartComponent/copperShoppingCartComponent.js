// Author:Thanvi      Date:01-SEP-2021
// To add the functionality for the breadcrumb home button and to call the preview page using pubsub modal when its invoked from child component
import {LightningElement,track,api} from 'lwc';
// To add publish and subscribe model
import pubsub from 'c/pubsub';

export default class CopperShoppingCartComponent extends LightningElement {
  //to hold the order Id given by the child component
  @api orderId;
  //To hold the selected buyBook details
  @api selectedBuyBookDetail; 
  //To hold the buyBookId
  @api buyBookId;
  //to hold the available budget
  @track availabeBudget = 0;
  //disable preview button
  @track disablePreview = false;

  connectedCallback() {
    this.availabeBudget =
      this.selectedBuyBookDetail.Available_Budget__c -
      this.selectedBuyBookDetail.Consumed_Budget__c;
  }

  //custom event from the child component is handled
  openPreviewComponent(event) {
      // to hold the order id sent from the child component
      this.orderId = event.detail;
      
  }

  //disable preview button
  disablePreviewButton(event) {
    this.disablePreview = event.detail;
  }

  //Aim: The event is fired when the home link in the breadcrumb is clicked
  navigateToHomePage(event) {
      //The home page is called using pubsub model.
      pubsub.fire('homeevent', 'home');

  }
  goToPosItemMenuComponent(event){
      //The pos item page is called using pubsub model.
      pubsub.fire('managepositemtocartevent', 'positemtocart');
  }

  previewOrder(event){
      // to navigate to the preview page
     pubsub.fire('previeworderevent', 'previeworder');
      // to hold the orderId
     pubsub.fire('previeworderId', this.orderId);
    //to hold program id
     pubsub.fire('buybookid',this.buyBookId);
     
  }
}