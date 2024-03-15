import { LightningElement, api, track } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
export default class fatjanster extends OmniscriptBaseMixin(LightningElement) {

    @api parentvalue;
    @api version;
    @track theRecord = {};
    @track nathyradefault ='Nej';
    @track mandatory;
    handleChange(event) {
        this.theRecord[event.target.name] = event.target.value;
        this.dispatchEvent(new CustomEvent
            ('produktertabevent', { detail: this.theRecord })
        );
    }
    get bool() {
        return [
            { label: 'Ja', value: 'Ja' },
            { label: 'Nej', value: 'Nej' },
        ];
    }

     get newBridge() {
        return [
            { label: '', value: '' },
            { label: 'Ja', value: 'Ja' },
            { label: 'Nej', value: 'Nej' },
        ];
    }

     get Servicetype() {
        return [
            { label: '', value: '' },
            { label: 'Full Mesh', value: 'Full Mesh' },
            { label: 'Hub-spooke', value: 'Hub-spooke' },
        ];
    }
    

 get makerequired() {
     this.mandatory = this.parentvalue.isMDUFSWAN;
        if (this.mandatory === "true") {
            return true;
        } else {
            return false;
        }
    
    }


    connectedCallback() {
        this.theRecord['Etableringsavgift'] = this.parentvalue.OneTimePropertyOwner;
        this.theRecord['Serviceavtal'] = this.parentvalue.Serviceavtal;
        this.theRecord['Centralpunktsadress'] = '';
        this.theRecord['FNTnummer'] = '';
        this.theRecord['natbrygga'] = '';
        this.theRecord['Servicetyp'] = '';
        this.theRecord['Nathyra'] = this.nathyradefault;

        this.dispatchEvent(new CustomEvent
            ('produktertabevent', { detail: this.theRecord })
        );
    }

}