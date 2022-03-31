//Author : Sanjana; Date : 21-09-2021


// Aim:To hold the functionalities of create , edit buttons and display the contents.

import { LightningElement, wire, track, api } from 'lwc';
// to import the pos item list from the apex class "InfiniumManagePosItems_Apex" with the method "getPOSItemList"
import searchPOSItem from '@salesforce/apex/InfiniumManagePosItems_Apex.searchPOSItem_Apex'
// to import the list of brand from the apex class "InfiniumManagePosItems_Apex" with the method "getBrandList_Apex"
import getBrandList from '@salesforce/apex/InfiniumManagePosItems_Apex.getBrandList_Apex'
// to import the list of item type from the apex class "InfiniumManagePosItems_Apex" with the method "getItemTypeList_Apex"
import getItemTypeList from '@salesforce/apex/InfiniumManagePosItems_Apex.getItemTypeList_Apex'
import deactivateSelectedItem from '@salesforce/apex/InfiniumManagePosItems_Apex.deactivateSelectedItem'
// to display no image
import noImage from '@salesforce/resourceUrl/noimageavailable';

// Import method refresh the page
import { refreshApex } from '@salesforce/apex';

//to display Toast Message
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class InfiniumManagePosItemListComponent extends LightningElement {
  //to hold the pos item deatils from apex
  @track posItemListData;
  //to hold the pos items to be displayed 
  @track posItems;
  //to hold the item names
  @api posItemsWithValidation;
  //to hold all the stock numbers
  @api posItemStockNumberValidation;
  //to open or close the pop-up modal
  @track isOpenModal;
  //to display brands under drop down
  @api brandListToDisplay;
  //to display item types under drop down
  @api itemTypeListToDisplay;
  //to hold searckey word
  @api searchedKeyword = '';
  //to hold the selected brand id
  @track selectedBrandId = '';
  //to hold the selected item type id
  @track selectedItemTypeId = '';
  //to hold the po item details to be sent to the pop up
  @api editedPosItemData;
  //To check if the edit button is clicked
  @api isEditClicked;
  //To hold the label of a pos item 
  @api labelName;
  //to check if pos item details exist or not
  @track posItemFound = false;

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

  // no image variable
  NoImageURL = noImage;

  @wire(searchPOSItem, {
    searchText: '$searchedKeyword',
    selectedBrand: '$selectedBrandId',
    selectedItemType: '$selectedItemTypeId',
    recordStartIndex: '$recordStartIndex'
  }) posItemListToBeDisplayed;

  // get method which acts as the init method on page load
  get posItemList() {
    if (this.posItemListToBeDisplayed.data) {
      this.posItemListData = this.posItemListToBeDisplayed.data;
      //console.log(' this.posItemListData--->', JSON.stringify(this.posItemListData))
      this.posItems = this.posItemListData.posItemList;
      this.posItemsWithValidation = this.posItemListData.posItemNamesForValidation;
      this.posItemStockNumberValidation = this.posItemListData.posItemStockNumbersForValidation;
      //to capture the total number of pos items
      this.totalPosItemSize = this.posItemListData.totalPosItemsSize;
      if (this.posItems.length == 0) {
        this.posItemFound = false;
      }
      else {
        this.posItemFound = true;
      }
      // If the pos item exists, then call the pagination method
      if (this.totalPosItemSize) {
console.log('inside');
        this.setNavigationItems(this.startIndex, this.lastIndex);
      }
      refreshApex(this.posItemListToBeDisplayed);

    }
  }

  // to open the popup modal on click of edit button and send the selected pos item details
  openEditPosItemModal(event) {
    //to capture the pos item deatils of the selected item
    let selectedPosItems = event.target.name;
    //to send the pos item value to the chils
    this.editedPosItemData = selectedPosItems;
    //to open the pop up
    this.isOpenModal = true;
    //to check if its edit/create button clicked
    this.isEditClicked = true;
    //to capture the item name and assign to the label
    this.labelName = selectedPosItems.posItemList.Item_Name__c;
    // console.log('editedPosItemData in parent',JSON.stringify(this.editedPosItemData));
  }


  //To open the create modal popup
  openCreateModal() {
    let temp = {
      "posItemImageURL": "",
      "posItemList": {
        "Item_No__c": '',
        "Attachment_Id__c": '',
        "Brand__c": '',
        "Type_of_Item__c": '',
        "Pack_Of__c": 1,
        "Price__c": 0,
        "Item_Name__c": '',
        "Approval_Required__c": false,
        "ExpirationDateRequired__c": false,
        "LotNumberRequired__c": false,
        "Account__c": '',
        "Active__c": true,
        "Length__c": 0.001,
        "Width__c": 0.001,
        "Height__c": 0.001,
        "Weight__c": 0.001,
        "Item_Descrption__c": '',
        "Low_inventory_level_applicable__c": false,
        "Maximum_order_quantity_applicable__c": false,
        "Marketing_Only__c": false,
        "Inventory_Seasonal_Program__c": 'Both',
        "Brand__r": {
          "Brand_Name__c": '',
          "Id": '',
        },
        "Type_of_Item__r": {
          "Item_Type__c": '',
          "Id": ''
        }
      }
    }
    this.editedPosItemData = temp;
    this.isOpenModal = true;
    this.isEditClicked = false;
    this.labelName = '';
  }

  //To close the create/edit modal
  closeModal(event) {
    this.isOpenModal = event.detail.modalopen;
    return refreshApex(this.posItemListToBeDisplayed);
  }

  //to get the data from 'getBrandList' to display under the drop dowm
  @wire(getBrandList)
  loadBrandList({ data, error }) {
    // If the getBrandList has data
    if (data) {
      // get the value and lable for each brand in the program list
      this.brandListToDisplay = [{ value: '', label: 'All Brands' }];
      // for each brand
      data.forEach(element => {
        const brand = {};
        //set brand name to the lable property
        brand.label = element.Brand_Name__c;
        // Set the brand id to the value property
        brand.value = element.Id;
        // push the brand data to "brandList" property
        this.brandListToDisplay.push(brand);
      });
    }
    //To handle the error
    else if (error) {
    }
  }
  //to capture the brand id end it to the parameter in init method
  handleChangeForBrand(event) {
    this.recordStartIndex = 0;
    this.selectedIndex = 1;
    this.startIndex = 1;
    this.lastIndex = 5;
    this.selectedBrandId = event.target.value;

  }
  //to capture the item type id end it to the parameter in init method
  handleChangeForItemType(event) {
    this.recordStartIndex = 0;
    this.selectedIndex = 1;
    this.startIndex = 1;
    this.lastIndex = 5;
    this.selectedItemTypeId = event.target.value;
  }


  //to get the data from 'getItemTypeList' 
  @wire(getItemTypeList)
  loadItemTypeList({ data, error }) {
    // If the getBrandList has data
    if (data) {
      // get the value and lable for each itemType in the program list
      this.itemTypeListToDisplay = [{ value: '', label: 'All Item Types' }];
      // for each itemType
      data.forEach(element => {
        const itemType = {};
        //set itemType name to the lable property
        itemType.label = element.Item_Type__c;
        // Set the itemType id to the value property
        itemType.value = element.Id;
        // push the itemType data to "itemTypeList" property
        this.itemTypeListToDisplay.push(itemType);
      });
    }
  }

  //To deactivate the pos item
  deactivatePosItem(event) {
    // to hold the deactivate pos item details
    let deactivatedPosItem = event.target.name;
    //to hold pos item name for the toast message
    let deactivatedPosItemForToast = deactivatedPosItem.Item_Name__c;
    deactivateSelectedItem({
      posItem: deactivatedPosItem,
    })
      .then(result => {
        let resultGiven = result;
        //to display a toast message to the user
        if (resultGiven == "done") {
          const evt = new ShowToastEvent({
            message: 'The POS item "' + deactivatedPosItemForToast + '" has been deactivated successfully.',
            variant: 'success',
          });
          this.dispatchEvent(evt);
        }
        //to refresh the list.
        return refreshApex(this.posItemListToBeDisplayed);
      })
  }
  //to capture the searched value and send it to the parameter in init method
  handlePOSItemSearchFilter(event) {
    this.recordStartIndex = 0;
        this.selectedIndex = 1;
        this.startIndex = 1;
        this.lastIndex = 5;
    this.searchedKeyword = event.target.value;
  }

  //To set values for pagination
  setNavigationItems(startnumber, lastnumber) {
    this.totalNavigationItems = Math.ceil(this.totalPosItemSize / 50);
    let navigationItemList = [];
    for (let i = startnumber; i <= lastnumber; i++) {
      let recordStartIndex = (i - 1) * 50;
      let recordLastIndex = recordStartIndex + 49;
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
    console.log('hi',JSON.stringify(this.navigationItems));

  }


  //To call set navigation method by passing  first number ,last number and the selected index 
  firstNavigationButton() {
    this.startIndex = 1;
    this.lastIndex = 5;
    this.selectedIndex = 1;
    this.recordStartIndex = 0;
    return refreshApex(this.posItemListToBeDisplayed);
  }

  //to navigate to the previous page if it is available
  previousNavigationButton() {
    if (this.navigationItems[0].recordStartIndex > 0) {
      this.startIndex = this.navigationItems[0].index - 5;
      this.lastIndex = this.startIndex + 4;
      this.selectedIndex = this.navigationItems[0].index - 5;
      this.recordStartIndex = this.navigationItems[0].recordStartIndex - 60;
      return refreshApex(this.posItemListToBeDisplayed);
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
      return refreshApex(this.posItemListToBeDisplayed);
    }
  }

  //on click of this button to naviagte to the last paginated navigation from any page ,if exist
  lastNavigationButton() {
    this.lastIndex = Math.ceil(Math.ceil(this.totalPosItemSize / 50) / 5) * 5;
    this.startIndex = this.lastIndex - 4;
    this.recordStartIndex = (this.startIndex - 1) * 50;
    this.selectedIndex = this.lastIndex - 4;
    return refreshApex(this.posItemListToBeDisplayed);
  }

  //To hold the selected page number and invoke the getPosItems 
  getPosItemsByIndex(event) {
    let selectedPageNumber = event.target.value;
    this.selectedIndex = selectedPageNumber.index;
    this.recordStartIndex = selectedPageNumber.recordStartIndex;
    return refreshApex(this.posItemListToBeDisplayed)

  }
}