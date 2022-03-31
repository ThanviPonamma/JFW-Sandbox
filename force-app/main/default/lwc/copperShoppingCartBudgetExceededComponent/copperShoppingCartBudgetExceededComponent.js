import { LightningElement,api,track } from 'lwc';

export default class CopperShoppingCartBudgetExceededComponent extends LightningElement {
    //To close modal
    closeModal() {
    var isModalOpen = false;
    const closeButton = new CustomEvent('exceedclosemodal', {
        detail: isModalOpen
    })
    this.dispatchEvent(closeButton);
    }
}