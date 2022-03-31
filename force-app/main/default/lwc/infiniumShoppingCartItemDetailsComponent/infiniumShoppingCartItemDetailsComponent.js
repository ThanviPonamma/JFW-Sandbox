//  Author:Thanvi;Date:20-SEP-2021
// to ge the pos item details from the apex method and display in the page and to send the pos items qunatity entered and if the user wants to delete the pos item
import { LightningElement,wire,track,api} from 'lwc';
// to ge the cart item list from the apex method 'getCartItemsList' of class 'InfiniumShoppingCartItem_Apex'
import getCartItemsList from '@salesforce/apex/InfiniumShoppingCartItem_Apex.getCartItemsList_Apex'
// to ge the updated quantity for the selected pos items from the apex method 'updateQuantityForSelectedItem_Apex' of class 'InfiniumShoppingCartItem_Apex'
import updateQuantityForSelectedPosItem from '@salesforce/apex/InfiniumShoppingCartItem_Apex.updateQuantityForSelectedItem_Apex'
// to send the pos items to the apex method 'deleteCartItemFromShippingCart_Apex' of the class 'InfiniumShoppingCartItem_Apex' if user wants to delete the items
import deleteCartItemFromShippingCart from '@salesforce/apex/InfiniumShoppingCartItem_Apex.deleteCartItemFromShippingCart_Apex'
// to refresh the apex page whenever any changes hapeens in the componenet
import {refreshApex} from '@salesforce/apex';
// to display toast message to the users
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
// to show the get the 'No image' image from the static resource
import InfiniumNoImage from '@salesforce/resourceUrl/noimageavailable';
// to send add same address to all to apex method
import getSelectedUserAddressBookListForAllItems from '@salesforce/apex/InfiniumShoppingCartItem_Apex.getSelectedUserAddressBookListForAllItems_Apex'
// To check if the address is domastic or international
import getUserDetails from '@salesforce/apex/InfiniumShoppingCartItem_Apex.getUserDetails_Apex'

export default class InfiniumShoppingCartItemDetailsComponent extends LightningElement {
    //to hold the list of  all pos items in cart
    @track posItemsListInCart = [];
    //variable to store the JSON parse covert of 'posItemsListInCart' variable
    @api cartItems;
    // to send the selected address to child component
    @api selectedAddressForPosItems;
    //to hold the modal status value
    @track isModalOpen = false;
    //to hold order Id
    @api orderId;
    //to hold pos item Id
    @track posItemId;
    //to hold shipping address Id
    @track shippingAddressId;
    @track quantityUpdateValue = 0;
    //to hold boolean value to disable the preview button
    @track disablePreview;
    @track totalQuantity = 0;
    //to check if the positems in cart exists
    @track isAddressAvailableForDisplay;
    // to send the user details to child component
    @api user;
    //To hold the programId
    @api programId;
    //To hold the selected Program details
    @api selectedProgramDetail;
    //to hold total quantity of the item
    @track totalItemQuantity = 0;
    //to hold total price of the item
    @track totalItemPrice = 0;
    //to disable preview button
    @track disablePreviewButtonForExceedBudget = false;
    //to display budget exceeded pop-up
    @track isBudgetExceeded = false;
    //to hold the total price from all items
    @track totalPrice = 0;
    //disable preview button in parent
    @api disablePreview = false;
    // the variable to store the no image given from static resource
    infiniumNoImage = InfiniumNoImage;
    @track invokeType='server'
    //to hold the list of pos items in cart along with the details
    @wire(getCartItemsList, { selectedProgramId: '$programId' }) cartItemsToBeDisplayed;


    @wire(getUserDetails) userAddressDetails;
    /* To check if the item type name in cart is COUPON, if yes the quantity is editable only for the states the item is valid for.*/
    //to get cart items on page inialisation
    get cartItemDetails() {
        // To check if the address is domastic of international
        if (this.userAddressDetails.data) {
            this.user = this.userAddressDetails.data;
        }
        // To get the pos items in cart to display
        if (this.cartItemsToBeDisplayed.data) {
            //  console.log('cartItemsToBeDisplayed-------->', JSON.stringify(this.cartItemsToBeDisplayed.data));
            this.posItemsListInCart = this.cartItemsToBeDisplayed.data;
            //To check if the given pos item has the data or not 
            if (this.posItemsListInCart.length > 0) {
                this.isAddressAvailableForDisplay = true;
            } else {
                this.isAddressAvailableForDisplay = false;
            }
            // to assign the total quanity to zero by default
            this.totalQuantity = 0;
            // to assign the total price to zero by default
            this.totalPrice = 0;
            // if total quantity is 0 then disable the preview button
            this.disablePreview = true;
            // local variable to convert the pos items in cart to json parse so that anyone can edit the incoming items
            var posItemsListWithCart = JSON.parse(JSON.stringify(this.posItemsListInCart));
            //to check if the entred quantity has exceed initally
            for (var i = 0; i < posItemsListWithCart.length; i++) {
                this.totalQuantity += this.posItemsListInCart[i].totalQuantityFromAllAddresses;
                this.totalPrice += this.posItemsListInCart[i].totalPriceFromAllAddresses;
                 var availableBudget = this.selectedProgramDetail.Available_Budget__c - this.selectedProgramDetail.Consumed_Budget__c;
                // if (this.totalPrice > availableBudget) {
                //     this.disablePreviewButtonForExceedBudget = true;
                //     this.disablePreviewButton();
                // }
                // else {
                //     this.disablePreviewButtonForExceedBudget = false;
                   this.openPreviewPage();
                //     this.disablePreviewButton();
                // }
            }
            this.posItemsListInCart = posItemsListWithCart;
            this.cartItemsToBeDisplayed.data = posItemsListWithCart;
            // if quantity is > 0 then enable the repview button
            if (this.totalQuantity > 0) {
               
                this.disablePreview = false;
            }
            if (this.posItemsListInCart.length > 0) {
                if (this.posItemsListInCart[0].orderId) {
                    this.orderId = this.posItemsListInCart[0].orderId;
                }
            }
            //below two lines are commented as infinium doesn't need exceed budget
            //if(this.invokeType=='server')
           // this.calculatePrice();
           
            // * To check if the item type name in cart is COUPON, if yes the quantity is editable only for the states the item is valid for. item type name is not coupoun then doesnt check for valid states**/

            for (var i = 0; i < posItemsListWithCart.length; i++) {
                //Check if the item type name is coupon
                if (posItemsListWithCart[i].posItem.Type_of_Item__r.Item_Type__c.toUpperCase() == 'COUPON') {
                    //to check if the state list of the pos item and the address selected are same
                    for (var k = 0; k < posItemsListWithCart[i].posItemStateList.length; k++) {
                        for (var j = 0; j < posItemsListWithCart[i].selectedAddressWithQtyDetails.length; j++) {
                            // if yes then the quantity is editable
                            if (posItemsListWithCart[i].posItemStateList[k].State__c == posItemsListWithCart[i].selectedAddressWithQtyDetails[j].selectedAddress.State__c) {
                                posItemsListWithCart[i].selectedAddressWithQtyDetails[j].isQuantityEditable = true;
                            }
                        }
                    }

                }
                //If the item type name is not coupon then the quantity field should be editable
                else {
                    for (var j = 0; j < posItemsListWithCart[i].selectedAddressWithQtyDetails.length; j++) {
                        posItemsListWithCart[i].selectedAddressWithQtyDetails[j].isQuantityEditable = true;
                    }
                }
            }
        }
        
       refreshApex(this.cartItemsToBeDisplayed);
    }

    disablePreviewButton(event) {
        var disablePreview = false;
       // console.log('disablePreviewButtonForExceedBudget',this.disablePreview);
       // console.log('disablePreview',this.disablePreview)
        if(this.disablePreview||this.disablePreviewButtonForExceedBudget)
        disablePreview = true;
        // Creates the event with the data.
        const selectedEvent = new CustomEvent("disablepreviewbutton", {
            detail: disablePreview
        });

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    //to set the isModalOpen to true and send the cartitems detsils  on click of 'add same address for all' button 
    //these details are sent to child component '-infinium-shopping-cart-address-modal-component'
    addSameAddressForAllItems() {
        this.cartItems = JSON.parse(JSON.stringify(this.posItemsListInCart));

        getSelectedUserAddressBookListForAllItems({
            posItemsListWithCart: JSON.stringify(this.cartItems)
        })
            .then(result => {
                this.selectedAddressForPosItems = result;
                this.isModalOpen = true;

            });
    }

    //invoke on 'close' modal button
    closeModal() {
        this.isModalOpen = false;
        refreshApex(this.cartItemsToBeDisplayed);
    }
    //invoke on 'close' modal button
    exceedCloseModal() {
        this.isBudgetExceeded = false;
        this.invokeType='frontend'
        // refreshApex(this.cartItemsToBeDisplayed);
    }

    //responsible to call preview page on click of 'preview' button
    openPreviewPage() {

        const sendToParent = new CustomEvent('callpreviewcomponent', {
            detail: this.orderId
        });
        this.dispatchEvent(sendToParent);
    }

    // to upadte the pos items quantity after selected the address
    updateQuantity(event) {
        this.shippingAddressId = event.target.dataset.id;
        this.posItemId = event.target.dataset.pos;
        this.quantityUpdateValue = event.target.value;
        this.orderId = event.target.dataset.order;
        var posItemsListWithCart = JSON.parse(JSON.stringify(this.posItemsListInCart))

        for (var i = 0; i < posItemsListWithCart.length; i++) {

            var individualQty = 0;
            for (var j = 0; j < posItemsListWithCart[i].selectedAddressWithQtyDetails.length; j++) {
                if (this.shippingAddressId == posItemsListWithCart[i].selectedAddressWithQtyDetails[j].selectedAddress.Id) {
                    let quantityTobeUpdated = event.target.value;
                    this.quantityUpdateValue = quantityTobeUpdated == '' ? 0 : quantityTobeUpdated;
                    posItemsListWithCart[i].selectedAddressWithQtyDetails[j].quantity = this.quantityUpdateValue;

                }
                // after getting the qunity to calculate the totla quantity
                var quantity = posItemsListWithCart[i].selectedAddressWithQtyDetails[j].quantity == '' ? 0 : posItemsListWithCart[i].selectedAddressWithQtyDetails[j].quantity;
                individualQty = parseInt(individualQty) + parseInt(quantity);
                posItemsListWithCart[i].selectedAddressWithQtyDetails[j].quantity = parseInt(quantity);
            }
            posItemsListWithCart[i].totalQuantityFromAllAddresses = individualQty;
        }



        this.posItemsListInCart = posItemsListWithCart;
        // to send the updated quantity ot the apex method "updateQuantityForSelectedPosItem" with the parameter positemid,shipping address id and order id and quantity added.
        updateQuantityForSelectedPosItem({
            posItemId: this.posItemId,
            shippingAddressId: this.shippingAddressId,
            orderId: this.orderId,
            quantity: this.quantityUpdateValue
        })
            .then(result => {
                // once the quantity is sent to the apex method the result should be sent as 'done'
                let resultObtained = result;
                this.invokeType='server';
               return refreshApex(this.cartItemsToBeDisplayed);
               
            })
            
    }

    calculatePrice() {
        var cartItems = this.posItemsListInCart;
        ///console.log('cartItems---->',JSON.stringify(cartItems));
        var totalQuantity = 0;
        var totalPrice = 0;
        //console.log('cartItems---->',JSON.stringify(cartItems));
        for (var i = 0; i < cartItems.length; i++) {
            var individualQty = 0;
            for (var j = 0; j < cartItems[i].selectedAddressWithQtyDetails.length; j++) {
                ///console.log('cartitems details--->',JSON.stringify(cartItems[i].selectedAddressWithQtyDetails));
                var itemQuantity = cartItems[i].selectedAddressWithQtyDetails[j].quantity == '' ? 0 : cartItems[i].selectedAddressWithQtyDetails[j].quantity;
                individualQty = parseInt(individualQty) + parseInt(itemQuantity);
                cartItems[i].selectedAddressWithQtyDetails[j].quantity = parseInt(itemQuantity);
            }
            totalQuantity = individualQty + totalQuantity;
            totalPrice = totalPrice + (individualQty * cartItems[i].posItem.Price__c);
            cartItems[i].totalPriceFromAllAddresses = individualQty * cartItems[i].posItem.Price__c;
            this.posItemsListInCart = cartItems;
            this.totalItemQuantity = totalQuantity;
            this.totalPrice = totalPrice;
            var availableBudget = this.selectedProgramDetail.Available_Budget__c - this.selectedProgramDetail.Consumed_Budget__c;
            if (this.totalPrice > availableBudget ) {
                this.disablePreviewButtonForExceedBudget = true;
                this.disablePreviewButton();
                this.isBudgetExceeded = true;
            }
            else {
                this.disablePreviewButtonForExceedBudget = false;
                this.openPreviewPage();
                this.disablePreviewButton();
                this.isBudgetExceeded = false;
            }
        }
    }


    //to restrict special character while entering data in quantity field
    validateNumber(event) {
        var regexForSpecialCharacters = /[^0-9]/g;
        var keyCodes = [8, 37, 38, 39, 40];
        if (regexForSpecialCharacters.test(event.key) && !keyCodes.includes(event.keyCode))
            event.preventDefault();
    }
    //to remove the item from the shopping cart page
    deleteItem(event) {
        // to get selected pos items id and store it in a variable on click of remove icon
        let posItemName = event.target.name;
        // apex method which receives the pos items details to be deleted and send it to the backend
        deleteCartItemFromShippingCart({
            selectedCartItemDetails: JSON.stringify(posItemName),
            posItemsListWithCart: JSON.stringify(this.posItemsListInCart)
        })
            .then(result => {
                let resultGiven = result;
                const evt = new ShowToastEvent({
                    message: 'The item is removed from the cart',
                    variant: 'success',
                    // mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                return refreshApex(this.cartItemsToBeDisplayed);

            })
    }



}