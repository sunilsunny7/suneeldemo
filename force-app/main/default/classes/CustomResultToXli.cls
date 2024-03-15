// global inherited sharing class CustomResultToXli implements VlocityOpenInterface
global inherited sharing class CustomResultToXli implements vlocity_cmt.VlocityOpenInterface
{

    private static Set<String> fieldsToUpdate = new Set<String>{
        'vlocity_cmt__LineNumber__c'
    };
    private vlocity_cmt.VOIInvoker invoker = vlocity_cmt.VOIInvoker.getInstance();
    private vlocity_cmt.VlocityOpenInterface defaultResultToXli = (vlocity_cmt.VlocityOpenInterface)invoker.invoke('DefaultResultToXLIImplementation', 'debugCreate', null, null, null);
    // private VOIInvoker invoker = VOIInvoker.getInstance();
    // private VlocityOpenInterface defaultResultToXli = (VlocityOpenInterface)invoker.invoke('DefaultResultToXLIImplementation', 'debugCreate', null, null, null);
    /*
        sample input : 
        {
            "totals" : {...},
            "records" : [
                {
                    "actions" : {...},
                    "lineItemKey" : "",
                    "bundleContextKey" : "",
                    ...
                },
                {
                    "actions" : {...},
                    "lineItemKey" : "",
                    "bundleContextKey" : "",
                    ...
                },
                ...
            ],
            "totalSize" : N
        }
    */
    public static void iterateJsonResult(Map<String, Object> jsonResult)
    {
        List<Object> jsonRecords = (List<Object>)jsonResult.get('records');
        for(Object jsonRecordObject : jsonRecords)
        {
            Map<String, Object> jsonRecord = (Map<String, Object>)jsonRecordObject;
            iterateJsonRecord(jsonRecord);
        }
    }

    public static void iterateJsonRecord(Map<String, Object> jsonRecord)
    {        
        for(String key :  fieldsToUpdate)
        {
            if(jsonRecord.get(key) == null || (jsonRecord.get(key) instanceOf Map<String,Object>))
            {
                continue;
            }

            Map<String, Object> objMap = new Map<String,Object> {
                'value' => jsonRecord.get(key)
            };
            jsonRecord.put(key, objMap);
        }

        Map<String, Object> productGroupsMap = (Map<String, Object>)jsonRecord.get('productGroups');
        if(productGroupsMap != null)
        {
            List<Object> productGroups = (List<Object>)productGroupsMap.get('records');
            for(Object productGroupObject : productGroups)
            {
                Map<String, Object> productGroup = (Map<String, Object>)productGroupObject;
                iterateJsonRecord(productGroup);
            }
        }

        Map<String, Object> lineItemsMap = (Map<String, Object>)jsonRecord.get('lineItems');
        if(lineItemsMap != null)
        {
            List<Object> lineItems = (List<Object>)lineItemsMap.get('records');
            for(Object lineItemObject : lineItems)
            {
                Map<String, Object> lineItem = (Map<String, Object>)lineItemObject;
                iterateJsonRecord(lineItem);
            }
        }

    }

    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap,
                                Map<String, Object> options)
    {
        if (methodName.equalsIgnoreCase('generateXLIFromResult'))
        {
            Object result = inputMap.get('result');
            System.debug('****before**** ::: ' + JSON.serialize(result));
            Map<String, Object> resultMap;
            if(result instanceof String)
            {   
                resultMap = (Map<String, Object>)JSON.deserializeUntyped((String)result);
                inputMap.put('result', resultMap);
            }
            else
            {
                resultMap = (Map<String, Object>)result;
            }
            iterateJsonResult(resultMap);
            System.debug('****after**** ::: ' + JSON.serialize(resultMap));
        }
        
        //invoke actual method
        defaultResultToXli.invokeMethod(methodName, inputMap, outputMap, options);
        return true;
    }
}