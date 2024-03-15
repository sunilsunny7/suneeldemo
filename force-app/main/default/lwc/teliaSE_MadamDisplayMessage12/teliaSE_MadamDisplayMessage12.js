import { LightningElement, track, api } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
export default class teliaSE_MadamDisplayMessage12 extends OmniscriptBaseMixin(LightningElement) {
    @track data;
    @api
   
    
    get contractItems()
    {
        return this.data;
    }
    set contractItems(value){
        this.data = value;
        console.log(JSON.stringify(value));
    }
    @track data;
    connectedCallback() {
        
    }
    
}