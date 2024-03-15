global class VOExtractRemoteActions_V2 implements vlocity_cmt.VlocityOpenInterface {
    
    final Integer batchSize = 50;
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        try {            
            if (methodName.equalsIgnoreCase('getAllBundles')) {
                return getAllBundles(inputMap, outputMap, options);
            } 
        }
        catch(System.Exception e) {            
            outputMap.put('error', e.getMessage());
            return false;
        }
        return true;
    }
    
    public Boolean getAllBundles(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
        
        String cartId;
        
        if (input.get('cartId') == null) {
            output.put('error ', 'No cartId'); 
            return false;
        }
        
        if (input.get('cartId') != null){
            cartId = (String)input.get('cartId');
        }
        String quoteType;
        List<Map<String,Object>> batchGroups = new List<Map<String, Object>>() ;
        List<QuoteLineItem> qliItem = [SELECT id,vlocity_cmt__LineNumber__c,vlocity_cmt__RootItemId__c,vlocity_cmt__ParentItemId__c,MC_RootPriceFlag__c,QuoteId,Quote.TeliaSE_MC_Sales_Flow_Identifier__c FROM QuoteLineItem WHERE QuoteId =: cartId ORDER BY vlocity_cmt__LineNumber__c];
        List<QuoteLineItem> cartItems = new List<QuoteLineItem>();
        System.debug('cartItems size ' +cartItems.size());
        if(cartItems.size() > 0){
            QuoteLineItem firstQLI = cartItems[0];
            quoteType = firstQLI.Quote.TeliaSE_MC_Sales_Flow_Identifier__c;
        }
        
        if(quoteType != 'New Sales')
        {            
            List<String> parentItemId = new List<String>();
            boolean allUpdated = true;
            for(QuoteLineItem qli:qliItem) {
                if(qli.vlocity_cmt__ParentItemId__c == null && qli.MC_RootPriceFlag__c == true) {
                    parentItemId.add(qli.vlocity_cmt__RootItemId__c);
                }
                else if(qli.vlocity_cmt__ParentItemId__c == null && qli.MC_RootPriceFlag__c == false) {
                    allUpdated = false;
                }
            }            
            if(parentItemId != null && parentItemId.size()>0 && allUpdated == false){                
                for(QuoteLineItem qliChild : qliItem) {
                    if(parentItemId.contains(qliChild.vlocity_cmt__RootItemId__c)) {
                        cartItems.add(qliChild);
                    }
                }
            }
            if(allUpdated){
                cartItems.addAll(qliItem);
            }
        }else{
            cartItems.addAll(qliItem);
        }       
        
        List<List<QuoteLineItem>> result = (List<List<QuoteLineItem>>) Lists.doPartions(cartItems, batchSize, List<List<QuoteLineItem>>.class);
        System.debug('result ' +result.size());
        
        for (Integer i=0; i< result.size(); i++){
            Map <String, Object> bundle = new Map <String, Object>();            
            List<Id> itemIds = new List<Id>(new Map<Id, QuoteLineItem>(result[i]).keySet());
            List<String> itemsArray = new List<String>();
            bundle.put('items',itemIds);
            batchGroups.add(bundle);
            System.debug('bundle ' +bundle);       
        }
        output.put('bundles' ,batchGroups);
        output.put('cartId', cartId);
        return true;
    }    
}