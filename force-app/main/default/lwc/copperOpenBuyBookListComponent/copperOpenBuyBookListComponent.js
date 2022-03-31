/**  Authors: Thanvi ; Date- 30/Aug/21
 * Aim: To dispaly the open buy book list with the budget details */
import { LightningElement,track,wire} from 'lwc';
// to display no image
import noImage from '@salesforce/resourceUrl/noimageavailable'; 
// To add publish and subscribe model
import pubsub from 'c/pubsub';
import getAllBuyBookList from '@salesforce/apex/CopperOpenBuyBookList_Apex.getBuyBook_ChairBudgetList_Apex'
// to refresh the apex page whenever any changes hapeens in the componenet
import {refreshApex} from '@salesforce/apex';
export default class CopperOpenBuyBookListComponent extends LightningElement {
    // no image variable
    NoImageURL = noImage;
    @track buyBookList;

    @wire(getAllBuyBookList) openBuyBookList;

    //to get the list of buy book list on page init 
    get getAllOpenBuyBook() {
        //   check if the openBuyBookList has data 
        if (this.openBuyBookList.data) {
            this.buyBookList = (this.openBuyBookList.data);
        }
        refreshApex(this.openBuyBookList);
    }
    //
    goToCartItemsComponent(event){
        var eventDetail = event.target.value;
        var buyBookDetail = eventDetail.buyBook_chairBudget;
        //The pos item menu page is called using pubsub model.
        pubsub.fire('managepositemtocartevent', 'positemtocart');
        //to hold the buyBook detail
        pubsub.fire('selectedbuybookdetailevent', buyBookDetail);
    }
}