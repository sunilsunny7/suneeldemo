import { LightningElement, track, api } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
export default class teliaSE_MadamDisplayMessage9 extends OmniscriptBaseMixin(LightningElement) {
    @track data;
    
    @api
    get lineItems()
    {
        return this.data;
    }
    set lineItems(value1){
        this.data = value1;
        console.log(JSON.stringify(value1));
    }
    @track data1;
    @api
    get contractItems()
    {
        return this.data1;
    }
    set contractItems(value){
        this.data1 = value;
        console.log(JSON.stringify(value));
    }
    connectedCallback() {
        
    }
    
}