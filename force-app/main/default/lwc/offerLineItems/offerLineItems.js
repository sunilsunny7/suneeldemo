import { LightningElement, api, track } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class OfferLineItems extends OmniscriptBaseMixin(LightningElement) {

    @track data = [];
    @track productscopy = [];
    @track productssorted = [];
    selectedProducts = [];
    NumberOfProducts = 0;
    @api
    get customItems() {
        return this.data;
    }
    set customItems(value) {
        if (value == undefined) {
            this.data = false;
        } else {
            this.data = value;
        }
    }

    connectedCallback() {
        if (Array.isArray(this.data) && this.data.length > 0) {
            this.data.forEach((item, index) => {
                this.productscopy.push(item.Name);
            });
            this.productscopy = this.productscopy.sort();
            this.productscopy.forEach((item, index) => {
                this.productssorted.push({ Name: item, checked: true });
            });
        } else {
            const evt = new ShowToastEvent({
                    title: "Error",
                    message: "No offerings available to select",
                    variant: 'error'
                });
                this.dispatchEvent(evt);
        }


    }

    handleCheckBox(event) {
        if (event.detail.checked) {
            this.selectedProducts.push(this.productssorted[event.target.dataset.opp]);
            this.NumberOfProducts++;
        } else {
            var index = this.selectedProducts.findIndex(ele => ele.Name === event.target.name);
            this.selectedProducts.splice(index, 1);
            this.NumberOfProducts--;
        }

    }

    nextStep() {
        if (this.omniJsonData) {
            let updateOmniJsonData = JSON.parse(JSON.stringify(this.omniJsonData));
            updateOmniJsonData.Offer.Line = this.selectedProducts;
            this.omniApplyCallResp(updateOmniJsonData); //updating OS data JSON
            this.omniNextStep();
        }
    }
}