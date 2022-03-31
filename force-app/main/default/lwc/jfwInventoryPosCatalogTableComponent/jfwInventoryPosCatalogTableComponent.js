// Authors: Varsha, Sanjana
// Date: 14-10-2020

import {
    LightningElement,
    wire,
    api,
    track
} from 'lwc';
//importing the method searchPOSItem from the class JFWInventoryPOSCatalog_Apex
import searchPosItem from '@salesforce/apex/JFWInventoryPOSCatalog_Apex.searchPOSItem'
// importing the noimageavailable image from the static resource
import noImage from '@salesforce/resourceUrl/noimageavailable'


export default class JfwInventoryPosCatalogTableComponent extends LightningElement {

    //to hold the list of pos items with detals
    @track posItemsListWithDetails;
    //to hold the brand Id received from the parent component
    @api getBrandId = '';
    //to hold the itemtype Id received from the parent component
    @api getItemTypeId = '';
    //to hold the search keyword value received from the parent component
    @api getSearchValue;
    //holds the image imported from static resource
    NoImageURL = noImage;
    //to check if pos items are present or not
    @track posItemsFound = false;

    //to fetch the list of pos items and its details based on the filters
    @wire(searchPosItem, {
        searchText: '$getSearchValue',
        selectedBrandId: '$getBrandId',
        selectedItemTypeId: '$getItemTypeId'
    }) posItems;

    //to hold the pos item details on page initialisation
    get getAllPosItemsdetails() {
        // console.log('init--->',JSON.stringify(this.posItems.data));
        //    check if pos item has data
        if (this.posItems.data) {
            // assign the boolean variable with the value true
            this.posItemsFound = true;
            // assign the variable posItemsListWithDetails with the data of the variable posItems
            this.posItemsListWithDetails = this.posItems.data;
            // check if the length of the variable posItemsListWithDetails is 0
            if (this.posItemsListWithDetails.length == 0) {
                // assign the the value false to the variable posItemsFound 
                this.posItemsFound = false;
            } else {
                // assign the the value true to the variable posItemsFound 
                this.posItemsFound = true;
            }
            //console.log('posItemsListWithDetails--->',JSON.stringify(this.posItemsListWithDetails));
        }
    }

}