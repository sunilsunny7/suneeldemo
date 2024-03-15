import { LightningElement, api, track } from 'lwc';

export default class Kundaninformation extends LightningElement {
    @api parentvalue;
    @api version;
    value = 'Papper';
    @track theRecord = {};
   // @track listOfKundInformation = [];

    get Fakturametod() {
        return [
            { label: 'Papper', value: 'Papper' },
            { label: 'E-postfaktura', value: 'E-postfaktura' },
        ];
    }
    connectedCallback() {
        /*this.listOfKundInformation[0] = {
            Avtalspart: this.parentvalue.Business1,
            Organisationsnummer: this.parentvalue.OrgNumber,
            Namnutmotkund: this.parentvalue.Business1,
            kundFavtalspart: '',
            kundForgnummer: '',
            activationtype: '',
            kundForgnummer: '',
        }*/
        
        //this.theRecord['listofKund'] = this.listOfKundInformation;
        this.theRecord['OwnerName'] = this.parentvalue.OwnerName;
        this.theRecord['OwnerPhoneNumber'] = this.parentvalue.OwnerPhoneNumber;
        this.theRecord['OwnerEmail'] = this.parentvalue.OwnerEmail;
        this.theRecord['Avtalspart'] = this.parentvalue.Business1;
        this.theRecord['Organisationsnummer'] = this.parentvalue.OrgNumber;
        this.theRecord['KundSalavtalet'] = this.parentvalue.loggedinUserName;
        this.theRecord['KundSalTelefonnummer'] = this.parentvalue.loggedinPhoneNumber;
        this.theRecord['KundSalEpost'] = this.parentvalue.loggedinEmail;
        this.theRecord['Namnutmotkund'] = this.parentvalue.Business1;
        this.theRecord['kundFavtalspart'] = '';
        this.theRecord['kundForgnummer'] = '';
        this.theRecord['kundFKOnummer'] = '';
        this.theRecord['KOnummer'] = this.parentvalue.KOnumber;
        this.theRecord['KundAttentioninformation'] = '';
        this.theRecord['KundFakturaadressCO'] = '';
        this.theRecord['KundFakturaadressReferenceinfo'] = '';
        this.theRecord['KundGatuadress'] = '';
        this.theRecord['KundPostnummer'] = '';
        this.theRecord['KundPostort'] = '';
        this.theRecord['Fakturametod'] = this.value;
        this.theRecord['FakturaadressEpostfaktura'] = '';

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