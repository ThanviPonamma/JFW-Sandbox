import { LightningElement ,wire, track } from 'lwc';
import getProgramOrderItemSummaryReport from '@salesforce/apex/ProgramOrderSummary.ReportWithTotalQuantity'
import getPrograms from '@salesforce/apex/ProgramOrderSummary.getProgramList'
import { refreshApex } from '@salesforce/apex';


export default class DfvProgramOrderItemSummaryReportComponent extends LightningElement {
    @track value = '';
    @track itemProgramId ='';
    @track programDetails;
    @track hrefdata;
    @track getAllProgramsOrder;
    @track totalAmountAvailable = 0 ;
    @track totalAmountSpent = 0;
    @track TotalAmount;
   

    @wire(getPrograms)
    wireprogramData({data,error}){
        console.log('entered wire---->');

        if(data){
            console.log('entered---->');
            this.programDetails=[{value :'' , label:'Select'}];
             console.log('program',  this.programDetails);
            data.forEach(element => {
                const programs = {};
            
               
                programs.label = element.Name__c;
               
               
                programs.value = element.Id;
             

                this.programDetails.push(programs);
               
              
            });
        }
        else if(error){
            console.log('Error', error.body.message , 'error');
        }
    }

   
    handleProgramChange(event){
       
        this.itemProgramId = event.detail.value;
 
        const programSelectionChangeEvent = new CustomEvent('programselect' , {detail : itemProgramId});
     
        this.dispatchEvent(programSelectionChangeEvent);
      
    }

   

    @wire(getProgramOrderItemSummaryReport, {programId:'$itemProgramId'})
    programOrderSummaryReport;
    

    get programItemResult(){

        if(this.programOrderSummaryReport.data){
    
            this.getAllProgramsOrder = this.programOrderSummaryReport.data;
           
             //  Author : Vanditha and Vighnesh 
            // Date :26 may 2020
            // Aim :To add the total Amount Spent for a user 
            for (var i in this.getAllProgramsOrder) {
                 
                this.totalAmountAvailable = this.getAllProgramsOrder[i].TotalAmount;
        
                this.totalAmountSpent = this.totalAmountSpent + this.totalAmountAvailable; 
        
            }
             this.TotalAmount = this.totalAmountSpent;

            if(this.getAllProgramsOrder.length){
                this.totalAmountSpent = 0;
                return refreshApex(this.programOrderSummaryReport);
             
                
            }
          
          
        }
      
    }
   

  
    //  To download the report using csv 
    exportToCSV() {  
        
        let columnHeader = ["Program Name","Brand Name","Item Number","Item Type","Item Name","Vendor","Price in $","Pack Of","Total Qty Ordered","Total Pieces Ordered","Total Amount in $"];  // This array holds the Column headers to be displayd
        let jsonKeys = ["ProgramName", "Brand","PosItemNumber","ItemType","PosItemName","Vendor","Price","PackOf","TotalQuantity","TotalPiecesOrdered","TotalAmount"]; // This array holds the keys in the json data  
          //console.log('program data', JSON.stringify(jsonKeys));
        var jsonRecordsData = this.programOrderSummaryReport.data;  
        //  console.log('program data', JSON.stringify(jsonRecordsData));
        // 
        let csvIterativeData;  
        let csvSeperator  
        let newLineCharacter;  
        csvSeperator = ",";  
        newLineCharacter = "\n";  
        csvIterativeData = "";  
        csvIterativeData += columnHeader.join(csvSeperator);  
        csvIterativeData += newLineCharacter; 
         //Author Vanditha and Vignesh Date : 13 May 2020 converting to Currency format
         let formatter = new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD',
            minimumFractionDigits: 2
          })
       

    //  console.log('length', jsonRecordsData.length);
        for (let i = 0; i < jsonRecordsData.length; i++) { 
     
          let counter = 0;  
          
         
         

          for (let iteratorObj in jsonKeys) {  
        
            let dataKey = jsonKeys[iteratorObj];  
            // console.log('datakey', dataKey);
           
    //  console.log('counter',counter );
      
            if (counter > 0) 
            {
                  csvIterativeData += csvSeperator;
                  }
            
               if (  jsonRecordsData[i][dataKey] !== null &&  
              jsonRecordsData[i][dataKey] !== undefined  )
               
            {
                  
                    
          //Author Vanditha and Vignesh Date : 13 May 2020 converting to Currency format
            this.totalAmount = jsonRecordsData[i].TotalAmount;
            // console.log('total Amount',this.totalAmount );

            formatter.format(this.totalAmoun)
            // console.log('total Amount ---->', formatter.format(this.totalAmount ));
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
        // console.log('data entered', csvIterativeData);
        this.hrefdata = "data:text/csv;charset=utf-8," + encodeURIComponent(csvIterativeData);
      }     
}