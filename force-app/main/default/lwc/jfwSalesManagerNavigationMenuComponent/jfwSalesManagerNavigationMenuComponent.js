import {LightningElement} from 'lwc';
import JFWLogo from '@salesforce/resourceUrl/JFWlogo'; // To add header logo
import pubsub from 'c/pubsub'; // To add publish and subscribe model

export default class JfwSalesManagerMenuComponent extends LightningElement {

    //To hold the header logo
    jfwHeaderLogo = JFWLogo;
    //To navigate to the home page
    navigateToHomeComponent() {
        // The fire event is used to publish the event 
        pubsub.fire('homeevent', 'home');
    }

    //To navigate to the Place order flow - inventory
    navigateToInventoryPlaceOrderComponent(event) {
        // The fire event is used to publish the event 
        pubsub.fire('inventoryplaceorderevent', 'inventorypositem');
    }
    //To navigate to the Shopping cart - inventory
    navigateToInventoryShoppingCartComponent(event) {
        // The fire event is used to publish the event 
        pubsub.fire('shoppingcartevent', 'shoppingcart');
    }
    //To navigate to the Order status  - inventory
    navigateToInventoryOrderStatusComponent(event) {
        // The fire event is used to publish the event 
        pubsub.fire('orderstatusevent', 'orderstatus');
    }
    //To navigate to the POS Catalog  - inventory
    navigateToPOSCatalog(event) {
        // The fire event is used to publish the event 
        pubsub.fire('poscatalogevent', 'poscatalog');
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