import { LightningElement, api, track } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
export default class ApprovalTableOS extends OmniscriptBaseMixin(LightningElement) {
    _qli;_quote;
    @api
    get qli() {
        return this._qli;
    }
    set qli(value) {
        if (value) {
            //console.log(value);
            this._qli = value;
            console.log(this._qli);
        }
    }
    @api
    get quote() {
        return this._quote;
    }
    set quote(value) {
        if (value) {
            this._quote = value;
        }
    }
    connectedCallback() {
        //Added this below logic to read it as String when negotiating value as 0 explicitly: LTAT-17291
        if(this.qli != null){
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
        }
        
    }
}