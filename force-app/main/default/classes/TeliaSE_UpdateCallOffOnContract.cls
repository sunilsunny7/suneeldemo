/**
 *  Created By: Vamsi D
 *  Calling from Omniscript: Document/ContractDocument
 *  MCSTO-4992: Auto Send TP Cal-Off to TUPP in Combi Scenario
 */
global class TeliaSE_UpdateCallOffOnContract  implements vlocity_cmt.VlocityOpenInterface2 {
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
    Boolean result = true;
        try {
            if(methodName.equalsIgnoreCase('updateCallOffDetails')) {
                updateCallOffDetails(inputMap, outMap);
            }else {
                result = false;
            }  
        }catch(Exception e) {          
            result = false;
        }        
        return result;
    }
    public static void updateCallOffDetails(Map<String,Object> inputMap, Map<String,Object> outMap){
        String ContractId = String.valueOf(inputMap.get('ContextId'));
        Contract contractToUpdate = new Contract();
        contractToUpdate.id = ContractId;
        Contract con = new Contract();
        con = [Select vlocity_cmt__OpportunityId__c,vlocity_cmt__QuoteId__c,CallOff_QuoteId__c,TeliaSE_is_combi__c from Contract where id =: ContractId];
        //verify if calloff QuoteId exists and Is Combi checked or not
        if((con.CallOff_QuoteId__c == ''|| con.CallOff_QuoteId__c == null) && con.TeliaSE_is_combi__c){
            // get Quote where record type is Offer and TP case Number is null
            List<Quote> quoteList = new List<Quote>([SELECT Id FROM Quote WHERE OpportunityId =: con.vlocity_cmt__OpportunityId__c AND RecordType.DeveloperName = 'Offer' AND Status != 'Cancelled' AND TeliaSE_Touchpoint_Case_Number__c = null AND vlocity_cmt__ParentQuoteId__c=: con.vlocity_cmt__QuoteId__c]);
            Set<String> quoteId = new Set<String>();
            Set<String> qliQuote = new Set<String>();
            if(quoteList != null){
                for(Quote qut : quoteList){
                    quoteId.add(qut.Id);
                }
                // Get QuoteLineItems if they contain Touch point exist and sort by created date 

                List<QuoteLineItem> qli = new List<QuoteLineItem>([SELECT Id, QuoteId FROM QuoteLineItem  WHERE (QuoteId in : quoteId AND  (TeliaSE_Product_Object_Type__c = 'Touch Point Offer Spec' OR TeliaSE_Product_Object_Type__c = 'Smart Connect Offer Spec')AND MC_TeliaExcludeQuoteItem__c = false and TeliaSE_Product_Service_Code__c != Null ) ORDER BY CreatedDate DESC]);
                if(qli.size() != null && qli.size()>0){

                    for(QuoteLineItem q : qli){
                        qliQuote.add(q.QuoteId);
                    }   
                }
            }
            // get the fist/latest Quote with TP and update the CallOffQuoteId on Contract
            if(qliQuote.size() != null){
                contractToUpdate.CallOff_QuoteId__c = qliQuote.iterator().next();
            }
            update contractToUpdate;
        }
    }
}