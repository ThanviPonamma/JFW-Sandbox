// Authors:Sanjana    Date:11-11-2021
import { LightningElement,api,wire,track } from 'lwc';

// import variable to store the selected comet order list sent from the 'InfiniumSendWaveOrders_Apex' class.
import selectedCometOrderList from '@salesforce/apex/InfiniumSendWaveOrders_Apex.loadSelectedCometOrders'

// Import method  to remove the data  from the apex class using the method "removeAvailableOrder" 
import removeAvailableOrder from '@salesforce/apex/InfiniumSendWaveAddOrRemoveOrders.removeAvailableOrder'

// Import method  to submit the data to warehouse from the apex class using the method "submitSelectedOrdersToComet"
import submitSelectedOrdersToComet from '@salesforce/apex/InfiniumSubmitWaveOrder_Apex.submitSelectedOrdersToComet'

// Import method to refresh the apex class
import { refreshApex } from '@salesforce/apex';

// Import method to show the toast message
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class InfiniumSelectedCometOrdersTable extends LightningElement {
    //variable to hold the incoming Program Id
    @api getProgramId;

    //variable to hold the incoming User Id
    @api getUserId;

    //variable to hold the comet order Id
    @track selectedCometOrderId;

    //variable to hold the selected orders
    @track selectedOrders;

    // variable that holds the orders to be removed
    @track removeSelectedCometOrder;

    // variable which has the boolean attribute to show the table only if the data is displayed
    @track isSelectedCometOrderHasData=true;
    
    //Variable to store the submit to warehouse data recevied from the backend.
    @track submitToWareHouseResult;

    // Boolean Variable to display the error message if the order exceeds more than 59 
    @track toDisableSubmitButton = true;

    //To get the data from 'selectedCometOrderList' import method and store in 'selectedCometOrderListToBeDisplayed' property
    @wire(selectedCometOrderList,{selectedProgramId:'$getProgramId',selectedUserId:'$getUserId'})
    selectedCometOrderListToBeDisplayed;


    // get method to get the selected Comet Order List data
    get selectedOrderList(){
        this.isSelectedCometOrderHasData=true;
        this.toDisableSubmitButton = true;


        if(this.selectedCometOrderListToBeDisplayed.data){
             this.selectedOrders=this.selectedCometOrderListToBeDisplayed.data;

  
          if(this.selectedOrders.length === 0){

            this.isSelectedCometOrderHasData=false;
              
        }
        else if (this.selectedOrders.length <= 59){
            this.toDisableSubmitButton = false;
        }
        return refreshApex(this.selectedCometOrderListToBeDisplayed);
        
    }
}

// too send the order to the avaibale order table
removeOrdersFromSelectedCometOrders(event){
    event.preventDefault();
         
    this.selectedCometOrderId = event.target.dataset.id;

    // Import apex method to add the available order to the selected comet orders
    removeAvailableOrder({selectedCometOrderId:this.selectedCometOrderId})
    .then(result => {
    this.removeSelectedCometOrder = result;
    //custom event updateavailableandselectedcometorderlist is called in the parent html as an element
    const removeCometOrderEvent = new CustomEvent('updateavailableandselectedcometorderlist',{detail:this.removeSelectedCometOrder});
    this.dispatchEvent(removeCometOrderEvent);
    })
    .catch(error => {
        this.error = error;
        console.log('ERROR',this.error);
    });
    
    }


    //To send program and user id
    onClickOfSubmitToWarehouse(event){
        submitSelectedOrdersToComet({selectedProgramId:this.getProgramId,selectedUserId:this.getUserId})
        .then(result => {
            this.submitToWareHouseResult = result;
            //custom event updateavailableandselectedcometorderlist is called in the parent html as an element
            const submitToWarehouseEvent = new CustomEvent('updateavailableandselectedcometorderlist',{detail:this.submitToWareHouseResult});
            this.dispatchEvent(submitToWarehouseEvent);
            const toastEvent = new ShowToastEvent({
                title: 'Success',
                message: 'The order has been submitted to the warehouse.',
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(toastEvent);
        })
        
       //to handle error
        .catch(error => {
            this.error = error;
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'The order is not submitted to warehouse',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        });
       
    }
}