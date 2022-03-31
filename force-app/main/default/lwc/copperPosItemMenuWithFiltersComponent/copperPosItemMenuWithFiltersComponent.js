//Aim --> To hold  the functionality of  search, sortby , brand and item type filters and to invoke the parent component based on custom event-->
import { LightningElement, wire, track,api } from 'lwc';
// to get the brandlist from the Apex class - CopperPosItemToCart_Apex
import getActiveBrands from '@salesforce/apex/CopperPosItemToCart_Apex.getBrands_Apex';
// to get the getActiveItemTypes from the Apex class - CopperPosItemToCart_Apex
import getActiveItemTypes from '@salesforce/apex/CopperPosItemToCart_Apex.getItemTypes_Apex';
//To check if the use has a shopping cart else create a shopping cart when user clicks place order the Apex class - CopperPosItemToCart_Apex
import createShoppingCart from '@salesforce/apex/CopperPosItemToCart_Apex.createSeasonalShoppingCart_Apex';
// To get the remove pos item to cart from the apex method "CopperPosItemToCart_Apex"
import addAllPosItemsToCart from '@salesforce/apex/CopperPosItemToCart_Apex.addAllPosItemsToCart_Apex'

export default class CopperPosItemMenuWithFiltersComponent extends LightningElement {
    //To hold the buyBookId
    @api buyBookId;
    //To display the brandlist
    @track brandListToDisplay = [];
    //To display the itemTypeList
    @track itemTypeListToDisplay = [];
    //To hold the value
    @track value = '';
    //To hold sortByvalue
    @track sortByValue = '';
    //To hold search keyword
    @track searchedKeyword;
    //to hold view type
    @track isListView = false;
    //to hold the shopping cart id
    @track shoppingcartId;
    //to hold the brand id
    @track brandId;
    //to hold the item type id
    @track itemTypeValue;
    //to hold the sort by id
    @track sortByValueId;
    //to disable or enable add all items to cart
    @track isAddAllItemsDisable = false;
    connectedCallback() {
        createShoppingCart({ selectedBuyBookId: this.buyBookId })
            .then(result => {
                this.shoppingcartId = result.Id;
            })
    }
    //wire property to get the list of active brands
    @wire(getActiveBrands)
    getActiveBrandList({ data, error }) {
        if (data) {

            this.brandListToDisplay = [{ value: '', label: 'All Brands' }];
            // for each program
            data.forEach(element => {
                const brand = {};

                brand.label = element.Brand_Name__c;

                brand.value = element.Id;

                this.brandListToDisplay.push(brand);

            });
        }
    }



    //  wire property to get the list of active item types
    @wire(getActiveItemTypes)
    getActiveItemTypeList({ data, error }) {

        if (data) {

            this.itemTypeListToDisplay = [{ value: '', label: 'All Item Types' }];
            // for each program
            data.forEach(element => {
                const itemType = {};

                itemType.label = element.Item_Type__c;

                itemType.value = element.Id;

                this.itemTypeListToDisplay.push(itemType);

            });
        }
    }
    //  To send the sort by values to the lightning combobox
    sortByValue = [
        { value: '', label: 'Select' },
        { value: 'Brand__r.Brand_Name__c', label: 'Brand' },
        { value: 'Item_Name__c', label: 'Item Name' },
        { value: 'Item_No__c', label: 'Item Number' },
        { value: 'Type_of_Item__r.Item_Type__c', label: 'Item Type' },
        { value: 'LAST_N_DAYS', label: 'Last 10 days' },
        { value: 'RECENT_ADDED_CARTITEMS', label: 'Items in cart' }
    ];

    //  Event to hold brand id and send to parent component 

    handleChangeForBrand(event) {
        this.brandValue = event.detail.value;
        this.selectedIndex = 1;

        // custom event is created here to send the selected brandid to the parent componenet
        const brandEvent = new CustomEvent('selectbrandevent', { detail: this.brandValue });
        this.dispatchEvent(brandEvent);

    }
    //  Event to hold Item Type id and send to parent component 
    handleChangeForItemType(event) {
        this.itemTypeValue = event.detail.value;
        this.selectedIndex = 1;

        // custom event is created here to send the selected item type id to the parent componenet
        const itemTypeEvent = new CustomEvent('selectitemtypeevent', { detail: this.itemTypeValue });
        this.dispatchEvent(itemTypeEvent);
    }



    //  Event to hold sort by value and send to parent component 
    handleChangeForSortBy(event) {
        this.sortByValueId = event.target.value;
        this.selectedIndex = 1;
        // custom event is created here to send the selected sort by id to the parent componenet
        const sortByEvent = new CustomEvent('selectsortbyevent', { detail: this.sortByValueId });
        this.dispatchEvent(sortByEvent);
    }


    //  To hold the user searched values
    searchPosItems(event) {
        this.searchedKeyword = event.detail.value;
        this.selectedIndex = 1;
        // custom event "sendsearchdatatoavailable" is called in the parent html. This event holds the searchKeyword
        const searchEvent = new CustomEvent('sendsearchdatatoparent', { detail: this.searchedKeyword });
        this.dispatchEvent(searchEvent);
    }



    //to display list/grid view 
    changeViewType(event) {
        let viewtype = event.target.value;

        if (viewtype == 'LIST_VIEW') {

            this.isListView = true;

        }
        else {
            this.isListView = false;

        }
        if (viewtype == 'GRID_VIEW') {

            this.isListView = false;

        }
        else {
            this.isListView = true;

        }

        // custom event is created here to send the selected value to check if its list view or grid view and then send to the parent componenet
        const viewEvent = new CustomEvent('viewitemevent', { detail: this.isListView });
        this.dispatchEvent(viewEvent);
    }

    // To add POS Item to cart
    addAllBuyBookItemsToCart(event) {
        //invoke the apex method with the paramter
        addAllPosItemsToCart({
            searchPosItemKeyword: this.searchedKeyword,
            chosenBrandId: this.brandId,
            chosenItemTypeId: this.itemTypeValue,
            sortById: this.sortByValueId,
            cartId: this.shoppingcartId,
            selectedBuyBookId: this.buyBookId
        })
            .then(result => {
                this.isAddAllItemsDisable = true;
                //to refresh the list
                const searchEvent = new CustomEvent('sendsearchdatatoparent', { detail: this.searchedKeyword });
                this.dispatchEvent(searchEvent);
            })

    }
}