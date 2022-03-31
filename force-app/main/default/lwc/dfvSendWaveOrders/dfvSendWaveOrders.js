// Author - VM,VP,JP Date - June 30th 2020
import { LightningElement,api} from 'lwc';

export default class DfvSendWaveOrders extends LightningElement {

    // Aim : To hold the incoming program Id selected by the user
    @api selectedProgramId='';

    // Aim : To hold the incoming user Id selected by the user
    @api selectedUserId='';

    // Aim : To hold the search text entered by the user
    @api searchValue='';

    // To refresh the child component
    isRefreshList=false;

    //To determine if Program and user id are obtained and to set the status
    programUserDetails=false;


    //Event to capture the selected program Id from the child component
    selectionOfProgramId(event){
        this.programUserDetails=false;
       this.selectedProgramId = event.detail;
       if(this.selectedUserId!='' && this.selectedProgramId!=''){
        //     set the programBrandDetails to true
        this.programUserDetails=true;
        this.isRefreshList=false;
       
       }
       if(this.selectedProgramId ==''){
           this.selectedUserId='';
       }
    }


//Event to capture the selected user Id from the child component
selectionOfUserId(event){
        this.programUserDetails=false;
        this.selectedUserId=event.detail;
        if(this.selectedUserId!='' && this.selectedProgramId!=''){
         //     set the programBrandDetails to true
            this.programUserDetails=true;
            this.isRefreshList=false;
           
           }
}
// Event to store the search data and store in the variable
enteredSearchValue(event){
        this.searchValue = event.detail;
}

  

// To refresh the page when the user perfrom add or remove events
pageRefreshEvent(event){
        if(this.isRefreshList)
        {
             this.programUserDetails=true;
             this.isRefreshList = false;
           
        }
        else
        {
             this.programUserDetails=false;
             this.isRefreshList = true;
        }
    
    }
}