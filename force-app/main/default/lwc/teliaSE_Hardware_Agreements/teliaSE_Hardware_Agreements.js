import { LightningElement, track, api } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class TeliaSE_Hardware_Agreements extends OmniscriptBaseMixin(LightningElement) {

    @track customLabels = [];
    @track data;
    @track selectedFrameAgreements = 0;
    @track position = 0;

    @api
    get customLabels() {
        return this.customLabels;
    }
    set customLabels(value) {
        if (value === undefined) {
            this.customLabels = false;
        } else {
            this.customLabels = value;
        }
    }
    @api
    get madamResponse(){
        return this.data;
    }
    set madamResponse(value) {
        if (value === undefined) {
            this.data = false;
        } else {
            this.data = value;
        } 
    }


    connectedCallback() {
        this.selectedFrameAgreements = 0;
        this.position = 0;
        console.log(JSON.stringify(this.data));
        console.log(JSON.stringify(this.customLabels));
    }

    handleChange(event){
        this.position = event.target.dataset.index;
        if(event.detail.checked){
            this.selectedFrameAgreements++;            
        } else {
            this.selectedFrameAgreements--;
        }
    }

    nextStep(){
        if (this.omniJsonData && this.selectedFrameAgreements === 1) {
            let updateJSON = JSON.parse(JSON.stringify(this.omniJsonData));
            updateJSON.Message7.Detail2 = this.data[this.position];
            this.omniApplyCallResp(updateJSON);
            this.omniNextStep();
        } else if(this.selectedFrameAgreements > 1) {
            const evt = new ShowToastEvent({
                title: 'Error Occured',
                message: 'Only one frame agreement selection is allowed',
                variant: 'error'
            });
            this.dispatchEvent(evt);
        } else if(this.selectedFrameAgreements === 0){
            const evt = new ShowToastEvent({
                title: 'Error Occured',
                message: 'Select a frame agreement before proceeding further',
                variant: 'error'
            });
            this.dispatchEvent(evt);
        }
    }
}