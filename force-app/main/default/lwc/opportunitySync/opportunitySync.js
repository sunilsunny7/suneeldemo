import { LightningElement,api } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
export default class OpportunitySync extends OmniscriptBaseMixin(LightningElement) {
    @api _familyOfferList;
    contextId;
    @api offerList;
    _omniJsonData;
    @api
    get familyofferlist() {
        return this._familyOfferList;
    }
    set familyofferlist(value) {
        if (value) {
            this._familyOfferList = value;
            this.offerList = value;
            console.log('this._familyOfferList',JSON.stringify(this._familyOfferList));
        }
    }
    @api
    get contextid() {
        return this.contextId;
    }
    set contextid(value) {
        if (value) {
            this.contextId = value;
            console.log('this.contextId',JSON.stringify(this.contextId));
        }
    }
   
    @api oppSync;
    methodUpdate(event){
        const items = JSON.parse(JSON.stringify(this._familyOfferList));
        console.log('items1',items);
        console.log('dataset',event.target.dataset.opp);
        console.log('Name',event.target.dataset.name);
        const fieldname = event.target.dataset.name;
        this.oppSync = items.filter((item, index, array) => {
            if(index === Number(event.target.dataset.opp)) {
                if(event.target.dataset.name === 'NewSalesEngangsavgift'){
                    if(event.target.value === ''){
                        item.NewSalesEngangsavgift = null;
                    }
                    else{
                        item.NewSalesEngangsavgift = Number(event.target.value);
                    }
                }
                if(event.target.dataset.name === 'NewSalesAngesnittmanadsavgift'){
                    if(event.target.value === ''){
                        item.NewSalesAngesnittmanadsavgift = null;
                    }
                    else{
                        item.NewSalesAngesnittmanadsavgift = Number(event.target.value);
                    }
                    
                }
                if(event.target.dataset.name === 'NewSalesAntal'){
                    if(event.target.value === ''){
                        item.NewSalesAntal = null;
                    }
                    else{
                        item.NewSalesAntal = Number(event.target.value);
                    }
                    
                }
                if(event.target.dataset.name === 'NewSalesType'){
                    item.NewSalesType = event.target.value;
                }
                if(event.target.dataset.name === 'ContinuousSalesAngesnittmanadsavgift'){
                    if(event.target.value === ''){
                        item.ContinuousSalesAngesnittmanadsavgift = null;
                    }
                    else{
                        item.ContinuousSalesAngesnittmanadsavgift = Number(event.target.value);
                    }
                    
                }
                if(event.target.dataset.name === 'ContinuousSalesAntal'){
                    if(event.target.value === ''){
                        item.ContinuousSalesAntal = null;
                    }
                    else{
                        item.ContinuousSalesAntal = Number(event.target.value);
                    }
                }
                if(event.target.dataset.name === 'ContinuousSalesType'){
                    item.ContinuousSalesType = event.target.value;
                }
                console.log('item1',item);
            }
            console.log('index',index);            
            return item;
        });
        console.log('items11',items);
        console.log('oppSync1',this.oppSync);
        const updatedItem = items.filter((item, index, array) => index === Number(event.target.dataset.opp));
        console.log('updatedItem',updatedItem);
        if(this.omniJsonData) {
            let updateOmniJsonData = JSON.parse(JSON.stringify(this.omniJsonData));
            updateOmniJsonData.FamilyOfferingQLIlist = this.oppSync;
            this.omniApplyCallResp(updateOmniJsonData);
        }
    }
    redirectToCart(){
        const sfdcBaseURL = window.location.origin;
        console.log('sfdcBaseURL',sfdcBaseURL);
        const endurl = sfdcBaseURL+'/apex/vlocity_cmt__hybridcpq?id='+this.contextId;
        console.log('endurl',endurl);
        location.href = endurl;
    }
}