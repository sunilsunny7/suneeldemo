global with sharing class BasketRequestDummy implements vlocity_cmt.VlocityOpenInterface {
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        
        if(methodName.equals('trimRequest'))
        {
            trimRequest(inputMap, outMap, options);
        }
        return true;
    }
    
    public static void trimRequest(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options){
        Map<String, Object> productConfigMap = new Map<String, Object>();
        Map<String, Object> tempMap = (Map<String, Object>)inputMap.get('productConfig');
        Map<String, Object> tempMap1 = new Map<String, Object>();
        removeItems(tempMap);
        tempMap1 = (Map<String, Object>)tempMap;
        Trim_addToBasketRequest__mdt finalNodeslist = [Select MCONL_Attributes_to_Remove_AddToBasket__c from Trim_addToBasketRequest__mdt];
        String finalNodeslistStr=finalNodeslist.MCONL_Attributes_to_Remove_AddToBasket__c;
        List<String> finalNodeslistStrtolist = finalNodeslistStr.split(',');
        Set<String> finalNodes= new Set<String>(finalNodeslistStrtolist);
        Map<String,Object> offerDetails=(Map<String,Object>)tempMap1.get('offerDetails');
        Map<String,Object> offer=(Map<String,Object>)offerDetails.get('offer');
        
        
        removeItemsFields(offer, finalNodes);
        string opString = JSON.serialize(tempMap1);
        productConfigMap = (Map<String, Object>)JSON.deserializeUntyped(opString);
        Boolean success = (Boolean)inputMap.get('success');
        String basketAction = (String)inputMap.get('basketAction');
        String basketLineRelationId = (String)inputMap.get('basketLineRelationId');
        Integer basketLineRelationCount = (Integer)inputMap.get('basketLineRelationCount');
        String contextKey = (String)inputMap.get('contextKey');
        outMap.put('productConfig',productConfigMap);
        outMap.put('contextKey',contextKey);
        outMap.put('basketLineRelationCount',basketLineRelationCount);
        outMap.put('basketLineRelationId',basketLineRelationId);
        outMap.put('basketAction',basketAction);
        outMap.put('success',success);
    }
    
    //Below method will remove the bundles and childproducts having quantity 0 as well as the json attributes that are not needed, via custom metadata.
    public static void removeItems(Object obj){
        
        Map<String, Object> tempMap1 = (Map<String, Object>)obj;
        Map<String,Object> offerDetails=(Map<String,Object>)tempMap1.get('offerDetails');
        Map<String,Object> offer=(Map<String,Object>)offerDetails.get('offer');
        if(offer.containsKey('childProducts'))
        {
            List<Object> childProducts=(List<Object>)offer.get('childProducts');
            for(Integer j = childProducts.size() - 1; j >= 0; j--)
            {
                Map<String, Object> tempMap2 = (Map<String, Object>)childProducts.get(j);
                if(tempMap2.containsKey('childProducts')){
                    List<Object> childProducts1=(List<Object>)tempMap2.get('childProducts');
                    for(Integer i = childProducts1.size() - 1; i >= 0; i--){
                        Map<String, Object> tempMap3 = (Map<String, Object>)childProducts1.get(i);
                        if(tempMap3.containsKey('Quantity')){
                            if(Integer.Valueof(tempMap3.get('Quantity'))==0){
                                childProducts1.remove(i);
                            }
                        }
                    }                
                    if(childProducts1.isEmpty()){
                        childProducts.remove(j);
                    }
                }
            }
        }           
    }
    public static void removeItemsFields(Object obj,Set<String> finalNodes)
    {
        List<String> errorList = new List<String>();
        try{
            Map<String,Object> tempMap=(Map<String,Object>)obj;
            if(tempMap.containsKey('childProducts'))
            {
                List<Object> childProducts=(List<Object>)tempMap.get('childProducts');
                for(Object obj3:childProducts)
                {
                    removeItemsFields(obj3,finalNodes);
                }
            }
            if(tempMap.containsKey('AttributeCategory'))
            {
                Map<String,Object> tempMap1=(Map<String,Object>)tempMap.get('AttributeCategory');
                removeItemsFields(tempMap1,finalNodes);
                List<Object> attrRecords=(List<Object>)tempMap1.get('records');
                for(Object obj2:attrRecords)
                {
                    Map<String,Object> tempMap2=(Map<String,Object>)obj2;
                    removeItemsFields(tempMap2,finalNodes);
                    Map<String,Object> tempMap3=(Map<String,Object>)tempMap2.get('productAttributes');
                    removeItemsFields(tempMap3,finalNodes);
                    List<Object> prodAttrRecords=(List<Object>)tempMap3.get('records');
                    for(Object obj1:prodAttrRecords)
                    {
                        removeItemsFields(obj1,finalNodes);
                        Map<String,Object> tempMap4=(Map<String,Object>)obj1;
                        if(tempMap4.containsKey('values')){
                            List<Object> prodAttrRecordsValue=(List<Object>)tempMap4.get('values');
                            for(Object obj12:prodAttrRecordsValue){
                                removeItemsFields(obj12,finalNodes);
                            }
                        }
                    }
                }
            }
            
            if(tempMap.containsKey('priceResult'))
            {
                List<Object> priceResult=(List<Object>)tempMap.get('priceResult');
                for(Object obj1:priceResult)
                {
                    removeItemsFields(obj1,finalNodes);
                }
            }
            for(String key:tempMap.keySet())
            {
                if(finalNodes.contains(key))
                {
                    tempMap.remove(key);
                }
            }
        }catch(Exception e){
            system.debug('Exception : '+e.getStackTraceString());
            errorList.add(e.getStackTraceString());
        }
    }
}