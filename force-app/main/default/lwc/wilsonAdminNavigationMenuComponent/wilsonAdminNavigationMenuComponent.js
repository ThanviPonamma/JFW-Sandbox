import {
    LightningElement,
    wire,
    track
} from "lwc";
// To add header logo
import WilsonDanielLogo from "@salesforce/resourceUrl/WilsonDanielLogo";
//Record api is used to get the users record from the org
import {
    getRecord
} from "lightning/uiRecordApi";
//import method to fetch the user id from the salesforce org
import USER_ID from "@salesforce/user/Id";
//import method to fetch the user name from the salesforce org
import NAME_FIELD from "@salesforce/schema/User.Username";
// To add publish and subscribe model
import pubsub from "c/pubsub";
//to hold the account url
import getAccount_Apex from '@salesforce/apex/WilsonManageBrandList_Apex.getAccount';

export default class WilsonAdminNavigationMenuComponent extends LightningElement {
    //Author: Sanjana ; Date: 31/01/2021
    //to hold user name
    @track userName;
    //to hold error message
    @track error;

    @track accountURL;
    /**Authors : Sanjana Nadig, Thanvi Ponamma;Date:17-03-2021;CR No:Wilson-17-Mar-02 
     * To meet the requirements of the CR. */
    //to hold the boolean state of the redirect required
    @track isRedirectRequired = false;

    //To hold the header logo
    wilsonDanielHeaderLogo = WilsonDanielLogo;

    @wire(getAccount_Apex) accountDetails;
    get accountDetailsForWilsonDaniel() {
        if (this.accountDetails.data) {
            let accountDetails = this.accountDetails.data;
            this.accountURL = accountDetails.Lightning_Community_URL__c;
        }
    }

    //Author: Sanjana ; Date: 31/01/2021
    //Using @wire we are capture the getRecord import method from the import method 'lightning/uiRecordApi'
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD]
    })

    // The "getUserName" method holds data of the recordId and fields from the getRecord
    getUserName({
        error,
        data
    }) {
        //@track property userName hold the username and bind the value to the html form attribute
        if (data) {
            this.userName = data.fields.Username.value;
        } else if (error) {
            this.error = error;
        }
    }

    // Authors: Thanvi, Sanjana
    // Date: 17/3/2021
    //commenting the below the code and rewriting it to satisfy the CR - Wilson-17-Mar-02 
    // connectedCallback() {
    //     var windowLocation = window.location.href;
    //     if (windowLocation.includes("/")) {
    //         var urlPath = windowLocation.substring(
    //             windowLocation.lastIndexOf("/") + 1,
    //             windowLocation.length
    //         );
    //         console.log("urlPath--->" + urlPath);
    //         if (urlPath == 'Recent' || urlPath == '?queryScope=mru') {
    //             this.isRedirectRequired = true;
    //         }
    //     }
    // }

     /**Authors : Sanjana Nadig, Thanvi Ponamma;Date:17-03-2021;CR No:Wilson-17-Mar-02 
     * To meet the requirements of the CR.The below method is added */
    //An init method to check if the url contains report in, if so set the refresh required to true
    connectedCallback() {
        //to hold the current url value
        var windowLocation = window.location.href;
        if (windowLocation.includes("/")) {
            //to hold the urlPath value
            this.isRedirectRequired = windowLocation.split("/").includes("report")

        }
    }

   /**Authors : Sanjana Nadig, Thanvi Ponamma;Date:17-03-2021;CR No:Wilson-17-Mar-02 
     * To meet the requirements of the CR.The below method is added */
    //To reload the page when the method is called.
    refreshPage() {
        location.reload();
    }
    //To navigate to the home page
    navigateToHomeComponent() {
           /**Authors : Sanjana Nadig, Thanvi Ponamma;Date:17-03-2021;CR No:Wilson-17-Mar-02 
         * To meet the requirements of the CR.The below line is added */
            if (this.isRedirectRequired) {
                window.history.pushState("", 'Home', this.accountURL + '/s/');
                this.refreshPage();
            }
        // The fire event is used to publish the event
        pubsub.fire("homeevent", "home");

    }

    //To navigate to the Place order flow - inventory
    navigateToInventoryPlaceOrderComponent(event) {
          /**Authors : Sanjana Nadig, Thanvi Ponamma;Date:17-03-2021;CR No:Wilson-17-Mar-02 
         * To meet the requirements of the CR.The below line is added */
           if (this.isRedirectRequired) {
            window.history.pushState("", 'Inventory Pos Item', this.accountURL + '/s/' + 'inventorypositem');
            this.refreshPage();
        }
        // The fire event is used to publish the event
        pubsub.fire("inventoryplaceorderevent", "inventorypositem");
    }
    //To navigate to the Shopping cart - inventory
    navigateToInventoryShoppingCartComponent(event) {
          /**Authors : Sanjana Nadig, Thanvi Ponamma;Date:17-03-2021;CR No:Wilson-17-Mar-02 
         * To meet the requirements of the CR.The below line is added */
           if (this.isRedirectRequired) {
            window.history.pushState("", 'Shopping Cart', this.accountURL + '/s/' + 'shoppingcart');
            this.refreshPage();
        }
        // The fire event is used to publish the event
        pubsub.fire("shoppingcartevent", "shoppingcart");
    }
    //To navigate to the Order status  - inventory
    navigateToInventoryOrderStatusComponent(event) {
         /**Authors : Sanjana Nadig, Thanvi Ponamma;Date:17-03-2021;CR No:Wilson-17-Mar-02 
         * To meet the requirements of the CR.The below line is added */
          if (this.isRedirectRequired) {
            window.history.pushState("", 'Order Status', this.accountURL + '/s/' + 'orderstatus');
            this.refreshPage();
        }
        // The fire event is used to publish the event
        pubsub.fire("orderstatusevent", "orderstatus");
    }
    //To navigate to the POS Catalog  - inventory
    navigateToPOSCatalog(event) {
         /**Authors : Sanjana Nadig, Thanvi Ponamma;Date:17-03-2021;CR No:Wilson-17-Mar-02 
         * To meet the requirements of the CR.The below line is added */
          if (this.isRedirectRequired) {
            window.history.pushState("", 'POS Catalog', this.accountURL + '/s/' + 'poscatalog');
            this.refreshPage();
        }
        // The fire event is used to publish the event
        pubsub.fire("poscatalogevent", "poscatalog");
    }
    //To navigate to the Address Book
    navigateToAddressBookComponent(event) {
          /**Authors : Sanjana Nadig, Thanvi Ponamma;Date:17-03-2021;CR No:Wilson-17-Mar-02 
         * To meet the requirements of the CR.The below line is added */
           if (this.isRedirectRequired) {
            window.history.pushState("", 'Address Book', this.accountURL + '/s/' + 'addressBook');
            this.refreshPage();
        }
        // The fire event is used to publish the event
        pubsub.fire("manageaddressbookevent", "addressBook");
    }
    //To navigate to the Manage Brand
    navigateManageBrandComponent(event) {
       /**Authors : Sanjana Nadig, Thanvi Ponamma;Date:17-03-2021;CR No:Wilson-17-Mar-02 
         * To meet the requirements of the CR.The below line is added */
        if (this.isRedirectRequired) {
            window.history.pushState("", 'Manage Brand', this.accountURL + '/s/' + 'managebrands');
            this.refreshPage();
        }
        // The fire event is used to publish the event
        pubsub.fire("managebrandevent", "managebrands");
    }
    //To navigate to the Manage Item Type
    navigateManageItemTypeComponent(event) {
      
         /**Authors : Sanjana Nadig, Thanvi Ponamma;Date:17-03-2021;CR No:Wilson-17-Mar-02 
         * To meet the requirements of the CR.The below line is added */
          if (this.isRedirectRequired) {
            window.history.pushState("", 'Manage Item Types', this.accountURL + '/s/' + 'manageitemtypes');
            this.refreshPage();
        }
        // The fire event is used to publish the event
        pubsub.fire("manageitemtypeevent", "manageitemtypes");
    }
    //To navigate to the Manage Terrioties
    navigateManageTerritoriesComponent(event) {
           /**Authors : Sanjana Nadig, Thanvi Ponamma;Date:17-03-2021;CR No:Wilson-17-Mar-02 
         * To meet the requirements of the CR.The below line is added */
            if (this.isRedirectRequired) {
                window.history.pushState("", 'Manage Territories', this.accountURL + '/s/' + 'manageterritories');
                this.refreshPage();
            }
        // The fire event is used to publish the event
        pubsub.fire("manageterritoriesevent", "manageterritories");
    }
    // To navigate to Manage Shipping method
    navigateManageShippingMethodComponent(event) {
         /**Authors : Sanjana Nadig, Thanvi Ponamma;Date:17-03-2021;CR No:Wilson-17-Mar-02 
         * To meet the requirements of the CR.The below line is added */
          if (this.isRedirectRequired) {
            window.history.pushState("", 'Manage Shipping Methods', this.accountURL + '/s/' + 'manageshippingmethods');
            this.refreshPage();
        }
        // The fire event is used to publish the event
        pubsub.fire("manageshippingmethodsevent", "manageshippingmethods");
    }

    // To navigate to Manage POS Items
    navigateManagePosItemComponent(event) {
        /**Authors : Sanjana Nadig, Thanvi Ponamma;Date:17-03-2021;CR No:Wilson-17-Mar-02 
         * To meet the requirements of the CR.The below line is added */
         if (this.isRedirectRequired) {
            window.history.pushState("", 'Manage Pos Items', this.accountURL + '/s/' + 'managepositems');
            this.refreshPage();
        }
        // The fire event is used to publish the event
        pubsub.fire("managepositemsevent", "managepositems");
    }

    // To navigate to Manage ASN
    navigateManageASNComponent(event) {
         /**Authors : Sanjana Nadig, Thanvi Ponamma;Date:17-03-2021;CR No:Wilson-17-Mar-02 
         * To meet the requirements of the CR.The below line is added */
          if (this.isRedirectRequired) {
            window.history.pushState("", 'Manage Advance Shipment Notice', this.accountURL + '/s/' + 'manageadvanceshipmentnotice');
            this.refreshPage();
        }
        // The fire event is used to publish the event
        pubsub.fire("manageasnevent", "manageadvanceshipmentnotice");
    }
    //To navigate to Manage Approval
    navigateManageApprovalsComponent(event) {
         /**Authors : Sanjana Nadig, Thanvi Ponamma;Date:17-03-2021;CR No:Wilson-17-Mar-02 
         * To meet the requirements of the CR.The below line is added */
          if (this.isRedirectRequired) {
            window.history.pushState("", 'Manage Approvals', this.accountURL + '/s/' + 'manageapprovals');
            this.refreshPage();
        }
        // The fire event is used to publish the event
        pubsub.fire("manageapprovalevent", "manageapprovals");
    }
    //to log out of the application
    logoutApplication() {
        // The fire event is used to publish the event
        pubsub.fire("logoutevent", "logout");
    }
    //to navigate to POD site
    //Author: Sanjana; Date: 31/01/2021
    navigateToPODSite() {
        this.template.querySelector("form").submit();
    }

    //to navigate to report page
    navigateToReportsPage() {
        // The fire event is used to publish the event
        pubsub.fire("reportevent", "report");
        isRedirectRequired = true;
    }
    //to open the the helpdesk to send email
    openHelpDesk(event) {
        var strWindowFeatures =
            "location=yes,height=570,width=520,scrollbars=yes,status=yes";
        var URL = "mailto:?to=helpdesk@uxltechnologies.net";
        var win = window.open(URL, "_blank", strWindowFeatures);
    }
}