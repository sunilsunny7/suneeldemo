import { LightningElement,api,track } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
export default class ovrigt extends OmniscriptBaseMixin(LightningElement) {
    @api version;
    @track theRecord = {};
    
    get bool() {
        return [
            { label: 'Ja', value: 'Ja' },
            { label: 'Nej', value: 'Nej' },
        ];
    }

    get Productcode() {
        return [
            { label: 'Individuellt', value: 'Individuellt' },
            { label: 'Kollektiv TV', value: 'Kollektiv TV' },
            { label: 'Kollektiv 3Play', value: 'Kollektiv 3Play' },
            { label: 'Kollektiv BB', value: 'Kollektiv BB' },
            { label: 'Kollektiv 2Play', value: 'Kollektiv 2Play' },
        ];
    }

    handleChange(event) {
        this.selectvalue = event.target.value;
        this.theRecord[event.target.name] = event.target.value;
        this.dispatchEvent(new CustomEvent
            ('childevent', { detail: this.theRecord })
        );
    }

    connectedCallback() {
        this.theRecord['Kundagtnat'] = '';
        this.theRecord['Produktkod'] = '';
        this.theRecord['Stationsnamn'] = '';
        this.theRecord['Ovriginformation'] = '';

    }

}