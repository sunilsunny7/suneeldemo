public class MCOnline_RetryNumberUnReservation {
    @InvocableMethod(label='Retry Number Un Reservation')
    public static List<List<String>> retryUnReservation(List<Id> baskets){
        Map<String,Map<string,set<string>>> MiniBasketUnreserve = new Map<String,Map<string,set<string>>>();
        Map<string,set<string>> MiniBasketMap = new Map<string,set<string>>();
        List<List<String>> outResponse = new List<List<String>>();
        List<String> responseList = new List<String>();
        List<MCOnline_Basket__c> basketItem = [SELECT id,Name,MCOnline_AttributeJSON__c,TSCID__c FROM MCOnline_Basket__c WHERE id=:baskets.get(0) AND MCOnline_Is_Processed__c=false];
        if(basketItem.isEmpty()){
            responseList.add('Basket is not eligible for retry number Unreservation');
            outResponse.add(responseList);
            return outResponse ;
        }else{
            Map<String,Object> productsMap = (Map<String,Object>)JSON.deserializeUntyped(basketItem.get(0).MCOnline_AttributeJSON__c); // map to store the attributesJson of that basket
            Set<string> tscid = new set<string>{basketItem.get(0).TSCID__c};  // storing the TSCID of the basket
            Set<String> msisdnSet = new Set<String>(); // Set to hold the number of msisdns of the basket
            List<Object> prodList = (List<Object>)JSON.deserializeUntyped(JSON.serialize(productsMap.get('products'))); // List to hold the products from the attribute JSON
            for(Object productObj : prodList){ // iterating through the number of products
                Map<String,Object> productMap = (Map<String,Object>)productObj; 
                Map<String,Object> attributeMap = (Map<String,Object>)productMap.get('attributes');  // map to store the attributes of the product
                if(attributeMap != null && attributeMap.get('MSISDN') != null){ // fetching the MSISDN of the product 
                    string msisdn = String.valueOf(attributeMap.get('MSISDN'));
                    msisdnSet.add(msisdn);  //adding the MSISDNs in the set 
                }
            }
            MiniBasketMap.put('MSISDN',msisdnSet);
            MiniBasketMap.put('tscid',tscid);
            MiniBasketUnreserve.put(string.valueOf(basketItem.get(0).Name),MiniBasketMap);
            MCOnline_Utility.retry_UnreserveNumber(JSON.serialize(MiniBasketUnreserve));
            List<String> msisdn = new List<String>(msisdnSet);
            List<MCONL_MSISDN__c> updatedRecord = [SELECT Unreservation_Response__c,Status__c FROM MCONL_MSISDN__c WHERE Number__c IN:msisdn];
            for(MCONL_MSISDN__c msisdnNumber : updatedRecord){
                if(msisdnNumber.Status__c=='Un Reserve'){
                    responseList.add(msisdnNumber.Unreservation_Response__c);
                }
            }
            system.debug(responseList);
            if(!responseList.isEmpty()){
                outResponse.add(responseList);
                return outResponse ; 
            }else{
                responseList.add('Failed to Unreserve');
                outResponse.add(responseList);
                return outResponse ; 
            } 
        }    
        
 	}
    
}