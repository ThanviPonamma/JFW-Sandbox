import { LightningElement,wire,api,track} from 'lwc';
 // Author : Sanjana Date:10-11-2021
// Import the brand data from 'InfiniumWaveOrders_Apex' apex class using the method 'loadBrandList' and store it in 'getBrandList'
import getBrandList from '@salesforce/apex/InfiniumWaveOrders_Apex.loadBrandList'

// Import the withheld item data from 'InfiniumWaveOrders_Apex' apex class using the method 'InfiniumWaveOrders_Apex' and store it in 'loadWithheldItems'
import loadWithheldItems from '@salesforce/apex/InfiniumWaveOrders_Apex.loadWithheldItems'

//Import to remove an item from withheld items from 'InfiniumWaveOrders_Apex' apex class using the method 'InfiniumWaveOrders_Apex' and store it in 'removeItemFromWithheldItems'
import addItemsToAvailableList from '@salesforce/apex/InfiniumWaveOrdersAddOrRemovePos_Apex.removeItemFromWithheldItems'

// Import method to refresh the apex class
import { refreshApex } from '@salesforce/apex';

export default class InfiniumManageOrderedWithheldItemsTableComponent extends LightningElement {
 
//Variable to hold the incoming Program Id
@api getProgramId;

// To hold the list of brand and send to the display
@track brandListToDisplay;

// Variable to hold the incoming brand Id
@track selectedBrandId =null;

// Variable to hold the withheld item id
@track withheldItemId;

// Variable to hold the list of items from withheld data
@track withheldOrderList;

// Variable to store when the item is sent to the available table
@track addItemsToAvailableListData;

// Boolean variable to check if the data is present in th available list
@track withheldListHasData=true;


 // Author : Sanjana
    //to get the data from 'getBrandList' 
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
            });
        }
        else if(error){
            console.log('Error', error.body.message , 'error');
    }
}


    //Brand onchange event to capture the selected brand Id
onSelectionOfBrand(event) {
         this.selectedBrandId = event.detail.value;
    }


//To get the data from 'loadWithheldItems' import method and store in 'getWithHeldItemsList' property
@wire(loadWithheldItems,{selectedProgramId:'$getProgramId',selectedBrandId:'$selectedBrandId'})
      getWithHeldItemsList;

// get method to get the list of withheld item list data
get withHeldItemsToBeDisplayed(){
    this.withheldListHasData =true;

    if(this.getWithHeldItemsList.data){

        this.withheldOrderList = this.getWithHeldItemsList.data;

        if(this.withheldOrderList.length === 0){
            this.withheldListHasData = false;
            
        }
    //    To refresh the table and get latest data
        return refreshApex(this.getWithHeldItemsList);
    }
}


// Event to remove the item from the withheld table and send to the available table
removeItemFromWithheldEvent(event) {
    event.preventDefault();
 
            // To hold the withheld item id for each value in the table
             this.withheldItemId = event.target.dataset.id;
             addItemsToAvailableList({selectedProgramId: this.getProgramId,selectedPosItemId:this.withheldItemId})
             .then(result => {
                  this.addItemsToAvailableListData = result;
                  refreshApex(this.getWithHeldItemsList);
                 // Custom event is called to send the withheld item id to parent component
                 const withheldEvent = new CustomEvent('updateavailableandwithheldlist',{detail:this.addItemsToAvailableListData});
                 this.dispatchEvent(withheldEvent);
        
                })
              .catch(error => {
                    this.error = error;
                    console.log('ERROR',this.error); 
               });     
}
}