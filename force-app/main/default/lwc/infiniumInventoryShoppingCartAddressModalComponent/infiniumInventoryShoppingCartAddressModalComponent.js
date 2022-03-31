// Authors:Sanjana   Date:08-11-2021
//Aim: to display the list of addresses and shipping menthods along with search filter and pagination in    the popup modal
    //to save the addresses
    import {
        LightningElement,
        track,
        api,
        wire
    } from 'lwc';
    //To save addresses for the particular items
    import saveAddressForSelectedItem from '@salesforce/apex/InfiniumInventoryShoppingCart_Apex.saveAddressForSelectedItem'
    //to save addresses for all items
    import saveAddressForAllOrderedItems from '@salesforce/apex/InfiniumInventoryShoppingCart_Apex.saveAddressForAllOrderedItems'
    // to get the address book list on click on Add same address
    import getUserAddressBookList from '@salesforce/apex/InfiniumInventoryShoppingCart_Apex.getUserAddressBookList'
    //to get the address book list on click on shipping address
    import getPosItemUserAddressBookList from '@salesforce/apex/InfiniumInventoryShoppingCart_Apex.getPosItemUserAddressBookList'
    import {
        refreshApex
    } from '@salesforce/apex';
    
export default class InfiniumInventoryShoppingCartAddressModalComponent extends LightningElement {
      //To hold the true/false value for isAddAllAddresses
      @api isAddAllAddresses;
      //To hold the total items in the cart
      @api posItemsListInCart;
      //to hold the selected pos item for shipping address
      @api particularPosItemDetails;
  // to selected adddress to get fom the parent
      @api selectedAddressForPosItems;
      // shipping method list
      @api shippingMethodListData;
      //To hold the sshipping method list
      @track shippingMethodList;
      //to hold the search result for searched value
      @track searchedAddresslistResult = [];
      //To hold the value true/false for the pop up modal
      @track isModalOpen = true;
      //To hold the available address list
      @track avaialbleAddressList;
      //To hold the selectedAddresslist
      @track selectedAddressList =[];
      //To hold the previously selected address list
      @track previouslyselectedAddressList;
      //to hold the response from the server call for getting the address list
      @track allAddressFromBackEnd;
      //to check if the pagination buttons are clicked
      @track isPagination;
      //To hold the shipping address with quantity details
      @track shippingAddressWithQtyDetails = [];
      //to hold the searckey word
      @track searchedKeyword = '';
      //to hold if the searchkey is present
      @track isSearchkey = true;
      //to hold the posItemList in cart
      @track getPosItem;
      //to hold the selected pos item details
      @track getParticularItem = [];
      //to hold the selected addresses from front end
      @track frontEndSelectedAddressList = [];
      //to hold validation for selected address list from front end
      @track validate = 'init';
      //to hold the unselected address from front end
      @track frontEndUnSelectedAddressList = [];
      //to disable the save button
      @track isdisableSave = true;
      //to hold the radio button value
      @track selectedRadioType = 'DOMESTIC';
      // pagination
      //To total size of address list
      @track totalAddressListSize;
      //to hold naviagtion items
      @track navigationItems;
      //to hold start index
      @track startIndex = 1;
      //to hold last index
      @track lastIndex = 5;
      //to hold selected index
      @track selectedIndex = 1;
      //to hold record start index
      @track recordStartIndex = 0;
      //to hold if the last navigation items exist or not
      @track isItLastNavigationItem = false;
      //to hold if the first navigation items exist or not
      @track isItFirstNavigationItem = false;
      // to hold all address list
      @track allAdressList;
      //to check if available addresses available
      @track isavailableaddresses = false;
      // To get the users details
      @api user;
      @track defaultValue;
      value='DOMESTIC';
  
  
      // to hold the radio button options
      get options() {
          return [{
                  label: 'Domestic',
                  value: 'DOMESTIC'
              
                  
              },
              {
                  label: 'International',
                  value: 'INTERNATIONAL'
              },
          ];
      }
  
      handleChangeRadioButton(event){
          this.selectedRadioType = event.target.value;
          this.isPagination = true;
          this.recordStartIndex = 0;
          this.selectedIndex =1;
      }
  
      //To close modal
      closeModal() {
          this.isModalOpen = false;
          const closeButton = new CustomEvent('closemodal', {
              detail: this.isModalOpen
          })
          this.dispatchEvent(closeButton);
      }
  
      connectedCallback() {   
          //    to get the shipping address from parent componet       
          if (this.shippingMethodListData) {
              //  console.log(JSON.stringify(this.shippingMethodListData))
              let shippingMethodData = [];
              // for each shipping method
              this.shippingMethodListData.forEach(element => {
                  const shippingMethod = {};
  
                  shippingMethod.label = element.Shipping_Method_Name__c;
  
                  shippingMethod.value = element.Id;
  
                  shippingMethod.default = element.Default__c;
  
                  if(shippingMethod.default == true){
                     this.defaultValue= element.Id;
                  }
                  shippingMethodData.push(shippingMethod);
  
                  this.shippingMethodList = shippingMethodData;
  
              });
  
          }
          if (this.isAddAllAddresses == false) {
              this.getParticularItem = JSON.stringify(this.particularPosItemDetails);
          } else if (this.isAddAllAddresses) {
              this.getPosItem = JSON.stringify(this.posItemsListInCart);
             
          }
          this.isPagination = true;
         
      }
  
  
      // to fetch the address on select of shipping address button
      @wire(getPosItemUserAddressBookList, {
          selectedPosItemDetails: '$getParticularItem',
          selectedRadioType: '$selectedRadioType',
          recordStartIndex: '$recordStartIndex'
      }) shippingAddressDetails;
  
      // to fetch the address on select of add same address button
      @wire(getUserAddressBookList, {
          posItemsListWithCart: '$getPosItem',
          selectedRadioType: '$selectedRadioType',
          recordStartIndex: '$recordStartIndex'
      })
      resultOfAllAddress;
  
      // to obtain result and display the data to the pop-up modal
      get userAddressBookData() {
         var selectedUserListBeforeApexCall =  this.selectedAddressList;
          //checks if the pop-up is for add same address ,the assigns then results to the variables
          if (this.isAddAllAddresses) {
              if (this.resultOfAllAddress.data) {
                  this.allAddressFromBackEnd = this.resultOfAllAddress.data;
                  this.shippingAddressWithQtyDetails = this.allAddressFromBackEnd.shippingAddressWithQtyDetails;
                  this.allAdressList = this.allAddressFromBackEnd.allAddresses;
                  this.totalAddressListSize = this.allAddressFromBackEnd.totalShippingAddressSize;
              }
          }
  
          // for single shipping method
          else if (this.isAddAllAddresses == false) {
            
              if (this.shippingAddressDetails.data) {
                
                  this.allAddressFromBackEnd = this.shippingAddressDetails.data;
                  this.shippingAddressWithQtyDetails = this.allAddressFromBackEnd.shippingAddressWithQtyDetails;
                  this.allAdressList = this.allAddressFromBackEnd.allAddresses;
                  this.totalAddressListSize = this.allAddressFromBackEnd.totalShippingAddressSize;
              }
          }
          //To hold address to be displayed under available address
          let avaialbleAddress = [];
          //To hold address to be displayed under selected address
          let selectedAddress = [];
          //To hold previoulsy selected address.
          let previousAddressList = [];
          //To hold address to perform manipulcation before sending to front end
          let userAddressList = JSON.parse(JSON.stringify(this.shippingAddressWithQtyDetails));
          //PREVIOUSLY SELECTED ADDRESS
          // To hold the previously selectedaddresses
              previousAddressList = this.selectedAddressForPosItems;       
          //SELECTED ADDRESS LIST
          //checks for the addresses selected in the front end
          if (this.frontEndSelectedAddressList.length > 0 || this.validate == 'frontend') {
              for (let i in this.frontEndSelectedAddressList) {
                  selectedAddress.push(this.frontEndSelectedAddressList[i]);
              }
          } 
          //check if the addresses are selected already and pop-up is opened on init
          else if(selectedUserListBeforeApexCall.length > 0){
              selectedAddress = selectedUserListBeforeApexCall;
          }else{
              selectedAddress =this.selectedAddressForPosItems; 
          }
          let temporaryList = [];
          //AVAILABLE ADDRESS LIST
          //checks if the addreses are populated on select of the page numbers
         
          if (this.isPagination) {
              //set checkbox value to false, then compare with selected and check only the addreses that are selected. Beacuse the data is stored locally and not saved in the database until the save button is clicked
              if (selectedAddress.length > 0) {
                  for (let j in userAddressList) {
                      userAddressList[j].isCheckboxClicked = false;
                  }
                  for (let userAddress in userAddressList) {
                      for (var i = 0; i < selectedAddress.length; i++) {
                          if (selectedAddress[i].selectedAddress.Id == userAddressList[userAddress].selectedAddress.Id &&     selectedAddress[i].isCheckboxClicked) {
                              userAddressList[userAddress].isCheckboxClicked = true;
                              temporaryList.push(userAddressList[userAddress]);
                          }
                      }
                  }
  
              }
          //check for check box value is false and display it in the html
              for (let userAddress in userAddressList) {
                  if (!userAddressList[userAddress].isCheckboxClicked) {
                      avaialbleAddress.push(userAddressList[userAddress])
                  }
              }
  
          } 
          //check for available list has chnaged in the front end
          else {
              for (var j = 0; j < this.frontEndUnSelectedAddressList.length; j++) {
                  avaialbleAddress.push(this.frontEndUnSelectedAddressList[j]);
              }
          }
          // if the searchresult has value then add the address list to the variable 'avaialbleAddress'
          if (this.searchedAddresslistResult.length > 0) {
              avaialbleAddress = [];
              for (var k = 0; k < this.searchedAddresslistResult.length; k++) {
                  this.searchedAddresslistResult[k].isCheckboxClicked = false;
              }
              let searchresult = JSON.parse(JSON.stringify(this.searchedAddresslistResult));
              //as the search is done in front end, get the number of available address and give to the global variable 'totalAddressListSize'
              this.totalAddressListSize = this.searchedAddresslistResult.length;
  
              for (var k = 0; k < searchresult.length; k++) {
                  for (var j = 0; j < selectedAddress.length; j++) {
                      if (selectedAddress[j].selectedAddress.Id == searchresult[k].selectedAddress.Id) {
                          searchresult[k].isCheckboxClicked = true;
                      }
                  }
              }
              for (var i = 0; i < searchresult.length; i++) {
                  if (!searchresult[i].isCheckboxClicked) {
                      avaialbleAddress.push(searchresult[i]);
                  }
              }
          }
          if (this.searchedAddresslistResult.length == 0 && this.validate == 'searchresult') {
              avaialbleAddress = [];
          }
          //store the available address list
          this.avaialbleAddressList = avaialbleAddress;
          if(this.avaialbleAddressList.length>0){
              this.isavailableaddresses = false;
          }
          else{
              this.isavailableaddresses = true;
          }
          //store the selected address list
          this.selectedAddressList = selectedAddress;
          if (this.selectedAddressList.length > 0) {
              this.isdisableSave = false;
          } else {
              this.isdisableSave = true;
          }
         
          //store the previously selected address
          this.previouslyselectedAddressList = previousAddressList;
        
          this.setNavigationItems(this.startIndex, this.lastIndex);
      }
      // to remove the addreses from the selected list
      removeAddressFromSelectedListEvent(event) {
          //hold the selected addresses list for manupilcations
          let selectedAddressList = JSON.parse(JSON.stringify(this.selectedAddressList));
          let selectedAddressBook = [];
          //hold the available addresses list for manupilcations
          let unSelectedAddressBook = JSON.parse(JSON.stringify(this.avaialbleAddressList));
          // hold the address to be removed from the selected list
          let selectedAddressId = event.target.dataset.id;
          //compare the incoming address id with selected address list id's and updated the selected and available address list
          if (selectedAddressList.length > 1) {
              for (var i = 0; i < selectedAddressList.length; i++) {
                  if (selectedAddressList[i].selectedAddress.Id == selectedAddressId) {
                      selectedAddressList[i].isCheckboxClicked = false;
                      unSelectedAddressBook.push(selectedAddressList[i]);
                  } else {
                      selectedAddressBook.push(selectedAddressList[i])
                  }
              }
          }
          // if selected list contains only one address,then set the check box value to false and set the selectedaddress list to null
           else if (selectedAddressList.length == 1) {
              for (var i = 0; i < selectedAddressList.length; i++) {
                  if (selectedAddressList[i].selectedAddress.Id == selectedAddressId) {
                      selectedAddressList[i].isCheckboxClicked = false;
                      unSelectedAddressBook.push(selectedAddressList[i]);
                  }
                  selectedAddressBook = [];
  
              }
          }
          this.validate = 'frontend';
          this.frontEndSelectedAddressList = selectedAddressBook;
          this.frontEndUnSelectedAddressList = unSelectedAddressBook;
          this.isPagination = false;
       
      }
      // to add the address to selected address list
      addAddressToListEvent(event) {
          //hold the available addresses list for manupilcations
          let tempAddressList = JSON.parse(JSON.stringify(this.avaialbleAddressList));
          //hold the selected addresses list for manupilcations
          let selectedAddressList = JSON.parse(JSON.stringify(this.selectedAddressList));
          let unSelectedAddressBook = [];
           // hold the address to be added from the selected list
          let selectedAddressId = event.target.dataset.id;
          //compare the incoming address id with available address list id's and updated the selected and available address list
          for (var i = 0; i < tempAddressList.length; i++) {
              if (tempAddressList[i].selectedAddress.Id === selectedAddressId) {
                  tempAddressList[i].isCheckboxClicked = true;
                  selectedAddressList.push(tempAddressList[i]);
              } else {
                  unSelectedAddressBook.push(tempAddressList[i]);
              }
          }
          this.frontEndSelectedAddressList = selectedAddressList;
          this.frontEndUnSelectedAddressList = unSelectedAddressBook;
          this.isPagination = false;
      }
  
      // onchange of shipping method
      shippingMethodHandleChange(event) {
          //to get the shipping selected method
          let shippingMethodId = event.detail.value;
          // to get the particular address list
          let allShippingDetails = event.target.name;
          //to get the selected address list to be manipulated
          let shippingAddressTobeSaved = JSON.parse(JSON.stringify(this.selectedAddressList))
          //compare the incoming id and update the shipping method selected by the user for the particular address id
          for (var i = 0; i < shippingAddressTobeSaved.length; i++) {
              if (shippingAddressTobeSaved[i].selectedAddress.Id == allShippingDetails.selectedAddress.Id) {
                  shippingAddressTobeSaved[i].selectedShippingMethodId = shippingMethodId;
              }
          }
          this.frontEndSelectedAddressList = shippingAddressTobeSaved;
       
      }
      // To save the addresses to the pos items
      saveSelectedAddress() {
          if (this.isAddAllAddresses) {
              //responsible to save the address for all the items in cart
              saveAddressForAllOrderedItems({
                      cartItemsJSONString: JSON.stringify(this.posItemsListInCart),
                      selectedAddresses: JSON.stringify(this.selectedAddressList),
                      previouslySelectedAddresses: JSON.stringify(this.previouslyselectedAddressList) //changed posItemIdForShippingAddress
                  })
                  .then(result => {
                      let savedAddresses = result;
                     
                      this.isModalOpen = false;
                      const closeButton = new CustomEvent('closemodal', {
                          detail: this.isModalOpen
                      })
                      this.dispatchEvent(closeButton);
  
                  })
                  .catch(error => {
                      this.error = error;
                    //   console.log('ERROR', this.error);
                  });
          }
          //responsible to save the address for all the items in cart
           else {
              let cartItemsJSONString = [];
              cartItemsJSONString.push(this.particularPosItemDetails)
              saveAddressForSelectedItem({
                      cartItemsJSONString: JSON.stringify(cartItemsJSONString),
                      selectedAddresses: JSON.stringify(this.selectedAddressList)
                  })
                  .then(result => {
                       let savedAddresses = result;
                     
                      this.isModalOpen = false;
                      const closeButton = new CustomEvent('closemodal', {
                          detail: this.isModalOpen
                      })
                      this.dispatchEvent(closeButton);
                  })
                  .catch(error => {
                      this.error = error;
                    //   console.log('ERROR', this.error);
                  });
          }
  
      }
  
      // pagination
      //to calulate the pagination values based on the number of items in the cart
      setNavigationItems(startnumber, lastnumber) { 
          this.isItFirstNavigationItem = true;
          this.isItLastNavigationItem = true;
          let totalNavigationItems = Math.ceil(this.totalAddressListSize / 100);
          let navigationItemList = [];
          for (let i = startnumber; i <= lastnumber; i++) {
              let recordStartIndex = (i - 1) * 100;
              let recordLastIndex = recordStartIndex + 99;
              let navigationItem = {
                  "index": i, //too display page numbers
                  "recordStartIndex": recordStartIndex, //to display start index number
                  "recordLastIndex": recordLastIndex,//to display the last index
                  "isRecordExisted": i <= totalNavigationItems, //to check if the address existing
                  "isIndexSelected": i == this.selectedIndex //to check the page number
              };
              navigationItemList.push(navigationItem);
          }
          //to check if the first,last,next and previous button should be enabled/disabled
          if (navigationItemList.length != 0) {
              let lastNavigationIndex = navigationItemList[navigationItemList.length - 1].index;
              if (lastNavigationIndex == totalNavigationItems || lastNavigationIndex > totalNavigationItems) {
                  this.isItLastNavigationItem = true;
              } else {
                  this.isItLastNavigationItem = false;
              }
              if (navigationItemList[0].index == 1) {
                  this.isItFirstNavigationItem = true;
              } else {
                  this.isItFirstNavigationItem = false;
              }
          }
          this.navigationItems = navigationItemList;
         
      }
      // on click of first navigation button
      firstNavigationButton() {
          this.startIndex = 1;
          this.lastIndex = 5;
          this.selectedIndex = 1;
          this.recordStartIndex = 0;
          return refreshApex(this.resultOfAllAddress);
      }
      // on click of previous navigation button
      previousNavigationButton() {
          if (this.navigationItems[0].recordStartIndex > 0) {
              this.startIndex = this.navigationItems[0].index - 5;
              this.lastIndex = this.startIndex + 4;
              this.selectedIndex = this.navigationItems[0].index - 5;
              this.recordStartIndex = this.navigationItems[0].recordStartIndex - 500;
              return refreshApex(this.resultOfAllAddress);
          } else {
              this.isItFirstNavigationItem = true;
          }
      }
      // on click of next navigation button
      nextNavigationButton() {
          if (this.navigationItems[4].isRecordExisted == true) {
              this.startIndex = this.navigationItems[0].index + 5;
              this.lastIndex = this.startIndex + 4;
              this.selectedIndex = this.navigationItems[4].index + 1;
              this.recordStartIndex = this.navigationItems[4].recordLastIndex + 1;
              return refreshApex(this.resultOfAllAddress)
          }
      }
      // on click of last naogation
      lastNavigationButton() {
          this.lastIndex = Math.ceil(Math.ceil(this.totalAddressListSize / 100) / 5) * 5;;
          this.startIndex = this.lastIndex - 4;
          this.selectedIndex = this.lastIndex - 4;
          this.recordStartIndex = (this.startIndex - 1) * 100;
          return refreshApex(this.resultOfAllAddress)
      }
      // on click of a particular page number
      getAddressListByIndex(event) {
          let selectedPageNumber = event.target.value;
          this.selectedIndex = selectedPageNumber.index;
          this.recordStartIndex = selectedPageNumber.recordStartIndex;
          this.isPagination = true;
          return refreshApex(this.resultOfAllAddress)
      }
  
      // to capture the searchkeyword enetred by the user
      searchAddress(event) {
          this.searchedKeyword = event.detail.value;
          if (this.searchedKeyword == '' || this.searchedKeyword == null) {
              this.isSearchkey = true;
              this.frontEndSelectedAddressList = JSON.parse(JSON.stringify(this.selectedAddressList));
              this.validate='frontend';
              this.isPagination = true;
              this.searchedAddresslistResult = [];
          } else {
              this.isSearchkey = false;
          }
      }
      // perform search on click of search button.
      searchOnClickOfButton() {
          this.recordStartIndex = 0;
          this.selectedIndex = 1;
          this.startIndex = 1
          this.lastIndex = 5;
          // to hold the addresses selected during search or pagination, before the addresses are saved in the database
          var selectedAdrressesByTheUser = this.selectedAddressList;
          this.isSearchkey = false;
          // to hold all the addresses in the list
          var allAddressList = JSON.parse(JSON.stringify(this.allAdressList));
  
          //to hold the searched address of the ith address
          var searchedAddress = [];
  
          // to hold the complete list of searchedAddress
          var searchedAddressList = [];
  
          // to the search key
          var searchKey = this.searchedKeyword;
          // to hold the search keyword that is converted to uppper case
          var searchKeyWord = searchKey.toUpperCase();
          for (var k = 0; k < allAddressList.length; k++) {
              allAddressList[k].isCheckboxClicked = false;
          }
          // for all the addresses the loop iss repeated to check if the searchkey is present is the address list
        
          for (var i = 0; i < allAddressList.length; i++) {
              // checks if the searchKeyWord is present in Ship to name, ship to company or city, if so
              if ((allAddressList[i].selectedAddress.City__c.toUpperCase().includes(searchKeyWord)) || (allAddressList[i].selectedAddress.Shipto_Company__c.toUpperCase().includes(searchKeyWord)) || (allAddressList[i].selectedAddress.Shipto_Name__c.toUpperCase().includes(searchKeyWord))) {
  
                  //then check if there are any selected addres, if yes then
                  if (selectedAdrressesByTheUser.length > 0) {
                      // for each selected addresess 
                      for (var j = 0; j < selectedAdrressesByTheUser.length; j++) {
  
                          //the matched address id is checked with the selected addresses id 
                          if (selectedAdrressesByTheUser[j].selectedAddress.Id == allAddressList[i].selectedAddress.Id) {
                              // the addresses of the searchedkeyword is set to true.
                              allAddressList[i].isCheckboxClicked = true;
                          }
                      }
                  }
                  //if the check box value of the allAddressList, store in the variable searchedAddressList
                  if (!allAddressList[i].isCheckboxClicked) {
                      searchedAddress = allAddressList[i];
                      searchedAddressList.push(searchedAddress);
                  }
              }
          }
          // the adddressses to be displayed to the user after the search
          this.searchedAddresslistResult = searchedAddressList
          this.validate = 'searchresult';
             
      }  
}