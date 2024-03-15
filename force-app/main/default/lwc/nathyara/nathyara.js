import { LightningElement, track } from 'lwc';

export default class Nathyara extends LightningElement {

    @track theRecord = {};
    @track value = 'Månad';

    get bool() {
        return [
            { label: 'Ja', value: 'Ja' },
            { label: 'Nej', value: 'Nej' },
        ];
    }

    get manad() {
        return [
            { label: 'Månad', value: 'Månad' },
            { label: 'Kvartal', value: 'Kvartal' },
        ];
    }
    
    connectedCallback(){
        this.theRecord['Nathyra_ip1'] = '';
        this.theRecord['Nathyra_ip2'] = this.value;
        this.theRecord['Nathyra_ip3'] = '';
        this.theRecord['Nathyra_ip4'] = '';
        this.theRecord['Nathyra_ip5'] = '';
        this.theRecord['aktiv_LHS1'] = 'Bredband 1 MDU';
        this.theRecord['aktiv_LHS2'] = 'Bredband >10 MDU';
        this.theRecord['aktiv_RHS1'] = '';
        this.theRecord['aktiv_RHS2'] = '';
        this.theRecord['aktiv_LHS3'] = 'Bredband 1 SDU';
        this.theRecord['aktiv_RHS3'] = '';
        this.theRecord['aktiv_LHS4'] = 'Bredband >10 SDU';
        this.theRecord['aktiv_RHS4'] = '';
        this.theRecord['aktiv_LHS5'] = 'Bredband 1 FTG';
        this.theRecord['aktiv_RHS5'] = '';
        this.theRecord['aktiv_LHS6'] = 'Bredband >10 FTG';
        this.theRecord['aktiv_RHS6'] = '';
        this.theRecord['aktiv_LHS7'] = 'Samma';
        this.theRecord['aktiv_RHS7'] = '';
        this.theRecord['passiv_LHS1'] = 'MDU';
        this.theRecord['passiv_RHS1'] = '';
        this.theRecord['passiv_LHS2'] = 'SDU';
        this.theRecord['passiv_RHS2'] = '';
        this.theRecord['passiv_LHS3'] = 'FTG';
        this.theRecord['passiv_RHS3'] = '';
        this.theRecord['passiv_LHS4'] = 'Samma';
        this.theRecord['passiv_RHS4'] = '';
    }

    changeHandler(event) {
        this.theRecord[event.target.name] = event.target.value;
        this.dispatchEvent(new CustomEvent
            ('childeventnathyara', { detail: this.theRecord })
        );

    }
}