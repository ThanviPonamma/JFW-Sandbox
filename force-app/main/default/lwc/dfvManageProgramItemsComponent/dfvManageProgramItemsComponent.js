import { LightningElement,track } from 'lwc';

export default class DfvManageProgramItemsComponent extends LightningElement {


    @track selectedBrand='';

    @track selectedProgram='';

    @track displayProgramItemDetails = false;

    get allBrands() {
        return [
            { label: '1924', value: '1924' },
           
        ];
    }

    get allPrograms() {
        return [
            { label: '2022 Summer Buy', value: '2022 Summer Buy' },
           
        ];
    }

    getSelectedBrand(event) {
        this.selectedBrand = event.detail.value;
        console.log('brand---->',this.selectedBrand);
        if(this.selectedBrand!='' && this.selectedProgram!=''){
            this.displayProgramItemDetails = true;
        }
        else{
            this.displayProgramItemDetails = false;
        }

    }

    getSelectedProgram(event) {
        this.selectedProgram = event.detail.value;
        console.log('program---->',this.selectedProgram);
        if(this.selectedBrand!='' && this.selectedProgram!=''){
            this.displayProgramItemDetails = true;
        }
        else{
            this.displayProgramItemDetails = false;
        }
    }
}