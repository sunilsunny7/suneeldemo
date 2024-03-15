global class MC_CustomFunctions implements vlocity_cmt.VlocityOpenInterface
{
    /*
inputs - arguments - List<Object> of passed in arguments
output - result - The result of the Function being called. Supports single Object values, List<Object> or Map<String, Object>
*/
    global Boolean invokeMethod(String methodName, Map<String, Object> inputs, Map<String, Object> output, Map<String, Object> options)
    {
        // SUM Returns a single value
        if (methodName == 'BundleFaItems')
        {
            system.debug(Json.serialize(inputs));
            List<Object> arguments = (List<Object>)inputs.get('arguments');
            system.debug(Json.serialize(arguments));
            output.put('result', bundleFaItems(arguments));
        }
        else if(methodName == 'BundleFAItemsRemote')
        {
            bundleFAItemsRemote(inputs,output);
        }
        else if(methodName == 'CheckB2BToggle')
        {
            output.put('result', System.Label.B2BSolution_Toggle);
        }
        else if(methodName == 'fetchSystemLabels')
        {
            List<Object> argumentsList = (List<Object>)inputs.get('arguments');
            String argument= String.valueOf(argumentsList[0]);
            fetchSystemLabels(argument, output);
        }
        else if(methodname == 'copyContentVersion'){
         	Map<String,Object> step1 = (Map<String,Object>)inputs.get('Step1');
            List<Object> files =(List<Object>) step1.get('File1');
            Map<String,Object> file1 = (Map<String,Object>) files[0];
			string contentId = (String) file1.get('data');
            string contextId = (String)inputs.get('ContextId');  
            system.debug(contentId + '   ' + contextId);
            List<ContentDocumentLink> cdlExist = [Select id from ContentDocumentLink where contentdocumentid=:contentId AND linkedEntityId=:contextId];
            if(cdlExist.size()>0){
                return true;
            }
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.linkedEntityId = contextId;
            cdl.contentdocumentid = contentId;
            cdl.shareType = 'V';
            cdl.Visibility = 'AllUsers'; 
            insert cdl;
            return true;
        }
        return true;
    }
    
    string bundleFaItems(List<Object> arguments)
    {
        
        Map<String,Integer> rootItemChildItemCount = new Map<String,Integer>(); 
        for(Object o: arguments)
        {            
            Map<String,Object> qli = (Map<String,Object>) o;
            List<Object> childQli =(List<Object>) qli.get('Child');
            system.debug('qli.Id: '+qli.get('Id') + ' childQliList Size: '+childQli.size());
            rootItemChildItemCount.put((String)qli.get('Id'),childQli.size());           
        }
        Map<String,object> outMap = new Map<String,Object>(); 
        batchify(rootItemChildItemCount,outMap);
        return json.serializePretty(outMap.get('result'));        
    }
    
    public static void bundleFAItemsRemote(Map<String, Object> inputs, Map<String, Object> output)
    {
        string quoteId = (String)inputs.get('quoteId');
        string salesIdentifier;
        Map<String,Object> qliMap = new Map<String,Object>();
        Map<String,Integer> qliChildCount = new Map<String,Integer>();
        List<QuoteLineItem> qliList = [Select id, Quote.TeliaSE_MC_Sales_Flow_Identifier__c  ,vlocity_cmt__Product2Id__r.TeliaSE_MC_isCallOff_Flag__c,TeliaSE_Product_Object_Type__c,MC_RootPriceFlag__c,vlocity_cmt__ParentItemId__c,vlocity_cmt__RootItemId__c from quoteLineItem where quoteId=:quoteId];
        If(qliList.size()>0)
        {
            salesIdentifier = qliList[0].Quote.TeliaSE_MC_Sales_Flow_Identifier__c;
        }
        
        integer count=0;
        for(QuoteLineItem qli:qliList)
        {
            system.debug(qli.vlocity_cmt__RootItemId__c);
            qliMap.put(qli.id,qli);
            if(qliChildCount.containsKey(qli.vlocity_cmt__RootItemId__c))
            {
                count = qliChildCount.get(qli.vlocity_cmt__RootItemId__c);
                count=count+1;
                qliChildCount.put(qli.vlocity_cmt__RootItemId__c,count);
            }
            else
            {
                qliChildCount.put(qli.vlocity_cmt__RootItemId__c,1);
            }
        }
        for(String item:qliChildCount.keySet())
        {
            quoteLineItem qli = (QuoteLineItem)qliMap.get(item);
            if((salesIdentifier == 'New Sales' && qli.vlocity_cmt__Product2Id__r.TeliaSE_MC_isCallOff_Flag__c == true) || 
               (salesIdentifier != 'New Sales' && (qli.vlocity_cmt__Product2Id__r.TeliaSE_MC_isCallOff_Flag__c == true || qli.MC_RootPriceFlag__c == false)))
            {
                qliChildCount.remove(item);
            }
        }
        
        batchify(qliChildCount,output);
        
    }
    
    public static void batchify(Map<String,Integer> input , Map<String,Object> outputMap)
    {
        integer blocksize = Integer.valueOf(system.label.MC_PricingItemsBatch);
        integer count = 0;
        List<Map<String,Object>> returnMap = new list<Map<String,Object>>();        
        List<Id> qliId = new List<Id>();
        integer currentBatchSize = 0;
        for(String itemId: input.keySet())
        {
            integer childItemListSize = input.get(itemId);
            if(childItemListSize > blocksize)
            {
                List<Id> qliIdLargeBundle = new List<Id>();
                qliIdLargeBundle.add(itemId);
                Map<String,Object> dummyMap1 = new Map<String,Object>();
                dummyMap1.put('Id',qliIdLargeBundle);
                returnMap.add(dummyMap1);
                qliIdLargeBundle.clear();
            }
            else if (childItemListSize + currentBatchSize <=blocksize)
            {
                currentBatchSize = currentBatchSize + childItemListSize;
                qliId.add(itemId);                
            }
            else if (childItemListSize + currentBatchSize > blocksize)
            {
                Map<String,Object> dummyMap = new Map<String,Object>();
                List<Id> qliClone = qliId.clone();
                dummyMap.put('Id',qliClone);
                returnMap.add(dummyMap);               
                qliId.clear();
                qliId.add(itemId);
                currentBatchSize = childItemListSize;
            }                
        }
        
        if(qliId.size() > 0)
        {
            Map<String,Object> dummyMap1 = new Map<String,Object>();
            dummyMap1.put('Id',qliId);
            returnMap.add(dummyMap1);
        }
        
        //system.debug(returnMap);        
        system.debug(json.serializePretty(returnMap));
        outputMap.put('result',returnMap);
    }
    
    public static void fetchSystemLabels(String arguments, Map<String,Object>output)
    {
        if(arguments == 'B2BToggleFlag'){
             output.put('result', System.Label.B2BSolution_Toggle);
        }
        else if(arguments== 'CheckSPOCKToggle')
        {
            output.put('result', System.Label.MC_SpockToggle);
        }
        else if(arguments== 'CheckQuantityCapture')
        {
            output.put('result', System.Label.MC_QuantityCapture);
        }
    }
}