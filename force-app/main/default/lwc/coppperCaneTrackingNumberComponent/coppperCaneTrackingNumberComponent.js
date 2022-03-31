import { LightningElement, track, wire,api } from 'lwc';

//To get the list of programs from the apex class 'CopperCaneTrackingNumberSyncApex' using the method 'getProgramList_Apex'
import getProgramList from "@salesforce/apex/CopperCaneTracking_Apex.getProgramList_Apex"
//To get the list of brands "@salesforce/apex/CopperCaneTracking_Apex.getBrandList"
import getBrandList from "@salesforce/apex/CopperCaneTracking_Apex.getBrandList"
//To get the list of programs from the apex class 'CopperCaneTrackingNumberSyncApex' using the method 'getProgramPOSList_Apex'
import getProgramPOSList from "@salesforce/apex/CopperCaneTracking_Apex.getProgramPOSList_Apex"
//To get the list of programs from the apex class 'CopperCaneTrackingNumberSyncApex' using the method 'getTrackingNumbersOfOrders_Apex'
import getTrackingNumbersOfOrders from "@salesforce/apex/CopperCaneTracking_Apex.getTrackingNumbersOfOrders_Apex"
import UploadCopperTracking from "@salesforce/apex/CopperCaneTracking_Apex.UploadCopperTracking_Apex"
import synchronizeCopperTracking from "@salesforce/apex/CopperCaneTracking_Apex.synchronizeCopperTracking_Apex"

import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class CoppperCaneTrackingNumberComponent extends LightningElement {
    //to hold the account details from the Admin Content component.
    @api account;
    // To hold the 'programListToDisplay' value and to make it reactive
    @track programListToDisplay;
    // To hold the selected Program Id
    @track selectedProgramId;
    // To hold the 'programItemListToDisplay' value and to make it reactive
    @track programItemListToDisplay;
    // To hold the selected POS Id
    @track selectedPOSItemId;
    @track isDisableProceedButton = true;
    // to hold the order details
    @track orderDetails = [];
    // to hold the boolean value
    @track isProgramSelected = true;
    // to hold the boolean value
    @track isOrderExist = false;
    @track isTrackingSynced = false;
    @track isTrackingFileUploaded = false;
    @track isOrderDetailsLoading = false;

    //to get the data from 'getProgramList'
    @wire(getProgramList)
    loadOrderedProgramList({ data, error }) {
        // If the getProgramList has data
        if (data) {
            // get the value and lable for each program in the program list
            this.programListToDisplay = [
                { value: "", label: "Select a Program" },
            ];
            // for each program
            data.forEach((element) => {
                const program = {};
                //set program name to the lable property
                program.label = element.Program_Name__c;
                // Set the program id to the value property
                program.value = element.Id;
                // push the program data to "programListToDisplay" property
                this.programListToDisplay.push(program);
            });
        }
    }

       //to get the data from 'getBrandList'
       @wire(getBrandList)
       loadOrderedBrandList({ data, error }) {
           // If the getProgramList has data
           if (data) {
               // get the value and lable for each program in the program list
               this.brandListToDisplay = [
                   { value: "", label: "Select a Brand" },
               ];
               // for each program
               data.forEach((element) => {
                   const brand = {};
                   //set program name to the lable property
                   brand.label = element.Brand_Name__c;
                   // Set the program id to the value property
                   brand.value = element.Id;
                   // push the program data to "programListToDisplay" property
                   this.brandListToDisplay.push(brand);
               });
           }
       }

    //Aim : To capture the selected program Id and fetch the program item list
    onSelectionOfProgram(event) {
        this.selectedProgramId = event.detail.value;
        this.isProgramSelected = false;
        // console.log(JSON.stringify(this.programItemListToDisplay));
        if (this.selectedProgramId != "") {
            getProgramPOSList({
                selectedProgramId: this.selectedProgramId,
            }).then((result) => {
                // get the value and lable for each pos item in the program pos item list
                this.programItemListToDisplay = [
                    { value: "", label: "Select a POS Item" },
                ];
                // for each program
                result.forEach((element) => {
                    const programPosItem = {};
                    //set program name to the lable property
                    programPosItem.label = element.POS_Item__r.Item_Name__c;
                    // Set the programPosItem id to the value property
                    programPosItem.value = element.POS_Item__r.Item_No__c;
                    // push the programPosItem data to "programItemListToDisplay" property
                    this.programItemListToDisplay.push(programPosItem);
                });
                this.isProgramSelected = false;
            });
        }
        else {
            this.isProgramSelected = true;
        }
        this.selectedPOSItemId = "";
        this.enableOrDisableProceedButton();
    }
    //Aim : To capture the selected program pos Id
    onSelectionOfPOSItem(event) {
        this.selectedPOSItemId = event.detail.value;
        this.enableOrDisableProceedButton();
    }
    //to check if the "Proceed" button should be enabled/disabled  
    enableOrDisableProceedButton() {
        this.isDisableProceedButton = true;
        if (this.selectedProgramId != "" && this.selectedPOSItemId != "" && this.selectedPOSItemId != undefined) {
            this.isDisableProceedButton = false;
        }
        else {
            this.isOrderExist = false;
        }
    }
    //to  call the method to fetch the order details
    onClickOfProceedButton(event) {
        this.isOrderDetailsLoading = true;
        getTrackingNumbersOfOrders({
            selectedProgramId: this.selectedProgramId,
            accountId: this.account.Id,
            selectedPOSItemId: this.selectedPOSItemId
        }).then((result) => {
            // console.log(JSON.stringify(result));
            this.orderDetails = result[0].cometOderedItems;
            // console.log(JSON.stringify(result));
            if (this.orderDetails.length > 0) {
                this.isTrackingFileUploaded = result[0].programItemDetail.Tracking_File_Uploaded__c;
                this.isTrackingSynced = result[0].programItemDetail.Tracking_Synced__c;
                this.isOrderExist = true;
            } else {
                this.isOrderExist = false;
            }
            this.isOrderDetailsLoading = false;
        });
        

    }
    // accepted parameters
    get acceptedCSVFormats() {
        return [".csv"];
    }

    uploadFileHandler(event) {
        // Get the list of records from the uploaded files
        const uploadedFiles = event.detail.files;
        // calling apex class csvFileread method
        UploadCopperTracking({
            contentDocumentId: uploadedFiles[0].documentId,
            accountId: this.account.Id,
            selectedProgramId: this.selectedProgramId,
            selectedPOSItemId: this.selectedPOSItemId
        })
            .then((result) => {
                this.isTrackingFileUploaded = true;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success!!",
                        message: "Records are created according to the CSV file upload!!!",
                        variant: "Success",
                    })
                );
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error!!",
                        message: JSON.stringify(error),
                        variant: "error",
                    })
                );
            });
    }
    //Aim : To capture the selected program Id
    onClickOfSyncTrackingNumberButton(event) {
        this.isOrderDetailsLoading = true;
        synchronizeCopperTracking({
            selectedProgramId: this.selectedProgramId,
            accountId: this.account.Id,
            selectedPOSItemId: this.selectedPOSItemId
        }).then((result) => {
            // console.log('result---->', JSON.stringify(result));
            this.isTrackingFileUploaded = result[0].programItemDetail.Tracking_File_Uploaded__c;
            this.isTrackingSynced = result[0].programItemDetail.Tracking_Synced__c;
            this.isOrderDetailsLoading = false;
            if (this.isTrackingSynced) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success!!",
                        message: "The tracking number(s) has been synced.",
                        variant: "Success",
                    })
                );
            }
            else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error!!",
                        message: "The data uploaded do not match the orders in the system. Please contact the Helpdesk team.",
                        variant: "Error",
                    })
                );
            }

        });
    }
    onClickOfShowTrackingButton() {
        if (this.selectedProgramId != "") {
            this.isProgramSelected = false;
            getTrackingNumbersOfOrders({
                selectedProgramId: this.selectedProgramId,
                accountId: this.account.Id,
                selectedPOSItemId: this.selectedPOSItemId
            }).then((result) => {
                // console.log('result---->',JSON.stringify(result));
                this.orderDetails = result[0].cometOderedItems;
                if (this.orderDetails.length > 0) {
                    this.isTrackingFileUploaded = result[0].programItemDetail.Tracking_File_Uploaded__c;
                    this.isTrackingSynced = result[0].programItemDetail.Tracking_Synced__c;
                    this.isOrderExist = true;
                    
                } else {
                    this.isOrderExist = false;
                }
                this.isOrderDetailsLoading = false;
            });
        } 
    }
}