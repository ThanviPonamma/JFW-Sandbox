//Author:Thanvi;Date:20-SEP-2021
//Aim:To hold the functinalities of Edit details and view details buttons ,the popup modal of view details, search filter and the table which displays contents of the order status page.

import { LightningElement, wire , track,api} from 'lwc';
// to get all the ordered details from the apex method 'loadOrdersForSelectedProgram_Apex' of the apex class "InfiniumOrderStatus_Apex"
// To get the selected ordered details to view the data from the apex method "getOrderDetailsOfSelectedOrder"
import getOrderDetailsOfSelectedCritria from '@salesforce/apex/InfiniumOrderStatus_Apex.loadOrdersForSelectedProgram_Apex'
import saveEditedOrder from '@salesforce/apex/InfiniumOrderStatus_Apex.saveEditedOrder_Apex'
//to get the list of  program
import programList from '@salesforce/apex/InfiniumOrderStatus_Apex.getProgram_Apex'
// To get the no image from the static resource
import noImage from '@salesforce/resourceUrl/noimageavailable';
// to naviage to the next page
import { NavigationMixin } from 'lightning/navigation';
// to refresh the apex method when the event is invoked
import { refreshApex } from '@salesforce/apex';
//to display toast messages
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import pubsub from 'c/pubsub' ;

export default class InfiniumOrderStatusDetailsComponent extends NavigationMixin(LightningElement) {
    //to hold the value to display the details of the order derstination
    @track isOrderDestinationDetailAvailable = false;
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
    // for the order status rejected
    @track statusRejected = false;
    // for the order status rejected
    @track orderFailed = false;
    //To hold the trachig number list
    @track trackNoList;
    // To hold tracking number
    @track trackingNo;

    // to hold tracking number list
    @track trackingNosList;
    @track searchedKeyword = '';
    @track selectedProgramId = '';
    @track programListToDisplay;
    @track selectedOrderItem = [];
    @track selectedOrder;
    @track isSeasonalOrderDetails = false;
    @track seasonalOrderDetails;
    @track addOrderTotalWithAvailableBudget;
    @track isBudgetExceeded = false;
    @track disableSaveButtonForExceedBudget = false;
    @track selectedProgramDetails;

    // Variable to hold if no image is found
    NoImageURL = noImage;
    @wire(programList)
    getProgramList({ data, error }) {
        if (data) {
            // console.log('data---->',JSON.stringify(data));
            this.programListToDisplay = [{ value: '', label: 'Select a Program' }];
            // for each program
            data.forEach(element => {
                const program = {};

                program.label = element.Name__c;

                program.value = element.Id;

                this.programListToDisplay.push(program);

            });
        }
    }


    //get program Id
    getSelectedProgramId(event) {
        //to fetch the seleted program Id
        this.selectedProgramId = event.detail.value;

        if (this.selectedProgramId != '') {
            this.openModal();
        }
        else {
            this.isOrderDestinationDetailAvailable=false;
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
            selectedProgramId: this.selectedProgramId
        })
            .then(result => {
                // console.log(JSON.stringify(result));
               // this.trackingNo = this.orderDestinationDetail.cometOrder.TrackingNos__c;
                this.orderDestinationDetail = result;
                // console.log('orderDestinationDetail---->',JSON.stringify(this.orderDestinationDetail));
               // this.trackingNo = this.orderDestinationDetail.cometOrder.TrackingNos__c;
                if(this.orderDestinationDetail.length>0){
                  this.isOrderDestinationDetailAvailable=true;
                }
                else
                {
                  this.isOrderDestinationDetailAvailable=false;
                }
            })

    }




    getSelectedOrderDetails(event) {
        // console.log('entered--->');
        var selectedOrder = event.target.value;
        //console.log('selectedOrder--->',JSON.stringify(selectedOrder));
        this.selectedOrder = selectedOrder.cometOrder;
        // console.log('selectedOrder--->',JSON.stringify(this.selectedOrder));
        this.selectedOrderItem = selectedOrder.orderedItems;

        this.orderStatus = this.selectedOrder.OrdStatus__c;

        this.isModalOpen = true;
        this.statusOpen = false;
        this.statusNeedApproval = false;
        this.statusSend = false;
        this.statusSubmit = false;
        this.statusInProcess = false;
        this.statusShipped = false;
        this.statusRejected = false;
        this.orderFailed = false;


        if (this.orderStatus == 'Open') {
            this.statusOpen = true;

        }
        if (this.orderStatus == 'Needs Approval') {

            this.statusNeedApproval = true;

        }
        if (this.orderStatus == 'Send to Comet') {
            this.statusSend = true;
        }
        if (this.orderStatus == 'This order has been submitted to Comet') {
            this.statusSubmit = true;
        }
        if (this.orderStatus == 'InProcess') {
            this.statusInProcess = true;
        }
        if (this.orderStatus == 'Shipped') {
            this.statusShipped = true;
        }
        if (this.orderStatus == 'Rejected') {
            this.statusRejected = true;
        }
        if (this.orderStatus == 'This order failed to submit') {
            this.orderFailed = true;
        }

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

    //To close the view details of an order on click of cancel or close button.
    closeModal() {
        this.isModalOpen = false;
        refreshApex(this.orderDestinationDetail);
    }



    //Custom event is sent to the parent component to navigate the edit order button to the shopping cartpage. 

    openShoppingCartDetails(event) {
        var orderDetails = event.target.value;

        this.selectedProgramDetails = orderDetails.programChairBudgetDetails.program_chairBudget;
        pubsub.fire('shoppingcartevent', 'shoppingcart');

        pubsub.fire('selectedProgramDetails', this.selectedProgramDetails);
    }





    editSelectedOrder(event) {

        var selectedOrder = event.target.value;
        this.seasonalOrderDetails = selectedOrder;
        // console.log('seasonalOrderDetails--->',JSON.stringify(this.seasonalOrderDetails));
        this.selectedOrderItem = selectedOrder.orderedItems;
        // console.log('selectedOrderItem--->',JSON.stringify(this.selectedOrderItem));
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
        //console.log('seasonalOrderItem--->',JSON.stringify(seasonalOrderItem));
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
        //The below line commented for infinium, as budget is not required
        // console.log('totalRowPrice--->',totalRowPrice);
        //  if (totalRowPrice > this.addOrderTotalWithAvailableBudget) {

        // this.isBudgetExceeded = true;
        // this.disableSaveButtonForExceedBudget = true;
        // }
        //  else {
        //The below line commented for infinium, as budget is not required
        //this.isBudgetExceeded = false;
        // this.disableSaveButtonForExceedBudget = false
        // }
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

        //invoking a method saveEditedOrder of the class InfiniumOrderStatus_Apex
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