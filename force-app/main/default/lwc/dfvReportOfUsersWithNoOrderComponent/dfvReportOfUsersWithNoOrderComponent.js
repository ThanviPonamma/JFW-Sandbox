import { LightningElement,track,wire } from 'lwc';
import getProgramList from '@salesforce/apex/ProgramChairBudgetForUserWithNoOrder.getProgramList'
import UserReportWithNoOrders from '@salesforce/apex/ProgramChairBudgetForUserWithNoOrder.UserReportWithNoOrders'
import { refreshApex } from '@salesforce/apex';

export default class DfvReportOfUsersWithNoOrderComponent extends LightningElement {

    @track value = '';
    @track programDetails;
    @track programOrderId;
    @track hrefdata;
    @track budgetAvaliable = 0;
    @track totalBudgetAvailable = 0;
    @track userDeatilsWithNoOrders;
    @track TotalAmount;


//to store the program names in the javascript
    @wire(getProgramList)
    wireProgramData({data,error})
    {
       if(data){
           this.programDetails=[{value :'', label:'Select'}];

           data.forEach(element => {

               const program = {};

               program.label = element.Name__c;

               program.value = element.Id;

               this.programDetails.push(program);

           });
       }
       
       else if(error){
           //console.log('Error',error.body.message , 'error');
       }
    }

 


    // Author : Vignesh and Vanditha 
    // Date : 25-05-2020
    handleProgramChange(event){
      
        this.programOrderId = event.detail.value;
        //console.log('program Id ------>', this.programOrderId);
        
    }



//  To get all orders for the selected program
@wire(UserReportWithNoOrders , {programId:'$programOrderId'})
userReportWithNoOrders;


get userReportWithNoOrderResult(){
    if(this.userReportWithNoOrders.data){

        // console.log('user with no orders details ------>',JSON.stringify(this.userReportWithNoOrders.data));

        this.userDeatilsWithNoOrders = this.userReportWithNoOrders.data;
         
        //console.log('USER DETAILS WITH NO ORDER ------>',JSON.stringify( this.userDeatilsWithNoOrders));
         

        // To get the Total budget available for loop below 
        for (var i in this.userDeatilsWithNoOrders) {
                 
          
            this.budgetAvaliable = this.userDeatilsWithNoOrders[i].BudgetAvailable;
    
            //console.log('budget Available ---->', this.budgetAvaliable);
            //console.log('Total budget Available before calcullation ---->', this.totalBudgetAvailable);
            this.totalBudgetAvailable =   this.totalBudgetAvailable + this.budgetAvaliable;
            //console.log('Total budget  Available ---->', this.totalBudgetAvailable);
    
        }
         this.TotalAmount = this.totalBudgetAvailable;
         //console.log('Total Amount --->', this.TotalAmount);

        if(this.userDeatilsWithNoOrders.length){
            this.totalBudgetAvailable = 0;
            return refreshApex(this.userReportWithNoOrders);
        }
      
    }
    
}





exportToCSV() {  
    let columnHeader = ["Program Name", "Designation Name","User","Order Status","Budget Remaning in $"];  // This array holds the Column headers to be displayd
    let jsonKeys = ["programName","ChairName","ChairUserName","OrdStatus","BudgetAvailable"]; // This array holds the keys in the json data
    var jsonRecordsData = this.userReportWithNoOrders.data;  
    // console.log('program data', JSON.stringify(jsonRecordsData));
    let csvIterativeData;  
    let csvSeperator  
    let newLineCharacter;  
    csvSeperator = ",";  
    newLineCharacter = "\n";  
    csvIterativeData = "";  
    csvIterativeData += columnHeader.join(csvSeperator);  
    csvIterativeData += newLineCharacter;  
//   console.log('length', jsonRecordsData.length);
    for (let i = 0; i < jsonRecordsData.length; i++) { 
 
      let counter = 0;  
      for (let iteratorObj in jsonKeys) {  
        let dataKey = jsonKeys[iteratorObj];  
//   console.log('counter',counter );
  
        if (counter > 0) 
        {
              csvIterativeData += csvSeperator;
              }
        
           if (  jsonRecordsData[i][dataKey] !== null &&  
          jsonRecordsData[i][dataKey] !== undefined  )
           
        {
              csvIterativeData += '"' + jsonRecordsData[i][dataKey] + '"';  
        }
         else
         {  
             csvIterativeData += '""';  
         }     
      counter++;  
      }  
      csvIterativeData += newLineCharacter;  
    }  
    //  console.log('data entered', csvIterativeData);
    this.hrefdata = "data:text/csv;charset=utf-8," + encodeURIComponent(csvIterativeData);
  }  

 

}