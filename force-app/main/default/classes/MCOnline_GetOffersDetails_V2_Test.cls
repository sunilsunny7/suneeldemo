@isTest
public class MCOnline_GetOffersDetails_V2_Test {
    
    private static String namespace = 'vlocity_cmt__';
    // Intitialized in Setup, used throughout
    public static vlocity_cmt__CalculationMatrixVersion__c version;
    public static vlocity_cmt__CalculationMatrix__c parent;
    public static List<vlocity_cmt__CalculationMatrixRow__c> lineItems;
    private static Id orderId;
    private static boolean flag;  //used to upload matrix row data for test1 or test2
    private static Id quoteId, quoteId2; // added by Dipanwita
    static TeliaSERecordTypeSetting__mdt TeliaSERecordTypeSetting;
    
    @testSetup
    static void initTestData() {
        
        Account acc = new Account();
        acc.Name='TestAccount';
        acc.Org_Nr__c =  '1234567890';
        acc.TSCID__c = 'TSCID5609';
        //acc.CreatedDate = Date.today().addDays(-30);
        Insert acc;
        System.debug('acc.id'+acc.id);
        Contract contr=new Contract();
        contr.Name='Test';
        contr.AccountId=acc.id;
        contr.Status='Active';
        // contr.Contract_Record_Type__c='Ramavtal';
        contr.Solution_Area__c='Vxl';
        contr.StartDate=Date.today();
        contr.ContractTerm=24;
        // contr.ContractNumber = [select ContractNumber from Contract where AccountId = ];
        //contr.ContractNumber;
        insert contr;
        // contr.Contract_Record_Type__c='Ramavtal';
        // update contr;
        System.debug('Contract no test : '+contr.ContractNumber);
        Product2 prod1 = new Product2 (Name='Office 365', ProductCode = 'Promo_Riksnet_BB', vlocity_cmt__JSONAttribute__c='{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1l000000pixdAAA","attributeid__c":"a2s1w00000005t7AAA","attributecategoryid__c":"a2r1w0000008xvuAAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Telia Mobile Agreements","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a2p1l0000008REzAAM","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Unspecified","valuedatatype__c":"Picklist","valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"Unspecified","id":10,"displayText":"Unspecified"}],"values":[{"value":"Unspecified","id":10,"displayText":"Unspecified"},{"value":"24","id":20,"displayText":"24 months"},{"value":"36","id":30,"displayText":"36 months"}]},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1l000000pixdAAA","attributeid__c":"a2s1w00000005tMAAQ","attributecategoryid__c":"a2r1w0000008xvuAAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Telia Mobile Agreements","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a2p1l0000008RF0AAM","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Number"},"$$AttributeDefinitionEnd$$":null}]}');
        insert prod1;
        Date today=Date.today();
        vlocity_cmt__ContractLineItem__c cli=new vlocity_cmt__ContractLineItem__c();
        cli.name='Office';
        cli.vlocity_cmt__product2id__c=prod1.id;
        cli.vlocity_cmt__ContractId__c=contr.id;
        cli.TeliaSE_MC_Customer_Requested_Percentage__c=5;
        cli.TeliaSE_End_Date__C=today.addDays(10);
        cli.TeliaSE_ProductHierarchy__c='ABC';
        cli.TeliasSETargetPercentage__c=5;
        cli.TeliaSE_SubsidisedVoice__c = 'No';
        cli.vlocity_cmt__RecurringCharge__c=200;
        insert cli;
        
        Utilizer_Contract_Relationship__c util = new Utilizer_Contract_Relationship__c();
        
        util.AccountId__c = acc.id;
        util.ContractNumber__c =contr.id;
        util.Org_Number__c = '5673289783';
        util.Status__c = 'Aktiv';
        //util.Utilizer_Contract_Name__c = '912';
        util.Utilizer_Role__c = 'Utilizer';
        util.Utilizer_Type__c = '';
        insert util;
        
        vlocity_cmt__Catalog__c ct = new vlocity_cmt__Catalog__c();
        ct.Name = 'Test Name';
        insert ct;
        vlocity_cmt__CatalogProductRelationship__c cpr=new vlocity_cmt__CatalogProductRelationship__c();
        cpr.vlocity_cmt__IsActive__c=true;
        cpr.vlocity_cmt__CatalogId__c = ct.Id;
        cpr.Name = 'NameInCPR';
        // cpr.vlocity_cmt__CatalogId__r.vlocity_cmt__IsActive__c = true;
        //cpr.vlocity_cmt__CatalogId__c.vlocity_cmt__CatalogCode__c = 'SUBSCRIPTIONABC';
        insert cpr;   
        
        vlocity_cmt__CatalogProductRelationship__c cprTwo = new vlocity_cmt__CatalogProductRelationship__c();
        cprTwo.vlocity_cmt__IsActive__c=true;
        cprTwo.vlocity_cmt__CatalogId__c = ct.Id;
        cprTwo.Name = 'NameInCPRTwo';
        insert cprTwo;
        
        vlocity_cmt__CatalogProductRelationship__c cprt = new vlocity_cmt__CatalogProductRelationship__c();
        cprt.vlocity_cmt__IsActive__c=true;
        cprt.vlocity_cmt__CatalogId__c = ct.Id;
        cprt.Name = 'NameInCPRThree';
        insert cprt;
        vlocity_cmt__Catalog__c catalg = new vlocity_cmt__Catalog__c();
        catalg.Name = 'SnehaD';
        insert catalg;
        
        CatalogAgreement__c cAgree = new CatalogAgreement__c();
        cAgree.Catalog__c = 'SUBSCRIPTIONS';
        cAgree.Name = 'NameForCatAgree';
        cAgree.Non_Negotiable_Catalog__c = false;
        cAgree.OnlyMappedproductAgreement__c = true;
        // cAgree.CreatedById='0054E000006aD8iQAE';
        //cAgree.CreatedById ='dfdj233546';
        // cAgree.CreatedDate = 2020-08-27T06:12:08.000+0000;
        //  cAgree.LastModifiedById = '0054E000006aD8iQAE';
        cAgree.OnlyMappedproductAgreement__c = true;
        insert cAgree;
        
        list <Order> ordList = new list <Order>();
        Order Ord = new Order();
        Ord.Account = acc;
        Ord.EffectiveDate = system.today()-12;
        Ord.Status = 'Draft';
        Ord.BillingCountry = 'Sweden';
        Ord.Contract = contr;
        ordList.add(Ord);
        
        list <Order> ordList1 = new list <Order>();
        Order Ord1 = new Order();
        Ord1.Account = acc;
        Ord1.EffectiveDate = system.today()-12;
        Ord1.Status = 'Draft';
        Ord1.BillingCountry = 'Sweden';
        Ord1.Contract = contr;
        ordList1.add(Ord1);
        
        
        List < WebService__c > endpointURLs = new List < WebService__c > ();
        WebService__c wbTest = new WebService__c(Name = 'MCONL_OrderProcessor',  
                                                 EndpointURL__c = 'https://apimarket-test.eam.telia.se/token',
                                                 Content_Type__c = 'application/x-www-form-urlencoded', 
                                                 userName__c = 'imStV5FaBfKqSeGuR6ff_BJR6Tga',
                                                 password__c = 'UAEkMX1YKQbplxPXhPVdcd2uxDEa', 
                                                 Authorization__c = 'Basic aW1TdFY1RmFCZktxU2VHdVI2ZmZfQkpSNlRnYTpVQUVrTVgxWUtRYnBseFBYaFBWZGNkMnV4REVh');
        endpointURLs.add(wbTest);
        WebService__c wbTest2 = new WebService__c(Name = 'TeliaSE_MadamAuthenticationWS',  
                                                  EndpointURL__c = 'https://apimarket-test.eam.telia.se/token',
                                                  Content_Type__c = 'application/x-www-form-urlencoded', 
                                                  userName__c = 'imStV5FaBfKqSeGuR6ff_BJR6Tga',
                                                  password__c = 'UAEkMX1YKQbplxPXhPVdcd2uxDEa', 
                                                  Authorization__c = 'Basic aW1TdFY1RmFCZktxU2VHdVI2ZmZfQkpSNlRnYTpVQUVrTVgxWUtRYnBseFBYaFBWZGNkMnV4REVh');
        endpointURLs.add(wbTest2);
        insert endpointURLs;
        
        
        
    }
    public static Map<String,Object> inputMap = new Map<String,Object>();
    public static Map<String,Object> outMap = new Map<String,Object>();
    public static Map<String,Object> options = new Map<String,Object>();
    
    @istest
    static void ProcessAccountManagementJSON_NewTest(){
        vlocity_cmt__Catalog__c ct = new vlocity_cmt__Catalog__c();
        ct.Name = 'Test Name';
        insert ct;
        vlocity_cmt__CatalogProductRelationship__c cpr=new vlocity_cmt__CatalogProductRelationship__c();
        cpr.vlocity_cmt__IsActive__c=true;
        cpr.vlocity_cmt__CatalogId__c = ct.Id;
        cpr.Name = 'NameInCPR';
        // cpr.vlocity_cmt__CatalogId__r.vlocity_cmt__IsActive__c = true;
        //cpr.vlocity_cmt__CatalogId__c.vlocity_cmt__CatalogCode__c = 'SUBSCRIPTIONABC';
        insert cpr; 
        new MCOnline_GetOffersDetails_V2().invokeMethod('getOffersDetails_V2',inputMap,outMap,options);     
        
    }
    
    @istest
    static  void test() {
        
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        
        List <Order> orderList = new List <Order>();
        List <Account> accountList = new list <Account>();
        accountList = [select id from account Where Org_Nr__c = '1234567890'];    
        order m= new order(Name = 'Order',AccountId= accountList.get(0).id,status = 'Draft',EffectiveDate = system.today(),
                           Pricebook2Id = stdPriceBookRecId);
        insert m;
        Datetime yesterday = Datetime.now().addDays(-13);
        Test.setCreatedDate(m.Id, yesterday);  
        update m;
        
        List<sObject> types=new List<sObject>();
        SObject sObj = [SELECT Id, SobjectType, DeveloperName FROM RecordType WHERE IsActive = TRUE and SobjectType = 'vlocity_cmt__ObjectClass__c' and DeveloperName = 'ObjectType' LIMIT 1];   
        vlocity_cmt__ObjectClass__c FiberType = new vlocity_cmt__ObjectClass__c(Name = 'Fiber Base Product Spec Type', vlocity_cmt__ObjectApiName__c = 'Product2', RecordTypeId = sObj.Id);
        
        types.add(FiberType);
        
        insert types;
        
        Account accountInfo = [SELECT Id FROM Account LIMIT 1];  
        
        Quote testQuote = new Quote();
        Id userId = Userinfo.getUserId();
        Seller__c sellerInfo = Test_DataFactory.createBusinessAreaManagerSeller(userId);
        insert sellerInfo;
        Opportunity testOpportunity = Test_DataFactory.createSmeOpportunity();
        testOpportunity.AccountId = accountInfo.Id;
        insert testOpportunity;
        RecordType rt = [Select id,name, DeveloperName from RecordType where Name='Contract Quote'];               
        
        Contract con=[select id from Contract limit 1];
        //Quote for Roll Down Test(Office 365)
        testQuote.Name= 'Test Quote';
        testQuote.OpportunityId = testOpportunity.Id;
        testQuote.Status = 'Draft';
        testQuote.Pricebook2Id = stdPriceBookRecId;
        testQuote.RecordTypeId = rt.Id; //RecordTypeIdQuote; //rt.Id;
        testQuote.vlocity_cmt__frameContractId__c=con.id;
        insert testQuote; 
        List<Product2> prod = Test_DataFactory.createProducts(10);
        prod[0].name='Promo_BB_LL';
        prod[0].ProductCode='Promo_BB_LL';
        prod[0].vlocity_cmt__ObjectTypeId__c=FiberType.Id;
        
        prod[1].name='Promo_XLAN_LL';
        prod[0].ProductCode='Promo_XLAN_LL';
        prod[1].vlocity_cmt__ObjectTypeId__c=FiberType.id;
        
        prod[2].name='Promo_COAX_TV';
        prod[0].ProductCode='Promo_COAX_TV';
        prod[2].vlocity_cmt__ObjectTypeId__c=FiberType.id;
        
        prod[3].name='Promo_IPTV_LL';
        prod[0].ProductCode='Promo_IPTV_LL';
        prod[3].vlocity_cmt__ObjectTypeId__c=FiberType.id;    
        prod[4].name='Promo_Open_Fiber_LL';
        prod[0].ProductCode='Promo_Open_Fiber_LL';
        prod[4].vlocity_cmt__ObjectTypeId__c=FiberType.id;    
        prod[5].name='Promo_Landlord';
        prod[0].ProductCode='Promo_Landlord';
        prod[5].vlocity_cmt__ObjectTypeId__c=FiberType.id;    
        prod[6].name='Promo_VoIP_LL';
        prod[0].ProductCode='Promo_VoIP_LL';
        prod[6].vlocity_cmt__ObjectTypeId__c=FiberType.id;    
        prod[7].name='Promo_Riksnet_BB';
        prod[0].ProductCode='Promo_Riksnet_BB';
        insert prod; 
        
        PricebookEntry objpricebookentry =new PricebookEntry();
        objpricebookentry.Product2ID = prod[0].id;
        objpricebookentry.Pricebook2ID = stdPriceBookRecId;
        objpricebookentry.UnitPrice=23.50;
        objpricebookentry.UseStandardPrice=false;
        objpricebookentry.isActive=true;//Add this line
        insert objpricebookentry;
        system.assert(objpricebookentry.Id != null);
        OrderItem orderItem = new OrderItem();
        orderItem.vlocity_cmt__JSONAttribute__c = '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4E000006ROTtQAO","attributeid__c":"a364E000000M1hoQAC","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"EXT_REF_ONLINE","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"External Reference Online","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a334E000000RSHUQA4","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4E000006ROTtQAO","attributeid__c":"a364E0000005SvrQAE","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"SIM_Format","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"SIM Format","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a334E000000RSvCQAW","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4E000006ROTtQAO","attributeid__c":"a364E0000005Sw1QAE","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ICC_number","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"ICC nummer","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a334E000000RSvDQAW","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4E000006ROTtQAO","attributeid__c":"a364E0000005TjKQAU","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"User_name","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"User_name","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a334E000000RTCGQA4","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"a4s4E000000nyuoQAA","attributeid__c":"a364E0000005SvwQAE","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"e-SIM_Method","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"e-SIM Method","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a334E000000RSw0QAG","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Email","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"Email","sequence":1,"id":"8a7f3b12-cf4b-413c-9ac3-bc851a3651e0","displayText":"Email"}],"values":[{"value":"Email","sequence":1,"id":"8a7f3b12-cf4b-413c-9ac3-bc851a3651e0","displayText":"Email"},{"value":"Printpdf","sequence":2,"id":"4505ebd8-5437-ead5-d2f9-3f6e57590ad3","displayText":"Printpdf"},{"value":"Printhtml","sequence":3,"id":"c85f2296-d69d-f781-d17e-48cb0c8020b2","displayText":"Printhtml"},{"value":"Portal","sequence":4,"id":"3dc0a245-7783-d1c9-4c45-dd7c6066876e","displayText":"Portal"}],"selectedItem":{"value":"Email","sequence":1,"id":"8a7f3b12-cf4b-413c-9ac3-bc851a3651e0","displayText":"Email"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4E000006ROTtQAO","attributeid__c":"a364E0000005SLgQAM","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"BILLING_ACCOUNT","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Billing Account Online","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a334E000000RSftQAG","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4E000006ROTtQAO","attributeid__c":"a364E000000M1hqQAC","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"TELIA_COMM_PERIOD","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period Online","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":0,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a334E000000RSHSQA4","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"0","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"0","sequence":1,"id":"e7e1d1c5-bb4e-0ca1-bd82-5f9b77216274","displayText":"0"}],"values":[{"value":"0","sequence":1,"id":"e7e1d1c5-bb4e-0ca1-bd82-5f9b77216274","displayText":"0"},{"value":"12","sequence":2,"id":"2946e54d-419b-62dd-358f-793ab153bed7","displayText":"12"},{"value":"24","sequence":3,"id":"2a44f701-88d4-3537-1a61-7a6a18991fe2","displayText":"24"},{"value":"36","sequence":3,"id":"f2b151d6-7c45-5a73-9d42-f32e81785d14","displayText":"36"}],"selectedItem":{"value":"0","sequence":1,"id":"e7e1d1c5-bb4e-0ca1-bd82-5f9b77216274","displayText":"0"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4E000006ROTtQAO","attributeid__c":"a364E000000M1hrQAC","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"TELIA_COMM_UNIT","attributeconfigurable__c":true,"attributedisplaysequence__c":"100","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Unit Online","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a334E000000RSHTQA4","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Month","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"Month","sequence":1,"id":"e0b4a920-3039-61e2-9bc3-9a8194f7270a","displayText":"Month"}],"values":[{"value":"Month","sequence":1,"id":"e0b4a920-3039-61e2-9bc3-9a8194f7270a","displayText":"Month"}],"selectedItem":{"value":"Month","sequence":1,"id":"e0b4a920-3039-61e2-9bc3-9a8194f7270a","displayText":"Month"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4E000006ROTtQAO","attributeid__c":"a364E0000005QwmQAE","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"EMAIL","attributeconfigurable__c":true,"attributedisplaysequence__c":"8","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Email Address","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a334E000000RSHNQA4","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4E000006ROTtQAO","attributeid__c":"a364E000000M1hpQAC","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"MSISDN","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"MSISDN","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a334E000000RSHOQA4","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":null},"$$AttributeDefinitionEnd$$":null}]}';                         
            orderItem.vlocity_cmt__RecurringCharge__c = 0;
        orderItem.MCOnline_CommitmentPeriod__c = '0';
        orderItem.MCOnline_CommitmentUnit__c = 'Month';
        orderItem.Quantity = 1;
        orderItem.vlocity_cmt__Action__c = 'Add';   
        orderItem.vlocity_cmt__ParentItemId__c = '8024E000002GqmbQAC';
        orderItem.OrderId = m.Id;
        orderItem.UnitPrice = 1;
        orderItem.PricebookEntryId = objpricebookentry.Id;
        Insert orderItem;
        
        
        List<Account> tscid_aclst=new List<Account>(); 
        Account acc = new Account();
        acc.Name='TestAccount';
        acc.TSCID__c = 'TSCID5608';
        tscid_aclst.add(acc);
        insert tscid_aclst; 
        
        List<contract> agreement_lst=new List<contract>();
        Contract cont = new Contract();
        cont.Name = 'Abhinav Test';
        cont.AccountId = acc.Id;
        // cont.Id = '8000Q000004g0D7QAI';
        agreement_lst.add(cont);
        insert agreement_lst;
        
        agreement_lst=[SELECT id,name,ContractNumber,AccountId,Status  
                       FROM contract 
                       where (AccountId=:tscid_aclst[0].Id) And Contract_Record_Type__c='Ramavtal' And Status='Active' ];
        insert agreement_lst; 
        
        
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String,Object>();
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> input2 = new Map<String, Object>();
        Map<String, Object> input3 = new Map<String, Object>();
        Map<String, Object> input4 = new Map<String, Object>();
        Map<String, Object> input5 = new Map<String, Object>();
        Map<String, List<Object>> input6 = new Map<String, List<Object>>();
        List<Object> input7 = new List<Object>();
        List<Object> input10 = new List<Object>();
        Map<String, Object> input8 = new Map<String, Object>();
        Map<String, Object> input9 = new Map<String, Object>();
        Map<String, Object> input11 = new Map<String, Object>();
        Map<String, Object> input12 = new Map<String, Object>();
        List<Object> input13 = new List<Object>();
        Map<String, Object> input14 = new Map<String, Object>();
        List<Object> input15 = new List<Object>();
        Map<String, Object> input16 = new Map<String, Object>();
        List<Object> input17 = new List<Object>();
        Map<String, Object> input18 = new Map<String, Object>();
        List<Object> input19 = new List<Object>();
        Test.startTest();
        system.assert(orderItem.Id != null);
        system.assert(prod[0] != null); 
        
        sObject targetProduct1 = [ SELECT Id, Name, vlocity_cmt__JSONAttribute__c FROM Product2 limit 1];
        sObject quoteSObject =[Select Id, RecordTypeId, RecordType.DeveloperName FROM Quote WHERE Id =: testQuote.Id];
        List<SObject> quoteItemList =[SELECT Id, PricebookEntryId, PricebookEntry.Product2.Name, PricebookEntry.Product2.ProductCode,
                                      PricebookEntry.Product2.vlocity_cmt__JSONAttribute__c,vlocity_cmt__RootItemId__c,
                                      vlocity_cmt__JSONAttribute__c, vlocity_cmt__ProvisioningStatus__c, vlocity_cmt__RecurringCharge__c,
                                      vlocity_cmt__LineNumber__c, vlocity_cmt__PricingLogData__c, vlocity_cmt__OneTimeCharge__c,
                                      vlocity_cmt__Product2Id__c, Quantity, ListPrice, UnitPrice,
                                      vlocity_cmt__ProductHierarchyPath__c, Product2Id, vlocity_cmt__EffectiveQuantity__c,
                                      vlocity_cmt__InCartQuantityMap__c, vlocity_cmt__ServiceAccountId__c, vlocity_cmt__ServiceAccountId__r.Id,
                                      vlocity_cmt__ServiceAccountId__r.Name, vlocity_cmt__ServiceAccountId__r.RecordTypeId,
                                      vlocity_cmt__BillingAccountId__c, vlocity_cmt__BillingAccountId__r.Id,
                                      vlocity_cmt__BillingAccountId__r.Name, vlocity_cmt__BillingAccountId__r.RecordTypeId,
                                      TeliaSE_Base_Quantity__c,TeliaSE_PriceTypeCategory__c
                                      FROM QuoteLineItem 
                                      WHERE QuoteId =: quoteId];
        
        //List<SObject> updatedquoteItemList = new List<sObject>();
        Vlocity_cmt.JSONAttributeSupport jsonSupport = new Vlocity_cmt.JSONAttributeSupport();
        
        
        vlocity_cmt.PricingPlanService.putInPricingContext('Parent', quoteSObject);
        vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList', quoteItemList);
        system.assert(quoteSObject != null);
        
        Set<String> rangeAttrs = new Set<String>();
        rangeAttrs.add('abc');
        rangeAttrs.add('bcd');
        rangeAttrs.add('def');
        
        input18.put('childProducts',prod[0]);
        
        // input18.put('ProductCode',prod[0]);
        input18.put('ProductCode','Promo_Riksnet_BB');
        input19.add(input18);
        //input16.put('ProductCode',prod[0]);
        input16.put('ProductCode','Promo_Riksnet_BB');
        input16.put('childProducts',input19);
        input16.put('priceResult',input19);
        input17.add(input16);
        input14.put('ProductCode','Promo_Riksnet_BB');
        input14.put('childProducts',input17);
        input14.put('Ordering_Flag__c','Hide');
        input15.add(input14);
        
        input12.put('ProductCode','Promo_Riksnet_BB');
        input12.put('priceResult',input15);
        input12.put('childProducts',input17);
        input13.add(input12);
        input.put('Catalog','NameForCatAgree');
        
        // CatalogAgreement__c catalog = [Select id,OnlyMappedproductAgreement__c,Catalog__c,Name,Non_Negotiable_Catalog__c from CatalogAgreement__c where Catalog__c = 'SUBSCRIPTIONS' Limit 1];
        //  input.put('Catalog',catalog);
        
        input8.put('ProductCode','Promo_Riksnet_BB');
        input8.put('priceResult',input13);
        input8.put('childProducts',input17);
        input7.add(input8);
        input6.put('AgreementLineItem',input7);
        input.put('DR_ExtractAgreementLineItems',input6);
        input.put('DR_AccountManagementDetails',input12);
        input10.add(input8);
        input8.put('priceResult',input13);
        input8.put('childProducts',input13);
        input9.put('priceResult',input10);
        input9.put('ProductCode',input7);
        
        input11.put('ProductCode','Promo_Riksnet_BB');
        input11.put('priceResult',input10);
        input11.put('childProducts', input10);
        input4.put('offer',input11);
        input3.put('offerDetails',input4);
        input2.put('result',input3);
        input.put('HA_GetOffersFromDgCommerce',input2);  
        input.put('Agreementid',[select id from contract limit 1].Id);  
        input.put('TSCID','TSCID5609');  
        // input.put('TSCID',[select tscid__c from account limit 1].tscid__c);  
        input12.put('agreement', 'agreement');
        input12.put('partyAccount', 'partyAccount');
        
        input.put('DR_AccountManagementDetails',input12);
        new MCOnline_GetOffersDetails_V2().invokeMethod('getOffersDetails_V2',input,output,options);
        //new MCOnline_GetOffersDetails_V2().invokeMethod('trim',input,output,options);
        //String JSONData = '{"offer":{"priceResult":[{"adjustments":[],"overrides":[],"chargeamount":0.00000,"baseamount":0.00000,"Amount__c":0.00000,"IsVirtualPrice__c":false,"IsBasePrice__c":false,"effectiveuntildatespec":null,"effectivefromdatespec":null,"SubType__c":"Standard","Type__c":"Price","RecurringFrequency__c":"Monthly","ChargeType__c":"Recurring","DisplayText__c":"SEK 0.00"}],"addtocart":{"rest":{"params":{"context":"{}","basketAction":"AddWithNoConfig","offer":null},"link":"v3/catalogs/SUBSCRIPTIONS/basket","method":"POST"}},"Name":"Mobilt Bredband erbjudande","ProductCode":"MOB_TOTAL_BB_V2","Product2Id":"01t7Z000007IGkCQAW","PricebookEntryId":"01u7Z00000Gwd35QAB","Quantity":1.0,"minQuantity":0.0,"maxQuantity":99999.0,"groupMinQuantity":0,"groupMaxQuantity":99999,"productHierarchyPath":"01t7Z000007IGkCQAW","lineNumber":"0001","Attachments":null,"Id":"01t7Z000007IGkCQAW","Description":null,"vlocity_cmt__SellingStartDate__c":"2020-08-04T18:30:00.000Z","vlocity_cmt__SellingEndDate__c":null,"vlocity_cmt__EndOfLifeDate__c":null,"vlocity_cmt__IsOrderable__c":true,"IsActive":true,"AO__c":null,"TeliaSE_Product_Service_Code__c":null,"Ordering_Flag__c":null,"Ordering_System__c":null,"C2BC_Category__c":null,"C2BC_Subcategory__c":null,"CID__c":null,"TeliaSE_Product_Category__c":null,"TeliaSE_Subscription_Type__c":null,"Downstream_CategoryData__c":null,"MConline_Action_Code__c":null,"MC_Product_Name_Eng__c":"Mobilt Bredband offer","childProducts":[{"priceResult":[{"adjustments":[],"overrides":[],"chargeamount":0.00000,"baseamount":0.00000,"Amount__c":0.00000,"IsVirtualPrice__c":false,"IsBasePrice__c":true,"effectiveuntildatespec":null,"effectivefromdatespec":null,"SubType__c":"Standard","Type__c":"Price","RecurringFrequency__c":"Monthly","ChargeType__c":"Recurring","DisplayText__c":"SEK 0.00"}],"Name":"Mobilt Bredband","ProductCode":"MOB_BB_Bundle_2020_04","Product2Id":"01t7Z000007IGjdQAG","PricebookEntryId":"01u7Z00000Gwd2gQAB","Quantity":1.0,"minQuantity":1.0,"maxQuantity":1.0,"groupMinQuantity":0,"groupMaxQuantity":1,"productHierarchyPath":"01t7Z000007IGkCQAW<01t7Z000007IGjdQAG","lineNumber":"0001.0001","Attachments":null,"Id":"01t7Z000007IGjdQAG","Description":"Ta med dig kontoret och landets snabbaste mobila bredband för företag, så kan du jobba på distans var som helst i Sverige","vlocity_cmt__SellingStartDate__c":"2020-08-30T22:00:00.000Z","vlocity_cmt__SellingEndDate__c":null,"vlocity_cmt__EndOfLifeDate__c":null,"vlocity_cmt__IsOrderable__c":false,"IsActive":true,"AO__c":null,"TeliaSE_Product_Service_Code__c":null,"Ordering_Flag__c":"Salesflow","Ordering_System__c":null,"C2BC_Category__c":"subscriptionbundle","C2BC_Subcategory__c":"mobilebroadbandsubscription","CID__c":null,"TeliaSE_Product_Category__c":null,"TeliaSE_Subscription_Type__c":null,"Downstream_CategoryData__c":null,"MConline_Action_Code__c":null,"MC_Product_Name_Eng__c":"Mobile Broadband","childProducts":[{"priceResult":[{"adjustments":[],"overrides":[],"chargeamount":729.00000,"baseamount":729.00000,"Amount__c":649.00,"IsVirtualPrice__c":false,"IsBasePrice__c":true,"effectiveuntildatespec":"2021-07-31","effectivefromdatespec":"2020-07-31","SubType__c":"Standard","Type__c":"Price","RecurringFrequency__c":"Monthly","ChargeType__c":"Recurring","DisplayText__c":"SEK 729.00"}],"Name":"Mobilt Bredband Företag 500 GB","ProductCode":"MOB_BB_500GB","Product2Id":"01t7Z000007IGh6QAG","PricebookEntryId":"01u7Z00000Gwd0YQAR","Quantity":0.0,"minQuantity":0.0,"maxQuantity":1.0,"groupMinQuantity":0,"groupMaxQuantity":99999,"productHierarchyPath":"01t7Z000007IGkCQAW<01t7Z000007IGjdQAG<01t7Z000007IGh6QAG","lineNumber":"0001.0001.0001","Attachments":null,"AttributeCategory":{"totalSize":1,"messages":[],"records":[{"messages":[],"displaySequence":10,"Code__c":"ATT_CODE_TELIAMOBAGGR","Name":"Attributes","id":"a353E000003rEvcQAE","productAttributes":{"totalSize":8,"messages":[],"records":[{"messages":[],"code":"EXT_REF_ONLINE","dataType":"text","inputType":"text","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a367Z000000PDG3QAO","label":"External_reference","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"readonly":false,"disabled":false}],"userValues":null},{"messages":[],"code":"Email","dataType":"text","inputType":"text","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a367Z000000PDG5QAO","label":"Email","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"readonly":false,"disabled":false}],"userValues":null},{"messages":[],"code":"ICC_number","dataType":"text","inputType":"text","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a367Z000000PDG6QAO","label":"ICC_number","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"readonly":false,"disabled":false}],"userValues":null},{"messages":[],"code":"MSISDN","dataType":"text","inputType":"text","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a367Z000000PDG8QAO","label":"MSISDN","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"readonly":false,"disabled":false}],"userValues":null},{"messages":[],"code":"SIM_Format","dataType":"text","inputType":"dropdown","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a367Z000000PDG9QAO","label":"SIM_Format","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"id":"c32c567c-c6f4-eaa8-0e16-a1da1dd42195","name":"c32c567c-c6f4-eaa8-0e16-a1da1dd42195","label":"esim","readonly":false,"disabled":false,"value":"esim","defaultSelected":false,"displaySequence":1},{"id":"74fe4898-fa10-3c39-f562-d2ba40b65ab4","name":"74fe4898-fa10-3c39-f562-d2ba40b65ab4","label":"simcard","readonly":false,"disabled":false,"value":"simcard","defaultSelected":true,"displaySequence":2}],"userValues":"simcard"},{"messages":[],"code":"TELIA_COMM_PERIOD","dataType":"text","inputType":"dropdown","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a367Z000000PDGCQA4","label":"Commitment_period","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"id":"e7e1d1c5-bb4e-0ca1-bd82-5f9b77216274","name":"e7e1d1c5-bb4e-0ca1-bd82-5f9b77216274","label":"0","readonly":false,"disabled":false,"value":"0","defaultSelected":true,"displaySequence":1},{"id":"2946e54d-419b-62dd-358f-793ab153bed7","name":"2946e54d-419b-62dd-358f-793ab153bed7","label":"12","readonly":false,"disabled":false,"value":"12","defaultSelected":false,"displaySequence":2},{"id":"2a44f701-88d4-3537-1a61-7a6a18991fe2","name":"2a44f701-88d4-3537-1a61-7a6a18991fe2","label":"24","readonly":false,"disabled":false,"value":"24","defaultSelected":false,"displaySequence":3},{"id":"f2b151d6-7c45-5a73-9d42-f32e81785d14","name":"f2b151d6-7c45-5a73-9d42-f32e81785d14","label":"36","readonly":false,"disabled":false,"value":"36","defaultSelected":false,"displaySequence":4}],"userValues":"0"},{"messages":[],"code":"User_name","dataType":"text","inputType":"text","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a367Z000000PDGHQA4","label":"User_name","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"readonly":false,"disabled":false}],"userValues":null},{"messages":[],"code":"e-SIM_Method","dataType":"text","inputType":"dropdown","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a367Z000000PDGIQA4","label":"e-SIM_Method","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"id":"8a7f3b12-cf4b-413c-9ac3-bc851a3651e0","name":"8a7f3b12-cf4b-413c-9ac3-bc851a3651e0","label":"email","readonly":false,"disabled":false,"value":"email","defaultSelected":true,"displaySequence":1}],"userValues":"email"}]}}]},"Id":"01t7Z000007IGh6QAG","Description":"Mobilt Bredband Företag 500 GB","vlocity_cmt__SellingStartDate__c":"2020-06-26T22:00:00.000Z","vlocity_cmt__SellingEndDate__c":null,"vlocity_cmt__EndOfLifeDate__c":null,"vlocity_cmt__IsOrderable__c":false,"IsActive":true,"AO__c":null,"TeliaSE_Product_Service_Code__c":null,"Ordering_Flag__c":"Salesflow","Ordering_System__c":"GSM-AHS","C2BC_Category__c":"Mobilebroadbandsubscription","C2BC_Subcategory__c":"broadband","CID__c":null,"TeliaSE_Product_Category__c":"F1GRUNDAVG","TeliaSE_Subscription_Type__c":"7U","Downstream_CategoryData__c":"F1GRUNDAVG","MConline_Action_Code__c":null,"MC_Product_Name_Eng__c":null},{"priceResult":[{"adjustments":[],"overrides":[],"chargeamount":379.00000,"baseamount":379.00000,"Amount__c":369.00,"IsVirtualPrice__c":false,"IsBasePrice__c":true,"effectiveuntildatespec":"2021-07-31","effectivefromdatespec":"2020-07-31","SubType__c":"Standard","Type__c":"Price","RecurringFrequency__c":"Monthly","ChargeType__c":"Recurring","DisplayText__c":"SEK 379.00"}],"Name":"Mobilt Bredband Företag 100 GB","ProductCode":"MOB_BB_100GB","Product2Id":"01t7Z000007IGfmQAG","PricebookEntryId":"01u7Z00000GwczEQAR","Quantity":0.0,"minQuantity":0.0,"maxQuantity":1.0,"groupMinQuantity":0,"groupMaxQuantity":99999,"productHierarchyPath":"01t7Z000007IGkCQAW<01t7Z000007IGjdQAG<01t7Z000007IGfmQAG","lineNumber":"0001.0001.0002","Attachments":null,"AttributeCategory":{"totalSize":1,"messages":[],"records":[{"messages":[],"displaySequence":10,"Code__c":"ATT_CODE_TELIAMOBAGGR","Name":"Attributes","id":"a353E000003rEvcQAE","productAttributes":{"totalSize":8,"messages":[],"records":[{"messages":[],"code":"EXT_REF_ONLINE","dataType":"text","inputType":"text","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a367Z000000PDG3QAO","label":"External_reference","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"readonly":false,"disabled":false}],"userValues":null},{"messages":[],"code":"Email","dataType":"text","inputType":"text","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a367Z000000PDG5QAO","label":"Email","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"readonly":false,"disabled":false}],"userValues":null},{"messages":[],"code":"ICC_number","dataType":"text","inputType":"text","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a367Z000000PDG6QAO","label":"ICC_number","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"readonly":false,"disabled":false}],"userValues":null},{"messages":[],"code":"MSISDN","dataType":"text","inputType":"text","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a367Z000000PDG8QAO","label":"MSISDN","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"readonly":false,"disabled":false}],"userValues":null},{"messages":[],"code":"SIM_Format","dataType":"text","inputType":"dropdown","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a367Z000000PDG9QAO","label":"SIM_Format","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"id":"c32c567c-c6f4-eaa8-0e16-a1da1dd42195","name":"c32c567c-c6f4-eaa8-0e16-a1da1dd42195","label":"esim","readonly":false,"disabled":false,"value":"esim","defaultSelected":false,"displaySequence":1},{"id":"74fe4898-fa10-3c39-f562-d2ba40b65ab4","name":"74fe4898-fa10-3c39-f562-d2ba40b65ab4","label":"simcard","readonly":false,"disabled":false,"value":"simcard","defaultSelected":true,"displaySequence":2}],"userValues":"simcard"},{"messages":[],"code":"TELIA_COMM_PERIOD","dataType":"text","inputType":"dropdown","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a367Z000000PDGCQA4","label":"Commitment_period","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"id":"e7e1d1c5-bb4e-0ca1-bd82-5f9b77216274","name":"e7e1d1c5-bb4e-0ca1-bd82-5f9b77216274","label":"0","readonly":false,"disabled":false,"value":"0","defaultSelected":true,"displaySequence":1},{"id":"2946e54d-419b-62dd-358f-793ab153bed7","name":"2946e54d-419b-62dd-358f-793ab153bed7","label":"12","readonly":false,"disabled":false,"value":"12","defaultSelected":false,"displaySequence":2},{"id":"2a44f701-88d4-3537-1a61-7a6a18991fe2","name":"2a44f701-88d4-3537-1a61-7a6a18991fe2","label":"24","readonly":false,"disabled":false,"value":"24","defaultSelected":false,"displaySequence":3},{"id":"f2b151d6-7c45-5a73-9d42-f32e81785d14","name":"f2b151d6-7c45-5a73-9d42-f32e81785d14","label":"36","readonly":false,"disabled":false,"value":"36","defaultSelected":false,"displaySequence":4}],"userValues":"0"},{"messages":[],"code":"User_name","dataType":"text","inputType":"text","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a367Z000000PDGHQA4","label":"User_name","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"readonly":false,"disabled":false}],"userValues":null},{"messages":[],"code":"e-SIM_Method","dataType":"text","inputType":"dropdown","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a367Z000000PDGIQA4","label":"e-SIM_Method","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"id":"8a7f3b12-cf4b-413c-9ac3-bc851a3651e0","name":"8a7f3b12-cf4b-413c-9ac3-bc851a3651e0","label":"email","readonly":false,"disabled":false,"value":"email","defaultSelected":true,"displaySequence":1}],"userValues":"email"}]}}]},"Id":"01t7Z000007IGfmQAG","Description":"Mobilt Bredband Företag 100 GB","vlocity_cmt__SellingStartDate__c":"2020-06-29T22:00:00.000Z","vlocity_cmt__SellingEndDate__c":null,"vlocity_cmt__EndOfLifeDate__c":null,"vlocity_cmt__IsOrderable__c":false,"IsActive":true,"AO__c":null,"TeliaSE_Product_Service_Code__c":null,"Ordering_Flag__c":"Salesflow","Ordering_System__c":"GSM-AHS","C2BC_Category__c":"Mobilebroadbandsubscription","C2BC_Subcategory__c":"broadband","CID__c":null,"TeliaSE_Product_Category__c":"F1GRUNDAVG","TeliaSE_Subscription_Type__c":"7T","Downstream_CategoryData__c":"F1GRUNDAVG","MConline_Action_Code__c":null,"MC_Product_Name_Eng__c":null},{"priceResult":[{"adjustments":[],"overrides":[],"chargeamount":279.00000,"baseamount":279.00000,"Amount__c":269.00,"IsVirtualPrice__c":false,"IsBasePrice__c":true,"effectiveuntildatespec":"2021-07-31","effectivefromdatespec":"2020-07-31","SubType__c":"Standard","Type__c":"Price","RecurringFrequency__c":"Monthly","ChargeType__c":"Recurring","DisplayText__c":"SEK 279.00"}],"Name":"Mobilt Bredband Företag 50 GB","ProductCode":"MOB_BB_50GB","Product2Id":"01t7Z000007IGgvQAG","PricebookEntryId":"01u7Z00000Gwd0NQAR","Quantity":0.0,"minQuantity":0.0,"maxQuantity":1.0,"groupMinQuantity":0,"groupMaxQuantity":99999,"productHierarchyPath":"01t7Z000007IGkCQAW<01t7Z000007IGjdQAG<01t7Z000007IGgvQAG","lineNumber":"0001.0001.0003","Attachments":null,"AttributeCategory":{"totalSize":1,"messages":[],"records":[{"messages":[],"displaySequence":10,"Code__c":"ATT_CODE_TELIAMOBAGGR","Name":"Attributes","id":"a353E000003rEvcQAE","productAttributes":{"totalSize":8,"messages":[],"records":[{"messages":[],"code":"EXT_REF_ONLINE","dataType":"text","inputType":"text","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a367Z000000PDG3QAO","label":"External_reference","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"readonly":false,"disabled":false}],"userValues":null},{"messages":[],"code":"Email","dataType":"text","inputType":"text","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a367Z000000PDG5QAO","label":"Email","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"readonly":false,"disabled":false}],"userValues":null},{"messages":[],"code":"ICC_number","dataType":"text","inputType":"text","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a367Z000000PDG6QAO","label":"ICC_number","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"readonly":false,"disabled":false}],"userValues":null},{"messages":[],"code":"MSISDN","dataType":"text","inputType":"text","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a367Z000000PDG8QAO","label":"MSISDN","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"readonly":false,"disabled":false}],"userValues":null},{"messages":[],"code":"SIM_Format","dataType":"text","inputType":"dropdown","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a367Z000000PDG9QAO","label":"SIM_Format","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"id":"c32c567c-c6f4-eaa8-0e16-a1da1dd42195","name":"c32c567c-c6f4-eaa8-0e16-a1da1dd42195","label":"esim","readonly":false,"disabled":false,"value":"esim","defaultSelected":false,"displaySequence":1},{"id":"74fe4898-fa10-3c39-f562-d2ba40b65ab4","name":"74fe4898-fa10-3c39-f562-d2ba40b65ab4","label":"simcard","readonly":false,"disabled":false,"value":"simcard","defaultSelected":true,"displaySequence":2}],"userValues":"simcard"},{"messages":[],"code":"TELIA_COMM_PERIOD","dataType":"text","inputType":"dropdown","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a367Z000000PDGCQA4","label":"Commitment_period","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"id":"e7e1d1c5-bb4e-0ca1-bd82-5f9b77216274","name":"e7e1d1c5-bb4e-0ca1-bd82-5f9b77216274","label":"0","readonly":false,"disabled":false,"value":"0","defaultSelected":true,"displaySequence":1},{"id":"2946e54d-419b-62dd-358f-793ab153bed7","name":"2946e54d-419b-62dd-358f-793ab153bed7","label":"12","readonly":false,"disabled":false,"value":"12","defaultSelected":false,"displaySequence":2},{"id":"2a44f701-88d4-3537-1a61-7a6a18991fe2","name":"2a44f701-88d4-3537-1a61-7a6a18991fe2","label":"24","readonly":false,"disabled":false,"value":"24","defaultSelected":false,"displaySequence":3},{"id":"f2b151d6-7c45-5a73-9d42-f32e81785d14","name":"f2b151d6-7c45-5a73-9d42-f32e81785d14","label":"36","readonly":false,"disabled":false,"value":"36","defaultSelected":false,"displaySequence":4}],"userValues":"0"},{"messages":[],"code":"User_name","dataType":"text","inputType":"text","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a367Z000000PDGHQA4","label":"User_name","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"readonly":false,"disabled":false}],"userValues":null},{"messages":[],"code":"e-SIM_Method","dataType":"text","inputType":"dropdown","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a367Z000000PDGIQA4","label":"e-SIM_Method","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"id":"8a7f3b12-cf4b-413c-9ac3-bc851a3651e0","name":"8a7f3b12-cf4b-413c-9ac3-bc851a3651e0","label":"email","readonly":false,"disabled":false,"value":"email","defaultSelected":true,"displaySequence":1}],"userValues":"email"}]}}]},"Id":"01t7Z000007IGgvQAG","Description":"Mobilt Bredband Företag 50 GB","vlocity_cmt__SellingStartDate__c":"2020-06-27T22:00:00.000Z","vlocity_cmt__SellingEndDate__c":null,"vlocity_cmt__EndOfLifeDate__c":null,"vlocity_cmt__IsOrderable__c":false,"IsActive":true,"AO__c":null,"TeliaSE_Product_Service_Code__c":null,"Ordering_Flag__c":"Salesflow","Ordering_System__c":"GSM-AHS","C2BC_Category__c":"Mobilebroadbandsubscription","C2BC_Subcategory__c":"broadband","CID__c":null,"TeliaSE_Product_Category__c":"F1GRUNDAVG","TeliaSE_Subscription_Type__c":"7S","Downstream_CategoryData__c":"F1GRUNDAVG","MConline_Action_Code__c":null,"MC_Product_Name_Eng__c":null},{"priceResult":[{"adjustments":[],"overrides":[],"chargeamount":199.00000,"baseamount":199.00000,"Amount__c":199.00,"IsVirtualPrice__c":false,"IsBasePrice__c":true,"effectiveuntildatespec":"2021-07-31","effectivefromdatespec":"2020-07-31","SubType__c":"Standard","Type__c":"Price","RecurringFrequency__c":"Monthly","ChargeType__c":"Recurring","DisplayText__c":"SEK 199.00"}],"Name":"Mobilt Bredband Företag 20 GB","ProductCode":"MOB_BB_20GB","Product2Id":"01t7Z000007IGh7QAG","PricebookEntryId":"01u7Z00000Gwd0ZQAR","Quantity":0.0,"minQuantity":0.0,"maxQuantity":1.0,"groupMinQuantity":0,"groupMaxQuantity":99999,"productHierarchyPath":"01t7Z000007IGkCQAW<01t7Z000007IGjdQAG<01t7Z000007IGh7QAG","lineNumber":"0001.0001.0004","Attachments":null,"AttributeCategory":{"totalSize":1,"messages":[],"records":[{"messages":[],"displaySequence":10,"Code__c":"ATT_CODE_TELIAMOBAGGR","Name":"Attributes","id":"a353E000003rEvcQAE","productAttributes":{"totalSize":8,"messages":[],"records":[{"messages":[],"code":"EXT_REF_ONLINE","dataType":"text","inputType":"text","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a367Z000000PDG3QAO","label":"External_reference","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"readonly":false,"disabled":false}],"userValues":null},{"messages":[],"code":"Email","dataType":"text","inputType":"text","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a367Z000000PDG5QAO","label":"Email","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"readonly":false,"disabled":false}],"userValues":null},{"messages":[],"code":"ICC_number","dataType":"text","inputType":"text","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a367Z000000PDG6QAO","label":"ICC_number","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"readonly":false,"disabled":false}],"userValues":null},{"messages":[],"code":"MSISDN","dataType":"text","inputType":"text","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a367Z000000PDG8QAO","label":"MSISDN","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"readonly":false,"disabled":false}],"userValues":null},{"messages":[],"code":"SIM_Format","dataType":"text","inputType":"dropdown","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a367Z000000PDG9QAO","label":"SIM_Format","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"id":"c32c567c-c6f4-eaa8-0e16-a1da1dd42195","name":"c32c567c-c6f4-eaa8-0e16-a1da1dd42195","label":"esim","readonly":false,"disabled":false,"value":"esim","defaultSelected":false,"displaySequence":1},{"id":"74fe4898-fa10-3c39-f562-d2ba40b65ab4","name":"74fe4898-fa10-3c39-f562-d2ba40b65ab4","label":"simcard","readonly":false,"disabled":false,"value":"simcard","defaultSelected":true,"displaySequence":2}],"userValues":"simcard"},{"messages":[],"code":"TELIA_COMM_PERIOD","dataType":"text","inputType":"dropdown","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a367Z000000PDGCQA4","label":"Commitment_period","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"id":"e7e1d1c5-bb4e-0ca1-bd82-5f9b77216274","name":"e7e1d1c5-bb4e-0ca1-bd82-5f9b77216274","label":"0","readonly":false,"disabled":false,"value":"0","defaultSelected":true,"displaySequence":1},{"id":"2946e54d-419b-62dd-358f-793ab153bed7","name":"2946e54d-419b-62dd-358f-793ab153bed7","label":"12","readonly":false,"disabled":false,"value":"12","defaultSelected":false,"displaySequence":2},{"id":"2a44f701-88d4-3537-1a61-7a6a18991fe2","name":"2a44f701-88d4-3537-1a61-7a6a18991fe2","label":"24","readonly":false,"disabled":false,"value":"24","defaultSelected":false,"displaySequence":3},{"id":"f2b151d6-7c45-5a73-9d42-f32e81785d14","name":"f2b151d6-7c45-5a73-9d42-f32e81785d14","label":"36","readonly":false,"disabled":false,"value":"36","defaultSelected":false,"displaySequence":4}],"userValues":"0"},{"messages":[],"code":"User_name","dataType":"text","inputType":"text","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a367Z000000PDGHQA4","label":"User_name","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"readonly":false,"disabled":false}],"userValues":null},{"messages":[],"code":"e-SIM_Method","dataType":"text","inputType":"dropdown","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a367Z000000PDGIQA4","label":"e-SIM_Method","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"id":"8a7f3b12-cf4b-413c-9ac3-bc851a3651e0","name":"8a7f3b12-cf4b-413c-9ac3-bc851a3651e0","label":"email","readonly":false,"disabled":false,"value":"email","defaultSelected":true,"displaySequence":1}],"userValues":"email"}]}}]},"Id":"01t7Z000007IGh7QAG","Description":"Mobilt Bredband Företag 20 GB","vlocity_cmt__SellingStartDate__c":"2020-06-26T22:00:00.000Z","vlocity_cmt__SellingEndDate__c":null,"vlocity_cmt__EndOfLifeDate__c":null,"vlocity_cmt__IsOrderable__c":false,"IsActive":true,"AO__c":null,"TeliaSE_Product_Service_Code__c":null,"Ordering_Flag__c":"Salesflow","Ordering_System__c":"GSM-AHS","C2BC_Category__c":"Mobilebroadbandsubscription","C2BC_Subcategory__c":"broadband","CID__c":null,"TeliaSE_Product_Category__c":"F1GRUNDAVG","TeliaSE_Subscription_Type__c":"7R","Downstream_CategoryData__c":"F1GRUNDAVG","MConline_Action_Code__c":null,"MC_Product_Name_Eng__c":null}]},{"priceResult":[{"adjustments":[],"overrides":[],"chargeamount":0.00000,"baseamount":0.00000,"Amount__c":0.00000,"IsVirtualPrice__c":false,"IsBasePrice__c":false,"effectiveuntildatespec":null,"effectivefromdatespec":null,"SubType__c":"Standard","Type__c":"Price","RecurringFrequency__c":"Monthly","ChargeType__c":"Recurring","DisplayText__c":"SEK 0"}],"Name":"Tillval","ProductCode":"MOB_BB_TECH_PROD","Product2Id":"01t7Z000007IGgBQAW","PricebookEntryId":"01u7Z00000GwczdQAB","Quantity":1.0,"minQuantity":1.0,"maxQuantity":1.0,"groupMinQuantity":0,"groupMaxQuantity":99999,"productHierarchyPath":"01t7Z000007IGkCQAW<01t7Z000007IGgBQAW","lineNumber":"0001.0002","Attachments":null,"Id":"01t7Z000007IGgBQAW","Description":null,"vlocity_cmt__SellingStartDate__c":"2020-07-26T22:00:00.000Z","vlocity_cmt__SellingEndDate__c":null,"vlocity_cmt__EndOfLifeDate__c":null,"vlocity_cmt__IsOrderable__c":false,"IsActive":true,"AO__c":null,"TeliaSE_Product_Service_Code__c":null,"Ordering_Flag__c":"Salesflow","Ordering_System__c":null,"C2BC_Category__c":"addonbundle","C2BC_Subcategory__c":null,"CID__c":null,"TeliaSE_Product_Category__c":"0","TeliaSE_Subscription_Type__c":null,"Downstream_CategoryData__c":"0","MConline_Action_Code__c":null,"MC_Product_Name_Eng__c":"Add-on options","childProducts":[{"priceResult":[{"adjustments":[],"overrides":[],"chargeamount":99.00000,"baseamount":99.00000,"Amount__c":99.00000,"IsVirtualPrice__c":false,"IsBasePrice__c":true,"effectiveuntildatespec":null,"effectivefromdatespec":null,"SubType__c":"Standard","Type__c":"Price","RecurringFrequency__c":"Monthly","ChargeType__c":"Recurring","DisplayText__c":"SEK 99.00"}],"Name":"Fast IP adress","ProductCode":"MOB_BB_FAST_IP","Product2Id":"01t7Z000007IGdzQAG","PricebookEntryId":"01u7Z00000GwcxRQAR","Quantity":0.0,"minQuantity":0.0,"maxQuantity":1.0,"groupMinQuantity":0,"groupMaxQuantity":99999,"productHierarchyPath":"01t7Z000007IGkCQAW<01t7Z000007IGgBQAW<01t7Z000007IGdzQAG","lineNumber":"0001.0002.0001","Attachments":null,"Id":"01t7Z000007IGdzQAG","Description":"Fast IP adress","vlocity_cmt__SellingStartDate__c":"2020-06-26T22:00:00.000Z","vlocity_cmt__SellingEndDate__c":null,"vlocity_cmt__EndOfLifeDate__c":null,"vlocity_cmt__IsOrderable__c":false,"IsActive":true,"AO__c":null,"TeliaSE_Product_Service_Code__c":"GPRSIP-1","Ordering_Flag__c":"Salesflow","Ordering_System__c":"GSM-AHS","C2BC_Category__c":"mobilevoicesubscription","C2BC_Subcategory__c":null,"CID__c":null,"TeliaSE_Product_Category__c":"0","TeliaSE_Subscription_Type__c":null,"Downstream_CategoryData__c":"0","MConline_Action_Code__c":null,"MC_Product_Name_Eng__c":"Fixed IP address"}]}],"offerType":"Product","vlocity_cmt__InCartQuantityMap__c":{"01t7Z000007IGjdQAG":1,"01t7Z000007IGgBQAW":1}}}';
        String JSONData = '{"childProducts":[{"priceResult":[{"adjustments":[],"overrides":[],"chargeamount":729.00000,"baseamount":729.00000,"Amount__c":649.00,"IsVirtualPrice__c":false,"IsBasePrice__c":true,"effectiveuntildatespec":"2021-07-31","effectivefromdatespec":"2020-07-31","SubType__c":"Standard","Type__c":"Price","RecurringFrequency__c":"Monthly","ChargeType__c":"Recurring","DisplayText__c":"SEK 729.00"}],"Name":"Mobilt Bredband Företag 500 GB","ProductCode":"MOB_BB_500GB","Product2Id":"01t7Z000007IGh6QAG","PricebookEntryId":"01u7Z00000Gwd0YQAR","Quantity":0.0,"minQuantity":0.0,"maxQuantity":1.0,"groupMinQuantity":0,"groupMaxQuantity":99999,"productHierarchyPath":"01t7Z000007IGkCQAW<01t7Z000007IGjdQAG<01t7Z000007IGh6QAG","lineNumber":"0001.0001.0001","Attachments":null,"AttributeCategory":{"totalSize":1,"messages":[],"records":[{"messages":[],"displaySequence":10,"Code__c":"ATT_CODE_TELIAMOBAGGR","Name":"Attributes","id":"a353E000003rEvcQAE","productAttributes":{"totalSize":8,"messages":[],"records":[{"messages":[],"code":"EXT_REF_ONLINE","dataType":"text","inputType":"text","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a367Z000000PDG3QAO","label":"External_reference","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"readonly":false,"disabled":false}],"userValues":null},{"messages":[],"code":"Email","dataType":"text","inputType":"text","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a367Z000000PDG5QAO","label":"Email","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"readonly":false,"disabled":false}],"userValues":null},{"messages":[],"code":"ICC_number","dataType":"text","inputType":"text","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a367Z000000PDG6QAO","label":"ICC_number","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"readonly":false,"disabled":false}],"userValues":null},{"messages":[],"code":"MSISDN","dataType":"text","inputType":"text","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a367Z000000PDG8QAO","label":"MSISDN","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"readonly":false,"disabled":false}],"userValues":null},{"messages":[],"code":"SIM_Format","dataType":"text","inputType":"dropdown","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a367Z000000PDG9QAO","label":"SIM_Format","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"id":"c32c567c-c6f4-eaa8-0e16-a1da1dd42195","name":"c32c567c-c6f4-eaa8-0e16-a1da1dd42195","label":"esim","readonly":false,"disabled":false,"value":"esim","defaultSelected":false,"displaySequence":1},{"id":"74fe4898-fa10-3c39-f562-d2ba40b65ab4","name":"74fe4898-fa10-3c39-f562-d2ba40b65ab4","label":"simcard","readonly":false,"disabled":false,"value":"simcard","defaultSelected":true,"displaySequence":2}],"userValues":"simcard"},{"messages":[],"code":"TELIA_COMM_PERIOD","dataType":"text","inputType":"dropdown","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a367Z000000PDGCQA4","label":"Commitment_period","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"id":"e7e1d1c5-bb4e-0ca1-bd82-5f9b77216274","name":"e7e1d1c5-bb4e-0ca1-bd82-5f9b77216274","label":"0","readonly":false,"disabled":false,"value":"0","defaultSelected":true,"displaySequence":1},{"id":"2946e54d-419b-62dd-358f-793ab153bed7","name":"2946e54d-419b-62dd-358f-793ab153bed7","label":"12","readonly":false,"disabled":false,"value":"12","defaultSelected":false,"displaySequence":2},{"id":"2a44f701-88d4-3537-1a61-7a6a18991fe2","name":"2a44f701-88d4-3537-1a61-7a6a18991fe2","label":"24","readonly":false,"disabled":false,"value":"24","defaultSelected":false,"displaySequence":3},{"id":"f2b151d6-7c45-5a73-9d42-f32e81785d14","name":"f2b151d6-7c45-5a73-9d42-f32e81785d14","label":"36","readonly":false,"disabled":false,"value":"36","defaultSelected":false,"displaySequence":4}],"userValues":"0"},{"messages":[],"code":"User_name","dataType":"text","inputType":"text","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a367Z000000PDGHQA4","label":"User_name","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"readonly":false,"disabled":false}],"userValues":null},{"messages":[],"code":"e-SIM_Method","dataType":"text","inputType":"dropdown","multiselect":false,"required":false,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a367Z000000PDGIQA4","label":"e-SIM_Method","displaySequence":1,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"id":"8a7f3b12-cf4b-413c-9ac3-bc851a3651e0","name":"8a7f3b12-cf4b-413c-9ac3-bc851a3651e0","label":"email","readonly":false,"disabled":false,"value":"email","defaultSelected":true,"displaySequence":1}],"userValues":"email"}]}}]},"Id":"01t7Z000007IGh6QAG","Description":"Mobilt Bredband Företag 500 GB","vlocity_cmt__SellingStartDate__c":"2020-06-26T22:00:00.000Z","vlocity_cmt__SellingEndDate__c":null,"vlocity_cmt__EndOfLifeDate__c":null,"vlocity_cmt__IsOrderable__c":false,"IsActive":true,"AO__c":null,"TeliaSE_Product_Service_Code__c":null,"Ordering_Flag__c":"Salesflow","Ordering_System__c":"GSM-AHS","C2BC_Category__c":"Mobilebroadbandsubscription","C2BC_Subcategory__c":"broadband","CID__c":null,"TeliaSE_Product_Category__c":"F1GRUNDAVG","TeliaSE_Subscription_Type__c":"7U","Downstream_CategoryData__c":"F1GRUNDAVG","MConline_Action_Code__c":null,"MC_Product_Name_Eng__c":null}]}';
        inputMap = (Map<String, Object>)JSON.deserializeUntyped(JSONData);
        Set<String> finalNodes= new Set<String>{'adjustments','overrides','id','name','cacheable','IsVirtualPrice__c', 'IsBasePrice__c', 'SubType__c', 'Type__c', 'DisplayText__c', 'Attachments', 'multiselect', 'required', 'readonly', 'disabled', 'filterable', 'attributeId', 'displaySequence', 'hasRules', 'hidden', 'cloneable', 'isNotTranslatable'};
        vlocity_cmt__ContractLineItem__c agreeList = [Select id, TeliaSE_SubsidisedVoice__c from vlocity_cmt__ContractLineItem__c Limit 1];
        MCOnline_GetOffersDetails_V2.removeNodes(inputMap, finalNodes, agreeList);
        String error;
        String errorCode;
        String errorType;
        MCOnline_GetOffersDetails_V2.generateError('error',errorCode,errorType,input);
        Test.stopTest();
    }
}