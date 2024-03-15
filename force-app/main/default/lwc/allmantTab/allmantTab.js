import { LightningElement, api, track } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
export default class AllmantTab extends OmniscriptBaseMixin(LightningElement) {
    selectvalue;
    @track ContractName = '';
    @api parentvalue;
    @api version;
    @track theRecord = {};

    dataForAllmant = [];

    get options2() {
        return [
            {label: '', value: '' },
            { label: 'Migrering 4.1 till 3.1', value: 'Migrering 4.1 till 3.1' },
            { label: 'Migrering 3.1 till 4.1', value: 'Migrering 3.1 till 4.1' },
            { label: 'Migrering till Zitius', value: 'Migrering till Zitius' },
            { label: 'Migrering till Telia', value: 'Migrering till Telia' },
            { label: 'Nedtag av KO', value: 'Nedtag av KO' },
            { label: 'Nedtag med Extern migrering', value: 'Nedtag med Extern migrering' },
            { label: 'FS WAN', value: 'FS WAN' },
            { label: 'Serviceavtal', value: 'Serviceavtal' },
            { label: 'Villagrupp', value: 'Villagrupp' },
            { label: 'FLIT (Capex)', value: 'FLIT (Capex)' },
            { label: 'FLIT Nätanslutning (0 Capex)', value: 'FLIT Nätanslutning (0 Capex)' },
            { label: 'KFÄ', value: 'KFÄ' },
        ];
    }
    get options() {
        return [
            { label: 'Telia Fastighetsanslutning (XLAN)', value: 'Telia Fastighetsanslutning(XLAN)' },
            { label: 'Telia Öppen Fiber', value: 'Telia Öppen Fiber' },
            { label: 'Halebop', value: 'Halebop' },
            { label: 'Zitius Stadsnät', value: 'Zitius Stadsnät' },
            { label: 'Zitius Byalag', value: 'Zitius Byalag' },
            { label: 'OCN', value: 'OCN' },
            { label: 'SSAB', value: 'SSAB' },
        ];
    }
    values = [
        { label: 'Nybeställning', value: 'Nybeställning' },
        { label: 'Omförhandling', value: 'Omförhandling' },
        { label: 'Överlåtelse', value: 'Överlåtelse' },
        { label: 'Avyttring', value: 'Avyttring' },
        { label: 'Migrering', value: 'Migrering' },
        { label: 'Nedtag av port', value: 'Nedtag av port' },
        { label: 'Tillägg (bef. switch)', value: 'Tillägg (bef. switch)' },
        { label: 'Utökning (ny switch)', value: 'Utökning (ny switch)' },
        { label: 'Uppsägning', value: 'Uppsägning' }
    ];
 
 valueslight =[
     { label: 'Överlåtelse', value: 'Överlåtelse' },
     { label: 'Flytt mellan avtal', value: 'Flytt mellan avtal'},
     { label: 'Avyttring', value: 'Avyttring' }
 ];


    handleChange(event) {
        this.theRecord[event.target.name] = event.target.value;

        this.dispatchEvent(new CustomEvent
            ('childevent', { detail: this.theRecord })
        );
        this.dispatchEvent(new CustomEvent
            ('tabchangeevent', { detail: '1' })
        );

        
    }
    getValuesFromMultiSelect(event){
        this.theRecord['typeofAffar']= event.detail;

        this.dispatchEvent(new CustomEvent
            ('childevent', { detail: this.theRecord })
        );
    }

    connectedCallback() {
        this.theRecord['Avtalsnummer'] = this.parentvalue.ContractNumber;
        this.theRecord['Tidigare avtalsnummer'] = this.parentvalue.ContractLink;
        this.theRecord['Brand'] = this.parentvalue.Brand;
        this.theRecord['offertype'] = '';
        this.theRecord['typeofAffar'] = '';
        this.theRecord['typeAffar'] = '';
        this.theRecord['WBS'] = '';
        this.dispatchEvent(new CustomEvent
            ('childevent', { detail: this.theRecord })
        );
    }

}