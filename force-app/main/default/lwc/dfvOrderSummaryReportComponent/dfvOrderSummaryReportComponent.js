import { LightningElement,track,wire } from 'lwc';
import getAllOderSummaryReport from '@salesforce/apex/DFVOrderSummaryReport.GetOrderDestinationItems'
import getAllPrograms from '@salesforce/apex/ProgramsController.GetAllPrograms'
import loggedInUserId from '@salesforce/user/Id'
import { refreshApex } from '@salesforce/apex';

export default class DfvOrderSummaryReportComponent extends LightningElement {
    
    
     // to re-render the component when it changes
     @track inProgress;
     @track selectedProgramId = '';
     @track userId = '';
     userId = loggedInUserId;
     @track hrefdata;  
     @track orderSummaryReport;
     
    //  gets the data from the apex and give it to the attribute

     @wire(getAllPrograms)
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
    //  on click of the dropdown onchange event is occurs when the program is clicked the data is sent using this event

     handleProgramChange(event){
       
         this.selectedProgramId = event.detail.value;
        
        const programSelectionChangeEvent = new CustomEvent('programselect' , {detail : selectedProgramId});
      
         this.dispatchEvent(programSelectionChangeEvent);
       

     }

        //  to get the data from the backend we use wire decor 

    @wire(getAllOderSummaryReport, {programId :'$selectedProgramId' , userId :'$userId'})
    orderSummaryReport;
   
    get responseValue(){
        if(this.orderSummaryReport.data){
          // console.log('data',JSON.stringify(this.orderSummaryReport.data));
          
            const getOrderSummaryReport = this.orderSummaryReport.data;
           
              if(getOrderSummaryReport.length){
                return refreshApex(this.orderSummaryReport);
               
                return true;
              }
              return false;
            //  console.log('data',JSON.stringify(this.orderSummaryReport.data));
           
        }
            return false;
    }
    exportToCSV() {  
        let columnHeader = ["Program Name" , "Brand Name" , "Order Name","Ordered By", "Vendor","Item Type", "Item Number","Item Name","PackOf","Quantity","Price in $","Total Line Amount","Ship To Name","Ship To Company","Address","Ship To City","State Code","Zip","Phone","Email","Status","Created Date","Last Modified Date"];  // This array holds the Column headers to be displayd
        let jsonKeys = ["ProgramName", "BrandName", "OrderName","UserId", "Vendor","ItemType","ItemNo","PosItemName","PosPackOf","Quantity","PosItemPrice","TotalLineAmount","OrdDestShipToName","OrdDestShipToCompany","OrdDestAddress","OrdDestShipToCity","OrdDestStateCode","OrdDestZip","OrdDestPhone","OrdDestEmail","OrdDestOrderStatus","CreatedDate","LastModifiedDate"]; // This array holds the keys in the json data  
        var jsonRecordsData = this.orderSummaryReport.data;  
        let csvIterativeData;  
        let csvSeperator  
        let newLineCharacter;  
        csvSeperator = ",";  
        newLineCharacter = "\n";  
        csvIterativeData = "";  
        csvIterativeData += columnHeader.join(csvSeperator);  
        csvIterativeData += newLineCharacter;  
      //  console.log('length', jsonRecordsData.length);
        for (let i = 0; i < jsonRecordsData.length; i++) { 
     
          let counter = 0;  
          for (let iteratorObj in jsonKeys) {  
            let dataKey = jsonKeys[iteratorObj];  
            // console.log('counter',counter );
      
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
      this.hrefdata = "data:text/csv;charset=utf-8," + encodeURIComponent(csvIterativeData);
      }  
    }