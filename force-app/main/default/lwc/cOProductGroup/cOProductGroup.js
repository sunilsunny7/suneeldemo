import { LightningElement, api, track } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import { getNamespaceDotNotation } from 'vlocity_cmt/omniscriptInternalUtils';
import { OmniscriptActionCommonUtil } from 'vlocity_cmt/omniscriptActionUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
export default class COProductGroup extends OmniscriptBaseMixin(LightningElement) {
    @api recordId;
    @track products=[];
    structuredPdt=[];
    OtherPdt=[];
    restPdt=[];
    root=[];
    sub=[];
    tempQuote;
    _actionUtil; 
    finalstring;  
    GroupMap = [];
    @track GroupInfo=[];
    GroupIdArray = [];
    ArrayOfItem=[];
    @track test = {}; 
    _ns = getNamespaceDotNotation();    
    getProductDetailsResponse=[];
    getGroupInputFromIP=[];
    @track quote=[];
    CatchGroupInfo=[];
    @track processedGroupInfo = [];
    @track productgroup = [{
        HeadQuater: '',
        Office: '',        
        Warehouse:''
    }];
    // items;

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
                this.getGroupInputFromIP=response.result.IPResult.DataRaptorExtractAction2.QuoteGroup;
                
                // console.log('Page 1 Response', response);
                this.OtherPdt = this.getProductDetailsResponse["GetProcessedPdt"] ;
                this.GroupInfo = this.getGroupInputFromIP;
                
                for(var i=0;i<this.GroupInfo.length; i++){
                    this.processedGroupInfo.push({
                        "GroupId" : this.GroupInfo[i].GroupId,
                        "GroupName": this.GroupInfo[i].GroupName,
                        "Quantity" : ""
                    });
                }

                
                const items = JSON.parse(JSON.stringify(this.OtherPdt));
                for(var k in items){
                    items[k]['Groups'] = this.processedGroupInfo;
                }
                this.OtherPdt = JSON.parse(JSON.stringify(items));
                
                    

            })
            .catch((error) => {
                console.error(error, "ERROR");
            });        
    }
    

    
    methodUpdate(event){
        if(Number(event.target.value)>0 || event.target.value == ''){
            var pos = this.OtherPdt[Number(event.target.dataset.quote)]['Groups'].map(function(e){ return e.GroupId; }).indexOf(event.target.dataset.groupid);
            this.OtherPdt[Number(event.target.dataset.quote)]['Groups'][pos]['Quantity'] = Number(event.target.value);
            if(Number(event.target.value)==0){
                this.OtherPdt[Number(event.target.dataset.quote)]['Groups'][pos]['Quantity'] = event.target.value;
            }
            
        }
    }
    previousStep(){
        this.omniPrevStep();
    }
    nextStep(event) {
        var SuccessFlag =1;
        if(this.omniJsonData) {
            
        }

        this.OtherPdt.forEach(element => {
            var sumUp=0;
            element['Groups'].forEach(ele => {
                sumUp = sumUp + Number(ele.Quantity);
            });
            if(sumUp !== Number(element.FACallOffQuantity)){
                SuccessFlag = 0;
                console.log('Please enter correct quantity against ==>', element.Product2Name);               
            }
        });

        if(SuccessFlag == 0){
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Antalet stämmer inte med totalen, vänligen korrigera',
                variant: 'error'
            });
            this.dispatchEvent(evt);
        }
        if(SuccessFlag == 1){
            /*this.OtherPdt.forEach(element => {  
            
            element['Groups'].forEach(ele => {
               if(ele.Quantity == 0){

                }
                });
            });*/
            let updateOmniJsonData = JSON.parse(JSON.stringify(this.omniJsonData));
            updateOmniJsonData.ProductGroupQuantity = this.OtherPdt;
            this.omniApplyCallResp(updateOmniJsonData);
            this.omniNextStep();
        }
        
    }
}