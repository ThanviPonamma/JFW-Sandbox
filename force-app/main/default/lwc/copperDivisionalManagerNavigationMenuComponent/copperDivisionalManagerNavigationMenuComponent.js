import {LightningElement,track,wire} from 'lwc';
import CopperCaneLogo from '@salesforce/resourceUrl/CopperCaneLogo'; // To add header logo
import pubsub from 'c/pubsub'; // To add publish and subscribe model
//Record api is used to get the users record from the org
import { getRecord } from 'lightning/uiRecordApi';
//import method to fetch the user id from the salesforce org
import USER_ID from '@salesforce/user/Id';
//import method to fetch the user name from the salesforce org
import NAME_FIELD from '@salesforce/schema/User.Username';

export default class CopperDivisionalManagerNavigationMenuComponent extends LightningElement {
    //to hold user name
    @track userName;

    //To hold the header logo
    coppercaneHeaderLogo = CopperCaneLogo;

    //Using @wire we are capture the getRecord import method from the import method 'lightning/uiRecordApi'
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD]
    })
    // The "getUserName" method holds data of the recordId and fields from the getRecord 
    getUserName({ error, data }) {

        // @track property userName hold the username and bind the value to the html form attribute
        if (data) {
            this.userName = data.fields.Username.value;
        }

        else if (error) {
            this.error = error;
        }
    }
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
    navigateToEditOrderForDivisionalManagerComponent(event) {
        // The fire event is used to publish the event 
        pubsub.fire('manageeditorderevent', 'editorder');
    }
     //to navigate to POD site
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