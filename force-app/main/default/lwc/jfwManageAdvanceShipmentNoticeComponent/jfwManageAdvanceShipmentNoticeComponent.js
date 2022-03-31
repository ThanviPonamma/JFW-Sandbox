//Authors:SN,JP
//Date:21-10-2020
//Aim: To navigate to the home page on clik oh 'home' in the breadcrum
import {LightningElement} from 'lwc';
import pubsub from 'c/pubsub';


export default class JfwManageAdvanceShipmentNoticeComponent extends LightningElement {

    //Aim: The event is fired when the there the home link in the breadcrumb is clicked
    navigateToHomePage(event) {
        //The home page is called using pubsub model.
        pubsub.fire('homeevent', 'home');

    }
}