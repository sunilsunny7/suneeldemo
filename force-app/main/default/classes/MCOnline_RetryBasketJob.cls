global class MCOnline_RetryBasketJob implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String name = 'Binamra';
        //String basketList = 'Select id, Name, MCOnline_Catalog__c,MCOnline_OfferCode__c, MCOnline_AttributeJSON__c, MCOnline_Basket_Key__c from MCOnline_Basket__c Where MCOnline_ParentBasket__r.Is_Processed__c = false AND CreatedBy.FirstName = \''+name+'\'';  
        String basketList = 'Select id, Name, MCOnline_Catalog__c,MCOnline_OfferCode__c, MCOnline_AttributeJSON__c, MCOnline_Basket_Key__c from MCOnline_Basket__c Where MCOnline_ParentBasket__r.Is_Processed__c = false';
        return Database.getQueryLocator(basketList);
    }
    global void execute(Database.BatchableContext BC,List<MCOnline_Basket__c> basketList)
    {
        for(MCOnline_Basket__c cacherecord : basketList)
        {
            String CartContextKey = String.valueOf(cacherecord.MCOnline_Basket_Key__c);
            String catalog = String.valueOf(cacherecord.MCOnline_Catalog__c);
            HttpRequest req=new HttpRequest();
            req.setMethod('GET');
            req.SetTimeout(120000);
            req.setHeader('Authorization', 'OAuth '+UserInfo.getSessionId());
            req.setEndpoint(System.URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/vlocity_cmt/v3/catalogs/'+catalog+'/basket/'+CartContextKey); // System.Label.BaseUrl
            HttpResponse response = new HttpResponse();
            string body = '';
            if(!Test.isRunningTest())
            {
                response = new Http().send(req);
                if(response != null)
                {
                    body = response.getBody();
                }
            }else
            {
                body = BasketDetailsResponse_CalloutGenerator.body;
            }
            System.debug(body);
            Map<String, Object> getBasketStd = new Map<String, Object>();
            if(body != null)
            {
                getBasketStd = (Map<String, Object>)JSON.deserializeUntyped(body);
            }
            if(response != null && response.getStatusCode() == 200 && getBasketStd != null && getBasketStd.containsKey('errorCode') && String.valueOf(getBasketStd.get('errorCode')) != 'INVOKE-200')
            {
                String output;
                getOfferDetailsStd(cacherecord, output);
            }
        }
    }
    global void finish(Database.BatchableContext BC)
    {
        System.debug('Success');
    }
    public static void getOfferDetailsStd (MCOnline_Basket__c cacherecord, String output)
    {
        Set<String> productCodelist = new Set<String>();
        String cartContextKey = '';
        Map<String, Object> remotemethodResponse = new Map<String, Object>();
        MCOnline_Basket__c basketDetails = (MCOnline_Basket__c)cacherecord;
        String catalog = String.valueOf(basketDetails.MCOnline_Catalog__c);
        String OfferCode = String.valueOf(basketDetails.MCOnline_OfferCode__c);
        if(basketDetails != null && basketDetails.MCOnline_AttributeJSON__c != null)
        {
            Map<String,Object> itemList1 = (Map<String,Object>)JSON.deserializeUntyped(basketDetails.MCOnline_AttributeJSON__c);
            List<Object> productList1 = (List<Object>)itemList1.get('products');
            for(Object obj: productList1)
            {
                Map<String, Object> recObj = ( Map<String, Object>)obj;
                if(recObj != null && recObj.containsKey('productCode') && recObj.get('productCode') != null)
                {
                    productCodelist.add(String.valueOf(recObj.get('productCode')));
                }
            }
        }
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> option = new Map<String, Object>();
        Map<String, Object> output2 = new Map<String, Object>();
        input.put('apiName','getOfferDetails');
        input.put('catalogCode',catalog);
        input.put('requestURL', '/v3/catalogs/'+catalog+'/offers/'+OfferCode);
        vlocity_cmt.CpqAppHandler appHandler = new vlocity_cmt.CpqAppHandler();
		if(!Test.isRunningTest()){
			appHandler.invokeMethod('getOfferDetailsByCatalogCode', input, output2, option);
		}
        //system.debug('std getOfferDetails--> '+JSON.serialize(output));   
        
        /*HttpRequest req=new HttpRequest();
        req.setMethod('GET');
        req.SetTimeout(120000);
        req.setHeader('Authorization', 'OAuth '+UserInfo.getSessionId());
        req.setEndpoint(System.URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/vlocity_cmt/v3/catalogs/'+catalog+'/offers/'+OfferCode); // System.Label.BaseUrl
        HttpResponse response = new HttpResponse();
        string body = '';
        if(!Test.isRunningTest())
        {
            response = new Http().send(req);
            if(response != null)
            {
                body = response.getBody();
            }
        }else
        {
            body = output;
        }
        System.debug(body);*/
        Map<String, Object> getOfferDetailsResponse = new Map<String, Object>();
        if(output2 != null && !Test.isRunningTest())
        {
            getOfferDetailsResponse = output2;
        }else{
			getOfferDetailsResponse = (Map<String,Object>)JSON.deserializeUntyped(output);
		}
        if(getOfferDetailsResponse != null)
        {
            Map<String, Object> output1 = new Map<String, Object>();
            string ContextKey = String.valueof(getOfferDetailsResponse.get('contextKey'));
            Map<String, Object> tempMap = (Map<String, Object>)getOfferDetailsResponse.get('result');
            Map<String,Object> offerDetails=(Map<String,Object>)tempMap.get('offerDetails');
            Map<String,Object> offer1=(Map<String,Object>)offerDetails.get('offer');
            makeQuantityZero(offer1);
            Map<String,Object> offer=(Map<String,Object>)offer1;
            //for(String productCode: productCodelist)
            //{
              //  addToBasketStdMap(offer, productCode);
            //}
            addToBasketStdMap(offer, productCodelist);
            Map<String, Object> productConfigMap = new Map<String, Object>();
            productConfigMap = (Map<String, Object>)tempMap;
            remotemethodResponse=addToBasketStd(ContextKey, JSON.serialize(productConfigMap), catalog);
            if(remotemethodResponse != null && remotemethodResponse.containskey('cartContextKey'))
            {
                cartContextKey = String.valueof(remotemethodResponse.get('cartContextKey'));
            }
            basketDetails.MCOnline_Basket_Key__c = cartContextKey;
            update basketDetails;
        }
    }
    public static void makeQuantityZero(Object offer)
    {
        Map<String,Object> tempMap=(Map<String,Object>)offer;
        if(tempMap.containsKey('childProducts') && tempMap.get('childProducts') != null)
        {
            List<Object> childProducts=(List<Object>)tempMap.get('childProducts');
            for(Object obj3:childProducts)
            {
                Map<String,Object> tempMap1=(Map<String,Object>)obj3;
                if(tempMap1 != null && tempMap1.containsKey('ProductCode') && (tempMap1.containsKey('childProducts') == false || tempMap1.get('childProducts') == null))
                {
                    tempMap1.put('Quantity', 0.0);
                }
                if(tempMap1.containsKey('childProducts') && tempMap1.get('childProducts') != null)
                {
                    List<Object> childProducts1=(List<Object>)tempMap1.get('childProducts');
                    for(Object obj4:childProducts1)
                    {
                        Map<String,Object> tempMap2=(Map<String,Object>)obj4;
                        if(tempMap2 != null && tempMap2.containsKey('ProductCode') && (tempMap2.containsKey('childProducts') == false || tempMap2.get('childProducts') == null))
                        {
                            tempMap2.put('Quantity', 0.0);
                        }
                    }
                }
                
                //addToBasketStdMap(obj3,productCode);
            }
        }               
    }
    public static void addToBasketStdMap(Object offer, Set<String> productCode)
    {
        Map<String,Object> tempMap=(Map<String,Object>)offer;
        if(tempMap.containsKey('childProducts') && tempMap.get('childProducts') != null)
        {
            List<Object> childProducts=(List<Object>)tempMap.get('childProducts');
            for(Object obj3:childProducts)
            {
                Map<String,Object> tempMap1=(Map<String,Object>)obj3;
                if(tempMap1 != null && tempMap1.containsKey('ProductCode') && productCode.contains(String.valueOf(tempMap1.get('ProductCode'))) && (tempMap1.containsKey('childProducts') == false || tempMap1.get('childProducts') == null))
                {
                    tempMap1.put('Quantity', 1.0);
                }
                if(tempMap1.containsKey('childProducts') && tempMap1.get('childProducts') != null)
                {
                    List<Object> childProducts1=(List<Object>)tempMap1.get('childProducts');
                    for(Object obj4:childProducts1)
                    {
                        Map<String,Object> tempMap2=(Map<String,Object>)obj4;
                        if(tempMap2 != null && tempMap2.containsKey('ProductCode') && productCode.contains(String.valueOf(tempMap2.get('ProductCode'))) && (tempMap2.containsKey('childProducts') == false || tempMap2.get('childProducts') == null))
                        {
                            tempMap2.put('Quantity', 1.0);
                        }
                    }
                }
                
                //addToBasketStdMap(obj3,productCode);
            }
        }
        /*if(tempMap != null && tempMap.containsKey('ProductCode') && productCode.contains(String.valueOf(tempMap.get('ProductCode'))) && (tempMap.containsKey('childProducts') == false || tempMap.get('childProducts') == null))
        {
            tempMap.put('Quantity', 1.0);
        } 
        else{
            tempMap.put('Quantity', 0.0);
        }*/
    }
    public static Map<String, Object> addToBasketStd(String ContextKey, String productConfigMap, String catalog)
    {
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        
        String methodName = 'addAfterConfig';
        input.put('apiName','basketOperations');
        input.put('catalogCode', catalog);
        input.put('productConfig', (Map<String, Object>)JSON.deserializeUntyped(productConfigMap));
        input.put('methodName', 'addAfterConfig');
        input.put('requestURL', '/v3/catalogs/'+catalog+'/basket');
        input.put('contextKey', ContextKey);
        //input.put('forceinvalidatecache','true');
        input.put('price', false);

        //remote action invocation
        vlocity_cmt.CpqAppHandler appHandler = new vlocity_cmt.CpqAppHandler();
        if(!Test.isRunningTest()){
            appHandler.invokeMethod(methodName, input, output, options);
        }
        if(output.containskey('nexttransaction'))
        {
            Map<String, Object> next = (Map<String, Object>)output.get('nexttransaction');
            Map<String,Object> rest = (Map<String, Object>)next.get('rest');
            Map<String,Object> params = (Map<String, Object>)rest.get('params');
            String multiTransactionKey = (String)params.get('multiTransactionKey');
            input.put('multiTransactionKey',multiTransactionKey);
            if(!Test.isRunningTest())
            {
                appHandler.invokeMethod(methodName, input, output, options);
            }
        }
        System.debug(JSON.serialize(output));
        return output;
    }
}