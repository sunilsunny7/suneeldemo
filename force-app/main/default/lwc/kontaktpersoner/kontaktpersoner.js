import { LightningElement, api, track } from 'lwc';

export default class Kontaktpersoner extends LightningElement {
    mobile;
    @api parentvalue;
    @track theRecord = {};
    value1 = ['För faktura','För leverans av boxar och kodkuvert','För bekräftelser och marknadsmaterial','För Fastighetsstyrning','För tillgång till switchrum','För Serviceavtal'];
    value2 = [''];


    get options() {
        return [
            { label: 'För faktura', value: 'För faktura' },
            { label: 'För leverans av boxar och kodkuvert', value: 'För leverans av boxar och kodkuvert' },
            { label: 'För bekräftelser och marknadsmaterial', value: 'För bekräftelser och marknadsmaterial' },
            { label: 'För Fastighetsstyrning', value: 'För Fastighetsstyrning' },
            { label: 'För tillgång till switchrum', value: 'För tillgång till switchrum' },
            { label: 'För Serviceavtal', value: 'För Serviceavtal' },
            { label: 'För frånträdande', value: 'För frånträdande' },
            { label: 'För tillträdande', value: 'För tillträdande' },

        ];
    }

    get selectedValues1() {
       return this.value1.join(',');
    }
    
     get selectedValues2() {
       return this.value2.join(',');
    }

    connectedCallback() {
        this.theRecord['BestallareNamn'] = this.parentvalue.ContactName;
        this.theRecord['BestallareTelefonnummer'] = this.parentvalue.ContactNumber;
        this.theRecord['BestallareEpost'] = this.parentvalue.ContactEmail;
        this.theRecord['Kontaktperson1Namn'] = this.parentvalue.ContactName;
        this.theRecord['Kontaktperson1Telefonnummer'] = this.parentvalue.ContactNumber;
        this.theRecord['Kontaktperson1Epost'] = this.parentvalue.ContactEmail;
        this.theRecord['BestallareGatuadress'] = '';
        this.theRecord['BestallarePostnummer'] = '';
        this.theRecord['BestallarePostort'] = '';
        this.theRecord['Kontaktperson1Gatuadress'] = '';
        this.theRecord['Kontaktperson1Postnummer'] = '';
        this.theRecord['Kontaktperson1Postort'] = '';
        this.theRecord['Kontaktperson2Namn'] = '';
        this.theRecord['Kontaktperson2Telefonnummer'] = '';
        this.theRecord['Kontaktperson2Epost'] = '';
        this.theRecord['Kontaktperson2Gatuadress'] = '';
        this.theRecord['Kontaktperson2Postnummer'] = '';
        this.theRecord['Kontaktperson2Postort'] = '';
        this.theRecord['selectedRoles1'] = this.value1;
        this.theRecord['selectedRoles2'] = this.value2;

        this.dispatchEvent(new CustomEvent
            ('childevent', { detail: this.theRecord })
        );
    }
    handleChange(event) {
        
        this.selectvalue = event.target.value;
        this.theRecord[event.target.name] = event.target.value;
        this.dispatchEvent(new CustomEvent
            ('childevent', { detail: this.theRecord })
        );
    }
}