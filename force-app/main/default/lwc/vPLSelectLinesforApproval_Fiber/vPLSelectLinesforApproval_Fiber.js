import { LightningElement, track, api } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
export default class vPLSelectLinesforApproval_Fiber extends OmniscriptBaseMixin(LightningElement) {
    @track data;
    @api
    get productItems()
    {
        return this.data;
    }
    set productItems(value){
        this.data = value;
        console.log(JSON.stringify(value));
        
    }
    @track data;
    connectedCallback() {
        
    }
    
}