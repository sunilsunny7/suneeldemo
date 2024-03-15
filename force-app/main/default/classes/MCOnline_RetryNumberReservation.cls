public class MCOnline_RetryNumberReservation {
    
    @InvocableMethod(label='Retry Number Reservationmconl')
    public static List<List<String>> retryReservation(List<Id> baskets){
        string msisdn;
        Boolean canRetry;
        Boolean grsResponse = false;
        Boolean retry = false;
        Integer msisdnSize;
        List<List<String>> outPutList = new List<List<String>>();
        List<MCONL_MSISDN__c> msisdnObj = new List<MCONL_MSISDN__c>();
        List<MCONL_MSISDN__c> msisdnObjUpdated = new List<MCONL_MSISDN__c>();
        List<String> msisdnResponse = new List<String>();
        //Fetch the basket details from the input basket id
        List<MCOnline_Basket__c> basketItems = [SELECT id,MCOnline_AttributeJSON__c,MCOnline_Basket_Key__c,TSCID__c,CreatedDate FROM MCOnline_Basket__c WHERE id=:baskets.get(0) AND MCOnline_Is_Processed__c=false];
        if(!basketItems.isEmpty()){
            String attributeJSON = basketItems.get(0).MCOnline_AttributeJSON__c;
            String cartContextKey = basketItems.get(0).MCOnline_Basket_Key__c;
            String tscid = basketItems.get(0).TSCID__c;
            Map<String,Object> itemList = new Map<String,Object>();
            itemList = (Map<String,Object>)JSON.deserializeUntyped(attributeJSON);
            Set<String> msisdnSet = new Set<String>();
            Set<String> productCategorySet = new Set<String>();
            List<Object> items = new List<Object>();
            //iterate through each product inside the basket
            items = (List<Object>)itemList.get('products');
            for(Object lineItemObj : items){
                if(lineItemObj != null){
                    Map<String, Object> recObj1Map = (Map<String, Object>)lineItemObj;
                    if(recObj1Map != null){
                        Map<String, Object> attributesMap = (Map<String, Object>)recObj1Map.get('attributes');
                        // save MSISDN from  attribute of the product into a Set
                        if(attributesMap != null){
                            msisdn = (string)attributesMap.get('MSISDN');
                            msisdnSet.add(msisdn);
                            msisdnSize = msisdnSet.size();
                        }
                    }
                }
            }
            if(!String.isBlank(attributeJSON)){
                List<String> msisdnList = new List<String>();
                msisdnList.addAll(msisdnSet);
                // fetch records from MSISDN Object associated with the basket
                msisdnObj = [SELECT id,HttpResponse__c,	Status__c FROM MCONL_MSISDN__c WHERE TSCID__c =:tscid AND CartContextKey__c=:cartContextKey AND number__c IN:msisdnList];
                // iterate through each record 
                for(MCONL_MSISDN__c msisdnRecord : msisdnObj){
                    if(!String.isBlank(msisdnRecord.HttpResponse__c)){
                      	// if status = Failed to Reserve AND HTTP response contains SRP or invalid credential then the record is right candidate for retry
                      	canRetry = ((msisdnRecord.Status__c).equalsIgnoreCase('Failed to Reserve')) && ((msisdnRecord.HttpResponse__c).contains('SRP')|| (msisdnRecord.HttpResponse__c).contains('Invalid Credentials'));
                     	// check if failed to reserve status is because of the GRS ( if number is already reserved GRS is returned as response from NHF) in the response
                    	grsResponse = ((msisdnRecord.Status__c).equalsIgnoreCase('Failed to Reserve')) && ((msisdnRecord.HttpResponse__c).contains('GRS'));
						if(canRetry){
                        	retry = true;

                        }
                    }else{
                        retry = true;
                    }
                     

                }
                // if retry flag is true then retry reservation with same input in the record
                if(retry){
                    MCOnline_Utility.reserveNumber(AttributeJSON, cartContextKey, tscid,'reTryNumberReservation');
                    // fetch the record which is updated by the above method 
                    msisdnObjUpdated = [SELECT id,HttpResponse__c,	Status__c FROM MCONL_MSISDN__c WHERE TSCID__c =:tscid AND CartContextKey__c=:cartContextKey AND number__c IN:msisdnList ORDER BY CreatedDate DESC LIMIT :msisdnSize];
                    for(MCONL_MSISDN__c response:msisdnObjUpdated ){
                        msisdnResponse.add(response.HttpResponse__c);
                    }
                }else{
                    msisdnResponse.add('Cant retry due to one of the following: Number already reserved OR Invalid credential OR number is not available for reservation');
                }
            }
            outPutList.add(msisdnResponse);
            return outPutList;
        }else{
            msisdnResponse.add('Basket is not eligible for retry number reservation');
            outPutList.add(msisdnResponse);
            return outPutList;
        }
        
    }
    
    
}