// Author : Sanjana; Date : 20-09-2021

import {LightningElement,api,track,wire} from 'lwc';
//to hold the account url
import getAccount_Apex from '@salesforce/apex/InfiniumManageBrandList_Apex.getAccount';
//pub sub model
import pubsub from 'c/pubsub';
//to navigate to the report page
import {NavigationMixin} from 'lightning/navigation';

export default class InfiniumAdminContentComponent extends NavigationMixin(LightningElement) {
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
  //to check if the selected menu is Manage program
  @track isManageprograms = false;
  //to check if the selected menu is Manage Designation
  @track isManageDesignation = false;
  //to check if the selected menu is Assign Designation
  @track isAssignDesignation = false;
  //to check if the selected menu is Manage Chair User
  @track isManageChairUser = false;
  //to check if the selected menu is Manage program Budget
  @track isManageprogramsBudget = false;
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
   //to check if the selected menu is inventory preview order
   @track isInventoryPreviewOrder = false;
  //to check if the selected menu is preview order
  @track isEditOrder = false;
  //to hold order id for preview
  @api orderId;
  //to check if the selected menu is order status
  @api isOrderStatus;
  //to check if the selected menu is inventory order status
  @api isInventoryOrderStatus =false;
  //to check if the selected menu is pos item in place order flow
   @track isPosItemMenuPage = false;
   //to check if the selected menu is inventory shopping cart
   @track isInventoryShoppingCart = false;
  //  to hold inventory order Id
  @track inventoryOrderId;
  //to check if the selected menu is pos catalog
  @track isPosCatalog=false;
  // to check if the selected menu is manage ordered items
  @track isManageOrderedItems = false;
  // to check if the selected menu is send wave orders
  @track isManageSendWaveOrders = false;
  

  @wire(getAccount_Apex) accountDetails;
  get accountDetailsForInfiniumSpirits() {
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
    //To hold the inventory shopping cart
    pubsub.register('inventoryshoppingcartevent', this.handleEvent.bind(this));
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
    //To hold the Manage progrNm
    pubsub.register('manageprogramevent', this.handleEvent.bind(this));
    //To hold the Manage Designation
    pubsub.register('managedesignationevent', this.handleEvent.bind(this));
    //To hold the Assign Designation
    pubsub.register('assigndesignationevent', this.handleEvent.bind(this));
    //To hold the Manage chair user
    pubsub.register('managechairuserevent', this.handleEvent.bind(this));
    //To hold the Manage program  Budget
    pubsub.register('manageprogrambudgetevent', this.handleEvent.bind(this));
    //To hold the Manage playbook
    pubsub.register('manageplaybookevent', this.handleEvent.bind(this));
    //To hold the Open program   List
    pubsub.register('manageopenprogramevent', this.handleEvent.bind(this));
    //To hold the program  item to cart
    pubsub.register('managepositemtocartevent', this.handleEvent.bind(this));
    //To hold the shopping cart details for the selected program
    pubsub.register('shoppingcartevent', this.handleEvent.bind(this));
    //To hold the preview order details for the selected program
    pubsub.register('previeworderevent', this.handleEvent.bind(this));
    //To hold the preview order details for the selected program
    pubsub.register('inventoryprevieworderevent', this.handleEvent.bind(this));
    //To hold the preview order details for the selected program
    pubsub.register('editorderevent', this.handleEvent.bind(this));
    //To hold the seasonal order id
    pubsub.register('previeworderId', this.handleOrderId.bind(this));
    //To hold the inventory order id
    pubsub.register('inventoryprevieworderId', this.handleInventoryOrderId.bind(this));
    //To hold the program  id for the seasonal order 
    pubsub.register('selectedprogramdetailevent', this.handleSelectedProgramDetail.bind(this));
    //To hold the order status
    pubsub.register('manageorderstatusevent', this.handleEvent.bind(this));
    //To hold the order status
    pubsub.register('manageinventoryorderstatusevent', this.handleEvent.bind(this));
    //to handle program  id
    pubsub.register('selectedProgramDetails', this.handleSelectedProgramDetailFromOrderStatus.bind(this));
    //to handle pos catalog
    pubsub.register('poscatalogevent', this.handleEvent.bind(this));
    // to hold manage approvals
    pubsub.register('manageapprovalevent', this.handleEvent.bind(this));
    // to hold manage ordered items
    pubsub.register('manageordereditemsevent', this.handleEvent.bind(this));
    // to hold manage send wave orders
    pubsub.register('managesendwaveordersevent', this.handleEvent.bind(this));

  }
  
  handleOrderId(value) {
    this.orderId = value;
  }

  handleInventoryOrderId(value){
    this.inventoryOrderId = value;
  }

  handleSelectedProgramDetailFromOrderStatus(value){
       this.selectedProgramDetail = value;
       this.selectedProgramId  =  this.selectedProgramDetail.Program__r.Id;

  }


  handleSelectedProgramDetail(value) {
    this.selectedProgramDetail = value;
    this.selectedProgramId = this.selectedProgramDetail.Program__c
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
      this.isManageprograms = false;
      this.isManageDesignation = false;
      this.isAssignDesignation = false;
      this.isManageChairUser = false;
      this.isManageprogramsBudget = false;
      this.isManagePlaybook = false;
      this.isOpenProgramList = false;
      this.isProgramPOSItemToCart=false
      this.isProgramShoppingCart=false;
      this.isPreviewOrder=false;
      this.isEditOrder=false;
      this.isOrderStatus=false;
      this.isPosItemMenuPage = false;
      this.isInventoryShoppingCart = false;
      this.isInventoryPreviewOrder = false;
      this.isInventoryOrderStatus=false;
      this.isPosCatalog = false;
      this.isManageApproval = false;
      this.isManageOrderedItems=false;
      this.isManageSendWaveOrders = false;
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
      this.isManageprograms = false;
      this.isManageDesignation = false;
      this.isAssignDesignation = false;
      this.isManageChairUser = false;
      this.isManageprogramsBudget = false;
      this.isManagePlaybook = false;
      this.isOpenProgramList = false;
      this.isProgramPOSItemToCart=false
      this.isProgramShoppingCart=false;
      this.isPreviewOrder=false;
      this.isEditOrder=false;
      this.isOrderStatus=false;
      this.isPosItemMenuPage = false;
      this.isInventoryShoppingCart = false;
      this.isInventoryPreviewOrder = false;
      this.isInventoryOrderStatus=false;
      this.isPosCatalog = false;
      this.isManageApproval = false;
      this.isManageOrderedItems=false;
      this.isManageSendWaveOrders = false;
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
      this.isManageprograms = false;
      this.isManageDesignation = false;
      this.isAssignDesignation = false;
      this.isManageChairUser = false;
      this.isManageprogramsBudget = false;
      this.isManagePlaybook = false;
      this.isOpenProgramList = false;
      this.isProgramPOSItemToCart=false
      this.isProgramShoppingCart=false;
      this.isPreviewOrder=false;
      this.isEditOrder=false;
      this.isOrderStatus=false;
      this.isPosItemMenuPage = false;
      this.isInventoryShoppingCart = false;
      this.isInventoryPreviewOrder = false;
      this.isInventoryOrderStatus=false;
      this.isPosCatalog = false;
      this.isManageApproval = false;
      this.isManageOrderedItems=false;
      this.isManageSendWaveOrders = false;
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
      this.isManageprograms = false;
      this.isManageDesignation = false;
      this.isAssignDesignation = false;
      this.isManageChairUser = false;
      this.isManageprogramsBudget = false;
      this.isManagePlaybook = false;
      this.isOpenProgramList = false;
      this.isProgramPOSItemToCart=false
      this.isProgramShoppingCart=false;
      this.isPreviewOrder=false;
      this.isEditOrder=false;
      this.isOrderStatus=false;
      this.isPosItemMenuPage = false;
      this.isInventoryShoppingCart = false;
      this.isInventoryPreviewOrder = false;
      this.isInventoryOrderStatus=false;
      this.isPosCatalog = false;
      this.isManageApproval = false;
      this.isManageOrderedItems=false;
      this.isManageSendWaveOrders = false;
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
      this.isManageprograms = false;
      this.isManageDesignation = false;
      this.isAssignDesignation = false;
      this.isManageChairUser = false;
      this.isManageprogramsBudget = false;
      this.isManagePlaybook = false;
      this.isOpenProgramList = false;
      this.isProgramPOSItemToCart=false
      this.isProgramShoppingCart=false;
      this.isPreviewOrder=false;
      this.isEditOrder=false;
      this.isOrderStatus=false;
      this.isPosItemMenuPage = false;
      this.isInventoryShoppingCart = false;
      this.isInventoryPreviewOrder = false;
      this.isInventoryOrderStatus=false;
      this.isPosCatalog = false;
      this.isManageApproval = false;
      this.isManageOrderedItems=false;
      this.isManageSendWaveOrders = false;
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
      this.isManageprograms = false;
      this.isManageDesignation = false;
      this.isAssignDesignation = false;
      this.isManageChairUser = false;
      this.isManageprogramsBudget = false;
      this.isManagePlaybook = false;
      this.isOpenProgramList = false;
      this.isProgramPOSItemToCart=false
      this.isProgramShoppingCart=false;
      this.isPreviewOrder=false;
      this.isEditOrder=false;
      this.isOrderStatus=false;
      this.isPosItemMenuPage = false;
      this.isInventoryShoppingCart = false;
      this.isInventoryPreviewOrder = false;
      this.isInventoryOrderStatus=false;
      this.isPosCatalog = false;
      this.isManageApproval = false;
      this.isManageOrderedItems=false;
      this.isManageSendWaveOrders = false;
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
      this.isManageprograms = false;
      this.isManageDesignation = false;
      this.isAssignDesignation = false;
      this.isManageChairUser = false;
      this.isManageprogramsBudget = false;
      this.isManagePlaybook = false;
      this.isOpenProgramList = false;
      this.isProgramPOSItemToCart=false
      this.isProgramShoppingCart=false;
      this.isPreviewOrder=false;
      this.isEditOrder=false;
      this.isOrderStatus=false;
      this.isPosItemMenuPage = false;
      this.isInventoryShoppingCart = false;
      this.isInventoryPreviewOrder = false;
      this.isInventoryOrderStatus=false;
      this.isPosCatalog = false;
      this.isManageApproval = false;
      this.isManageOrderedItems=false;
      this.isManageSendWaveOrders = false;
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
      this.isManageprograms = false;
      this.isManageDesignation = false;
      this.isAssignDesignation = false;
      this.isManageChairUser = false;
      this.isManageprogramsBudget = false;
      this.isManagePlaybook = false;
      this.isOpenProgramList = false;
      this.isProgramPOSItemToCart=false
      this.isProgramShoppingCart=false;
      this.isPreviewOrder=false;
      this.isEditOrder=false;
      this.isOrderStatus=false;
      this.isPosItemMenuPage = false;
      this.isInventoryShoppingCart = false;
      this.isInventoryPreviewOrder = false;
      this.isInventoryOrderStatus=false;
      this.isPosCatalog = false;
      this.isManageApproval = false;
      this.isManageOrderedItems=false;
      this.isManageSendWaveOrders = false;
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
      this.isManageprograms = false;
      this.isManageDesignation = false;
      this.isAssignDesignation = false;
      this.isManageChairUser = false;
      this.isManageprogramsBudget = false;
      this.isManagePlaybook = false;
      this.isOpenProgramList = false;
      this.isProgramPOSItemToCart=false
      this.isProgramShoppingCart=false;
      this.isPreviewOrder=false;
      this.isEditOrder=false;
      this.isOrderStatus=false;
      this.isPosItemMenuPage = false;
      this.isInventoryShoppingCart = false;
      this.isInventoryPreviewOrder = false;
      this.isInventoryOrderStatus=false;
      this.isPosCatalog = false;
      this.isManageOrderedItems=false;
      this.isManageSendWaveOrders = false;
      window.history.pushState("", 'Manage Approvals', this.accountURL + '/s/' + 'manageapprovals');
    }
    // To navigate to Manage Program
    //checks if the menu selected is Manage Program
    if (this.selectedMenu == 'manageprogram') {
      document.title = 'Manage Program';
      this.isManageprograms = true;
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
      this.isManageprogramsBudget = false;
      this.isManagePlaybook = false;
      this.isOpenProgramList = false;
      this.isProgramPOSItemToCart=false
      this.isProgramShoppingCart=false;
      this.isPreviewOrder=false;
      this.isEditOrder=false;
      this.isOrderStatus=false;
      this.isPosItemMenuPage = false;
      this.isInventoryShoppingCart = false;
      this.isInventoryPreviewOrder = false;
      this.isInventoryOrderStatus=false;
      this.isPosCatalog = false;
      this.isManageApproval = false;
      this.isManageOrderedItems=false;
      this.isManageSendWaveOrders = false;
      window.history.pushState("", 'Manage Program', this.accountURL + '/s/' + 'manageprogram');
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
      this.isManageprograms = false;
      this.isAssignDesignation = false;
      this.isManageChairUser = false;
      this.isManageprogramsBudget = false;
      this.isManagePlaybook = false;
      this.isOpenProgramList = false;
      this.isProgramPOSItemToCart=false
      this.isProgramShoppingCart=false;
      this.isPreviewOrder=false;
      this.isEditOrder=false;
      this.isOrderStatus=false;
      this.isPosItemMenuPage = false;
      this.isInventoryShoppingCart = false;
      this.isInventoryPreviewOrder = false;
      this.isInventoryOrderStatus=false;
      this.isPosCatalog = false;
      this.isManageApproval = false;
      this.isManageOrderedItems=false;
      this.isManageSendWaveOrders = false;
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
      this.isManageprograms = false;
      this.isManageDesignation = false;
      this.isManageChairUser = false;
      this.isManageprogramsBudget = false;
      this.isManagePlaybook = false;
      this.isOpenProgramList = false;
      this.isProgramPOSItemToCart=false
      this.isProgramShoppingCart=false;
      this.isPreviewOrder=false;
      this.isEditOrder=false;
      this.isOrderStatus=false;
      this.isPosItemMenuPage = false;
      this.isInventoryShoppingCart = false;
      this.isInventoryPreviewOrder = false;
      this.isInventoryOrderStatus=false;
      this.isPosCatalog = false;
      this.isManageApproval = false;
      this.isManageOrderedItems=false;
      this.isManageSendWaveOrders = false;
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
      this.isManageprograms = false;
      this.isManageDesignation = false;
      this.isAssignDesignation = false;
      this.isManageprogramsBudget = false;
      this.isManagePlaybook = false;
      this.isOpenProgramList = false;
      this.isProgramPOSItemToCart=false
      this.isProgramShoppingCart=false;
      this.isPreviewOrder=false;
      this.isEditOrder=false;
      this.isOrderStatus=false;
      this.isPosItemMenuPage = false;
      this.isInventoryShoppingCart = false;
      this.isInventoryPreviewOrder = false;
      this.isInventoryOrderStatus=false;
      this.isPosCatalog = false;
      this.isManageApproval = false;
      this.isManageOrderedItems=false;
      this.isManageSendWaveOrders = false;
      window.history.pushState("", 'Manage Chair User', this.accountURL + '/s/' + 'managechairuser');
    }
    // To navigate to Manage Program budget
    //checks if the menu selected is Manage Program budget
    if (this.selectedMenu == 'manageprogrambudget') {
      document.title = 'Manage Program Budget';
      this.isManageprogramsBudget = true;
      this.isHome = false;
      this.isAddressBook = false;
      this.isManageBrand = false;
      this.isManageItemType = false;
      this.isManagePosItem = false;
      this.isManageTerrioties = false;
      this.isManageShippingMethods = false;
      this.isManageASN = false;
      this.isManageApproval = false;
      this.isManageprograms = false;
      this.isManageDesignation = false;
      this.isAssignDesignation = false;
      this.isManageChairUser = false;
      this.isManagePlaybook = false;
      this.isOpenProgramList = false;
      this.isProgramPOSItemToCart=false
      this.isProgramShoppingCart=false;
      this.isPreviewOrder=false;
      this.isEditOrder=false;
      this.isOrderStatus=false;
      this.isPosItemMenuPage = false;
      this.isInventoryShoppingCart = false;
      this.isInventoryPreviewOrder = false;
      this.isInventoryOrderStatus=false;
      this.isPosCatalog = false;
      this.isManageApproval = false;
      this.isManageOrderedItems=false;
      this.isManageSendWaveOrders = false;
      window.history.pushState("", 'Manage Program Budget', this.accountURL + '/s/' + 'manageprogrambudget');
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
      this.isManageprograms = false;
      this.isManageDesignation = false;
      this.isAssignDesignation = false;
      this.isManageChairUser = false;
      this.isManageprogramsBudget = false;
      this.isOpenProgramList = false;
      this.isProgramPOSItemToCart=false
      this.isProgramShoppingCart=false;
      this.isPreviewOrder=false;
      this.isEditOrder=false;
      this.isOrderStatus=false;
      this.isPosItemMenuPage = false;
      this.isInventoryShoppingCart = false;
      this.isInventoryPreviewOrder = false;
      this.isInventoryOrderStatus=false;
      this.isPosCatalog = false;
      this.isManageApproval = false;
      this.isManageOrderedItems=false;
      this.isManageSendWaveOrders = false;
      window.history.pushState("", 'Manage Playbook', this.accountURL + '/s/' + 'manageplaybook');
    }

    // To navigate to Open Program List
    //checks if the menu selected is Open Program List
    if (this.selectedMenu == 'manageopenprogram') {
      this.isOpenProgramList = true;
      this.isHome = false;
      this.isAddressBook = false;
      this.isManageBrand = false;
      this.isManageItemType = false;
      this.isManagePosItem = false;
      this.isManageTerrioties = false;
      this.isManageShippingMethods = false;
      this.isManageASN = false;
      this.isManageApproval = false;
      this.isManageprograms = false;
      this.isManageDesignation = false;
      this.isAssignDesignation = false;
      this.isManageChairUser = false;
      this.isManageprogramsBudget = false;
      this.isManagePlaybook = false;
      this.isProgramPOSItemToCart=false
      this.isProgramShoppingCart=false;
      this.isPreviewOrder=false;
      this.isEditOrder=false;
      this.isOrderStatus=false;
      this.isPosItemMenuPage = false;
      this.isInventoryShoppingCart = false;
      this.isInventoryPreviewOrder = false;
      this.isInventoryOrderStatus=false;
      this.isPosCatalog = false;
      this.isManageApproval = false;
      this.isManageOrderedItems=false;
      this.isManageSendWaveOrders = false;
      window.history.pushState("", 'Place Orders', this.accountURL + '/s/' + 'manageopenprogram');
    }
    // To navigate to Place order in seasonal order
    //checks if the menu selected is place order in seasonal order
    if (this.selectedMenu == 'positemtocart') {
      document.title = 'Place Orders';
      this.isProgramPOSItemToCart = true;
      this.isHome = false;
      this.isAddressBook = false;
      this.isManageBrand = false;
      this.isManageItemType = false;
      this.isManagePosItem = false;
      this.isManageTerrioties = false;
      this.isManageShippingMethods = false;
      this.isManageASN = false;
      this.isManageApproval = false;
      this.isManageprograms = false;
      this.isManageDesignation = false;
      this.isAssignDesignation = false;
      this.isManageChairUser = false;
      this.isManageprogramsBudget = false;
      this.isManagePlaybook = false;
      this.isOpenProgramList = false;
      this.isProgramShoppingCart=false;
      this.isPreviewOrder=false;
      this.isEditOrder=false;
      this.isOrderStatus=false;
      this.isPosItemMenuPage = false;
      this.isInventoryShoppingCart = false;
      this.isInventoryPreviewOrder = false;
      this.isInventoryOrderStatus=false;
      this.isPosCatalog = false;
      this.isManageApproval = false;
      this.isManageOrderedItems=false;
      this.isManageSendWaveOrders = false;
      window.history.pushState("", 'Place Orders', this.accountURL + '/s/' + 'positemtocart');
    }
    // To navigate to shopping cart in seasonal order
    //checks if the menu selected is shopping cart in seasonal order
    if (this.selectedMenu == 'shoppingcart') {
      document.title = 'Shopping Cart';
      this.isProgramShoppingCart = true;
      this.isHome = false;
      this.isAddressBook = false;
      this.isManageBrand = false;
      this.isManageItemType = false;
      this.isManagePosItem = false;
      this.isManageTerrioties = false;
      this.isManageShippingMethods = false;
      this.isManageASN = false;
      this.isManageApproval = false;
      this.isManageprograms = false;
      this.isManageDesignation = false;
      this.isAssignDesignation = false;
      this.isManageChairUser = false;
      this.isManageprogramsBudget = false;
      this.isManagePlaybook = false;
      this.isOpenProgramList = false;
      this.isProgramPOSItemToCart=false;
      this.isPreviewOrder=false;
      this.isEditOrder=false;
      this.isOrderStatus=false;
      this.isPosItemMenuPage = false;
      this.isInventoryShoppingCart = false;
      this.isInventoryPreviewOrder = false;
      this.isInventoryOrderStatus=false;
      this.isPosCatalog = false;
      this.isManageApproval = false;
      this.isManageOrderedItems=false;
      this.isManageSendWaveOrders = false;
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
    this.isManageprograms = false;
    this.isManageDesignation = false;
    this.isAssignDesignation = false;
    this.isManageChairUser = false;
    this.isManageprogramsBudget = false;
    this.isManagePlaybook = false;
    this.isOpenProgramList=false;
    this.isProgramPOSItemToCart = false;
    this.isProgramShoppingCart = false;
    this.isEditOrder=false;
    this.isOrderStatus=false;
    this.isPosItemMenuPage = false;
    this.isInventoryShoppingCart = false;
    this.isInventoryPreviewOrder = false;
    this.isInventoryOrderStatus=false;
    this.isPosCatalog = false;
    this.isManageApproval = false;
    this.isManageOrderedItems=false;
    this.isManageSendWaveOrders = false;
    window.history.pushState("", 'Preview Order', this.accountURL + '/s/' + 'previeworder');
  }

   // To navigate to Inventory Preview Order  page
   if (this.selectedMenu == 'inventoryprevieworder') {
    document.title = 'Inventory Preview Order';
    this.isInventoryPreviewOrder = true;
    this.isPreviewOrder=false;
    this.isHome = false;
    this.isAddressBook = false;
    this.isManageBrand = false;
    this.isManageItemType = false;
    this.isManagePosItem = false;
    this.isManageTerrioties = false;
    this.isManageShippingMethods = false;
    this.isManageASN = false;
    this.isManageApproval = false;
    this.isManageprograms = false;
    this.isManageDesignation = false;
    this.isAssignDesignation = false;
    this.isManageChairUser = false;
    this.isManageprogramsBudget = false;
    this.isManagePlaybook = false;
    this.isOpenProgramList=false;
    this.isProgramPOSItemToCart = false;
    this.isProgramShoppingCart = false;
    this.isEditOrder=false;
    this.isOrderStatus=false;
    this.isPosItemMenuPage = false;
    this.isInventoryShoppingCart = false;
    this.isInventoryOrderStatus=false;
    this.isPosCatalog = false;
    this.isManageApproval = false;
    this.isManageOrderedItems=false;
    this.isManageSendWaveOrders = false;
    window.history.pushState("", 'Inventory Preview Order', this.accountURL + '/s/' + 'inventoryprevieworder');
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
    this.isManageprograms = false;
    this.isManageDesignation = false;
    this.isAssignDesignation = false;
    this.isManageChairUser = false;
    this.isManageprogramsBudget = false;
    this.isManagePlaybook = false;
    this.isOpenProgramList=false;
    this.isProgramPOSItemToCart = false;
    this.isProgramShoppingCart = false;
    this.isPreviewOrder=false;
    this.isOrderStatus=false;
    this.isPosItemMenuPage = false;
    this.isInventoryShoppingCart = false;
    this.isInventoryPreviewOrder = false;
    this.isInventoryOrderStatus=false;
    this.isPosCatalog = false;
    this.isManageApproval = false;
    this.isManageOrderedItems=false;
    this.isManageSendWaveOrders = false;
    window.history.pushState("", 'Edit Order', this.accountURL + '/s/' + 'editorder');
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
      this.isManageprograms = false;
      this.isManageDesignation = false;
      this.isAssignDesignation = false;
      this.isManageChairUser = false;
      this.isManageprogramsBudget = false;
      this.isManagePlaybook = false;
      this.isOpenProgramList=false;
      this.isProgramPOSItemToCart = false;
      this.isProgramShoppingCart = false;
      this.isPreviewOrder=false;
      this.isEditOrder=false;
      this.isOrderStatus=false;
      this.isPosItemMenuPage = false;
      this.isInventoryPreviewOrder = false;
      this.isInventoryShoppingCart = false;
      this.isInventoryOrderStatus=false;
      this.isPosCatalog = false;
      this.isManageApproval = false;
      this.isManageOrderedItems=false;
      this.isManageSendWaveOrders = false;
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
  this.isManageprograms = false;
  this.isManageDesignation = false;
  this.isAssignDesignation = false;
  this.isManageChairUser = false;
  this.isManageprogramsBudget = false;
  this.isManagePlaybook = false;
  this.isOpenProgramList=false;
  this.isProgramPOSItemToCart = false;
  this.isProgramShoppingCart = false;
  this.isPreviewOrder=false;
  this.isEditOrder=false;
  this.isPosItemMenuPage = false;
  this.isInventoryShoppingCart = false;
  this.isInventoryPreviewOrder = false;
  this.isInventoryOrderStatus=false;
  this.isPosCatalog = false;
  this.isManageApproval = false;
  this.isManageOrderedItems=false;
  this.isManageSendWaveOrders = false;
  window.history.pushState("", 'Order Status', this.accountURL + '/s/' + 'manageorderstatus');
}

// To navigate to inventory Order status  page
if (this.selectedMenu == 'manageinventoryorderstatus') {
  document.title = 'Inventory Order Status';
  this.isInventoryOrderStatus=true;
  this.isOrderStatus=false;
  this.isHome = false;
  this.isAddressBook = false;
  this.isManageBrand = false;
  this.isManageItemType = false;
  this.isManagePosItem = false;
  this.isManageTerrioties = false;
  this.isManageShippingMethods = false;
  this.isManageASN = false;
  this.isManageApproval = false;
  this.isManageprograms = false;
  this.isManageDesignation = false;
  this.isAssignDesignation = false;
  this.isManageChairUser = false;
  this.isManageprogramsBudget = false;
  this.isManagePlaybook = false;
  this.isOpenProgramList=false;
  this.isProgramPOSItemToCart = false;
  this.isProgramShoppingCart = false;
  this.isPreviewOrder=false;
  this.isEditOrder=false;
  this.isPosItemMenuPage = false;
  this.isInventoryShoppingCart = false;
  this.isInventoryPreviewOrder = false;
  this.isPosCatalog = false;
  this.isManageApproval = false;
  this.isManageOrderedItems=false;
  this.isManageSendWaveOrders = false;
  window.history.pushState("", 'Inventory Order Status', this.accountURL + '/s/' + 'manageinventoryorderstatus');
}


 // To navigate to inventory page
    //checks if the menu selected is inventory pos item
    if (this.selectedMenu == 'inventorypositem') {
      document.title = 'Inventory Pos Item';
      this.isPosItemMenuPage = true;
      this.isOrderStatus=false;
      this.isHome = false;
      this.isAddressBook = false;
      this.isManageBrand = false;
      this.isManageItemType = false;
      this.isManagePosItem = false;
      this.isManageTerrioties = false;
      this.isManageShippingMethods = false;
      this.isManageASN = false;
      this.isManageApproval = false;
      this.isManageprograms = false;
      this.isManageDesignation = false;
      this.isAssignDesignation = false;
      this.isManageChairUser = false;
      this.isManageprogramsBudget = false;
      this.isManagePlaybook = false;
      this.isOpenProgramList=false;
      this.isProgramPOSItemToCart = false;
      this.isProgramShoppingCart = false;
      this.isPreviewOrder=false;
      this.isEditOrder=false;
      this.isInventoryShoppingCart = false;
      this.isInventoryPreviewOrder = false;
      this.isInventoryOrderStatus=false;
      this.isPosCatalog = false;
      this.isManageApproval = false;
      this.isManageOrderedItems=false;
      this.isManageSendWaveOrders = false;
      window.history.pushState("", 'Inventory Pos Item', this.accountURL + '/s/' + 'inventorypositem');

    }

    // To navigate to inventory page
    //checks if the menu selected is inventory shopping cart page
    if (this.selectedMenu == 'inventoryshoppingcart') {
      document.title = 'Inventory shopping cart';
      this.isInventoryShoppingCart = true;
      this.isPosItemMenuPage = false;
      this.isOrderStatus=false;
      this.isHome = false;
      this.isAddressBook = false;
      this.isManageBrand = false;
      this.isManageItemType = false;
      this.isManagePosItem = false;
      this.isManageTerrioties = false;
      this.isManageShippingMethods = false;
      this.isManageASN = false;
      this.isManageApproval = false;
      this.isManageprograms = false;
      this.isManageDesignation = false;
      this.isAssignDesignation = false;
      this.isManageChairUser = false;
      this.isManageprogramsBudget = false;
      this.isManagePlaybook = false;
      this.isOpenProgramList=false;
      this.isProgramPOSItemToCart = false;
      this.isProgramShoppingCart = false;
      this.isPreviewOrder=false;
      this.isEditOrder=false;
      this.isInventoryPreviewOrder = false;
      this.isInventoryOrderStatus=false;
      this.isPosCatalog = false;
      this.isManageApproval = false;
      this.isManageOrderedItems=false;
      this.isManageSendWaveOrders = false;
      window.history.pushState("", 'Inventory Shopping Cart', this.accountURL + '/s/' + 'inventoryshoppingcart');

    }

    // To navigate to pos catalog page
    //checks if the menu selected is inventory pos catalog
    if (this.selectedMenu == 'poscatalog') {
      document.title = 'Inventory POS Catalog';
      this.isPosCatalog = true;
      this.isInventoryShoppingCart = false;
      this.isPosItemMenuPage = false;
      this.isOrderStatus=false;
      this.isHome = false;
      this.isAddressBook = false;
      this.isManageBrand = false;
      this.isManageItemType = false;
      this.isManagePosItem = false;
      this.isManageTerrioties = false;
      this.isManageShippingMethods = false;
      this.isManageASN = false;
      this.isManageApproval = false;
      this.isManageprograms = false;
      this.isManageDesignation = false;
      this.isAssignDesignation = false;
      this.isManageChairUser = false;
      this.isManageprogramsBudget = false;
      this.isManagePlaybook = false;
      this.isOpenProgramList=false;
      this.isProgramPOSItemToCart = false;
      this.isProgramShoppingCart = false;
      this.isPreviewOrder=false;
      this.isEditOrder=false;
      this.isInventoryPreviewOrder = false;
      this.isInventoryOrderStatus=false;
      this.isManageApproval = false;
      this.isManageOrderedItems=false;
      this.isManageSendWaveOrders = false;
      window.history.pushState("", 'Inventory POS Catalog', this.accountURL + '/s/' + 'poscatalog');

    }

    // To navigate to manage ordered items page
    //checks if the menu selected is manage ordered items page
    if (this.selectedMenu == 'manageordereditems') {
      document.title = 'Manage Ordered Items';
      this.isManageOrderedItems=true;
      this.isPosCatalog = false;
      this.isInventoryShoppingCart = false;
      this.isPosItemMenuPage = false;
      this.isOrderStatus=false;
      this.isHome = false;
      this.isAddressBook = false;
      this.isManageBrand = false;
      this.isManageItemType = false;
      this.isManagePosItem = false;
      this.isManageTerrioties = false;
      this.isManageShippingMethods = false;
      this.isManageASN = false;
      this.isManageApproval = false;
      this.isManageprograms = false;
      this.isManageDesignation = false;
      this.isAssignDesignation = false;
      this.isManageChairUser = false;
      this.isManageprogramsBudget = false;
      this.isManagePlaybook = false;
      this.isOpenProgramList=false;
      this.isProgramPOSItemToCart = false;
      this.isProgramShoppingCart = false;
      this.isPreviewOrder=false;
      this.isEditOrder=false;
      this.isInventoryPreviewOrder = false;
      this.isInventoryOrderStatus=false;
      this.isManageApproval = false;
      this.isManageSendWaveOrders = false;
      window.history.pushState("", 'Manage Ordered Items', this.accountURL + '/s/' + 'manageordereditems');

    }

    // To navigate to manage send wave orders
    //checks if the menu selected is manage send wave orders
    if (this.selectedMenu == 'managesendwaveorders') {
      document.title = 'Manage Send Wave Orders';
      this.isManageSendWaveOrders = true;
      this.isManageOrderedItems=false;
      this.isPosCatalog = false;
      this.isInventoryShoppingCart = false;
      this.isPosItemMenuPage = false;
      this.isOrderStatus=false;
      this.isHome = false;
      this.isAddressBook = false;
      this.isManageBrand = false;
      this.isManageItemType = false;
      this.isManagePosItem = false;
      this.isManageTerrioties = false;
      this.isManageShippingMethods = false;
      this.isManageASN = false;
      this.isManageApproval = false;
      this.isManageprograms = false;
      this.isManageDesignation = false;
      this.isAssignDesignation = false;
      this.isManageChairUser = false;
      this.isManageprogramsBudget = false;
      this.isManagePlaybook = false;
      this.isOpenProgramList=false;
      this.isProgramPOSItemToCart = false;
      this.isProgramShoppingCart = false;
      this.isPreviewOrder=false;
      this.isEditOrder=false;
      this.isInventoryPreviewOrder = false;
      this.isInventoryOrderStatus=false;
      this.isManageApproval = false;
      window.history.pushState("", 'Manage Send Wave Orders', this.accountURL + '/s/' + 'managesendwaveorders');

    }
   

  // To log out from the application
  if (this.selectedMenu == 'logout') {
    window.location.replace(this.accountURL + "/secur/logout.jsp");
  }


  }
}