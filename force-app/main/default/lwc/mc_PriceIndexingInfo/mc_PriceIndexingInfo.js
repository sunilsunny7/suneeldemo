import { LightningElement, wire, api, track } from 'lwc';
import getDetails from '@salesforce/apex/MC_PriceIndexing.getPriceIndexingInfo';
export default class Mc_PriceIndexingInfo extends LightningElement {

    @api recordId;
    @track data;
    @track indexedDate;
    @track priceIndex;
    @track indexStatus;
    @track indexingInfo;

    connectedCallback() {
        getDetails({ contractId: this.recordId }).then(result => {
            console.log(result);
            this.data = JSON.parse(JSON.stringify(result));
            var status = '';
            if (this.data.length > 0) {
                this.indexedDate = this.data[0].MC_IndexedDate__c ? this.data[0].MC_IndexedDate__c : '';
                this.priceIndex = this.data[0].MC_IndexationCriteria__r ? this.data[0].MC_IndexationCriteria__r.MC_CurrentBaseValue__c ? this.data[0].MC_IndexationCriteria__r.MC_CurrentBaseValue__c : '' : '';
                if(this.data[0].MC_PriceUpdateType__c){
                    if(this.data[0].MC_PriceUpdateType__c =='Indexed price update'){
                        status = 'Indexerat';
                    }
                    else if(this.data[0].MC_PriceUpdateType__c =='Rollback Price Update'){
                        status = 'Återkallat';
                    }
                }                
                else{
                    status = '';
                }                
                this.indexStatus = status;
                this.indexingInfo = '';
                this.data.forEach((element,index) => {
                    this.indexingInfo += element.vlocity_cmt__Product2Id__r.Name; 

                    if(element.MC_IndexedDate__c !== undefined){
                        this.indexingInfo += ' (' + element.MC_IndexedDate__c + ') ';
                    }
                    

                    if(this.data.length > index && index !== this.data.length-1) {
                        this.indexingInfo += ', ';
                    }
                });
            }

        })
    }
}