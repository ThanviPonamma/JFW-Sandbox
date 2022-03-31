import { LightningElement,track,wire,api } from 'lwc';
import getProgramList from '@salesforce/apex/InfiniumProgramPlaybook_Apex.getProgramList_Apex';
import getPOSItemList from '@salesforce/apex/InfiniumProgramPlaybook_Apex.getProgramItems_Apex';
// to display no image
import noImage from '@salesforce/resourceUrl/noimageavailable';
//to get the account details
import getAccountDetails from '@salesforce/apex/InfiniumProgramPlaybook_Apex.getAccount';
//the below line is used to navaigate to the visual force page using the URL for the user to download Playbook  pdf file
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';

export default class InfiniumProgramPlaybookListComponent extends NavigationMixin(LightningElement){
    // no image variable
    NoImageURL = noImage;
    //to hold the list of proram
    @track programListToDisplay;
    //to hold the program selected by the user
    @track selectedProgramId;
    //to hold the program items
    @track programItemList;
    //to check if the items list is empty or not
    @ track isProgramItemAvailable=false;
    //to hold the account URl
    @track accountURL;

    @wire(getProgramList)
    loadProgramList({ data, error }) {
        // If the getProgramList has data
        if (data) {
            // get the value and lable for each brand in the program list
            this.programListToDisplay = [{ value: '', label: 'AllProgram' }];
            // for each program
            data.forEach(element => {
                const program = {};
                //set program name to the lable property
                program.label = element.Name__c;
                // Set the program id to the value property
                program.value = element.Id;
                // push the program data to "programListToDisplay" property
                this.programListToDisplay.push(program);
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
    //get program Id
    handleChangeForProgram(event) {
        //to fetch the seleted program Id
        this.selectedProgramId = event.target.value;
        if (this.selectedProgramId != '') {
            this.getProgramItems();
        }
        else {
            this.programItemList = null;
            this.isProgramItemAvailable=false;
        }
    }
    //to get the items for selected proram
    getProgramItems(event) {
        // invoke the method loadChairBudgetList with the parameter Buy book Id
        getPOSItemList({
            programId: this.selectedProgramId
        })
            .then(result => {
                this.programItemList = result;
                if(this.programItemList.length>0){
                    this.isProgramItemAvailable=true;
                }
                else
                {
                    this.isProgramItemAvailable=false;
                }

            })
    }

    //event that is invoked onclick of the 'download PDF' button which is responsible to navigate to the visual force page Infinium_PlayBook_Logo and download pdf file
    downloadPlayBook() {
        //  check if the variable brandValue is not empty or not null
        if (this.selectedProgramId != '' || this.selectedProgramId != null) {
            //  navigate to the visual force page Infinium_PlayBook_Logo 
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__webPage',
                attributes: {
                    url:  this.accountURL+'/Infinium_PlayBook_Logo'+'?id='+this.selectedProgramId
                }
            }).then(generatedUrl => {
                window.open(generatedUrl);
            });
        }
    }
}