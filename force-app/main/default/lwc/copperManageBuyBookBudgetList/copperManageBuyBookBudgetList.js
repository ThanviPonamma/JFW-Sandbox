import { LightningElement, wire, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//to import the list of buy book from the apex class "CopperManageBuyBookBudget_Apex" with the method "loadBuyBookList_Apex"
import loadBuyBookList from '@salesforce/apex/CopperManageBuyBookBudget_Apex.loadBuyBookList_Apex'
//to import thebudget from the apex class "CopperManageBuyBookBudget_Apex" with the method "loadBuyBookList_Apex"
import loadChairBudgetList from '@salesforce/apex/CopperManageBuyBookBudget_Apex.loadChairBudgetList_Apex'
//to import the save budget from the apex class "CopperManageBuyBookBudget_Apex" with the method "checkAndValidateAllocatedChairBudget_Apex"
import checkAndValidateAllocatedChairBudget from '@salesforce/apex/CopperManageBuyBookBudget_Apex.checkAndValidateAllocatedChairBudget_Apex'

export default class CopperManageBuyBookBudgetList extends LightningElement {
    //to hold the buy book list for the combo-box
    @track buyBookListToDisplay;
    //to hold the selected buy book Id
    @track selectedBuyBookId;
    //to hold the chair budget details 
    @track chairBudgetList;
    //to hold the total marketing budget
    @track totalMarketingBudget = 0;
    //to hold the allocated marketing budget
    @track allocatedMarketingBudget;
    //to hold the available marketing budget
    @track availableMarketingBudget;
    //to hold shared budget
    @track sharedBudget;
    //to hold the remaing budget value
    @track remainingBudget;


    //to get the data from 'loadBuyBookList' to display under the drop dowm
    @wire(loadBuyBookList)
    loadBuyBookList({ data, error }) {
        // If the loadBuyBookList has data
        if (data) {
            // get the value and label for each buyBook in the program list
            this.buyBookListToDisplay = [{ value: '', label: 'All Buy Book' }];
            // for each buyBook
            data.forEach(element => {
                const buyBook = {};
                //set buyBook name to the label property
                buyBook.label = element.Name__c;
                // Set the buyBook id to the value property
                buyBook.value = element.Id;
                // push the buyBook data to "buyBook" property
                this.buyBookListToDisplay.push(buyBook);
            });
        }

    }
    //to capture the buy book id end it to the parameter in init method
    handleChangeForBuyBook(event) {
        this.selectedBuyBookId = event.target.value;
        if (this.selectedBuyBookId != '') {
            this.getChairBugetForBuyBook();
        }
        else {
            this.chairBudgetList = null;
        }

    }

    //to get the chair budget for selected buyBook
    getChairBugetForBuyBook(event) {
        // invoke the method loadChairBudgetList with the parameter Buy book Id
        loadChairBudgetList({
            buyBookId: this.selectedBuyBookId
        })

            .then(result => {
                this.chairBudgetList = result;
                // console.log('result->',JSON.stringify(result));
                if (this.chairBudgetList.length > 0) {
                    this.totalMarketingBudget = this.chairBudgetList[0].chairBudget.Program__r.Program_Budget__c ? this.chairBudgetList[0].chairBudget.Program__r.Program_Budget__c : 0;
                    this.allocatedMarketingBudget = 0;
                    this.availableMarketingBudget = 0;
                    this.remainingBudget = 0;
                    this.sharedBudget = 0;
                    for (var i = 0; i < this.chairBudgetList.length; i++) {
                        this.allocatedMarketingBudget += this.chairBudgetList[i].chairBudget.Allocated_Budget__c ? this.chairBudgetList[i].chairBudget.Allocated_Budget__c : 0;
                        this.availableMarketingBudget += this.chairBudgetList[i].chairBudget.Available_Budget__c ? this.chairBudgetList[i].chairBudget.Available_Budget__c : 0;
                        this.sharedBudget += this.chairBudgetList[i].chairBudget.Shared_Budget__c ? this.chairBudgetList[i].chairBudget.Shared_Budget__c : 0;
                    }
                    //to set remaining budget value 
                    this.remainingBudget = this.totalMarketingBudget - this.availableMarketingBudget;
                }
            })
    }
    calculateDifferenceInAllocatedBudget(event) {
        var allocatedBudget = 0;
        allocatedBudget = event.target.value


        checkAndValidateAllocatedChairBudget({
            buyBookId: this.selectedBuyBookId,
            chairBudgetId: event.target.dataset.id,
            newAllocatedBudgetValue: allocatedBudget
        })
            .then(result => {
                if (result == 'The budget cannot be increased') {
                    const evt = new ShowToastEvent({
                        message: 'The budget cannot be increased.',
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);
                }
                else if (result == 'The budget cannot be decreased') {
                    const evt = new ShowToastEvent({
                        message: 'The budget cannot be decreased.',
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);
                }
                else {
                    const evt = new ShowToastEvent({
                        message: 'The budget has been updated.',
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);
                }
                this.getChairBugetForBuyBook();
            })

    }
}