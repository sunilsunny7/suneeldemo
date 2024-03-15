import { LightningElement } from 'lwc';
    import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
    export default class fibercheckaIn extends OmniscriptBaseMixin(LightningElement) {
      
       nextStep() {
        this.omniNextStep();
    }
    
    }