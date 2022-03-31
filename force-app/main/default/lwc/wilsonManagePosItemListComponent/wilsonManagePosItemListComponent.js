// Authors:Vanditha,Thanvi
// Date:05-01-2021

// Aim:To hold the functionalities of create , edit buttons and display the contents.

import { LightningElement,wire,track,api } from 'lwc';
// to import the pos item list from the apex class "WilsonManagePosItems_Apex" with the method "getPOSItemList"
import searchPOSItem from '@salesforce/apex/WilsonManagePosItems_Apex.searchPOSItem'
// to import the list of brand from the apex class "WilsonManagePosItems_Apex" with the method "getBrandList"
import getBrandList from '@salesforce/apex/WilsonManagePosItems_Apex.getBrandList'
// to import the list of item type from the apex class "WilsonManagePosItems_Apex" with the method "getItemTypeList"
import getItemTypeList from '@salesforce/apex/WilsonManagePosItems_Apex.getItemTypeList'
import deactivateSelectedItem from '@salesforce/apex/WilsonManagePosItems_Apex.deactivateSelectedItem'
// to display no image
import noImage from '@salesforce/resourceUrl/noimageavailable';

// Import method refresh the page
import { refreshApex } from '@salesforce/apex';

//to display Toast Message
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class WilsonManagePosItemListComponent extends LightningElement {
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
 @track posItemFound=false;

 // no image variable
 NoImageURL = noImage;

 @wire(searchPOSItem,{searchText:'$searchedKeyword' , 
                        selectedBrand:'$selectedBrandId',
                        selectedItemType:'$selectedItemTypeId'}) posItemListToBeDisplayed;

// get method which acts as the init method on page load
 get posItemList(){ 
     if(this.posItemListToBeDisplayed.data){
     //    console.log('pos items',JSON.stringify(this.posItemListToBeDisplayed.data));
         this.posItemListData = this.posItemListToBeDisplayed.data;
         // console.log('positems',JSON.stringify(this.posItemListData));
         this.posItems =this.posItemListData.posItemList;
         this.posItemsWithValidation = this.posItemListData.posItemNamesForValidation;
         // console.log('posItemsWithValidation----->',JSON.stringify(this.posItemsWithValidation));
         this.posItemStockNumberValidation = this.posItemListData.posItemStockNumbersForValidation;
         // console.log('posItemStockNumberValidation----->',JSON.stringify(this.posItemStockNumberValidation));
         if(this.posItems.length==0){
             this.posItemFound=false;
         }
         else{
             this.posItemFound=true;
         }
         refreshApex(this.posItemListToBeDisplayed);

   
 }
}

// to open the popup modal on click of edit button and send the selected pos item details
openEditPosItemModal(event){
 //to capture the pos item deatils of the selected item
 let selectedPosItems = event.target.name;
 //to send the pos item value to the chils
 this.editedPosItemData = selectedPosItems;
 //to open the pop up
 this.isOpenModal=true;
 //to check if its edit/create button clicked
 this.isEditClicked=true;
 //to capture the item name and assign to the label
 this.labelName = selectedPosItems.posItemList.Item_Name__c;
 // console.log('editedPosItemData in parent',JSON.stringify(this.editedPosItemData));
}


//To open the create modal popup
openCreateModal(){
let temp ={
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
   "Low_inventory_level_applicable__c": false,
   "Maximum_order_quantity_applicable__c": false,
   "Marketing_Only__c": false,
   "Inventory_Seasonal_Program__c": 'Inventory',
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
this.editedPosItemData=temp;

 this.isOpenModal=true;
 this.isEditClicked=false;
 this.labelName='';
 // console.log('create modal ending');
}

//To close the create/edit modal
closeModal(event){

     this.isOpenModal=event.detail.modalopen; 
     return refreshApex(this.posItemListToBeDisplayed);
}

//to get the data from 'getBrandList' to display under the drop dowm
@wire(getBrandList)
loadBrandList({data,error}){
  // If the getBrandList has data
  if(data){
      // get the value and lable for each brand in the program list
      this.brandListToDisplay = [{value : '', label:'All Brands'}];
     // for each brand
      data.forEach(element => {
          const brand = {};
         //set brand name to the lable property
          brand.label = element.Brand_Name__c;
         // Set the brand id to the value property
          brand.value = element.Id;
          // push the brand data to "brandList" property
          this.brandListToDisplay.push(brand);
         //  console.log('the Brand  name',JSON.stringify( this.brandListToDisplay))
      });
  }
  //To handle the error
  else if(error){
      // console.log('Error', error.body.message , 'error');
  }
}
//to capture the brand id end it to the parameter in init method
handleChangeForBrand(event){
this.selectedBrandId = event.target.value;

}
//to capture the item type id end it to the parameter in init method
handleChangeForItemType(event){
 this.selectedItemTypeId = event.target.value;
}


//to get the data from 'getItemTypeList' 
@wire(getItemTypeList)
loadItemTypeList({data,error}){
  // If the getBrandList has data
  if(data){
      // get the value and lable for each itemType in the program list
      this.itemTypeListToDisplay = [{value : '', label:'All Item Types'}];
     // for each itemType
      data.forEach(element => {
          const itemType = {};
         //set itemType name to the lable property
          itemType.label = element.Item_Type__c;
         // Set the itemType id to the value property
          itemType.value = element.Id;
          // push the itemType data to "itemTypeList" property
          this.itemTypeListToDisplay.push(itemType);
     //   console.log('the item type name',JSON.stringify( this.itemTypeListToDisplay))
      });
  }
  //To handle the error
  else if(error){
      console.log('Error', error.body.message , 'error');
  }
}

//To deactivate the pos item
deactivatePosItem(event){
 // to hold the deactivate pos item details
 let deactivatedPosItem = event.target.name;
 //to hold pos item name for the toast message
 let deactivatedPosItemForToast = deactivatedPosItem.Item_Name__c;
 // console.log('deactivatedPosItemForToast----->',deactivatedPosItemForToast);
  deactivateSelectedItem({  
         posItem :deactivatedPosItem,

         })
         .then(result => {
             let resultGiven = result;
             //to display a toast message to the user
             if(resultGiven=="done"){
                 const evt = new ShowToastEvent({
                   message: 'The POS item "'+deactivatedPosItemForToast +'" has been deactivated successfully.',
                   variant: 'success',
                 });
                 this.dispatchEvent(evt);
               }
               //to refresh the list.
             return refreshApex(this.posItemListToBeDisplayed);
         })
}

//to capture the searched value and send it to the parameter in init method
  handlePOSItemSearchFilter(event){
   this.searchedKeyword = event.target.value;
 }


}