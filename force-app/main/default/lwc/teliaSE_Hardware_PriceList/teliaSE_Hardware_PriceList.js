import { LightningElement, api, track } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
export default class TeliaSE_Hardware_PriceList extends OmniscriptBaseMixin(LightningElement) {
    @track data = [];
    @api
    get priceList() {
        return this.data;
    }
    set priceList(value) {
        if (value === undefined) {
            this.data = false;
        } else {
            this.data = value;
        }
    }

    connectedCallback(){
        // console.log(JSON.stringify(this.data));
        this.finalMap = this.data;
        this.priceList = this.data.matrixPriceMap;

        // this.priceList.forEach(ele => {
        //     ele.Amount 
        //     ele.OTC1 
        //     ele.RTC1 
        //     ele.OTC2 
        //     ele.RTC2 
        //     ele.OTC3 
        //     ele.RTC3 
        // })
    }

    nextStep() {
        this.omniNextStep();
    }

    previousStep() {
        this.omniPrevStep();
    }
}