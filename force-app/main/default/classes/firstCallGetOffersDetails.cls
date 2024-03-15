global class firstCallGetOffersDetails Implements Schedulable{
    global void execute(SchedulableContext sc){
        List<vlocity_cmt__CatalogProductRelationship__c> offers = [select id,Name,vlocity_cmt__CatalogId__r.Name from vlocity_cmt__CatalogProductRelationship__c order by vlocity_cmt__CatalogId__r.Name];
        Set<String> catalogCode = new Set<String>();
        Set<String> offerCode = new Set<String>();
        Map<String, Object> input = new Map<String, Object>();
        String output;
        Map<String, Object> option = new Map<String, Object>();
        Map<String, Object> output2 = new Map<String, Object>();
        input.put('apiName','getOfferDetails');
        if(offers != null){
            for(vlocity_cmt__CatalogProductRelationship__c pr : offers){
                //catalogCode.add(pr.vlocity_cmt__CatalogId__r.Name);
                //offerCode.add(pr.Name);
                input.put('catalogCode',pr.vlocity_cmt__CatalogId__r.Name);
                input.put('requestURL', '/v3/catalogs/'+pr.vlocity_cmt__CatalogId__r.Name+'/offers/'+pr.Name);
                vlocity_cmt.CpqAppHandler appHandler = new vlocity_cmt.CpqAppHandler();
                if(!Test.isRunningTest())
                {
                    appHandler.invokeMethod('getOfferDetailsByCatalogCode', input, output2, option);
                }
                Map<String, Object> getOfferDetailsResponse = new Map<String, Object>();
                if(output2 != null && !Test.isRunningTest())
                {
                    getOfferDetailsResponse = output2;
                }
                else
                {
                    getOfferDetailsResponse = (Map<String,Object>)JSON.deserializeUntyped(output);
                }
                system.debug('getOfferDetailsResponse=>'+getOfferDetailsResponse);
    		}           
        }        
    }
}