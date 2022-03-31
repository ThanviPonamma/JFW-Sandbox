import {
  LightningElement,
  api,
  track,
  wire
} from 'lwc';
//to hold the account url
import getAccount_Apex from '@salesforce/apex/JFWManageBrandList_Apex.getAccount';
//pub sub model
import pubsub from 'c/pubsub';
//to navigate to the report page
import {
  NavigationMixin
} from 'lightning/navigation';

export default class JfwAdminContentComponent extends NavigationMixin(LightningElement) {
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
  //to check if the selected menu is Manage Brands
  @track isManageBrand = false;
  //to check if the selected menu is Manage Item Types
  @track isManageItemType = false;
  //to check if the selected menu is Manage Territoroes
  @track isManageTerrioties = false;
  //to check if the selected menu is Manage Shipping Methods
  @track isManageShippingMethods = false;
  //to check if the selected menu is Manage Pos Item
  @track isManagePosItem = false
  //to check if the selected menu is Manage Advance Shipment Notice
  @track isManageASN = false;
  //to check if the selected menu is Manage Approval
  @track isManageApproval = false;

  @track accountURL;

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
    //To hold the Manage Brand
    pubsub.register('managebrandevent', this.handleEvent.bind(this));
    //To hold the Manage Item Type
    pubsub.register('manageitemtypeevent', this.handleEvent.bind(this));
    //To hold the Manage Terrioties
    pubsub.register('manageterritoriesevent', this.handleEvent.bind(this));
    //To hold the Manage Shipping Method
    pubsub.register('manageshippingmethodsevent', this.handleEvent.bind(this));
    //To hold the Manage Pos Item
    pubsub.register('managepositemsevent', this.handleEvent.bind(this));
    //To hold the Manage ASN
    pubsub.register('manageasnevent', this.handleEvent.bind(this));
    //To hold the Manage Approval
    pubsub.register('manageapprovalevent', this.handleEvent.bind(this));
    //To hold the log out event
    pubsub.register('logoutevent', this.handleEvent.bind(this));
    //To hold the log out event
    pubsub.register('reportevent', this.handleEvent.bind(this));

  }
  handleOrderId(value) {
    // console.log('order Id in admin comp---->',this.orderId);
    this.orderId = value;
  }
  handleEvent(messageFromEvt) {
    //to hold the selected menu in the navigation menu
    this.selectedMenu = messageFromEvt;
    //  console.log(' this.selectedMenu', this.selectedMenu)
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
      this.isManageBrand = false;
      this.isManageItemType = false;
      this.isManageTerrioties = false;
      this.isManageShippingMethods = false;
      this.isManagePosItem = false;
      this.isManageASN = false;
      this.isManageApproval = false;
      window.history.pushState("", 'Home', this.accountURL + '/s/');
    }
    // To navigate to inventory page
    //checks if the menu selected is inventory pos item
    if (this.selectedMenu == 'inventorypositem') {
      document.title = 'Inventory Pos Item';
      this.isPosItemMenuPage = true;
      this.isHome = false;
      this.isPosCatalog = false;
      this.isShoppingCart = false;
      this.isPreviewOrder = false;
      this.isOrderStatusPage = false;
      this.isAddressBook = false;
      this.isManageBrand = false;
      this.isManageItemType = false;
      this.isManageTerrioties = false;
      this.isManageShippingMethods = false;
      this.isManagePosItem = false;
      this.isManageASN = false;
      this.isManageApproval = false;
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
      this.isManageBrand = false;
      this.isManageItemType = false;
      this.isManageTerrioties = false;
      this.isManageShippingMethods = false;
      this.isManagePosItem = false;
      this.isManageASN = false;
      this.isManageApproval = false;
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
      this.isManageBrand = false;
      this.isManageItemType = false;
      this.isManageTerrioties = false;
      this.isManageShippingMethods = false;
      this.isManagePosItem = false;
      this.isManageASN = false;
      this.isManageApproval = false;
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
      this.isManageBrand = false;
      this.isManageItemType = false;
      this.isManageTerrioties = false;
      this.isManageShippingMethods = false;
      this.isManagePosItem = false;
      this.isManageASN = false;
      this.isManageApproval = false;
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
      this.isManageBrand = false;
      this.isManageItemType = false;
      this.isManageTerrioties = false;
      this.isManageShippingMethods = false;
      this.isManagePosItem = false;
      this.isManageASN = false;
      this.isManageApproval = false;
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
      this.isManageBrand = false;
      this.isManageItemType = false;
      this.isManageTerrioties = false;
      this.isManageShippingMethods = false;
      this.isManagePosItem = false;
      this.isManageASN = false;
      this.isManageApproval = false;
      window.history.pushState("", 'POS Catalog', this.accountURL + '/s/' + 'poscatalog');
    }
    // To navigate to Manage Brand  page
    //checks if the menu selected is Manage Brand
    if (this.selectedMenu == 'managebrand') {
      document.title = 'Manage Brands';
      this.isManageBrand = true;
      this.isHome = false;
      this.isPosCatalog = false;
      this.isPosItemMenuPage = false;
      this.isShoppingCart = false;
      this.isPreviewOrder = false;
      this.isOrderStatusPage = false;
      this.isAddressBook = false;
      this.isManageItemType = false;
      this.isManageTerrioties = false;
      this.isManageShippingMethods = false;
      this.isManagePosItem = false;
      this.isManageASN = false;
      this.isManageApproval = false;
      window.history.pushState("", 'Manage Brands', this.accountURL + '/s/' + 'managebrand');
    }
    // To navigate to Manage Item Type  page
    //checks if the menu selected is Manage Item type
    if (this.selectedMenu == 'manageitemtype') {
      document.title = 'Manage Item Types';
      this.isManageItemType = true;
      this.isHome = false;
      this.isPosCatalog = false;
      this.isPosItemMenuPage = false;
      this.isShoppingCart = false;
      this.isPreviewOrder = false;
      this.isOrderStatusPage = false;
      this.isAddressBook = false;
      this.isManageBrand = false;
      this.isManageTerrioties = false;
      this.isManageShippingMethods = false;
      this.isManagePosItem = false;
      this.isManageASN = false;
      this.isManageApproval = false;
      window.history.pushState("", 'Manage Item Types', this.accountURL + '/s/' + 'manageitemtype');
    }
    // To navigate to Manage Territories  page
    //checks if the menu selected is Manage Territories
    if (this.selectedMenu == 'manageterritories') {
      document.title = 'Manage Territories';
      this.isManageTerrioties = true;
      this.isHome = false;
      this.isPosCatalog = false;
      this.isPosItemMenuPage = false;
      this.isShoppingCart = false;
      this.isPreviewOrder = false;
      this.isOrderStatusPage = false;
      this.isAddressBook = false;
      this.isManageBrand = false;
      this.isManageItemType = false;
      this.isManageShippingMethods = false;
      this.isManagePosItem = false;
      this.isManageASN = false;
      this.isManageApproval = false;
      window.history.pushState("", 'Manage Territories', this.accountURL + '/s/' + 'manageterritories');
    }
    // To navigate to Manage Shipping Method page
    //checks if the menu selected is Manage Territories
    if (this.selectedMenu == 'manageshippingmethods') {
      document.title = 'Manage Shipping Methods';
      this.isManageShippingMethods = true;
      this.isHome = false;
      this.isPosCatalog = false;
      this.isPosItemMenuPage = false;
      this.isShoppingCart = false;
      this.isPreviewOrder = false;
      this.isOrderStatusPage = false;
      this.isAddressBook = false;
      this.isManageBrand = false;
      this.isManageItemType = false;
      this.isManageTerrioties = false;
      this.isManagePosItem = false;
      this.isManageASN = false;
      this.isManageApproval = false;
      window.history.pushState("", 'Manage Shipping Methods', this.accountURL + '/s/' + 'manageshippingmethods');
    }
    // To navigate to Manage pos items page
    //checks if the menu selected is Manage Pos Items
    if (this.selectedMenu == 'managepositems') {
      document.title = 'Manage Pos Items';
      this.isManagePosItem = true;
      this.isManageShippingMethods = false;
      this.isHome = false;
      this.isPosCatalog = false;
      this.isPosItemMenuPage = false;
      this.isShoppingCart = false;
      this.isPreviewOrder = false;
      this.isOrderStatusPage = false;
      this.isAddressBook = false;
      this.isManageBrand = false;
      this.isManageItemType = false;
      this.isManageTerrioties = false;
      this.isManageASN = false;
      this.isManageApproval = false;
      window.history.pushState("", 'Manage Pos Items', this.accountURL + '/s/' + 'managepositems');
    }

    // To navigate to Manage ASN
    //checks if the menu selected is Manage ASN
    if (this.selectedMenu == 'manageasn') {
      document.title = 'Manage Advance Shipment Notice';
      this.isManageASN = true
      this.isManagePosItem = false;
      this.isManageShippingMethods = false;
      this.isHome = false;
      this.isPosCatalog = false;
      this.isPosItemMenuPage = false;
      this.isShoppingCart = false;
      this.isPreviewOrder = false;
      this.isOrderStatusPage = false;
      this.isAddressBook = false;
      this.isManageBrand = false;
      this.isManageItemType = false;
      this.isManageTerrioties = false;
      this.isManageApproval = false;
      window.history.pushState("", 'Manage Advance Shipment Notice', this.accountURL + '/s/' + 'manageasn');
    }
    // To navigate to Manage Approvals
    //checks if the menu selected is Manage Approvals
    if (this.selectedMenu == 'manageapprovals') {
      document.title = 'Manage Approvals';
      this.isManageApproval = true;
      this.isManagePosItem = false;
      this.isManageShippingMethods = false;
      this.isHome = false;
      this.isPosCatalog = false;
      this.isPosItemMenuPage = false;
      this.isShoppingCart = false;
      this.isPreviewOrder = false;
      this.isOrderStatusPage = false;
      this.isAddressBook = false;
      this.isManageBrand = false;
      this.isManageItemType = false;
      this.isManageTerrioties = false;
      this.isManageASN = false;
      window.history.pushState("", 'Manage Approvals', this.accountURL + '/s/' + 'manageapprovals');
    }
    // To log out from the application
    if (this.selectedMenu == 'logout') {
      window.location.replace(this.accountURL + "/secur/logout.jsp");
    }
    if (this.selectedMenu == 'report') {
      this.isManageApproval = false;
      this.isManagePosItem = false;
      this.isManageShippingMethods = false;
      this.isHome = false;
      this.isPosCatalog = false;
      this.isPosItemMenuPage = false;
      this.isShoppingCart = false;
      this.isPreviewOrder = false;
      this.isOrderStatusPage = false;
      this.isAddressBook = false;
      this.isManageBrand = false;
      this.isManageItemType = false;
      this.isManageTerrioties = false;
      this.isManageASN = false;
      this[NavigationMixin.Navigate]({
        type: 'standard__webPage',
        attributes: {
          url: this.accountURL + '/s/report/Report/Recent'
        }
    });
    
    }
  }
}