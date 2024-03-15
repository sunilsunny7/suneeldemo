import { LightningElement, api, track } from 'lwc';
export default class AffarInformation extends LightningElement {
    @track stage = 'Nej';
    @track debitdefault = '0 dagar';
    @track  skickasdefault = 'Ja - Skickas som PDF till säljare och till Fastighetsägaren';


    @api parentvalue;
    @api version;
    @track theRecord = {};
    getdate() {
        let currentDate = new Date();

        let formatter = new Intl.DateTimeFormat('en', {
            year: "numeric",
            month: "numeric",
            day: "numeric",

        })

        let formattedDate = formatter.format(currentDate);
    }

    get YesNo() {
        return [
            { label: 'Nej', value: 'Nej' },
            { label: 'Ja', value: 'Ja' },
        ];
    }

    get YesNo1() {
        return [
            { label: 'Nej', value: 'Nej' },
            { label: 'Ja', value: 'Ja' },
        ];
    }


    get YesNoInstall() {
        return [
            { label: 'Nej', value: 'Nej' },
            { label: 'Ja', value: 'Ja' },
        ];
    }
    get YesNonewproduction() {
        return [
            { label: 'Nej', value: 'Nej' },
            { label: 'Ja', value: 'Ja' },
        ];
    }
    get debit() {
        return [
            { label: '0 dagar', value: '0 dagar' },
            { label: '7 dagar', value: '7 dagar' },
            { label: '14 dagar', value: '14 dagar' },
            { label: '1 månad', value: '1 månad' },
            { label: '2 månader', value: '2 månader' },
            { label: '3 månader', value: '3 månader' },

        ];
    }
    get Strom() {
        return [
            { label: 'Ström 1', value: 'Ström 1' },
            { label: 'Ström 2', value: 'Ström 2' },
            { label: 'Ström 3', value: 'Ström 3' },
        ];
    }

    get Byte() {
        return [
            { label: 'Nej', value: 'Nej' },
            { label: 'Ja - Ström 1 till 2', value: 'Ja - Ström 1 till 2' },
            { label: 'Ja - Ström 1 till 3', value: 'Ja - Ström 1 till 3' },
            { label: 'Ja - Ström 2 till 1', value: 'Ja - Ström 2 till 1' },
            { label: 'Ja - Ström 2 till 3', value: 'Ja - Ström 2 till 3' },
            { label: 'Ja - Ström 3 till 1', value: 'Ja - Ström 3 till 1' },
            { label: 'Ja - Ström 3 till 2', value: 'Ja - Ström 3 till 2' },

        ];
    }
    get option() {
        return [
            { label: 'Nej', value: 'Nej' },
            { label: 'Ja - Skickas som PDF till säljare och till Fastighetsägaren', value: 'Ja - Skickas som PDF till säljare och till Fastighetsägaren' },
            { label: 'Ja - Skickas som PDF endast till säljare', value: 'Ja - Skickas som PDF endast till säljare' },
            { label: 'Ja - Skickas som PDF till säljare och till slutkund/bifogad namnlista', value: 'Ja - Skickas som PDF till säljare och till slutkund/bifogad namnlista' },
            { label: 'Ja - Skickas som PDF till säljare och onamnad bunt till kontaktperson', value: 'Ja - Skickas som PDF till säljare och onamnad bunt till kontaktperson' },
        ];
    }
    handleChange(event) {
       
        this.value = event.target.value;
        if(this.value === null){
           this.value = '';
           console.log('value222 >> '+ this.value); 
        }
        this.theRecord[event.target.name] = this.value;
        console.log('therecord >> '+ this.theRecord); 
        this.dispatchEvent(new CustomEvent
            ('childevent', { detail: this.theRecord })
        );

    }
    connectedCallback() {
        this.theRecord['Avtalstid'] = this.parentvalue.ContractYears;
        this.theRecord['Heranummer'] = this.parentvalue.HERANumber;
        this.theRecord['Leveranstid'] = this.parentvalue.Leveransperiod;
        this.theRecord['Nyproduktion'] = this.parentvalue.NewProduction;
        this.theRecord['Extern fiber'] = this.parentvalue.ExternFiber;
        this.theRecord['Extern fiber (Namn)'] = this.parentvalue.ExternalNetworkOwner;
        this.theRecord['stage'] = this.stage;
        this.theRecord['debit'] = this.debitdefault;
        this.theRecord['Onskatleveransdatum'] = this.parentvalue.wisheddeliverydate;
        this.theRecord['OnskatleveransdatumKabelTv'] = '';
        this.theRecord['Inflyttningsdatum'] = '';
        this.theRecord['Nedtagsdatum'] = this.parentvalue.ContractTerminationDate;;
        this.theRecord['Installationship'] = this.parentvalue.isInstallationHelp;
        this.theRecord['Byte'] = '';
        this.theRecord['skickas'] = this.skickasdefault;
        this.theRecord['Strom'] = this.parentvalue.Strom;
        //console.log('');
        this.dispatchEvent(new CustomEvent
            ('childevent', { detail: this.theRecord })
        );
    }

    get checkFieldValue(){
        if (this.theRecord['Leveranstid'] !== ''){
            return 'already_filled';
        } else {
            return 'required_field';
        }
    }

    get checkFieldValue1() {
        if (this.theRecord['Avtalstid'] !== '') {
            return 'already_filled';
        } else {
            return 'required_field';
        }
    }

    get checkFieldValue2() {
        if (this.theRecord['skickas'] !== '') {
            return 'already_filled';
        } else {
            return 'required_field';
        }
    }

}