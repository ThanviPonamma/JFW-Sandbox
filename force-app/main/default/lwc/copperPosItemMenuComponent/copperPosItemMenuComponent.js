//Author:Thanvi; Date:31/Aug2021
// Aim : To hold the functionalities of breadcrubms , cart button and to receive the custom event from  child components copperPosItemMenuWithFiltersComponent and copperPosItemMenuAddOrRemoveItemsComponent
import {LightningElement,api,track} from 'lwc';
// to import the pubsub component to navigate to shopping cart page on click view cart button
import pubsub from 'c/pubsub';

export default class CopperPosItemMenuComponent extends LightningElement {
  //To hold the selected buyBook details
  @api selectedBuyBookDetail;
  //To hold the buyBookId
  @api buyBookId;
  //To hold the brandId
  @api brandId = "";
  //To hold the itemTypeId
  @api itemTypeId = "";
  //To hold the sortById
  @api sortByValue = "";
  //To hold the searck key word
  @api searchValue = "";
  //To hold the cart Size
  @track viewCartSize = 0;
  //to disable the view cart button
  @track isDisableViewCart;
  //to hold the value of viewType
  @api isListView;
  @track availabeBudget = 0;
  connectedCallback() {
    this.availabeBudget =
      this.selectedBuyBookDetail.Available_Budget__c -
      this.selectedBuyBookDetail.Consumed_Budget__c;
  }
  // To get the brand id from child one to parent component
  brandIdEvent(event) {
    // to get the brandid from the custom event detail
    this.brandId = event.detail;
    this.template
      .querySelector("c-copper-pos-item-menu-add-or-remove-items-component")
      .doInit();
  }

  //  To get the item id from child one to parent component
  itemTypeIdEvent(event) {
    // to get the itemId from the custom event detail
    this.itemTypeId = event.detail;
    this.template
      .querySelector("c-copper-pos-item-menu-add-or-remove-items-component")
      .doInit();
  }

  // To get the sort by  id from child one to parent component
  getSortbyIdEvent(event) {
    // to get the sortby from the custom event detail
    this.sortByValue = event.detail;
    this.template
      .querySelector("c-copper-pos-item-menu-add-or-remove-items-component")
      .doInit();
  }

  // To get the search value sent from child one to parent component
  searchEventHandler(event) {
    // to get the search value from the custom event detail
    this.searchValue = event.detail;
    this.template
      .querySelector("c-copper-pos-item-menu-add-or-remove-items-component")
      .doInit();
  }
  //To set the value to true to dipaly the  shopping cart using publish
  navigateToShoppingCartComponent() {
    pubsub.fire("shoppingcartevent", "shoppingcart");
  }

  // to get the total cart from child 2 to display in parent component
  cartItemSizeEvent(event) {
    // to get the cart item size from the custom event detail
    this.viewCartSize = event.detail;
    if (this.viewCartSize > 0) {
      this.isDisableViewCart = false;
    } else {
      this.isDisableViewCart = true;
    }
  }

  // on click of the view cart button this event in called and it takes the data given from the child componenet and call the "Shopping cart" componenet
  viewItemEvent(event) {
    // // to get the item view list/grid from the custom event detail
    this.isListView = event.detail;

    this.template
      .querySelector("c-copper-pos-item-menu-add-or-remove-items-component")
      .doInit();
  }
  //Aim: The event is fired when the there the home link in the breadcrumb is clicked
  navigateToHomePage(event) {
    //The home page is called using pubsub model.
    pubsub.fire("homeevent", "home");
  }
  goToOpenProgramList(){
      pubsub.fire('manageopenbuybookevent', 'manageopenbuybook');
  }
}