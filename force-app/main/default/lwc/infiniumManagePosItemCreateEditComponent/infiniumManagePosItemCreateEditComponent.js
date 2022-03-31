// Author : Sanjana; Date : 21-09-2021

// To create and edit the pos item in the popup modal
import {LightningElement,api,track,wire} from 'lwc';
// importing the method addOrEditPOSItem_Apex from the class InfiniumManagePosItems_Apex
import addOrEditPOSItem from '@salesforce/apex/InfiniumManagePosItems_Apex.addOrEditPOSItem_Apex'
// importing the method getStateList from the class InfiniumManagePosItems_Apex
import getStateList from '@salesforce/apex/InfiniumManagePosItems_Apex.getAllState'
// importing the method getAllAndSelectedStates from the class InfiniumManagePosItems_Apex
import getAllAndSelectedStates from '@salesforce/apex/InfiniumManagePosItems_Apex.getAllAndSelectedStates'
//to display Toast Message
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
// to refresh the apex page whenever any changes hapeens in the componenet
import {refreshApex} from '@salesforce/apex';

export default class InfiniumManagePosItemCreateEditComponent extends LightningElement {
    // to get the pos item list to be edited fromparent component
    @api editedPosItemData;
    // to check if the value is to be edited or created if "isEditClicked" is true that we should edit the item
    @api isEditClicked;
    // to get the label name of the pos ite to be edited
    @api labelName;
    // the pos item name validation is received from backend and sent to the child wiith the help of parent component
    @api posItemsWithValidation;
    // the pos item stock number validation is received from backend and sent to the child wiith the help of parent component
    @api posItemStockNumberValidation;
    // get list of pos item details of the partcular pos item id
    @track posItems;
    // get the brandlist for dropdown
    @api brandListToDisplay;
    // get item type list for dropdown
    @api itemTypeListToDisplay;
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
    //to hold the value of today's date
    @track today;
    //to check if the state list needs to be displayed or not
    @track displayStateListDualBox = false;
    //To hold the available state list
    @track availableStateList;
    //To hold the available state list
    @track assignedStateList;
    //To hold the posItem Id
    @track posItemId;
    //To hold the selected state ids
    @track selectedStateIds;
    //To hold the inoke type
    @track invokeType = 'init';

    /** To capture the positem id and to determine if the item selected to edit belongs to item type name - coupon. */
    // init method to hold the result from parent component and display on page load
    connectedCallback() {
        // holding the list of pos item details of the partcular pos item id fetched fom the parent
        this.posItems = JSON.parse(JSON.stringify(this.editedPosItemData));
        //capture the positemId
        this.posItemId = this.posItems.posItemList.Id;
        if (this.posItems.posItemList.Type_of_Item__r.Item_Type__c.toUpperCase() == 'COUPON') {
            //Enable the select state section (DUAL LIST)
            this.displayStateListDualBox = true;
        } else {
            //Disable the select state section (DUAL LIST)
            this.displayStateListDualBox = false;
        }
        //determining today's data
        var todayDate = new Date();
        var dateObj = new Date(todayDate);
        dateObj.setDate(todayDate.getDate() + 1);
        var month = dateObj.getUTCMonth() + 1; //months from 1-12
        var day = dateObj.getUTCDate();
        var year = dateObj.getUTCFullYear();
        var newdate = year + "-" + month + "-" + day;
        this.today = newdate;
    }


    // combo box options

    @track value ;

    get options() {
        return [
            { label: 'Both', value: 'Both' },
            { label: 'Seasonal Program', value: 'Seasonal Program' },
            { label: 'Inventory', value: 'Inventory' },
        ];  
    }

    handleChangeForPosItemType(event) {
        var selectedValue = event.detail.value;
        this.posItems.posItemList.Inventory_Seasonal_Program__c = selectedValue;
        this.validatePosItemData();
    }

    // onchange for after the brand is selected
    handleChangeForBrand(event) {
        // assigning selected brand id to the lookup brand id of the pos item
        this.posItems.posItemList.Brand__r.Id = event.target.value;
        // assigning selected brand id to the brand field of the item
        this.posItems.posItemList.Brand__c = this.posItems.posItemList.Brand__r.Id;
        //invoke the method validatePosItemData
        this.validatePosItemData();
    }

    //To capture the item type selected by the user from the drop down
    handleChangeForItemType(event) {
        // assigning selected item type id to the lookup item type id of the pos item
        this.posItems.posItemList.Type_of_Item__r.Id = event.target.value;
        // assigning selected item type id to the item type field of the item
        this.posItems.posItemList.Type_of_Item__c = this.posItems.posItemList.Type_of_Item__r.Id;
        //to hold the item type name selected from the drop down menu
        let itemTypeName;
        //to check the selected item type id with the list of item type ids and capture the item name
        for (var i = 0; i < this.itemTypeListToDisplay.length; i++) {
            if (this.posItems.posItemList.Type_of_Item__r.Id == this.itemTypeListToDisplay[i].value)
                itemTypeName = this.itemTypeListToDisplay[i].label;
        }
        //to check if the item name is COUPON
        if (itemTypeName.toUpperCase() == 'COUPON') {
            //capture the positemId
            this.posItemId = this.posItems.posItemList.Id
            //Enable the select state section (DUAL LIST)
            this.displayStateListDualBox = true;
            //Invoke the apex method to get the state list.
            this.getStateListToBeDisplayed();
        } else {
            //Disable the select state section (DUAL LIST)
            this.displayStateListDualBox = false;
        }
        //invoke the method validatePosItemData
        this.validatePosItemData();
    }
    //close the popup modal and send custom event to parent component 
    closeModal() {
        //creating a custom event to the parent component to close the pop-up
        const closeButton = new CustomEvent('closemodal', {
            detail: {
                modalopen: false,
                //saveandnew: false,
            }
        });
        this.dispatchEvent(closeButton);
    }

    //validation on change of Pos Item stock number
    validatePosItemStockNumber() {
        // fetching the class of the item stock number input field
        var posItemStockNumberInputField = this.template.querySelector(".posItemStockNumber");
        //fetching the value of the variable posItemStockNumberInputField 
        var posItemStockNumber = posItemStockNumberInputField.value;
        //avoid repeating of the characters entered by the users
        posItemStockNumber = posItemStockNumber.replace(/\s/g, '');
        posItemStockNumber = posItemStockNumber.replace(/__+/g, '_');
        posItemStockNumber = posItemStockNumber.replace(/--+/g, '-');
        posItemStockNumber = posItemStockNumber.replace(/\.\.+/g, '.');
        //dont let the user start the stock number with characters
        if (posItemStockNumber.startsWith('_') || posItemStockNumber.startsWith('-') || posItemStockNumber.startsWith('.')) {
            var posItemStockNumber_FirstCharacter = posItemStockNumber.match(/[^_.-]/);
            if (!posItemStockNumber_FirstCharacter) {
                posItemStockNumber = '';
            } else {
                var posItemStockNumber_Index = posItemStockNumber.indexOf(posItemStockNumber_FirstCharacter);
                posItemStockNumber = posItemStockNumber.substring(posItemStockNumber_Index, posItemStockNumber.length);
            }
        }
        this.posItems.posItemList.Item_No__c = posItemStockNumber;

        var regexForSpecialCharacters = /[^a-zA-Z0-9_.-]/ig;
        //donot allow special characters except for hyphen, dot and underscore
        if (regexForSpecialCharacters.test(posItemStockNumber)) {
            posItemStockNumberInputField.setCustomValidity("Special characters not allowed except _-.");
        } else {
            if (this.posItemStockNumberValidation.includes(posItemStockNumber.replace(/\s/g, '').toUpperCase().trim())) {
                posItemStockNumberInputField.setCustomValidity("Item number already exists.Please check and enter again.");
            } else
                posItemStockNumberInputField.setCustomValidity("");
        }
        //display the error message on invalid input field
        posItemStockNumberInputField.reportValidity();
        //invoke the method validatePosItemData
        this.validatePosItemData();
    }

    // Validation onchnage of pos item Name
    validatePosItemName() {
        // fetching the class of the item name input field
        var posItemNameInputField = this.template.querySelector(".posItemName");
        //fetching the value of the variable posItemNameInputField 
        var posItemName = posItemNameInputField.value;
        //avoid repeating of the characters entered by the users
        posItemName = posItemName.replace(/\s\s+/g, ' ');
        posItemName = posItemName.replace(/__+/g, '_');
        posItemName = posItemName.replace(/--+/g, '-');
        posItemName = posItemName.replace(/\.\.+/g, '.');
        posItemName = posItemName.replace(/,,+/g, ',');
        posItemName = posItemName.replace(/\'\'+/g, '\'');
        posItemName = posItemName.replace(/\/\/+/g, '\/');
        //dont let the user start the stock number with characters
        if (posItemName.startsWith(' ') || posItemName.startsWith('_') || posItemName.startsWith('-') ||
            posItemName.startsWith('.') || posItemName.startsWith(',') || posItemName.startsWith('\'')) {
            var posItemName_FirstCharacter = '';
            if (!posItemName.includes('\''))
                posItemName_FirstCharacter = posItemName.match(/[^_. -,/]/);
            else
                posItemName_FirstCharacter = posItemName.match(/'\''/);

            if (!posItemName_FirstCharacter) {
                posItemName = '';
            } else {
                var posItemName_Index = posItemName.indexOf(posItemName_FirstCharacter);
                posItemName = posItemName.substring(posItemName_Index, posItemName.length);
            }
        }
        this.posItems.posItemList.Item_Name__c = posItemName;
        var regexForSpecialCharacters = /[^a-zA-Z0-9 _.,-/]/ig;
        //donot allow special characters except for hyphen, dot and underscore
        if (regexForSpecialCharacters.test(posItemName) && !posItemName.includes('\'')) {
            posItemNameInputField.setCustomValidity("Special characters not allowed except _- .,'/");
        } else {
            if (this.posItemsWithValidation.includes(posItemName.replace(/\s/g, '').toUpperCase().trim()) &&
                posItemName.replace(/\s/g, '').toUpperCase().trim() != this.labelName.replace(/\s/g, '').toUpperCase().trim()) {
                posItemNameInputField.setCustomValidity("Pos item name exists. Please check and enter again.");
            } else
                posItemNameInputField.setCustomValidity("");
        }
        //   donot allow the user to enter the name that is less than or equal to 4 letters
        if (posItemName.length < 4) {
            posItemNameInputField.setCustomValidity("Please enter item name more than 3 characters.");
        }
        if (posItemName.length > 40) {
            posItemNameInputField.setCustomValidity("Please enter item name less than 40 characters.");
        }
        if (posItemName.length == 4) {
            if (posItemName.endsWith(' '))
                posItemNameInputField.setCustomValidity("Please enter item name more than 3 characters.");
        }
        //display the error message on invalid input field
        posItemNameInputField.reportValidity();
        //invoke the method validatePosItemData
        this.validatePosItemData();
    }


    // validation onc cg=hange of pos item pack of
    validatePosItemPackOf() {
        // fetching the class of the item pack of input field
        var posItemPackOfInputField = this.template.querySelector(".packOf");
        //fetch the value of the variable posItemPackOfInputField and give it to the variable packOfValue
        var packOfValue = posItemPackOfInputField.value;
        //give the value to the object field Pack_Of__c of the posItem
        this.posItems.posItemList.Pack_Of__c = packOfValue;
        var regexForSpecialCharacters = /[^0-9]/g;
        //do not allow the user to enter any other character/letter other than numbers, else display the custom error message
        if (regexForSpecialCharacters.test(packOfValue))
            posItemPackOfInputField.setCustomValidity("Only numbers allowed");
        else
            posItemPackOfInputField.setCustomValidity("");
        //display the error message on invalid input field
        posItemPackOfInputField.reportValidity();
        //invoke the method validatePosItemData
        this.validatePosItemData();
    }


    // validation for price
    validatePosItemPrice(event) {
        // fetching the class of the item price of input field
        var posItemPriceInputField = this.template.querySelector(".posItemPrice");
        //fetch the value of the variable posItemPriceInputField and give it to the variable priceValue
        var priceValue = posItemPriceInputField.value;
        //give the value to the object field Price__c of the posItem
        this.posItems.posItemList.Price__c = priceValue;
        var regexForSpecialCharacters = /[^0-9.]/g;
        //do not allow the user to enter any other character/letter other than decimal values, else display the custom error message
        if (regexForSpecialCharacters.test(priceValue))
            posItemPriceInputField.setCustomValidity("Only decimal numbers allowed");
        else {
            if (priceValue.split('.').length > 2 || priceValue.endsWith('.'))
                posItemPriceInputField.setCustomValidity("Price is invalid");
            else {
                if (priceValue.startsWith('.'))
                    this.posItems.posItemList.Price__c = isNaN(parseFloat(priceValue)) ? 0 : parseFloat(priceValue);

                posItemPriceInputField.setCustomValidity("");

            }
        }
        //display the error message on invalid input field
        posItemPriceInputField.reportValidity();
        // invoke the method removeSpecialCharacters along with the variable posItemPriceInputField as its parameter
        this.removeSpecialCharacters(posItemPriceInputField, event);
        //invoke the method validatePosItemData
        this.validatePosItemData();
    }

    validateItemDescription(event) {
        //assign the value of event.target.value to the field Item_Descrption__c of the pos item
        this.posItems.posItemList.Item_Descrption__c = event.target.value;
        //invoke the method validatePosItemData
        this.validatePosItemData();
    }


    //validation on change of Approval Required
    handleChangeApprovalRequired(event) {
        //assign the value entered by the user to the field Approval_Required__c of the object pos item
        this.posItems.posItemList.Approval_Required__c = event.target.checked;
        //invoke the method validatePosItemData
        this.validatePosItemData();

    }

    //validation on change of Marketing only
    handleChangeMarketingOnly(event) {
        //assign the value entered by the user to the field Marketing_Only__c of the object pos item
        this.posItems.posItemList.Marketing_Only__c = event.target.checked;
        //invoke the method validatePosItemData
        this.validatePosItemData();

    }

    //validation on change of LOt Number required
    handleChangeLotNumberRequired(event) {
        //assign the value entered by the user to the field LotNumberRequired__c of the object pos item
        this.posItems.posItemList.LotNumberRequired__c = event.target.checked;
        //invoke the method validatePosItemData
        this.validatePosItemData();

    }
    //validation on change of active status
    handleChangeActiveStatus(event) {
        //assign the value entered by the user to the field Active__c of the object pos item
        this.posItems.posItemList.Active__c = event.target.checked;
        //invoke the method validatePosItemData
        this.validatePosItemData();

    }

    //validation on change of remove special character
    removeSpecialCharacters(inputFieldData, event) {
        var inputId = inputFieldData;
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

    //validation on change of pos item length
    validatePosItemLength(event) {
        // fetching the class of the item length of input field
        var posItemLengthInputField = this.template.querySelector(".numericvalidationForLength");
        //fetch the value of the variable posItemLengthInputField and give it to the variable lengthValue
        var lengthValue = posItemLengthInputField.value;
        //give the value to the object field Length__c of the posItem
        this.posItems.posItemList.Length__c = lengthValue;
        var regexForSpecialCharacters = /[^0-9.]/g;
        //do not allow the user to enter any other character/letter other than decimal values, else display the custom error message
        if (regexForSpecialCharacters.test(lengthValue)) {
            posItemLengthInputField.setCustomValidity("Only decimal numbers allowed");
        } else {
            if (lengthValue.split('.').length > 2 || lengthValue.endsWith('.'))
                posItemLengthInputField.setCustomValidity("Length is invalid");
            else {
                if (lengthValue.startsWith('.'))

                    this.posItems.posItemList.Length__c = lengthValue;
                //let the user enter value only between 0.0001 to 48 else display the error message on invalid input field
                var fieldFloatValue = isNaN(parseFloat(lengthValue)) ? 0 : parseFloat(lengthValue);
                if (lengthValue != '' && (fieldFloatValue < 0.001 || fieldFloatValue > 48))
                    posItemLengthInputField.setCustomValidity('Value must be between 0.001 to 48');
                else
                    posItemLengthInputField.setCustomValidity('');
                //invoke the method removeSpecialCharacters
                this.removeSpecialCharacters(posItemLengthInputField, event);
                //invoke the method validatePosItemData
                this.validatePosItemData();
            }
        }
    }

    //validation on change of pos item width
    validatePosItemWidth() {
        // fetching the class of the item width of input field
        var posItemWidthInputField = this.template.querySelector(".numericvalidationForWidth");
        //fetch the value of the variable posItemWidthInputField and give it to the variable widthValue
        var widthValue = posItemWidthInputField.value;
        //give the value to the object field Width__c of the posItem
        this.posItems.posItemList.Width__c = widthValue;
        var regexForSpecialCharacters = /[^0-9.]/g;
        //do not allow the user to enter any other character/letter other than decimal values, else display the custom error message
        if (regexForSpecialCharacters.test(widthValue)) {
            posItemWidthInputField.setCustomValidity("Only decimal numbers allowed");
        } else {
            if (widthValue.split('.').length > 2 || widthValue.endsWith('.'))
                posItemWidthInputField.setCustomValidity("Width is invalid");
            else {
                if (widthValue.startsWith('.'))

                    this.posItems.posItemList.Width__c = widthValue;
                //let the user enter value only between 0.0001 to 48 else display the error message on invalid input field
                var fieldFloatValue = isNaN(parseFloat(widthValue)) ? 0 : parseFloat(widthValue);
                if (widthValue != '' && (fieldFloatValue < 0.001 || fieldFloatValue > 48))
                    posItemWidthInputField.setCustomValidity('Value must be between 0.001 to 48');
                else
                    posItemWidthInputField.setCustomValidity('');
                //invoke the method removeSpecialCharacters
                this.removeSpecialCharacters();
                //invoke the method validatePosItemData
                this.validatePosItemData();
            }
        }
    }


    //validation on change of pos item height
    validatePosItemHeight() {
        // fetching the class of the item height of input field
        var posItemHeigthInputField = this.template.querySelector(".numericValidationForHeight");
        //fetch the value of the variable posItemHeigthInputField and give it to the variable heigthValue
        var heigthValue = posItemHeigthInputField.value;
        //give the value to the object field Height__c of the posItem
        this.posItems.posItemList.Height__c = heigthValue;
        var regexForSpecialCharacters = /[^0-9.]/g;
        //do not allow the user to enter any other character/letter other than decimal values, else display the custom error message
        if (regexForSpecialCharacters.test(heigthValue)) {
            posItemHeigthInputField.setCustomValidity("Only decimal numbers allowed");
        } else {
            if (heigthValue.split('.').length > 2 || heigthValue.endsWith('.'))
                posItemHeigthInputField.setCustomValidity("Heigth is invalid");
            else {
                if (heigthValue.startsWith('.'))

                    this.posItems.posItemList.Height__c = heigthValue;
                //let the user enter value only between 0.0001 to 48 else display the error message on invalid input field
                var fieldFloatValue = isNaN(parseFloat(heigthValue)) ? 0 : parseFloat(heigthValue);
                if (heigthValue != '' && (fieldFloatValue < 0.001 || fieldFloatValue > 48))
                    posItemHeigthInputField.setCustomValidity('Value must be between 0.001 to 48');
                else
                    posItemHeigthInputField.setCustomValidity('');
                //invoke the method removeSpecialCharacters
                this.removeSpecialCharacters();
                //invoke the method validatePosItemData
                this.validatePosItemData();
            }
        }
    }


    //validation on change of pos item weight
    validatePosItemWeight() {
        // fetching the class of the item weight of input field
        var posItemWidthInputField = this.template.querySelector(".numericValidationForWeight");
        //fetch the value of the variable posItemWidthInputField and give it to the variable weigthValue
        var weigthValue = posItemWidthInputField.value;
        //give the value to the object field Weight__c of the posItem
        this.posItems.posItemList.Weight__c = weigthValue;
        //let the user enter value only between 0.0001 to 48 else display the error message on invalid input field
        var regexForSpecialCharacters = /[^0-9.]/g;
        //do not allow the user to enter any other character/letter other than decimal values, else display the custom error message
        if (regexForSpecialCharacters.test(weigthValue)) {
            posItemWidthInputField.setCustomValidity("Only decimal numbers allowed");
        } else {
            if (weigthValue.split('.').length > 2 || weigthValue.endsWith('.'))
                posItemWidthInputField.setCustomValidity("Weigth is invalid");
            else {
                if (weigthValue.startsWith('.'))

                    this.posItems.posItemList.Weight__c = weigthValue;
                var fieldFloatValue = isNaN(parseFloat(weigthValue)) ? 0 : parseFloat(weigthValue);
                if (weigthValue != '' && (fieldFloatValue < 0.001 || fieldFloatValue > 2000))
                    posItemWidthInputField.setCustomValidity('Value must be between 0.001 to 2000');
                else
                    posItemWidthInputField.setCustomValidity('');
                //invoke the method removeSpecialCharacters
                this.removeSpecialCharacters();
                //invoke the method validatePosItemData
                this.validatePosItemData();
            }
        }

    }

    //validation on change of Low level inventory applicable
    handleChangeLowInventoryLevelApplicable(event) {
        //assign the value entered by the user to the field Low_inventory_level_applicable__c of the object pos item
        this.posItems.posItemList.Low_inventory_level_applicable__c = event.target.checked;
        //invoke the method validatePosItemData
        this.validatePosItemData();

    }
    //validation on change of pos item low inventory level
    validateLowLevelInventory() {
        // fetching the class of the item low level inventory of input field
        var posItemLowLevelInputField = this.template.querySelector(".lowInventoryLevel");
        //fetch the value of the variable posItemLowLevelInputField and give it to the variable lowLevelValue
        var lowLevelValue = posItemLowLevelInputField.value;
        //give the value to the object field Low_Inventory_Level__c of the posItem
        this.posItems.posItemList.Low_Inventory_Level__c = lowLevelValue;
        var regexForSpecialCharacters = /[^0-9]/g;
        //do not allow users to enter anything other than the numbers
        if (regexForSpecialCharacters.test(lowLevelValue))
            posItemLowLevelInputField.setCustomValidity("Only numbers allowed");
        else
            posItemLowLevelInputField.setCustomValidity("");
        //invoke the method removeSpecialCharacters
        posItemLowLevelInputField.reportValidity();
        //invoke the method validatePosItemData
        this.validatePosItemData();
    }


    //validation on change of pos item max order quntity
    validateMaxOrderQuantity(event) {
        // fetching the class of the maximum quantity applicable input field
        var posItemMaximumQtyInputField = this.template.querySelector(".maximumOrderQuantityApplicable");
        //fetch the value of the variable posItemMaximumQtyInputField and give it to the variable MaximuQtyValue
        var MaximuQtyValue = posItemMaximumQtyInputField.value;
        //give the value to the object field Maximum_Order_Qty__c of the posItem
        this.posItems.posItemList.Maximum_Order_Qty__c = MaximuQtyValue;
        //do not allow users to enter anything other than the numbers
        var regexForSpecialCharacters = /[^0-9]/g;
        var keyCodes = [8, 37, 38, 39, 40];
        if (regexForSpecialCharacters.test(event.key) && !keyCodes.includes(event.keyCode))
            event.preventDefault();

        if (regexForSpecialCharacters.test(MaximuQtyValue))
            posItemMaximumQtyInputField.setCustomValidity("Only numbers allowed");
        else
            posItemMaximumQtyInputField.setCustomValidity("");
        posItemMaximumQtyInputField.reportValidity();
        //invoke the method validatePosItemData
        this.validatePosItemData();

    }

    //validation on change of pos item date
    handleChangeExpirationDateRequired(event) {
        //assign the boolean value checked by the user to the field ExpirationDateRequired__c of the pos item
        this.posItems.posItemList.ExpirationDateRequired__c = event.target.checked;
        //invoke the method validatePosItemData
        this.validatePosItemData();
    }

    handleChangeMaxOrderQuantityApplicable(event) {
        //assign the boolean value checked by the user to the field Maximum_order_quantity_applicable__c of the pos item
        this.posItems.posItemList.Maximum_order_quantity_applicable__c = event.target.checked;
        //invoke the method validatePosItemData
        this.validatePosItemData();
    }

    //validation on change of pos item expected date
    validateExpirationDate(event) {

        //assign the date value checked by the user to the field Expiration_Date__c of the pos item
        this.posItems.posItemList.Expiration_Date__c = event.target.value;
        //invoke the method validatePosItemData
        this.validatePosItemData();
    }

    //validation on change of haromonization code
    validateHarmonizationCode() {
        // fetching the class of the haromonization code input field
        var posItemHarmonizationCodeInputField = this.template.querySelector(".posItemHarmonizationCode");
        //fetch the value of the variable posItemHarmonizationCodeInputField and give it to the variable harmonizationCode
        var harmonizationCode = posItemHarmonizationCodeInputField.value;
        //avoid repeating of the characters entered by the users
        harmonizationCode = harmonizationCode.replace(/\s/g, '');
        harmonizationCode = harmonizationCode.replace(/__+/g, '_');
        harmonizationCode = harmonizationCode.replace(/--+/g, '-');
        harmonizationCode = harmonizationCode.replace(/\.\.+/g, '.');
        //donot allow special characters except for hyphen, dot and underscore
        if (harmonizationCode.startsWith('_') || harmonizationCode.startsWith('-') || harmonizationCode.startsWith('.')) {
            var harmonizationCode_FirstCharacter = harmonizationCode.match(/[^_.-]/);
            if (!harmonizationCode_FirstCharacter) {
                harmonizationCode = '';
            } else {
                var harmonizationCode_Index = harmonizationCode.indexOf(harmonizationCode_FirstCharacter);
                harmonizationCode = harmonizationCode.substring(harmonizationCode_Index, harmonizationCode.length);
            }

        }
        this.posItems.posItemList.HarmonizationCode__c = harmonizationCode;
        var regexForSpecialCharacters = /[^a-zA-Z0-9_.-]/ig;
        //do not allow any special characters other than underscore, hyphen and dot
        if (regexForSpecialCharacters.test(harmonizationCode)) {
            posItemHarmonizationCodeInputField.setCustomValidity("Special characters not allowed except _-.");
        } else {
            posItemHarmonizationCodeInputField.setCustomValidity("");
        }
        //display error message if the input is invalid
        posItemHarmonizationCodeInputField.reportValidity();
        //invoke the method validatePosItemData
        this.validatePosItemData();
    }


    // POS Item Image
    handleFilesChange(event) {
        //fetch the file uploaded by the user and store it in the variable filesUploaded
        this.filesUploaded = event.target.files;
        //hold the value of the variable filesUploaded to the variable files
        var files = this.filesUploaded;
        if (files[0] != undefined) {
            // invoke the method ResizeImageToUpload
            this.ResizeImageToUpload();
        }
        //invoke the method validatePosItemData
        this.validatePosItemData();
    }

    ResizeImageToUpload() {
        //to enable the save button
        this.isButtonDisable = true;
        //to enable the preview of the image
        this.isImageShown = true;
        //hold the value of the variable filesUploaded to the variable files
        this.file = this.filesUploaded[0];
        //fetching the class of the image input field
        var posItemFileId = this.template.querySelector(".posItemFileId");
        // create a FileReader object 

        this.fileReader = new FileReader();
        // set onload function of FileReader object  
        this.fileReader.onloadend = ((event) => {
            //to store the result of the variable fileReader
            this.fileContents = this.fileReader.result;
            //   console.log('this.fileReader.result',JSON.stringify(this.fileReader.result));
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
                    var MAX_WIDTH = 220;
                    //setting max height of the image to 200
                    var MAX_HEIGHT = 220;
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
                    // access elements rendered by a component using the class
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
            });
        });
        //read the image as URL to show the preview of the image
        this.fileReader.readAsDataURL(this.file);
    }



    // validation on Image
    uploadHelper() {
        //display the preview of the uploaded message
        this.isImageShown = true;
        //hold the value of the variable filesUploaded to the variable files
        this.file = this.filesUploaded[0];
        // fetching the class of the image input field
        var posItemFileId = this.template.querySelector(".posItemFileId");
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
            //on load of an image
            this.image.onload = (() => {
                //fetch the image loaded by the user
                var img = this.template.querySelector(".attachedImage");
                //determine the width of an image
                var imageWidth = img.clientWidth;
                //determine the height of an image
                var imageHeight = img.clientHeight;

                //check if the width and height of an image is exceeding 200 and do not allow the user to exceed 200
                if (parseInt(imageWidth) > 200 || parseInt(imageHeight) > 200) {
                    posItemFileId.setCustomValidity("Image size is " + imageWidth + " x " + imageHeight + " Image width should be less than 200 and Image height should be less than 200");
                    this.isImageValidated = true;
                }
                //else, preveiw the uploaded image
                else {
                    this.imageBlobData = this.fileContents;
                    this.fileName = this.file.name;
                    this.contentType = this.file.type;
                    var preview = [];
                    preview = this.template.querySelector(".attachedImage");
                    preview.src = this.fileReader.result;
                    //check if the user is editing/ creating a pos item
                    // if (this.isEditClicked == true) {
                    //     //if user is editing, enable the save button
                    //     this.isButtonDisable = false;
                    // } else {
                    //     //else disable the save button
                    //     this.isButtonDisable = true;
                    // }
                    //
                    this.isImageValidated = false;
                    posItemFileId.setCustomValidity("");
                }
                //display error message if the image is invalid
                posItemFileId.reportValidity();
            });
        });
        //read the image as URL to show the preview of the image
        this.fileReader.readAsDataURL(this.file);
    }

    // remove the image
    removeImage() {
        //set null value to the image URL of pos items
        this.posItems.posItemImageURL = '';
        //set null value to the Attachment_Id__c of the pos items
        this.posItems.posItemList.Attachment_Id__c = '';
        //remove the displayed image
        this.isImageShown = false;
        //set null value to the imageBlobData
        this.imageBlobData = '';
        //set null value to the fileName
        this.fileName = '';
        //set null value to the contentType
        this.contentType = '';
        //invoke the method validatePosItemData
        this.validatePosItemData();
    }

    // validation for vendor name
    validateVendorName(event) {
        //assign the value of event.target.value to the field Vendor__c of the pos item
        this.posItems.posItemList.Vendor__c = event.target.value;
        //invoke the method validatePosItemData
        this.validatePosItemData();
    }

    //  The below line is commeneted to validated for seasonal program as below method was for inventory
    // Validation for all required pos item data
    validatePosItemData() {
        //enable the save button
        this.isButtonDisable = true;
        // fetching the class of the available stock number input field
        var posItemStockNumberInputField = this.template.querySelector(".posItemStockNumber");
        // fetching the class of the available pos item name input field
        var posItemNameInputField = this.template.querySelector(".posItemName");
        // fetching the class of the brand drop down menu
        var posItemBrandInputField = this.template.querySelector(".posItemBrandId");
        // fetching the class of the item type drop down menu
        var posItemItemTypeInputField = this.template.querySelector(".posItemItemTypeId");
        // fetching the class of the available pack of input field
        var posItemPackOfInputField = this.template.querySelector(".packOf");
        // fetching the class of the available item price input field
        var posItemPriceInputField = this.template.querySelector(".posItemPrice");
        // fetching the class of the available length input field
        var lengthInputField = this.template.querySelector(".numericvalidationForLength");
        // fetching the class of the available width input field
        var widthInputField = this.template.querySelector(".numericvalidationForWidth");
        // fetching the class of the available height input field
        var heightInputField = this.template.querySelector(".numericValidationForHeight");
        // fetching the class of the available weight input field
        var weightInputField = this.template.querySelector(".numericValidationForWeight");
        // fetching the class of the available expiration date input field
        var posItemExpirationDateInputField = this.template.querySelector(".posItemExpirationDate");
        // fetching the class of the low level inventory input field
        var posItemLowLevelInputField = this.template.querySelector(".lowInventoryLevel");
        // fetching the class of the maximum ordered qty input field
        var posItemMaxQtyInputField = this.template.querySelector(".maximumOrderQuantityApplicable");
        // fetching the class of the available pos item file Id input field
        var posItemFileId = this.template.querySelector(".posItemFileId");
        //to check if all the madotry field data is present
        var allCheckValidity = true;
        //check validity of all the input fields and enable the save button if all the input fields are valid
        if (posItemStockNumberInputField.checkValidity() && posItemNameInputField.checkValidity() && posItemBrandInputField.checkValidity() && posItemItemTypeInputField.checkValidity() && posItemPriceInputField.checkValidity() && posItemPackOfInputField.checkValidity() &&
            lengthInputField.checkValidity() && widthInputField.checkValidity() &&
            heightInputField.checkValidity() && weightInputField.checkValidity()
        ) {
            allCheckValidity = false;
        } else {
            allCheckValidity = true;
        }
        //to check if the data for expiration date exist if the ExpirationDateRequired__c is true
        var isPosItemExperirationdate = false;
        if (this.posItems.posItemList.ExpirationDateRequired__c == true) {
            if (posItemExpirationDateInputField.checkValidity()) {
                isPosItemExperirationdate = false;
            } else {
                isPosItemExperirationdate = true;
            }
        }
        //to check if the data for low level inventory exist if the Low_inventory_level_applicable__c is true
        var isLowLevelInventory = false;
        if (this.posItems.posItemList.Low_inventory_level_applicable__c == true) {
            if (posItemLowLevelInputField.checkValidity()) {
                isLowLevelInventory = false;
            } else {
                isLowLevelInventory = true;
            }
        }
        //to check if the data formaximum order qty exist if the Maximum_order_quantity_applicable__c is true
        var isMaxOrderQty = false;
        if (this.posItems.posItemList.Maximum_order_quantity_applicable__c == true) {
            if (posItemMaxQtyInputField.checkValidity()) {
                isMaxOrderQty = false;
            } else {
                isMaxOrderQty = true;
            }
        }
        //if any of the boolean field contains true value then button should be disabled.
        if (allCheckValidity == true || isPosItemExperirationdate == true || isLowLevelInventory == true || isMaxOrderQty)
            this.isButtonDisable = true;
        else
            this.isButtonDisable = false;

    } 

    // Validation for all required pos item data
    // validatePosItemData() {
    //     //enable the save button
    //     this.isButtonDisable = true;
    //     // fetching the class of the available stock number input field
    //     var posItemStockNumberInputField = this.template.querySelector(".posItemStockNumber");
    //     // fetching the class of the available pos item name input field
    //     var posItemNameInputField = this.template.querySelector(".posItemName");
    //     // fetching the class of the brand drop down menu
    //     var posItemBrandInputField = this.template.querySelector(".posItemBrandId");
    //     // fetching the class of the item type drop down menu
    //     var posItemItemTypeInputField = this.template.querySelector(".posItemItemTypeId");
    //     // fetching the class of the available pack of input field
    //     var posItemPackOfInputField = this.template.querySelector(".packOf");
    //     // fetching the class of the available item price input field
    //     var posItemPriceInputField = this.template.querySelector(".posItemPrice");
    //     // fetching the class of the available length input field
    //     var lengthInputField = this.template.querySelector(".numericvalidationForLength");
    //     // fetching the class of the available width input field
    //     var widthInputField = this.template.querySelector(".numericvalidationForWidth");
    //     // fetching the class of the available height input field
    //     var heightInputField = this.template.querySelector(".numericValidationForHeight");
    //     // fetching the class of the available weight input field
    //     var weightInputField = this.template.querySelector(".numericValidationForWeight");
    //     // fetching the class of the available expiration date input field
    //     var posItemExpirationDateInputField = this.template.querySelector(".posItemExpirationDate");
    //     //to check if all the madotry field data is present
    //     var allCheckValidity = true;
    //     //check validity of all the input fields and enable the save button if all the input fields are valid
    //     if (posItemStockNumberInputField.checkValidity() && posItemNameInputField.checkValidity() && posItemBrandInputField.checkValidity() && posItemItemTypeInputField.checkValidity() && posItemPriceInputField.checkValidity() && posItemPackOfInputField.checkValidity() &&
    //         lengthInputField.checkValidity() && widthInputField.checkValidity() &&
    //         heightInputField.checkValidity() && weightInputField.checkValidity()
    //     ) {
    //         allCheckValidity = false;
    //     } else {
    //         allCheckValidity = true;
    //     }
    //     //to check if the data for expiration date exist if the ExpirationDateRequired__c is true
    //     var isPosItemExperirationdate = false;
    //     if (this.posItems.posItemList.ExpirationDateRequired__c == true) {
    //         if (posItemExpirationDateInputField.checkValidity()) {
    //             isPosItemExperirationdate = false;
    //         } else {
    //             isPosItemExperirationdate = true;
    //         }
    //     }

    //     //if any of the boolean field contains true value then button should be disabled.
    //     if (allCheckValidity == true || isPosItemExperirationdate == true)
    //         this.isButtonDisable = true;
    //     else
    //         this.isButtonDisable = false;

    // }

    // save the pos item data
    savePosItem() {
        console.log('line 972---->',JSON.stringify(this.posItems.posItemList.Inventory_Seasonal_Program__c));
        addOrEditPOSItem({
            posItem: this.posItems.posItemList,
            imageBlobData: this.isImageValidated ? '' : this.imageBlobData != '' ? encodeURIComponent(this.imageBlobData) : '',
            fileName: this.fileName,
            ContentType: this.contentType,
            states: JSON.stringify(this.selectedStateIds)
        })
            .then(result => {
                let resultGiven = result;
                //to display toast message after update
                if (this.isEditClicked) {
                    const evt = new ShowToastEvent({
                        message: 'The pos item "' + this.labelName + '" has been updated successfully.',
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);
                }
                //to check if the save is for the create pop-up and show the toast message
                else {
                    const evt = new ShowToastEvent({
                        message: 'The pos item has been created successfully.',
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);
                }
                //To set the modal vale to false and send the value to parent , as the parent needs to know the value changed to open/close the popUp
                const closeButton = new CustomEvent('closemodal', {
                    detail: {
                        modalopen: false,
                    }
                });
                this.dispatchEvent(closeButton);
            })
    }

    @wire(getStateList)
    getAllStates;
    @wire(getAllAndSelectedStates, {
        posItemId: '$posItemId'
    })
    getStates;
    get getStateListToBeDisplayed() {
        //to get the state list for the item type coupoun
        if (this.getStates.data) {
            let getStateList = this.getStates.data;
            this.availableStateList = getStateList.allStates;
            this.assignedStateList = getStateList.selectedStates;
            if (this.invokeType == 'init') {
                this.selectedStateIds = this.assignedStateList;
            }
            refreshApex(this.getStates)
        }
        // to get the state list for the item type coupoun if the states are not associated
        else if (this.getAllStates.data) {
            this.availableStateList = this.getAllStates.data;
            refreshApex(this.getAllStates)
        }

    }
    handleSelectedStates(event) {
        this.invokeType = 'selectedStateIds';
        this.selectedStateIds = event.target.value;
        this.validatePosItemData();
    }
}