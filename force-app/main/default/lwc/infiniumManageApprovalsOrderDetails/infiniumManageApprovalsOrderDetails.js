import {
    LightningElement,
    api,
    track
} from 'lwc';

//To save the approved shippping method
import approveShippingMethod_Apex from '@salesforce/apex/InfiniumManageApproval_Apex.approveShippingMethod';
//To save the rejected shippping method
import rejectShippingMethod_Apex from '@salesforce/apex/InfiniumManageApproval_Apex.rejectShippingMethod';
//To save the approved items
import approveOrderedItem_Apex from '@salesforce/apex/InfiniumManageApproval_Apex.approveOrderedItem';
//To save the rejected items
import rejectOrderedItem_Apex from '@salesforce/apex/InfiniumManageApproval_Apex.rejectOrderedItem';
//To save the approved max ordered item
import approveMaximumOrderQuantity_Apex from '@salesforce/apex/InfiniumManageApproval_Apex.approveMaximumOrderQuantity';
//To save the rejected max ordered item
import rejectMaximumOrderQuantity_Apex from '@salesforce/apex/InfiniumManageApproval_Apex.rejectMaximumOrderQuantity';


export default class InfiniumManageApprovalsOrderDetails extends LightningElement {
    
    // to get the comet order details from parent component
    @api cometOrderFromParent;

    // to get the shiiping method fromparent component
    @api shippingMethodFromParent;

    // to store the comet order item details
    @track cometOrderDetailsList;

    // to store the shipping method
    @track shippingMethodNameToDisplay;
 
    //to display error message if approved quantity increases the ordered quantity

    connectedCallback() {
        this.doInit();
    }

    @api
    doInit() {
      
        this.cometOrderDetailsList = JSON.parse(JSON.stringify(this.cometOrderFromParent));
        // console.log('this.', JSON.stringify(this.cometOrderDetailsList))
        
     
        if (this.shippingMethodFromParent) {
            let shippingMethodData = [];
            this.shippingMethodFromParent.forEach(element => {
                const shippingmethod = {};
                shippingmethod.label = element.Shipping_Method_Name__c;
                shippingmethod.value = element.Id;
                shippingMethodData.push(shippingmethod);
                this.shippingMethodNameToDisplay = shippingMethodData;
            });

            
        }
        this.showSpinner = false;
    }
// To get the selected shipping method id
    onChangeShippingMethod(event) {
        this.cometOrderDetails.cometOrder.Shipping_Method__c = event.target.value;
    }

    // to send the shipping method for approval
    approveShippingMethodOrder(event) {
        let updatedCometOrder = event.target.value;
        // console.log('The approval shipping method',JSON.stringify(updatedCometOrder))
        approveShippingMethod_Apex({
                cometOrder: updatedCometOrder
            })
            .then(result => {
                let resultGiven = result;
                const refreshApproval = new CustomEvent('refreshorderapproval', {
                    detail: 'refresh'
                });
                this.dispatchEvent(refreshApproval);

            })

    }
    // to send the shipping method for rejecting 
    rejectShippingMethodOrder(event) {
        let updatedCometOrder = event.target.value;
        // console.log('The reject shipping method--->',JSON.stringify(updatedCometOrder))
        rejectShippingMethod_Apex({
                cometOrder: updatedCometOrder
            })
            .then(result => {
                let resultGiven = result;
                const refreshApproval = new CustomEvent('refreshorderapproval', {
                    detail: 'refresh'
                });
                this.dispatchEvent(refreshApproval);
            })
    }
     // to send the item for approval
    approveItem(event) {
        let updatedCometOrderItem = event.target.value;
        approveOrderedItem_Apex({
                cometOrderItem: updatedCometOrderItem
            })
            .then(result => {
                let resultGiven = result;
                const refreshApproval = new CustomEvent('refreshorderapproval', {
                    detail: 'refresh'
                });
                this.dispatchEvent(refreshApproval);
            })
    }

      // to send the item for rejecting 
    rejectItem(event) {
        let updatedCometOrderItem = event.target.value;
        rejectOrderedItem_Apex({
                cometOrderItem: updatedCometOrderItem
            })
            .then(result => {
                let resultGiven = result;
                const refreshApproval = new CustomEvent('refreshorderapproval', {
                    detail: 'refresh'
                });
                this.dispatchEvent(refreshApproval);
            })
    }

    // onchange event for the max order quntity
    validateQty(event) {
        //get the value entered in the input field
        let approvedQuanity = event.target.value;
        //to get the selected quanity
        let orderDetails = event.target.name;
        //compare the values
        // console.log('approvedQuanity--->',approvedQuanity);
        // console.log('orderDetails.Quantity__c',orderDetails.SelectedQuantity__c);
        if (approvedQuanity <= orderDetails.SelectedQuantity__c) {
            for (var i = 0; i <this.cometOrderDetailsList.length; i++) {
                for (var j = 0; j <this.cometOrderDetailsList[i].cometOrderItemsForMaxOrdQtyApprovalWithQuantityDisable.length; j++) {
                    if (this.cometOrderDetailsList[i].cometOrderItemsForMaxOrdQtyApprovalWithQuantityDisable[j].cometOrderItemsForMaxOrdQtyApproval.Id == event.target.dataset.id) {
                        this.cometOrderDetailsList[i].cometOrderItemsForMaxOrdQtyApprovalWithQuantityDisable[j].isdisableQuantity = false;
                        // console.log('value lesser-->',this.cometOrderDetailsList[i].cometOrderItemsForMaxOrdQtyApprovalWithQuantityDisable[j].isdisableQuantity)
                        this.cometOrderDetailsList[i].cometOrderItemsForMaxOrdQtyApprovalWithQuantityDisable[j].cometOrderItemsForMaxOrdQtyApproval.Quantity__c = approvedQuanity;
                    }

                }
            }
        } else {
            for (var i = 0; i <this.cometOrderDetailsList.length; i++) {
                for (var j = 0; j <this.cometOrderDetailsList[i].cometOrderItemsForMaxOrdQtyApprovalWithQuantityDisable.length; j++) {
                    if (this.cometOrderDetailsList[i].cometOrderItemsForMaxOrdQtyApprovalWithQuantityDisable[j].cometOrderItemsForMaxOrdQtyApproval.Id == event.target.dataset.id) {
                        this.cometOrderDetailsList[i].cometOrderItemsForMaxOrdQtyApprovalWithQuantityDisable[j].isdisableQuantity = true;
                        // console.log('value exceeded--->',this.cometOrderDetailsList[i].cometOrderItemsForMaxOrdQtyApprovalWithQuantityDisable[j].isdisableQuantity)
                        this.cometOrderDetailsList[i].cometOrderItemsForMaxOrdQtyApprovalWithQuantityDisable[j].cometOrderItemsForMaxOrdQtyApproval.Quantity__c = approvedQuanity;
                    }
                }
            }
        }


    }

    // To send the entered max order quntity for approval
    approveMaxOrderQty(event) {
        let updatedCometOrderItem = event.target.value;
        console.log(updatedCometOrderItem);
        approveMaximumOrderQuantity_Apex({
                cometOrderItem: updatedCometOrderItem
            })
            .then(result => {
                let resultGiven = result;
                console.log(resultGiven);
                const refreshApproval = new CustomEvent('refreshorderapproval', {
                    detail: 'refresh'
                });
                this.dispatchEvent(refreshApproval);
            })
    }

    // To send the entered max order quntity for reject
    rejectMaxOrderQty(event) {
        let updatedCometOrderItem = event.target.value;
        rejectMaximumOrderQuantity_Apex({
                cometOrderItem: updatedCometOrderItem
            })
            .then(result => {
                let resultGiven = result;
                console.log(resultGiven);
                const refreshApproval = new CustomEvent('refreshorderapproval', {
                    detail: 'refresh'
                });
                this.dispatchEvent(refreshApproval);
            })
    }

    // validation for the approval quntity field
    validateNumber(event) {
        var keyCodes=[];
        for(var i=48;i<58;i++)
            keyCodes.push(i);  
        for(var i=96;i<106;i++)
            keyCodes.push(i);
        for(var i=37;i<41;i++)
            keyCodes.push(i);
        keyCodes.push(8);
        if(!keyCodes.includes(event.keyCode))
            event.preventDefault();
       
            
    }


}