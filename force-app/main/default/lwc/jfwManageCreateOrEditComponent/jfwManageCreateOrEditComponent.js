import { LightningElement,wire,track,api } from 'lwc';
import updateBrandOnEdit from '@salesforce/apex/JFWManageBrandList_Apex.addBrand'

export default class JfwManageCreateOrEditComponent extends LightningElement {
@api getBrandDetails;
@api isEditClicked;
@api labelName;
@track brandDetails=[];
@track showErrorMessage=false;
@api isModalOpen=false;
@api brandNameForValidation;
@api saveandnew=false;



 //This is theh LWC Lifecycle method and it is invoked on page load
 connectedCallback(){
    // to make the addressbook available to hold the chnages made by the user in the UI
    this.brandDetails = JSON.parse(JSON.stringify(this.getBrandDetails));
    console.log('brandDetails------>',this.brandDetails);
    if( this.brandDetails.length>0){
      this.showErrorMessage = false;
    }
  }

  // // On click of close popUp modal
  // closeModal(event){
  //   //To set the modal vale to false and send the value to parent , as the parent needs to know the value changed
  //   this.isModalOpen=false;
  //   const closeButton = new CustomEvent('closemodal', {detail:this.isModalOpen})
  //   this.dispatchEvent(closeButton);
  // }


  //to close the pop up modal and to send the value to the parent componet of the changed value
closeModal(){
  //To set the modal vale to false and send the value to parent , as the parent needs to know the value changed
    const closeButton = new CustomEvent('closemodal', {
      detail: {
        isModalOpen: false,
          saveandnew:false,
      } 
    });
    this.dispatchEvent(closeButton);
  }

  validateBrandName(event){
    console.log('entred validateBrandName');
    // this.brandDetails.Brand_Name__c = event.target.value;
    // console.log('update name--->',JSON.stringify(this.brandDetails.Brand_Name__c));


    let brandNameInputField = this.template.querySelector(".brandNameValidation");
    console.log('brandNameInputField---->',brandNameInputField);
    console.log('brandNameForValidation---->',JSON.stringify(this.brandNameForValidation));
    console.log('labelName---->',this.labelName)
    let brandName = brandNameInputField.value;
    console.log('brandName---->',brandName);
    if (brandName.startsWith(' '))
    brandName = brandName.trim();
    console.log('brandName---->',brandName);
    this.brandDetails.Brand_Name__c = brandName;
    console.log('46--->',this.brandDetails.Brand_Name__c);
    if (this.brandNameForValidation.includes(brandName.replace(/\s/g, '').toUpperCase().trim()) && brandName.replace(/\s/g, '').toUpperCase().trim() != this.labelName.replace(/\s/g, '').toUpperCase().trim()) {
      console.log('48');
        brandNameInputField.setCustomValidity("Territory name exists. Please check and enter again.");
       } else {
         brandNameInputField.setCustomValidity("");
        }
        if (brandName.length < 3) {
          console.log('54');
          brandNameInputField.setCustomValidity("Please enter territory name more than 3 characters.");
           }
           if (brandName.length == 3) {
                if (territoryName.endsWith(' '))
                brandNameInputField.setCustomValidity("Please enter territory name more than 3 characters.");
             }
             brandNameInputField.reportValidity();
             if (!brandNameInputField.checkValidity())
                  this.showErrorMessage = true;
               else
                  this.showErrorMessage = false;
               }
              

  





  // validateTerritoryName(event) {
  //   // to hold the id of the territoy name input field
  //   let territoryNameInputField = this.template.querySelector(".territoyNameValidation");
  //   //to hold the value in the id field
  //   let territoryName = territoryNameInputField.value;
  //   //if the entered territoy name starts with space, the trim the same and store the value.
  //   if (territoryName.startsWith(' '))
  //     territoryName = territoryName.trim();
  //     this.selectedTerritory.Territory_Name__c= territoryName;
  // // to check if the territory name already exist
  //   if (this.territoryNamesForValidation.includes(territoryName.replace(/\s/g, '').toUpperCase().trim()) && territoryName.replace(/\s/g, '').toUpperCase().trim() != this.labelName.replace(/\s/g, '').toUpperCase().trim()) {
  //     territoryNameInputField.setCustomValidity("Territory name exists. Please check and enter again.");
  //   } else {
  //     territoryNameInputField.setCustomValidity("");
  //   }
  
  //   if (territoryName.length < 3) {
  //       territoryNameInputField.setCustomValidity("Please enter territory name more than 3 characters.");
  //   }
  //   if (territoryName.length == 3) {
  //       if (territoryName.endsWith(' '))
  //           territoryNameInputField.setCustomValidity("Please enter territory name more than 3 characters.");
  //   }
  //   territoryNameInputField.reportValidity();
  //   if (!territoryNameInputField.checkValidity())
  //     this.showErrorMessage = true;
  //   else
  //     this.showErrorMessage = false;
  // }






    
  handleChangeActive(event){
    this.brandDetails.Active__c = event.target.checked;
    console.log('update name--->',JSON.stringify(this.brandDetails.Active__c));

  }
  
  // saveBrand(event){
  //   console.log('brandList----->',JSON.stringify(this.brandDetails));
  //   updateBrandOnEdit({  
        
  //       selectedBrand :JSON.stringify(this.brandDetails)
  //      })
  //      .then(result => {
  //       let resultGiven = result;
  //       //To set the modal vale to false and send the value to parent , as the parent needs to know the value changed
  //       const closeButton = new CustomEvent('closemodal', {
  //       detail: {
  //       isModalOpen: false,
  //       saveandnew: false,
  //       }
  //      })
     
  //      this.closeModal();
  // }


//to save the territory
saveBrand(event){
  updateBrandOnEdit({  
    selectedBrand :JSON.stringify(this.brandDetails)
    })
    .then(result => {
        let resultGiven = result;
        //To set the modal vale to false and send the value to parent , as the parent needs to know the value changed
        const closeButton = new CustomEvent('closemodal', {
        detail: {
          isModalOpen: false,
        saveandnew: false,
      } 
      });
      this.dispatchEvent(closeButton);
    })
}


   //To save and create a new terrioty
   saveAndNewBrand(){
    updateBrandOnEdit({  
      selectedBrand :JSON.stringify(this.brandDetails)
      })
      .then(result => {
        let resultGiven = result;
        this.brandDetails.Brand_Name__c='';
        this.brandDetails.Active__c=false;
        //To set the modal vale to false and send the value to parent , as the parent needs to know the value changed
        const closeButton = new CustomEvent('closemodal', {
        detail: {
        isModalOpen: true,
        saveandnew: true,
        } 
      });
        console.log('before dispatch')
        this.dispatchEvent(closeButton);
      })
  }

}