import { LightningElement,wire, api, track } from 'lwc';
import getBuyBookList from '@salesforce/apex/CopperEditOrderForDivisionalManager_Apex.getAllBuyBookList_Apex';
import loadOrdersForSelectedBuyBookAndUser_Apex from '@salesforce/apex/CopperEditOrderForDivisionalManager_Apex.loadOrdersForSelectedBuyBookAndUser_Apex';
import saveEditedOrder from '@salesforce/apex/CopperEditOrderForDivisionalManager_Apex.saveEditedOrder_Apex';
import getUserList from '@salesforce/apex/CopperEditOrderForDivisionalManager_Apex.getAllUsersToDisplay_Apex';
// to display no image
import noImage from '@salesforce/resourceUrl/noimageavailable';
//import the toast message event
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class CopperEditOrderDetailsForDivisionalManagerComponent extends LightningElement {
    //to hold the list of buyBook
    @track buyBookListToDisplay;
    //to hold the buy book selected by the user
    @track selectedBuyBookId='';
    // to hold theprogram budget
    @track totalProgramBudget = 0;
    //to hold the seasonal order list for the selected criteria
    @track seasonalOrderList = [];
    //to hold if the seasonal order table should be displayed
    @track isSeasonalOrder = false;
    //to hold if the seasonal order details should be displayed
    @track isSeasonalOrderDetails = false;
    // to hold the value of avialble budget for the order total 
    @track addOrderTotalWithAvailableBudget = 0;
    // to hold seasonal order items for the selected order number 
    @track seasonalOrderItems = [];
    //to hold the seasonal order details
    @track seasonalOrderDetails = [];
    // to disable save button
    @track disableSaveButtonForExceedBudget = true;
    //to display budget exceeded pop-up
    @track isBudgetExceeded = false;
    // no image variable
    NoImageURL = noImage;
    //to hold search keyword
    // @track serachKeyword=''
    //to hold the users to be displayed
    @track usersToDisplay;
    //to hold selectedUser
    @track selectedUser='';

    @track displayOrders = false;

    @wire(getBuyBookList)
    loadBuyBookList({ data, error }) {
        // If the getBuyBookList has data
        if (data) {
            // get the value and lable for each brand in the buy book list
            this.buyBookListToDisplay = [{ value: '', label: 'All Buy Book' }];
            // for each buy book
            data.forEach(element => {
                const buyBook = {};
                //set buy book name to the lable property
                buyBook.label = element.Name__c;
                // Set the buyBook id to the value property
                buyBook.value = element.Id;
                // push the buyBook data to "buyBookListToDisplay" property
                this.buyBookListToDisplay.push(buyBook);
            });
        }
    }

    @wire(getUserList)
    getUserListToDisplay({ data, error }) {

        if (data) {

            this.usersToDisplay = [{ value: '', label: 'All Users' }];
            // for each program
            data.forEach(element => {
                const user = {};

                user.label = element.Name;

                user.value = element.Id;

                this.usersToDisplay.push(user);

                console.log('usersToDisplay---->',JSON.stringify(this.usersToDisplay));

            });
        }
    }

    //get buyBook Id
    handleChangeForBuyBook(event) {
        //to fetch the seleted buyBook Id
        this.selectedBuyBookId = event.target.value;
        this.getSeasonalOrders();
    }

    getSelectedUser(event){
        this.selectedUser = event.target.value;
        console.log('selectedUser---->',this.selectedUser);
        console.log('selectedBuyBookId---->',this.selectedBuyBookId);
            this.getSeasonalOrders();
    }
    //to fetch the seasonal order based on the buy book id and search key word
    // handleSearchKeyword(event) {
    //     this.serachKeyword = event.target.value;
    //     this.getSeasonalOrders();
    // }
    getSeasonalOrders(event){

        if (this.selectedBuyBookId != '' && this.selectedUser!='') {

            // invoke the method loadOrdersForSelectedBuyBookAndUser_Apex with the parameter Buy book Id, search keyword
            loadOrdersForSelectedBuyBookAndUser_Apex({
                selectedBuyBookId: this.selectedBuyBookId,
                selectedUser: this.selectedUser
            })
                .then(result => {
                    // to hold the seasonal order result
                    this.seasonalOrderList = result;
                    // to check if the seasonal order lenght is greater than 0
                    if (this.seasonalOrderList.length > 0) {
                        this.totalProgramBudget = (result[0].buyBookConsumedValue == '') ? 0 : result[0].buyBookConsumedValue;
                        this.isSeasonalOrder = true;
                        this.isSeasonalOrderDetails = false;
                        this.displayOrders = true;
                    }
                    else {
                        this.displayOrders = false;
                        this.isSeasonalOrder = false;
                        this.isSeasonalOrderDetails = false;
                    }
                })
        }
        else {
            this.displayOrders = false;
            this.seasonalOrderList = null;
            this.totalProgramBudget = 0;
        }
    }
    // to open the order details based on the order number selected
    editSeasonalOrder(event) {
        this.seasonalOrderDetails = event.target.value;
        var dataForTotalValue = this.seasonalOrderDetails.totalOrderValue;
        var availableBudget = this.seasonalOrderDetails.chairBudget.Available_Chair_Budget__c;
        dataForTotalValue = dataForTotalValue == '' ? 0 : dataForTotalValue;
        availableBudget = availableBudget == '' ? 0 : availableBudget;
        this.addOrderTotalWithAvailableBudget = parseFloat(dataForTotalValue) + parseFloat(availableBudget);
        this.seasonalOrderItems = this.seasonalOrderDetails.orderedItems;
        this.isSeasonalOrder = false;
        this.isSeasonalOrderDetails = true;

    }
    validateNumber(event) {
        var keyboardKey = event.which ? event.which : event.keycode;
        var regexForSpecialCharacters = /[^0-9]/;
        if (regexForSpecialCharacters.test(event.key) && keyboardKey != 8)
            event.preventDefault();
    }
    onEditButtonSelected(event) {
        var seasonalOrderItem = event.target.value;
        let seasonalOrderItems = [];
        let updateDetails = [];
        for (var i = 0; i < this.seasonalOrderItems.length; i++) {
            if (this.seasonalOrderItems[i].cometOrderItem.Id == seasonalOrderItem.cometOrderItem.Id) {
                updateDetails = JSON.parse(JSON.stringify(this.seasonalOrderItems[i]));
                updateDetails.isQtyEditable = false;
                seasonalOrderItems.push(updateDetails);
            }
            else {
                updateDetails = JSON.parse(JSON.stringify(this.seasonalOrderItems[i]));
                updateDetails.isQtyEditable = true;
                seasonalOrderItems.push(updateDetails);
            }
        }
        this.seasonalOrderItems = seasonalOrderItems;
    }

    onChangeOrderQuantity(event) {
        var enteredQuantity = 0; // on changes, the quantity entered
        enteredQuantity = event.target.value;
        var seasonalOrderItem = event.target.dataset.id;
        let seasonalOrderItems = [];
        let seasonalOrderDetails = [];
        let updateDetails = [];
        var indiviualQty = 0; // Indiviual Quantity of each row
        var indiviualPricePerRow = 0.00;
        var totalRowPrice = 0.00;
        for (var i = 0; i < this.seasonalOrderItems.length; i++) {
            if (this.seasonalOrderItems[i].cometOrderItem.Id == seasonalOrderItem) {
                updateDetails = JSON.parse(JSON.stringify(this.seasonalOrderItems[i]));
                updateDetails.cometOrderItem.Quantity__c = enteredQuantity;
                seasonalOrderItems.push(updateDetails);
            }
            else {
                updateDetails = JSON.parse(JSON.stringify(this.seasonalOrderItems[i]));
                seasonalOrderItems.push(updateDetails);
            }
        }
        this.seasonalOrderItems = seasonalOrderItems;
        //console.log('this.seasonalOrderItems--->',JSON.stringify(this.seasonalOrderItems));

        for (var i = 0; i < this.seasonalOrderItems.length; i++) {
            enteredQuantity = this.seasonalOrderItems[i].cometOrderItem.Quantity__c;
            indiviualQty = parseInt(indiviualQty) + parseInt(enteredQuantity);
            indiviualPricePerRow = enteredQuantity * this.seasonalOrderItems[i].cometOrderItem.POS_Item__r.Price__c;
            totalRowPrice = parseInt(totalRowPrice) + parseInt(indiviualPricePerRow);
            this.seasonalOrderItems[i].cometOrderItem.Total_Line_Amount__c = indiviualPricePerRow;
        }
       /**The below lines are removed as exceed budget is hidden for copper cane as of now */
        // if (totalRowPrice > this.addOrderTotalWithAvailableBudget) {
        //     this.isBudgetExceeded = true;
        //     this.disableSaveButtonForExceedBudget = true;
        // }
        // else {
        //     this.isBudgetExceeded = false;
        //     this.disableSaveButtonForExceedBudget = false;
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
    // go back to previous page()
    goBackToPreviousPage(event) {

        this.isSeasonalOrder = true;
        this.isSeasonalOrderDetails = false;
    }

      //to save the edited order 
      saveOrder(event) {
    //invoking a method saveEditedOrder of the class CopperEditOrderForDivisionalManager_Apex
    saveEditedOrder({
      // send order details as the parameter
      seasonalOrderItems : JSON.stringify(this.seasonalOrderItems),
            orderAmount : this.seasonalOrderDetails.cometOrder.Order_Amount__c,
            cometOrderId : this.seasonalOrderDetails.cometOrder.Id,
            chairBudget : this.seasonalOrderDetails.chairBudget
    })
      .then(result => {
        //to hold the result from the apex method
        let resultGiven = result;
        this.getSeasonalOrders();
          //display the toast message as the brand has been updated successfully
          const evt = new ShowToastEvent({
            message: 'Your order has been updated successfully.',
            variant: 'success',
          });
          // disaptch the event
          this.dispatchEvent(evt);
      })
  }
}