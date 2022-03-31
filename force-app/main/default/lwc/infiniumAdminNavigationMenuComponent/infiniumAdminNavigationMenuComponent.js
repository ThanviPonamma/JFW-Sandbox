// Author : Sanjana; Date : 20-09-2021

import {LightningElement,api,track,wire} from 'lwc';
import InfiniumSpiritsLogo from '@salesforce/resourceUrl/InfiniumHeaderLogo'; // To add header logo
import pubsub from 'c/pubsub'; // To add publish and subscribe model
//to hold the account url
import getAccount_Apex from '@salesforce/apex/InfiniumManageBrandList_Apex.getAccount';
//FORM Factor
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class InfiniumAdminNaviagtionMenuComponent extends LightningElement {

    //To hold the header logo
    InfiniumHeaderLogo = InfiniumSpiritsLogo;
    //to hold the account url
    @track accountURL;
    //to hold if the resolution is destktop or tablet
    @track isDesktopView;
    //to hold if the admin sub menu should be displayed
    @track showAdminSubMenu = false;
    //to hold if the seasonal sub menu should be displayed
    @track showSeasonalSubMenu = false;

    //to hold the boolean state of the redirect required
    @track isRedirectRequired = false;

    //To fetch the account detials
    @wire(getAccount_Apex) accountDetails;
    get accountDetailsForInfiniumSpirits() {
        if (this.accountDetails.data) {
            let accountDetails = this.accountDetails.data;
            this.accountURL = accountDetails.Lightning_Community_URL__c;
        }
    }

    //An init method to check if the url contains report in, if so set the refresh required to true
    connectedCallback() {
        //to hold the current url value
        var windowLocation = window.location.href;
        if (windowLocation.includes("/")) {
            //to hold the urlPath value
            this.isRedirectRequired = windowLocation.split("/").includes("report")

        }
        /** Aim: To if it is laptop or desktop resolution
        */
        if (FORM_FACTOR == 'Large') {
            this.isDesktopView = true;
        }
        else {
            this.isDesktopView = false;
        }
    }
    /** Aim: To check which submenu should be displayed on click*/
    displaySubMenu(event) {
        //to check if the admin submenu should be displayed
        if (event.target.name == 'adminsubmenu') {
            this.showAdminSubMenu = true;
            this.showSeasonalSubMenu = false;
        }
        //to check if the seasonal submenu is selected
        else {
            this.showSeasonalSubMenu = true;
            this.showAdminSubMenu = false;
        }

    }
    //To reload the page when the method is called.
    refreshPage() {
        location.reload();
    }


    //To navigate to the home page
    navigateToHomeComponent() {
        this.showAdminSubMenu = false;
        this.showSeasonalSubMenu = false;
        if (this.isRedirectRequired) {
            window.history.pushState("", 'Home', this.accountURL + '/s/');
            this.refreshPage();
        }
        // The fire event is used to publish the event 
        pubsub.fire('homeevent', 'home');
    }


    //To navigate to the Address Book
    navigateToAddressBookComponent(event) {
        this.showAdminSubMenu = false;
        this.showSeasonalSubMenu = false;
        if (this.isRedirectRequired) {
            window.history.pushState("", 'Address Book', this.accountURL + '/s/' + 'manageaddressBook');
            this.refreshPage();
        }
        // The fire event is used to publish the event 
        pubsub.fire('manageaddressbookevent', 'manageaddressBook');
    }

    //to navigate to order status
    navigateToOrderStatusComponent(event){
        this.showAdminSubMenu = false;
        this.showSeasonalSubMenu = false;
        if (this.isRedirectRequired) {
            window.history.pushState("", 'Order Status', this.accountURL + '/s/' + 'manageorderstatus');
            this.refreshPage();
        }
        // The fire event is used to publish the event 
        pubsub.fire('manageorderstatusevent', 'manageorderstatus');
    }

    //to navigate to inventory order status
    navigateToInventoryOrderStatusComponent(event){
        this.showAdminSubMenu = false;
        this.showSeasonalSubMenu = false;
        if (this.isRedirectRequired) {
            window.history.pushState("", 'Inventory Order Status', this.accountURL + '/s/' + 'manageinventoryorderstatus');
            this.refreshPage();
        }
        // The fire event is used to publish the event 
        pubsub.fire('manageinventoryorderstatusevent', 'manageinventoryorderstatus');
    }
    //To navigate to the Manage Brand
    navigateManageBrandComponent(event) {
        this.showAdminSubMenu = false;
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
        if (this.isRedirectRequired) {
            window.history.pushState("", 'Manage Advance Shipment Notice', this.accountURL + '/s/' + 'manageasn');
            this.refreshPage();
        }
        // The fire event is used to publish the event 
        pubsub.fire('manageasnevent', 'manageasn');
    }
    //To navigate to Manage Buy Book
    navigateManageProgramComponent(event) {
        this.showAdminSubMenu = false;
        if (this.isRedirectRequired) {
            window.history.pushState("", 'Manage Program', this.accountURL + '/s/' + 'manageprogram');
            this.refreshPage();
        }
        // The fire event is used to publish the event 
        pubsub.fire('manageprogramevent', 'manageprogram');
    }

     //To navigate to the Place order flow - inventory
     navigateToInventoryPlaceOrderComponent(event) {
        /**Authors : Sanjana Nadig Date:08-11-2021*/
         if (this.isRedirectRequired) {
          window.history.pushState("", 'Inventory Pos Item', this.accountURL + '/s/' + 'inventorypositem');
          this.refreshPage();
      }
      // The fire event is used to publish the event
      pubsub.fire("inventoryplaceorderevent", "inventorypositem");
  }

    //To navigate to Manage Designation
    navigateManageDesignationComponent(event) {
        this.showAdminSubMenu = false;
        if (this.isRedirectRequired) {
            window.history.pushState("", 'Manage Designation', this.accountURL + '/s/' + 'managedesignation');
            this.refreshPage();
        }
        // The fire event is used to publish the event 
        pubsub.fire('managedesignationevent', 'managedesignation');
    }

    //To navigate to assign designation
    navigateManageAssignDesignationComponent(event) {
        this.showAdminSubMenu = false;
        if (this.isRedirectRequired) {
            window.history.pushState("", 'Assign Designation', this.accountURL + '/s/' + 'assigndesignation');
            this.refreshPage();
        }
        // The fire event is used to publish the event 
        pubsub.fire('assigndesignationevent', 'assigndesignation');
    }

    // to navigate to manage ordered items
    navigateManageOrderedItems(event){
        this.showAdminSubMenu = false;
        if (this.isRedirectRequired) {
            window.history.pushState("", 'Manage Ordered Items', this.accountURL + '/s/' + 'manageordereditems');
            this.refreshPage();
        }
        // The fire event is used to publish the event 
        pubsub.fire('manageordereditemsevent', 'manageordereditems');
    }

    // to navigate to send wave orders
    navigateSendWaveOrders(event){
        this.showAdminSubMenu = false;
        if (this.isRedirectRequired) {
            window.history.pushState("", 'Manage Send Wave Oreders', this.accountURL + '/s/' + 'managesendwaveorders');
            this.refreshPage();
        }
        // The fire event is used to publish the event 
        pubsub.fire('managesendwaveordersevent', 'managesendwaveorders');
    }

    //to navigate to manage chair user component
    navigateManageChairUserComponent(event) {
        this.showAdminSubMenu = false;
        if (this.isRedirectRequired) {
            window.history.pushState("", 'Manage Chair User', this.accountURL + '/s/' + 'managechairuser');
            this.refreshPage();
        }
        // The fire event is used to publish the event 
        pubsub.fire('managechairuserevent', 'managechairuser');
    }
    //To navigate to Manage Buy Book Budget
    navigateManageProgramBudgetComponent(event) {
        this.showAdminSubMenu = false;
        if (this.isRedirectRequired) {
            window.history.pushState("", 'Manage Program Budget', this.accountURL + '/s/' + 'manageprogrambudget');
            this.refreshPage();
        }
        // The fire event is used to publish the event 
        pubsub.fire('manageprogrambudgetevent', 'manageprogrambudget');
    }
    navigateToInventoryShoppingCartComponent(event){
        this.showAdminSubMenu = false;
        if (this.isRedirectRequired) {
            window.history.pushState("", 'Manage Inventory Shopping Cart', this.accountURL + '/s/' + 'inventoryshoppingcart');
            this.refreshPage();
        }
        // The fire event is used to publish the event 
        pubsub.fire('inventoryshoppingcartevent', 'inventoryshoppingcart');
    }
    //to navigate to playbook component
    navigateToPlaybook(event) {
        this.showAdminSubMenu = false;
        if (this.isRedirectRequired) {
            window.history.pushState("", 'Manage Playbook', this.accountURL + '/s/' + 'manageplaybook');
            this.refreshPage();
        }
        // The fire event is used to publish the event 
        pubsub.fire('manageplaybookevent', 'manageplaybook');
    }
    
    //to navigate to open buy book component
    navigateToOpenProgramComponent(event) {
        this.showAdminSubMenu = false;
        if (this.isRedirectRequired) {
            window.history.pushState("", 'Place Orders', this.accountURL + '/s/' + 'manageopenprogram');
            this.refreshPage();
        }
        // The fire event is used to publish the event 
        pubsub.fire('manageopenprogramevent', 'manageopenprogram');
    }
     //to navigate to edit order component
     navigateEditOrderComponent(event) {
        this.showAdminSubMenu = false;
        if (this.isRedirectRequired) {
            window.history.pushState("", 'Edit Order', this.accountURL + '/s/' + 'editorder');
            this.refreshPage();
        }
        // The fire event is used to publish the event 
        pubsub.fire('editorderevent', 'editorder');
    }

    navigateToPOSCatalog(event){
        this.showAdminSubMenu = false;
        if (this.isRedirectRequired) {
            window.history.pushState("", 'POS Catalog', this.accountURL + '/s/' + 'poscatalog');
            this.refreshPage();
        }
        // The fire event is used to publish the event 
        pubsub.fire('poscatalogevent', 'poscatalog');
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
     //To navigate to Manage Approval
     navigateManageApprovalsComponent(event) {
        
         if (this.isRedirectRequired) {
           window.history.pushState("", 'Manage Approvals', this.accountURL + '/s/' + 'manageapprovals');
           this.refreshPage();
       }
       // The fire event is used to publish the event
       pubsub.fire("manageapprovalevent", "manageapprovals");
   }
    //to open the the helpdesk to send email
    openHelpDesk(event) {
        var strWindowFeatures = "location=yes,height=570,width=520,scrollbars=yes,status=yes";
        var URL = "mailto:?to=helpdesk@uxltechnologies.net";
        var win = window.open(URL, "_blank", strWindowFeatures);
    }
}