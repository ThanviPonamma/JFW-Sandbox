import { LightningElement, track, wire } from 'lwc';
// Authors:Sanjana    Date:09-11-2021

// Import the program data from 'InfiniumWaveOrders_Apex' apex class using the method 'loadProgramList' and store it in 'getProgramList'
import getProgramList from '@salesforce/apex/InfiniumWaveOrders_Apex.loadProgramList'

// Import the Brand data from 'InfiniumWaveOrders_Apex' apex class using the method 'loadBrandList' and store it in 'getBrandList'
import getBrandList from '@salesforce/apex/InfiniumWaveOrders_Apex.loadBrandList'

export default class InfiniumManageOrderProgramAndBrandListComponent extends LightningElement {

    // To hold the 'programListToDisplay' value and to make it reactive
    @track programListToDisplay;
     
    // To hold the program id when the program is selected in the combobox
     @track selectedProgramId;

    // To hold the 'brandListToDisplay' value and to make it reactive
    @track brandListToDisplay;

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
                // push the program data to "programList" property
                this.programListToDisplay.push(program);
            });
        }

        //To handle the error
        else if(error){
            console.log('Error', error.body.message , 'error');
        }
}

    //Event to capture the selected program Id
onSelectionOfProgram(event) {
        this.selectedProgramId = event.detail.value;

        //   Custom event is created to send the program id to the parent component
          const programEvent = new CustomEvent('selectedprogramid',{detail:this.selectedProgramId});
          this.dispatchEvent(programEvent);
}


 // Author : VM,VP,JP
 //to get the data from 'getBrandList' 
@wire(getBrandList)
    loadBrandList({data,error}){
        // If the getBrandList has data
        if(data){
            // get the value and lable for each brand in the program list
            this.brandListToDisplay = [{value : '', label:'Select'}];
           // for each brand
            data.forEach(element => {
                const brand = {};
               //set brand name to the lable property
                brand.label = element.Brand_Name__c;
               // Set the brand id to the value property
                brand.value = element.Id;
                // push the brand data to "brandList" property
                this.brandListToDisplay.push(brand);
            });
        }
        //To handle the error
        else if(error){
            console.log('Error', error.body.message , 'error');
        }
}

    //Event to capture selected Brand Id
onSelectionOfBrand(event) {
        const selectedBrandId = event.detail.value;
      
        // Custom event is created to send the brand id to the parent component
          const brandEvent = new CustomEvent('selectedbrandid',{detail:selectedBrandId});
          this.dispatchEvent(brandEvent);
  
     }
}