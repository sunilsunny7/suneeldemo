@isTest
public class MCOnline_GetAgreementOffers_V4Test {
    
    private static String namespace = 'vlocity_cmt__';
    public static vlocity_cmt__CalculationMatrixVersion__c version;
    public static vlocity_cmt__CalculationMatrix__c parent;
    public static List<vlocity_cmt__CalculationMatrixRow__c> lineItems;
    private static Id orderId;
    private static boolean flag;  //used to upload matrix row data for test1 or test2
    private static Id quoteId, quoteId2; 
    static TeliaSERecordTypeSetting__mdt TeliaSERecordTypeSetting;
    
    @testSetup
    static void initTestData() {
        User salesManager;
        salesManager = Test_DataFactory.createAdminUser();
        salesManager.ForecastEnabled = true;
        salesManager.Bypass_VR__c = true;
        insert salesManager;
        
        Account acc = new Account();
        acc.RecordTypeId = '012240000008l9YAAQ';
        acc.Name='TestAccount';
        acc.TSCID__c = 'TSCID_1234';
        Insert acc;
        
        Account acc1 = new Account();
        acc1.RecordTypeId = '012240000008l9YAAQ';
        acc1.Name='TestAccount';
        acc1.TSCID__c = 'TSCID_5';
        Insert acc1;
        RecordType rt1 = [Select id,name, DeveloperName from RecordType where Name='Ramavtal'];
        Contract contr=new Contract();
        contr.Name='Test';
        contr.AccountId=acc.id;
        contr.Status='Draft';
        contr.RecordTypeId = rt1.id;
        contr.Solution_Area__c='Vxl';
        contr.StartDate=Date.today();
        contr.ContractTerm=24;
        insert contr;
        contr.Status='Active';
        System.runAs(salesManager){update contr;}
        Utilizer_Contract_Relationship__c util = new Utilizer_Contract_Relationship__c();
        util.AccountId__c = acc.id;
        util.ContractNumber__c =contr.id;
        util.Org_Number__c = '5673289783';
        util.Status__c = 'Aktiv';
        util.Utilizer_Role__c = 'Utilizer';
        util.Utilizer_Type__c = '';
        insert util;
        
        vlocity_cmt__Catalog__c ct = new vlocity_cmt__Catalog__c();
        ct.Name = 'Test Name';
        ct.vlocity_cmt__IsActive__c=true;
        insert ct;
        
        vlocity_cmt__CatalogProductRelationship__c cpr=new vlocity_cmt__CatalogProductRelationship__c();
        cpr.vlocity_cmt__IsActive__c=true;
        cpr.vlocity_cmt__CatalogId__c = ct.Id;
        cpr.Name = 'NameInCPR';
        insert cpr;   
        
        vlocity_cmt__CatalogProductRelationship__c cprTwo = new vlocity_cmt__CatalogProductRelationship__c();
        cprTwo.vlocity_cmt__IsActive__c=true;
        cprTwo.vlocity_cmt__CatalogId__c = ct.Id;
        cprTwo.Name = 'NameInCPRTwo';
        insert cprTwo;
        
        
        Product2 prod1 = new Product2 (Name='Office 365', ProductCode = 'C-OFFICE-365',C2BC_Category__c = 'offerbundle',Family ='Online Order',
                                       vlocity_cmt__JSONAttribute__c='{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1l000000pixdAAA","attributeid__c":"a2s1w00000005t7AAA","attributecategoryid__c":"a2r1w0000008xvuAAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Telia Mobile Agreements","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a2p1l0000008REzAAM","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Unspecified","valuedatatype__c":"Picklist","valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"Unspecified","id":10,"displayText":"Unspecified"}],"values":[{"value":"Unspecified","id":10,"displayText":"Unspecified"},{"value":"24","id":20,"displayText":"24 months"},{"value":"36","id":30,"displayText":"36 months"}]},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1l000000pixdAAA","attributeid__c":"a2s1w00000005tMAAQ","attributecategoryid__c":"a2r1w0000008xvuAAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Telia Mobile Agreements","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a2p1l0000008RF0AAM","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Number"},"$$AttributeDefinitionEnd$$":null}]}');
        insert prod1;
        
        vlocity_cmt__CatalogProductRelationship__c cprt = new vlocity_cmt__CatalogProductRelationship__c();
        cprt.vlocity_cmt__IsActive__c=true;
        cprt.vlocity_cmt__CatalogId__c = ct.Id;
        cprt.Name = 'C-OFFICE-365';
        cprt.vlocity_cmt__Product2Id__c = prod1.Id;
        insert cprt;
        
        vlocity_cmt__ContractLineItem__c cli=new vlocity_cmt__ContractLineItem__c();
        cli.name='Office';
        cli.vlocity_cmt__product2id__c=prod1.id;
        cli.vlocity_cmt__ContractId__c=contr.id;
        cli.TeliaSE_MC_Customer_Requested_Percentage__c=5;
        cli.TeliaSE_End_Date__C = Date.today().addDays(10);
        cli.TeliaSE_ProductHierarchy__c='ABC';
        cli.TeliasSETargetPercentage__c=5;
        cli.TeliaSE_Product_Object_Type__c = 'Mobile Offer Specification';
        cli.vlocity_cmt__RecurringCharge__c=200;
        insert cli;
        
        Order order = new Order();
        order.EffectiveDate = Date.today();
        order.Status = 'Draft';
        order.AccountId = acc.Id;  
        order.ContractId = contr.Id;
        insert order;
        
        MCOnline_ParentBasket__c pbasket = new MCOnline_ParentBasket__c();
        pbasket.TSCID__c = 'TSCID_1234';
        pbasket.BasketStatus__c = 'Success';
        pbasket.Order__c = order.Id;
        //pbasket.CreatedDate = Date.today();
        pbasket.AgreementId__c = contr.Id;
        pbasket.Admin__c = UserInfo.getUserId();
        pbasket.Account__c = acc.Id;        
        pbasket.UpdateOrderRequest__c = '';
        pbasket.CheckoutResponse__c = '';
        insert pbasket;
        
        MCOnline_Basket__c basket = new MCOnline_Basket__c();
        basket.MCOnline_Admin__c = UserInfo.getUserId();
        //basket.CreatedDate = Date.today();
        basket.MCOnline_Order__c = order.Id;
        basket.MCOnline_Basket_Key__c = 'c949525b7f60a2d109c75305a525867c';
        basket.MCOnline_OfferCode__c = 'MOB_MULTI_BB_V2';
        basket.TSCID__c = 'TSCID_1234';
        basket.MCOnline_Catalog__c = 'SUBSCRIPTIONS';
        basket.MCOnline_AttributeJSON__c = '{"products":[{"attributes":{"userName":null,"SIM_Format":"esim","MSISDN":"1017635812","ICCNumber":"89460110191104000000","externalReference":"ERO","email":"vilbertas.soraka@teliacompany.com","eSIM_Method":"email","commitmentPeriod":"12"},"displayText":"SEK 649","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"429","baseAmount":"649","chargeAmount":"649","name":"JobbMobil 120 GB","lineNumber":"0001.0001.0002","downstream_CategoryData":"F1GRUNDAVG","TeliaSE_Subscription_Type":"97","TeliaSE_Product_Category":"F1GRUNDAVG","CID":null,"C2BC_Subcategory":"voice","C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":null,"AO":null,"productCode":"MOB_MULTI_120_V2"},{"displayText":"SEK 29.00","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"29","baseAmount":"29","chargeAmount":"29","name":"5G","lineNumber":"0001.0002.0001","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":"network1","AO":"Yes","productCode":"MOB_5G"},{"displayText":"SEK 0","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"0","baseAmount":"0","chargeAmount":"0","name":"Spärr 118","lineNumber":"0001.0002.0003","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":"071-1","AO":"Yes","productCode":"MOB_BARRING_COLLECT_CALL_118"},{"displayText":"SEK 0","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"0","baseAmount":"0","chargeAmount":"0","name":"MMS","lineNumber":"0001.0002.0002","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"ManageFlow","TeliaSE_Product_Service_Code":"MMS","AO":null,"productCode":"MOB_MMS"},{"attributes":{"SIM_Format":"esim","MSISDN":"1814377554","ICCNumber":"89460110191104000000","email":"vilbertas.soraka@teliacompany.com","eSIM_Method":"email","commitmentPeriod":"12"},"displayText":"SEK 49","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"29","baseAmount":"49","chargeAmount":"49","name":"Jobbmobil datasim","lineNumber":"0001.0004.0001","downstream_CategoryData":"F1GRUNDAVG","TeliaSE_Subscription_Type":"KÄ-KÖ","TeliaSE_Product_Category":"F1GRUNDAVG","CID":null,"C2BC_Subcategory":"datasim","C2BC_Category":"Mobilebroadbandsubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":null,"AO":"No","productCode":"MOB_MULTI_DATASIM_OFFER"}]}';
        basket.MCOnline_Contract__c = contr.Id;
        basket.Account__c = acc.Id;
        basket.MCOnline_ParentBasket__c = pbasket.Id;
        insert basket;
        
        Product2 prod1child = new Product2 (Name='Office 366', ProductCode = 'C-OFFICE-366',C2BC_Category__c = 'offerbundle',Family ='Online Order',
                                            vlocity_cmt__JSONAttribute__c='{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1l000000pixdAAA","attributeid__c":"a2s1w00000005t7AAA","attributecategoryid__c":"a2r1w0000008xvuAAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Telia Mobile Agreements","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a2p1l0000008REzAAM","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Unspecified","valuedatatype__c":"Picklist","valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"Unspecified","id":10,"displayText":"Unspecified"}],"values":[{"value":"Unspecified","id":10,"displayText":"Unspecified"},{"value":"24","id":20,"displayText":"24 months"},{"value":"36","id":30,"displayText":"36 months"}]},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1l000000pixdAAA","attributeid__c":"a2s1w00000005tMAAQ","attributecategoryid__c":"a2r1w0000008xvuAAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Telia Mobile Agreements","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a2p1l0000008RF0AAM","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Number"},"$$AttributeDefinitionEnd$$":null}]}');
        insert prod1child;
        vlocity_cmt__ProductChildItem__c pct= new vlocity_cmt__ProductChildItem__c();
        pct.vlocity_cmt__ParentProductId__c =prod1.id;
        pct.vlocity_cmt__ChildProductId__c = prod1child.id;
        pct.vlocity_cmt__ChildLineNumber__c='123';
        insert pct;
        Product2 prod1child1 = new Product2 (Name='Office 3665', ProductCode = 'C-OFFICE-3665',C2BC_Category__c = 'offerbundle',Family ='Online Order',
                                            vlocity_cmt__JSONAttribute__c='{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1l000000pixdAAA","attributeid__c":"a2s1w00000005t7AAA","attributecategoryid__c":"a2r1w0000008xvuAAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Telia Mobile Agreements","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a2p1l0000008REzAAM","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Unspecified","valuedatatype__c":"Picklist","valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"Unspecified","id":10,"displayText":"Unspecified"}],"values":[{"value":"Unspecified","id":10,"displayText":"Unspecified"},{"value":"24","id":20,"displayText":"24 months"},{"value":"36","id":30,"displayText":"36 months"}]},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1l000000pixdAAA","attributeid__c":"a2s1w00000005tMAAQ","attributecategoryid__c":"a2r1w0000008xvuAAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Telia Mobile Agreements","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a2p1l0000008RF0AAM","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Number"},"$$AttributeDefinitionEnd$$":null}]}');

        vlocity_cmt__ProductChildItem__c pct1= new vlocity_cmt__ProductChildItem__c();
        pct1.vlocity_cmt__ParentProductId__c =prod1.id;
        pct1.vlocity_cmt__ChildProductId__c = prod1child1.id;
        pct1.vlocity_cmt__ChildLineNumber__c='1234';
        insert pct1;
        
        CatalogAgreement__c catAgr = new CatalogAgreement__c();
        catAgr.Name = 'SUBSCRIPTIONS';
        catAgr.Catalog__c = 'SUBSCRIPTIONS';
        catAgr.OnlyMappedproductAgreement__c = true;
        insert catAgr;
        
        CatalogAgreement__c catAgr1 = new CatalogAgreement__c();
        catAgr1.Name = 'MOBILEDEVICE';
        catAgr1.Catalog__c = 'MOBILEDEVICE';
        catAgr1.OnlyMappedproductAgreement__c = true;
        catAgr1.Non_Negotiable_Catalog__c = true;
        insert catAgr1;
    }
    @istest
    static  void agreementOffersTest() {
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        inputMap.put('TSCID','TSCID_1234');
        Test.startTest();
        new MCOnline_GetAgreementOffers_V4().invokeMethod('getAgreementOffers_V3',inputMap,outMap,options);
        Test.stopTest();
    }
    
    @istest
    static  void blankTSCID_Test() {
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        inputMap.put('TSCID','');
        Test.startTest();
        new MCOnline_GetAgreementOffers_V4().invokeMethod('getAgreementOffers_V3',inputMap,outMap,options);
        Test.stopTest();
        system.assertEquals(400,outMap.get('StatusCode'));
    }
    
    @istest
    static  void invalidTSCID_Test() {
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        inputMap.put('TSCID','invalidTSCID');
        Test.startTest();
        new MCOnline_GetAgreementOffers_V4().invokeMethod('getAgreementOffers_V3',inputMap,outMap,options);
        Test.stopTest();
        system.assertEquals(400,outMap.get('StatusCode'));
    }
    
    @istest
    static  void noActiveAgreement_Test() {
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        inputMap.put('TSCID','TSCID_5');
        Test.startTest();
        new MCOnline_GetAgreementOffers_V4().invokeMethod('getAgreementOffers_V3',inputMap,outMap,options);
        Test.stopTest();
        system.assertEquals(400,outMap.get('StatusCode'));
    }
    
    @istest
    static  void noTSCID_Test() {
        Map<String,Object> inputMap = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        //inputMap.put('TSCID','TSCID_5');
        Test.startTest();
        new MCOnline_GetAgreementOffers_V4().invokeMethod('getAgreementOffers_V3',inputMap,outMap,options);
        Test.stopTest();
       // system.assertEquals(200,outMap.get('StatusCode'));
    }
    
}