/**  Author:Thanvi;Date:20-SEP-2021
 * Aim: To dispaly the open program list with the budget details */
import { LightningElement,track,wire} from 'lwc';
// to display no image
import noImage from '@salesforce/resourceUrl/noimageavailable'; 
// To add publish and subscribe model
import pubsub from 'c/pubsub';
import getAllProgramList from '@salesforce/apex/InfiniumOpenProgramList_Apex.getProgram_ChairBudgetList_Apex'
// to refresh the apex page whenever any changes hapeens in the componenet
import {refreshApex} from '@salesforce/apex';
export default class InfiniumOpenProgramListComponent extends LightningElement {
    // no image variable
    NoImageURL = noImage;
    @track programList;

    @wire(getAllProgramList) openProgramList;

    //to get the list of program list on page init 
    get getAllOpenProgram() {
        //   check if the openProgramList has data 
        if (this.openProgramList.data) {
            this.programList = (this.openProgramList.data);
        }
        refreshApex(this.openProgramList);
    }
    //
    goToCartItemsComponent(event){
        var eventDetail = event.target.value;
        var programDetail = eventDetail.program_chairBudget;
        //The pos item menu page is called using pubsub model.
        pubsub.fire('managepositemtocartevent', 'positemtocart');
        //to hold the program detail
        pubsub.fire('selectedprogramdetailevent', programDetail);
    }
}