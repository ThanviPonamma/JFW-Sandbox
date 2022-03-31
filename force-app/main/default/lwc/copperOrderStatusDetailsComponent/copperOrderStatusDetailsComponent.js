//Authors:Sanjana      Date:16-09-2021
//Aim:To hold the functinalities of Edit details and view details buttons ,the popup modal of view details, search filter and the table which displays contents of the order status page.

import { LightningElement, wire, track, api } from 'lwc';
// to get all the ordered details from the apex method 'getAllInventoryOrders' of the apex class "CopperOrderStatus_Apex"
// To get the selected ordered details to view the data from the apex method "getOrderDetailsOfSelectedOrder"
import getOrderDetailsOfSelectedCritria from '@salesforce/apex/CopperOrderStatus_Apex.loadOrdersForSelectedProgram_Apex'

import saveEditedOrder from '@salesforce/apex/CopperOrderStatus_Apex.saveEditedOrder_Apex'

//to get the list of buy book
import buyBookList from '@salesforce/apex/CopperOrderStatus_Apex.getBuyBook_Apex'
// To get the no image from the static resource
import noImage from '@salesforce/resourceUrl/noimageavailable';
// to naviage to the next page
import { NavigationMixin } from 'lightning/navigation';
// to refresh the apex method when the event is invoked
import { refreshApex } from '@salesforce/apex';
//to display toast messages
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import pubsub from 'c/pubsub';

export default class CopperOrderStatusDetailsComponent extends NavigationMixin(LightningElement) {
  // to get the search keyword from the parent component
  @api searchKey = '';
  // to hold the ordered details
  @track orderStatus;
  // to bind the order details in the popup modal
  @track orderDestinationDetail;
  // boolean variable to  open the popup modal
  @track isModalOpen = false;
  // boolean variable for the order status as open 
  @track statusOpen = false;
  // boolean variable if the order needs approval 
  @track statusNeedApproval = false;
  // boolean variable if the order has the status send
  @track statusSend = false;
  // boolean variable if the order status is submitted
  @track statusSubmit = false;
  //boolean variable if the order status is InProcess
  @track statusInProcess = false;
  // boolean variable if the order status is shipped
  @track statusShipped = false;
  // for the order status failed
  @track orderFailed = false;
  // Rejected dude to shipping method
  @track shippingMethodRejected = false;
  // boolean variable if the order status is found
  @track orderStatusFound;
  //To hold the trachig number list
  @track trackNoList;
  // To hold tracking number
  @track trackingNo;
  //to hold the value to display the details of the order derstination
  @track isOrderDestinationDetailAvailable = false;
  // to hold tracking number list
  @track trackingNosList = [];
  //to display the comet order details in the pop-up
  @track cometOrderAddressDetails;
  @track searchedKeyword = '';
  @track selectedBuyBookId = '';
  @track buyBookListToDisplay;
  @track selectedOrderItem = [];
  @track selectedOrder;
  @track isSeasonalOrderDetails = false;
  @track seasonalOrderDetails;
  @track addOrderTotalWithAvailableBudget;
  @track isBudgetExceeded = false;
  @track disableSaveButtonForExceedBudget = true;
  @track selectedBuyBookDetails;
  @track consumedBudget;

  // Variable to hold if no image is found
  NoImageURL = noImage;


  // for spinner
  @track isLoading = false;

  @wire(buyBookList)
  getProgramList({ data, error }) {
    if (data) {
      this.buyBookListToDisplay = [{ value: '', label: 'All Buy Book' }];
      // for each buy book
      data.forEach(element => {
        const buyBook = {};

        buyBook.label = element.Name__c;

        buyBook.value = element.Id;

        this.buyBookListToDisplay.push(buyBook);

      });
    }
  }


  //get buyBook Id
  getSelectedBuyBookId(event) {
    //  //to fetch the seleted buyBook Id
    this.selectedBuyBookId = event.detail.value;
    if (this.selectedBuyBookId != '') {
      this.openModal();
    }
    else {
      this.isOrderDestinationDetailAvailable = false;
    }

  }

  //the onchange event to stored the searched keyword
  getSearchKeyword(event) {
    this.searchedKeyword = event.detail.value;
    this.openModal();

  }

  //To open view details modal for the selected order
  openModal(event) {
    getOrderDetailsOfSelectedCritria({
      searchKeyword: this.searchedKeyword,
      isEmergeAdmin: false,
      selectedBuyBookId: this.selectedBuyBookId
    })
      .then(result => {
        this.orderDestinationDetail = result;
        if (this.orderDestinationDetail.length > 0) {
          this.isOrderDestinationDetailAvailable = true;
          this.consumedBudget = this.orderDestinationDetail[0].programChairBudgetDetails.program_chairBudget.Consumed_Budget__c;
        }
        else {
          this.isOrderDestinationDetailAvailable = false;
        }
      })
  }

  getSelectedOrderDetails(event) {
    var selectedOrder = event.target.value;
    //console.log('selectedOrder--->',JSON.stringify(selectedOrder));
    this.selectedOrder = selectedOrder.cometOrder;
    this.selectedOrderItem = selectedOrder.orderedItems;
    //  console.log('selectedOrderItem--->',JSON.stringify(this.selectedOrderItem));
    this.orderStatus = this.selectedOrder.OrdStatus__c;
    // Author - Thanvi; Date - 10-Fe-2021; CR No Copper-10-Feb-1
    this.trackingNo = selectedOrder.cometOrder.TrackingNos__c;
    this.isModalOpen = true;
    //comet order 
    if (this.trackingNo != null) {
      let splittedTrackingNos = this.trackingNo.split(',');
      for (let i = 0; i < splittedTrackingNos.length; i++) {
        this.trackingNosList.push(splittedTrackingNos[i].trim());
      }
      this.trackNoList = this.trackingNosList;
    }
    else {
      this.trackNoList = [];
    }
  }


  onClickOfTrackingNumberButton(event){
    var trackingNumber = event.target.value;

    if(event.target.name == 'UPS'){
      this[NavigationMixin.Navigate]({
        "type": "standard__webPage",
        "attributes": {
          "url": "https://www.ups.com/track?loc=null&tracknum=" + trackingNumber
        }
      });
    }
    if(event.target.name == 'Fedex'){
      this[NavigationMixin.Navigate]({
        "type": "standard__webPage",
        "attributes": {
          "url": "https://www.fedex.com/apps/fedextrack/?action=track&trackingnumber=" + trackingNumber
        }
      });
    }
    if(event.target.name == 'Road Runner'){
      this[NavigationMixin.Navigate]({
        "type": "standard__webPage",
        "attributes": {
          "url": "http://tools.rrts.com/LTLTrack/?searchValues=" + trackingNumber
        }
      });

    }
    if(event.target.name == 'BOE'){
      this[NavigationMixin.Navigate]({
        "type": "standard__webPage",
        "attributes": {
          "url": "https://www.bestovernite.com/tracking.aspx?boereq=track;pro=" + trackingNumber
        }
      });

    }
    if(event.target.name == 'Estes'){
      this[NavigationMixin.Navigate]({
        "type": "standard__webPage",
        "attributes": {
          "url": "https://www.estes-express.com/myestes/tracking/shipments;trackingnumber=" + trackingNumber
        }
      });
    }
  }

  //To close the view details of an order on click of cancel or close button.
  closeModal() {
    this.isModalOpen = false;
    refreshApex(this.orderDestinationDetail);
  }



  //Custom event is sent to the parent component to navigate the edit order button to the shopping cartpage. 

  openShoppingCartDetails(event) {
    var orderDetails = event.target.value;
    this.selectedBuyBookDetails = orderDetails.programChairBudgetDetails.program_chairBudget;
    pubsub.fire('shoppingcartevent', 'shoppingcart');
    pubsub.fire('selectedBuyBookDetails', this.selectedBuyBookDetails);
  }

  editSelectedOrder(event) {
    var selectedOrder = event.target.value;
    this.seasonalOrderDetails = selectedOrder;
    this.selectedOrderItem = selectedOrder.orderedItems;
    var dataForTotalValue = this.seasonalOrderDetails.totalOrderValue;
    var availableBudget = this.seasonalOrderDetails.programChairBudgetDetails.program_chairBudget.Available_Chair_Budget__c;
    // console.log('availableBudget--->',availableBudget);
    dataForTotalValue = dataForTotalValue == '' ? 0 : dataForTotalValue;
    availableBudget = availableBudget == '' ? 0 : availableBudget;
    this.addOrderTotalWithAvailableBudget = parseFloat(dataForTotalValue) + parseFloat(availableBudget);
    this.isSeasonalOrderDetails = true;
  }

  goBackToPreviousPage(event) {
    this.isSeasonalOrderDetails = false;
  }

  onEditButtonSelected(event) {
    var seasonalOrderItem = event.target.value;
    let selectedOrderItem = [];
    let updateDetails = [];
    for (var i = 0; i < this.selectedOrderItem.length; i++) {
      if (this.selectedOrderItem[i].cometOrderItem.Id == seasonalOrderItem.cometOrderItem.Id) {
        updateDetails = JSON.parse(JSON.stringify(this.selectedOrderItem[i]));
        updateDetails.isQtyEditable = false;
        selectedOrderItem.push(updateDetails);
      }
      else {
        updateDetails = JSON.parse(JSON.stringify(this.selectedOrderItem[i]));
        updateDetails.isQtyEditable = true;
        selectedOrderItem.push(updateDetails);
      }
    }
    this.selectedOrderItem = selectedOrderItem;
  }

  validateNumber(event) {
    var keyboardKey = event.which ? event.which : event.keycode;
    var regexForSpecialCharacters = /[^0-9]/;
    if (regexForSpecialCharacters.test(event.key) && keyboardKey != 8)
      event.preventDefault();
  }

  onChangeOrderQuantity(event) {
    var enteredQuantity = 0; // on changes, the quantity entered
    enteredQuantity = event.target.value;
    var seasonalOrderItem = event.target.dataset.id;
    let selectedOrderItem = [];
    let seasonalOrderDetails = [];
    let updateDetails = [];
    var indiviualQty = 0; // Indiviual Quantity of each row
    var indiviualPricePerRow = 0.00;
    var totalRowPrice = 0.00;
    for (var i = 0; i < this.selectedOrderItem.length; i++) {
      if (this.selectedOrderItem[i].cometOrderItem.Id == seasonalOrderItem) {
        updateDetails = JSON.parse(JSON.stringify(this.selectedOrderItem[i]));
        updateDetails.cometOrderItem.Quantity__c = enteredQuantity;
        selectedOrderItem.push(updateDetails);
      }
      else {
        updateDetails = JSON.parse(JSON.stringify(this.selectedOrderItem[i]));
        selectedOrderItem.push(updateDetails);
      }
    }
    this.selectedOrderItem = selectedOrderItem;
    // console.log('this.selectedOrderItem--->',JSON.stringify(this.selectedOrderItem));

    for (var i = 0; i < this.selectedOrderItem.length; i++) {
      enteredQuantity = this.selectedOrderItem[i].cometOrderItem.Quantity__c;
      indiviualQty = parseInt(indiviualQty) + parseInt(enteredQuantity);
      indiviualPricePerRow = enteredQuantity * this.selectedOrderItem[i].cometOrderItem.POS_Item__r.Price__c;
      totalRowPrice = parseInt(totalRowPrice) + parseInt(indiviualPricePerRow);
      this.selectedOrderItem[i].cometOrderItem.Total_Line_Amount__c = indiviualPricePerRow;
    }

    /**The below lines are removed as exceed budget is hidden for copper cane as of now */
    // if (totalRowPrice > this.addOrderTotalWithAvailableBudget) {
    //   this.isBudgetExceeded = true;
    //   this.disableSaveButtonForExceedBudget = true;
    // }
    // else {
    //   this.isBudgetExceeded = false;
    //   this.disableSaveButtonForExceedBudget = false;
    // }
    this.disableSaveButtonForExceedBudget = false;
    let updateTotalAmount = JSON.parse(JSON.stringify(this.seasonalOrderDetails));
    updateTotalAmount.totalOrderValue = totalRowPrice
    seasonalOrderDetails.push(updateTotalAmount);
    this.seasonalOrderDetails = seasonalOrderDetails[0];
  }


  //invoke on 'close' modal button
  exceedCloseModal() {
    this.isBudgetExceeded = false;
  }


  //to save the edited order 
  saveOrder(event) {
    //  console.log('selectedOrderItem--->',JSON.stringify(this.selectedOrderItem));
    //  console.log('seasonalOrderDetails--->',JSON.stringify(this.seasonalOrderDetails));

    //invoking a method saveEditedOrder of the class CopperEditOrder_Apex
    saveEditedOrder({
      // send order details as the parameter
      seasonalOrderItems: JSON.stringify(this.selectedOrderItem),
      orderAmount: this.seasonalOrderDetails.cometOrder.Order_Amount__c,
      cometOrderId: this.seasonalOrderDetails.cometOrder.Id,
      chairBudget: this.seasonalOrderDetails.programChairBudgetDetails.program_chairBudget
    })
      .then(result => {
        //to hold the result from the apex method
        let resultGiven = result;
        // console.log('resultGiven--->', resultGiven);
        this.openModal();
        this.isSeasonalOrderDetails = false;
        //display the toast message as the brand has been updated successfully
        const evt = new ShowToastEvent({
          message: 'Your order has been updated successfully.',
          variant: 'success',
        });
        // disaptch the event
        this.dispatchEvent(evt);
      })
  }
  onClickOfTrackingNo(event) {
    // tracking no    
    let trackingNo = event.target.value;
    this[NavigationMixin.Navigate]({
      "type": "standard__webPage",
      "attributes": {
        "url": "https://www.ups.com/track?loc=null&tracknum=" + trackingNo
      }
    });
  }

}