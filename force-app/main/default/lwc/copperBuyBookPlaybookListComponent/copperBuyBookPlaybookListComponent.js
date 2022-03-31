import { LightningElement,track,wire,api } from 'lwc';
import getBuyBookList from '@salesforce/apex/CopperBuyBookPlaybook_Apex.getBuyBookList_Apex';
import getPOSItemList from '@salesforce/apex/CopperBuyBookPlaybook_Apex.getBuyBookItems_Apex';
// to display no image
import noImage from '@salesforce/resourceUrl/noimageavailable';
//to get the account details
import getAccountDetails from '@salesforce/apex/CopperBuyBookPlaybook_Apex.getAccount';
//the below line is used to navaigate to the visual force page using the URL for the user to download Playbook  pdf file
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';

export default class CopperBuyBookPlaybookListComponent extends NavigationMixin(LightningElement){
    // no image variable
    NoImageURL = noImage;
    //to hold the list of buyBook
    @track buyBookListToDisplay;
    //to hold the buy book selected by the user
    @track selectedBuyBookId;
    //to hold the buy book items
    @track buyBookItemList;
    //to get the data from 'getBuyBookList' to display under the drop dowm
    //to hold the account URl
    @track accountURL;

    @wire(getBuyBookList)
    loadBuyBookList({ data, error }) {
        // If the getBuyBookList has data
        if (data) {
            // get the value and lable for each brand in the buy book list
            this.buyBookListToDisplay = [{ value: '', label: 'All Buy Book' }];
            // for each buy book
            data.forEach(element => {
                const buyBook = {};
                //set buy book name to the lable property
                buyBook.label = element.Name__c;
                // Set the buyBook id to the value property
                buyBook.value = element.Id;
                // push the buyBook data to "buyBookListToDisplay" property
                this.buyBookListToDisplay.push(buyBook);
            });
        }

    }
    //to get the account details
    connectedCallback() {
        getAccountDetails()
            .then(result => {
                this.accountURL = result.Lightning_Community_URL__c;
            })
    }
    //get buyBook Id
    handleChangeForBuyBook(event) {

        //to fetch the seleted buyBook Id
        this.selectedBuyBookId = event.target.value;

        if (this.selectedBuyBookId != '') {
            this.getBuyBookItems();
        }
        else {
            this.buyBookItemList = null;
        }
    }
    //to get the chair budget for selected buyBook
    getBuyBookItems(event) {
        // invoke the method loadChairBudgetList with the parameter Buy book Id
        getPOSItemList({
            buyBookId: this.selectedBuyBookId
        })
            .then(result => {
                this.buyBookItemList = result;

            })
    }

    //event that is invoked onclick of the 'download PDF' button which is responsible to navigate to the visual force page Copper_PlayBook_Logo and download pdf file
    downloadPlayBook() {
        //  check if the variable brandValue is not empty or not null
        if (this.selectedBuyBookId != '' || this.selectedBuyBookId != null) {
            //  navigate to the visual force page Copper_PlayBook_Logo 
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__webPage',
                attributes: {
                    url:  this.accountURL+'/Copper_PlayBook_Logo'+'?id='+this.selectedBuyBookId
                }
            }).then(generatedUrl => {
                console.log('generatedUrl');
                console.log(generatedUrl);
                window.open(generatedUrl);
            });
        }
    }
}