// Author - VM,VP,JP Date - June 30th 2020
import { LightningElement,api, wire,track} from 'lwc';
// To get the available Comet Order List from the apex class using the method "loadAvailableCometOrders"
import availableCometOrderList from '@salesforce/apex/DFVSendWaveOrders_Apex.loadAvailableCometOrders'
// To get the Pos Items for the Comet Order from the apex class using the method "loadPosItemsForCometOrder"
import loadPosItemsForCometOrder from '@salesforce/apex/DFVSendWaveOrders_Apex.loadPosItemsForCometOrder'
// add Orders to Selected Comet Orders list from the apex class using the method "addAvailableOrder"
import addOrdersToSelectedCometOrders from '@salesforce/apex/DFVSendWaveAddOrRemoveOrders.addAvailableOrder'
import { refreshApex } from '@salesforce/apex';

export default class DfvAvailableCometOrdersTable extends LightningElement {

    //property to hold the incoming Program Id
    @api getProgramId;

    //property to hold the incoming User Id
    @api getUserId;

     //property to hold the search data information
    @api getSearchValue;

    // To open the modal to view the items
    @track isModalOpen= false;

    // property to hold the incoming available Comet List Id
    @track availableCometListId;

    // property to hold the incoming order Destination Items List
    @track orderDestinationItemsList;

    // property to hold the incoming selected Comet Order Id
    @track selectedCometOrderId;

    // property to hold the selected orders
    @track addSelectedOrder;

    // variable to hold the list of available comet orders
    @track availableOrderList;

    // variable which holds the boolean attribute to hide and display the table
    @track isAvailableCometOrderHasData=true;



     //To get the data from 'availableCometOrderList' import method and store in 'availableCometOrderListToBeDisplayed' property
@wire(availableCometOrderList,{selectedProgramId:'$getProgramId',selectedUserId:'$getUserId',searchkeyWord:'$getSearchValue'})
availableCometOrderListToBeDisplayed;
    // get method to get the available Comet Order List data
get availableCometOrderList(){
    this.isAvailableCometOrderHasData=true;
        if(this.availableCometOrderListToBeDisplayed.data){

            this.availableOrderList = this.availableCometOrderListToBeDisplayed.data;
            if(this.availableOrderList.length === 0){

                this.isAvailableCometOrderHasData=false;
                
            }
            return refreshApex(this.availableCometOrderListToBeDisplayed);
        }
}


// Popup modal event to open the view items
//  onclick of the button the event is handled to open the popup
openModal(event){
        this.isModalOpen = true;
        event.preventDefault();
        this.availableCometListId = event.target.dataset.id;

    //Import apex method to get the pos items for the selected comet order 
     loadPosItemsForCometOrder({selectedOrderDestinationId: this.availableCometListId})
      .then(result => {
              this.orderDestinationItemsList = result;
              return refreshApex(this.orderDestinationItemsList)
        })
        .catch(error => {
        this.error = error;
        console.log('ERROR',this.error); 
        });
}
    
// onclick of close button event is handled to close the popup modal
closeModal() {
    this.isModalOpen = false;
}


    // on click of add button this event is occured
getPosItemsForCometOrders(event){
            event.preventDefault();
                this.selectedCometOrderId = event.target.dataset.id;
                        
                //Import apex method to add the available order to the selected comet orders
                addOrdersToSelectedCometOrders({selectedProgramId: this.getProgramId,selectedCometOrderId:this.selectedCometOrderId,selectedUserId:this.getUserId})
                .then(result => {
                this.addSelectedOrder = result;
                // console.log('addSelectedOrder--->', this.addSelectedOrder)
                     
                const availableCometOrderEvent = new CustomEvent('updateavailableandselectedcometorderlist',{detail:this.addSelectedOrder});
                this.dispatchEvent(availableCometOrderEvent);
                })
                .catch(error => {
                    this.error = error;
                  console.log('ERROR',this.error); 
                });
                
      }
}