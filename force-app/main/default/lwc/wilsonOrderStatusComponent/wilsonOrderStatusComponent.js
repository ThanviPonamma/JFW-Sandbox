// Authors:Vanditha,Thanvi      Date:07-01-2021
//Aim:To hold the functinalities of  breadcrumb and call the child component responsible for showing table data-->

import { LightningElement,track,api } from 'lwc';
import pubsub from 'c/pubsub' ;


export default class WilsonOrderStatusComponent extends LightningElement {
    
    // to store the searched keword
    @track searchedKeyword = '';
    // to send the searched keyword to the child component to get the result
    @api searchKey = '';

//the onchange event to stored the searched keyword
 handleChangeSearchAddressBook(event) {
    this.searchedKeyword = event.detail.value;
    //the value is sent to parent to load the addreses without a search key
    if (this.searchedKeyword == '' || this.searchedKeyword == null) {
        this.searchKey = '';
    }
}

// the on click button to get the result of the searched keyword
searchOrderEvent(){
    this.searchKey = this.searchedKeyword;
    // console.log('the searched keyword', this.searchKey)
    if (this.searchedKeyword != '' || this.searchedKeyword != null) {
    }
  }
    // Aim:The event is fired when the there is an onclick event of edit pos button from the front end.
    openShoppingCartDetails(event){
       //the shopping cart page is called on click of the edit pos item button.
        pubsub.fire('shoppingcartevent', 'shoppingcart' );
    }

    //Aim: The event is fired when the there the home link in the breadcrumb is clicked
    navigateToHomePage(event){
       //The home page is called using pubsub model.
        pubsub.fire('homeevent', 'home' );
       
    }

}