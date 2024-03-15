import { LightningElement,api,wire,track } from 'lwc';
import getJSONValue from '@salesforce/apex/LWCController.getJSONValue';
import checkIfSandbox from '@salesforce/apex/LWCController.checkIfSandbox';
import { NavigationMixin } from 'lightning/navigation';
import CPQ_URL_UAT from '@salesforce/label/c.CygateCpqUAT';
import CPQ_URL_PROD from '@salesforce/label/c.CygateCpqPROD';


export default class cPQRedirect extends NavigationMixin(LightningElement) {
    @api recordId;
    @track navItem;
    @track error;
    isSandbox;

    @api invoke() {
        checkIfSandbox()
            .then(result => {
                this.isSandbox = result;
                getJSONValue({ opptyId: this.recordId })
                    .then(result => {
                        this.navItem = result;
                        this.error = undefined;
                        var appendUrl;

                        this.appendUrl = this.isSandbox ? CPQ_URL_UAT +'?data='+this.navItem : CPQ_URL_PROD +'?data='+this.navItem;

                        console.log('@@@'+this.appendUrl);
                        this[NavigationMixin.Navigate]({
                            "type": "standard__webPage",
                            "attributes": {
                                url: this.appendUrl
                            }
                        });
                    })
                    .catch(error => {
                        this.error = error;
                        this.navItem = undefined;
                    });
            });
    }
}