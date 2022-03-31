import { LightningElement, wire, api,track} from 'lwc';
// Import the available item data from 'DFVWaveOrders_Apex' apex class using the method 'loadWithheldItems' and store it in 'loadAvailableItems'
import loadAvailableItems from '@salesforce/apex/DFVWaveOrders_Apex.loadAvailableItems'

// Import the add items to the withheld items from 'DFVWaveOrdersAddOrRemovePosItems_Apex' and store it in 'addItemToWithheldItems'
import addItemToWithheldItems from '@salesforce/apex/DFVWaveOrdersAddOrRemovePosItems_Apex.addItemToWithheldItems'

// Import method to refresh the apex class
import { refreshApex } from '@salesforce/apex';


export default class DfvManageOrderedAvailableItemsTable extends LightningElement {
//Variable to hold the incoming Program Id
@api getProgramId;

//Variable to hold the incoming Brand Id
@api getBrandId;

// Variable to hold the available item Id
@track availableItemsId;

// Variable to store the data when the item is removed from the available table
@track removeItemFromAvailableList;


// The varilable 'availableItemsId' is used to store the item id.
@track availableListHasData=true;



    //To get the data from 'loadAvailableItems' import method and store in 'getAvailableProgramList' property and send the programid and brandid as parameter
    @wire(loadAvailableItems,{selectedProgramId:'$getProgramId',selectedBrandId:'$getBrandId'})
    getAvailableItemList;


    // get method to get the list of available item list data
    get availableItemsToBeDisplayed(){

        this.availableListHasData=true;

        if(this.getAvailableItemList.data){

        this.availableItems = this.getAvailableItemList.data;
         
        // If the available items doesn't have the data the boolean variable "availableListHasData" is set as false and the table should be hidden
        if(this.availableItems.length === 0){
            
            this.availableListHasData=false;
        }
        // To refresh the apex class
        return refreshApex(this.getAvailableItemList);
        }
    }



    // Onclick event to add the values to the withheld table the event 'addItemToWithheldEvent' is called
    addItemToWithheldEvent(event) {
        event.preventDefault();
                
        // Each item has the seperate id and the varilable 'availableItemsId' is used to store the item id.
                 this.availableItemsId = event.target.dataset.id;

                 addItemToWithheldItems({selectedProgramId: this.getProgramId,selectedPosItemId:this.availableItemsId})
            .then(result => {
                 this.removeItemFromAvailableList = result;

                  // Custom event is called to sent the item id to the parent component 
                     const availableEvent = new CustomEvent('updateavailableandwithheldlist',{detail:this.removeItemFromAvailableList});
                          this.dispatchEvent(availableEvent);
            
                })
            .catch(error => {
                     this.error = error;
                      console.log('ERROR',this.error); 
                });   
    }
}