//  Author : VM,VB
//Date:21th october 2020
//Aim: To navigate to home page of click of home on the breadcrum
import { LightningElement } from 'lwc';
import pubsub from 'c/pubsub' ; 

export default class JfwManagePosItemsComponent extends LightningElement {
       //Aim: The event is fired when the there the home link in the breadcrumb is clicked
 navigateToHomePage(event){
    //The home page is called using pubsub model.
     pubsub.fire('homeevent', 'home' );
    
 }
}