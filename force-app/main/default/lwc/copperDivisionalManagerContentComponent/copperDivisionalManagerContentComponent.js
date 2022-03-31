import {LightningElement,api,track,wire} from 'lwc';
//to hold the account url
import getAccount_Apex from '@salesforce/apex/CopperManageBrandList_Apex.getAccount';
//pub sub model
import pubsub from 'c/pubsub';
//to navigate to the report page
import {NavigationMixin} from 'lightning/navigation';

export default class CopperDivisionalManagerContentComponent extends NavigationMixin(LightningElement) {
    // to track the URL
    @track urlPath;
    //to hold the selected menu
    @track selectedMenu;
    //to check if the selected menu is home
    @track isHome = false;
    //to hold selected buy book details for seasonal order flow
    @api selectedBuyBookDetail;
    //to hold selected buy book id
    @api selectedBuyBookId
    //to check if the selected menu is address book
    @track isAddressBook = false;
    //to check if the selected menu is Pos Catalog
    @track isPosCatalog = false;
    //to check if the selected menu is Manage Playbook
    @track isManagePlaybook = false;
    //to check if the selected menu open buy book  is Place Order
    @track isOpenBuyBookList = false;
    //to check if the selected menu is Place Order in seasonal order
    @track isBuyBookPOSItemToCart = false;
    //to check if the selected menu is shopping cart in seasonal order
    @track isBuyBookShoppingCart = false;
    //to hold the account URL
    @track accountURL;
    //to check if the selected menu is preview order
    @track isPreviewOrder = false;
    //to hold order id for preview
    @api orderId;
    //to check if the selected menu is order status
    @api isOrderStatus;
    @api isEditOrder;

    @wire(getAccount_Apex) accountDetails;
    get accountDetailsForCopperCane() {
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
        //To hold the Open Buy Book  List
        pubsub.register('manageopenbuybookevent', this.handleEvent.bind(this));
        //To hold the Buy Book item to cart
        pubsub.register('managepositemtocartevent', this.handleEvent.bind(this));
        //To hold the shopping cart details for the selected program
        pubsub.register('shoppingcartevent', this.handleEvent.bind(this));
        //To hold the preview order details for the selected program
        pubsub.register('previeworderevent', this.handleEvent.bind(this));
        //To hold the seasonal order id
        pubsub.register('previeworderId', this.handleOrderId.bind(this));
        //To hold the buy book id for the seasonal order 
        pubsub.register('selectedbuybookdetailevent', this.handleSelectedBuyBookDetail.bind(this));
        //To hold the order status
        pubsub.register('manageorderstatusevent', this.handleEvent.bind(this));
        pubsub.register('manageeditorderevent', this.handleEvent.bind(this));

        //to handle buy book id
        pubsub.register('selectedBuyBookDetails', this.handleselectedBuyBookDetailFromOrderStatus.bind(this));
        
    }

    handleOrderId(value) {
        this.orderId = value;
    }

    handleselectedBuyBookDetailFromOrderStatus(value) {
        this.selectedBuyBookDetail = value;
        this.selectedBuyBookId = this.selectedBuyBookDetail.Program__c;
    }

    handleSelectedBuyBookDetail(value) {
        this.selectedBuyBookDetail = value;
        this.selectedBuyBookId = this.selectedBuyBookDetail.Program__c;
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
            this.isOpenBuyBookList = false;
            this.isBuyBookPOSItemToCart = false
            this.isBuyBookShoppingCart = false;
            this.isPreviewOrder = false;
            this.isOrderStatus = false;
            this.isEditOrder = false;
            window.history.pushState("", 'Home', this.accountURL + '/s/');
        }

        // To navigate to address Book  page
        //checks if the menu selected is orderstatus
        if (this.selectedMenu == 'manageaddressBook') {
            document.title = 'Address Book';
            this.isAddressBook = true;
            this.isHome = false;
            this.isManagePlaybook = false;
            this.isOpenBuyBookList = false;
            this.isBuyBookPOSItemToCart = false
            this.isBuyBookShoppingCart = false;
            this.isPreviewOrder = false;
            this.isOrderStatus = false;
            this.isEditOrder = false;
            window.history.pushState("", 'Address Book', this.accountURL + '/s/' + 'manageaddressBook');
        }


        // To navigate to Manage Playbook
        //checks if the menu selected is Manage Playbook
        if (this.selectedMenu == 'manageplaybook') {
            document.title = 'Manage Playbook';
            this.isManagePlaybook = true;
            this.isHome = false;
            this.isAddressBook = false;
            this.isOpenBuyBookList = false;
            this.isBuyBookPOSItemToCart = false
            this.isBuyBookShoppingCart = false;
            this.isPreviewOrder = false;
            this.isOrderStatus = false;
            this.isEditOrder = false;
            window.history.pushState("", 'Manage Playbook', this.accountURL + '/s/' + 'manageplaybook');
        }

        // To navigate to Open Buy Book List
        //checks if the menu selected is Open Buy Book List
        if (this.selectedMenu == 'manageopenbuybook') {
            document.title = 'Place Orders';
            this.isOpenBuyBookList = true;
            this.isHome = false;
            this.isAddressBook = false;
            this.isManagePlaybook = false;
            this.isBuyBookPOSItemToCart = false
            this.isBuyBookShoppingCart = false;
            this.isPreviewOrder = false;
            this.isOrderStatus = false;
            this.isEditOrder = false;
            window.history.pushState("", 'Place Orders', this.accountURL + '/s/' + 'manageopenbuybook');
        }
        // To navigate to Place order in seasonal order
        //checks if the menu selected is place order in seasonal order
        if (this.selectedMenu == 'positemtocart') {
            document.title = 'Place Orders';
            this.isBuyBookPOSItemToCart = true;
            this.isHome = false;
            this.isAddressBook = false;
            this.isManagePlaybook = false;
            this.isOpenBuyBookList = false;
            this.isBuyBookShoppingCart = false;
            this.isPreviewOrder = false;
            this.isOrderStatus = false;
            this.isEditOrder = false;
            window.history.pushState("", 'Place Orders', this.accountURL + '/s/' + 'positemtocart'); 
        }
        // To navigate to shopping cart in seasonal order
        //checks if the menu selected is shopping cart in seasonal order
        if (this.selectedMenu == 'shoppingcart') {
            document.title = 'Shopping Cart';
            this.isBuyBookShoppingCart = true;
            this.isHome = false;
            this.isAddressBook = false;
            this.isManagePlaybook = false;
            this.isOpenBuyBookList = false;
            this.isBuyBookPOSItemToCart = false;
            this.isPreviewOrder = false;
            this.isOrderStatus = false;
            this.isEditOrder = false;
            window.history.pushState("", 'Shopping Cart', this.accountURL + '/s/' + 'shoppingcart');
        }

        // To navigate to Preview Order  page
        if (this.selectedMenu == 'previeworder') {
            document.title = 'Place Orders';
            this.isPreviewOrder = true;
            this.isHome = false;
            this.isAddressBook = false
            this.isManagePlaybook = false;
            this.isOpenBuyBookList = false;
            this.isBuyBookPOSItemToCart = false;
            this.isBuyBookShoppingCart = false;
            this.isOrderStatus = false;
            this.isEditOrder = false;
            window.history.pushState("", 'Preview Order', this.accountURL + '/s/' + 'previeworder');
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
            this.isOpenBuyBookList = false;
            this.isBuyBookPOSItemToCart = false;
            this.isBuyBookShoppingCart = false;
            this.isPreviewOrder = false;
            this.isOrderStatus = false;
            this.isEditOrder = false;
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
            this.isOpenBuyBookList = false;
            this.isBuyBookPOSItemToCart = false;
            this.isBuyBookShoppingCart = false;
            this.isPreviewOrder = false;
            this.isEditOrder = false;
            window.history.pushState("", 'Order Status', this.accountURL + '/s/' + 'manageorderstatus');
        }

         // To navigate to Order status  page
         if (this.selectedMenu == 'editorder') {
            document.title = 'Edit Order';
            this.isEditOrder = true;
            this.isOrderStatus = false;
            this.isHome = false;
            this.isAddressBook = false
            this.isManagePlaybook = false;
            this.isOpenBuyBookList = false;
            this.isBuyBookPOSItemToCart = false;
            this.isBuyBookShoppingCart = false;
            this.isPreviewOrder = false;
            window.history.pushState("", 'Edit Order', this.accountURL + '/s/' + 'editorder');
        }
        // To log out from the application
        if (this.selectedMenu == 'logout') {
            window.location.replace(this.accountURL + "/secur/logout.jsp");
        }


    }
}