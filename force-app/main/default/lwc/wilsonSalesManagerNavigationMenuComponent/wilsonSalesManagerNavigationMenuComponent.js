import {LightningElement,wire,track} from 'lwc';
import WilsonDanielLogo from '@salesforce/resourceUrl/WilsonDanielLogo';// To add header logo
//Record api is used to get the users record from the org
import { getRecord } from 'lightning/uiRecordApi';
//import method to fetch the user id from the salesforce org
import USER_ID from '@salesforce/user/Id';
//import method to fetch the user name from the salesforce org
import NAME_FIELD from '@salesforce/schema/User.Username';
import pubsub from 'c/pubsub'; // To add publish and subscribe model

export default class WilsonSalesManagerNavigationMenuComponent extends LightningElement {
    //Author: Sanjana ; Date: 31/01/2021
    //to hold user name
    @track userName;
    //to hold error message
    @track error ;


    //Author: Sanjana ; Date: 31/01/2021
    //Using @wire we are capture the getRecord import method from the import method 'lightning/uiRecordApi'
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD]
    })

    // The "getUserName" method holds data of the recordId and fields from the getRecord 
    getUserName({error, data}) {

    // @track property userName hold the username and bind the value to the html form attribute
        if (data) {
            this.userName = data.fields.Username.value;
        }
        
        else if (error) {
            this.error = error ; 
         } 
    }
    //To hold the header logo
    wilsonDanielHeaderLogo = WilsonDanielLogo;

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
        pubsub.fire('manageaddressbookevent', 'addressBook');
    }
 //to navigate to POD site
      //Author: Sanjana; Date: 31/01/2021
      navigateToPODSite(){
        this.template.querySelector('form').submit();
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