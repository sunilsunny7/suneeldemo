global class JsonPayloadUpdate implements Database.Batchable<String>, Database.Stateful, Database.AllowsCallouts
{
    private Map<string, string> productListPhim;
    private List<String> productList;
    private List<String> phimlist;
    private String Catalog;
    private boolean phim=false;
    //private List<Product2> OfferList;
    global JsonPayloadUpdate(List<String> productList, String Catalog)
    {
        this.productList = productList;
        this.Catalog = Catalog;
    }
    global JsonPayloadUpdate(Map<string, string> productListHW,boolean PHIM)
    {
        this.productListPhim = productListHW;
        this.phim = PHIM;
        list<string> phimproductList = new list<string>();
        
        for(string ob: productListPhim.keySet()){
            phimproductList.add(string.valueOf(ob));
        }
        this.phimlist = phimproductList;
        //this.OfferList = OfferList;
    }
    global Iterable<String> start(Database.BatchableContext BC)
    {
        if(phim==true){
            //if(phimlist != null && phimlist.size()>0){
            return phimlist;
            //}
        }
        else{
            return productList;
        }
    }
    global void execute(Database.BatchableContext BC,List<String> productList)
    {
        //for(string ofr: productList){
        String productCode = String.valueOf(productList[0]);
        Map<String, Object> input = new Map<String, Object>();
        String output;
        Map<String, Object> option = new Map<String, Object>();
        Map<String, Object> output2 = new Map<String, Object>();
        input.put('apiName','getOfferDetails');
        if(phim)
        {
            input.put('catalogCode',String.valueOf(productListPhim.get(productCode)));
            input.put('requestURL', '/v3/catalogs/'+String.valueOf(productListPhim.get(productCode))+'/offers/'+productCode);
        }else
        {
            input.put('catalogCode',Catalog);
            input.put('requestURL', '/v3/catalogs/'+Catalog+'/offers/'+productCode);
        }
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
            output = '{"contextKey":"99914b932bd37a50b983c5e7c90ae93b","result":{"offerDetails":{"offer":{"priceResult":[{"adjustments":[],"overrides":[],"chargeamount":0.00000,"baseamount":0.00000,"Amount__c":0.00000,"IsVirtualPrice__c":false,"IsBasePrice__c":false,"effectiveuntildatespec":null,"effectivefromdatespec":null,"SubType__c":"Standard","Type__c":"Price","RecurringFrequency__c":"Monthly","ChargeType__c":"Recurring","DisplayText__c":"SEK 0.00","pleEffectiveFrom":"2020-08-04T18:30:00.000Z"}],"addtocart":{"rest":{"params":{"context":"{}","basketAction":"AddWithNoConfig","offer":"MOB_TOTAL_JOBBMOBIL_V2"},"link":"v3/catalogs/SUBSCRIPTIONS/basket","method":"POST"}},"vlocity_cmt__SpecificationType__c":"Offer","Name":"Jobbmobil erbjudande","ProductCode":"MOB_TOTAL_JOBBMOBIL_V2","Product2Id":"01t08000009u5oTAAQ","PricebookEntryId":"01u0800000ZVs9RAAT","Quantity":1,"minQuantity":0,"maxQuantity":99999,"groupMinQuantity":0,"groupMaxQuantity":99999,"productHierarchyPath":"01t08000009u5oTAAQ","lineNumber":"0001","Attachments":null,"AttributeCategory":{"totalSize":1,"messages":[],"records":[{"messages":[],"displaySequence":10,"Code__c":"ATT_CODE_TELIAMOBAGGR","Name":"Attributes","id":"a353O0000001a3SQAQ","productAttributes":{"totalSize":1,"messages":[],"records":[{"messages":[],"code":"Relation_Id","dataType":"text","inputType":"text","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a363O0000001KhOQAU","label":"Relation_Id","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"readonly":false,"disabled":false}],"userValues":null}]}}]},"Id":"01t08000009u5oTAAQ","Description":null,"vlocity_cmt__SellingStartDate__c":"2020-08-03T22:00:00.000Z","vlocity_cmt__SellingEndDate__c":null,"vlocity_cmt__EndOfLifeDate__c":null,"vlocity_cmt__IsOrderable__c":true,"IsActive":true,"AO__c":null,"TeliaSE_Product_Service_Code__c":null,"Ordering_Flag__c":null,"Ordering_System__c":null,"C2BC_Category__c":"subscriptionbundle","C2BC_Subcategory__c":"mobilevoicesubscription","CID__c":null,"TeliaSE_Product_Category__c":null,"TeliaSE_Subscription_Type__c":null,"Downstream_CategoryData__c":null,"MConline_Action_Code__c":null,"MC_Product_Name_Eng__c":"Jobbmobil offering","Feature_Id__c":null,"childProducts":[{"priceResult":[{"adjustments":[],"overrides":[],"chargeamount":0.00000,"baseamount":0.00000,"Amount__c":0.00000,"IsVirtualPrice__c":false,"IsBasePrice__c":false,"effectiveuntildatespec":null,"effectivefromdatespec":null,"SubType__c":"Standard","Type__c":"Price","RecurringFrequency__c":"Monthly","ChargeType__c":"Recurring","DisplayText__c":"SEK 0.00","pleEffectiveFrom":"2020-08-04T18:30:00.000Z"}],"vlocity_cmt__SpecificationType__c":"Product","Name":"Jobbmobil","ProductCode":"MOB_TOTAL_Bundle_2020_04","Product2Id":"01t08000009u5n5AAA","PricebookEntryId":"01u0800000ZVs7zAAD","Quantity":1,"minQuantity":1,"maxQuantity":1,"groupMinQuantity":0,"groupMaxQuantity":1,"productHierarchyPath":"01t08000009u5oTAAQ<01t08000009u5n5AAA","lineNumber":"0001.0001","Attachments":null,"Id":"01t08000009u5n5AAA","Description":"Ring och jobbsurfa säkert i Sveriges bästa mobilnät.","vlocity_cmt__SellingStartDate__c":"2020-07-30T22:00:00.000Z","vlocity_cmt__SellingEndDate__c":null,"vlocity_cmt__EndOfLifeDate__c":null,"vlocity_cmt__IsOrderable__c":false,"IsActive":true,"AO__c":null,"TeliaSE_Product_Service_Code__c":null,"Ordering_Flag__c":"Salesflow","Ordering_System__c":null,"C2BC_Category__c":"subscriptionbundle","C2BC_Subcategory__c":"mobilevoicesubscription","CID__c":null,"TeliaSE_Product_Category__c":null,"TeliaSE_Subscription_Type__c":null,"Downstream_CategoryData__c":null,"MConline_Action_Code__c":null,"MC_Product_Name_Eng__c":null,"Feature_Id__c":null,"childProducts":[{"priceResult":[{"adjustments":[],"overrides":[],"chargeamount":599.00000,"baseamount":599.00000,"Amount__c":599.00000,"IsVirtualPrice__c":false,"IsBasePrice__c":true,"effectiveuntildatespec":null,"effectivefromdatespec":null,"SubType__c":"Standard","Type__c":"Price","RecurringFrequency__c":"Monthly","ChargeType__c":"Recurring","DisplayText__c":"599 SEK","pleEffectiveFrom":"2021-08-31T18:30:00.000Z"}],"vlocity_cmt__SpecificationType__c":"Product","Name":"Jobbmobil Obegränsad Plus","ProductCode":"MOB_MULTI_OBEGRANSADPLUS_V3","Product2Id":"01t3O000005O70iQAC","PricebookEntryId":"01u3O00002QBBLGQA5","Quantity":0,"minQuantity":0,"maxQuantity":1,"groupMinQuantity":0,"groupMaxQuantity":99999,"productHierarchyPath":"01t08000009u5oTAAQ<01t08000009u5n5AAA<01t3O000005O70iQAC","lineNumber":"0001.0001.0001","Attachments":null,"AttributeCategory":{"totalSize":1,"messages":[],"records":[{"messages":[],"displaySequence":10,"Code__c":"ATT_CODE_TELIAMOBAGGR","Name":"Attributes","id":"a353O0000001a3SQAQ","productAttributes":{"totalSize":10,"messages":[],"records":[{"messages":[],"code":"EXT_REF_ONLINE","dataType":"text","inputType":"text","cacheable":true,"multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a363O0000001FArQAM","label":"External_reference","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"readonly":false,"disabled":false}],"userValues":null},{"messages":[],"code":"Email","dataType":"text","inputType":"text","cacheable":true,"multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a363O0000001FAtQAM","label":"Email","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"readonly":false,"disabled":false}],"userValues":null},{"messages":[],"code":"ICC_number","dataType":"text","inputType":"text","cacheable":true,"multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a363O0000001FAuQAM","label":"ICC_number","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"readonly":false,"disabled":false}],"userValues":null},{"messages":[],"code":"MSISDN","dataType":"text","inputType":"text","cacheable":true,"multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a363O0000001FAwQAM","label":"MSISDN","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"readonly":false,"disabled":false}],"userValues":null},{"messages":[],"code":"NumberReservationRequired","dataType":"text","inputType":"dropdown","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a363O0000001PI8QAM","label":"NumberReservationRequired","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"id":"d6323397-e8c4-7a76-01cf-f950fe20cb68","name":"d6323397-e8c4-7a76-01cf-f950fe20cb68","label":"Yes","readonly":false,"disabled":false,"value":"Yes","defaultSelected":true,"displaySequence":1},{"id":"e2126f73-7ca6-4553-c2e2-a3d8b9307cc0","name":"e2126f73-7ca6-4553-c2e2-a3d8b9307cc0","label":"No","readonly":false,"disabled":false,"value":"No","defaultSelected":false,"displaySequence":2}],"userValues":"Yes"},{"messages":[],"code":"SIM_Format","dataType":"text","inputType":"dropdown","cacheable":true,"multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a363O0000001FAxQAM","label":"SIM_Format","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"id":"0c5489fc-04ff-b0d2-6f6e-f5609ecb5334","name":"0c5489fc-04ff-b0d2-6f6e-f5609ecb5334","label":"esim","readonly":false,"disabled":false,"value":"esim","defaultSelected":false,"displaySequence":1},{"id":"488a6e15-e683-d5fd-c084-a6ca8c2a25ba","name":"488a6e15-e683-d5fd-c084-a6ca8c2a25ba","label":"simcard","readonly":false,"disabled":false,"value":"simcard","defaultSelected":true,"displaySequence":2},{"id":"e3e55489-f2d3-4238-8852-f05ec8c99b04","name":"e3e55489-f2d3-4238-8852-f05ec8c99b04","label":"keep","readonly":false,"disabled":false,"value":"keep","defaultSelected":false,"displaySequence":3}],"userValues":"simcard"},{"messages":[],"code":"TELIA_COMM_PERIOD","dataType":"text","inputType":"dropdown","cacheable":true,"multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a363O0000001FB0QAM","label":"Commitment_period","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"id":"e7e1d1c5-bb4e-0ca1-bd82-5f9b77216274","name":"e7e1d1c5-bb4e-0ca1-bd82-5f9b77216274","label":"0","readonly":false,"disabled":false,"value":"0","defaultSelected":true,"displaySequence":1},{"id":"2a44f701-88d4-3537-1a61-7a6a18991fe2","name":"2a44f701-88d4-3537-1a61-7a6a18991fe2","label":"24","readonly":false,"disabled":false,"value":"24","defaultSelected":false,"displaySequence":2},{"id":"f2b151d6-7c45-5a73-9d42-f32e81785d14","name":"f2b151d6-7c45-5a73-9d42-f32e81785d14","label":"36","readonly":false,"disabled":false,"value":"36","defaultSelected":false,"displaySequence":3}],"userValues":"0"},{"messages":[],"code":"User_name","dataType":"text","inputType":"text","cacheable":true,"multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a363O0000001FB6QAM","label":"User_name","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"readonly":false,"disabled":false}],"userValues":null},{"messages":[],"code":"e-SIM_Method","dataType":"text","inputType":"dropdown","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a363O0000001FB9QAM","label":"e-SIM_Method","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"id":"8a7f3b12-cf4b-413c-9ac3-bc851a3651e0","name":"8a7f3b12-cf4b-413c-9ac3-bc851a3651e0","label":"email","readonly":false,"disabled":false,"value":"email","defaultSelected":true,"displaySequence":1}],"userValues":"email"},{"messages":[],"code":"subAgreementId","dataType":"text","inputType":"text","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a363O0000001liEQAQ","label":"subAgreementId","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"readonly":false,"disabled":false}],"userValues":null}]}}]},"Id":"01t3O000005O70iQAC","Description":null,"vlocity_cmt__SellingStartDate__c":"2021-10-14T22:00:00.000Z","vlocity_cmt__SellingEndDate__c":null,"vlocity_cmt__EndOfLifeDate__c":null,"vlocity_cmt__IsOrderable__c":false,"IsActive":true,"AO__c":"No","TeliaSE_Product_Service_Code__c":null,"Ordering_Flag__c":"Salesflow","Ordering_System__c":"GSM-AHS","C2BC_Category__c":"mobilevoicesubscription","C2BC_Subcategory__c":"voice","CID__c":null,"TeliaSE_Product_Category__c":"F1GRUNDAVG","TeliaSE_Subscription_Type__c":"KM","Downstream_CategoryData__c":"F1GRUNDAVG","MConline_Action_Code__c":null,"MC_Product_Name_Eng__c":null,"Feature_Id__c":null}]}],"offerType":"Product","vlocity_cmt__InCartQuantityMap__c":{"01t08000009u5n5AAA":1,"01t3O000006129mQAA":1,"01t08000009u5oqAAA":1,"01t08000009u5oWAAQ":1,"01t3O00000612ABQAY":1,"01t3O000006129wQAA":1}}}},"errorCode":"INVOKE-200","error":"OK"}';
                getOfferDetailsResponse = (Map<String,Object>)JSON.deserializeUntyped(output);
        }
        if(getOfferDetailsResponse != null)
        {
            Map<String, Object> result = (Map<String, Object>)getOfferDetailsResponse.get('result');
            Map<String, Object> offerDetails = (Map<String, Object>)result.get('offerDetails');
            Map<String, Object> offer = (Map<String, Object>)offerDetails.get('offer');
            if(offer != null && phim==false)
            {
                mapQuantity(offer);
            }
            Map<String, Object> finalResult = (Map<String, Object>)result;
            List<WarmupCacheConfiguration__c> warmupList = new List<WarmupCacheConfiguration__c>();
            Map<Integer, String> str = new Map<Integer, String>();
            Integer i=0;
            if(finalResult != null)
            {
                String jsonPayload = JSON.serialize(finalResult);
                String jsonload = jsonPayload;
                if(jsonload.length() >= Schema.SObjectType.WarmupCacheConfiguration__c.fields.JSONPayload__c.getLength())
                {
                    do
                    {
                        i++;
                        String str1 = String.valueOf(jsonload.subString(0 ,Integer.valueOf(Schema.SObjectType.WarmupCacheConfiguration__c.fields.JSONPayload__c.getLength())));
                        str.put(i, str1);
                        Integer j = Integer.valueOf(Schema.SObjectType.WarmupCacheConfiguration__c.fields.JSONPayload__c.getLength());
                        jsonload = jsonload.subString(j, Integer.valueOf(jsonPayload.length()));
                    }while (jsonload.length() > Schema.SObjectType.WarmupCacheConfiguration__c.fields.JSONPayload__c.getLength());
                    str.put(++i, jsonload);
                    System.debug(String.valueOf(str));
                    if(str != null)
                    {
                        for(Integer inte: str.KeySet())
                        {
                            WarmupCacheConfiguration__c warmup = new WarmupCacheConfiguration__c();
                            if(phim){
                                warmup.CatalogCode__c = String.valueOf(productListPhim.get(productCode));   
                            }
                            else
                                warmup.CatalogCode__c = Catalog;
                            warmup.ProductCode__c = productCode;
                            warmup.JSONPayload__c = String.valueOf(str.get(inte));
                            warmup.OverFlowSequence__c = inte;
                            warmupList.add(warmup);
                        }
                    }
                }else{
                    WarmupCacheConfiguration__c warmup1 = new WarmupCacheConfiguration__c();
                    if(phim){
                        warmup1.CatalogCode__c = String.valueOf(productListPhim.get(productCode));  
                    }
                    else
                        warmup1.CatalogCode__c = Catalog;
                    warmup1.ProductCode__c = productCode;
                    warmup1.JSONPayload__c = jsonPayload;
                    warmup1.OverFlowSequence__c = 1;
                    warmupList.add(warmup1);
                }
            }
            if(warmupList != null && warmupList.size()>0)
            {
                insert warmupList;
            }
        }
    //}
    }
    global void finish(Database.BatchableContext BC)
    {
        if(phim==true){
            if(!Test.isRunningTest()){
             for(string prodCode: productListPhim.keySet()){
                if(!Test.isRunningTest()){
                  Database.executeBatch(new WarmupDCApiCacheBatch_V3(productListPhim.get(prodCode),prodCode),1);
             }    
            }
            }
        }
        else
            System.debug('Success');
    }
    
    public static void mapQuantity(Object obj)
    {
        Map<String, Object> tempMap = (Map<String, Object>)obj;
        if(tempMap != null)
        {
            if(tempMap.containsKey('childProducts'))
            {
                List<Object> childProducts1 = (List<Object>)tempMap.get('childProducts');
                for(Object obj1: childProducts1)
                {
                    mapQuantity(obj1);
                }
            }
            if(tempMap.containsKey('childProducts') == false)
            {
                tempMap.put('Quantity', String.valueOf('%Q_'+String.valueOf(tempMap.get('ProductCode')).replace('.', '_')+'%'));
            }
        }
    }
}