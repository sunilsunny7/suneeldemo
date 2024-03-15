import { LightningElement, track, api } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class teliaSE_Fiber_FrameContracts extends OmniscriptBaseMixin(LightningElement) {

    
    @track selectedcontact = 0;
    @track position = 0;
    @track data;
  //  @track flag = true;

    @api
    get lineItems()
    {
        return this.data;
    }
    set lineItems(value)
   
    {
        if (value == null){
             this.data =false;
         }
         else{
            this.data = value;   
        } 
    }
        connectedCallback() {
            
        this.selectedcontact = 0;
        this.position = 0;
    }

    handleChange(event){
        this.position = event.target.dataset.index;
        if(event.detail.checked){
        
            this.selectedcontact++; 
            }           
        else {
            this.selectedcontact--;
        }
    }

    nextStep(){
        if (this.omniJsonData && this.selectedcontact === 1) {
            let updateJSON = JSON.parse(JSON.stringify(this.omniJsonData));
            updateJSON.Contracts.Item = this.data[this.position];
            this.omniApplyCallResp(updateJSON);
            this.omniNextStep();
        } else if(this.selectedcontact > 1) {
            const evt = new ShowToastEvent({
                title: 'Välj endast en kontrakt för att fortsätta.',
                message: '',
                variant: 'error'
            });
            this.dispatchEvent(evt);
        } else if(this.selectedcontact === 0){
            const evt = new ShowToastEvent({
                title: 'Ingen kontrakt har valts. Välj en kontrakt för att fortsätta.',
                message: '',
                variant: 'error'
            });
            this.dispatchEvent(evt);
        }
    }
    
}