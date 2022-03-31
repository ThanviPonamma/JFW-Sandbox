import {LightningElement,api,track,wire} from 'lwc';
//to hold the account url
import getAccount_Apex from '@salesforce/apex/InfiniumOpenProgramList_Apex.getAccount_Apex';
//pub sub model
import pubsub from 'c/pubsub';
//to navigate to the report page
import {NavigationMixin} from 'lightning/navigation';

export default class InfiniumSalesManagerContentComponent extends NavigationMixin(LightningElement) {
    // to track the URL
    @track urlPath;
    //to hold the selected menu
    @track selectedMenu;
    //to check if the selected menu is home
    @track isHome = false;
    //to hold selected program details for seasonal order flow
    @api selectedProgramDetail;
    //to hold selected program id
    @api selectedProgramId
    //to check if the selected menu is address book
    @track isAddressBook = false;
    //to check if the selected menu is Pos Catalog
    @track isPosCatalog = false;
    //to check if the selected menu is Manage Playbook
    @track isManagePlaybook = false;
    //to check if the selected menu open program  is Place Order
    @track isOpenProgramList = false;
    //to check if the selected menu is Place Order in seasonal order
    @track isProgramPOSItemToCart = false;
    //to check if the selected menu is shopping cart in seasonal order
    @track isProgramShoppingCart = false;
    //to hold the account URL
    @track accountURL;
    //to check if the selected menu is preview order
    @track isPreviewOrder = false;
    //to hold order id for preview
    @api orderId;
    //to check if the selected menu is order status
    @api isOrderStatus;
    	
	 //to check if the selected menu is inventory shopping cart
   @track isInventoryShoppingCart = false;
   //  to hold inventory order Id
   @track inventoryOrderId;
   //to check if the selected menu is pos catalog
   @track isPosCatalog=false;
    //to check if the selected menu is inventory preview order
    @track isInventoryPreviewOrder = false;
    @track isInventoryOrderStatus=false;
    @track isInventoryisPosItemMenuPage = false;

    @wire(getAccount_Apex) accountDetails;
    get accountDetailsForInfinium() {
        if (this.accountDetails.data) {
            let accountDetails = this.accountDetails.data;
            this.accountURL = accountDetails.Lightning_Community_URL__c;
            this.regiser();
            this.getCurrentUrl();
        }
    }
    //To get current URL, also used while the page is refreshed by the user.
    getCurrentUrl() {
        var windowLocation = window.location.href;
        if (windowLocation.includes('/')) {
            this.urlPath = windowLocation.substring(windowLocation.lastIndexOf("/") + 1, windowLocation.length);
            this.handleEvent(this.urlPath);
        }
    }


    // The register event is used to subscribe the event 
    regiser() {
        // To hold the home page
        pubsub.register('homeevent', this.handleEvent.bind(this));
        //To hold the Address book
        pubsub.register('manageaddressbookevent', this.handleEvent.bind(this));
        //To hold the log out event
        pubsub.register('logoutevent', this.handleEvent.bind(this));
        //To hold the log out event
        //To hold the Manage playbook
        pubsub.register('manageplaybookevent', this.handleEvent.bind(this));
        //To hold the Open program  List
        pubsub.register('manageopenprogramevent', this.handleEvent.bind(this));
        //To hold the program item to cart
        pubsub.register('managepositemtocartevent', this.handleEvent.bind(this));
        //To hold the shopping cart details for the selected program
        pubsub.register('shoppingcartevent', this.handleEvent.bind(this));
        //To hold the preview order details for the selected program
        pubsub.register('previeworderevent', this.handleEvent.bind(this));
        //To hold the seasonal order id
        pubsub.register('previeworderId', this.handleOrderId.bind(this));
        //To hold the program id for the seasonal order 
        pubsub.register('selectedprogramdetailevent', this.handleSelectedProgramDetail.bind(this));
        //To hold the order status
        pubsub.register('manageorderstatusevent', this.handleEvent.bind(this));
        //to handle program id
        pubsub.register('selectedProgramDetails', this.handleSelectedProgramDetailFromOrderStatus.bind(this));
        //To hold the inventory place order 
        pubsub.register('inventoryplaceorderevent', this.handleEvent.bind(this));
        //To hold the inventory shopping cart
        pubsub.register('inventoryshoppingcartevent', this.handleEvent.bind(this));
        //To hold the inventory order id
        pubsub.register('inventoryprevieworderId', this.handleInventoryOrderId.bind(this));
            //To hold the preview order details for the selected program
    pubsub.register('inventoryprevieworderevent', this.handleEvent.bind(this));
        //To hold the order status
        pubsub.register('manageinventoryorderstatusevent', this.handleEvent.bind(this));
        //to handle pos catalog
        pubsub.register('poscatalogevent', this.handleEvent.bind(this));
    }

    handleOrderId(value) {
        this.orderId = value;
    }

    handleInventoryOrderId(value){
        this.inventoryOrderId = value;
      }

    handleSelectedProgramDetailFromOrderStatus(value) {
        this.selectedProgramDetail = value;
        this.selectedProgramId = this.selectedProgramDetail.Program__c;
    }

    handleSelectedProgramDetail(value) {
        this.selectedProgramDetail = value;
        this.selectedProgramId = this.selectedProgramDetail.Program__c;
    }
    handleEvent(messageFromEvt) {
        //to hold the selected menu in the navigation menu
        this.selectedMenu = messageFromEvt;
        // To navigate to home page
        //Checks if the menu selected is blank or 'home'
        if (this.selectedMenu == 'home' || this.selectedMenu.length == 0) {
            document.title = 'Home';
            this.isHome = true;
            this.isAddressBook = false;
            this.isManagePlaybook = false;
            this.isOpenProgramList = false;
            this.isProgramPOSItemToCart = false
            this.isProgramShoppingCart = false;
            this.isPreviewOrder = false;
            this.isOrderStatus = false;
            this.isInventoryOrderStatus=false;
            this.isInventoryisPosItemMenuPage=false;
            this.isInventoryShoppingCart=false;
            this.isPosCatalog=false;
            this.isInventoryPreviewOrder=false;
            window.history.pushState("", 'Home', this.accountURL + '/s/');
        }

        // To navigate to address Book  page
        //checks if the menu selected is orderstatus
        if (this.selectedMenu == 'manageaddressBook') {
            document.title = 'Address Book';
            this.isAddressBook = true;
            this.isHome = false;
            this.isManagePlaybook = false;
            this.isOpenProgramList = false;
            this.isProgramPOSItemToCart = false
            this.isProgramShoppingCart = false;
            this.isPreviewOrder = false;
            this.isOrderStatus = false;
            this.isInventoryOrderStatus=false;
            this.isInventoryisPosItemMenuPage=false;
            this.isInventoryShoppingCart=false;
            this.isPosCatalog=false;
            this.isInventoryPreviewOrder=false;
            window.history.pushState("", 'Address Book', this.accountURL + '/s/' + 'manageaddressBook');
        }


        // To navigate to Manage Playbook
        //checks if the menu selected is Manage Playbook
        if (this.selectedMenu == 'manageplaybook') {
            document.title = 'Manage Playbook';
            this.isManagePlaybook = true;
            this.isHome = false;
            this.isAddressBook = false;
            this.isOpenProgramList = false;
            this.isProgramPOSItemToCart = false
            this.isProgramShoppingCart = false;
            this.isPreviewOrder = false;
            this.isOrderStatus = false;
            this.isInventoryOrderStatus=false;
            this.isInventoryisPosItemMenuPage=false;
            this.isInventoryShoppingCart=false;
            this.isPosCatalog=false;
            this.isInventoryPreviewOrder=false;
            window.history.pushState("", 'Manage Playbook', this.accountURL + '/s/' + 'manageplaybook');
        }

        // To navigate to Open Program List
        //checks if the menu selected is Open Program List
        if (this.selectedMenu == 'manageopenprogram') {
            document.title = 'Place Orders';
            this.isOpenProgramList = true;
            this.isHome = false;
            this.isAddressBook = false;
            this.isManagePlaybook = false;
            this.isProgramPOSItemToCart = false
            this.isProgramShoppingCart = false;
            this.isPreviewOrder = false;
            this.isOrderStatus = false;
            this.isInventoryOrderStatus=false;
            this.isInventoryisPosItemMenuPage=false;
            this.isInventoryShoppingCart=false;
            this.isPosCatalog=false;
            this.isInventoryPreviewOrder=false;
            window.history.pushState("", 'Place Orders', this.accountURL + '/s/' + 'manageopenprogram');
        }
        // To navigate to Place order in seasonal order
        //checks if the menu selected is place order in seasonal order
        if (this.selectedMenu == 'positemtocart') {
            document.title = 'Place Orders';
            this.isProgramPOSItemToCart = true;
            this.isHome = false;
            this.isAddressBook = false;
            this.isManagePlaybook = false;
            this.isOpenProgramList = false;
            this.isProgramShoppingCart = false;
            this.isPreviewOrder = false;
            this.isOrderStatus = false;
            this.isInventoryOrderStatus=false;
            this.isInventoryisPosItemMenuPage=false;
            this.isInventoryShoppingCart=false;
            this.isPosCatalog=false;
            this.isInventoryPreviewOrder=false;
            window.history.pushState("", 'Place Orders', this.accountURL + '/s/' + 'positemtocart'); 
        }
        // To navigate to shopping cart in seasonal order
        //checks if the menu selected is shopping cart in seasonal order
        if (this.selectedMenu == 'shoppingcart') {
            document.title = 'Shopping Cart';
            this.isProgramShoppingCart = true;
            this.isHome = false;
            this.isAddressBook = false;
            this.isManagePlaybook = false;
            this.isOpenProgramList = false;
            this.isProgramPOSItemToCart = false;
            this.isPreviewOrder = false;
            this.isOrderStatus = false;
            this.isInventoryOrderStatus=false;
            this.isInventoryisPosItemMenuPage=false;
            this.isInventoryShoppingCart=false;
            this.isPosCatalog=false;
            this.isInventoryPreviewOrder=false;
            window.history.pushState("", 'Shopping Cart', this.accountURL + '/s/' + 'shoppingcart');
        }

        // To navigate to Preview Order  page
        if (this.selectedMenu == 'previeworder') {
            document.title = 'Place Orders';
            this.isPreviewOrder = true;
            this.isHome = false;
            this.isAddressBook = false
            this.isManagePlaybook = false;
            this.isOpenProgramList = false;
            this.isProgramPOSItemToCart = false;
            this.isProgramShoppingCart = false;
            this.isOrderStatus = false;
            this.isInventoryOrderStatus=false;
            this.isInventoryisPosItemMenuPage=false;
            this.isInventoryShoppingCart=false;
            this.isPosCatalog=false;
            this.isInventoryPreviewOrder=false;
            window.history.pushState("", 'Preview Order', this.accountURL + '/s/' + 'previeworder');
        }

        if (this.selectedMenu == 'manageinventoryorderstatus') {
            document.title = 'Inventory Order Status';
            this.isInventoryOrderStatus=true;
            this.isPreviewOrder = false;
            this.isHome = false;
            this.isAddressBook = false
            this.isManagePlaybook = false;
            this.isOpenProgramList = false;
            this.isProgramPOSItemToCart = false;
            this.isProgramShoppingCart = false;
            this.isOrderStatus = false;
            this.isInventoryisPosItemMenuPage=false;
            this.isInventoryShoppingCart=false;
            this.isPosCatalog=false;
            this.isInventoryPreviewOrder=false;
            window.history.pushState("", 'Inventory Order Status', this.accountURL + '/s/' + 'manageinventoryorderstatus');
        }

        // To log out from the application
        if (this.selectedMenu == 'logout') {
            window.location.replace(this.accountURL + "/secur/logout.jsp");
        }

        //the report navigation
        if (this.selectedMenu == 'report') {
            this.isHome = false;
            this.isAddressBook = false;
            this.isManagePlaybook = false;
            this.isOpenProgramList = false;
            this.isProgramPOSItemToCart = false;
            this.isProgramShoppingCart = false;
            this.isPreviewOrder = false;
            this.isOrderStatus = false;
            this.isInventoryOrderStatus=false;
            this.isInventoryisPosItemMenuPage=false;
            this.isInventoryShoppingCart=false;
            this.isPosCatalog=false;
            this.isInventoryPreviewOrder=false;
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: this.accountURL + '/s/report/Report/Recent'
                }
            });

        }

        // To navigate to Order status  page
        if (this.selectedMenu == 'manageorderstatus') {
            document.title = 'Order Status';
            this.isOrderStatus = true;
            this.isHome = false;
            this.isAddressBook = false
            this.isManagePlaybook = false;
            this.isOpenProgramList = false;
            this.isProgramPOSItemToCart = false;
            this.isProgramShoppingCart = false;
            this.isPreviewOrder = false;
            this.isInventoryOrderStatus=false;
            this.isInventoryisPosItemMenuPage=false;
            this.isInventoryShoppingCart=false;
            this.isPosCatalog=false;
            this.isInventoryPreviewOrder=false;
            window.history.pushState("", 'Order Status', this.accountURL + '/s/' + 'manageorderstatus');
        }
       

        if (this.selectedMenu == 'inventorypositem') {
            document.title = 'Inventory Pos Item';
            this.isInventoryisPosItemMenuPage=true;
            this.isPosCatalog=false;
            this.isInventoryShoppingCart=false;
            this.isInventoryOrderStatus=false;
            this.isPreviewOrder = false;
            this.isHome = false;
            this.isAddressBook = false
            this.isManagePlaybook = false;
            this.isOpenProgramList = false;
            this.isProgramPOSItemToCart = false;
            this.isProgramShoppingCart = false;
            this.isOrderStatus = false;
            this.isInventoryPreviewOrder=false;
            window.history.pushState("", 'Inventory Pos Item', this.accountURL + '/s/' + 'inventorypositem');
        }

        if (this.selectedMenu == 'inventoryshoppingcart') {
            document.title = 'Inventory shopping cart';
            this.isInventoryShoppingCart=true;
            this.isInventoryisPosItemMenuPage=false;
            this.isInventoryOrderStatus=false;
            this.isPreviewOrder = false;
            this.isHome = false;
            this.isAddressBook = false
            this.isManagePlaybook = false;
            this.isOpenProgramList = false;
            this.isProgramPOSItemToCart = false;
            this.isProgramShoppingCart = false;
            this.isOrderStatus = false;
            this.isPosCatalog=false;
            this.isInventoryPreviewOrder=false;
            window.history.pushState("", 'Inventory shopping cart', this.accountURL + '/s/' + 'inventoryshoppingcart');
        }

        if (this.selectedMenu == 'poscatalog') {
            document.title = 'Inventory POS Catalog';
            this.isPosCatalog=true;
            this.isInventoryShoppingCart=false;
            this.isInventoryisPosItemMenuPage=false;
            this.isInventoryOrderStatus=false;
            this.isPreviewOrder = false;
            this.isHome = false;
            this.isAddressBook = false
            this.isManagePlaybook = false;
            this.isOpenProgramList = false;
            this.isProgramPOSItemToCart = false;
            this.isProgramShoppingCart = false;
            this.isOrderStatus = false;
            this.isInventoryPreviewOrder=false;
            window.history.pushState("", 'Inventory POS Catalog', this.accountURL + '/s/' + 'poscatalog');
        }

        if (this.selectedMenu == 'inventoryprevieworder') {
            document.title = 'Inventory Preview Order';
            this.isInventoryPreviewOrder=true;
            this.isPosCatalog=false;
            this.isInventoryShoppingCart=false;
            this.isInventoryisPosItemMenuPage=false;
            this.isInventoryOrderStatus=false;
            this.isPreviewOrder = false;
            this.isHome = false;
            this.isAddressBook = false
            this.isManagePlaybook = false;
            this.isOpenProgramList = false;
            this.isProgramPOSItemToCart = false;
            this.isProgramShoppingCart = false;
            this.isOrderStatus = false;
            window.history.pushState("", 'Inventory Preview Order', this.accountURL + '/s/' + 'inventoryprevieworder');
        }
    }
}