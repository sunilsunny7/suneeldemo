import { track,api,LightningElement } from 'lwc';
    import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
    export default class picklistValue extends OmniscriptBaseMixin(LightningElement) {
      
     @api
    selected = false;
    
    @api
    label;
    
    @api
    value;


    handleSelect(event) {
        //this.selected = true;
        
        if(this.selected){
            this.selected = false;
        }else{
            this.selected = true;
        } 
        
    }
    
    }