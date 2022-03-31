import {LightningElement} from 'lwc';
import CopperCaneLogo from '@salesforce/resourceUrl/CopperCaneLogo'; // To add header logo
import pubsub from 'c/pubsub'; // To add publish and subscribe model

export default class JfwSalesManagerMenuComponent extends LightningElement {
    //To hold the header logo
    coppercaneHeaderLogo = CopperCaneLogo;
    //To navigate to the home page
    navigateToHomeComponent() {
        // The fire event is used to publish the event 
        pubsub.fire('homeevent', 'home');
    }
    //To navigate to the Open Buy Book - seasonal
    navigateToOpenBuyBookComponent(event) {
        pubsub.fire('manageopenbuybookevent', 'manageopenbuybook');
    }
    //To navigate to the Order status  - seasonal
    navigateToOrderStatusComponent(event) {
        // The fire event is used to publish the event 
        pubsub.fire('manageorderstatusevent', 'manageorderstatus');
    }

    //To navigate to the POS Catalog  - seasonal
    navigateToPlaybook(event) {
       // The fire event is used to publish the event 
       pubsub.fire('manageplaybookevent', 'manageplaybook')
    }
    //To navigate to the Address Book
    navigateToAddressBookComponent(event) {
        // The fire event is used to publish the event 
        pubsub.fire('manageaddressbookevent', 'manageaddressBook');
    }
    logoutApplication() {
        // The fire event is used to publish the event 
        pubsub.fire('logoutevent', 'logout');
    }
        //to open the the helpdesk to send email
        openHelpDesk(event) {
            var strWindowFeatures = "location=yes,height=570,width=520,scrollbars=yes,status=yes";
            var URL = "mailto:?to=helpdesk@uxltechnologies.net";
            var win = window.open(URL, "_blank", strWindowFeatures);
        }
}