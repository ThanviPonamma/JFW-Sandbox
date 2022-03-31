// Authors:Vanditha,Thanvi      Date:06-01-2021
// Aim: This is the parent component that calls the two child components responsible to hold filterinputs and buttons and to display the table of pos items respectively.
//It is also responsible for the data exchange between the child components 

import { LightningElement ,api , track} from 'lwc';
import pubsub from 'c/pubsub' ;
export default class WilsonInventoryPosCatalogComponent extends LightningElement {

// To hold the brand Id coming from the component wilsonInventortPosCatalogComponent
@api brandId = '';
// To hold the search value coming from the component wilsonInventortPosCatalogComponent
@api searchValue = '';

// To get the brand id from child one to parent component
brandEvent(event) {
   //  give the brand detail from the custom event to the variable brand
   this.brandId = event.detail;  
   //console.log('parent brandId',this.brandId);
}

// To get the search value sent from child one to parent component
searchEventHandler(event) {
   //  give the search keywork detail from the custom event to the variable searchValue
   this.searchValue = event.detail;   
}

//Aim: The event is fired when the there the home link in the breadcrumb is clicked
navigateToHomePage(event){
   //The home page is called using pubsub model.
    pubsub.fire('homeevent', 'home' ); 
}
}