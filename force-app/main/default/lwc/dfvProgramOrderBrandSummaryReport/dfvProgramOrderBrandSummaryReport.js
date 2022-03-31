import { LightningElement,track,wire,api} from 'lwc';
import getAllPrograms from '@salesforce/apex/ProgramOrderBrandSummary.getProgramList'
import getProgramBrandList from '@salesforce/apex/ProgramOrderBrandSummary.ReportWithTotalBrandOrder'
import { refreshApex } from '@salesforce/apex';


export default class DfvProgramOrderBrandSummaryReport extends LightningElement {
    @track value = '';
    @track programBrandDetails;
    @track itemProgramId ='';
    @track hrefdata;
    @track programBrandOrderSummary;
    @track getprogramBrandOrderSummary;
    @track amountAvailable = 0;
    @track totalAmountSpent = 0;
    @track TotalAmount;

 


    @wire(getAllPrograms)
    wireprogramData({data,error}){
        if(data){
            this.programBrandDetails=[{value :'' , label:'Select'}];
         
            data.forEach(element => {
                const programs = {};
               
                programs.label = element.Name__c;
               
              
                programs.value = element.Id;
           
              
                this.programBrandDetails.push(programs);
              
                
              
            });
        }
        else if(error){
            console.log('Error', error.body.message , 'error');
        }
    }

    handleProgramChange(event){
        this.itemProgramId = event.detail.value;
    //    console.log('program Id present ',this.itemProgramId);
    
    }
    @wire(getProgramBrandList, {programId:'$itemProgramId'})
    programBrandOrderSummary;

    get programBrandResult(){
      
        if(this.programBrandOrderSummary.data){
   
             this.getprogramBrandOrderSummary = this.programBrandOrderSummary.data;
           
           //  Author : Vanditha and Vighnesh 
            // Date :26 may 2020
            // Aim :To add the total Amount Spent for a user 
            for (var i in this.getprogramBrandOrderSummary) {
                 
                this.amountAvailable = this.getprogramBrandOrderSummary[i].ItemTotalAmountForBrand;
        
                this.totalAmountSpent = this.totalAmountSpent + this.amountAvailable; 
        
            }
             this.TotalAmount = this.totalAmountSpent;
          
            if(this.getprogramBrandOrderSummary.length){
                this.totalAmountSpent = 0;
                return refreshApex(this.programBrandOrderSummary); 
            }
          
        }
    }
   
   

     //  To download the report using csv 
     exportToCSV() {  
        let columnHeader = ["Program Name","Brand Name","Total Amount spent on the Brand in $"];  // This array holds the Column headers to be displayd
        let jsonKeys = ["ProgramName","BrandName","ItemTotalAmountForBrand"]; // This array holds the keys in the json data
        var jsonRecordsData = this.programBrandOrderSummary.data;  
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