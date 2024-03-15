import { LightningElement, api, track } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class ProdukterTab extends OmniscriptBaseMixin(LightningElement) {
processingProducts = true;
@api parentvalue;
@api activationlabel;
@api activationtypemapinprodukter = [];
pricelistvalue;
@track listOfProducts = [];
@track theRecord = {};

handleChange(event) {
    let fieldName = event.target.name;
    this.listOfProducts[event.target.dataset.opp][fieldName] = event.target.value;
    this.dispatchEvent(new CustomEvent
        ('produktertabevent', { detail: this.listOfProducts })
    );
}
connectedCallback() {
    this.listOfProducts[0] = {
        addButton: false,
        productCode: '',
        quantity: 0,
        price: 0,
        otc: '',
        activationtype: '',
        Omforhandling: '',
        disablefield: false,
    }
    let index = 0;
    var activationtypelabel = 'MDU_Coll_InstallationHelp_1707';
    for (let key1 in this.parentvalue.isCharge) {
      
        if (index < this.parentvalue.isCharge.length) {
            var requestedPrice = this.parentvalue.isCharge[key1].RequestedPrice != undefined ? this.parentvalue.isCharge[key1].RequestedPrice : 0;
            var otc1 = this.parentvalue.isCharge[key1].Charge;

            //22.05.2023 : adding below lines of code as part of LTAT-8316 and LTAT-8392 Activation Type value logic
            for(let mapkey1 in this.activationtypemapinprodukter){
            if (this.parentvalue.isCharge[key1].ProductCode == activationtypelabel) {
                var actType = this.parentvalue.isCharge[key1].Installationhelp;
                break;
              }
            else if(this.parentvalue.isCharge[key1].ProductCode == mapkey1)
                    {
                    var actType = this.activationtypemapinprodukter[mapkey1];
                    break;
                    }
            else{
                var actType ='';
            }
        }         
        
        // logic for price flow in orderunderlag
            var pricex;
            if(this.parentvalue.ContractRecordType == 'CAwithFA'){
                if ( this.parentvalue.isCharge[key1].FAPrice != null && this.parentvalue.isCharge[key1].OTC>0) {
                    pricex = this.parentvalue.isCharge[key1].OTC;
                }
                if ( this.parentvalue.isCharge[key1].FAPrice != null  && (this.parentvalue.isCharge[key1].OTC == 0 ||this.parentvalue.isCharge[key1].OTC == undefined )) {
                    pricex = this.parentvalue.isCharge[key1].FAPrice;
                }
                if ((this.parentvalue.isCharge[key1].FAPrice == null|| this.parentvalue.isCharge[key1].FAPrice == undefined) && (this.parentvalue.isCharge[key1].OTC < this.parentvalue.isCharge[key1].RCT)) {
                        pricex = this.parentvalue.isCharge[key1].RCT;
                }
                if ((this.parentvalue.isCharge[key1].FAPrice == null|| this.parentvalue.isCharge[key1].FAPrice == undefined) && (this.parentvalue.isCharge[key1].OTC > this.parentvalue.isCharge[key1].RCT)) {
                    pricex = this.parentvalue.isCharge[key1].OTC;
                }
                if ((this.parentvalue.isCharge[key1].FAPrice == null|| this.parentvalue.isCharge[key1].FAPrice == undefined) && (this.parentvalue.isCharge[key1].OTC == this.parentvalue.isCharge[key1].RCT)) {
                    pricex = this.parentvalue.isCharge[key1].OTC;
                }
                if (otc1 =='Yearly') {
                    pricex = this.parentvalue.isCharge[key1].OTC;
                }
            }
                
                if ((this.parentvalue.ContractRecordType == 'CAwoFA' || this.parentvalue.ContractRecordType == 'Individual Agreement') && this.parentvalue.isCharge[key1].RequestedPrice != null) {
                    pricex = this.parentvalue.isCharge[key1].RequestedPrice;
                }
                if ((this.parentvalue.ContractRecordType == 'CAwoFA' || this.parentvalue.ContractRecordType == 'Individual Agreement') && (this.parentvalue.isCharge[key1].RequestedPrice == null || this.parentvalue.isCharge[key1].RequestedPrice == undefined)) {
                    if(this.parentvalue.isCharge[key1].RCT == 0|| this.parentvalue.isCharge[key1].RCT == undefined){
                        pricex = this.parentvalue.isCharge[key1].OTC;
                    }else if(this.parentvalue.isCharge[key1].RCT > 0){
                        pricex = this.parentvalue.isCharge[key1].RCT;
                    }else{
                       pricex =0; 
                    }    
                }
                console.log('price '+pricex); 

            this.listOfProducts[index] = {
                addButton: true,
                productCode: this.parentvalue.isCharge[key1].ProductCode,
                quantity: this.parentvalue.isCharge[key1].Quantity,
                price: pricex,
                otc: otc1 === "Monthly" ? 'Månadsavgift/styck (exkl. moms)' : otc1 === undefined ? '' : 'Engångsavgift/styck (exkl. moms)',
                activationtype: actType,
                Omforhandling: '',
                disablefield: false,
            }

            index++;
        
    }
    }
    this.positionOfAddButton();

    this.dispatchEvent(new CustomEvent
        ('produktertabevent', { detail: this.listOfProducts })
    );
}

addRow() {
    this.listOfProducts.push({
        addButton: false,
        productCode: '',
        quantity: 0,
        price: 0,
        otc: 0,
        activationtype: '',
        Omforhandling: '',
        disablefield: false
    });

    this.positionOfAddButton();
}
get Aktiveringstyp() {
    return [
        { label: '', value: '' },
        { label: 'Bulk Activation', value: 'Bulk Activation' },
        { label: 'Individual', value: 'Individual' },
    ];
}

get retention() {
    return [
        { label: '', value: '' },
        { label: 'Nedgradering', value: 'Nedgradering' },
        { label: 'Prisjutering', value: 'Prisjutering' },
        { label: 'Uppgradering', value: 'Uppgradering' },
    ];
}

get typeofcharge() {
    return [
        { label: '', value: '' },
        { label: 'Månadsavgift/styck (exkl. moms)', value: 'Månadsavgift/styck (exkl. moms)' },
        { label: 'Engångsavgift/styck (exkl. moms)', value: 'Engångsavgift/styck (exkl. moms)' },
    ];
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

deleteRow(event) {

    let index = parseInt(event.target.dataset.opp);
    console.log(index);
    if (this.listOfProducts.length > 1) {
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

    this.positionOfAddButton();
}

}