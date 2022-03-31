import { LightningElement } from 'lwc';
// import pubsub compoent to navigate to home page
import pubsub from 'c/pubsub' ;

export default class JfwManageShippingMethodsComponent extends LightningElement {
   
    //Aim: The event is fired when the there the home link in the breadcrumb is clicked
    navigateToHomePage(event){
    //The home page is called using pubsub model.
     pubsub.fire('homeevent', 'home' );
    
 }
}