import {
    LightningElement,
    api,
    track,
    wire
} from 'lwc';
import JFWLogo from '@salesforce/resourceUrl/JFWlogo'; // To add header logo
import pubsub from 'c/pubsub'; // To add publish and subscribe model
//to hold the account url
import getAccount_Apex from '@salesforce/apex/JFWManageBrandList_Apex.getAccount';
//FORM Factor
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class JfwAdminNavigationMenuComponent extends LightningElement {

    //To hold the header logo
    jfwHeaderLogo = JFWLogo;
    //to hold the account url
    @track accountURL;
    //to hold if the resolution is destktop or tablet
    @track isDesktopView;
    //to hold if the admin sub menu should be displayed
    @track showAdminSubMenu = false;
    //to hold if the invenrory sub menu should be displayed
    @track showInventorySubMenu=false;

    /**Authors : Sanjana Nadig, Thanvi Ponamma;Date:11-03-2021;CR No:JFW-10-Mar-11 
     * To meet the requirements of the CR. */
    //to hold the boolean state of the redirect required
    @track isRedirectRequired = false;

    //To fetch the account detials
    @wire(getAccount_Apex) accountDetails;
    get accountDetailsForWilsonDaniel() {
        if (this.accountDetails.data) {
            let accountDetails = this.accountDetails.data;
            this.accountURL = accountDetails.Lightning_Community_URL__c;
        }
    }

    /**Authors : Sanjana Nadig, Thanvi Ponamma;Date:11-03-2021;CR No:JFW-10-Mar-11 
     * To meet the requirements of the CR.The below method is added */
    //An init method to check if the url contains report in, if so set the refresh required to true
    connectedCallback() {
        //to hold the current url value
        var windowLocation = window.location.href;
        if (windowLocation.includes("/")) {
            //to hold the urlPath value
            this.isRedirectRequired = windowLocation.split("/").includes("report")

        }
       /**Authors : Varsha Thanvi Ponamma;Date:15-04-2021;
       * Aim: To if it is laptop or desktop resolution
       */
        if(FORM_FACTOR == 'Large'){
            this.isDesktopView = true;
        }
        else {
            this.isDesktopView = false;
        }
    }
      /**Authors : Varsha Thanvi Ponamma;Date:15-04-2021;
       * Aim: To check which submenu should be displayed on clcik
       */
    displaySubMenu(event){
        //to check if the admin submenu should be displayed
        if(event.target.name == 'adminsubmenu'){
            this.showAdminSubMenu = true;
            this.showInventorySubMenu=false;
        }
        //to check if the inventory submenu is selected
        else 
        {
            this.showInventorySubMenu=true;
            this.showAdminSubMenu = false;
        }
     
    }
    /**Authors : Sanjana Nadig, Thanvi Ponamma;Date:11-03-2021;CR No:JFW-10-Mar-11 
     * To meet the requirements of the CR.The below method is added */
    //To reload the page when the method is called.
    refreshPage() {
        location.reload();
    }


    //To navigate to the home page
    navigateToHomeComponent() {
        this.showAdminSubMenu = false;
        this.showInventorySubMenu=false;
        /**Authors : Sanjana Nadig, Thanvi Ponamma;Date:11-03-2021;CR No:JFW-10-Mar-11 
         * To meet the requirements of the CR.The below line is added */
        if (this.isRedirectRequired) {
            window.history.pushState("", 'Home', this.accountURL + '/s/');
            this.refreshPage();
        }
        // The fire event is used to publish the event 
        pubsub.fire('homeevent', 'home');
    }

    //To navigate to the Place order flow - inventory
    navigateToInventoryPlaceOrderComponent(event) {
        this.showInventorySubMenu=false;
        /**Authors : Sanjana Nadig, Thanvi Ponamma;Date:11-03-2021;CR No:JFW-10-Mar-11 
         * To meet the requirements of the CR.The below line is added */
        if (this.isRedirectRequired) {
            window.history.pushState("", 'Inventory Pos Item', this.accountURL + '/s/' + 'inventorypositem');
            this.refreshPage();
        }
        // The fire event is used to publish the event 
        pubsub.fire('inventoryplaceorderevent', 'inventorypositem');
    }
    //To navigate to the Shopping cart - inventory
    navigateToInventoryShoppingCartComponent(event) {
        this.showInventorySubMenu=false;
        /**Authors : Sanjana Nadig, Thanvi Ponamma;Date:11-03-2021;CR No:JFW-10-Mar-11 
         * To meet the requirements of the CR.The below line is added */
        if (this.isRedirectRequired) {
            window.history.pushState("", 'Shopping Cart', this.accountURL + '/s/' + 'shoppingcart');
            this.refreshPage();
        }
        // The fire event is used to publish the event 
        pubsub.fire('shoppingcartevent', 'shoppingcart');
    }
    //To navigate to the Order status  - inventory
    navigateToInventoryOrderStatusComponent(event) {
        this.showInventorySubMenu=false;
        /**Authors : Sanjana Nadig, Thanvi Ponamma;Date:11-03-2021;CR No:JFW-10-Mar-11 
         * To meet the requirements of the CR.The below line is added */
        if (this.isRedirectRequired) {
            window.history.pushState("", 'Order Status', this.accountURL + '/s/' + 'orderstatus');
            this.refreshPage();
        }
        // The fire event is used to publish the event 
        pubsub.fire('orderstatusevent', 'orderstatus');
    }
    //To navigate to the POS Catalog  - inventory
    navigateToPOSCatalog(event) {
        this.showInventorySubMenu=false;
        /**Authors : Sanjana Nadig, Thanvi Ponamma;Date:11-03-2021;CR No:JFW-10-Mar-11 
         * To meet the requirements of the CR.The below line is added */
        if (this.isRedirectRequired) {
            window.history.pushState("", 'POS Catalog', this.accountURL + '/s/' + 'poscatalog');
            this.refreshPage();
        }
        // The fire event is used to publish the event 
        pubsub.fire('poscatalogevent', 'poscatalog');
    }
    //To navigate to the Address Book
    navigateToAddressBookComponent(event) {
        this.showAdminSubMenu = false;
        this.showInventorySubMenu=false;
        /**Authors : Sanjana Nadig, Thanvi Ponamma;Date:11-03-2021;CR No:JFW-10-Mar-11 
         * To meet the requirements of the CR.The below line is added */
        if (this.isRedirectRequired) {
            window.history.pushState("", 'Address Book', this.accountURL + '/s/' + 'manageaddressBook');
            this.refreshPage();
        }
        // The fire event is used to publish the event 
        pubsub.fire('manageaddressbookevent', 'manageaddressBook');
    }
    //To navigate to the Manage Brand
    navigateManageBrandComponent(event) {
        this.showAdminSubMenu = false;
        /**Authors : Sanjana Nadig, Thanvi Ponamma;Date:11-03-2021;CR No:JFW-10-Mar-11 
         * To meet the requirements of the CR.The below line is added */
        if (this.isRedirectRequired) {
            window.history.pushState("", 'Manage Brand', this.accountURL + '/s/' + 'managebrand');
            this.refreshPage();
        }
        // The fire event is used to publish the event 
        pubsub.fire('managebrandevent', 'managebrand')
    }
    //To navigate to the Manage Item Type
    navigateManageItemTypeComponent(event) {
        this.showAdminSubMenu = false;
        /**Authors : Sanjana Nadig, Thanvi Ponamma;Date:11-03-2021;CR No:JFW-10-Mar-11 
         * To meet the requirements of the CR.The below line is added */
        if (this.isRedirectRequired) {
            window.history.pushState("", 'Manage Item Types', this.accountURL + '/s/' + 'manageitemtype');
            this.refreshPage();
        }
        // The fire event is used to publish the event 
        pubsub.fire('manageitemtypeevent', 'manageitemtype')
    }
    //To navigate to the Manage Terrioties
    navigateManageTerritoriesComponent(event) {
        this.showAdminSubMenu = false;
        /**Authors : Sanjana Nadig, Thanvi Ponamma;Date:11-03-2021;CR No:JFW-10-Mar-11 
         * To meet the requirements of the CR.The below line is added */
        if (this.isRedirectRequired) {
            window.history.pushState("", 'Manage Territories', this.accountURL + '/s/' + 'manageterritories');
            this.refreshPage();
        }
        // The fire event is used to publish the event 
        pubsub.fire('manageterritoriesevent', 'manageterritories');
    }
    // To navigate to Manage Shipping method
    navigateManageShippingMethodComponent(event) {
        this.showAdminSubMenu = false;
        /**Authors : Sanjana Nadig, Thanvi Ponamma;Date:11-03-2021;CR No:JFW-10-Mar-11 
         * To meet the requirements of the CR.The below line is added */
        if (this.isRedirectRequired) {
            window.history.pushState("", 'Manage Shipping Methods', this.accountURL + '/s/' + 'manageshippingmethods');
            this.refreshPage();
        }
        // The fire event is used to publish the event 
        pubsub.fire('manageshippingmethodsevent', 'manageshippingmethods');
    }

    // To navigate to Manage POS Items
    navigateManagePosItemComponent(event) {
        this.showAdminSubMenu = false;
        /**Authors : Sanjana Nadig, Thanvi Ponamma;Date:11-03-2021;CR No:JFW-10-Mar-11 
         * To meet the requirements of the CR.The below line is added */
        if (this.isRedirectRequired) {
            window.history.pushState("", 'Manage Pos Items', this.accountURL + '/s/' + 'managepositems');
            this.refreshPage();
        }
        // The fire event is used to publish the event 
        pubsub.fire('managepositemsevent', 'managepositems');
    }

    // To navigate to Manage ASN
    navigateManageASNComponent(event) {
        this.showAdminSubMenu = false;
        /**Authors : Sanjana Nadig, Thanvi Ponamma;Date:11-03-2021;CR No:JFW-10-Mar-11 
         * To meet the requirements of the CR.The below line is added */
        if (this.isRedirectRequired) {
            window.history.pushState("", 'Manage Advance Shipment Notice', this.accountURL + '/s/' + 'manageasn');
            this.refreshPage();
        }
        // The fire event is used to publish the event 
        pubsub.fire('manageasnevent', 'manageasn');
    }
    //To navigate to Manage Approval
    navigateManageApprovalsComponent(event) {
        this.showAdminSubMenu = false;
        /**Authors : Sanjana Nadig, Thanvi Ponamma;Date:11-03-2021;CR No:JFW-10-Mar-11 
         * To meet the requirements of the CR.The below line is added */
        if (this.isRedirectRequired) {
            window.history.pushState("", 'Manage Approvals', this.accountURL + '/s/' + 'manageapprovals');
            this.refreshPage();
        }
        // The fire event is used to publish the event 
        pubsub.fire('manageapprovalevent', 'manageapprovals');
    }
    //to log out of the application
    logoutApplication() {
        // The fire event is used to publish the event 
        pubsub.fire('logoutevent', 'logout');
    }
    //to navigate to report page
    navigateToReportsPage() {
        // The fire event is used to publish the event 
        pubsub.fire('reportevent', 'report');
        isRedirectRequired = true;
    }
    //to open the the helpdesk to send email
    openHelpDesk(event) {
        var strWindowFeatures = "location=yes,height=570,width=520,scrollbars=yes,status=yes";
        var URL = "mailto:?to=helpdesk@uxltechnologies.net";
        var win = window.open(URL, "_blank", strWindowFeatures);
    }
}