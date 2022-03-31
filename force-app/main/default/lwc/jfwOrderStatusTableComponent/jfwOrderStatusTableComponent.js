//Author: VB , SN , TP,VM
// Date: 12th October 2020
//Aim:To hold the functinalities of Edit details and view details buttons ,the popup modal of view details, search filter and the table which displays contents of the order status page.

import { LightningElement, wire , track,api} from 'lwc';
// to get all the ordered details from the apex method 'getAllInventoryOrders' of the apex class "JFWInventoryOrderStatus_Apex"
import getAllInventoryOrders from '@salesforce/apex/JFWInventoryOrderStatus_Apex.getAllInventoryOrders'
// To get the selected ordered details to view the data from the apex method "getOrderDetailsOfSelectedOrder"
import getOrderDetailsOfSelectedOrder from '@salesforce/apex/JFWInventoryOrderStatus_Apex.getOrderDetailsOfSelectedOrder'
// To get the no image from the static resource
import noImage from '@salesforce/resourceUrl/noimageavailable';
// to naviage to the next page
import { NavigationMixin } from 'lightning/navigation';
// to refresh the apex method when the event is invoked
import { refreshApex } from '@salesforce/apex';

export default class JfwOrderStatusTableComponent extends NavigationMixin(LightningElement) {
 
    // to get the search keyword from the parent component
    @api searchKey = '';
    // to store the selected ordered id to view the order
    @track viewDetailsOrderId;
    // to hold the ordered details
    @track orderStatus;
    // to bind the order details in the popup modal
    @track orderDestinationDetail;
     // boolean variable to  open the popup modal
     @track isModalOpen = false;
    // boolean variable for the order status as open 
    @track statusOpen=false;
    // boolean variable if the order needs approval 
    @track statusNeedApproval=false;
   // boolean variable if the order has the status send
    @track statusSend = false;
     // boolean variable if the order status is submitted
    @track statusSubmit=false;
    //boolean variable if the order status is InProcess
    @track statusInProcess=false;
     // boolean variable if the order status is shipped
    @track statusShipped = false;
    // for the order status rejected
    @track statusRejected = false;
    // for the order status rejected
    @track orderFailed = false;
    // Rejected dude to shipping method
    @track shippingMethodRejected =false;
    // boolean variable if the order status is found
    @track orderStatusFound;
    //To hold the trachig number list
    @track trackNoList;
    // To hold tracking number
    @track trackingNo;

    // to hold tracking number list
    @track trackingNosList;
    //to display the comet order details in the pop-up
    @track cometOrderAddressDetails;
    

    // Variable to hold if no image is found
    NoImageURL = noImage;


    // for spinner
     @track isLoading = false;

    //To hold all the ordered details from the apex method 'getAllInventoryOrders' of the apex class "JFWInventoryOrderStatus_Apex"
    @wire(getAllInventoryOrders, {searchKeyword :'$searchKey'}) 
    receivedInventoryOrders;


    //To hold the order statuses fetched from the backend on init.
       get orderStatusData(){
        // to add the spinner
            this.isLoading = true;
           if (this.receivedInventoryOrders.data){
             this.orderStatus = this.receivedInventoryOrders.data;
            // console.log('orderStatus--->',JSON.stringify(this.orderStatus));
            // to check if the variable order status has the data or not
             if(this.orderStatus.length==0){
                 this.orderStatusFound=false;
                   // variable check for spinner
                 this.isLoading = false;
             }
             else{
                 this.orderStatusFound=true;
                 this.isLoading = false;
             }
                        
           }    
            refreshApex(this.receivedInventoryOrders); 
       }

//To open view details modal for the selected order
    openModal(event) {
        this.isModalOpen = true;
        this.trackingNosList=[];
        this.viewDetailsOrderId = event.target.dataset.id;
        this.cometOrderAddressDetails = event.target.value;
         this.trackingNo = this.cometOrderAddressDetails.TrackingNos__c;
        getOrderDetailsOfSelectedOrder ({orderDestinationId:this.viewDetailsOrderId})
        .then(result =>{
            this.orderDestinationDetail = result;
          //  console.log('orderDestinationDetail returing--->',JSON.stringify(this.orderDestinationDetail));
           for(let i=0;i<this.orderDestinationDetail.length;i++){
                 this.orderStatus = this.orderDestinationDetail[i].OrderItems.OrderDestination__r.OrdStatus__c;
            this.statusOpen=false;
            this.statusNeedApproval=false;
            this.statusSend = false;
            this.statusSubmit=false;
            this.statusShipped = false;
            this.statusRejected = false;
            this.orderFailed = false;
            this.shippingMethodRejected =false;
            this.statusInProcess = false;
     
            if(this.orderStatus == 'Open'){
               this.statusOpen = true;
     
            }
            if(this.orderStatus == 'Needs Approval'){
              
                this.statusNeedApproval = true;
               
             }
             if(this.orderStatus == 'Send to Comet'){
                this.statusSend = true;
             }
             if(this.orderStatus == 'This order has been submitted to Comet'){
                this.statusSubmit = true;

             }
             if(this.orderStatus == 'Shipped'){
                this.statusShipped = true;
             }

             if(this.orderStatus == 'InProcess'){
                 this.statusInProcess = true;
             }

             if(this.orderStatus == 'Rejected'){
                this.statusRejected = true;
             }
             if(this.orderStatus == 'This order failed to submit'){
                this. orderFailed = true;
             }
             if(this.orderStatus == 'Rejected due to choice of Shipping method'){
                this. shippingMethodRejected = true;
             }
             
            }   
            if(this.trackingNo!=null){
                  
                let splittedTrackingNos=this.trackingNo.split(',');
               
               for(let i=0;i<splittedTrackingNos.length;i++)
               {
                  
                   this.trackingNosList.push(splittedTrackingNos[i].trim());
                  
               }
               this.trackNoList = this.trackingNosList;
             
              }
              else{
                this.trackNoList=[];
              }
        })

    .catch(error => {
        this.error = error;
        console.log('ERROR', this.error);
    });
    
}


onClickOfTrackingNo(event){
 // tracking no    
 let trackingNo = event.target.value;  
            this[NavigationMixin.Navigate]({
                "type": "standard__webPage",
                "attributes": {
                    "url": "https://www.fedex.com/fedextrack/?trknbr="+trackingNo
                }
            });
}
    


//To close the view details of an order on click of cancel or close button.
    closeModal(){
        this.isModalOpen = false;
        refreshApex(this.receivedInventoryOrders); 
   }

   //Custom event is sent to the parent component to navigate the edit order button to the shopping cartpage. 
   openShoppingCartDetails(){
   const sendToParent = new CustomEvent('callshippingcartcomponent');
   this.dispatchEvent(sendToParent);
}
}