import { LightningElement, track, api } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
export default class vPLQuoteforApproval_Fiber extends OmniscriptBaseMixin(LightningElement) {
    @track data;
    @api
    get lineItems()
    {
        return this.data;
    }
    set lineItems(value){
        this.data = value;
        console.log(JSON.stringify(value));
    }
    @track data;
    connectedCallback() {
        
    }
    
}