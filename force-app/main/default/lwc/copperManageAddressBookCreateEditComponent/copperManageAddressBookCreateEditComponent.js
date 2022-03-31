import {LightningElement,track,api} from 'lwc';
// To get the List of updated address from the apex class "CopperManageAddressBook_Apex" along with the method "updateAddressBook"
import updateAddressbook from '@salesforce/apex/CopperManageAddressBook_Apex.updateAddressBook'
export default class CopperManageAddressBookCreateEditComponent extends LightningElement {
  //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
  @track isModalOpen = true;
  //to hold the value if the edit/create button is clicked
  @api isEditClicked;
  //To hold the data sent by the parent - address details
  @api addressBook;
  // To hold the state list sent from the paret component
  @track allStates;
  //to hold the address book details to be displayed
  @track updatedAddressBook = [];
  //to hold state names to be displayed
  @api getStateNames;
  @track showErrorMessage = true;
  //To display the label for edit modal popup.
  @api labelName;

  //This is theh LWC Lifecycle method and it is invoked on page load
  connectedCallback() {
    // to make the addressbook available to hold the chnages made by the user in the UI
    this.updatedAddressBook = JSON.parse(JSON.stringify(this.addressBook));
    if (this.updatedAddressBook.length > 0) {
      this.showErrorMessage = false;
    }
  }

  // On click of close popUp modal
  closeModal() {
    //To set the modal vale to false and send the value to parent , as the parent needs to know the value changed
    this.isModalOpen = false;
    const closeButton = new CustomEvent('closemodal', {
      detail: this.isModalOpen
    })
    this.dispatchEvent(closeButton);
  }

  //To capture the DESTINATION NAME 
  handleChangeDestinatioName(event) {
    if (this.updatedAddressBook.Shipto_Name__c != undefined && this.updatedAddressBook.City__c != undefined)
      this.updatedAddressBook.Destination_Name__c = this.updatedAddressBook.Shipto_Name__c + '-' + this.updatedAddressBook.City__c;
  }

  handleChangeShipToName(event) {
    // to hold the ship to name with the help of class name
    let shipToNameInputField = this.template.querySelector(".addressBookShipToName");
    //to hold the ship to name value
    let shipToNameValue = shipToNameInputField.value;
    //to hold the regex
    var regexForSpecialCharacters = /[^a-zA-Z0-9]/;
    if (shipToNameValue.trim() == '') {
      shipToNameValue = shipToNameValue.trim();
    }

    if (regexForSpecialCharacters.test(shipToNameValue)) {
      var shipToNameValue_FirstCharacter = shipToNameValue.match(/[a-zA-Z0-9]/);
      if (!shipToNameValue_FirstCharacter) {
        shipToNameValue = '';
      } else {
        var shipToNameValue_Index = shipToNameValue.indexOf(shipToNameValue_FirstCharacter);
        shipToNameValue = shipToNameValue.substring(shipToNameValue_Index, shipToNameValue.length);
      }
    }
    //to hold ship to name value to be updated
    this.updatedAddressBook.Shipto_Name__c = shipToNameValue;
    //to display error,if any.
    shipToNameInputField.reportValidity();
    this.handleChangeDestinatioName();
    //to validate the address book
    this.validateAddressBook();
  }

  removeSpecialCharactersForPhone_Fax(event) {
    var regexForSpecialCharacters = /[0-9+]/g;
    var keycodes = [8, 37, 38, 39, 40];
    if (!regexForSpecialCharacters.test(event.key) && !keycodes.includes(event.keyCode))
      event.preventDefault();
  }

  // Onchange event when the users enters the Phone in the input field,event is invoked
  handleChangePhone(event) {
    //to hold the phone details from the class name
    let addressBookPhoneInputField = this.template.querySelector(".addressBookPhone");
    //to capture the phone number
    let phone = addressBookPhoneInputField.value;
    phone = phone.replace(/\s+/g, '');
    if (phone.startsWith(' '))
      phone = phone.trim();
    //to update the phone number
    this.updatedAddressBook.Phone__c = phone;
    var regexForSpecialCharacters = /[^0-9+]/ig;
    if (regexForSpecialCharacters.test(phone)) {
      addressBookPhoneInputField.setCustomValidity('Special characters not allowed');
    } else {
      addressBookPhoneInputField.setCustomValidity('');
    }
    //display error messages if any
    addressBookPhoneInputField.reportValidity();
    //to validate the address book
    this.validateAddressBook();
  }


  handleChangeShipToCompany(event) {
    //to capture the ship to company details from the class name
    let shipToCompanyInputField = this.template.querySelector(".addressBookShipToCompany");
    //to capture the value
    let shipToCompanyValue = shipToCompanyInputField.value;
    var regexForSpecialCharacters = /[^a-zA-Z0-9]/;
    if (shipToCompanyValue.trim() == '') {
      shipToCompanyValue = shipToCompanyValue.trim();
    }

    if (regexForSpecialCharacters.test(shipToCompanyValue)) {
      var shipToCompanyValue_FirstCharacter = shipToCompanyValue.match(/[a-zA-Z0-9]/);
      if (!shipToCompanyValue_FirstCharacter) {
        shipToCompanyValue = '';
      } else {
        var shipToCompanyValue_Index = shipToCompanyValue.indexOf(shipToCompanyValue_FirstCharacter);
        shipToCompanyValue = shipToCompanyValue.substring(shipToCompanyValue_Index, shipToCompanyValue.length);
      }
    }
    //to hold the ship to comapany value
    this.updatedAddressBook.Shipto_Company__c = shipToCompanyValue;
    //to display error message if any
    shipToCompanyInputField.reportValidity();

    this.validateAddressBook();
  }

  // Onchange event when the users selects their State in the combobox,event is invoked
  handleChangeState(event) {
    //to hold state value
    this.updatedAddressBook.State__c = event.target.value;
    // to validate the address book
    this.validateAddressBook();
  }

  // Onchange event when the users adds their address in the input field,event is invoked
  handleChangeAddress(event) {
    //to capture the address book details with help pf class name
    let addressBookDetailsInputField = this.template.querySelector(".addressBookAddress");
    //to hold the vlaue
    let address = addressBookDetailsInputField.value;
    if (address.trim() == '')
      address = address.trim();
    //to assign the address value
    this.updatedAddressBook.Address__c = address;
    //to display error message if any
    addressBookDetailsInputField.reportValidity();
    // to validate the address book
    this.validateAddressBook();
  }

  // Onchange event when the users adds their fax in the input field,event is invoked
  handleChangeFax(event) {
    //to capture the fax detials with the help of class name
    var addressBookFaxInputField = this.template.querySelector(".addressBookFax");
    //to hold the fax value
    var faxValue = addressBookFaxInputField.value;
    //to update the fax value
    faxValue = faxValue.replace(/\s+/g, '');
    this.updatedAddressBook.Fax__c = faxValue;
    var regexForSpecialCharacters = /[^0-9]/ig;
    if (regexForSpecialCharacters.test(faxValue)) {
      addressBookFaxInputField.setCustomValidity('Special characters not allowed');
    } else {
      addressBookFaxInputField.setCustomValidity('');
    }
    //to display error message if any
    addressBookFaxInputField.reportValidity();
    // to validate the address book
    this.validateAddressBook();
  }

  //to remove special caharaters on key press
  validateSpecialCharactersOnkeypress(event) {
    var regexForSpecialCharacters = /[a-zA-Z ]/g;
    if (!regexForSpecialCharacters.test(event.key))
      event.preventDefault();
  }

  //to remove the special characters  on keydown
  validateCitySpecialCharactersOnkeydown(event) {
    var city = event.target.value;
    var regexForSpecialCharacters = /[a-zA-Z ]/g;
    if (!regexForSpecialCharacters.test(event.key) || (city == '' && event.key == ' '))
      event.preventDefault();
  }

  handleChangeCity() {
    //to hold the city detials through the class name
    var addressBookCityInputField = this.template.querySelector(".addressBookCity");
    //to hold city details
    var city = addressBookCityInputField.value
    city = city.replace(/\s\s+/g, ' ');
    if (city.startsWith(' '))
      city = city.trim();
    //to hold the city value
    this.updatedAddressBook.City__c = city
    var regexForSpecialCharacters = /[^a-zA-Z ]/ig;
    if (regexForSpecialCharacters.test(city)) {
      addressBookCityInputField.setCustomValidity('Special characters not allowed');
    } else {
      addressBookCityInputField.setCustomValidity('');
    }
    //to display errors if any
    addressBookCityInputField.reportValidity();
    //invoke the method handleChangeDestinatioName
    this.handleChangeDestinatioName();
    this.validateAddressBook()
  }

  //to remove the special characters for zip code
  removeZipCodeSpecialCharacters(event) {
    var zip = event.tarrget.value;
    var regexForSpecialCharacters = /[0-9-]/g;
    var keycodes = [8, 37, 38, 39, 40];
    if (!regexForSpecialCharacters.test(event.key) && !keycodes.includes(event.keyCode))
      event.preventDefault();
    if (event.key == '-' && zip == '')
      event.preventDefault();
    if (event.key == '-' && zip.includes('-'))
      event.preventDefault();
  }

  // Onchange event when the users adds their zip code in the input field,event is invoked
  handleChangeZip(event) {
    var addressBookZipInputField = this.template.querySelector(".addressBookZip")
    var zip = addressBookZipInputField.value;
    zip = zip.replace(/[^0-9-]/ig, '');
    zip = zip.replace(/--+/g, '-');
    if (zip.startsWith('-'))
      zip = zip.slice(1, zip.length);
    this.updatedAddressBook.Zip__c = zip;
    var regexForSpecialCharacters = /[^0-9-]/ig;
    if (regexForSpecialCharacters.test(zip)) {
      addressBookZipInputField.setCustomValidity('Special characters not allowed');
    } else {
      addressBookZipInputField.setCustomValidity('');
    }
    addressBookZipInputField.reportValidity();
    this.validateAddressBook();
  }
  // Onclick event when the user clicks on the active checkbix
  handleChangeActive(event) {
    this.updatedAddressBook.Active__c = event.target.checked;
    this.validateAddressBook();
  }

  validateAddressBook() {
    //to hold the ship to name
    var addressBookShipToNameInputField = this.template.querySelector('.addressBookShipToName');
    //to hold the destination  name
    var addressBookDestNameInputField = this.template.querySelector('.addressBookDestinationName');
    //to hold the ship to company
    var addressBookShipToCompanyInputField = this.template.querySelector('.addressBookShipToCompany');
    //to hold the addresses details
    var addressBookAddressInputField = this.template.querySelector('.addressBookAddress');
    //to hold the city details
    var addressBookCityInputField = this.template.querySelector('.addressBookCity');
    //to hold the phone number
    var addressBookPhoneInputField = this.template.querySelector('.addressBookPhone');
    //to hold the state
    var addressBookStateField = this.template.querySelector('.addressBookState');
    let addressBookStateValue = addressBookStateField.value;
    //to hold the zip code
    var addressBookZipInputField = this.template.querySelector('.addressBookZip');
    //to check if the required is filled or empty and set the 'showErrorMessage' message variable to true/false
    if (addressBookShipToNameInputField.checkValidity() && addressBookDestNameInputField.checkValidity() && addressBookShipToCompanyInputField.checkValidity() && (this.updatedAddressBook.State__c != '') &&
      addressBookAddressInputField.checkValidity() && addressBookCityInputField.checkValidity() &&
      addressBookPhoneInputField.checkValidity() && addressBookZipInputField.checkValidity() && (addressBookStateValue != '' && addressBookStateValue != undefined))
      this.showErrorMessage = false;
    else
      this.showErrorMessage = true;
  }

  // On click of the save button in the UI ,this event is invoked and sends the address to the backend
  SaveAddressBook(event) {
    updateAddressbook({
      selectedAddressBook: JSON.stringify(this.updatedAddressBook)
    })
      .then(result => {
        let resultGiven = result;
        this.isModalOpen = false;
        const closeButton = new CustomEvent('closemodal', {
          detail: this.isModalOpen
        })
        this.dispatchEvent(closeButton);
      })

    this.closeModal();
  }
}