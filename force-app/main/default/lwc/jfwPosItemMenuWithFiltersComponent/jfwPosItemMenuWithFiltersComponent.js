//Aim --> To hold  the functionality of  search, sortby , brand and item type filters and to invoke the parent component based on custom event-->
import { LightningElement, wire, track,api } from 'lwc';
// to get the brandlist from the Apex class - jfwPosItemToCart_Apex
import getActiveBrands from '@salesforce/apex/jfwPosItemToCart_Apex.getBrandList';
// to get the getActiveItemTypes from the Apex class - jfwPosItemToCart_Apex
import getActiveItemTypes from '@salesforce/apex/jfwPosItemToCart_Apex.getItemTypeList';
//To check if the use has a shopping cart else create a shopping cart when user clicks place order the Apex class - jfwPosItemToCart_Apex
import createShoppingCart from '@salesforce/apex/jfwPosItemToCart_Apex.createInventoryShoppingCart';


 
export default class JfwPosItemMenuWithFilters extends LightningElement {
 
    //To display the brandlist
    @track brandListToDisplay = [];
    //To display the itemTypeList
    @track itemTypeListToDisplay = [];
    //To hold the value
    @track value = '';
    //To hold sortByvalue
    @track sortByValue = '';
    //To hold search keyword
    @track searchedKeyword;
    //to hold view type
    @track isListView = false;
 
    connectedCallback(){ 
        createShoppingCart()
                    .then(result => {
                
        })
    }
   //wire property to get the list of active brands
    @wire(getActiveBrands)
    getActiveBrandList({ data, error }) {
        if (data) {
 
            this.brandListToDisplay = [{ value: '', label: 'All Brands' }];
            // for each program
            data.forEach(element => {
                const brand = {};
 
                brand.label = element.Brand_Name__c;
 
                brand.value = element.Id;
 
                this.brandListToDisplay.push(brand);
                
            });
        } else if (error) {
            console.log('Error', error.body.message, 'error');
        }
    }

 

    //  wire property to get the list of active item types
    @wire(getActiveItemTypes)
    getActiveItemTypeList({ data, error }) {
 
        if (data) {
 
            this.itemTypeListToDisplay = [{ value: '', label: 'All Item Types' }];
            // for each program
            data.forEach(element => {
                const itemType = {};
 
                itemType.label = element.Item_Type__c;
 
                itemType.value = element.Id;
 
                this.itemTypeListToDisplay.push(itemType);
                
            });
        } else if (error) {
            console.log('Error', error.body.message, 'error');
        }
    }
    //  To send the sort by values to the lightning combobox
    sortByValue = [
        { value: '', label: 'Select' },
        { value: 'Logical_Invenory_Stock__c DESC', label: 'Available Inventory' },
        { value: 'Brand__r.Brand_Name__c', label: 'Brand' },
        { value: 'Item_Name__c', label: 'Item Name' },
        { value: 'Item_No__c', label: 'Item Number' },
        { value: 'Type_of_Item__r.Item_Type__c', label: 'Item Type' },
        { value: 'LAST_N_DAYS', label: 'Last 10 days' },
        { value: 'RECENT_ADDED_CARTITEMS', label: 'Items in cart' }
    ];

    //  Event to hold brand id and send to parent component 

    handleChangeForBrand(event) {
        const brandValue = event.detail.value;
        this.selectedIndex = 1;

        // custom event is created here to send the selected brandid to the parent componenet
        const brandEvent = new CustomEvent('selectbrandevent', { detail: brandValue});         
        this.dispatchEvent(brandEvent);
 
    }
    //  Event to hold Item Type id and send to parent component 
    handleChangeForItemType(event) {
        const itemTypeValue = event.detail.value;
        this.selectedIndex = 1;

        // custom event is created here to send the selected item type id to the parent componenet
        const itemTypeEvent = new CustomEvent('selectitemtypeevent', { detail: itemTypeValue });
        this.dispatchEvent(itemTypeEvent);
    }
 


  //  Event to hold sort by value and send to parent component 
    handleChangeForSortBy(event) {
        const sortByValueId = event.target.value;
        this.selectedIndex = 1;
        // custom event is created here to send the selected sort by id to the parent componenet
        const sortByEvent = new CustomEvent('selectsortbyevent', { detail: sortByValueId });
        this.dispatchEvent(sortByEvent);
    }
 

//  To hold the user searched values
    searchAvailableUsers(event) {
        this.searchedKeyword = event.detail.value;
        this.selectedIndex = 1;
         // custom event "sendsearchdatatoavailable" is called in the parent html. This event holds the searchKeyword
         const searchEvent = new CustomEvent('sendsearchdatatoparent', { detail: this.searchedKeyword });
          this.dispatchEvent(searchEvent);
    }
 
 
 
    //to display list/grid view 
    changeViewType(event){
        let viewtype = event.target.value;
       
        if(viewtype == 'LIST_VIEW'){
           
            this.isListView = true;
          
        }
        else{
            this.isListView = false;

        }
        if(viewtype == 'GRID_VIEW'){
           
            this.isListView = false;
           
        }
        else{
            this.isListView = true;

        }
       
// custom event is created here to send the selected value to check if its list view or grid view and then send to the parent componenet
        const viewEvent = new CustomEvent('viewitemevent', { detail: this.isListView});         
        this.dispatchEvent(viewEvent);
    }
 
 
 
}