import { LightningElement,wire,api,track} from 'lwc';

//To get all the comet orders that requires Approval
import loadAllCometApprovalOrders from '@salesforce/apex/WilsonManageApproval_Apex.loadAllCometApprovalOrders';
//To get all the shipping method List
import loadShippingMethodList from '@salesforce/apex/WilsonManageApproval_Apex.loadShippingMethodList';
// Import method refresh the page
import { refreshApex } from '@salesforce/apex';
 // To add publish and subscribe model
import pubsub from 'c/pubsub' ;

export default class WilsonManageApprovalsComponent extends LightningElement {
 //to hold the list of all comet orders that requires approval
 @api cometOrders;
 //to hold all the shiping method list
 @api shippingMethodList;
 //to check if the comet orders exists
 @track isCometOrders = false;
 //to check if the shipping methods exists
 @track isShippingMethod = false;
 //to check the refresh condition
 @track  refresh='';
// to show the spinner whne page is loaded
   // for spinner
   @track isLoading = false;
      
   // to display error message if no result found
   @track approvalItemsFound;
 //to invoke the load the come order apex
 @wire(loadAllCometApprovalOrders)
   getCometOrders;
 //to invoke the load shipping method apex
 @wire(loadShippingMethodList)
   getShippingMethodList;

 //To get the comet order for approvals 
 get cometOrderApprovalList(){
   this.isLoading = true;
   if(this.getCometOrders.data){
     this.cometOrders = this.getCometOrders.data;
      this.isCometOrders = true;
      if(this.cometOrders.length==0){
       this.approvalItemsFound=false;
         // variable check for spinner
       this.isLoading = false;
   }
   else{
       this.approvalItemsFound=true;
       this.isLoading = false;
   }
   }
 }
   //To get theshipping methods for approvals 
   get shippingMethod(){
     if(this.getShippingMethodList.data){
       this.shippingMethodList = this.getShippingMethodList.data;
       this.isShippingMethod = true;
        //to check if the refresh of the order has occured from the child through custom event
       if(this.refresh == 'refresh'){
      
       this.invokeChildRefresh()
     }
     }
   }
   //to re-invoke the init method in child when the child has to be refreshed
   invokeChildRefresh(){
     if(this.isCometOrders && this.isShippingMethod){
       //doInit is of type @api in the child  
       this.template.querySelector('c-wilson-manage-approvals-order-details').doInit();
     }
   }


   //custom event from child
   refreshApprovalOrderList(event){
     //capture the value from the event
     this.refresh=event.detail;
     //reset the value to false
     this.isCometOrders = false;
     //reset the value to false
     this.isShippingMethod = false;
     //re-invoke apex class to get order for approval
     refreshApex(this.getCometOrders);
     //re-invoke apex class to get shipping method list for approval
     refreshApex(this.getShippingMethodList);
   }


   //to navigate home page on click of the bread crumbs
   navigateToHomePage(event){
     // The fire event is used to publish the event 
     pubsub.fire('homeevent', 'home' );
   }
}