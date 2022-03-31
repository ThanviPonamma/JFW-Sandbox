import { LightningElement ,wire, track } from 'lwc';
import getProgramOrderItemSummaryReport from '@salesforce/apex/TFEInventoryOrderReportApex.ReportWithTotalQuantity'
import { refreshApex } from '@salesforce/apex';


export default class TfeInventoryOrderReport extends LightningElement {
    @track value = '';
    @track itemProgramId ='';
    @track programDetails;
    @track hrefdata;
    @track getAllProgramsOrder;
    @track totalAmountAvailable = 0 ;
    @track totalAmountSpent = 0;
    @track TotalAmount;
   
    @wire(getProgramOrderItemSummaryReport)
    programOrderSummaryReport;

    get result(){
        if(this.programOrderSummaryReport.data){
              //  console.log('programOrderSummaryReport---->',this.programOrderSummaryReport.data);
        }
    }
 
   

  
    //  To download the report using csv 
    
    exportToCSV() {  
        
        let columnHeader = ["Order Number","Order By","Item Number","Item Name","Brand Name","Item Type","Pack Of","Price in $","Total Qty Ordered","Total Amount in $","Ship To Name","Ship To Company","Address","City","Zip","State","Email","Phone","Shipping Method Name","Order Status","Ordered Date"];  // This array holds the Column headers to be displayd
        let jsonKeys = [ "OrderName","OrderedBy","PosItemNumber","PosItemName","Brand","ItemType","PackOf","Price","TotalQuantity","TotalPiecesOrdered","TotalAmount","ShipToName","ShipToCompany","Address","City","Zip","State","Email","Phone","ShippingMethod","OrderStatus","CreatedDate"]; // This array holds the keys in the json data  
          //console.log('program data', JSON.stringify(jsonKeys));
        var jsonRecordsData = this.programOrderSummaryReport.data;  
         //console.log('program data', JSON.stringify(jsonRecordsData));
        // 
        let csvIterativeData;  
        let csvSeperator  
        let newLineCharacter;  
        csvSeperator = ",";  
        newLineCharacter = "\n";  
        csvIterativeData = "";  
        csvIterativeData += columnHeader.join(csvSeperator);  
        csvIterativeData += newLineCharacter; 
         let formatter = new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD',
            minimumFractionDigits: 2
          })
       

      console.log('length', jsonRecordsData.length);
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
            this.totalAmount = jsonRecordsData[i].TotalAmount;
            formatter.format(this.totalAmoun)
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