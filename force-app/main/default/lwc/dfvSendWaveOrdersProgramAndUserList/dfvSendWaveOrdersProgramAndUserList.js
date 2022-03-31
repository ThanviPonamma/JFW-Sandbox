import { LightningElement, track, wire } from 'lwc';
// Author - VM,VP,JP Date - June 30th 2020
//To get the list of programs from the apex class 'DFVSendWaveOrders_Apex' using the method 'loadProgramList'
import getProgramList from "@salesforce/apex/DFVSendWaveOrders_Apex.loadProgramList"

//To get the list of users from the apex class 'DFVSendWaveOrders_Apex' using the method 'loadUserList'
import getUserList from "@salesforce/apex/DFVSendWaveOrders_Apex.loadUserList"
//to refresh the page
import { refreshApex } from'@salesforce/apex';



export default class DfvSendWaveOrdersProgramAndUserList extends LightningElement {

// To hold the 'programListToDisplay' value and to make it reactive
@track programListToDisplay;

// To hold the 'loadOrderUserList' value and to make it reactive
@track loadOrderUserList;

// To hold the selected Program Id
@track selectedProgramId;

// To hold the selected User Id
@track selectedUserId;
//to hold the data entered by user is the search input
@track searchedKeyword;

@track disableIfNoUser = true;

//to get the data from 'getProgramList'
@wire(getProgramList)
    loadOrderedProgramList({data,error}){

        // If the getProgramList has data
        if(data){

            // get the value and lable for each program in the program list
            this.programListToDisplay = [{value : '', label:'Select'}];


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

        else if(error){
            // console.log('Error',error.body.message , 'error');
        }
    }

    //Aim : To capture the selected program Id
    onSelectionOfProgram(event){
        this.selectedProgramId = event.detail.value;
    
        // Custom event is called to send the selected programid
        const programEvent = new CustomEvent('selectedprogramid',{detail:this.selectedProgramId});
              this.dispatchEvent(programEvent);
                // this.loadOrderUserList.data;
                // console.log("userlist data",this.loadOrderUserList.data);

    }

    // to get the user list
    @wire(getUserList,{selectedProgramId:'$selectedProgramId'})
    loadUserList({data,error}){
  
        if(data){
            this.loadOrderUserList = [{value : '', label:'Select'}];
            this.disableIfNoUser=true;
            //for each user
            data.forEach(element => {
                const user = {};
                //set user name to the lable property
                user.label = element.Name;
                // Set the user id to the value property
                user.value = element.Id;
                // push the program data to "loadOrderUserList" property
                this.loadOrderUserList.push(user);
                if( this.loadOrderUserList.length>1)
                {
                    this.disableIfNoUser=false;
                }
            });

        }
        else if(error){
            // console.log('Error',error.body.message , 'error');
        }
    }

       //Aim : To capture the selected user Id
       onSelectionOfUser(event){
        this.selectedUserId = event.detail.value;

        const userEvent = new CustomEvent('selecteduserid',{detail:this.selectedUserId});
        this.dispatchEvent(userEvent);

    }

    // search event to hold the search word

    handleSearchEvent(event){

        this.searchedKeyword = event.detail.value;

        if(this.searchedKeyword =='' || this.searchedKeyword == null){
            // custom event "sendsearchdatatoavailable" is called in the parent html. This event holds the searchKeyword
            const searchvent = new CustomEvent('sendsearchdatatoavailable',{detail:this.searchedKeyword});
            this.dispatchEvent(searchvent);
        }

    }

    searchButtonEvent(event){
    
        if(this.searchedKeyword!='' || this.searchedKeyword!= null){
            
            // custom event "sendsearchdatatoavailable" is called in the parent html. This event holds the searchKeyword
            const searchvent = new CustomEvent('sendsearchdatatoavailable',{detail:this.searchedKeyword});
            this.dispatchEvent(searchvent);
        }
    }
    
}