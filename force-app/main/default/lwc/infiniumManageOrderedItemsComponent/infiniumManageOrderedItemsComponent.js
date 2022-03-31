import { LightningElement,api,track } from 'lwc';

export default class InfiniumManageOrderedItemsComponent extends LightningElement {
// Aim : To hold the incoming program Id selected by the user
@api selectedProgramId='';

// Aim : To hold the incoming brand Id selected by the user
@api selectedBrandId='';

//To detaermine if Program and brand id are obtained and set the status
programBrandDetails=false;

// To refresh the child component
isRefreshList=false;


//Event to capture the selected program Id from the child component
selectionOfProgramId(event){
     // To set the program brand details to false
         this.programBrandDetails=false;
         this.selectedProgramId = event.detail;

     //   Check if the selected brandid and selected programId is not null
         if(this.selectedBrandId!='' && this.selectedProgramId!=''){
          //     set the programBrandDetails to true
          this.programBrandDetails=true;
          this.isRefreshList=false;
         }
    }


//Event to capture the selected brand Id from the child component
 selectionOfBrandId(event){
       // To set the program brand details to false
       this.programBrandDetails=false;
        this.selectedBrandId = event.detail;
        //   Check if the selected brandid and selected programId is not null
        if(this.selectedBrandId!='' && this.selectedProgramId!=''){
          //     set the programBrandDetails to true
          this.programBrandDetails=true;
          this.isRefreshList=false;
         
         }
   }

//Event to refresh the child components
    pageRefreshEvent(event){
        if(this.isRefreshList)
         {
             this.programBrandDetails=true;
             this.isRefreshList = false;
       
         }
        else
            {
               this.programBrandDetails=false;
               this.isRefreshList = true;
            }
    }

}