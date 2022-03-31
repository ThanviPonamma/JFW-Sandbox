import { LightningElement,wire,track,api } from 'lwc';
import getAllUserPrograms from '@salesforce/apex/UserOrderSummary.getProgramList'
import getAllUserOderSummaryReport from '@salesforce/apex/UserOrderSummary.ReportWithUserOrders'
import { refreshApex } from '@salesforce/apex';


export default class DfvUserOrderSummaryReport extends LightningElement {
    @track value = '';
    @track inProgress;
    @track selectedUserProgramId = '';
    @track hrefdata;
    @track getUserOrderSummaryReport;
    @track amountAvailable = 0;
    @track totalAmountSpent = 0;
    @track TotalAmount;


    @wire(getAllUserPrograms)
    wiredAllPrograms({data,error}){
        if(data){
            this.inProgress = [{value : '', label:'Select'}];
           
            data.forEach(element => {
                const programs = {};
               
                programs.label = element.Name__c;
              
                programs.value = element.Id;
              
                this.inProgress.push(programs);
                
              
            });
        }
        else if(error){
            console.log('Error', error.body.message , 'error');
        }
    }

    
    handleProgramChange(event){
       
        this.selectedUserProgramId = event.detail.value;
      //  console.log('selectedUserProgramId',this.selectedUserProgramId)

      
    }
   

    @wire(getAllUserOderSummaryReport, {programId :'$selectedUserProgramId'})
    userOrderSummaryReport;
   
    get userResponseResult(){
        if(this.userOrderSummaryReport.data){
      
             this.getUserOrderSummaryReport = this.userOrderSummaryReport.data;
            //  Author : Vanditha and Vighnesh 
            // Date :26 may 2020
            // Aim :To add the total Amount Spent for a user 
            for (var i in this.getUserOrderSummaryReport) {
                 
          
              this.amountAvailable = this.getUserOrderSummaryReport[i].TotalOrderAmount;
      
              this.totalAmountSpent = this.totalAmountSpent + this.amountAvailable;
             
      
          }
           this.TotalAmount = this.totalAmountSpent;
       

              if(this.getUserOrderSummaryReport.length){
                  this.totalAmountSpent = 0;
               return refreshApex(this.userOrderSummaryReport);
                 
               
              }
        }   
    }

     //  To download the report using csv 
     exportToCSV() {  
        let columnHeader = ["Program Name","Designation Name","Ordered By","Order Number","Order Date","Order Status","Order Amount","Budget Remaining in $"];  // This array holds the Column headers to be displayd
        let jsonKeys = ["programName","ChairName", "ChairUserName","OrderName","OrderDate","OrdStatus","TotalOrderAmount","BudgetAvailable"]; // This array holds the keys in the json data  
        var jsonRecordsData = this.userOrderSummaryReport.data;  
      //  console.log('program data', JSON.stringify(jsonRecordsData));
        let csvIterativeData;  
        let csvSeperator  
        let newLineCharacter;  
        csvSeperator = ",";  
        newLineCharacter = "\n";  
        csvIterativeData = "";  
        csvIterativeData += columnHeader.join(csvSeperator);  
        csvIterativeData += newLineCharacter;  
 
        for (let i = 0; i < jsonRecordsData.length; i++) { 
     
          let counter = 0;  
          for (let iteratorObj in jsonKeys) {  
            let dataKey = jsonKeys[iteratorObj];  
   
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