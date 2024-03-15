import { LightningElement,api } from 'lwc';
import approvalInfo from '@salesforce/apex/MC_QuoteApprovalTable.approvalInfo';
export default class McQuoteApprovalRequestPage extends LightningElement {
    @api qli;
    @api quote;
    @api recordId;
    connectedCallback() {
        approvalInfo({
            pId: this.recordId
        }).then(result => {
            console.log('result:', result);            
            this.qli = result.QLI;
            this.quote = result.quote;
            console.log('qli:', JSON.stringify(this.qli));
            console.log('quote:', this.quote.PaymentTerm);
            //Added this below logic to read it as String when negotiating value as 0 explicitly: LTAT-17291
            this.qli = JSON.parse(JSON.stringify(this.qli));
            this.qli.forEach(element => {
                if(element.RequestedPercentage != undefined) {
                    element['RequestedPercentage'] = String(element['RequestedPercentage']);
                }
                if(element.RequestedPercentage != undefined) {
                    element['RequestedPrice'] = String(element['RequestedPrice']);
                }
                if(element.miniCom != undefined) {
                    element['miniCom'] = String(element['miniCom']);
                }
                element.Child.forEach(child => {
                    if(child.RequestedPercentage != undefined) {
                        child['RequestedPercentage'] = String(child['RequestedPercentage']);
                    }
                    if(child.RequestedPrice != undefined) {
                        child['RequestedPrice'] = String(child['RequestedPrice']);
                    }
                    if(child.ClusterItems != undefined) { 
                        child.ClusterItems.forEach(clusterItem => {
                            if(clusterItem.RequestedPercentage != undefined) {
                                clusterItem['RequestedPercentage'] = String(clusterItem['RequestedPercentage']);
                            }
                            if (clusterItem.RequestedPrice != undefined) {
                                clusterItem['RequestedPrice'] = String(clusterItem['RequestedPrice']);
                            }
                        });
                    }
                });
            });
            this.qli = JSON.parse(JSON.stringify(this.qli));
        }).catch(error => {
            console.error('**** error **** \n ', error)
        });
    }  
}