import { LightningElement, api, track } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import { getNamespaceDotNotation } from 'vlocity_cmt/omniscriptInternalUtils';
import { OmniscriptActionCommonUtil } from 'vlocity_cmt/omniscriptActionUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
export default class CoGetRootProducts extends OmniscriptBaseMixin(LightningElement){
    _actionUtil; 
    _ns = getNamespaceDotNotation();    
    getProductDetailsResponse=[];
    quote=[];
    @track bindOptions =[];
    rootProduct= [];
    value;

    
    
    connectedCallback() {
        this._actionUtil = new OmniscriptActionCommonUtil();
        this.getDataFromIP();
        
    }
    getDataFromIP(){
        const options = {};
        const params = {
            input: this.omniJsonData,
            sClassName: `${this._ns}IntegrationProcedureService`,
            sMethodName: "ProductGroup_DRcall",
            options:  '{}',
        };
        this._actionUtil
            .executeAction(params, null, this, null, null)
            .then((response) => {
                this.getProductDetailsResponse = response.result.IPResult.RemoteAction1; 
                
                console.log('Page 1 Response', response);
                this.quote = this.getProductDetailsResponse["GetProcessedPdt"] ;
                
                for(var i in this.quote){
                    if(this.quote[i]['Level'] == 0){
                        console.log('I am IN');
                        console.log('Selected QuoteLineItem',this.quote[i]);
                        this.quote[i]['BindingPeriod']="";
                        this.rootProduct= this.rootProduct.concat(this.quote[i]);

                    }
                }
                console.log('Root Product List', this.rootProduct);
                this.rootProduct.forEach(element => {
                    if(element.Product2Name == 'Telia Bredband Start'){
                        console.log('Its start');
                        this.bindOptions.push({
                            'ProductName': element.Product2Name,
                            'Options' : [
                                { label: '0', value: '0' },
                                { label: '24', value: '24' },
                            ]
                        });
                        
                    }else if(element.Product2Name == 'Telia Cloud VPN Wifi/Lan'){
                        this.bindOptions.push({
                            'ProductName': element.Product2Name,
                            'Options' : [
                                { label: '12', value: '12' },
                                { label: '36', value: '36' },
                            ]
                        });
        
                    }else if(element.Product2Name == 'Telia Bredband Plus'){
                        this.bindOptions.push({
                            'ProductName': element.Product2Name,
                            'Options' : [
                                { label: '0', value: '0' },
                                { label: '24', value: '24' },
                            ]
                        });
        
                    }else if(element.Product2Name == 'Telia Bredband Pro'){
                        this.bindOptions.push({
                            'ProductName': element.Product2Name,
                            'Options' : [
                                { label: '12', value: '12' },
                                { label: '24', value: '24' },
                                { label: '36', value: '36' },
                            ]
                        });
        
                    }else if(element.Product2Name == 'Telia Datanet'){
                        this.bindOptions.push({
                            'ProductName': element.Product2Name,
                            'Options' : [
                                { label: '12', value: '12' },
                                { label: '24', value: '24' },
                                { label: '36', value: '36' },
                            ]
                        });
        
                    }else if(element.Product2Name == 'Telia Cloud VPN SD-Wan/Firewall'){
                        this.bindOptions.push({
                            'ProductName': element.Product2Name,
                            'Options' : [
                                { label: '12', value: '12' },
                                { label: '36', value: '36' },
                            ]
                        });
        
                    }
                });
                
            })
            .catch((error) => {
                console.error(error, "ERROR");
            });        
    }
    
    handleChange(event) {
        var pos = this.rootProduct.map(function(e){ return e.Product2Name; }).indexOf(event.target.dataset.rpname);
        
        this.rootProduct[pos]['BindingPeriod'] =event.target.value;
        
    }
    
    previousStep(){
        this.omniPrevStep();
    }
    nextStep(event){
        var successflag = 1;
        this.rootProduct.forEach(ele=>{
            if(ele.BindingPeriod === ""){
                successflag =0;
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Select input for :'+ ele.Product2Name,  //Swedish
                    variant: 'error'
                });
                this.dispatchEvent(evt);
            }
        });

        if(successflag == 1) {
            let updateOmniJsonData = JSON.parse(JSON.stringify(this.omniJsonData));
            updateOmniJsonData.BindingMap = this.rootProduct;
            this.omniApplyCallResp(updateOmniJsonData);
            this.omniNextStep();
        }
    }
}