// Authors:Sanjana Date:08-11-2021
// Aim:This is the child component of InfiniumInventoryPosCatalogComponent which is responsible to display the filter inputs and download button and to send brand Id and search keyword to the parent


import { LightningElement ,wire ,track} from 'lwc';
import getBrands from '@salesforce/apex/InfiniumInventoryPOSCatalog_Apex.getBrandList';
//to get the account details
import getAccountDetails from '@salesforce/apex/InfiniumInventoryPOSCatalog_Apex.getAccount';
//the below line is used to navaigate to the visual force page using the URL for the user to download POS catalog pdf file
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';

export default class InfiniumInventoryPosCatalogFiltersComponent extends NavigationMixin(LightningElement) {
  //to hold the account URl
  @track accountURL;
  //brandListToDisplay holds the list of brands fetched from the apex class to display to the user
  @track brandListToDisplay;
  //searchedKeyword holds the search keyword entered by the user
  @track searchedKeyword = '';
  //brandValue holds the brand Id selected by the user
  @track brandValue = '';
  //searchKey holds the value of the attribute searchedKeyword on click of the button 'search'
  @track searchKey = '';
  
  //to get the account details
  connectedCallback(){
      getAccountDetails()
          .then(result => {
              this.accountURL = result.Lightning_Community_URL__c;
          })
  }
  //to get the list of brands from the apex class InfiniumPosItemToCart_Apex and the method getBrandList
  @wire(getBrands)
  getActiveBrandList({ data, error }) {
      // if data exists
      if (data) {

          this.brandListToDisplay = [{ value: '', label: 'All Brands' }];
          // for each program
          data.forEach(element => {
              const brand = {};
              // assigning brand name
              brand.label = element.Brand_Name__c;
              // assigning brand Id
              brand.value = element.Id;
              // pushing the variable brand to the variable this.brandListToDisplay
              this.brandListToDisplay.push(brand);
          });
      } else if (error) {
        //   console.log('Error', error.body.message, 'error');
      }
  }

//  Event to hold brand id and send to parent component 
  handleChangeForBrand(event) {
  //    to fetch the selected brand value and storing in brandValue
      this.brandValue = event.detail.value;
      // creating a custom event along with parameter brandValue . This is handled by the parent component
      const brandEvent = new CustomEvent('selectbrandevent', { detail: this.brandValue });
      // dispatching the custom event
      this.dispatchEvent(brandEvent);

  }

  ///  To hold the user searched values
  searchPosItem(event) {
      // to fetch the entered search keyword by the user and storing it in the variable this.searchedKeyword
      this.searchedKeyword = event.detail.value;
      // check if the searchedKeyword is empty or null
      if (this.searchedKeyword == '' || this.searchedKeyword == null) {
          // custom event "sendsearchdatatoavailable" is called in the parent html. This event holds the searchKeyword
          const searchvent = new CustomEvent('sendsearchdatatoparent', { detail: this.searchedKeyword });
          // dispatching the custom event
          this.dispatchEvent(searchvent);
      }
  }

  // To search the value on click of button
  searchEvent(event) {
      // check if the searchedKeyword is empty or null
      if (this.searchedKeyword != '' || this.searchedKeyword != null) {
          // custom event "sendsearchdatatoavailable" is called in the parent html. This event holds the searchKeyword
          const searchvent = new CustomEvent('sendsearchdatatoparent', { detail: this.searchedKeyword });
           // dispatching the custom event
          this.dispatchEvent(searchvent);
      }
  }


//event that is invoked onclick of the 'download PDF' button which is responsible to navigate to the visual force page Infinium_POS_Catalog_Logo and download pdf file
   getPOSCatalog(event){
      //  check if the variable brandValue is empty or null
       if(this.brandValue==''||this.brandValue==null){
          //  navigate to the visual force page Infinium_POS_Catalog_Logo 
          this[NavigationMixin.GenerateUrl]({
              type: 'standard__webPage',
              attributes: {
                 
                  url:  this.accountURL+'/Infinium_POS_Catalog_Logo'
              }

          }).then(generatedUrl => {
              window.open(generatedUrl);
          });
       }

       else{
          this[NavigationMixin.GenerateUrl]({
              type: 'standard__webPage',
              attributes: {
               
                  url:  this.accountURL+'/Infinium_POS_Catalog_Logo'+'?id='+this.brandValue
              }

          }).then(generatedUrl => {
              window.open(generatedUrl);
          });

       }

   }

}