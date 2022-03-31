import { LightningElement,api } from 'lwc';
// pubsub import method to navigate to home component
import pubsub from 'c/pubsub' ;
export default class JfwInventoryAddressBook extends LightningElement {

    @api searchValue = '';



    // To get the search value sent from child one to parent component
    searchEventHandler(event) {
        this.searchValue = event.detail;   
        this.template.querySelector('c-jfw-inventory-address-book-table').doInit();
    }

 //Aim: The event is fired when the there the home link in the breadcrumb is clicked
 navigateToHomePage(event){
    //The home page is called using pubsub model.
     pubsub.fire('homeevent', 'home' );
    
 }
    
}