// Author : Thanvi, Vanditha, Varsha, Sanjana
// Date : 01/10/2020 
// Aim : To hold the functionality and get the POS item List and send the add/remove item button value and get pagination details.
import {
    LightningElement,
    wire,
    api,
    track
} from 'lwc';
// To get the item list from the apex method "jfwPosItemToCart_Apex"
import getItems from '@salesforce/apex/jfwPosItemToCart_Apex.getInventoryPosItemList'
// To get the add pos item to cart from the apex method "jfwPosItemToCart_Apex"
import addItemToCart from '@salesforce/apex/jfwPosItemToCart_Apex.addInventoryPosItemToCart'
// To get the remove pos item to cart from the apex method "jfwPosItemToCart_Apex"
import removeItemFromCart from '@salesforce/apex/jfwPosItemToCart_Apex.removeInventoryPosItemFromCart'
// To get the show Toast Event from the apex method
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
// To get the JFW logo resoruce URl 
import JFWLogo from '@salesforce/resourceUrl/noimageavailable';
// Import method to refresh the apex class
import {
    refreshApex
} from '@salesforce/apex';
//FORM Factor
import FORM_FACTOR from '@salesforce/client/formFactor';
export default class JfwPosItemMenuAddOrRemoveItems extends LightningElement {

    //To hold the brandId
    @api getBrandId = '';
    // To hold item type id
    @api getItemTypeId = '';
    // To hold sortbyid
    @api getSortBy = '';
    // To hold search value
    @api getSearchValue;
    //To hold the data obtained from the server
    @track posItemListWrapper;
    //To hold the positem details for the display
    @track posItemDetails;
    //To hold the pos item id to be added
    @track addPosItemId;
    //To set the value from front end when adding an item
    @track itemIsAdded;
    //To hold the pos item id to be removed
    @track removePosItemId;
    //To set the value from front end when removing an item
    @track itemIsRemoved;

    // for pagination
    // to hold the size for pagination
    @track totalPosItemSize;
    //to hold navigation items size
    @track totalNavigationItems;
    // to hold the naviagtion items
    @track navigationItems;
    //to hold the start index
    @track startIndex = 1;
    // to hold last index
    @track lastIndex = 5;
    //to hold the selected Index
    @track selectedIndex = 1;
    //to hold last navigation idex
    @track lastNavigationIndex;
    //to hold record start index
    @api recordStartIndex = 0;
    //to hold the record last index
    @track recordLastIndex;
    //to detremine if the lastnavigation button should be disabled or not
    @track isItLastNavigationItem = false;
    //to detremine if the firstnavigation button should be disabled or not
    @track isItFirstNavigationItem = false;
    // it is an boolean variable to check if the pos item has  data or not
    @track posItemsFound = false;
    //to hold view type value
    @api isListView = false;
    //To hold if the spinner should appear or not
    @track showSpinner;
    //To send the jfw image logo 
    jfwNoImage = JFWLogo;
    //to hold if the resolution is destktop or tablet
    @track isDesktopView;

    // init method to display the record start index and selected index value from child componenet
    @api
    doInit() {
        this.recordStartIndex = 0;
        this.selectedIndex = 1;
        this.startIndex = 1;
        this.lastIndex = 5;
        /**Authors : Varsha Thanvi Ponamma;Date:15-04-2021;
       * Aim: To if it is laptop or desktop resolution
       */
         if(FORM_FACTOR == 'Large'){
            this.isDesktopView = true;
        }
        else {
            this.isDesktopView = false;
        }
    }

    // The @wire method to get the pos items from the apex method by passing the parameter
    @wire(getItems, {
        searchedPosItem: '$getSearchValue',
        chosenBrandId: '$getBrandId',
        chosenItemTypeId: '$getItemTypeId',
        sortById: '$getSortBy',
        recordStartIndex: '$recordStartIndex'
    })
    getPosItems;

    //To get the pos items to be displayed
    get posItemsData() {
        //  Check if the get pos item data from the @wire method "getPosItems"
        if (this.getPosItems.data) {
            this.showSpinner = true;
            // console.log('the list of pos items', JSON.stringify(this.getPosItems.data))
            //to set the value to true
            this.posItemsFound = true;
            //to hold the data obtained from the backend
            this.posItemListWrapper = this.getPosItems.data;
            //responsible for diplay the pos item details
            this.posItemDetails = this.posItemListWrapper.PosItemDetails;
            //to capture the total number of pos items
            this.totalPosItemSize = this.posItemListWrapper.totalPosItemsSize;
            //to capture size of pos items in cart
            let cartItemSize = this.posItemListWrapper.totalCartItemsSize;
            //to send the cart size to parent, in order to display the value under view cart button
            const cartSize = new CustomEvent('cartitemsize', {
                detail: cartItemSize
            });
            this.dispatchEvent(cartSize);
            // to check if the posItemDetails variable contains data or not if yes display the table
            if (this.posItemDetails.length == 0) {
                this.posItemsFound = false;
            }

            // to check if the posItemDetails variable contains data or not if no display error message
            else {
                this.posItemsFound = true;
            }

            // If the pos item exists, then call the pagination method
            if (this.totalPosItemSize) {

                this.setNavigationItems(this.startIndex, this.lastIndex);
            }

        }
        this.showSpinner = false;
        refreshApex(this.getPosItems);
    }

    // To add POS Item to cart
    addItemToCartEvent(event) {
        this.showSpinner = true;
        //capture the addPosItem item value when the 'add to cart' button is clicked
        this.addPosItemId = event.target.dataset.id;
        //invoke the apex method with the paramter
        addItemToCart({
                selectedPosItemId: this.addPosItemId
            })
            .then(result => {
                this.itemIsAdded = result;
                // the pos item list needs to obtained from the server afer it is added to cart and a toast message should be displayed to the user
                if (this.itemIsAdded == 'done') {
                    const evt = new ShowToastEvent({
                        title: 'Item Is Added',
                        message: 'Item is added to cart',
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);
                    refreshApex(this.getPosItems);
                }

            })
            .catch(error => {
                this.error = error;
            });
    }


    // Remove item from cart
    removeItemToCartEvent(event) {
        this.showSpinner = true;
        this.removePosItemId = event.target.dataset.id;
        removeItemFromCart({
                selectedPosItemId: this.removePosItemId
            })
            .then(result => {
                this.itemIsRemoved = result;
                // the pos item list needs to obtained from the server ater it is removed from cart
                if (this.itemIsRemoved == 'done') {
                    const evt = new ShowToastEvent({
                        title: 'Item Removed',
                        message: 'Item is removed from the cart',
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);
                    refreshApex(this.getPosItems);
                    this.showSpinner = false;
                }


            })
            .catch(error => {
                this.error = error;
            });

    }


    //To set values for pagination
    setNavigationItems(startnumber, lastnumber) {
        this.totalNavigationItems = Math.ceil(this.totalPosItemSize / 12);
        let navigationItemList = [];
        for (let i = startnumber; i <= lastnumber; i++) {
            let recordStartIndex = (i - 1) * 12;
            let recordLastIndex = recordStartIndex + 11;
            let navigationItem = {
                "index": i,
                "recordStartIndex": recordStartIndex,
                "recordLastIndex": recordLastIndex,
                "isRecordExisted": i <= this.totalNavigationItems,
                "isIndexSelected": i == this.selectedIndex
            };
            navigationItemList.push(navigationItem);
        }
        if (navigationItemList.length != 0) {
            let lastNavigationIndex = navigationItemList[navigationItemList.length - 1].index;
            if (lastNavigationIndex == this.totalNavigationItems || lastNavigationIndex > this.totalNavigationItems) {
                this.isItLastNavigationItem = true;
            } else {
                this.isItLastNavigationItem = false;
            }
            if (navigationItemList[0].index == 1) {
                this.isItFirstNavigationItem = true;
            } else {
                this.isItFirstNavigationItem = false;
            }
        }
        // console.log(JSON.stringify(navigationItemList));
        this.navigationItems = navigationItemList;
    }


    //To call set navigation method by passing  first number ,last number and the selected index 
    firstNavigationButton() {
        this.startIndex = 1;
        this.lastIndex = 5;
        this.selectedIndex = 1;
        this.recordStartIndex = 0;
        return refreshApex(this.getPosItems);
    }

    //to navigate to the previous page if it is available
    previousNavigationButton() {
        if (this.navigationItems[0].recordStartIndex > 0) {
            this.startIndex = this.navigationItems[0].index - 5;
            this.lastIndex = this.startIndex + 4;
            this.selectedIndex = this.navigationItems[0].index - 5;
            this.recordStartIndex = this.navigationItems[0].recordStartIndex - 60;
            return refreshApex(this.getPosItems);
        } else {
            this.isItFirstNavigationItem = true;
        }
    }


    //On click buttton to navigate to next page if it is available 
    nextNavigationButton() {
        if (this.navigationItems[4].isRecordExisted == true) {
            this.startIndex = this.navigationItems[0].index + 5;
            this.lastIndex = this.startIndex + 4;
            this.selectedIndex = this.navigationItems[4].index + 1;
            this.recordStartIndex = this.navigationItems[4].recordLastIndex + 1;
            return refreshApex(this.getPosItems);
        }
    }

    //on click of this button to naviagte to the last paginated navigation from any page ,if exist
    lastNavigationButton() {
        this.lastIndex = Math.ceil(Math.ceil(this.totalPosItemSize / 12) / 5) * 5;
        this.startIndex = this.lastIndex - 4;
        this.recordStartIndex =(this.startIndex - 1) * 12;
        this.selectedIndex = this.lastIndex - 4;
        return refreshApex(this.getPosItems);
    }

    //To hold the selected page number and invoke the getPosItems 
    getPosItemsByIndex(event) {
        let selectedPageNumber = event.target.value;
        this.selectedIndex = selectedPageNumber.index;
        this.recordStartIndex = selectedPageNumber.recordStartIndex;
        return refreshApex(this.getPosItems)

    }

}