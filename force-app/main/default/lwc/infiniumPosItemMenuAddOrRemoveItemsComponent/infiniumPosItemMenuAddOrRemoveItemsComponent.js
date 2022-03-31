//  Author:Thanvi;Date:20-SEP-2021
// Aim : To hold the functionality and get the POS item List and send the add/remove item button value and get pagination details.
import {LightningElement,wire,api,track} from 'lwc';
// To get the item list from the apex method "InfiniumPosItemToCart_Apex"
import getProgramItems from '@salesforce/apex/InfiniumPosItemToCart_Apex.getPosItems_Apex'
// To get the add pos item to cart from the apex method "InfiniumPosItemToCart_Apex"
import addItemToCart from '@salesforce/apex/InfiniumPosItemToCart_Apex.addPosItemToCart_Apex'
// To get the remove pos item to cart from the apex method "InfiniumPosItemToCart_Apex"
import removeItemFromCart from '@salesforce/apex/InfiniumPosItemToCart_Apex.removePosItemFromCart_Apex'
// To get the show Toast Event from the apex method
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
// To get the WDW logo resoruce URl 
import NoImageAvailable from '@salesforce/resourceUrl/noimageavailable';
// Import method to refresh the apex class
import {refreshApex} from '@salesforce/apex';


export default class InfiniumPosItemMenuAddOrRemoveItemsComponent extends LightningElement {
    //To hold the programId
    @api programId;
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
    //To set the value from front end when adding an item
    @track itemIsAdded;
    //To set the value from front end when removing an item
    @track itemIsRemoved;

    // for pagination
    // to hold the size for pagination
    @track totalPosItemSize=0;
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
    //To send the no image  
    noImage = NoImageAvailable;

    // init method to display the record start index and selected index value from child componenet
    @api
    doInit() {
        this.recordStartIndex = 0;
        this.selectedIndex = 1;
        this.startIndex = 1;
        this.lastIndex = 5;
    }

    // The @wire method to get the pos items from the apex method by passing the parameter
    @wire(getProgramItems, {
        searchPosItemKeyword: '$getSearchValue',
        chosenBrandId: '$getBrandId',
        chosenItemTypeId: '$getItemTypeId',
        sortById: '$getSortBy',
        selectedProgramId: '$programId',
        recordStartIndex: '$recordStartIndex'
    })
    getPosItems;

    //To get the pos items to be displayed
    get posItemsData() {
        //  Check if the get pos item data from the @wire method "getPosItems"
        if (this.getPosItems.data) {
            this.showSpinner = true;
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
console.log('count',this.totalPosItemSize)

              // If the pos item exists, then call the pagination method
              if (this.totalPosItemSize>0) {
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
        let addPosItemId = event.target.dataset.id;
        let posItemDetail = event.target.name;
        //invoke the apex method with the paramter
        addItemToCart({
            posItemId: addPosItemId,
            selectedProgramId: this.programId
        })
            .then(result => {
                this.itemIsAdded = result;
                // the pos item list needs to obtained from the server afer it is added to cart and a toast message should be displayed to the user
                if (this.itemIsAdded == 'done') {

                    const evt = new ShowToastEvent({
                        message: 'The "' + posItemDetail.posItem.Item_Name__c + '" item is added to cart.',
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
        let removePosItemId = event.target.dataset.id;
        let posItemDetail = event.target.name;
        removeItemFromCart({
            posItemId: removePosItemId,
            selectedProgramId: this.programId
        })
            .then(result => {
                this.itemIsRemoved = result;
                // the pos item list needs to obtained from the server ater it is removed from cart
                if (this.itemIsRemoved == 'done') {
                    const evt = new ShowToastEvent({
                        message: 'The "' + posItemDetail.posItem.Item_Name__c + '" item is removed from the cart',
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
        console.log('hi')
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
        this.recordStartIndex = (this.startIndex - 1) * 12;
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