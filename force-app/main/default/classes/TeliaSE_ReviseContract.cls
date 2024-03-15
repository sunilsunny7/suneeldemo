global without Sharing  class TeliaSE_ReviseContract implements vlocity_cmt.VlocityOpenInterface {
global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
     Boolean result = true;
        try
        {
            if(methodname.equals('reviseContract'))
            {
                reviseContract(inputMap,outMap);
            }
        }
        catch(Exception e)
        {
            System.debug('exception: '+e);
            outMap.put('Error','Error');
            result = false;
        }
        return result;

}
private void reviseContract(Map<String,Object> inputMap,Map<String,Object> outMap)
{
    Id contractId=(Id)inputMap.get('ContextId');
    Contract con = [Select TeliaSE_MC_Sales_Flow_Identifier__c from Contract Where id =: contractId];
    //System.debug('ContractValue'+con.TeliaSE_MC_Sales_Flow_Identifier__c);
    Id  quoteId=[select vlocity_cmt__QuoteId__c from Contract where id=:contractId].vlocity_cmt__QuoteId__c;
    Approval.unlock(quoteId,false);
    Quote quote=[select TeliaSE_Locked__c  from Quote where id=:quoteId];
    quote.TeliaSE_Locked__c=false;
    quote.TeliaSE_RevisedAgreement__c=contractId;
    //quote.status='Draft';
    //MCSTO-8100 UAT defect
    if(con.TeliaSE_MC_Sales_Flow_Identifier__c==NULL)
    {
        quote.TeliaSE_MC_Sales_Flow_Identifier__c = 'Omforhandling';
    }
    else
    {
        quote.TeliaSE_MC_Sales_Flow_Identifier__c = con.TeliaSE_MC_Sales_Flow_Identifier__c;    
    }
        //System.debug('Quote Value'+quote.TeliaSE_MC_Sales_Flow_Identifier__c);
    if(TeliaSE_Checkrecursive.runOnce())
    {
        update quote;
    }
    outMap.put('quoteId',quoteId);
}
    
}