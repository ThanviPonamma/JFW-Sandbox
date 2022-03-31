// Authors:Sanjana    Date:08-11-2021
// to ge the pos item details from the apex method and display in the page and to send the pos items qunatity entered and if the user wants to delete the pos item
import { LightningElement,wire,track,api} from 'lwc';
// to ge the cart item list from the apex method 'getCartItemsList' of class 'InfiniumInventoryShoppingCart_Apex'
import getCartItemsList from '@salesforce/apex/InfiniumInventoryShoppingCart_Apex.getCartItemsList'
// to ge the updated quantity for the selected pos items from the apex method 'updateQuantityForSelectedItem' of class 'InfiniumInventoryShoppingCart_Apex'
import updateQuantityForSelectedPosItem from '@salesforce/apex/InfiniumInventoryShoppingCart_Apex.updateQuantityForSelectedItem'
// to send the pos items to the apex method 'deleteCartItemFromShippingCart' of the class 'InfiniumInventoryShoppingCart_Apex' if user wants to delete the items
import deleteCartItemFromShippingCart from '@salesforce/apex/InfiniumInventoryShoppingCart_Apex.deleteCartItemFromShippingCart'
//  to get the shipping method to the dropdown
import getShippingMethodList from '@salesforce/apex/InfiniumInventoryShoppingCart_Apex.getShippingMethodList'
// to refresh the apex page whenever any changes hapeens in the componenet
import {refreshApex} from '@salesforce/apex';
// to display toast message to the users
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
// to show the get the 'No image' image from the static resource
import InfiniumNoImage from '@salesforce/resourceUrl/noimageavailable';
// to send add same address to all to apex method
import getSelectedUserAddressBookListForAllItems from '@salesforce/apex/InfiniumInventoryShoppingCart_Apex.getSelectedUserAddressBookListForAllItems'
// to send the selected pos items to apex method
import getSelectedAddressesForPosItem from '@salesforce/apex/InfiniumInventoryShoppingCart_Apex.getSelectedAddressesForPosItem'
// To check if the address is domastic or international
import getUserDetails from '@salesforce/apex/InfiniumInventoryShoppingCart_Apex.getUserDetails'

export default class InfiniumInventoryShoppingCartItemDetailsComponent extends LightningElement {
    
    //to hold the list of  all pos items in cart
    @track posItemsListInCart = [];
    //variable to store the JSON parse covert of 'posItemsListInCart' variable
    @api cartItems;
    // to hold selcted pos item id for the shipping address
    @api posCartItemDetails = [];
    // to send the selected address to child component
    @api selectedAddressForPosItems;
    //to hold the modal status value
    @track isModalOpen = false;
    //to hold boolean value on click of the add address buttons
    @api isAddAllAddresses;
    //to hold order Id
    @api orderId;
    //to hold pos item Id
    @track posItemId;
    //to hold shipping address Id
    @track shippingAddressId;
    //to hold the list of shipping methods
    @api shippingMethodListToDisplay;
    @track quantityUpdateValue = 0;
    //to hold boolean value to disable the preview button
    @track disablePreview;
    @track totalQuantity = 0;
    //to check if the positems in cart exists
    @track isAddressAvailableForDisplay;
    // to send the user details to child component
    @api user;

    // the variable to store the no image given from static resource
    infiniumNoImage = InfiniumNoImage;

    //to hold the list of pos items in cart along with the details
    @wire(getCartItemsList) cartItemsToBeDisplayed;


    @wire(getUserDetails) userAddressDetails;
    
    /**Authors: Thanvi, sanjana Date: 05/10/2020 CR No: JFW-28-Dec-03
     * The below code is commented to meet the requirements of the CR
     * To check if the item type name in cart is COUPON, if yes the quantity is editable only for the states the item is valid for.

        //to get cart items on page inialisation
        get cartItemDetails() {

        // To check if the address is domastic of international
        if (this.userAddressDetails.data) {   

            this.user = this.userAddressDetails.data;
           
        }

        // To get the pos items in cart to display
            if (this.cartItemsToBeDisplayed.data) {   
                console.log('cartItemsToBeDisplayed-->',JSON.stringify(this.cartItemsToBeDisplayed.data))     
                this.posItemsListInCart = this.cartItemsToBeDisplayed.data;
               
                
                //To check if the given pos item has the data or not 
                if(this.posItemsListInCart.length>0){
                    this.isAddressAvailableForDisplay=true;
                }
                else
                {
                    this.isAddressAvailableForDisplay = false;
                }
                // to assign the total quanity to zero by default
                this.totalQuantity = 0;
                // if total quntity is 0 then disable the preview button
                this.disablePreview = true;

                // get the totalquantity for each shopping cart pos items and store it in the cariable
                for (let i = 0; i < this.posItemsListInCart.length; i++) {
                    this.totalQuantity += this.posItemsListInCart[i].totalQuantityFromAllAddresses;

                }
                // if quntity is > 0 then enable the repview button
                if (this.totalQuantity > 0) {
                    this.disablePreview = false;

                    // if quntity is = 0 then the repview button is disabled with the help of the variable "disablePreview"
                } else if (this.totalQuantity == 0) {
                    this.disablePreview = true;
                }

                // local variable to convert the pos items in cart to json parse so that anyone can edit the incoming items
                var posItemsListWithCart = JSON.parse(JSON.stringify(this.posItemsListInCart))
                //to check if the entred quantity has exceed initally
                for (var i = 0; i < posItemsListWithCart.length; i++) {
                    var individualQty = 0;
                    //local variable to store thhe logical inventory stock
                    var currentAvailableStock = posItemsListWithCart[i].posItem.Logical_Invenory_Stock__c;
                    // to check if any item in cart has a quanity entred greater than available stock
                    for (var j = 0; j < posItemsListWithCart[i].selectedAddressWithQtyDetails.length; j++) {
                        var quantity = posItemsListWithCart[i].selectedAddressWithQtyDetails[j].quantity == '' ? 0 : posItemsListWithCart[i].selectedAddressWithQtyDetails[j].quantity;
                        individualQty = parseInt(individualQty) + parseInt(quantity);
                        posItemsListWithCart[i].selectedAddressWithQtyDetails[j].quantity = parseInt(quantity);
                    }
                    posItemsListWithCart[i].totalQuantityFromAllAddresses = individualQty;
                    //if exceded then disable the preview button
                    //to display error message
                    if (posItemsListWithCart[i].totalQuantityFromAllAddresses <= currentAvailableStock) {
                        posItemsListWithCart[i].isAvailableQuantityExceeded = false;
                     
                    } else {
                        posItemsListWithCart[i].isAvailableQuantityExceeded = true;
                        this.disablePreview = true;
                    
                    }

                }
                this.posItemsListInCart = posItemsListWithCart;
                this.cartItemsToBeDisplayed.data = posItemsListWithCart;
              
                if (this.posItemsListInCart.length > 0) {
                    if (this.posItemsListInCart[0].orderId) {
                        this.orderId = this.posItemsListInCart[0].orderId;
                    }
                }
            }  
            refreshApex(this.cartItemsToBeDisplayed);
        }*/
        /**Authors: Thanvi, sanjana Date: 05/10/2020 CR No: JFW-28-Dec-03
     * The below code is added to meet the requirements of the CR
     * To check if the item type name in cart is COUPON, if yes the quantity is editable only for the states the item is valid for.*/
    //to get cart items on page inialisation
    get cartItemDetails() {

        // To check if the address is domastic of international
        if (this.userAddressDetails.data) {

            this.user = this.userAddressDetails.data;

        }

        // To get the pos items in cart to display
        if (this.cartItemsToBeDisplayed.data) {
            this.posItemsListInCart = this.cartItemsToBeDisplayed.data;
            // console.log('posItemsListInCart---->',JSON.stringify(this.posItemsListInCart));
            //To check if the given pos item has the data or not 
            if (this.posItemsListInCart.length > 0) {
                this.isAddressAvailableForDisplay = true;
            } else {
                this.isAddressAvailableForDisplay = false;
            }
            // to assign the total quanity to zero by default
            this.totalQuantity = 0;
            // if total quntity is 0 then disable the preview button
            this.disablePreview = true;
            // local variable to convert the pos items in cart to json parse so that anyone can edit the incoming items
            var posItemsListWithCart = JSON.parse(JSON.stringify(this.posItemsListInCart));
            var isAvailableQuantityExceeded = false;
            //to check if the entred quantity has exceed initally
            for (var i = 0; i < posItemsListWithCart.length; i++) {
                this.totalQuantity += this.posItemsListInCart[i].totalQuantityFromAllAddresses;
                var individualQty = 0;
                //local variable to store thhe logical inventory stock
                var currentAvailableStock = posItemsListWithCart[i].posItem.Logical_Invenory_Stock__c;
                // to check if any item in cart has a quanity entred greater than available stock
                for (var j = 0; j < posItemsListWithCart[i].selectedAddressWithQtyDetails.length; j++) {
                    var quantity = posItemsListWithCart[i].selectedAddressWithQtyDetails[j].quantity == '' ? 0 : posItemsListWithCart[i].selectedAddressWithQtyDetails[j].quantity;
                    individualQty = parseInt(individualQty) + parseInt(quantity);
                    posItemsListWithCart[i].selectedAddressWithQtyDetails[j].quantity = parseInt(quantity);
                }
                posItemsListWithCart[i].totalQuantityFromAllAddresses = individualQty;
                //if exceded then disable the preview button
                //to display error message
                if (posItemsListWithCart[i].totalQuantityFromAllAddresses <= currentAvailableStock ) {
                    posItemsListWithCart[i].isAvailableQuantityExceeded = false;

                } else {
                    posItemsListWithCart[i].isAvailableQuantityExceeded = true;
                    isAvailableQuantityExceeded = true;

                }

            }
            this.posItemsListInCart = posItemsListWithCart;
            this.cartItemsToBeDisplayed.data = posItemsListWithCart;
            // if quntity is > 0 then enable the repview button
            if (this.totalQuantity > 0 ) {
                this.disablePreview = false;
            }
                // if quntity is = 0 then the repview button is disabled with the help of the variable "disablePreview"
            if (this.totalQuantity == 0 || isAvailableQuantityExceeded) {
                this.disablePreview = true;
            }
            if (this.posItemsListInCart.length > 0) {
                if (this.posItemsListInCart[0].orderId) {
                    this.orderId = this.posItemsListInCart[0].orderId;
                }
            }
             /**Authors: Thanvi, sanjana Date: 05/10/2020 CR No: JFW-28-Dec-03
            * The below code is added to meet the requirements of the CR
            * To check if the item type name in cart is COUPON, if yes the quantity is editable only for the states the item is valid for. item type name is not coupoun then doesnt check for valid states**/

            for (var i = 0; i < posItemsListWithCart.length; i++) {
                //Check if the item type name is coupon
                if(posItemsListWithCart[i].posItem.Type_of_Item__r.Item_Type__c.toUpperCase() == 'COUPON'){
                    //to check if the state list of the pos item and the address selected are same
                    for (var k=0; k<posItemsListWithCart[i].posItemStateList.length; k++){
                        for (var j = 0; j <posItemsListWithCart[i].selectedAddressWithQtyDetails.length; j++) {
                            // if yes then the quantity is editable
                            if(posItemsListWithCart[i].posItemStateList[k].State__c == posItemsListWithCart[i].selectedAddressWithQtyDetails[j].selectedAddress.State__c){
                                posItemsListWithCart[i].selectedAddressWithQtyDetails[j].isQuantityEditable = true;
                            }
                        }
                    }
                    
                }
                //If the item type name is not coupon then the quantity field should be editable
                else{
                    for (var j = 0; j <posItemsListWithCart[i].selectedAddressWithQtyDetails.length; j++) {
                        posItemsListWithCart[i].selectedAddressWithQtyDetails[j].isQuantityEditable = true;
                    }
                }

            }
            /** Authors: Thanvi, sanjana Date: 05/10/2020 CR No: JFW-28-Dec-03
            * The below line is added to display the Alert message on exceeding the max order qty*/
            this.displayAlertMessage(posItemsListWithCart);
            
        }
        refreshApex(this.cartItemsToBeDisplayed);
    }
    /** Authors: Thanvi, sanjana Date: 05/10/2020 CR No: JFW-28-Dec-03
     * The below line is added to display the Alert message on exceeding the max order qty*/
    displayAlertMessage(cartItems){
        //To loop through all the items in cart
        for (var i = 0; i < cartItems.length; i++) {
            //to get the each shipping details for the i'th pos item
            for (var j = 0; j <cartItems[i].selectedAddressWithQtyDetails.length; j++){
                //to set the value to fasle
                cartItems[i].selectedAddressWithQtyDetails[j].isMaxOrderQtyExceeded = false;
                //to check if the quantity exceeds
                if(cartItems[i].selectedAddressWithQtyDetails[j].quantity > cartItems[i].posItem.Maximum_Order_Qty__c){
                    //to set the value to true
                    cartItems[i].selectedAddressWithQtyDetails[j].isMaxOrderQtyExceeded = true;
                }
            } 
        }
    }
    //to fetch shipping method details on page initialisation
    @wire(getShippingMethodList)
    getShippingMethodList({
        data,
        error
    }) {
        if (data) {
            this.shippingMethodListToDisplay = data;

        } else if (error) {
          
        }
    }


    //to set the isModalOpen to true, isAddAllAddresses to true and send the cartitems detsils  on click of 'add same address for all' button 
    //these details are sent to child component '-jfw-shopping-cart-address-modal-component'
    addSameAddressForAllItems() {
        this.cartItems = JSON.parse(JSON.stringify(this.posItemsListInCart));

        getSelectedUserAddressBookListForAllItems({
                posItemsListWithCart: JSON.stringify(this.cartItems)
            })
            .then(result => {
                this.selectedAddressForPosItems = result;
                this.isModalOpen = true;
                this.isAddAllAddresses = true;

            });
    }


    //to set the isModalOpen to true and isAddAllAddresses to false on click of 'shipping address' button
    openShippingAddressModal(event) {
        this.posCartItemDetails = event.target.value;

        getSelectedAddressesForPosItem({
                selectedPosItemDetails: JSON.stringify(this.posCartItemDetails)
            })
            .then(result => {
                this.selectedAddressForPosItems = result;
                this.isModalOpen = true;
                this.isAddAllAddresses = false;

            });
    }


    //invoke on 'close' modal button
    closeModal() {
        this.isModalOpen = false;
        refreshApex(this.cartItemsToBeDisplayed);
    }


    //responsible to call preview page on click of 'preview' button
    openPreviewPage() {

        const sendToParent = new CustomEvent('callpreviewcomponent', {
            detail: this.orderId
        });
        this.dispatchEvent(sendToParent);
    }

    // to upadte the pos items quntity after selected the address
    updateQuantity(event) {
        this.shippingAddressId = event.target.dataset.id;
        this.posItemId = event.target.dataset.pos;
        this.quantityUpdateValue = event.target.value;
        this.orderId = event.target.dataset.order;
        var posItemsListWithCart = JSON.parse(JSON.stringify(this.posItemsListInCart))
       
        for (var i = 0; i < posItemsListWithCart.length; i++) {
            var individualQty = 0;
            var currentAvailableStock = posItemsListWithCart[i].posItem.Logical_Invenory_Stock__c;
            for (var j = 0; j < posItemsListWithCart[i].selectedAddressWithQtyDetails.length; j++) {
                if (this.shippingAddressId == posItemsListWithCart[i].selectedAddressWithQtyDetails[j].selectedAddress.Id) {
                    let quantityTobeUpdated = event.target.value;
                    this.quantityUpdateValue = quantityTobeUpdated == '' ? 0 : quantityTobeUpdated;
                    posItemsListWithCart[i].selectedAddressWithQtyDetails[j].quantity = this.quantityUpdateValue;

                }
                // after getting the qunity to calculate the totla quntity
                var quantity = posItemsListWithCart[i].selectedAddressWithQtyDetails[j].quantity == '' ? 0 : posItemsListWithCart[i].selectedAddressWithQtyDetails[j].quantity;

                individualQty = parseInt(individualQty) + parseInt(quantity);

                posItemsListWithCart[i].selectedAddressWithQtyDetails[j].quantity = parseInt(quantity);
            }
            posItemsListWithCart[i].totalQuantityFromAllAddresses = individualQty;
            // to check if the total quntity is less than current available stock
            if (posItemsListWithCart[i].totalQuantityFromAllAddresses <= currentAvailableStock) {
                posItemsListWithCart[i].isAvailableQuantityExceeded = false;

            } else {
                posItemsListWithCart[i].isAvailableQuantityExceeded = true;
                this.disablePreview = true;

            }

        }

        this.posItemsListInCart = posItemsListWithCart;
        // to send the updated quntity ot the apex method "updateQuantityForSelectedPosItem" with the parameter positemid,shipping address id and order id and quntity added.
        updateQuantityForSelectedPosItem({
                posItemId: this.posItemId,
                shippingAddressId: this.shippingAddressId,
                orderId: this.orderId,
                quantity: this.quantityUpdateValue
            })
            .then(result => {
                // once the quntity is sent to the apex method the result should be sent as 'done'
                let resultObtained = result;
                return refreshApex(this.cartItemsToBeDisplayed);
            })
            .catch(error => {
                this.error = error;
                // console.log('ERROR', this.error);
            });
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
            .catch(error => {
                this.error = error;
                // console.log('ERROR', this.error);
            });
    }

}