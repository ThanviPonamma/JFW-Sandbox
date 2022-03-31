import {LightningElement,api,track,wire} from 'lwc';
//to hold the account url
import getAccount_Apex from '@salesforce/apex/CopperManageBrandList_Apex.getAccount';
//pub sub model
import pubsub from 'c/pubsub';
//to navigate to the report page
import {NavigationMixin} from 'lightning/navigation';

export default class CopperAdminContentComponent extends NavigationMixin(LightningElement) {
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
  //to check if the selected menu is Manage Buy Book
  @track isManageBuyBook = false;
  //to check if the selected menu is Manage Designation
  @track isManageDesignation = false;
  //to check if the selected menu is Assign Designation
  @track isAssignDesignation = false;
  //to check if the selected menu is Manage Chair User
  @track isManageChairUser = false;
  //to check if the selected menu is Manage Buy Book Budget
  @track isManageBuyBookBudget = false;
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
  //to check if the selected menu is edit order
  @track isEditOrder = false;
   //to check if the selected menu is tracking number
   @track isTrackingNumber = false;
  //to hold order id for preview
  @api orderId;
  //to check if the selected menu is order status
  @api isOrderStatus;

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
    //To hold the Manage Buy Book
    pubsub.register('managebuybookevent', this.handleEvent.bind(this));
    //To hold the Manage Designation
    pubsub.register('managedesignationevent', this.handleEvent.bind(this));
    //To hold the Assign Designation
    pubsub.register('assigndesignationevent', this.handleEvent.bind(this));
    //To hold the Manage chair user
    pubsub.register('managechairuserevent', this.handleEvent.bind(this));
    //To hold the Manage Buy Book Budget
    pubsub.register('managebuybookbudgetevent', this.handleEvent.bind(this));
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
    //To hold the edit order for the selected program
    pubsub.register('editorderevent', this.handleEvent.bind(this));
    //To hold the tracking number 
    pubsub.register('trackingnumberevent', this.handleEvent.bind(this));
    //To hold the seasonal order id
    pubsub.register('previeworderId', this.handleOrderId.bind(this));
    //To hold the buy book id for the seasonal order 
    pubsub.register('selectedbuybookdetailevent', this.handleSelectedBuyBookDetail.bind(this));
    //To hold the order status
    pubsub.register('manageorderstatusevent', this.handleEvent.bind(this));
    //to handle buy book id
    pubsub.register('selectedBuyBookDetails', this.handleselectedBuyBookDetailFromOrderStatus.bind(this));

  }

  handleOrderId(value) {
    this.orderId = value;
  }

  handleselectedBuyBookDetailFromOrderStatus(value){
       this.selectedBuyBookDetail = value;
       this.selectedBuyBookId  =  this.selectedBuyBookDetail.Program__r.Id;
  }

  handleSelectedBuyBookDetail(value) {
    this.selectedBuyBookDetail = value;
    this.selectedBuyBookId = this.selectedBuyBookDetail.Program__c
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
      this.isManageBrand = false;
      this.isManageItemType = false;
      this.isManagePosItem = false;
      this.isManageTerrioties = false;
      this.isManageShippingMethods = false;
      this.isManageASN = false;
      this.isManageApproval = false;
      this.isManageBuyBook = false;
      this.isManageDesignation = false;
      this.isAssignDesignation = false;
      this.isManageChairUser = false;
      this.isManageBuyBookBudget = false;
      this.isManagePlaybook = false;
      this.isOpenBuyBookList = false;
      this.isBuyBookPOSItemToCart=false
      this.isBuyBookShoppingCart=false;
      this.isPreviewOrder=false;
      this.isEditOrder=false;
      this.isTrackingNumber=false;
      this.isOrderStatus=false;
      window.history.pushState("", 'Home', this.accountURL + '/s/');
    }

    // To navigate to address Book  page
    //checks if the menu selected is orderstatus
    if (this.selectedMenu == 'manageaddressBook') {
      document.title = 'Address Book';
      this.isAddressBook = true;
      this.isHome = false;
      this.isManageBrand = false;
      this.isManageItemType = false;
      this.isManagePosItem = false;
      this.isManageTerrioties = false;
      this.isManageShippingMethods = false;
      this.isManageASN = false;
      this.isManageApproval = false;
      this.isManageBuyBook = false;
      this.isManageDesignation = false;
      this.isAssignDesignation = false;
      this.isManageChairUser = false;
      this.isManageBuyBookBudget = false;
      this.isManagePlaybook = false;
      this.isOpenBuyBookList = false;
      this.isBuyBookPOSItemToCart=false
      this.isBuyBookShoppingCart=false;
      this.isPreviewOrder=false;
      this.isEditOrder=false;
      this.isTrackingNumber=false;
      this.isOrderStatus=false;
      window.history.pushState("", 'Address Book', this.accountURL + '/s/' + 'manageaddressBook');
    }

    // To navigate to Manage Brand  page
    //checks if the menu selected is Manage Brand
    if (this.selectedMenu == 'managebrand') {
      document.title = 'Manage Brands';
      this.isManageBrand = true;
      this.isHome = false;
      this.isAddressBook = false;
      this.isManageItemType = false;
      this.isManagePosItem = false;
      this.isManageTerrioties = false;
      this.isManageShippingMethods = false;
      this.isManageASN = false;
      this.isManageApproval = false;
      this.isManageBuyBook = false;
      this.isManageDesignation = false;
      this.isAssignDesignation = false;
      this.isManageChairUser = false;
      this.isManageBuyBookBudget = false;
      this.isManagePlaybook = false;
      this.isOpenBuyBookList = false;
      this.isBuyBookPOSItemToCart=false
      this.isBuyBookShoppingCart=false;
      this.isPreviewOrder=false;
      this.isEditOrder=false;
      this.isTrackingNumber=false;
      this.isOrderStatus=false;
      window.history.pushState("", 'Manage Brands', this.accountURL + '/s/' + 'managebrand');
    }
    // To navigate to Manage Item Type  page
    //checks if the menu selected is Manage Item type
    if (this.selectedMenu == 'manageitemtype') {
      document.title = 'Manage Item Types';
      this.isManageItemType = true;
      this.isHome = false;
      this.isAddressBook = false;
      this.isManageBrand = false;
      this.isManagePosItem = false;
      this.isManageTerrioties = false;
      this.isManageShippingMethods = false;
      this.isManageASN = false;
      this.isManageApproval = false;
      this.isManageBuyBook = false;
      this.isManageDesignation = false;
      this.isAssignDesignation = false;
      this.isManageChairUser = false;
      this.isManageBuyBookBudget = false;
      this.isManagePlaybook = false;
      this.isOpenBuyBookList = false;
      this.isBuyBookPOSItemToCart=false
      this.isBuyBookShoppingCart=false;
      this.isPreviewOrder=false;
      this.isEditOrder=false;
      this.isTrackingNumber=false;
      this.isOrderStatus=false;
      window.history.pushState("", 'Manage Item Types', this.accountURL + '/s/' + 'manageitemtype');
    }
    // To navigate to Manage Territories  page
    //checks if the menu selected is Manage Territories
    if (this.selectedMenu == 'manageterritories') {
      document.title = 'Manage Territories';
      this.isManageTerrioties = true;
      this.isHome = false;
      this.isAddressBook = false;
      this.isManageBrand = false;
      this.isManageItemType = false;
      this.isManagePosItem = false;
      this.isManageShippingMethods = false;
      this.isManageASN = false;
      this.isManageApproval = false;
      this.isManageBuyBook = false;
      this.isManageDesignation = false;
      this.isAssignDesignation = false;
      this.isManageChairUser = false;
      this.isManageBuyBookBudget = false;
      this.isManagePlaybook = false;
      this.isOpenBuyBookList = false;
      this.isBuyBookPOSItemToCart=false
      this.isBuyBookShoppingCart=false;
      this.isPreviewOrder=false;
      this.isEditOrder=false;
      this.isTrackingNumber=false;
      this.isOrderStatus=false;
      window.history.pushState("", 'Manage Territories', this.accountURL + '/s/' + 'manageterritories');
    }
    // To navigate to Manage Shipping Method page
    //checks if the menu selected is Manage Territories
    if (this.selectedMenu == 'manageshippingmethods') {
      document.title = 'Manage Shipping Methods';
      this.isManageShippingMethods = true;
      this.isHome = false;
      this.isAddressBook = false;
      this.isManageBrand = false;
      this.isManageItemType = false;
      this.isManageTerrioties = false;
      this.isManagePosItem = false;
      this.isManageASN = false;
      this.isManageApproval = false;
      this.isManageBuyBook = false;
      this.isManageDesignation = false;
      this.isAssignDesignation = false;
      this.isManageChairUser = false;
      this.isManageBuyBookBudget = false;
      this.isManagePlaybook = false;
      this.isOpenBuyBookList = false;
      this.isBuyBookPOSItemToCart=false
      this.isBuyBookShoppingCart=false;
      this.isPreviewOrder=false;
      this.isEditOrder=false;
      this.isTrackingNumber=false;
      this.isOrderStatus=false;
      window.history.pushState("", 'Manage Shipping Methods', this.accountURL + '/s/' + 'manageshippingmethods');
    }
    // To navigate to Manage pos items page
    //checks if the menu selected is Manage Pos Items
    if (this.selectedMenu == 'managepositems') {
      document.title = 'Manage Pos Items';
      this.isManagePosItem = true;
      this.isHome = false;
      this.isAddressBook = false;
      this.isManageBrand = false;
      this.isManageItemType = false;
      this.isManageTerrioties = false;
      this.isManageShippingMethods = false;
      this.isManageASN = false;
      this.isManageApproval = false;
      this.isManageBuyBook = false;
      this.isManageDesignation = false;
      this.isAssignDesignation = false;
      this.isManageChairUser = false;
      this.isManageBuyBookBudget = false;
      this.isManagePlaybook = false;
      this.isOpenBuyBookList = false;
      this.isBuyBookPOSItemToCart=false
      this.isBuyBookShoppingCart=false;
      this.isPreviewOrder=false;
      this.isEditOrder=false;
      this.isTrackingNumber=false;
      this.isOrderStatus=false;
      window.history.pushState("", 'Manage Pos Items', this.accountURL + '/s/' + 'managepositems');
    }

    // To navigate to Manage ASN
    //checks if the menu selected is Manage ASN
    if (this.selectedMenu == 'manageasn') {
      document.title = 'Manage Advance Shipment Notice';
      this.isManageASN = true
      this.isHome = false;
      this.isAddressBook = false;
      this.isManageBrand = false;
      this.isManageItemType = false;
      this.isManagePosItem = false;
      this.isManageTerrioties = false;
      this.isManageShippingMethods = false;
      this.isManageApproval = false;
      this.isManageBuyBook = false;
      this.isManageDesignation = false;
      this.isAssignDesignation = false;
      this.isManageChairUser = false;
      this.isManageBuyBookBudget = false;
      this.isManagePlaybook = false;
      this.isOpenBuyBookList = false;
      this.isBuyBookPOSItemToCart=false
      this.isBuyBookShoppingCart=false;
      this.isPreviewOrder=false;
      this.isEditOrder=false;
      this.isTrackingNumber=false;
      this.isOrderStatus=false;
      window.history.pushState("", 'Manage Advance Shipment Notice', this.accountURL + '/s/' + 'manageasn');
    }
    // To navigate to Manage Approvals
    //checks if the menu selected is Manage Approvals
    if (this.selectedMenu == 'manageapprovals') {
      document.title = 'Manage Approvals';
      this.isManageApproval = true;
      this.isHome = false;
      this.isAddressBook = false;
      this.isManageBrand = false;
      this.isManageItemType = false;
      this.isManagePosItem = false;
      this.isManageTerrioties = false;
      this.isManageShippingMethods = false;
      this.isManageASN = false;
      this.isManageBuyBook = false;
      this.isManageDesignation = false;
      this.isAssignDesignation = false;
      this.isManageChairUser = false;
      this.isManageBuyBookBudget = false;
      this.isManagePlaybook = false;
      this.isOpenBuyBookList = false;
      this.isBuyBookPOSItemToCart=false
      this.isBuyBookShoppingCart=false;
      this.isPreviewOrder=false;
      this.isEditOrder=false;
      this.isTrackingNumber=false;
      this.isOrderStatus=false;
      window.history.pushState("", 'Manage Approvals', this.accountURL + '/s/' + 'manageapprovals');
    }
    // To navigate to Manage Buy Book
    //checks if the menu selected is Manage Buy Book
    if (this.selectedMenu == 'managebuybook') {
      document.title = 'Manage Buy Book';
      this.isManageBuyBook = true;
      this.isHome = false;
      this.isAddressBook = false;
      this.isManageBrand = false;
      this.isManageItemType = false;
      this.isManagePosItem = false;
      this.isManageTerrioties = false;
      this.isManageShippingMethods = false;
      this.isManageASN = false;
      this.isManageApproval = false;
      this.isManageDesignation = false;
      this.isAssignDesignation = false;
      this.isManageChairUser = false;
      this.isManageBuyBookBudget = false;
      this.isManagePlaybook = false;
      this.isOpenBuyBookList = false;
      this.isBuyBookPOSItemToCart=false
      this.isBuyBookShoppingCart=false;
      this.isPreviewOrder=false;
      this.isEditOrder=false;
      this.isTrackingNumber=false;
      this.isOrderStatus=false;
      window.history.pushState("", 'Manage Buy Book', this.accountURL + '/s/' + 'managebuybook');
    }
    // To navigate to Manage Designation
    //checks if the menu selected is Manage Designation
    if (this.selectedMenu == 'managedesignation') {
      document.title = 'Manage Designation';
      this.isManageDesignation = true;
      this.isHome = false;
      this.isAddressBook = false;
      this.isManageBrand = false;
      this.isManageItemType = false;
      this.isManagePosItem = false;
      this.isManageTerrioties = false;
      this.isManageShippingMethods = false;
      this.isManageASN = false;
      this.isManageApproval = false;
      this.isManageBuyBook = false;
      this.isAssignDesignation = false;
      this.isManageChairUser = false;
      this.isManageBuyBookBudget = false;
      this.isManagePlaybook = false;
      this.isOpenBuyBookList = false;
      this.isBuyBookPOSItemToCart=false
      this.isBuyBookShoppingCart=false;
      this.isPreviewOrder=false;
      this.isEditOrder=false;
      this.isTrackingNumber=false;
      this.isOrderStatus=false;
      window.history.pushState("", 'Manage Designation', this.accountURL + '/s/' + 'managedesignation');
    }

    // To navigate to Manage Designation
    //checks if the menu selected is Manage Designation
    if (this.selectedMenu == 'assigndesignation') {
      document.title = 'Assign Designation';
      this.isAssignDesignation = true;
      this.isHome = false;
      this.isAddressBook = false;
      this.isManageBrand = false;
      this.isManageItemType = false;
      this.isManagePosItem = false;
      this.isManageTerrioties = false;
      this.isManageShippingMethods = false;
      this.isManageASN = false;
      this.isManageApproval = false;
      this.isManageBuyBook = false;
      this.isManageDesignation = false;
      this.isManageChairUser = false;
      this.isManageBuyBookBudget = false;
      this.isManagePlaybook = false;
      this.isOpenBuyBookList = false;
      this.isBuyBookPOSItemToCart=false
      this.isBuyBookShoppingCart=false;
      this.isPreviewOrder=false;
      this.isEditOrder=false;
      this.isTrackingNumber=false;
      this.isOrderStatus=false;
      window.history.pushState("", 'Assign Designation', this.accountURL + '/s/' + 'assigndesignation');
    }


    // To navigate to Manage Chair User
    //checks if the menu selected is Manage Chair User
    if (this.selectedMenu == 'managechairuser') {
      document.title = 'Manage Chair User';
      this.isManageChairUser = true
      this.isHome = false;
      this.isAddressBook = false;
      this.isManageBrand = false;
      this.isManageItemType = false;
      this.isManagePosItem = false;
      this.isManageTerrioties = false;
      this.isManageShippingMethods = false;
      this.isManageASN = false;
      this.isManageApproval = false;
      this.isManageBuyBook = false;
      this.isManageDesignation = false;
      this.isAssignDesignation = false;
      this.isManageBuyBookBudget = false;
      this.isManagePlaybook = false;
      this.isOpenBuyBookList = false;
      this.isBuyBookPOSItemToCart=false
      this.isBuyBookShoppingCart=false;
      this.isPreviewOrder=false;
      this.isEditOrder=false;
      this.isTrackingNumber=false;
      this.isOrderStatus=false;
      window.history.pushState("", 'Manage Chair User', this.accountURL + '/s/' + 'managechairuser');
    }
    // To navigate to Manage Buy Book
    //checks if the menu selected is Manage Buy Book
    if (this.selectedMenu == 'managebuybookbudget') {
      document.title = 'Manage Buy Book Budget';
      this.isManageBuyBookBudget = true;
      this.isHome = false;
      this.isAddressBook = false;
      this.isManageBrand = false;
      this.isManageItemType = false;
      this.isManagePosItem = false;
      this.isManageTerrioties = false;
      this.isManageShippingMethods = false;
      this.isManageASN = false;
      this.isManageApproval = false;
      this.isManageBuyBook = false;
      this.isManageDesignation = false;
      this.isAssignDesignation = false;
      this.isManageChairUser = false;
      this.isManagePlaybook = false;
      this.isOpenBuyBookList = false;
      this.isBuyBookPOSItemToCart=false
      this.isBuyBookShoppingCart=false;
      this.isPreviewOrder=false;
      this.isEditOrder=false;
      this.isTrackingNumber=false;
      this.isOrderStatus=false;
      window.history.pushState("", 'Manage Buy Book Budget', this.accountURL + '/s/' + 'managebuybookbudget');
    }

    // To navigate to Manage Playbook
    //checks if the menu selected is Manage Playbook
    if (this.selectedMenu == 'manageplaybook') {
      document.title = 'Manage Playbook';
      this.isManagePlaybook = true;
      this.isHome = false;
      this.isAddressBook = false;
      this.isManageBrand = false;
      this.isManageItemType = false;
      this.isManagePosItem = false;
      this.isManageTerrioties = false;
      this.isManageShippingMethods = false;
      this.isManageASN = false;
      this.isManageApproval = false;
      this.isManageBuyBook = false;
      this.isManageDesignation = false;
      this.isAssignDesignation = false;
      this.isManageChairUser = false;
      this.isManageBuyBookBudget = false;
      this.isOpenBuyBookList = false;
      this.isBuyBookPOSItemToCart=false
      this.isBuyBookShoppingCart=false;
      this.isPreviewOrder=false;
      this.isEditOrder=false;
      this.isTrackingNumber=false;
      this.isOrderStatus=false;
      window.history.pushState("", 'Manage Playbook', this.accountURL + '/s/' + 'manageplaybook');
    }

    // To navigate to Open Buy Book List
    //checks if the menu selected is Open Buy Book List
    if (this.selectedMenu == 'manageopenbuybook') {
      this.isOpenBuyBookList = true;
      this.isHome = false;
      this.isAddressBook = false;
      this.isManageBrand = false;
      this.isManageItemType = false;
      this.isManagePosItem = false;
      this.isManageTerrioties = false;
      this.isManageShippingMethods = false;
      this.isManageASN = false;
      this.isManageApproval = false;
      this.isManageBuyBook = false;
      this.isManageDesignation = false;
      this.isAssignDesignation = false;
      this.isManageChairUser = false;
      this.isManageBuyBookBudget = false;
      this.isManagePlaybook = false;
      this.isBuyBookPOSItemToCart=false
      this.isBuyBookShoppingCart=false;
      this.isPreviewOrder=false;
      this.isEditOrder=false;
      this.isTrackingNumber=false;
      this.isOrderStatus=false;
      window.history.pushState("", 'Place Orders', this.accountURL + '/s/' + 'manageopenbuybook');
    }
    // To navigate to Place order in seasonal order
    //checks if the menu selected is place order in seasonal order
    if (this.selectedMenu == 'positemtocart') {
      document.title = 'Place Orders';
      this.isBuyBookPOSItemToCart = true;
      this.isHome = false;
      this.isAddressBook = false;
      this.isManageBrand = false;
      this.isManageItemType = false;
      this.isManagePosItem = false;
      this.isManageTerrioties = false;
      this.isManageShippingMethods = false;
      this.isManageASN = false;
      this.isManageApproval = false;
      this.isManageBuyBook = false;
      this.isManageDesignation = false;
      this.isAssignDesignation = false;
      this.isManageChairUser = false;
      this.isManageBuyBookBudget = false;
      this.isManagePlaybook = false;
      this.isOpenBuyBookList = false;
      this.isBuyBookShoppingCart=false;
      this.isPreviewOrder=false;
      this.isEditOrder=false;
      this.isTrackingNumber=false;
      this.isOrderStatus=false;
      window.history.pushState("", 'Place Orders', this.accountURL + '/s/' + 'positemtocart');
    }
    // To navigate to shopping cart in seasonal order
    //checks if the menu selected is shopping cart in seasonal order
    if (this.selectedMenu == 'shoppingcart') {
      document.title = 'Shopping Cart';
      this.isBuyBookShoppingCart = true;
      this.isHome = false;
      this.isAddressBook = false;
      this.isManageBrand = false;
      this.isManageItemType = false;
      this.isManagePosItem = false;
      this.isManageTerrioties = false;
      this.isManageShippingMethods = false;
      this.isManageASN = false;
      this.isManageApproval = false;
      this.isManageBuyBook = false;
      this.isManageDesignation = false;
      this.isAssignDesignation = false;
      this.isManageChairUser = false;
      this.isManageBuyBookBudget = false;
      this.isManagePlaybook = false;
      this.isOpenBuyBookList = false;
      this.isBuyBookPOSItemToCart=false;
      this.isPreviewOrder=false;
      this.isEditOrder=false;
      this.isTrackingNumber=false;
      this.isOrderStatus=false;
      window.history.pushState("", 'Shopping Cart', this.accountURL + '/s/' + 'shoppingcart');
    }

    // To navigate to Preview Order  page
    if (this.selectedMenu == 'previeworder') {
    document.title = 'Preview Order';
    this.isPreviewOrder=true;
    this.isHome = false;
    this.isAddressBook = false;
    this.isManageBrand = false;
    this.isManageItemType = false;
    this.isManagePosItem = false;
    this.isManageTerrioties = false;
    this.isManageShippingMethods = false;
    this.isManageASN = false;
    this.isManageApproval = false;
    this.isManageBuyBook = false;
    this.isManageDesignation = false;
    this.isAssignDesignation = false;
    this.isManageChairUser = false;
    this.isManageBuyBookBudget = false;
    this.isManagePlaybook = false;
    this.isOpenBuyBookList=false;
    this.isBuyBookPOSItemToCart = false;
    this.isBuyBookShoppingCart = false;
    this.isEditOrder=false;
    this.isTrackingNumber=false;
    this.isOrderStatus=false;
    window.history.pushState("", 'Preview Order', this.accountURL + '/s/' + 'previeworder');
  }

  // To navigate to Edit Order  page
  if (this.selectedMenu == 'editorder') {
    document.title = 'Edit Order';
    this.isEditOrder=true;
    this.isHome = false;
    this.isAddressBook = false;
    this.isManageBrand = false;
    this.isManageItemType = false;
    this.isManagePosItem = false;
    this.isManageTerrioties = false;
    this.isManageShippingMethods = false;
    this.isManageASN = false;
    this.isManageApproval = false;
    this.isManageBuyBook = false;
    this.isManageDesignation = false;
    this.isAssignDesignation = false;
    this.isManageChairUser = false;
    this.isManageBuyBookBudget = false;
    this.isManagePlaybook = false;
    this.isOpenBuyBookList=false;
    this.isBuyBookPOSItemToCart = false;
    this.isBuyBookShoppingCart = false;
    this.isPreviewOrder=false;
    this.isOrderStatus=false;
    this.isTrackingNumber=false;
    window.history.pushState("", 'Edit Order', this.accountURL + '/s/' + 'editorder');
  }
    // To navigate to Tracking Number  page
    if (this.selectedMenu == 'trackingnumber') {
      document.title = 'Tracking Number';
      this.isTrackingNumber=true;
      this.isHome = false;
      this.isAddressBook = false;
      this.isManageBrand = false;
      this.isManageItemType = false;
      this.isManagePosItem = false;
      this.isManageTerrioties = false;
      this.isManageShippingMethods = false;
      this.isManageASN = false;
      this.isManageApproval = false;
      this.isManageBuyBook = false;
      this.isManageDesignation = false;
      this.isAssignDesignation = false;
      this.isManageChairUser = false;
      this.isManageBuyBookBudget = false;
      this.isManagePlaybook = false;
      this.isOpenBuyBookList=false;
      this.isBuyBookPOSItemToCart = false;
      this.isBuyBookShoppingCart = false;
      this.isPreviewOrder=false;
      this.isOrderStatus=false;
      this.isEditOrder=false;
      window.history.pushState("", 'Tracking Number', this.accountURL + '/s/' + 'trackingnumber');
    }
    // To log out from the application
    if (this.selectedMenu == 'logout') {
      window.location.replace(this.accountURL + "/secur/logout.jsp");
    }

    //the report navigation
    if (this.selectedMenu == 'report') {
      this.isHome = false;
      this.isAddressBook = false;
      this.isManageBrand = false;
      this.isManageItemType = false;
      this.isManagePosItem = false;
      this.isManageTerrioties = false;
      this.isManageShippingMethods = false;
      this.isManageASN = false;
      this.isManageApproval = false;
      this.isManageBuyBook = false;
      this.isManageDesignation = false;
      this.isAssignDesignation = false;
      this.isManageChairUser = false;
      this.isManageBuyBookBudget = false;
      this.isManagePlaybook = false;
      this.isOpenBuyBookList=false;
      this.isBuyBookPOSItemToCart = false;
      this.isBuyBookShoppingCart = false;
      this.isPreviewOrder=false;
      this.isEditOrder=false;
      this.isTrackingNumber=false;
      this.isOrderStatus=false;
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
  this.isOrderStatus=true;
  this.isHome = false;
  this.isAddressBook = false;
  this.isManageBrand = false;
  this.isManageItemType = false;
  this.isManagePosItem = false;
  this.isManageTerrioties = false;
  this.isManageShippingMethods = false;
  this.isManageASN = false;
  this.isManageApproval = false;
  this.isManageBuyBook = false;
  this.isManageDesignation = false;
  this.isAssignDesignation = false;
  this.isManageChairUser = false;
  this.isManageBuyBookBudget = false;
  this.isManagePlaybook = false;
  this.isOpenBuyBookList=false;
  this.isBuyBookPOSItemToCart = false;
  this.isBuyBookShoppingCart = false;
  this.isPreviewOrder=false;
  this.isEditOrder=false;
  this.isTrackingNumber=false;
  window.history.pushState("", 'Order Status', this.accountURL + '/s/' + 'manageorderstatus');
}
  // To log out from the application
  if (this.selectedMenu == 'logout') {
    window.location.replace(this.accountURL + "/secur/logout.jsp");
  }


  }
}