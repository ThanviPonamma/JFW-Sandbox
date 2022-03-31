import {LightningElement, api,track,wire} from 'lwc';
//to hold the account url
import getAccount_Apex from '@salesforce/apex/jfwPosItemToCart_Apex.getAccount';
//pub sub model
import pubsub from 'c/pubsub';
export default class JfwSalesManagerContentComponent extends LightningElement {
  // to track the URL
  @track urlPath;
  //to hold the selected menu
  @track selectedMenu;
  //to check if the selected menu is home
  @track isHome = false;
  //to check if the selected menu is pos item in place order flow
  @track isPosItemMenuPage = false;
  //to check if the selected menu is shopping cart  in place order flow
  @track isShoppingCart = false;
  //to check if the selected menu is shopping cart  in place order flow
  @track isPreviewOrder = false;
  //to hold order id for preview
  @api orderId;
  //to check if the selected menu is order status page
  @track isOrderStatusPage = false;
  //to check if the selected menu is address book
  @track isAddressBook = false;
  //to check if the selected menu is Pos Catalog
  @track isPosCatalog = false;

  @track accountURL;
  //to fetch the account details
  @wire(getAccount_Apex) accountDetails;
  get accountDetailsForJFW() {
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
    //To hold the inventory place order 
    pubsub.register('inventoryplaceorderevent', this.handleEvent.bind(this));
    //To hold the inventory Shopping cart 
    pubsub.register('shoppingcartevent', this.handleEvent.bind(this));
    //To hold the inventory preview order 
    pubsub.register('previeworderevent', this.handleEvent.bind(this));
    //To hold the inventory order id
    pubsub.register('previeworderId', this.handleOrderId.bind(this));
    // Order Status
    pubsub.register('orderstatusevent', this.handleEvent.bind(this));
    //To hold the pos catalog
    pubsub.register('poscatalogevent', this.handleEvent.bind(this));
    //To hold the Address book
    pubsub.register('manageaddressbookevent', this.handleEvent.bind(this));
    //To hold thelog out event
    pubsub.register('logoutevent', this.handleEvent.bind(this));
  }
  handleOrderId(value) {
    this.orderId = value;
  }
  handleEvent(messageFromEvt) {
    //to hold the selected menu in the navigation menu
    this.selectedMenu = messageFromEvt;

    // To navigate to home page
    //Checks if the menu selected is blank or 'home'
    if (this.selectedMenu == 'home' || this.selectedMenu.length == 0) {
      document.title = 'Home';
      this.isHome = true;
      this.isPosCatalog = false;
      this.isPosItemMenuPage = false;
      this.isShoppingCart = false;
      this.isPreviewOrder = false;
      this.isOrderStatusPage = false;
      this.isAddressBook = false;
      window.history.pushState("", 'Inventory Pos Item', this.accountURL + '/s/');
    }
    // To navigate to inventory page
    //checks if the menu selected is inventory pos item
    if (this.selectedMenu == 'inventorypositem') {
      document.title = 'Inventory Pos Item';
      this.isPosItemMenuPage = true;
      this.isHome = false;
      this.isPosCatalog = false;
      this.isShoppingCart = false;
      this.isOrderStatusPage = false;
      this.isAddressBook = false;
      this.isManageBrand = false;
      this.isManageItemType = false;
      this.isManageTerrioties = false;
      window.history.pushState("", 'Inventory Pos Item', this.accountURL + '/s/' + 'inventorypositem');

    }
    // To navigate to shopping cart  page
    //checks if the menu selected is shoppingcart
    if (this.selectedMenu == 'shoppingcart') {
      document.title = 'Shopping Cart';
      this.isShoppingCart = true;
      this.isHome = false;
      this.isPosCatalog = false;
      this.isPosItemMenuPage = false;
      this.isPreviewOrder = false;
      this.isOrderStatusPage = false;
      this.isAddressBook = false;
      window.history.pushState("", 'Shopping Cart', this.accountURL + '/s/' + 'shoppingcart');
    }
    // To navigate to Preview Order  page
    //checks if the menu preview order is shoppingcart
    if (this.selectedMenu == 'previeworder') {
      document.title = 'Preview Order';
      this.isPreviewOrder = true;
      this.isHome = false;
      this.isPosCatalog = false;
      this.isShoppingCart = false;
      this.isPosItemMenuPage = false;
      this.isOrderStatusPage = false;
      this.isAddressBook = false;
      window.history.pushState("", 'Preview Order', this.accountURL + '/s/' + 'previeworder');
    }
    // To navigate to order status  page
    //checks if the menu selected is orderstatus
    if (this.selectedMenu == 'orderstatus') {
      document.title = 'Order Status';
      this.isOrderStatusPage = true;
      this.isHome = false;
      this.isPosCatalog = false;
      this.isPosItemMenuPage = false;
      this.isShoppingCart = false;
      this.isPreviewOrder = false;
      this.isAddressBook = false;
      window.history.pushState("", 'Order Status', this.accountURL + '/s/' + 'orderstatus');
    }

    // To navigate to address Book  page
    //checks if the menu selected is orderstatus
    if (this.selectedMenu == 'manageaddressBook') {
      document.title = 'Address Book';
      this.isAddressBook = true;
      this.isHome = false;
      this.isPosCatalog = false;
      this.isPosItemMenuPage = false;
      this.isShoppingCart = false;
      this.isPreviewOrder = false;
      this.isOrderStatusPage = false;
      window.history.pushState("", 'Address Book', this.accountURL + '/s/' + 'manageaddressBook');
    }

    // To navigate to pos catalog  page
    //checks if the  menu selected is pos catalog
    if (this.selectedMenu == 'poscatalog') {
      document.title = 'POS Catalog';
      this.isPosCatalog = true;
      this.isHome = false;
      this.isPosItemMenuPage = false;
      this.isShoppingCart = false;
      this.isPreviewOrder = false;
      this.isOrderStatusPage = false;
      this.isAddressBook = false;
      window.history.pushState("", 'POS Catalog', this.accountURL + '/s/' + 'poscatalog');
    }
    // To log out from the application
    if (this.selectedMenu == 'logout') {
      window.location.replace(this.accountURL + "/secur/logout.jsp");
    }
  }
}