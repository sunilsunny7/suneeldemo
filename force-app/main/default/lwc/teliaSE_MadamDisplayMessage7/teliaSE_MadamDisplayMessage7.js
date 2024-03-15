import { LightningElement, track, api } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
export default class teliaSE_MadamDisplayMessage7 extends OmniscriptBaseMixin(LightningElement) {
    @track data;
    @track index;
    @api
    get lineItems()
    {
        return this.data;
    }
    set lineItems(value1){
        this.data = value1; //these are the custom labels fetched from custom label class
    }
    @track data1;
    @api
    get contractItems()
    {
        return this.data1; //this is the data inside the table
    }
    set contractItems(value){
        this.data1 = value;
    }
    connectedCallback() {

        // var data = JSON.parse(JSON.stringify(this.data1));
    }

    checked(e) {
        if (e.target.checked) {
            const boxes = this.template.querySelectorAll('lightning-input');
            boxes.forEach(box =>
                box.checked = e.target.name === box.name ? true : false
            );

            if (this.omniJsonData) {
                let updateJson = JSON.parse(JSON.stringify(this.omniJsonData));
                updateJson.Message7.Detail7 = this.data1[e.target.name];
                updateJson.madamMessage7Selected = true;
                this.omniApplyCallResp(updateJson);
            }
        } else if (this.omniJsonData){
            let updateJson = JSON.parse(JSON.stringify(this.omniJsonData));
            updateJson.madamMessage7Selected = false;
            this.omniApplyCallResp(updateJson);
        }
    }
    
}