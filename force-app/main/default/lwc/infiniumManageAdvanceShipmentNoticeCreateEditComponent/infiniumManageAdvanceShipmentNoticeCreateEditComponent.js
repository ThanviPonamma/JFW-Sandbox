// Authors:SN
// Date:07-11-2021
// Aim: To get the data required from apex for edit/create pop and to perform validation the data entered before saving to databse
import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';
import getAllPositems from '@salesforce/apex/InfiniumHanadleASNPOSItemsList_Apex.loadPosItemList'
import saveAdvanceShipmentNotice from '@salesforce/apex/InfiniumHanadleASNPOSItemsList_Apex.saveAdvanceShipmentNotice'
import {
    refreshApex
} from '@salesforce/apex';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

export default class InfiniumManageAdvanceShipmentNoticeCreateEditComponent extends LightningElement {
    //to know if the edit button is clicked
    @api isEditClicked;
    //to get all asn details
    @api getAsnDetails;
    //to hold selected asn details
    @track selectedASNId;
    //to hold selected pos items
    @track selectedPosItems;
    //to hold unselected pos items
    @track unselectedPosItems = [];
    //to hold selected pos items
    @track fronEndSelectedPosItems = [];
    //to hold unselected pos items
    @track fronEndUnSelectedPosItems = [];
    //to know if add icon is clicked
    @track addOrRemoveIconClicked = false;
    //to know if search is performed
    @track isSearchPerformed = false;
    //to hold total quantity
    @track totalQuantity;
    //to hold the boolean value to open / close a modal
    @api isModalOpen = false;
    //to hold asn details
    @track asnDetails;
    //to disable the button
    @track isButtonDisable;
    //to hold today date
    @track today;
    //to hold search keyword
    @track searchKeyWord = '';
    //to hold the searched pos item record
    @track searchedResult = [];
    //to hold the invoke type
    @track invokeType = 'init';
    //to display error message if quanity for selected pos item is not gretaer than 1
    @track displayErrorMessageForQTY = false

    //to fetch the asn details from parent
    connectedCallback() {
        this.asnDetails = JSON.parse(JSON.stringify(this.getAsnDetails));
        this.selectedASNId = this.asnDetails.Id;
        if (this.asnDetails.Id == undefined) {
            this.selectedASNId = null;
        }
        // console.log('selectedASNId--->', JSON.stringify(this.selectedASNId));
    }

    //to fetch pos items from apex class
    @wire(getAllPositems, {
        selectedASNId: '$selectedASNId'
    }) allPosItems;

    //to display pos items on init and to calculate today's date
    get allPosItemsList() {
        //this condition is checked to get the list from the server, if true, the items are updated from front end.
        if (this.allPosItems.data) {
            // console.log('entered after');
            let selectedAndUnselectedItems = this.allPosItems.data;
            if (this.selectedASNId == null) {
                this.selectedPosItems = [];
            }
            //To hold the selected pos items to be displayed from front end
            if (this.fronEndSelectedPosItems.length > 0 && this.addOrRemoveIconClicked == true || this.invokeType == 'frontend') {
                this.selectedPosItems = this.fronEndSelectedPosItems;
            }
            //To hold the availble pos items to be displayed from front end
            if (this.fronEndUnSelectedPosItems.length > 0 && this.addOrRemoveIconClicked == true || this.invokeType == 'frontend') {
                this.unselectedPosItems = this.fronEndUnSelectedPosItems;
            }
            //To display the serach result
            if (this.searchedResult.length > 0 && this.isSearchPerformed == true || this.invokeType == 'search') {
                this.unselectedPosItems = this.searchedResult;
            }

            //To hold the selected and available pos items to be displayed on init

            if (this.invokeType == 'init') {
                this.unselectedPosItems = selectedAndUnselectedItems.unSelectedPosItems;
                this.selectedPosItems = selectedAndUnselectedItems.selectedPosItems;

            }
            // to display avilable pos items in the front end
            if (this.invokeType == 'reinvoke') {
                let updatedAvailablePosItems = [];
                // console.log('this.invokeType',this.invokeType)
                // console.log('before reninvoke--->',JSON.stringify(this.selectedPosItems))
                // console.log('this.addOrRemoveIconClicked--->',JSON.stringify(this.addOrRemoveIconClicked))
                if (this.selectedPosItems.length > 0 && this.addOrRemoveIconClicked == true) {
                    this.unselectedPosItems = [];
                    let availablePosItemsList = JSON.parse(JSON.stringify(selectedAndUnselectedItems.unSelectedPosItems));
                    for (var i = 0; i < availablePosItemsList.length; i++) {
                        for (var j = 0; j < this.selectedPosItems.length; j++) {
                            if (availablePosItemsList[i].posItemList.Id == this.selectedPosItems[j].posItemList.POS_Item__r.Id && this.selectedPosItems[j].isPosItemSelected == true) {
                                availablePosItemsList[i].isPosItemSelected = true;
                                updatedAvailablePosItems.push(availablePosItemsList[i]);
                            }

                        }
                    }
                    for (var k = 0; k < availablePosItemsList.length; k++) {
                        if (!availablePosItemsList[k].isPosItemSelected) {
                            this.unselectedPosItems.push(availablePosItemsList[k])
                        }
                    }
                } else {
                    this.unselectedPosItems = selectedAndUnselectedItems.unSelectedPosItems;
                }
            }

            // console.log('selectedPosItems------>',JSON.stringify(this.selectedPosItems.length));
            //  console.log('this.unselectedPosItems--->',JSON.stringify(this.unselectedPosItems.length));
            this.validateASNData();
        }

    }

    //on assign entered vendor value to the respective object and field
    onChangeVendor(event) {
        this.asnDetails.Vendor__c = event.target.value;
        this.validateASNData();
    }
    //on assign entered purchase number value to the respective object and field
    onChangePurchaseNumber(event) {
        this.asnDetails.Purchase_Order_Number__c = event.target.value;
        this.validateASNData();

    }
    //on assign entered pallet value to the respective object and field
    onChangePalletCount(event) {
        this.asnDetails.Pallet_Count__c = event.target.value;
        this.validateASNData();

    }
    //on assign entered carrier value to the respective object and field
    onChangeCarrier(event) {
        this.asnDetails.Carrier__c = event.target.value;
        this.validateASNData();

    }
    //on assign entered tracking number value to the respective object and field
    onChangeTrackingNumber(event) {
        this.asnDetails.Tracking_Number__c = event.target.value;
        this.validateASNData();

    }
    //on assign entered package count value to the respective object and field
    onChangePackageCount(event) {
        this.asnDetails.Package_Count__c = event.target.value;
        this.validateASNData();

    }
    //on assign entered expected date value to the respective object and field
    onChangeExpectedDate(event) {
        this.asnDetails.Expected_Date__c = event.target.value;
        this.validateASNData();
    }
    //to validate asn data    
    validateASNData() {
        let validatedate = this.template.querySelector(".dateValidityField");
        let datewithTimeValue = validatedate.value;
        // console.log('datewithTimeValue',datewithTimeValue)
        let dateValue;

        this.displayErrorMessageForQTY = false;
        this.isButtonDisable = false;
        if(this.selectedPosItems.length>0){
            for (let i = 0; i < this.selectedPosItems.length; i++) {
                if (this.selectedPosItems[i].posItemList.Quantity__c <= 0) {
                    this.displayErrorMessageForQTY = true;
                }
            }
        }
        else {
            this.displayErrorMessageForQTY = true;
        }
        
        if (datewithTimeValue == null) {
            this.isButtonDisable = true;
            //   console.log('datewithTimeValue')
        }
        if (datewithTimeValue != null)
            dateValue =datewithTimeValue;  
            var todayDate = new Date();
            this.today = todayDate.toISOString();
        if (dateValue < this.today) {
            this.isButtonDisable = true;
        }


    }
    //Not to alllow special charaters in the quantity field
    removeSpecialCharactersForQuantity(event) {
        //   console.log('key code-->',JSON.stringify(event.keyCode))
        for (var i = 48; i < 58; i++)
            keyCodes.push(i);
        keyCodes.push(8);
        if (!keyCodes.includes(event.keyCode))
            event.preventDefault();
    }
    // //to add pos items to the list
    addPosItemsToList(event) {
        this.invokeType = 'frontend';
        this.addOrRemoveIconClicked = true;
        let posItemTobeAdded = event.target.name;
        let selectedPosItemList = [];
        let unSelectedPosItemList = [];
        let existingSelectedPosItemList = this.selectedPosItems;
        //hold the items that are under unselected address
        this.addOrRemoveIconClicked = true;
        this.isSearchPerformed = false;
        for (let i = 0; i < this.unselectedPosItems.length; i++) {
            if (this.unselectedPosItems[i].posItemList.Id != posItemTobeAdded.Id)
                unSelectedPosItemList.push(this.unselectedPosItems[i]);

        }

        //hold the new selected address to list and update the List
        selectedPosItemList.push({
            "isPosItemSelected": true,
            "posItemList": {
                "POS_Item__c": posItemTobeAdded.Id,
                "Quantity__c": 0,
                "POS_Item__r": {
                    "Item_Name__c": posItemTobeAdded.Item_Name__c,
                    "Pack_Of__c": posItemTobeAdded.Pack_Of__c,
                    "Item_No__c": posItemTobeAdded.Item_No__c,
                    "Id": posItemTobeAdded.Id,
                }
            }
        });
        this.fronEndUnSelectedPosItems = unSelectedPosItemList;
        //  console.log('fronEndUnSelectedPosItems after add----->',this.fronEndUnSelectedPosItems.length);
        this.fronEndSelectedPosItems = selectedPosItemList.concat(existingSelectedPosItemList);
        this.validateASNData();

    }
    //to hold the pos item to be removed from selectecd
    removePosItemsFromList(event) {
        this.invokeType = 'frontend';
        this.addOrRemoveIconClicked = true;
        this.isSearchPerformed = false;
        let posItemToBeRemoved = event.target.name;
        let selectedPosItemList = [];
        let unSelectedPosItemList = [];
        let existingunSelectedPosItemList = this.unselectedPosItems;
        for (let i = 0; i < this.selectedPosItems.length; i++) {
            if (this.selectedPosItems[i].posItemList.POS_Item__r.Id != posItemToBeRemoved.POS_Item__r.Id)
                selectedPosItemList.push(this.selectedPosItems[i]);

        }
        unSelectedPosItemList.push({
            "isPosItemSelected": false,
            "posItemList": {
                "Id": posItemToBeRemoved.POS_Item__r.Id,
                "Item_No__c": posItemToBeRemoved.POS_Item__r.Item_No__c,
                "Pack_Of__c": posItemToBeRemoved.POS_Item__r.Pack_Of__c,
                "Item_Name__c": posItemToBeRemoved.POS_Item__r.Item_Name__c
            }

        });

        this.fronEndUnSelectedPosItems = unSelectedPosItemList.concat(existingunSelectedPosItemList);
        this.fronEndSelectedPosItems = selectedPosItemList;
        this.validateASNData();
    }
    //to save asn
    saveASN(event) {
        let selectedPosItems = []
        for (var i = 0; i < this.selectedPosItems.length; i++) {
            selectedPosItems.push(this.selectedPosItems[i].posItemList);
        }
        saveAdvanceShipmentNotice({
                advanceShipmentNotice: JSON.stringify(this.asnDetails),
                selectedPosItemList: selectedPosItems,
                actionType: 'Save'
            })
            .then(result => {
                let resultGiven = result;
                if (this.isEditClicked) {
                    const evt = new ShowToastEvent({

                        message: 'The edited ASN has been updated successfully.',
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);
                    refreshApex(this.allPosItems);

                }
                //to check if the save is for the create pop-up and show the toast message
                else {
                    const evt = new ShowToastEvent({

                        message: 'The ASN has been created successfully.',
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);
                    refreshApex(this.allPosItems);

                }
                const closeButton = new CustomEvent('closemodal', {
                    detail: {
                        isModalOpen: false,
                        // saveandnew: false,
                    }
                });
                this.dispatchEvent(closeButton);
            })
    }

    //to save and submit asn
    saveAndSubmit(event) {
        let selectedPosItems = []
        for (var i = 0; i < this.selectedPosItems.length; i++) {
            selectedPosItems.push(this.selectedPosItems[i].posItemList);
        }
        saveAdvanceShipmentNotice({
                advanceShipmentNotice: JSON.stringify(this.asnDetails),
                selectedPosItemList: selectedPosItems,
                actionType: 'SAVE_AND_SUBMIT'
            })
            .then(result => {
                let resultGiven = result;
                if (this.isEditClicked) {
                    const evt = new ShowToastEvent({

                        message: 'The edited Advance Shipment Notice has been updated successfully.',
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);
                    refreshApex(this.allPosItems);

                } else {
                    const evt = new ShowToastEvent({

                        message: 'The Advance Shipment Notice has been created successfully.',
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);
                    refreshApex(this.allPosItems);

                }
                const closeButton = new CustomEvent('closemodal', {
                    detail: {
                        isModalOpen: false,
                        isViewModal: false
                    }
                });
                this.dispatchEvent(closeButton);

            })
    }
    //to close the pop up modal and to send the value to the parent componet of the changed value
    closeModal() {
        const closeButton = new CustomEvent('closemodal', {
            detail: {
                isModalOpen: false,
                isViewModal: false
            }
        });
        this.dispatchEvent(closeButton);
    }
    //to calculate total quantity
    addToTotalQty(event) {
        //to capture the details enetred in the quantity field
        this.invokeType = 'frontend';
        let selectedPosItemsQuantity = event.target.value;
        let totalQty = 0;
        let selectedPosItem = event.target.name;
        let selectedPosItemId = selectedPosItem.POS_Item__c;
        let selectedListTobeUpdated = JSON.parse(JSON.stringify(this.selectedPosItems))
        //to update the quanity field
        for (let i = 0; i < selectedListTobeUpdated.length; i++) {
            if (selectedPosItemId == selectedListTobeUpdated[i].posItemList.POS_Item__c) {
                selectedListTobeUpdated[i].posItemList.Quantity__c = selectedPosItemsQuantity;
            }
        }
        //to calculate the quanity field
        for (let i = 0; i < selectedListTobeUpdated.length; i++) {
            totalQty = totalQty + parseInt(selectedListTobeUpdated[i].posItemList.Quantity__c);
        }
        this.fronEndSelectedPosItems = selectedListTobeUpdated;
        this.fronEndUnSelectedPosItems = this.unselectedPosItems;
        this.totalQuantity = totalQty;
        this.validateASNData();

    }

    //to perform the serach
    handleSearchFilter(event) {
        //to capture the search key and perform the
        var searchKey = event.target.value;
        var searchKeyWord = searchKey.toUpperCase();
        var unselectedPosItems = JSON.parse(JSON.stringify(this.unselectedPosItems));
        this.searchedResult = [];
        //if the search key exists check for the search result exists
        if (searchKey) {
            this.isSearchPerformed = true;
            this.addOrRemoveIconClicked = false;
            this.invokeType = 'search';
            for (var i = 0; i < unselectedPosItems.length; i++) {
                if ((unselectedPosItems[i].posItemList.Item_Name__c.toUpperCase().includes(searchKeyWord)) || (unselectedPosItems[i].posItemList.Item_No__c.toUpperCase().includes(searchKeyWord))) {
                    this.searchedResult.push(unselectedPosItems[i]);
                }
            }
        }
        //if the serach key is removed and is null
        else {
            this.isSearchPerformed = false;
            this.invokeType = 'reinvoke';
            if (this.fronEndSelectedPosItems.length > 0) {
                this.addOrRemoveIconClicked = true;
            } else {
                this.addOrRemoveIconClicked = false;
            }

            this.searchedResult = [];

        }
    }
}