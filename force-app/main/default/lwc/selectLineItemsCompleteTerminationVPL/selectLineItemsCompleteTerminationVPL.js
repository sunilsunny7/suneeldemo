import { LightningElement, api, track } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
export default class SelectLineItemsCompleteTerminationVPL extends OmniscriptBaseMixin(LightningElement) {
    @track data;
    @api
    get customItems() {
        return this.data;
    }
    set customItems(value) {
        // console.log(value);
        if (value === undefined) {
            this.data = false;
        } else {
            this.data = value;
        }
    }

    connectedCallback() {
        console.log(JSON.stringify(this.data));
    }
}