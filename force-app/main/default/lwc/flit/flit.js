import { api, LightningElement, track } from 'lwc';
//import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
//export default class Flit extends OmniscriptBaseMixin(LightningElement)
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class Flit extends LightningElement {
    processingProducts = true;
    @api parentvalue;
    @track adressanslutning;
    @track antalPortar;
    @track prisPerAdressanslutning;
    @track size1;
    @track flit = {
        "adressanslutning": " ",
        "antalPortar": " ",
        "prisPerAdressanslutning": " "
    };
    @track listOfProducts = [];
    @track theRecord = {};
    connectedCallback() {


        this.listOfProducts[0] = {
            addButton: false,
            Adressanslutning: '',
            Antal: 0,
            price: 0

        }
        if (this.listOfProducts.length > 1) {
            this.size1 = true;
        } else {
            this.size1 = false;
        }
        this.positionOfAddButton();
    }

    addRow() {
        this.listOfProducts.push({
            addButton: false,
            Adressanslutning: '',
            Antal: 0,
            price: 0
            
        });
        if (this.listOfProducts.length > 1) {
            this.size1 = true;
        } else {
            this.size1 = false;
        }

        this.positionOfAddButton();
    }
    deleteRow(event) {
        let index = parseInt(event.target.dataset.opp);
        if(this.listOfProducts.length > 1) {
            this.listOfProducts.splice(index, 1);
        } else {
            const evt = new ShowToastEvent({
                    message: 'There has to be atleast one row',
                    variant: 'error'
                });
                this.dispatchEvent(evt);
        }
        
        if (this.listOfProducts[index - 1] != undefined) {
            this.listOfProducts[index - 1].addButton = true;
        }
        if (this.listOfProducts.length > 1) {
            this.size1 = true;
        } else {
            this.size1 = false;
        }
    }
    positionOfAddButton() {
        const lastIndexOfAddButton = this.listOfProducts.length - 1;
        for (var i = 0; i < this.listOfProducts.length; i++) {
            this.listOfProducts[i].addButton = false;
            if (i === lastIndexOfAddButton) {
                this.listOfProducts[i].addButton = true;
            }
        }
    }


    adressanslutningChange(event) {
        this.adressanslutning = event.target.value;
        this.flit['adressanslutning'] = this.adressanslutning;

    }
    antalPortarChange(event) {
        this.antalPortar = event.target.value;
        this.flit['antalPortar'] = this.antalPortar;
    }
    prisPerAdressanslutningChange(event) {
        this.prisPerAdressanslutning = event.target.value;
        this.flit['prisPerAdressanslutning'] = this.prisPerAdressanslutning;

    }
    
     handleChange(event) {
        
        let fieldName = event.target.name;
        this.listOfProducts[event.target.dataset.opp][fieldName] = event.target.value;
        this.dispatchEvent(new CustomEvent
            ('childevent5', { detail: this.listOfProducts })
        );

        
    }

    nextStep() {
        // creating event 
        const finalFlit = new CustomEvent("getFinalFlit", { detail: this.flit });

        // Dispatches the event 
        this.dispatchEvent(finalFlit);

    }
}