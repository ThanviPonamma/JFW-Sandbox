import { LightningElement } from 'lwc';
import pubsub from 'c/pubsub' ;
  //Aim: The event is fired when the there the home link in the breadcrumb is clicked
export default class CopperBuyBookPlaybookComponent extends LightningElement {
      //Aim: The event is fired when the there the home link in the breadcrumb is clicked
      navigateToHomePage(event){
        //The home page is called using pubsub model.
         pubsub.fire('homeevent', 'home' );
        
     }
}