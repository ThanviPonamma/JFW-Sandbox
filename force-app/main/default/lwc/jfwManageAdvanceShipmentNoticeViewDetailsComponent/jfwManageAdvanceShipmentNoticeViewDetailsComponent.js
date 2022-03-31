//  Authors:SN,JP
// Date:21-10-2020
// Aim: pop-up modal to view submitted ASN on click of "view details" icon 
import { LightningElement,wire,api,track} from 'lwc';
//importing a method getSubmittedASNPosItemsList from the class JFWGetSubmittedASNList_Apex
import getAllASNDetails from '@salesforce/apex/JFWGetSubmittedASNList_Apex.getSubmittedASNPosItemsList'


export default class JfwManageAdvanceShipmentNoticeViewDetailsComponent extends LightningElement {
    //to hold asn details
    @api getAsnDetails;
    //to hold the Id of selected asn
    @track selectedASNId;
    //to hold all the asn details to be displayed
    @track detailsToBeDisplayed;
    //to hold all the asn details
    @track asnDetails;

    //to get asn Id fetched from parent
    connectedCallback(){
      // to hold all the asn details from parent
        this.asnDetails = JSON.parse(JSON.stringify(this.getAsnDetails));
        // to hold the Id of selected asn from parent
        this.selectedASNId = this.asnDetails.Id;
        
      }

      //fetch the list of asn details for selected asn Id
    @wire(getAllASNDetails,{existingId:'$selectedASNId'}) allAsnDetails;

    //to get all the asn details
    get existingASNDetails(){
      // if the details exists for the asn Id
        if(this.allAsnDetails.data){
          //fetch the asn details and store it in the variable detailsToBeDisplayed
        this.detailsToBeDisplayed = this.allAsnDetails.data;

        }
    }
//to close the pop-up modal
    closeModal(){
      //custom event sent to the parent along with boolean value to close the pop-up modal
        const closeButton = new CustomEvent('closemodal', {
          detail: {
            isViewModal: false
          } 
        });
        this.dispatchEvent(closeButton);
      }
}