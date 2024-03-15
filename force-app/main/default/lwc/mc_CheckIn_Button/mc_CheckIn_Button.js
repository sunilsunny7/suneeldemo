import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import { LightningElement } from 'lwc';
    export default class mc_CheckIn_Button extends OmniscriptBaseMixin(LightningElement) {
        nextStep() {
        this.omniNextStep();
    }
    }