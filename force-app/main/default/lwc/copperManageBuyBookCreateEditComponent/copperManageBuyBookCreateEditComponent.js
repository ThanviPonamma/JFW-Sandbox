/** Author: Thanvi  Date:10/Aug/2021
Aim: This is the grandchild component that is responsible create/edit modal pop-up */
import { LightningElement, wire, track, api } from 'lwc';
//importing the method add/edit buy book method from the class CopperManageBuyBookList_Apex to update a buy book
import saveBuyBook from '@salesforce/apex/CopperManageBuyBookList_Apex.saveBuyBook_Apex'
//import the toast message event
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CopperManageBuyBookCreateEditComponent extends LightningElement {
  //to get buy book details from the parent component
  @api getBuyBookDetails;
  //to get a boolean value from parent
  @api isEditClicked;
  //to hold lable name fetched from  parent
  @api labelName;
  //to hold the type of button selected by the user
  @api selectedButtonName;
  //to hold buy book detail
  @track buyBookDetail = [];
  //to hold boolean value to dislay error message
  @track showErrorMessage = true;
  //to hold boolean value to open the modal
  @api isModalOpen = false;
  //to hold buyBookNameForValidation from parent
  @api buyBookNameForValidation;
  //to hold boolean value to check of the button clicked is 'save and new'
  @api saveandnew = false;
  // boolean variable to see is the image valied or not
  @track isImageValidated = false;
  // bollean avriable to send to html after the image is added or not
  @track isImageShown = false;
  // variable to hold the slected image url and send to backend
  @track imageBlobData = '';
  // variavle to send the selected file type to backend
  @track contentType;
  // variable to enable and disable the save button upon validations
  @track isButtonDisable = true;
  //variable to hold the files from the html an send to js
  @track filesUploaded;
  // variable to hold the selected image file and send to backend
  @track fileName;
  // to hold the file result
  @track fileContents;
  // to hold the content
  @track content;
  // create a FileReader object
  @track fileReader;
  // to hild file result
  @track file;
  // to hold image
  @track image;

  //This is theh LWC Lifecycle method and it is invoked on page load
  connectedCallback() {
    //  fetching the buy book list details from the parent
    this.buyBookDetail = JSON.parse(JSON.stringify(this.getBuyBookDetails));
    // check if the buy book list from the parent exists
    if (this.buyBookDetail.length > 0) {
      //enable the save, save and new button
      this.showErrorMessage = false;
    }
  }

  //to close the pop up modal and to send the value to the parent componet of the changed value
  closeModal() {
    // custom event fired to the parent component to close the pop-up modal
    const closeButton = new CustomEvent('closemodal', {
      detail: {
        isModalOpen: false,
        saveandnew: false,
      }
    });
    //dispatch the custom event
    this.dispatchEvent(closeButton);
  }

  //to validate buy book name entered by the user.
  //Validation 1 : The buy book name should not be repeated
  //Validation 2: The name should greater than 3 letters in length
  validateBuyBookName(event) {
    //fetch the value of the buy book name field
    let buyBookNameInputField = this.template.querySelector(".buyBookNameValidation");
    //store the value of the variable buyBookNameInputField in the variable buyBookName
    let buyBookName = buyBookNameInputField.value;

    //do not let the user enter space in the beginning
    if (buyBookName.startsWith(' '))
      buyBookName = buyBookName.trim();
    // assign the variable buyBookName to the field Name__c of the object Program__c
    this.buyBookDetail.buyBook.Name__c = buyBookName;
    //check if the Buy Book Name entered already exists by comparing the variables buyBookName and buyBookNameForValidation by converting both of them to upper case
    if (this.buyBookNameForValidation.includes(buyBookName.replace(/\s/g, '').toUpperCase().trim()) && buyBookName.replace(/\s/g, '').toUpperCase().trim() != this.labelName.replace(/\s/g, '').toUpperCase().trim()) {
      //display the custom error message if the Buy Book Name already exists
      buyBookNameInputField.setCustomValidity("Buy Book Name exists. Please check and enter again.");
    } else {
      buyBookNameInputField.setCustomValidity("");
    }
    //donot let the user enter Buy Book Name whose length is lesser than 3 letters
    if (buyBookName.length < 3) {
      buyBookNameInputField.setCustomValidity("Please enter a Buy Book Name of at least 4 characters.");
    }
    //donot let the user enter Buy Book Name whose length is equal to 3 letters
    if (buyBookName.length == 3) {
      if (buyBookName.endsWith(' '))
        buyBookNameInputField.setCustomValidity("Please enter a Buy Book Name of at least 4 characters.");
    }
    //report validity
    buyBookNameInputField.reportValidity();
    //the validation doesnot meet, disable the save and save and new buttons else enable them
    if (!buyBookNameInputField.checkValidity())
      this.showErrorMessage = true;
    else
      this.showErrorMessage = false;
    this.validateBuyBookData();
  }
  //To validate the buy book budget
  validateBuyBookBudget(event) {
    this.buyBookDetail.buyBook.Program_Budget__c = event.target.value;
    //invoke the method validateBuyBookData
    this.validateBuyBookData();
  }
  //To restrict the use of special characters
  removeBuyBookBudgetSpecialCharacters(event) {
    var inputId = this.template.querySelector(".buyBookBudget");
    var inputValue = inputId.value.toString();
    var regexForSpecialCharacters = /[^0-9.]/g;
    var keyCodes = [8, 37, 38, 39, 40];
    if (regexForSpecialCharacters.test(event.key) && !keyCodes.includes(event.keyCode))
      event.preventDefault();
    if (inputValue == '' && event.key == '.')
      event.preventDefault();
    if (inputValue.includes('.') && event.key == '.')
      event.preventDefault();
  }
  validateBuyBookStartDate(event) {
    this.buyBookDetail.buyBook.Start_Date__c = event.target.value;
    var startDate = 'START_DATE';
    this.validateDate(startDate);
  }
  validateBuyBookCloseDate(event) {
    this.buyBookDetail.buyBook.Closing_Date__c = event.target.value;
    var closeDate = 'CLOSE_DATE';
    this.validateDate(closeDate);
  }
  validateBuyBookInMarketDate(event) {
    this.buyBookDetail.buyBook.In_Market_Date__c = event.target.value;
    var inMarketDate = 'IN_MARKET_DATE';
    this.validateDate(inMarketDate);
  }
  //to validate the start,close and in market date 
  validateDate(dateType) {
    var buyBookStartDateInputField = this.template.querySelector(".buyBookStartDateInputField");
    var buyBookCloseDateInputField = this.template.querySelector(".buyBookCloseDateInputField");
    var buyBookInMarketDateInputField = this.template.querySelector(".buyBookInMarketDateInputField");
    var buyBookStartDate = buyBookStartDateInputField.value;
    var buyBookCloseDate = buyBookCloseDateInputField.value;
    var buyBookInMarketDate = buyBookInMarketDateInputField.value;
    if (buyBookStartDate != '' && buyBookCloseDate != '') {
      if (buyBookStartDate > buyBookCloseDate) {
        if (dateType == 'START_DATE')
        buyBookStartDateInputField.setCustomValidity("Buy Book Closing Date cannot be before Buy Book Start Date.");
        if (dateType == 'CLOSE_DATE')
          buyBookCloseDate.setCustomValidity("Buy Book Closing Date cannot be before Buy Book Start Date.");
      } else {
        if (dateType == 'START_DATE')
        buyBookStartDateInputField.setCustomValidity("");
        if (dateType == 'CLOSE_DATE')
          buyBookCloseDateInputField.setCustomValidity("");
      }
      if (dateType == 'START_DATE')
      buyBookStartDateInputField.reportValidity();
      if (dateType == 'CLOSE_DATE')
        buyBookCloseDateInputField.reportValidity();
    }
    if (buyBookCloseDate != '' && buyBookInMarketDate != '') {
      if (buyBookCloseDate > buyBookInMarketDate) {
        if (dateType == 'CLOSE_DATE')
        buyBookCloseDateInputField.setCustomValidity("Buy Book In-Market Date cannot be before Buy Book Closing Date.");
        if (dateType == 'IN_MARKET_DATE')
          buyBookInMarketDateInputField.setCustomValidity("Buy Book In-Market Date cannot be before Buy Book Closing Date.");
      } else {
        if (dateType == 'CLOSE_DATE')
        buyBookCloseDateInputField.setCustomValidity("");
        if (dateType == 'IN_MARKET_DATE')
          buyBookInMarketDateInputField.setCustomValidity("");
      }
      if (dateType == 'CLOSE_DATE')
      buyBookCloseDateInputField.reportValidity();
      if (dateType == 'IN_MARKET_DATE')
      buyBookInMarketDateInputField.reportValidity();
    }
    //the validation doesnot meet, disable the save and save and new buttons else enable them
    if (!buyBookStartDateInputField.checkValidity() || !buyBookCloseDateInputField.checkValidity() || !buyBookInMarketDateInputField.checkValidity()) {
      this.showErrorMessage = true;
    }
    else {
      this.showErrorMessage = false;
      //invoke the method validateBuyBookData
      this.validateBuyBookData();
    }
  }
  //to the active status of the buy book
  handleChangeActive(event) {
    //disable the "Save" and "Save and New" buttons
    this.showErrorMessage = false;
    //assign the true value to the field Active__c field of the buy book if the user checks the checkbox
    this.buyBookDetail.buyBook.Active__c = event.target.checked;
    //invoke the method validateBuyBookData
    this.validateBuyBookData();
  }
  preventDate(event) {
    event.preventDefault();
  }


  //to save the buy book
  saveBuyBook(event) {
    //invoking a method saveBuyBook of the class CopperManageBuyBookList_Apex
    saveBuyBook({
      // send selected buy book details as the parameter
      buybook: JSON.stringify(this.buyBookDetail.buyBook),
      imageBlobData: this.isImageValidated ? '' : this.imageBlobData != '' ? encodeURIComponent(this.imageBlobData) : '',
      fileName: this.fileName,
      ContentType: this.contentType,
      selectedButtonName: this.selectedButtonName
    })
      .then(result => {
        //to hold the result from the apex method
        let resultGiven = result;
        // check if the user is trying to edit a buy book
        if (this.isEditClicked) {
          //display the toast message as the buy book has been updated successfully
          const evt = new ShowToastEvent({
            message: 'The Buy Book "' + this.labelName + '" has been updated successfully.',
            variant: 'success',
          });
          // disaptch the event
          this.dispatchEvent(evt);
        }
        //to check if the save is for the create pop-up and show the toast message as the buy book is created successfully
        else {
          const evt = new ShowToastEvent({
            title: 'Success',
            message: 'The Buy Book has been created successfully.',
            variant: 'success',
          });
          // disaptch the event
          this.dispatchEvent(evt);
        }
        //To set the modal vale to true and send the value to parent , as the parent needs to know the value changed
        const closeButton = new CustomEvent('closemodal', {
          detail: {
            isModalOpen: false,
            saveandnew: false,
          }
        });
        // disaptch the event
        this.dispatchEvent(closeButton);
      })
  }
  // used to disconnect the callback from the parent and change the value of the variables once the user clicks on the button "Save and New"
  disconnectedCallback() {
    //make the variable buyBook emnpty
    let temp = {
      "buyBook": {
        "Name__c": "",
        "Closing_Date__c": "",
        "Account__c": "",
        "Program_Budget__c": '',
        "In_Market_Date__c": "",
        "Name": "",
        "Start_Date__c": "",
        "Active__c": true
      },
      "buyBookImageURL": ""
    }
    this.buyBookDetail = temp;
    //enable the "save" and "save and new" button
    this.showErrorMessage = true;

  }
  //To save and create a new buy book
  saveAndNewBuyBook() {
    //invoking a method saveBuyBook of the class CopperManageBuyBookList_Apex
    saveBuyBook({
      // send selected buy book details as the parameter
      buybook: JSON.stringify(this.buyBookDetail.buyBook),
      imageBlobData: this.isImageValidated ? '' : this.imageBlobData != '' ? encodeURIComponent(this.imageBlobData) : '',
      fileName: this.fileName,
      ContentType: this.contentType,
      selectedButtonName: this.selectedButtonName
    })
      .then(result => {
        let resultGiven = result;
        //invoking disconnectedCallback method
        this.disconnectedCallback();
        // check if the user is trying to edit a buy book
        if (this.isEditClicked) {
          //display the toast message as the buy book has been updated successfully
          const evt = new ShowToastEvent({
            message: 'The Buy Book "' + this.labelName + '" has been updated successfully.',
            variant: 'success',
          });
          this.dispatchEvent(evt);
        }
        //to check if the save is for the create pop-up and show the toast message as the buy book is created successfully
        else {
          const evt = new ShowToastEvent({
            message: 'The Buy Book has been created successfully.',
            variant: 'success',
          });
          this.dispatchEvent(evt);
        }

        //To set the modal vale to false and send the value to parent , as the parent needs to know the value changed
        const closeButton = new CustomEvent('closemodal', {
          detail: {
            isModalOpen: true,
            saveandnew: true,
          }
        });
        this.dispatchEvent(closeButton);
      })
  }

  handleFilesChange(event) {
    //fetch the file uploaded by the user and store it in the variable filesUploaded
    this.filesUploaded = event.target.files;
    //hold the value of the variable filesUploaded to the variable files
    var files = this.filesUploaded;
    if (files[0] != undefined) {
      // invoke the method ResizeImageToUpload
      this.ResizeImageToUpload();
    }
    //invoke the method validateBuyBookData
    this.validateBuyBookData();
  }
  //resizing the image uploaded by the user
  ResizeImageToUpload() {
    //to enable the save button
    this.isButtonDisable = true;
    //to enable the preview of the image
    this.isImageShown = true;
    //hold the value of the variable filesUploaded to the variable files
    this.file = this.filesUploaded[0];
    //fetching the class of the image input field
    var buyBookFileId = this.template.querySelector(".buyBookFileId");
    // create a FileReader object 

    this.fileReader = new FileReader();
    // set onload function of FileReader object  
    this.fileReader.onloadend = ((event) => {
      //to store the result of the variable fileReader
      this.fileContents = this.fileReader.result;
      //creating an instance of the variable Image
      this.image = new Image();
      //to store the result of the variable fileReader in the variable source of the image
      this.image.src = this.fileReader.result;

      let base64 = 'base64,';
      //encoding the value of fileContents and storing it in the variable content
      this.content = this.fileContents.indexOf(base64) + base64.length;
      //to hold the substring of the content in fileContents
      this.fileContents = this.fileContents.substring(this.content);
      //create an empty variable to preview the image
      var preview = [];
      //on load of an image
      this.image.onload = (() => {
        //determine the width of an image
        var imageWidth = this.image.width;

        //determine the height of an image
        var imageHeight = this.image.height;

        //check if the width and height of an image is exceeding 200 and do not allow the user to exceed 200
        if (parseInt(imageWidth) > 200 || parseInt(imageHeight) > 200) {
          //creating a canvas
          const canvas = document.createElement('canvas');
          let ctx = canvas.getContext('2d');
          //setting max width of the image to 200
          var MAX_WIDTH = 200;
          //setting max height of the image to 200
          var MAX_HEIGHT = 200;
          var width = imageWidth;
          var height = imageHeight;

          //check if the width is greater than height
          if (width > height) {
            //check if width is greater than max width
            if (width > MAX_WIDTH) {
              height *= MAX_WIDTH / width;
              width = MAX_WIDTH;
            }
          } else {
            //check if height is greater than max height
            if (height > MAX_HEIGHT) {
              width *= MAX_HEIGHT / height;
              height = MAX_HEIGHT;
            }
          }

          //assign width to the width of the canvas
          canvas.width = width;
          //assign height to the height of the canvas
          canvas.height = height;

          //drwaing the uploaded image on canvas
          ctx.drawImage(this.image, 0, 0, width, height);


          //converting the canvas to dataUrl
          var dataurl = canvas.toDataURL(this.file.type);
          //access elements rendered by a component using the class
          preview = this.template.querySelector(".attachedImage");
          //assign the dataurl to the source of the preview
          preview.src = dataurl;
          //converting the dataurl to image blob 
          this.imageBlobData = dataurl.replace(/^data:image\/(png|jpeg|jpg);base64,/, "");

        }


        //else, preveiw the uploaded image
        else {
          //assigning the file content to imageBlobData
          this.imageBlobData = this.fileContents;
          //access elements rendered by a component using the class
          preview = this.template.querySelector(".attachedImage");
          //assign the result of the filereader to the preview source
          preview.src = this.fileReader.result;

        }
        //fetching the file name 
        this.fileName = this.file.name;
        //fetching content type
        this.contentType = this.file.type;
        //make the variable isImageValidated false
        this.isImageValidated = false;
        //check if the user is editing the buy book
        if (this.isEditClicked == true) {                                                                                                                     //if user is editing, enable the save button
          this.isButtonDisable = false;
        } else {
          //else disable the save button
          this.isButtonDisable = true;
        }

        //display error message if the image is invalid
      });
    });
    //read the image as URL to show the preview of the image
    this.fileReader.readAsDataURL(this.file);
  }


  // remove the image
  removeImage() {
    //set null value to the image URL of buy book
    this.buyBookDetail.buyBookImageURL = '';
    //set null value to the Attachment_Id__c of the buy book
    this.buyBookDetail.buyBook.Attachment_Id__c = '';
    //remove the displayed image
    this.isImageShown = false;
    //set null value to the imageBlobData
    this.imageBlobData = '';
    //set null value to the fileName
    this.fileName = '';
    //set null value to the contentType
    this.contentType = '';
    //invoke the method validateBuyBookData
    this.validateBuyBookData();
  }

  validateBuyBookData() {
    var buyBookNameInputField = this.template.querySelector(".buyBookNameValidation");
    var buyBookBudget = this.template.querySelector(".buyBookBudget");
    var buyBookStartDate = this.template.querySelector(".buyBookStartDateInputField");
    var buyBookCloseDate = this.template.querySelector(".buyBookCloseDateInputField");
    var buyBookInMarketDate = this.template.querySelector(".buyBookInMarketDateInputField");
    if (!buyBookNameInputField.checkValidity() && !buyBookStartDate.checkValidity() && !buyBookCloseDate.checkValidity() && !buyBookInMarketDate.checkValidity()) {
      this.showErrorMessage = true;
    }
    else
      this.showErrorMessage = false;
  }
}