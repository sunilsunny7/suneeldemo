import {LightningElement,api } from "lwc"; 
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import {OmniscriptActionCommonUtil} from "vlocity_cmt/omniscriptActionUtils"; 

export default class businessPlusCustomerDetails extends OmniscriptBaseMixin(LightningElement) {     
    @api recordId;
    customerFlag = false;
    customerFlag2 = false;
    customerFlag3 = false;
    _actionUtil;
    _ns = "vlocity_cmt"; 
    
    connectedCallback() {
        this._actionUtil = new OmniscriptActionCommonUtil(); 
        this.IPInput = {AccountId: this.recordId};
        const options = {};
        const params = {
            input: JSON.stringify(this.IPInput),
            sClassName: `${this._ns}.IntegrationProcedureService`,
            sMethodName: "BusinessPlus_Customer",
            options: JSON.stringify(options)
        };
        this._actionUtil
            .executeAction(params, null, this, null, null)
            .then((response)=> { 
            if(response.result.IPResult.goodieList[0].eligibility == false)
            {
                this.customerFlag = true;
            }
            else if(response.result.IPResult.goodieList[0].eligibility == true && response.result.IPResult.goodieList[0].status == "VALID_TO_ORDER" && response.result.IPResult.goodieList[0].currentHoldings[0] == null){
                this.customerFlag2 = true;
            }
            
            else if(response.result.IPResult.goodieList[0].eligibility == true && response.result.IPResult.goodieList[0].currentHoldings[0].name != null){
                this.customerFlag3 = true;
            }
                    
            })
            
            .catch((error)=> { 
                console.error(error, "ERROR");
            });  
        }

}