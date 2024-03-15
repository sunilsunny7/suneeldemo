import { LightningElement, api, track } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
const columns = [
    { label: 'Koppar eller Fiber', fieldName: 'Koppar', value: 'Koppar eller Fiber', type: 'text', editable: false },
    { label: 'Totalt antal portar', fieldName: 'antalportar', value: 'Totalt antal portar', type: 'number', editable: true },
    { label: 'Varav antal hushåll', fieldName: 'antalhushall', value: 'Varav antal hushåll', type: 'number', editable: true },
    { label: 'Varav antal lokaler', fieldName: 'antallokaler', value: 'Varav antal lokaler', type: 'number', editable: true },
    { label: 'Varav antal FS-portar', fieldName: 'antalFSportar', value: 'Varav antal FS-portar', type: 'number', editable: true },
];

const columns1 = [
    { label: 'Förändring', fieldName: 'Fiber', value: 'Förändring', editable: false },
    { label: 'Varav tillägg portar', fieldName: 'tillagportar', value: 'Varav tillägg portar', type: 'number', editable: true },
    { label: 'Varav nedtag portar', fieldName: 'nedtagportar', value: 'Varav nedtag portar', type: 'number', editable: true },
];

export default class Anslutning extends LightningElement {
    @api parentvalue;
    @api version;
    @api recordMetadata;
    @api values;
    @api omradesnat;
    @track theRecord = {};



    data = [];
    data1 = [];
    columns = columns;
    rowOffset = 0;
    columns1 = columns1;

    getValuesFromMultiSelect1(event) {
        this.theRecord['Fastighetsnat'] = event.detail;

        this.dispatchEvent(new CustomEvent
            ('childevent', { detail: this.theRecord })
        );
    }

    getDraftValues(event) {
        this.draftValues = this.template.querySelector(".koppar").draftValues;


        this.draftValues.forEach(ele => {
            const index = ele.id == 'row-0' ? 0 : 1;
            this.data[index]['antalportar'] = ele.antalportar ? ele.antalportar : '';
            this.data[index]['antalhushall'] = ele.antalhushall ? ele.antalhushall : '';
            this.data[index]['antallokaler'] = ele.antallokaler ? ele.antallokaler : '';
            this.data[index]['antalFSportar'] = ele.antalFSportar ? ele.antalFSportar : '';
            this.theRecord['Koppar'] = this.data;
        })


        this.dispatchEvent(new CustomEvent
            ('childevent', { detail: this.theRecord })
        );
    }

    getDraftValues1(event) {
        this.draftValues1 = this.template.querySelector(".fiber").draftValues;

        this.draftValues1.forEach(ele => {
            const index = ele.id == 'row-0' ? 0 : 1;
            this.data1[index].tillagportar = ele.tillagportar ? ele.tillagportar : '';
            this.data1[index].nedtagportar = ele.nedtagportar ? ele.nedtagportar : '';
            

            this.theRecord['Fiber'] = this.data1;
        });

        this.dispatchEvent(new CustomEvent
            ('childevent', { detail: this.theRecord })
        );
    }
    getValuesFromMultiSelect2(event) {
        this.theRecord['omradesnat'] = event.detail;

        this.dispatchEvent(new CustomEvent
            ('childevent', { detail: this.theRecord })
        );
    }

    get bool() {
        return [
            { label: 'Ja', value: 'Ja' },
            { label: 'Nej', value: 'Nej' },
        ];
    }

    connectedCallback() {
        this.theRecord['Fastighetsnat'] = [];
        this.theRecord['omradesnat'] = [];
        this.theRecord['lagenhetsnat'] = this.parentvalue.isMDULES1729;
        this.theRecord['antallghmed'] = this.parentvalue.MDULES1729Quantity;
        this.theRecord['totalantal'] = this.parentvalue.NumberOfPorts;

        this.theRecord['Koppar'] = [
            { Koppar: 'Koppar', antalportar: this.parentvalue.KoperNumberofPort, antalhushall: this.parentvalue.KoperNumberOfHouseholds, antallokaler: this.parentvalue.KoperNumberofPremises, antalFSportar: this.parentvalue.KoperNumberofOtherPorts },
            { Koppar: 'Fiber', antalportar: this.parentvalue.FiberNumberOfPort, antalhushall: this.parentvalue.FiberNumberofHouseholds, antallokaler: this.parentvalue.FiberNumberofPremises, antalFSportar: this.parentvalue.FiberNumberofOtherPorts }
        ];
        this.data = this.theRecord['Koppar'];

        this.theRecord['Fiber'] = [
            { Fiber: 'Koppar', tillagportar: '', nedtagportar: '' },
            { Fiber: 'Fiber', tillagportar: '', nedtagportar: '' }
        ]
        this.data1 = this.theRecord['Fiber'];

        this.values = [
            { label: 'Telia bygger Fastighetsnät Koppar', value: 'Telia bygger Fastighetsnät Koppar', selected: false },
            { label: 'Telia bygger Fastighetsnät Fiber', value: 'Telia bygger Fastighetsnät Fiber', selected: false },
            { label: 'Befintligt Fastighetsnät Koppar', value: 'Befintligt Fastighetsnät Koppar', selected: false },
            { label: 'Befintligt Fastighetsnät Fiber', value: 'Befintligt Fastighetsnät Fiber', selected: false },
            { label: 'Skanova bygger', value: 'Skanova bygger' },
            { label: 'Skanova ansluter befintligt', value: 'Skanova ansluter befintligt' }
        ];
        const obj1 = this.values.map(obj => {
            if (this.parentvalue.isFiber == true && obj.label === 'Telia bygger Fastighetsnät Fiber') {
                obj.selected = true;
            }
            if (this.parentvalue.isKoppar == true && obj.label === 'Telia bygger Fastighetsnät Koppar') {
                obj.selected = true;
            }
            if (this.parentvalue.isFTTB == true && obj.label === 'Befintligt Fastighetsnät Koppar') {
                obj.selected = true;
            }
            if (this.parentvalue.isFTTBFTTH == true && obj.label === 'Befintligt Fastighetsnät Koppar') {
                obj.selected = true;
            }	
            if (this.parentvalue.isFTTBFTTH == true && obj.label === 'Befintligt Fastighetsnät Fiber') {
                obj.selected = true;
            }
            
            if (this.parentvalue.isFTTH == true && obj.label === 'Befintligt Fastighetsnät Fiber') {
                obj.selected = true;
            }
            if (this.parentvalue.BuildPropertyNetwork == 'Skanova bygger' && obj.label === 'Skanova bygger') {
                obj.selected = true;
            }
            if (this.parentvalue.BuildPropertyNetwork == 'Skanova ansluter befintligt' && obj.label === 'Skanova ansluter befintligt') {
                obj.selected = true;
            }
        });

        this.omradesnat = [
            { label: 'Nej', value: 'Nej', selected: false },
            { label: 'Telia bygger Områdesnät', value: 'Telia bygger Områdesnät', selected: false },
            { label: 'Befintligt Områdesnät finns', value: 'Befintligt Områdesnät finns', selected: false }
        ];
        const obj2 = this.omradesnat.map(obj => {
            if (this.parentvalue.BuildAreaNetwork == '2' && obj.label === 'Telia bygger Områdesnät') {
                obj.selected = true;
            }
            else if (this.parentvalue.BuildAreaNetwork == '1' && obj.label === 'Befintligt Områdesnät finns') {
                obj.selected = true;
            } else if (this.parentvalue.BuildAreaNetwork == '0' && obj.label === 'Nej') {
                obj.selected = true;
            }
        });

        this.values.forEach(element => {
            if (element.selected === true) {
                this.theRecord['Fastighetsnat'].push(element.value);
            }
        });

        this.dispatchEvent(new CustomEvent
            ('childevent', { detail: this.theRecord })
        );


        this.omradesnat.forEach(element => {
            if (element.selected === true) {
                this.theRecord['omradesnat'].push(element.value);
            }
        });

        this.dispatchEvent(new CustomEvent
            ('childevent', { detail: this.theRecord })
        );


        this.dispatchEvent(new CustomEvent
            ('subtabchange', { detail: 'allmantTab1Subtab' })
        );

    }


    handleChange(event) {

        this.theRecord[event.target.name] = event.target.value;
        this.dispatchEvent(new CustomEvent
            ('childevent', { detail: this.theRecord })
        );
    }

}