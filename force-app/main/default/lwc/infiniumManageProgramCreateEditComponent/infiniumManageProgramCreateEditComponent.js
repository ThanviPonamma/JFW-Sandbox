/**Author : Sanjana; Date : 20-09-2021
Aim: This is the grandchild component that is responsible create/edit modal pop-up */
import { LightningElement, wire, track, api } from 'lwc';
//importing the method add/edit Program method from the class InfiniumManageprogramList_Apex to update a Program
import saveProgramDetails from '@salesforce/apex/InfiniumManageProgramList_Apex.saveProgram_Apex'
//import the toast message event
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class InfiniumManageProgramCreateEditComponent extends LightningElement {
  //to get Program details from the parent component
  @api getProgramDetails;
  //to get a boolean value from parent
  @api isEditClicked;
  //to hold lable name fetched from  parent
  @api labelName;
  //to hold the type of button selected by the user
  @api selectedButtonName;
  //to hold Program detail
  @track programDetail = [];
  //to hold boolean value to dislay error message
  @track showErrorMessage = true;
  //to hold boolean value to open the modal
  @api isModalOpen = false;
  //to hold programNameForValidation from parent
  @api programNameForValidation;
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
    //  fetching the  list details from the parent
    this.programDetail = JSON.parse(JSON.stringify(this.getProgramDetails));
    // check if the  list from the parent exists
    if (this.programDetail.length > 0) {
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

  //to validate  name entered by the user.
  //Validation 1 : The  name should not be repeated
  //Validation 2: The name should greater than 3 letters in length
  validateProgramName(event) {
    //fetch the value of the  name field
    let programNameInputField = this.template.querySelector(".programNameValidation");
    //store the value of the variable programNameInputField in the variable programName
    let programName = programNameInputField.value;

    //do not let the user enter space in the beginning
    if (programName.startsWith(' '))
      programName = programName.trim();
    // assign the variable programName to the field Name__c of the object Program__c
    this.programDetail.program.Name__c = programName;
    //check if the  Name entered already exists by comparing the variables programName and programNameForValidation by converting both of them to upper case
    if (this.programNameForValidation.includes(programName.replace(/\s/g, '').toUpperCase().trim()) && programName.replace(/\s/g, '').toUpperCase().trim() != this.labelName.replace(/\s/g, '').toUpperCase().trim()) {
      //display the custom error message if the  Name already exists
      programNameInputField.setCustomValidity(" Name exists. Please check and enter again.");
    } else {
      programNameInputField.setCustomValidity("");
    }
    //donot let the user enter  Name whose length is lesser than 3 letters
    if (programName.length < 3) {
      programNameInputField.setCustomValidity("Please enter a  Name of at least 4 characters.");
    }
    //donot let the user enter  Name whose length is equal to 3 letters
    if (programName.length == 3) {
      if (programName.endsWith(' '))
        programNameInputField.setCustomValidity("Please enter a  Name of at least 4 characters.");
    }
    //report validity
    programNameInputField.reportValidity();
    //the validation doesnot meet, disable the save and save and new buttons else enable them
    if (!programNameInputField.checkValidity())
      this.showErrorMessage = true;
    else
      this.showErrorMessage = false;
    this.validateProgramData();
  }
  //To validate the  budget
  validateProgramData(event) {
    this.programDetail.program.Program_Budget__c = event.target.value;
    //invoke the method validateProgramData
    this.validateProgramData();
  }
  //To restrict the use of special characters
  removeProgramBudgetSpecialCharacters(event) {
    var inputId = this.template.querySelector(".programBudget");
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
  validateProgramStartDate(event) {
    this.programDetail.program.Start_Date__c = event.target.value;
    var startDate = 'START_DATE';
    this.validateDate(startDate);
  }
  validateProgramCloseDate(event) {
    this.programDetail.program.Closing_Date__c = event.target.value;
    var closeDate = 'CLOSE_DATE';
    this.validateDate(closeDate);
  }
  validateProgramInMarketDate(event) {
    this.programDetail.program.In_Market_Date__c = event.target.value;
    var inMarketDate = 'IN_MARKET_DATE';
    this.validateDate(inMarketDate);
  }
  //to validate the start,close and in market date 
  validateDate(dateType) {
    var programStartDateFieldValue = this.template.querySelector(".programStartDateInputField");
    var programCloseDateFieldValue = this.template.querySelector(".programCloseDateInputField");
    var programInMarketDateFieldValue = this.template.querySelector(".programInMarketDateInputField");
    var programStartDate = programStartDateFieldValue.value;
    var programCloseDate = programCloseDateFieldValue.value;
    var programInMarketDate = programInMarketDateFieldValue.value;
    if (programStartDate != '' && programCloseDate != '') {
      if (programStartDate > programCloseDate) {
        if (dateType == 'START_DATE')
        programStartDateFieldValue.setCustomValidity(" Closing Date cannot be before Start Date.");
        if (dateType == 'CLOSE_DATE')
        programCloseDateFieldValue.setCustomValidity(" Closing Date cannot be before Start Date.");
      } else {
        if (dateType == 'START_DATE')
        programStartDateFieldValue.setCustomValidity("");
        if (dateType == 'CLOSE_DATE')
        programCloseDateFieldValue.setCustomValidity("");
      }
      if (dateType == 'START_DATE')
      programStartDateFieldValue.reportValidity();
      if (dateType == 'CLOSE_DATE')
      programCloseDateFieldValue.reportValidity();
    }
    if (programCloseDate != '' && programInMarketDate != '') {
      if (programCloseDate > programInMarketDate) {
        if (dateType == 'CLOSE_DATE')
        programCloseDateFieldValue.setCustomValidity(" In-Market Date cannot be before Closing Date.");
        if (dateType == 'IN_MARKET_DATE')
        programInMarketDateFieldValue.setCustomValidity("In-Market Date cannot be before Closing Date.");
      } else {
        if (dateType == 'CLOSE_DATE')
        programCloseDateFieldValue.setCustomValidity("");
        if (dateType == 'IN_MARKET_DATE')
        programInMarketDateFieldValue.setCustomValidity("");
      }
      if (dateType == 'CLOSE_DATE')
      programCloseDateFieldValue.reportValidity();
      if (dateType == 'IN_MARKET_DATE')
      programInMarketDateFieldValue.reportValidity();
    }
    //the validation doesnot meet, disable the save and save and new buttons else enable them
    if (!programStartDateFieldValue.checkValidity() || !programCloseDateFieldValue.checkValidity() || !programInMarketDateFieldValue.checkValidity()){
      this.showErrorMessage = true;
    }
    else{
      this.showErrorMessage = false;
      //invoke the method validateProgramData
      this.validateProgramData();
    } 
  }
    //To validate the buy book budget
    validateProgramBudget(event) {
      this.programDetail.program.Program_Budget__c = event.target.value;
      //invoke the method validateProgramData
      this.validateProgramData();
    }
  //to the active status of the 
  handleChangeActive(event) {
    //disable the "Save" and "Save and New" buttons
    this.showErrorMessage = false;
    //assign the true value to the field Active__c field of the  if the user checks the checkbox
    this.programDetail.program.Active__c = event.target.checked;
        //invoke the method validateProgramData
        this.validateProgramData();
  }

  preventDate(event) {
    event.preventDefault();
  }
  //to save the 
  saveProgram(event) {
    console.log('this.programDetail.program',JSON.stringify(this.programDetail.program));
    //invoking a method saveProgramDetails of the class InfiniumManageProgramList_Apex
    saveProgramDetails({
      // send selected  details as the parameter
      program: JSON.stringify(this.programDetail.program),
      imageBlobData: this.isImageValidated ? '' : this.imageBlobData != '' ? encodeURIComponent(this.imageBlobData) : '',
      fileName: this.fileName,
      ContentType: this.contentType,
      selectedButtonName: this.selectedButtonName
    })
      .then(result => {
      
        // check if the user is trying to edit a 
        if (this.isEditClicked) {
          //display the toast message as the  has been updated successfully
          const evt = new ShowToastEvent({
            message: 'The program "' + this.labelName + '" has been updated successfully.',
            variant: 'success',
          });
          // disaptch the event
          this.dispatchEvent(evt);
        }
        //to check if the save is for the create pop-up and show the toast message as the  is created successfully
        else {
          const evt = new ShowToastEvent({
            title: 'Success',
            message: 'The program has been created successfully.',
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
    //make the variable program emnpty
    let temp = {
      "program": {
        "Name__c": "",
        "Closing_Date__c": "",
        "Account__c": "",
        "Program_Budget__c": '',
        "In_Market_Date__c": "",
        "Name": "",
        "Start_Date__c": "",
        "Active__c": true
      },
      "programImageURL": ""
    }
    this.programDetail = temp;
    //enable the "save" and "save and new" button
    this.showErrorMessage = true;

  }
  //To save and create a new 
  saveAndNewProgram() {
    //invoking a method saveProgramDetails of the class InfiniumManageProgramList_Apex
    saveProgramDetails({
      // send selected Program details as the parameter
      program: JSON.stringify(this.programDetail.program),
      imageBlobData: this.isImageValidated ? '' : this.imageBlobData != '' ? encodeURIComponent(this.imageBlobData) : '',
      fileName: this.fileName,
      ContentType: this.contentType,
      selectedButtonName: this.selectedButtonName
    })
      .then(result => {
        let resultGiven = result;
        //invoking disconnectedCallback method
        this.disconnectedCallback();
        // check if the user is trying to edit a Program
        if (this.isEditClicked) {
          //display the toast message as the Program has been updated successfully
          const evt = new ShowToastEvent({
            message: 'The Program "' + this.labelName + '" has been updated successfully.',
            variant: 'success',
          });
          this.dispatchEvent(evt);
        }
        //to check if the save is for the create pop-up and show the toast message as the Program is created successfully
        else {
          const evt = new ShowToastEvent({
            message: 'The Program has been created successfully.',
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
    //invoke the method validateProgramData
    this.validateProgramData();
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
    var programFileId = this.template.querySelector(".programFileId");
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
        //check if the user is editing the Program
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
    //set null value to the image URL of Program
    this.programDetail.programImageURL = '';
    //set null value to the Attachment_Id__c of the Program
    this.programDetail.program.Attachment_Id__c = '';
    //remove the displayed image
    this.isImageShown = false;
    //set null value to the imageBlobData
    this.imageBlobData = '';
    //set null value to the fileName
    this.fileName = '';
    //set null value to the contentType
    this.contentType = '';
    //invoke the method validateProgramData
    this.validateProgramData();
  }

  validateProgramData() {
    var programNameInputField = this.template.querySelector(".programNameValidation");
    var programBudget = this.template.querySelector(".programBudget");
    var programStartDate = this.template.querySelector(".programStartDateInputField");
    var programCloseDate = this.template.querySelector(".programCloseDateInputField");
    var programInMarketDate = this.template.querySelector(".programInMarketDateInputField");
    if (!programNameInputField.checkValidity() && !programStartDate.checkValidity() && !programCloseDate.checkValidity() && !programInMarketDate.checkValidity()) {
      this.showErrorMessage = true;
    }
    else
      this.showErrorMessage = false;
  }
}