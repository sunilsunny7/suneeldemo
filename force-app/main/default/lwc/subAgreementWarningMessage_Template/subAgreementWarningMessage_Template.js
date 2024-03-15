import { LightningElement,api,track} from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
export default class subAgreementWarningMessage_Template extends OmniscriptBaseMixin(LightningElement) {
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
    connectedCallback() {
        
    }
    nextStep(){
        
            this.omniNextStep();
        } 
    ReDirectStep(){
        location.href = '/lightning/r/Opportunity/{ContextId}/view';
    }
}