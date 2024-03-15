@isTest(SeeAllData=true)
public class Test_TeliaSE_HardwarePricesDisplay {
    
    testMethod public static void test1(){
        vlocity_cmt__ObjectClass__c objClass = new vlocity_cmt__ObjectClass__c();
        objClass.Name = 'Mobile Handset Product Specification';    
        objClass.vlocity_cmt__IsActive__c = True;
        objClass.vlocity_cmt__ObjectApiName__c = 'Product2';
        insert objClass;
        
        List<Product2> prodList = new List<Product2>();
        
        Product2 prod1 = Test_DataFactory.createProducts(1)[0];
        prod1.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        prod1.Name = 'Apple iPhone 11 128GB Svart';
        prod1.ProductCode = '9100224';
        prod1.vlocity_cmt__JSONAttribute__c = '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0Q000004Tqn5QAC","attributeid__c":"a360Q000000HwtJQAS","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_HW_MEMORY","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"HWItemCnetMemory","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a330Q0000001eUeQAI","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"128GB","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"128GB","sequence":3,"id":"9d1c9af2-b3f4-5d03-27ba-6dd0b9ee1917","displayText":"128GB"}],"values":[{"value":"16GB","sequence":1,"id":"87b170d4-d971-9488-463b-fcc79e979f19","displayText":"16GB"},{"value":"32GB","sequence":1,"id":"d8b52e9b-4dd0-3b9e-2e61-1efe3c9ee852","displayText":"32GB"},{"value":"64GB","sequence":2,"id":"94033785-5e3d-1acc-e617-01817dc31009","displayText":"64GB"},{"value":"128GB","sequence":3,"id":"9d1c9af2-b3f4-5d03-27ba-6dd0b9ee1917","displayText":"128GB"},{"value":"256GB","sequence":4,"id":"8e757acc-593f-cf09-b4f7-9d11a8478e39","displayText":"256GB"},{"value":"512GB","sequence":5,"id":"e67d9afd-6f7d-3aea-3e3b-34bb1e238eff","displayText":"512GB"},{"value":"4GB 512MB","sequence":6,"id":"1ad035fd-8464-cdad-6c7c-e9a5caadc429","displayText":"4GB 512MB"},{"value":"MicroSDHC","sequence":7,"id":"812bf2a9-4597-86c4-9444-a36736c7d58a","displayText":"MicroSDHC"},{"value":"MicroSD","sequence":8,"id":"f5cee089-dc3e-9817-b2ee-e6d808d12e7e","displayText":"MicroSD"}]},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0Q000004Tqn5QAC","attributeid__c":"a360Q000000HwtHQAS","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_HW_BRAND","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"HWProductBrand","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a330Q0000001eUhQAI","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"Apple","valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"Apple"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0Q000004Tqn5QAC","attributeid__c":"a360Q000000HwtIQAS","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_HW_COLOR","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"HWItemCnetBrandColor","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a330Q0000001eUdQAI","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"Black","valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"Black"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0Q000004Tqn5QAC","attributeid__c":"a360Q000000HwtKQAS","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_HW_PROMISE_ID","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"HWItemPromisID","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":890207,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a330Q0000001eUfQAI","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"890207","valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"890207"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0Q000004Tqn5QAC","attributeid__c":"a360Q000000HwtLQAS","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_HW_SAP_ID","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"HWSAPID","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":9087146,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a330Q0000001eUiQAI","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"9087146","valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"9087146"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0Q000004Tqn5QAC","attributeid__c":"a360Q000000HwtMQAS","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_HW_SKU_ID","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"HWItemTeliaSku","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a330Q0000001eUgQAI","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text"},"$$AttributeDefinitionEnd$$":null}]}';
        prodList.add(prod1);
        
        Product2 prod2 = Test_DataFactory.createProducts(1)[0];
        prod2.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        prod2.Name = 'Apple iPhone SE 64GB Svart';
        prod2.ProductCode = '9098690';
        prod2.vlocity_cmt__JSONAttribute__c = '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0Q000004TqrKQAS","attributeid__c":"a360Q000000HwtJQAS","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_HW_MEMORY","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"HWItemCnetMemory","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a330Q0000001epQQAQ","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"64GB","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"64GB","sequence":2,"id":"94033785-5e3d-1acc-e617-01817dc31009","displayText":"64GB"}],"values":[{"value":"16GB","sequence":1,"id":"87b170d4-d971-9488-463b-fcc79e979f19","displayText":"16GB"},{"value":"32GB","sequence":1,"id":"d8b52e9b-4dd0-3b9e-2e61-1efe3c9ee852","displayText":"32GB"},{"value":"64GB","sequence":2,"id":"94033785-5e3d-1acc-e617-01817dc31009","displayText":"64GB"},{"value":"128GB","sequence":3,"id":"9d1c9af2-b3f4-5d03-27ba-6dd0b9ee1917","displayText":"128GB"},{"value":"256GB","sequence":4,"id":"8e757acc-593f-cf09-b4f7-9d11a8478e39","displayText":"256GB"},{"value":"512GB","sequence":5,"id":"e67d9afd-6f7d-3aea-3e3b-34bb1e238eff","displayText":"512GB"},{"value":"4GB 512MB","sequence":6,"id":"1ad035fd-8464-cdad-6c7c-e9a5caadc429","displayText":"4GB 512MB"},{"value":"MicroSDHC","sequence":7,"id":"812bf2a9-4597-86c4-9444-a36736c7d58a","displayText":"MicroSDHC"},{"value":"MicroSD","sequence":8,"id":"f5cee089-dc3e-9817-b2ee-e6d808d12e7e","displayText":"MicroSD"}]},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0Q000004TqrKQAS","attributeid__c":"a360Q000000HwtHQAS","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_HW_BRAND","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"HWProductBrand","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a330Q0000001epTQAQ","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"Apple","valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"Apple"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0Q000004TqrKQAS","attributeid__c":"a360Q000000HwtIQAS","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_HW_COLOR","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"HWItemCnetBrandColor","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a330Q0000001epPQAQ","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"Black","valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"Black"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0Q000004TqrKQAS","attributeid__c":"a360Q000000HwtKQAS","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_HW_PROMISE_ID","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"HWItemPromisID","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":900490,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a330Q0000001epRQAQ","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"900490","valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"900490"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0Q000004TqrKQAS","attributeid__c":"a360Q000000HwtLQAS","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_HW_SAP_ID","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"HWSAPID","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":9091556,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a330Q0000001epUQAQ","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"9091556","valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"9091556"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0Q000004TqrKQAS","attributeid__c":"a360Q000000HwtMQAS","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_HW_SKU_ID","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"HWItemTeliaSku","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a330Q0000001epSQAQ","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text"},"$$AttributeDefinitionEnd$$":null}]}';
        prodList.add(prod2);
        
        insert prodList;
        set<String> prodidSet = new set<String>();
        prodidSet.add(prod1.id);
        prodidSet.add(prod2.id);
        
        vlocity_cmt__PricingVariable__c pv = new vlocity_cmt__PricingVariable__c();
        pv = [select id from vlocity_cmt__PricingVariable__c where vlocity_cmt__Code__c = 'OT_STD_PRC'];

        Id stdPriceBookRecId = Test.getStandardPricebookId();
        vlocity_cmt__PriceList__c priceList = new vlocity_cmt__PriceList__c();
        priceList =  [select id from vlocity_cmt__PriceList__c where vlocity_cmt__Code__c = 'PL-SOHO'];
               
        List<vlocity_cmt__PricingElement__c> peList = new List<vlocity_cmt__PricingElement__c>();
        vlocity_cmt__PricingElement__c pe1 = new vlocity_cmt__PricingElement__c();
        pe1.vlocity_cmt__Amount__c = 4396;
        pe1.vlocity_cmt__PricingVariableId__c = pv.id;
        peList.add(pe1);
        vlocity_cmt__PricingElement__c pe2 = new vlocity_cmt__PricingElement__c();
        pe2.vlocity_cmt__Amount__c = 3895;
        pe2.vlocity_cmt__PricingVariableId__c = pv.id;
        peList.add(pe2);
        insert peList;
        
        
        
        List<vlocity_cmt__PriceListEntry__c> pleList = new List<vlocity_cmt__PriceListEntry__c>();
        vlocity_cmt__PriceListEntry__c ple1 = new vlocity_cmt__PriceListEntry__c();
        ple1.vlocity_cmt__PricingElementId__c = pe1.Id;
        ple1.vlocity_cmt__ProductId__c = prod1.id;
        ple1.vlocity_cmt__PriceListId__c = priceList.id;
        pleList.add(ple1);
		
		vlocity_cmt__PriceListEntry__c ple2 = new vlocity_cmt__PriceListEntry__c();
        ple2.vlocity_cmt__PricingElementId__c = pe2.Id;
        ple2.vlocity_cmt__ProductId__c = prod2.id;
        ple2.vlocity_cmt__PriceListId__c = priceList.id;

        pleList.add(ple2);
        
        insert pleList;
        List<vlocity_cmt__PriceListEntry__c> productList = new List<vlocity_cmt__PriceListEntry__c>();       
        String prodId1 = prod1.Id;
        String prodId2 = prod2.Id;
        
        
        productList = [select vlocity_cmt__PricingElementId__r.vlocity_cmt__Amount__c,vlocity_cmt__ProductId__r.vlocity_cmt__JSONAttribute__c, vlocity_cmt__ProductId__c from vlocity_cmt__PriceListEntry__c where vlocity_cmt__ProductId__c in : prodidSet];                
        String JsonResponse = '{'+
		'  \"BindingTime\": {'+
		'    \"Months\": \"24 Månader\"'+
		'  },'+
		'  \"PriceListSetup\": {'+
		'    \"PriceList\": \"Månadsavgift\"'+
		'  },'+
		'  \"NumberOfSelectedSubscription\": 3,'+
		'  \"SubscriptionList\": ['+
		'    {'+
		'      \"Name\": \"Jobbmobil Multi 10 GB\",'+
		'      \"Id\": \"01t1p0000081yNvAAI\",'+
		'      \"Price\": 300'+
		'    },'+
		'    {'+
		'      \"Name\": \"Jobbmobil Multi 30 GB\",'+
		'      \"Id\": \"01t1p0000081yNyAAI\",'+
		'      \"Price\": 550'+
		'    },'+
		'    {'+
		'      \"Name\": \"Jobbmobil Multi 50 GB\",'+
		'      \"Id\": \"01t1p0000081yNxAAI\",'+
		'      \"Price\": 420'+
		'    }'+
		'  ],'+
		'  \"SelectedHardwareProductList\": ['+
		'    {'+
		'      \"Name\": \"Apple iPhone 11 128GB Svart\",'+
		'      \"Id\": \"01u1w000008TlL7AAK\",'+
		'      \"ProductId\":\"'+prodId1+'\",'+
		'      \"Code\": \"9100224\"'+
		'    },'+
		'    {'+
		'      \"Name\": \"Apple iPhone SE 64GB Svart\",'+
		'      \"Id\": \"01u1w000008TlM5AAK\",'+
		'      \"ProductId\": \"'+prodId2+'\",'+
		'      \"Code\": \"9098690\"'+
		'    }'+
		'  ]'+
		'}';
        Map<String, Object> inputMap = (Map<String, Object>)JSON.deserializeUntyped(JsonResponse);
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> optionsMap = new Map<String,Object>();
        
        TeliaSE_HardwarePricesDisplay hpd = new TeliaSE_HardwarePricesDisplay();
        hpd.invokeMethod('displayProd',inputMap,outMap,optionsMap);
        
        Map<String,String> monthMap = new Map<String, String>();
        monthMap.put('Months','36 Månader');
        inputMap.put('BindingTime',monthMap);
        
        Map<String,String> priceListMap = new Map<String, String>();
        priceListMap.put('PriceList','Engångskostnad');        
        inputMap.put('PriceListSetup',priceListMap);
        
        hpd.invokeMethod('displayProd',inputMap,outMap,optionsMap);
    }
    testMethod public static void test2(){
        vlocity_cmt__ObjectClass__c objClass = new vlocity_cmt__ObjectClass__c();
        objClass.Name = 'Mobile Handset Product Specification';    
        objClass.vlocity_cmt__IsActive__c = True;
        objClass.vlocity_cmt__ObjectApiName__c = 'Product2';
        insert objClass;
        
        List<Product2> prodList = new List<Product2>();
        
        Product2 prod1 = Test_DataFactory.createProducts(1)[0];
        prod1.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        prod1.Name = 'Apple iPhone 11 128GB Svart';
        prod1.ProductCode = '9100224';
        prod1.vlocity_cmt__JSONAttribute__c = '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0Q000004Tqn5QAC","attributeid__c":"a360Q000000HwtJQAS","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_HW_MEMORY","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"HWItemCnetMemory","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a330Q0000001eUeQAI","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"128GB","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"128GB","sequence":3,"id":"9d1c9af2-b3f4-5d03-27ba-6dd0b9ee1917","displayText":"128GB"}],"values":[{"value":"16GB","sequence":1,"id":"87b170d4-d971-9488-463b-fcc79e979f19","displayText":"16GB"},{"value":"32GB","sequence":1,"id":"d8b52e9b-4dd0-3b9e-2e61-1efe3c9ee852","displayText":"32GB"},{"value":"64GB","sequence":2,"id":"94033785-5e3d-1acc-e617-01817dc31009","displayText":"64GB"},{"value":"128GB","sequence":3,"id":"9d1c9af2-b3f4-5d03-27ba-6dd0b9ee1917","displayText":"128GB"},{"value":"256GB","sequence":4,"id":"8e757acc-593f-cf09-b4f7-9d11a8478e39","displayText":"256GB"},{"value":"512GB","sequence":5,"id":"e67d9afd-6f7d-3aea-3e3b-34bb1e238eff","displayText":"512GB"},{"value":"4GB 512MB","sequence":6,"id":"1ad035fd-8464-cdad-6c7c-e9a5caadc429","displayText":"4GB 512MB"},{"value":"MicroSDHC","sequence":7,"id":"812bf2a9-4597-86c4-9444-a36736c7d58a","displayText":"MicroSDHC"},{"value":"MicroSD","sequence":8,"id":"f5cee089-dc3e-9817-b2ee-e6d808d12e7e","displayText":"MicroSD"}]},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0Q000004Tqn5QAC","attributeid__c":"a360Q000000HwtHQAS","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_HW_BRAND","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"HWProductBrand","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a330Q0000001eUhQAI","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"Apple","valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"Apple"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0Q000004Tqn5QAC","attributeid__c":"a360Q000000HwtIQAS","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_HW_COLOR","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"HWItemCnetBrandColor","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a330Q0000001eUdQAI","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"Black","valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"Black"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0Q000004Tqn5QAC","attributeid__c":"a360Q000000HwtKQAS","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_HW_PROMISE_ID","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"HWItemPromisID","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":890207,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a330Q0000001eUfQAI","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"890207","valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"890207"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0Q000004Tqn5QAC","attributeid__c":"a360Q000000HwtLQAS","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_HW_SAP_ID","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"HWSAPID","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":9087146,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a330Q0000001eUiQAI","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"9087146","valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"9087146"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0Q000004Tqn5QAC","attributeid__c":"a360Q000000HwtMQAS","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_HW_SKU_ID","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"HWItemTeliaSku","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a330Q0000001eUgQAI","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text"},"$$AttributeDefinitionEnd$$":null}]}';
        prodList.add(prod1);
        
        Product2 prod2 = Test_DataFactory.createProducts(1)[0];
        prod2.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        prod2.Name = 'Apple iPhone SE 64GB Svart';
        prod2.ProductCode = '9098690';
        prod2.vlocity_cmt__JSONAttribute__c = '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0Q000004TqrKQAS","attributeid__c":"a360Q000000HwtJQAS","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_HW_MEMORY","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"HWItemCnetMemory","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a330Q0000001epQQAQ","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"64GB","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"64GB","sequence":2,"id":"94033785-5e3d-1acc-e617-01817dc31009","displayText":"64GB"}],"values":[{"value":"16GB","sequence":1,"id":"87b170d4-d971-9488-463b-fcc79e979f19","displayText":"16GB"},{"value":"32GB","sequence":1,"id":"d8b52e9b-4dd0-3b9e-2e61-1efe3c9ee852","displayText":"32GB"},{"value":"64GB","sequence":2,"id":"94033785-5e3d-1acc-e617-01817dc31009","displayText":"64GB"},{"value":"128GB","sequence":3,"id":"9d1c9af2-b3f4-5d03-27ba-6dd0b9ee1917","displayText":"128GB"},{"value":"256GB","sequence":4,"id":"8e757acc-593f-cf09-b4f7-9d11a8478e39","displayText":"256GB"},{"value":"512GB","sequence":5,"id":"e67d9afd-6f7d-3aea-3e3b-34bb1e238eff","displayText":"512GB"},{"value":"4GB 512MB","sequence":6,"id":"1ad035fd-8464-cdad-6c7c-e9a5caadc429","displayText":"4GB 512MB"},{"value":"MicroSDHC","sequence":7,"id":"812bf2a9-4597-86c4-9444-a36736c7d58a","displayText":"MicroSDHC"},{"value":"MicroSD","sequence":8,"id":"f5cee089-dc3e-9817-b2ee-e6d808d12e7e","displayText":"MicroSD"}]},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0Q000004TqrKQAS","attributeid__c":"a360Q000000HwtHQAS","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_HW_BRAND","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"HWProductBrand","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a330Q0000001epTQAQ","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"Apple","valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"Apple"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0Q000004TqrKQAS","attributeid__c":"a360Q000000HwtIQAS","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_HW_COLOR","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"HWItemCnetBrandColor","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a330Q0000001epPQAQ","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"Black","valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"Black"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0Q000004TqrKQAS","attributeid__c":"a360Q000000HwtKQAS","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_HW_PROMISE_ID","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"HWItemPromisID","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":900490,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a330Q0000001epRQAQ","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"900490","valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"900490"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0Q000004TqrKQAS","attributeid__c":"a360Q000000HwtLQAS","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_HW_SAP_ID","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"HWSAPID","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":9091556,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a330Q0000001epUQAQ","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"9091556","valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"9091556"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0Q000004TqrKQAS","attributeid__c":"a360Q000000HwtMQAS","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_HW_SKU_ID","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"HWItemTeliaSku","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a330Q0000001epSQAQ","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text"},"$$AttributeDefinitionEnd$$":null}]}';
        prodList.add(prod2);
        
        insert prodList;
        set<String> prodidSet = new set<String>();
        prodidSet.add(prod1.id);
        prodidSet.add(prod2.id);
        
        vlocity_cmt__PricingVariable__c pv = new vlocity_cmt__PricingVariable__c();
        pv = [select id from vlocity_cmt__PricingVariable__c where vlocity_cmt__Code__c = 'OT_STD_PRC'];

        Id stdPriceBookRecId = Test.getStandardPricebookId();
        vlocity_cmt__PriceList__c priceList = new vlocity_cmt__PriceList__c();
         priceList =  [select id from vlocity_cmt__PriceList__c where vlocity_cmt__Code__c = 'PL-SOHO'];

        List<vlocity_cmt__PricingElement__c> peList = new List<vlocity_cmt__PricingElement__c>();
        vlocity_cmt__PricingElement__c pe1 = new vlocity_cmt__PricingElement__c();
        pe1.vlocity_cmt__Amount__c = 4396;
        pe1.vlocity_cmt__PricingVariableId__c = pv.id;
        peList.add(pe1);
        vlocity_cmt__PricingElement__c pe2 = new vlocity_cmt__PricingElement__c();
        pe2.vlocity_cmt__Amount__c = 3895;
        pe2.vlocity_cmt__PricingVariableId__c = pv.id;
        peList.add(pe2);
        insert peList;
        
        
        
        List<vlocity_cmt__PriceListEntry__c> pleList = new List<vlocity_cmt__PriceListEntry__c>();
        vlocity_cmt__PriceListEntry__c ple1 = new vlocity_cmt__PriceListEntry__c();
        ple1.vlocity_cmt__PricingElementId__c = pe1.Id;
        ple1.vlocity_cmt__ProductId__c = prod1.id;
        ple1.vlocity_cmt__PriceListId__c = priceList.id;
        pleList.add(ple1);
		
		vlocity_cmt__PriceListEntry__c ple2 = new vlocity_cmt__PriceListEntry__c();
        ple2.vlocity_cmt__PricingElementId__c = pe2.Id;
        ple2.vlocity_cmt__ProductId__c = prod2.id;
        ple2.vlocity_cmt__PriceListId__c = priceList.id;

        pleList.add(ple2);
        
        insert pleList;
        List<vlocity_cmt__PriceListEntry__c> productList = new List<vlocity_cmt__PriceListEntry__c>();       
        String prodId1 = prod1.Id;
        String prodId2 = prod2.Id;
        
        
        productList = [select vlocity_cmt__PricingElementId__r.vlocity_cmt__Amount__c,vlocity_cmt__ProductId__r.vlocity_cmt__JSONAttribute__c, vlocity_cmt__ProductId__c from vlocity_cmt__PriceListEntry__c where vlocity_cmt__ProductId__c in : prodidSet];                
        String JsonResponse = '{'+
		'  \"BindingTime\": {'+
		'    \"Months\": \"24 Månader\"'+
		'  },'+
		'  \"PriceListSetup\": {'+
		'    \"PriceList\": \"Månadsavgift\"'+
		'  },'+
		'  \"NumberOfSelectedSubscription\": 2,'+
		'  \"SubscriptionList\": ['+
		'    {'+
		'      \"Name\": \"Jobbmobil Multi 30 GB\",'+
		'      \"Id\": \"01t1p0000081yNyAAI\",'+
		'      \"Price\": 300'+
		'    },'+
		'    {'+
		'      \"Name\": \"Jobbmobil Multi 50 GB\",'+
		'      \"Id\": \"01t1p0000081yNxAAI\",'+
		'      \"Price\": 550'+
		'    }'+
		'  ],'+
		'  \"SelectedHardwareProductList\": ['+
		'    {'+
		'      \"Name\": \"Apple iPhone 11 128GB Svart\",'+
		'      \"Id\": \"01u1w000008TlL7AAK\",'+
		'      \"ProductId\":\"'+prodId1+'\",'+
		'      \"Code\": \"9100224\"'+
		'    },'+
		'    {'+
		'      \"Name\": \"Apple iPhone SE 64GB Svart\",'+
		'      \"Id\": \"01u1w000008TlM5AAK\",'+
		'      \"ProductId\": \"'+prodId2+'\",'+
		'      \"Code\": \"9098690\"'+
		'    }'+
		'  ]'+
		'}';
        Map<String, Object> inputMap = (Map<String, Object>)JSON.deserializeUntyped(JsonResponse);
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> optionsMap = new Map<String,Object>();
        TeliaSE_HardwarePricesDisplay hpd = new TeliaSE_HardwarePricesDisplay();
       	inputMap.put('NumberOfSelectedSubscription',2);
        hpd.invokeMethod('displayProd',inputMap,outMap,optionsMap);
        Map<String,String> monthMap = new Map<String, String>();
        monthMap.put('Months','36 Månader');
        Map<String,String> priceListMap = new Map<String, String>();
        priceListMap.put('PriceList','Engångskostnad');
        inputMap.put('BindingTime',monthMap);
        inputMap.put('PriceListSetup',priceListMap);
        hpd.invokeMethod('displayProd',inputMap,outMap,optionsMap);
    }
    testMethod public static void test3(){
        vlocity_cmt__ObjectClass__c objClass = new vlocity_cmt__ObjectClass__c();
        objClass.Name = 'Mobile Handset Product Specification';    
        objClass.vlocity_cmt__IsActive__c = True;
        objClass.vlocity_cmt__ObjectApiName__c = 'Product2';
        insert objClass;
        
        List<Product2> prodList = new List<Product2>();
        
        Product2 prod1 = Test_DataFactory.createProducts(1)[0];
        prod1.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        prod1.Name = 'Apple iPhone 11 128GB Svart';
        prod1.ProductCode = '9100224';
        prod1.vlocity_cmt__JSONAttribute__c = '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0Q000004Tqn5QAC","attributeid__c":"a360Q000000HwtJQAS","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_HW_MEMORY","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"HWItemCnetMemory","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a330Q0000001eUeQAI","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"128GB","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"128GB","sequence":3,"id":"9d1c9af2-b3f4-5d03-27ba-6dd0b9ee1917","displayText":"128GB"}],"values":[{"value":"16GB","sequence":1,"id":"87b170d4-d971-9488-463b-fcc79e979f19","displayText":"16GB"},{"value":"32GB","sequence":1,"id":"d8b52e9b-4dd0-3b9e-2e61-1efe3c9ee852","displayText":"32GB"},{"value":"64GB","sequence":2,"id":"94033785-5e3d-1acc-e617-01817dc31009","displayText":"64GB"},{"value":"128GB","sequence":3,"id":"9d1c9af2-b3f4-5d03-27ba-6dd0b9ee1917","displayText":"128GB"},{"value":"256GB","sequence":4,"id":"8e757acc-593f-cf09-b4f7-9d11a8478e39","displayText":"256GB"},{"value":"512GB","sequence":5,"id":"e67d9afd-6f7d-3aea-3e3b-34bb1e238eff","displayText":"512GB"},{"value":"4GB 512MB","sequence":6,"id":"1ad035fd-8464-cdad-6c7c-e9a5caadc429","displayText":"4GB 512MB"},{"value":"MicroSDHC","sequence":7,"id":"812bf2a9-4597-86c4-9444-a36736c7d58a","displayText":"MicroSDHC"},{"value":"MicroSD","sequence":8,"id":"f5cee089-dc3e-9817-b2ee-e6d808d12e7e","displayText":"MicroSD"}]},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0Q000004Tqn5QAC","attributeid__c":"a360Q000000HwtHQAS","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_HW_BRAND","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"HWProductBrand","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a330Q0000001eUhQAI","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"Apple","valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"Apple"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0Q000004Tqn5QAC","attributeid__c":"a360Q000000HwtIQAS","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_HW_COLOR","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"HWItemCnetBrandColor","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a330Q0000001eUdQAI","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"Black","valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"Black"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0Q000004Tqn5QAC","attributeid__c":"a360Q000000HwtKQAS","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_HW_PROMISE_ID","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"HWItemPromisID","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":890207,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a330Q0000001eUfQAI","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"890207","valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"890207"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0Q000004Tqn5QAC","attributeid__c":"a360Q000000HwtLQAS","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_HW_SAP_ID","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"HWSAPID","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":9087146,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a330Q0000001eUiQAI","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"9087146","valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"9087146"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0Q000004Tqn5QAC","attributeid__c":"a360Q000000HwtMQAS","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_HW_SKU_ID","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"HWItemTeliaSku","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a330Q0000001eUgQAI","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text"},"$$AttributeDefinitionEnd$$":null}]}';
        prodList.add(prod1);
        
        Product2 prod2 = Test_DataFactory.createProducts(1)[0];
        prod2.vlocity_cmt__ObjectTypeId__c = objClass.Id;
        prod2.Name = 'Apple iPhone SE 64GB Svart';
        prod2.ProductCode = '9098690';
        prod2.vlocity_cmt__JSONAttribute__c = '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0Q000004TqrKQAS","attributeid__c":"a360Q000000HwtJQAS","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_HW_MEMORY","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"HWItemCnetMemory","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a330Q0000001epQQAQ","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"64GB","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"64GB","sequence":2,"id":"94033785-5e3d-1acc-e617-01817dc31009","displayText":"64GB"}],"values":[{"value":"16GB","sequence":1,"id":"87b170d4-d971-9488-463b-fcc79e979f19","displayText":"16GB"},{"value":"32GB","sequence":1,"id":"d8b52e9b-4dd0-3b9e-2e61-1efe3c9ee852","displayText":"32GB"},{"value":"64GB","sequence":2,"id":"94033785-5e3d-1acc-e617-01817dc31009","displayText":"64GB"},{"value":"128GB","sequence":3,"id":"9d1c9af2-b3f4-5d03-27ba-6dd0b9ee1917","displayText":"128GB"},{"value":"256GB","sequence":4,"id":"8e757acc-593f-cf09-b4f7-9d11a8478e39","displayText":"256GB"},{"value":"512GB","sequence":5,"id":"e67d9afd-6f7d-3aea-3e3b-34bb1e238eff","displayText":"512GB"},{"value":"4GB 512MB","sequence":6,"id":"1ad035fd-8464-cdad-6c7c-e9a5caadc429","displayText":"4GB 512MB"},{"value":"MicroSDHC","sequence":7,"id":"812bf2a9-4597-86c4-9444-a36736c7d58a","displayText":"MicroSDHC"},{"value":"MicroSD","sequence":8,"id":"f5cee089-dc3e-9817-b2ee-e6d808d12e7e","displayText":"MicroSD"}]},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0Q000004TqrKQAS","attributeid__c":"a360Q000000HwtHQAS","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_HW_BRAND","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"HWProductBrand","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a330Q0000001epTQAQ","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"Apple","valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"Apple"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0Q000004TqrKQAS","attributeid__c":"a360Q000000HwtIQAS","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_HW_COLOR","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"HWItemCnetBrandColor","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a330Q0000001epPQAQ","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"Black","valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"Black"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0Q000004TqrKQAS","attributeid__c":"a360Q000000HwtKQAS","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_HW_PROMISE_ID","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"HWItemPromisID","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":900490,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a330Q0000001epRQAQ","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"900490","valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"900490"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0Q000004TqrKQAS","attributeid__c":"a360Q000000HwtLQAS","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_HW_SAP_ID","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"HWSAPID","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":9091556,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a330Q0000001epUQAQ","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"9091556","valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"9091556"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0Q000004TqrKQAS","attributeid__c":"a360Q000000HwtMQAS","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_HW_SKU_ID","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"HWItemTeliaSku","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a330Q0000001epSQAQ","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text"},"$$AttributeDefinitionEnd$$":null}]}';
        prodList.add(prod2);
        
        insert prodList;
        set<String> prodidSet = new set<String>();
        prodidSet.add(prod1.id);
        prodidSet.add(prod2.id);
        
        vlocity_cmt__PricingVariable__c pv = new vlocity_cmt__PricingVariable__c();
        pv = [select id from vlocity_cmt__PricingVariable__c where vlocity_cmt__Code__c = 'OT_STD_PRC'];

        Id stdPriceBookRecId = Test.getStandardPricebookId();
        vlocity_cmt__PriceList__c priceList = new vlocity_cmt__PriceList__c();
        priceList =  [select id from vlocity_cmt__PriceList__c where vlocity_cmt__Code__c = 'PL-SOHO'];
       
        
        List<vlocity_cmt__PricingElement__c> peList = new List<vlocity_cmt__PricingElement__c>();
        vlocity_cmt__PricingElement__c pe1 = new vlocity_cmt__PricingElement__c();
        pe1.vlocity_cmt__Amount__c = 4396;
        pe1.vlocity_cmt__PricingVariableId__c = pv.id;
        peList.add(pe1);
        vlocity_cmt__PricingElement__c pe2 = new vlocity_cmt__PricingElement__c();
        pe2.vlocity_cmt__Amount__c = 3895;
        pe2.vlocity_cmt__PricingVariableId__c = pv.id;
        peList.add(pe2);
        insert peList;
        
        
        
        List<vlocity_cmt__PriceListEntry__c> pleList = new List<vlocity_cmt__PriceListEntry__c>();
        vlocity_cmt__PriceListEntry__c ple1 = new vlocity_cmt__PriceListEntry__c();
        ple1.vlocity_cmt__PricingElementId__c = pe1.Id;
        ple1.vlocity_cmt__ProductId__c = prod1.id;
        ple1.vlocity_cmt__PriceListId__c = priceList.id;
        pleList.add(ple1);
		
		vlocity_cmt__PriceListEntry__c ple2 = new vlocity_cmt__PriceListEntry__c();
        ple2.vlocity_cmt__PricingElementId__c = pe2.Id;
        ple2.vlocity_cmt__ProductId__c = prod2.id;
        ple2.vlocity_cmt__PriceListId__c = priceList.id;

        pleList.add(ple2);
        
        insert pleList;
        List<vlocity_cmt__PriceListEntry__c> productList = new List<vlocity_cmt__PriceListEntry__c>();       
        String prodId1 = prod1.Id;
        String prodId2 = prod2.Id;
        
        
        productList = [select vlocity_cmt__PricingElementId__r.vlocity_cmt__Amount__c,vlocity_cmt__ProductId__r.vlocity_cmt__JSONAttribute__c, vlocity_cmt__ProductId__c from vlocity_cmt__PriceListEntry__c where vlocity_cmt__ProductId__c in : prodidSet];                
        String JsonResponse = '{'+
		'  \"BindingTime\": {'+
		'    \"Months\": \"24 Månader\"'+
		'  },'+
		'  \"PriceListSetup\": {'+
		'    \"PriceList\": \"Engångskostnad\"'+
		'  },'+
		'  \"NumberOfSelectedSubscription\": 1,'+
		'  \"SubscriptionList\": ['+
		'    {'+
		'      \"Name\": \"Jobbmobil Multi 50 GB\",'+
		'      \"Id\": \"01t1p0000081yNxAAI\",'+
		'      \"Price\": 300'+
		'    }'+
		'  ],'+
		'  \"SelectedHardwareProductList\": ['+
		'    {'+
		'      \"Name\": \"Apple iPhone SE 64GB Svart\",'+
		'      \"Id\": \"01u1w000008TlM5AAK\",'+
		'      \"ProductId\": \"'+prodId2+'\",'+
		'      \"Code\": \"9098690\"'+
		'    }'+
		'  ]'+
		'}';
        
        Map<String, Object> inputMap = (Map<String, Object>)JSON.deserializeUntyped(JsonResponse);
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> optionsMap = new Map<String,Object>();

        TeliaSE_HardwarePricesDisplay hpd = new TeliaSE_HardwarePricesDisplay();
        hpd.invokeMethod('displayProd',inputMap,outMap,optionsMap);
        
        Map<String,String> monthMap = new Map<String, String>();
        monthMap.put('Months','36 Månader');
        inputMap.put('BindingTime',monthMap);
        
        Map<String,String> priceListMap = new Map<String, String>();
        priceListMap.put('PriceList','Månadsavgift');        
        inputMap.put('PriceListSetup',priceListMap);
        
        hpd.invokeMethod('displayProd',inputMap,outMap,optionsMap);
    }
}