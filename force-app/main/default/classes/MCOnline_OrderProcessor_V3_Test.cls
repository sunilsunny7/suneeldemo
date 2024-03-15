@isTest
public class MCOnline_OrderProcessor_V3_Test {
    private static Id quoteId;
    
    private static User salesManager;
    
    @testSetup
    static void initTestData() {
        
        List <Checkout_Offer__c> CheckoutOffer = new List <Checkout_Offer__c> ();
        
        Checkout_Offer__c offer1 = new Checkout_Offer__c(Name = 'PORTIN_PROCESS',
                                                         OfferCode__c = 'PORTIN_PROCESS');
        CheckoutOffer.add(offer1);
        Checkout_Offer__c offer2 = new Checkout_Offer__c(Name = 'PORTIN_PROCESS_DATA',
                                                         OfferCode__c = 'PORTIN_PROCESS_DATA');
        CheckoutOffer.add(offer2);
        
        Checkout_Offer__c offer3 = new Checkout_Offer__c(Name = 'TRANSFER_PROCESS',
                                                         OfferCode__c = 'TRANSFER_PROCESS');
        CheckoutOffer.add(offer3);
        
        Checkout_Offer__c offer4 = new Checkout_Offer__c(Name = 'TRANSFER_PROCESS_DATA',
                                                         OfferCode__c = 'TRANSFER_PROCESS_DATA');
        CheckoutOffer.add(offer4);
        
        
        insert CheckoutOffer;
        
        
        
        List < WebService__c > endpointURLs = new List < WebService__c > ();
        
        HW_VAT__c HW_vat = new HW_VAT__c(Name = 'VatRate',
                                         VAT_Rate_Percentage__c = 25);
        insert HW_vat;
        
        
        WebService__c wbTest = new WebService__c(Name = 'MCONLINE_ActivateOrder',  
                                                 EndpointURL__c = 'https://apimarket-test.eam.telia.se/token',
                                                 Content_Type__c = 'application/x-www-form-urlencoded', 
                                                 userName__c = 'imStV5FaBfKqSeGuR6ff_BJR6Tga',
                                                 password__c = 'UAEkMX1YKQbplxPXhPVdcd2uxDEa', 
                                                 Authorization__c = 'Basic aW1TdFY1RmFCZktxU2VHdVI2ZmZfQkpSNlRnYTpVQUVrTVgxWUtRYnBseFBYaFBWZGNkMnV4REVh');
        endpointURLs.add(wbTest);
        WebService__c wbTest1 = new WebService__c(Name = 'MCONL_OrderProcessor',  
                                                  EndpointURL__c = 'https://apimarket-test.eam.telia.se/token',
                                                  Content_Type__c = 'application/x-www-form-urlencoded', 
                                                  userName__c = 'imStV5FaBfKqSeGuR6ff_BJR6Tga',
                                                  password__c = 'UAEkMX1YKQbplxPXhPVdcd2uxDEa', 
                                                  Authorization__c = 'Basic aW1TdFY1RmFCZktxU2VHdVI2ZmZfQkpSNlRnYTpVQUVrTVgxWUtRYnBseFBYaFBWZGNkMnV4REVh');
        endpointURLs.add(wbTest1);
        WebService__c wbTest2 = new WebService__c(Name = 'TeliaSE_MadamAuthenticationWS',  
                                                  EndpointURL__c = 'https://apimarket-test.eam.telia.se/token',
                                                  Content_Type__c = 'application/x-www-form-urlencoded', 
                                                  userName__c = 'imStV5FaBfKqSeGuR6ff_BJR6Tga',
                                                  password__c = 'UAEkMX1YKQbplxPXhPVdcd2uxDEa', 
                                                  Authorization__c = 'Basic aW1TdFY1RmFCZktxU2VHdVI2ZmZfQkpSNlRnYTpVQUVrTVgxWUtRYnBseFBYaFBWZGNkMnV4REVh');
        
        
        endpointURLs.add(wbTest2);
        
        WebService__c wbTest3 = new WebService__c(Name = 'MCONLINE_ActivateOrder_UAT',  
                                                  EndpointURL__c = 'https://apimarket-at.eam.telia.se/orderprocessor-b2b/v1.0.0/create-order/',
                                                  Content_Type__c = 'application/x-www-form-urlencoded', 
                                                  userName__c = 'imStV5FaBfKqSeGuR6ff_BJR6Tga',
                                                  password__c = 'UAEkMX1YKQbplxPXhPVdcd2uxDEa', 
                                                  Authorization__c = 'Basic aW1TdFY1RmFCZktxU2VHdVI2ZmZfQkpSNlRnYTpVQUVrTVgxWUtRYnBseFBYaFBWZGNkMnV4REVh');
        endpointURLs.add(wbTest3);
        WebService__c wbTest4 = new WebService__c(Name = 'MCONL_OrderProcessor_UAT',  
                                                  EndpointURL__c = 'https://apimarket-at.eam.telia.se/customer-order-data/v2.12.0/orders',
                                                  Content_Type__c = 'application/x-www-form-urlencoded', 
                                                  userName__c = 'imStV5FaBfKqSeGuR6ff_BJR6Tga',
                                                  password__c = 'UAEkMX1YKQbplxPXhPVdcd2uxDEa', 
                                                  Authorization__c = 'Basic aW1TdFY1RmFCZktxU2VHdVI2ZmZfQkpSNlRnYTpVQUVrTVgxWUtRYnBseFBYaFBWZGNkMnV4REVh');
        endpointURLs.add(wbTest4);
        WebService__c wbTest5 = new WebService__c(Name = 'TeliaSE_MadamAuthenticationWS_UAT',  
                                                  EndpointURL__c = 'https://apimarket-at.eam.telia.se/token',
                                                  Content_Type__c = 'application/x-www-form-urlencoded', 
                                                  userName__c = 'imStV5FaBfKqSeGuR6ff_BJR6Tga',
                                                  password__c = 'UAEkMX1YKQbplxPXhPVdcd2uxDEa', 
                                                  Authorization__c = 'Basic aW1TdFY1RmFCZktxU2VHdVI2ZmZfQkpSNlRnYTpVQUVrTVgxWUtRYnBseFBYaFBWZGNkMnV4REVh');
        endpointURLs.add(wbTest5);
        WebService__c wbTest6 = new WebService__c(Name = 'MCONLINE_ActivateOrder_Mock',  
                                                  EndpointURL__c = 'https://run.mocky.io/v3/da074a90-216b-43eb-8d46-0aecf624dd87',
                                                  Content_Type__c = 'application/x-www-form-urlencoded', 
                                                  userName__c = 'imStV5FaBfKqSeGuR6ff_BJR6Tga',
                                                  password__c = 'UAEkMX1YKQbplxPXhPVdcd2uxDEa', 
                                                  Authorization__c = 'Basic aW1TdFY1RmFCZktxU2VHdVI2ZmZfQkpSNlRnYTpVQUVrTVgxWUtRYnBseFBYaFBWZGNkMnV4REVh');
        
        endpointURLs.add(wbTest6);                                         
        
        
        
        insert endpointURLs;
        
        
        
        salesManager = Test_DataFactory.createAdminUser();
        salesManager.ForecastEnabled = true;
        salesManager.Bypass_VR__c = true;
        insert salesManager;
        
        Account acc = new Account();
        acc.Name='TestAccount';
        acc.Org_Nr__c =  '1234567890';
        //acc.CreatedDate = Date.today().addDays(-30);
        
        Insert acc;
        
        RecordType rt1 = [Select id,name, DeveloperName from RecordType where Name='Ramavtal'];  
        Contract contr=new Contract();
        contr.Name='Test';
        contr.AccountId=acc.id;
        contr.Status='Draft';
        contr.Solution_Area__c='Vxl';
        contr.StartDate=Date.today();
        contr.ContractTerm=24;
        contr.recordtypeId = rt1.id;
        insert contr;
        
        contr.Status='Active';
        System.runAs(salesManager){update contr;}
        
        
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        
        vlocity_cmt__AttributeCategory__c trr = new vlocity_cmt__AttributeCategory__c();
        trr.Name = 'attr';
        trr.vlocity_cmt__Code__c = 'ATTR';
        trr.vlocity_cmt__DisplaySequence__c = 1;
        insert trr;
        
        List<vlocity_cmt__Attribute__c> attrList = new List<vlocity_cmt__Attribute__c>();
        vlocity_cmt__Attribute__c attr = new vlocity_cmt__Attribute__c();
        attr.vlocity_cmt__Code__c = 'agentList1_cdgIdentifyingNumber';
        attr.vlocity_cmt__AttributeCategoryId__c = trr.Id;
        attrList.add(attr);
        
        vlocity_cmt__Attribute__c attr1 = new vlocity_cmt__Attribute__c();
        attr1.vlocity_cmt__Code__c = 'agentList2_cdgIdentifyingNumber';
        attr1.vlocity_cmt__AttributeCategoryId__c = trr.Id;
        attrList.add(attr1);
        
        vlocity_cmt__Attribute__c attr2 = new vlocity_cmt__Attribute__c();
        attr2.vlocity_cmt__Code__c = 'usergroup1_action';
        attr2.vlocity_cmt__AttributeCategoryId__c = trr.Id;
        attrList.add(attr2);
        
        vlocity_cmt__Attribute__c attr3 = new vlocity_cmt__Attribute__c();
        attr3.vlocity_cmt__Code__c = 'directoryField1';
        attr3.vlocity_cmt__AttributeCategoryId__c = trr.Id;
        attrList.add(attr3); 
        vlocity_cmt__Attribute__c attr4 = new vlocity_cmt__Attribute__c();
        attr4.vlocity_cmt__Code__c = 'usergroup2_action';
        attr4.vlocity_cmt__AttributeCategoryId__c = trr.Id;
        attrList.add(attr4);
        
        insert attrList;
        
        Order Ord = new Order();
        Ord.Account = acc;
        Ord.EffectiveDate = system.today()-12;
        Ord.Status = 'Draft';
        Ord.BillingCountry = 'Sweden';
        Ord.Contract = contr;
        Ord.vlocity_cmt__BillingName__c='TestingSuneel';
        Ord.OrderProcessor_ResponseStatusCode__c = '200';
        Ord.Pricebook2Id=stdPriceBookRecId;
        Ord.AccountId=acc.Id;
        
        insert Ord;
        List<Product2> prods=new List<Product2>();
        Product2 prod=new Product2();
        prod.ProductCode='1234';
        prod.C2BC_Category__c='Goods';
        prod.C2BC_Subcategory__c='mobiledevice';
        prod.Name='Phone';
        
        prods.add(prod);
        
        Product2 prod1=new Product2();
        prod1.ProductCode='12345';
        prod1.C2BC_Category__c='mobilevoicesubscription';
        prod1.C2BC_Subcategory__c='voice';
        prod1.Name='Sub';
        
        prods.add(prod1);
        
        insert prods;
        
        
        
        
        PricebookEntry objpricebookentry =new PricebookEntry();
        objpricebookentry.Product2ID = prods[0].id;
        objpricebookentry.Pricebook2ID = stdPriceBookRecId;
        objpricebookentry.UnitPrice=23.50;
        objpricebookentry.UseStandardPrice=false;
        objpricebookentry.isActive=true;//Add this line
        insert objpricebookentry;
        
        
        PricebookEntry objpricebookentry1 =new PricebookEntry();
        objpricebookentry1.Product2ID = prods[1].id;
        objpricebookentry1.Pricebook2ID = stdPriceBookRecId;
        objpricebookentry1.UnitPrice=23.50;
        objpricebookentry1.UseStandardPrice=false;
        objpricebookentry1.isActive=true;//Add this line
        insert objpricebookentry1;
        
        
        
        List<OrderItem> olis=new List<OrderItem>();
        OrderItem oli=new OrderItem();
        oli.product2Id=[select id from Product2 where name ='Phone' limit 1]?.Id;
        oli.vlocity_cmt__RecurringCharge__c=180;
        oli.vlocity_cmt__OneTimeCharge__c = 190;
        oli.orderId=Ord.Id;
        oli.MCONL_multiSubscriptionAssetIdentifier__c='123';
        oli.PricebookEntryId=objpricebookentry.Id;
        oli.UnitPrice=12;
        oli.Quantity=1;
        olis.add(oli);
        
        OrderItem oli1=new OrderItem();
        oli1.product2Id=[select id from Product2 where name ='Sub' limit 1]?.Id;
        oli1.orderId=Ord.Id;
        oli.vlocity_cmt__OneTimeCharge__c = 200;
        oli1.MCONL_multiSubscriptionAssetIdentifier__c='123';
        oli1.PricebookEntryId=objpricebookentry1.Id;
        oli1.UnitPrice=12;
        oli1.Quantity=1;
        olis.add(oli1);
        
        insert olis;
        
    }
    
    @istest
    static  void test() {
        
        //SETMOCK
        Test.setMock(HttpCalloutMock.class, new VlocityDiagnosticWizardTestHTTPCallout(
            201,
            'OK',
            '{}'
        ));
        
        //Attempt 1 - No fileName
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        Account acc = new Account();
        acc.Name='TestAccount';
        acc.Org_Nr__c =  '1234566890';
        //acc.CreatedDate = Date.today().addDays(-30);
        System.runAs(Test_DataFactory.getByPassUser()){
            insert acc;
        }
        
        Contract contr= [Select id from Contract Where Name= 'Test' LIMIT 1];
        
        
        list <Order> ordList = new list <Order>();
        Order Ord = new Order();
        Ord.Account = acc;
        Ord.EffectiveDate = system.today()-12;
        Ord.Status = 'Draft';
        Ord.BillingCountry = 'Sweden';
        Ord.Contract = contr;
        ord.OrderProcessor_ResponseStatusCode__c = '200';
        ordList.add(Ord);
        
        list <Order> ordList1 = new list <Order>();
        Order Ord1 = new Order();
        Ord1.Account = acc;
        Ord1.EffectiveDate = system.today()-12;
        Ord1.Status = 'Draft';
        Ord1.BillingCountry = 'Sweden';
        Ord1.Contract = contr;
        ord1.OrderProcessor_ResponseStatusCode__c = '200';
        ordList1.add(Ord1);
        
        
        order__c orc= new order__c();
        orc.MCOnline_Number_of_Days__c=7;
        orc.Name='MCOnline Order Inactive Days';
        insert orc;
        
        List <Order> orderList = new List <Order>();
        
        order m= new order(Name = 'Order',AccountId= acc.id,status = 'Draft',EffectiveDate = system.today(),
                           Pricebook2Id = stdPriceBookRecId, OrderProcessor_ResponseStatusCode__c = '200');
        insert m;
        Datetime yesterday = Datetime.now().addDays(-13);
        
        
        List<sObject> types=new List<sObject>();
        SObject sObj = [SELECT Id, SobjectType, DeveloperName FROM RecordType WHERE IsActive = TRUE and SobjectType = 'vlocity_cmt__ObjectClass__c' and DeveloperName = 'ObjectType' LIMIT 1];   
        vlocity_cmt__ObjectClass__c FiberType = new vlocity_cmt__ObjectClass__c(Name = 'Fiber Base Product Spec Type', vlocity_cmt__ObjectApiName__c = 'Product2', RecordTypeId = sObj.Id);
        
        types.add(FiberType);
        
        insert types;
        
        
        
        
        Account accountInfo = acc; 
        
        Test.setCreatedDate(m.Id, yesterday);  
        m.AccountId = accountInfo.Id;
        m.vlocity_cmt__OrderStatus__c = 'Draft';
        update m;
        Quote testQuote = new Quote();
        Id userId = Userinfo.getUserId();
        Seller__c sellerInfo = Test_DataFactory.createBusinessAreaManagerSeller(userId);
        insert sellerInfo;
        Opportunity testOpportunity = Test_DataFactory.createSmeOpportunity();
        testOpportunity.AccountId = accountInfo.Id;
        insert testOpportunity;
        RecordType rt = [Select id,name, DeveloperName from RecordType where Name='Contract Quote'];
        
        
        Contract con=[select id,recordTypeId,status,AccountId from Contract where RecordType.Name = 'Ramavtal' limit 1];
        /*con.status = 'Active';
con.AccountId = accountInfo.Id;
update con;*/
        
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
        prod[4].Parent_Family__c='Online Order';
        prod[5].name='Promo_Landlord';
        prod[0].ProductCode='Promo_Landlord';
        prod[5].vlocity_cmt__ObjectTypeId__c=FiberType.id;    
        prod[6].name='Promo_VoIP_LL';
        prod[0].ProductCode='Promo_VoIP_LL';
        prod[6].vlocity_cmt__ObjectTypeId__c=FiberType.id;    
        prod[6].Parent_Family__c='Online Order';
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
        orderItem.vlocity_cmt__JSONAttribute__c = '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t7a000008E4a2AAC","attributeid__c":"a367Z000000PDG3QAO","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"EXT_REF_ONLINE","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"External_reference","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a337a000000TdfrAAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"external_ref"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t7a000008E4a2AAC","attributeid__c":"a367Z000000PDG5QAO","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"Email","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Email","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a337a000000TdfqAAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"rajkant020@gmail.com"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t7a000008E4a2AAC","attributeid__c":"a367Z000000PDG6QAO","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ICC_number","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"ICC_number","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a337a000000TdfsAAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"icc"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t7a000008E4a2AAC","attributeid__c":"a367Z000000PDG8QAO","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"MSISDN","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"MSISDN","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a337a000000TdftAAC","isrequired__c":true,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"7620896789"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t7a000008E4a2AAC","attributeid__c":"a367Z000000PDG9QAO","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"SIM_Format","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"SIM_Format","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a337a000000TdfuAAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"blank","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"displayText":"blank","id":"e9a88636-0eae-7448-386b-886496de5ac1","sequence":3,"value":"blank"}],"values":[{"displayText":"esim","id":"c32c567c-c6f4-eaa8-0e16-a1da1dd42195","sequence":1,"value":"esim"},{"displayText":"simcard","id":"74fe4898-fa10-3c39-f562-d2ba40b65ab4","sequence":2,"value":"simcard"},{"displayText":"blank","id":"e9a88636-0eae-7448-386b-886496de5ac1","sequence":3,"value":"blank"}],"selectedItem":{"displayText":"blank","id":"e9a88636-0eae-7448-386b-886496de5ac1","sequence":3,"value":"keep"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t7a000008E4a2AAC","attributeid__c":"a367Z000000PDGCQA4","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"TELIA_COMM_PERIOD","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment_period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":0,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a337a000000TdfpAAC","isrequired__c":true,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"0","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"displayText":"0","id":"e7e1d1c5-bb4e-0ca1-bd82-5f9b77216274","sequence":1,"value":"0"}],"values":[{"displayText":"0","id":"e7e1d1c5-bb4e-0ca1-bd82-5f9b77216274","sequence":1,"value":"0"},{"displayText":"12","id":"2946e54d-419b-62dd-358f-793ab153bed7","sequence":2,"value":"12"},{"displayText":"24","id":"2a44f701-88d4-3537-1a61-7a6a18991fe2","sequence":3,"value":"24"},{"displayText":"36","id":"f2b151d6-7c45-5a73-9d42-f32e81785d14","sequence":3,"value":"36"}],"selectedItem":{"displayText":"24","id":"2a44f701-88d4-3537-1a61-7a6a18991fe2","sequence":3,"value":"24"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t7a000008E4a2AAC","attributeid__c":"a367Z000000PDGHQA4","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"User_name","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"User_name","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a337a000000TdfvAAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"rajnroy"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t7a000008E4a2AAC","attributeid__c":"a367Z000000PDGIQA4","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"e-SIM_Method","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"e-SIM_Method","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a337a000000TdfwAAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"email","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"displayText":"email","id":"8a7f3b12-cf4b-413c-9ac3-bc851a3651e0","sequence":1,"value":"email"}],"values":[{"displayText":"email","id":"8a7f3b12-cf4b-413c-9ac3-bc851a3651e0","sequence":1,"value":"email"}],"selectedItem":{"displayText":"email","id":"8a7f3b12-cf4b-413c-9ac3-bc851a3651e0","sequence":1,"value":"email"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CcPWGQA3","attributeid__c":"a369E000000VhIXQA0","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"agentList1_cdgIdentifyingNumber","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"agentList1_cdgIdentifyingNumber","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JxH3QAK","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CcPWGQA3","attributeid__c":"a369E000000VhI3QAK","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"Användarnamn","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Användarnamn","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JzcUQAS","isrequired__c":true,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test1"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CcPWGQA3","attributeid__c":"a369E000000VhIcQAK","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"agentList1_cdgAgentLoggedIn","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"agentList1_cdgAgentLoggedIn","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JzcoQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"N","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"N","sequence":2,"id":"e537051a-0eba-2764-e4a9-e5e472a920b6","displayText":"N"}],"values":[{"value":"Y","sequence":1,"id":"a936e2b9-92e3-7bc7-4ab9-cd0ad6f36a92","displayText":"Y"},{"value":"N","sequence":2,"id":"e537051a-0eba-2764-e4a9-e5e472a920b6","displayText":"N"}],"selectedItem":{"value":"N","sequence":2,"id":"e537051a-0eba-2764-e4a9-e5e472a920b6","displayText":"N"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CcPWGQA3","attributeid__c":"a369E000000VhIDQA0","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"roleUser","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"roleUser","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JzcPQAS","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedatatype__c":"Checkbox","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Checkbox","default":false,"value":true},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CcPWGQA3","attributeid__c":"a369E000000VhIwQAK","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"agentList3_cdgAgentLoggedIn","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"agentList3_cdgAgentLoggedIn","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JzctQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"N","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"N","sequence":2,"id":"f81d7519-4c1c-17d4-f510-06b21a28485d","displayText":"N"}],"values":[{"value":"Y","sequence":1,"id":"7814e6e4-8545-ef1a-9018-ebaf46f86b1e","displayText":"Y"},{"value":"N","sequence":2,"id":"f81d7519-4c1c-17d4-f510-06b21a28485d","displayText":"N"}],"selectedItem":{"value":"N","sequence":2,"id":"f81d7519-4c1c-17d4-f510-06b21a28485d","displayText":"N"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CcPWGQA3","attributeid__c":"a369E000000VhISQA0","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"callingLineType","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"callingLineType","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JzcZQAS","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"MOBILE","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"MOBILE","sequence":1,"id":"2b666904-3699-95e9-eadc-cfb35cbfa5bd","displayText":"MOBILE"}],"values":[{"value":"MOBILE","sequence":1,"id":"2b666904-3699-95e9-eadc-cfb35cbfa5bd","displayText":"MOBILE"},{"value":"FIXED","sequence":2,"id":"7583a0bd-2aba-7c27-6875-263df83f4d51","displayText":"FIXED"},{"value":"COMPANY_NUMBER","sequence":3,"id":"ca01acfe-6e03-4432-bc4a-c31cdac932c5","displayText":"COMPANY_NUMBER"}],"selectedItem":{"value":"MOBILE","sequence":1,"id":"2b666904-3699-95e9-eadc-cfb35cbfa5bd","displayText":"MOBILE"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CcPWGQA3","attributeid__c":"a369E000000VhI8QAK","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"roleCompanyAdmin","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"roleCompanyAdmin","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JzcjQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":"false","valuedatatype__c":"Checkbox","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Checkbox","default":false,"value":false},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"a4s9E000000V12yQAC","attributeid__c":"a369E000000VhImQAK","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"agentList2_cdgAgentLoggedIn","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"agentList2_cdgAgentLoggedIn","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JwsrQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"N","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"N","sequence":2,"id":"0045b39d-0b10-f562-eb7b-da99d64af5b1","displayText":"N"}],"values":[{"value":"Y","sequence":1,"id":"1ab58de7-3d22-cd11-d990-49e7925fa0aa","displayText":"Y"},{"value":"N","sequence":2,"id":"0045b39d-0b10-f562-eb7b-da99d64af5b1","displayText":"N"}],"selectedItem":{"value":"N","sequence":2,"id":"0045b39d-0b10-f562-eb7b-da99d64af5b1","displayText":"N"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CcPWGQA3","attributeid__c":"a369E000000VhHyQAK","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"instanceId","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"instanceId","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JzceQAC","isrequired__c":true,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test1"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CcPWGQA3","attributeid__c":"a369E000000VhIhQAK","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"agentList2_cdgIdentifyingNumber","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"agentList2_cdgIdentifyingNumber","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JxH4QAK","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CcPWGQA3","attributeid__c":"a369E000000VhIrQAK","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"agentList3_cdgIdentifyingNumber","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"agentList3_cdgIdentifyingNumber","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JxH5QAK","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CbbHaQAJ","attributeid__c":"a369E000000Vfs5QAC","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"appartmentNumber","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"appartmentNumber","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JwbYQAS","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test1"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CbbHaQAJ","attributeid__c":"a369E000000VfsAQAS","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"careOf","attributeconfigurable__c":true,"attributedisplaysequence__c":"11","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"careOf","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JwbZQAS","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test1"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CbbHaQAJ","attributeid__c":"a369E000000VfrlQAC","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"city","attributeconfigurable__c":true,"attributedisplaysequence__c":"6","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"city","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JwbaQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test1"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CbbHaQAJ","attributeid__c":"a369E000000VfrqQAC","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"country","attributeconfigurable__c":true,"attributedisplaysequence__c":"7","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"country","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JwbbQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test1"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CbbHaQAJ","attributeid__c":"a369E000000Vfs0QAC","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"entrance","attributeconfigurable__c":true,"attributedisplaysequence__c":"9","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"entrance","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JwbcQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test1"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CbbHaQAJ","attributeid__c":"a369E000000VfrCQAS","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"firstName","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"firstName","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JwbdQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test1"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CbbHaQAJ","attributeid__c":"a369E000000VfrMQAS","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"lastName","attributeconfigurable__c":true,"attributedisplaysequence__c":"2","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"lastName","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JwbeQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test1"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CbbHaQAJ","attributeid__c":"a369E000000VfrvQAC","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"pointid","attributeconfigurable__c":true,"attributedisplaysequence__c":"8","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"pointid","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JwbfQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test1"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CbbHaQAJ","attributeid__c":"a369E000000VfrgQAC","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"postalCode","attributeconfigurable__c":true,"attributedisplaysequence__c":"5","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"postalCode","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JwbgQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test1"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CbbHaQAJ","attributeid__c":"a369E000000VfrWQAS","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"street","attributeconfigurable__c":true,"attributedisplaysequence__c":"3","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"street","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JwbhQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test1"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CbbHaQAJ","attributeid__c":"a369E000000VfrbQAC","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"streetNumber","attributeconfigurable__c":true,"attributedisplaysequence__c":"4","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"streetNumber","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JwbiQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test1"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000BLYO6QAP","attributeid__c":"a369E000000ZdqvQAC","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"External_reference","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"External_reference","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000NM06QAG","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"ext"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000BLYO6QAP","attributeid__c":"a369E000000XZDwQAO","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"Contact_telephone_number","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Contact_telephone_number","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000NLzzQAG","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"81238823"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000BLYO6QAP","attributeid__c":"a369E000000XZDmQAO","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"Current_MSISDN","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Current_MSISDN","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000NM00QAG","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"234283482"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000BLYO6QAP","attributeid__c":"a369E000000ZbOTQA0","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"Current_owner_last_name","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Current_owner_last_name","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000NM05QAG","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000BLYO6QAP","attributeid__c":"a369E000000XZDhQAO","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"Temporary_MSISDN","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Temporary_MSISDN","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000NM07QAG","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000BLYO6QAP","attributeid__c":"a367Z000000PDGHQA4","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"User_name","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"User_name","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000NM08QAG","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000BLYO6QAP","attributeid__c":"a369E000000O1pGQAS","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ownerPhoneNumber","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"ownerPhoneNumber","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000NM09QAG","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000BLYO6QAP","attributeid__c":"a369E000000XZE6QAO","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"Current_owner_Organization","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Current_owner_Organization","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000NM01QAG","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000BLYO6QAP","attributeid__c":"a369E000000XZE1QAO","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"Current_owner_SSN","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Current_owner_SSN","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000NM02QAG","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000BLYO6QAP","attributeid__c":"a369E000000XZEBQA4","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"Current_owner_email","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Current_owner_email","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000NM03QAG","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000BLYO6QAP","attributeid__c":"a369E000000ZbOOQA0","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"Current_owner_first_name","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Current_owner_first_name","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000NM04QAG","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test"},"$$AttributeDefinitionEnd$$":null}]}';
            orderItem.vlocity_cmt__RecurringCharge__c = 0;
        orderItem.vlocity_cmt__AttributeSelectedValues__c = '{"roleTeamLead":"abc","roleCompanyAdmin":"test","agentList1_cdgIdentifyingNumber":"12345","agentList1_cdgAgentLoggedIn":"true","agentList2_cdgIdentifyingNumber":"123455","agentList2_cdgAgentLoggedIn":"true","agentList3_cdgIdentifyingNumber":"1234555","agentList3_cdgAgentLoggedIn":"true","agentList4_cdgIdentifyingNumber":"12345555","agentList4_cdgAgentLoggedIn":"true","agentList5_cdgIdentifyingNumber":"123455555","agentList5_cdgAgentLoggedIn":"false","agentList6_cdgIdentifyingNumber":"1234555555","agentList6_cdgAgentLoggedIn":"false","agentList7_cdgIdentifyingNumber":"123456666","agentList7_cdgAgentLoggedIn":"false","agentList8_cdgIdentifyingNumber":"123456789","agentList8_cdgAgentLoggedIn":"true","agentList10_cdgIdentifyingNumber":"12323442","agentList10_cdgAgentLoggedIn":"false","SIM_Format":"keep","ICC_number":"82349283423432","e-SIM_Method":"email","Email":"ag@gmail.com","User_name":"testUser","Current_owner_SSN":"orgSSN","Current_owner_Organization":"org","Current_owner_last_name":"lastName","fixedPhoneNumber":"2757283584","firstName":"fts","lastName":"lst","street":"street","streetNumber":"46","postalCode":"6235633","country":"Sweden"}';
        orderItem.MCOnline_CommitmentPeriod__c = '0';
        orderItem.MCOnline_CommitmentUnit__c = 'Month';
        orderItem.vlocity_cmt__OneTimeCharge__c = 190;
        orderItem.Quantity = 1;
        orderItem.vlocity_cmt__Action__c = 'Add';   
        orderItem.vlocity_cmt__ParentItemId__c = '8024E000002GqmbQAC';
        orderItem.OrderId = m.Id;
        orderItem.UnitPrice = 1;
        orderItem.PricebookEntryId = objpricebookentry.Id;
        Insert orderItem;
        system.assert(orderItem.Id != null);
        
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
        Map<String, Object> conMap = new Map<String, Object>();
        Map<String, Object> salesMap = new Map<String, Object>();
        Map<String, Object> shipping = new Map<String, Object>();
        Map<String, Object> Billing = new Map<String, Object>();
        
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
        String orderNumber = [Select orderNumber from Order where Id =: m.Id].orderNumber;
        //List<SObject> updatedquoteItemList = new List<sObject>();
        Vlocity_cmt.JSONAttributeSupport jsonSupport = new Vlocity_cmt.JSONAttributeSupport();
        
        
        vlocity_cmt.PricingPlanService.putInPricingContext('Parent', quoteSObject);
        vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList', quoteItemList);
        system.assert(quoteSObject != null);
        
        Set<String> rangeAttrs = new Set<String>();
        rangeAttrs.add('abc');
        rangeAttrs.add('bcd');
        rangeAttrs.add('def');
        
        conMap.put('contactMethod', 'test');
        conMap.put('emailAddress', 'test@test.com');
        conMap.put('firstName', 'test');
        conMap.put('lastName', 'test');
        conMap.put('phoneNumber', '1234321');
        salesMap.put('resellerId', 'test');
        salesMap.put('salesChannel', 'test');
        salesMap.put('salesChannelId', 'test');
        salesMap.put('userId', 'test');
        shipping.put('shippingcity', 'test');
        shipping.put('shippingcountry', 'test');
        shipping.put('shippingpointId', 'test');
        shipping.put('shippingpostalcode', 'test');
        shipping.put('shippingstate', 'test');
        shipping.put('shippingstreet', 'test');
        Billing.put('billingAccountId','test');
        
        input18.put('childProducts',prod[0]);
        input19.add(input18);
        input16.put('ProductCode',prod[0]);
        input16.put('childProducts',input19);
        input17.add(input16);
        input14.put('ProductCode',prod[0]);
        input14.put('childProducts',input17);
        input15.add(input14);
        input12.put('ProductCode',prod[0]);
        input12.put('priceResult',input15);
        input12.put('childProducts',input17);
        input13.add(input12);
        input.put('Catalog','RangeAttributePricingMatrix');
        input8.put('ProductCode',prod[0]);
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
        input11.put('ProductCode',prod[0]);
        input11.put('priceResult',input10);
        input11.put('childProducts', input10);
        input4.put('offer',input11);
        input3.put('offerDetails',input4);
        input2.put('result',input3);
        input2.put('messageMap',input3);
        input.put('HA_GetOffersFromDgCommerce',input2);  
        input.put('OrderNumber',orderNumber);
        input.put('orderId',m.id);
        input.put('contactDetails',conMap);
        input.put('salesTracking',salesMap);
        input.put('shippingAddress',shipping);
        Billing.put('billingAccountDetails',Billing);
        input.put('RA_Order_Processor', input2);
        
        
        
        MCOnline_OrderProcessor_V3 orderProcessor = new MCOnline_OrderProcessor_V3();
        MCOnline_OrderProcessor_V3.submitOrder(m.id, input, output);
        //orderProcessor.invokeMethod('submitOrder',input,output,options);
        //orderProcessor.invokeMethod('getOrderDetails',input,output,options);
        MCOnline_OrderProcessor_V3.submitOrder(m.id, input, output);
        MCOnline_OrderProcessor_V3.activateOrder(orderNumber,m,output,options);
        MCOnline_OrderProcessor_V3.BilliantSubscription testBilliant = new MCOnline_OrderProcessor_V3.BilliantSubscription();
        MCOnline_OrderProcessor_V3.getAttribute(orderItem.vlocity_cmt__JSONAttribute__c,orderItem.vlocity_cmt__JSONAttribute__c );
        testBilliant.serviceCode = '1';
        testBilliant.subscriptionType = '21';
        system.assert(true);
        Test.stopTest();
    }
    
    @istest
    static  void test2() {
        
        //SETMOCK
        Test.setMock(HttpCalloutMock.class, new VlocityDiagnosticWizardTestHTTPCallout(
            200,
            'OK',
            '{}'
        ));
        
        //Attempt 1 - No fileName
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        Account acc = new Account();
        acc.Name='TestAccount';
        acc.Org_Nr__c =  '1237567890';
        //acc.CreatedDate = Date.today().addDays(-30);
        System.runAs(Test_DataFactory.getByPassUser()){
            insert acc;
        }
        
        Contract contr= [Select id from Contract Where Name= 'Test' LIMIT 1];
        
        
        list <Order> ordList = new list <Order>();
        Order Ord = new Order();
        Ord.Account = acc;
        Ord.EffectiveDate = system.today()-12;
        Ord.Status = 'Draft';
        Ord.BillingCountry = 'Sweden';
        Ord.Contract = contr;
        ord.OrderProcessor_ResponseStatusCode__c = '200';
        ordList.add(Ord);
        
        
        list <Order> ordList1 = new list <Order>();
        Order Ord1 = new Order();
        Ord1.Account = acc;
        Ord1.EffectiveDate = system.today()-12;
        Ord1.Status = 'Draft';
        Ord1.BillingCountry = 'Sweden';
        Ord1.Contract = contr;
        ord1.OrderProcessor_ResponseStatusCode__c = '200';
        ordList1.add(Ord1);
        
        
        order__c orc= new order__c();
        orc.MCOnline_Number_of_Days__c=7;
        orc.Name='MCOnline Order Inactive Days';
        insert orc;
        
        List <Order> orderList = new List <Order>();
        
        order m= new order(Name = 'Order',AccountId= acc.id,status = 'Draft',EffectiveDate = system.today(),
                           Pricebook2Id = stdPriceBookRecId, OrderProcessor_ResponseStatusCode__c = '200');
        insert m;
        Datetime yesterday = Datetime.now().addDays(-13);
        
        
        List<sObject> types=new List<sObject>();
        SObject sObj = [SELECT Id, SobjectType, DeveloperName FROM RecordType WHERE IsActive = TRUE and SobjectType = 'vlocity_cmt__ObjectClass__c' and DeveloperName = 'ObjectType' LIMIT 1];   
        vlocity_cmt__ObjectClass__c FiberType = new vlocity_cmt__ObjectClass__c(Name = 'Fiber Base Product Spec Type', vlocity_cmt__ObjectApiName__c = 'Product2', RecordTypeId = sObj.Id);
        
        types.add(FiberType);
        
        Account accountInfo = acc; 
        
        Test.setCreatedDate(m.Id, yesterday);  
        m.AccountId = accountInfo.Id;
        m.vlocity_cmt__OrderStatus__c = 'Draft';
        update m;
        Quote testQuote = new Quote();
        Id userId = Userinfo.getUserId();
        Seller__c sellerInfo = Test_DataFactory.createBusinessAreaManagerSeller(userId);
        insert sellerInfo;
        Opportunity testOpportunity = Test_DataFactory.createSmeOpportunity();
        testOpportunity.AccountId = accountInfo.Id;
        insert testOpportunity;
        RecordType rt = [Select id,name, DeveloperName from RecordType where Name='Contract Quote'];
        
        
        Contract con=[select id,recordTypeId,status,AccountId from Contract where RecordType.Name = 'Ramavtal' limit 1];
        /*con.status = 'Active';
con.AccountId = accountInfo.Id;
update con;*/
        
        MCOnline_ParentBasket__c pbasket1 = new MCOnline_ParentBasket__c();
        pbasket1.TSCID__c = 'TSCID9809';
        pbasket1.AgreementId__c = con.Id;
        pbasket1.Admin__c = UserInfo.getUserId();
        pbasket1.flow__c = 'MANAGEFLOW';
        //pbasket1.Name = 'PBasket1';
        //pbasket1.OrderNumber__c = '';
        pbasket1.Account__c = acc.Id;
        pbasket1.UpdateOrderRequest__c = '';
        pbasket1.CheckoutResponse__c = '';
        //pbasket1.Order__c = order.Id;
        insert pbasket1;
        
        MCOnline_Basket__c basket1 = new MCOnline_Basket__c();
        basket1.MCOnline_Basket_Key__c = '0c33e332c0f698416833c0f15ed3a872';
        basket1.MCOnline_OfferCode__c = 'MOB_MULTI_JOBBMOBIL';
        basket1.TSCID__c = 'TSCID9808';
        basket1.MCOnline_Catalog__c = 'SUBSCRIPTIONS';
        basket1.MCOnline_AttributeJSON__c = '{"products":[{"attributes":{"userName":"test","SIM_Format":"esim","MSISDN":"1017635812","ICCNumber":"89460110191104000000","externalReference":"ERO","email":"vilbertas.soraka@teliacompany.com","eSIM_Method":"email","commitmentPeriod":"12","currentMSISDN":"732223271212","currentOwnerOrganization":"org","portinDate":"21072021","contactTelephoneNumber":"82392392323","currentOwnerSSN":"SSNB","currentOwnerEmail":"tg@gmail.com","currentOwnerFirstName":"test","currentOwnerLastName":"Kumar","ownerPhoneNumber":"673437473433","temporaryMSISDN":"923246364633","documentId":"docu","userEmail":"tg@gmail.com","billingAccount":"123456","requestedPortInDate":"12022020","currentOwnerOrgName":"TestOrg","callingLineType":"txt","agentList1_cdgIdentifyingNumber":"5623234","agentList1_cdgAgentLoggedIn":"true","agentList2_cdgAgentLoggedIn":"true","agentList3_cdgAgentLoggedIn":"true","agentList4_cdgAgentLoggedIn":"true","agentList5_cdgAgentLoggedIn":"true","agentList6_cdgAgentLoggedIn":"true","agentList7_cdgAgentLoggedIn":"true","agentList8_cdgAgentLoggedIn":"true","agentList9_cdgAgentLoggedIn":"true","agentList10_cdgAgentLoggedIn":"true","agentList2_cdgIdentifyingNumber":"2473434","agentList3_cdgIdentifyingNumber":"2473434","agentList4_cdgIdentifyingNumber":"2473434","agentList5_cdgIdentifyingNumber":"2473434","agentList6_cdgIdentifyingNumber":"2473434","agentList7_cdgIdentifyingNumber":"2473434","agentList8_cdgIdentifyingNumber":"2473434","agentList9_cdgIdentifyingNumber":"2473434","agentList10_cdgIdentifyingNumber":"2473434","instanceId":"2473434","subAgreementId":"2473434","fixedPhoneNumber":"2473434","tppdomain":"2473434","department":"2473434","costCenter":"2473434","usergroup1_name":"2473434","usergroup2_name":"2473434","usergroup3_name":"2473434","usergroup4_name":"2473434","usergroup5_name":"2473434","usergroup6_name":"2473434","usergroup7_name":"2473434","usergroup8_name":"2473434","usergroup9_name":"2473434","usergroup10_name":"2473434","subOrganizationNumber":"09852"},"displayText":"SEK 649","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"429","baseAmount":"649","chargeAmount":"649","name":"JobbMobil 120 GB","lineNumber":"0001.0001.0002","downstream_CategoryData":"F1GRUNDAVG","TeliaSE_Subscription_Type":"97","TeliaSE_Product_Category":"F1GRUNDAVG","CID":null,"C2BC_Subcategory":"voice","C2BC_Category":"mobilevoicesubscription","Ordering_System__c":"autovoice","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":null,"AO":null,"productCode":"MOB_MULTI_120_V2"},{"displayText":"SEK 29.00","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"29","baseAmount":"29","chargeAmount":"29","name":"5G","lineNumber":"0001.0002.0001","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":"network1","AO":"Yes","productCode":"MOB_5G"},{"displayText":"SEK 0","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"0","baseAmount":"0","chargeAmount":"0","name":"Spärr 118","lineNumber":"0001.0002.0003","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":"071-1","AO":"Yes","productCode":"MOB_BARRING_COLLECT_CALL_118"},{"displayText":"SEK 0","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"0","baseAmount":"0","chargeAmount":"0","name":"MMS","lineNumber":"0001.0002.0002","downstream_CategoryData":null,"TeliaSE_Subscription_Type":null,"TeliaSE_Product_Category":null,"CID":null,"C2BC_Subcategory":null,"C2BC_Category":"mobilevoicesubscription","ordering_System":"GSM-AHS","ordering_Flag":"ManageFlow","TeliaSE_Product_Service_Code":"MMS","AO":null,"productCode":"MOB_MMS"},{"attributes":{"SIM_Format":"esim","MSISDN":"1814377554","ICCNumber":"89460110191104000000","email":"vilbertas.soraka@teliacompany.com","eSIM_Method":"email","commitmentPeriod":"12"},"displayText":"SEK 49","chargeType":"Recurring","recurringFrequency":"Monthly","amount":"29","baseAmount":"49","chargeAmount":"49","name":"Jobbmobil datasim","lineNumber":"0001.0004.0001","downstream_CategoryData":"F1GRUNDAVG","TeliaSE_Subscription_Type":"KÄ-KÖ","TeliaSE_Product_Category":"F1GRUNDAVG","CID":null,"C2BC_Subcategory":"datasim","C2BC_Category":"Mobilebroadbandsubscription","ordering_System":"GSM-AHS","ordering_Flag":"Salesflow","TeliaSE_Product_Service_Code":null,"AO":"No","productCode":"MOB_MULTI_DATASIM_OFFER"}]}';
        basket1.MCOnline_Contract__c = contr.Id;
        basket1.Account__c = acc.Id;
        basket1.MCOnline_Orders__c = m.Id;
        
        basket1.Basket_Line_Relation_Id__c = '12345';
        basket1.basket_Line_Relation_Count__c = 1;
        
        basket1.MCOnline_ParentBasket__c = pbasket1.Id;
        insert basket1;
        
        
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
        prod[4].Parent_Family__c='Online Order';
        prod[5].name='Promo_Landlord';
        prod[0].ProductCode='Promo_Landlord';
        prod[5].vlocity_cmt__ObjectTypeId__c=FiberType.id;    
        prod[6].name='Promo_VoIP_LL';
        prod[0].ProductCode='Promo_VoIP_LL';
        prod[6].vlocity_cmt__ObjectTypeId__c=FiberType.id;    
        prod[6].Parent_Family__c='Online Order';
        prod[7].name='Promo_Riksnet_BB';
        prod[0].ProductCode='Promo_Riksnet_BB';
        prod[0].Ordering_System__c='autovoice';
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
        orderItem.Product2=prod[0];
        orderItem.vlocity_cmt__JSONAttribute__c = '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t7a000008E4a2AAC","attributeid__c":"a367Z000000PDG3QAO","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"EXT_REF_ONLINE","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"External_reference","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a337a000000TdfrAAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"external_ref"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t7a000008E4a2AAC","attributeid__c":"a367Z000000PDG5QAO","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"Email","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Email","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a337a000000TdfqAAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"rajkant020@gmail.com"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t7a000008E4a2AAC","attributeid__c":"a367Z000000PDG6QAO","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ICC_number","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"ICC_number","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a337a000000TdfsAAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"icc"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t7a000008E4a2AAC","attributeid__c":"a367Z000000PDG8QAO","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"MSISDN","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"MSISDN","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a337a000000TdftAAC","isrequired__c":true,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"7620896789"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t7a000008E4a2AAC","attributeid__c":"a367Z000000PDG9QAO","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"SIM_Format","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"SIM_Format","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a337a000000TdfuAAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"blank","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"displayText":"blank","id":"e9a88636-0eae-7448-386b-886496de5ac1","sequence":3,"value":"blank"}],"values":[{"displayText":"esim","id":"c32c567c-c6f4-eaa8-0e16-a1da1dd42195","sequence":1,"value":"esim"},{"displayText":"simcard","id":"74fe4898-fa10-3c39-f562-d2ba40b65ab4","sequence":2,"value":"simcard"},{"displayText":"blank","id":"e9a88636-0eae-7448-386b-886496de5ac1","sequence":3,"value":"blank"}],"selectedItem":{"displayText":"blank","id":"e9a88636-0eae-7448-386b-886496de5ac1","sequence":3,"value":"keep"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t7a000008E4a2AAC","attributeid__c":"a367Z000000PDGCQA4","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"TELIA_COMM_PERIOD","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment_period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":0,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a337a000000TdfpAAC","isrequired__c":true,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"0","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"displayText":"0","id":"e7e1d1c5-bb4e-0ca1-bd82-5f9b77216274","sequence":1,"value":"0"}],"values":[{"displayText":"0","id":"e7e1d1c5-bb4e-0ca1-bd82-5f9b77216274","sequence":1,"value":"0"},{"displayText":"12","id":"2946e54d-419b-62dd-358f-793ab153bed7","sequence":2,"value":"12"},{"displayText":"24","id":"2a44f701-88d4-3537-1a61-7a6a18991fe2","sequence":3,"value":"24"},{"displayText":"36","id":"f2b151d6-7c45-5a73-9d42-f32e81785d14","sequence":3,"value":"36"}],"selectedItem":{"displayText":"24","id":"2a44f701-88d4-3537-1a61-7a6a18991fe2","sequence":3,"value":"24"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t7a000008E4a2AAC","attributeid__c":"a367Z000000PDGHQA4","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"User_name","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"User_name","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a337a000000TdfvAAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"rajnroy"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t7a000008E4a2AAC","attributeid__c":"a367Z000000PDGIQA4","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"e-SIM_Method","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"e-SIM_Method","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a337a000000TdfwAAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"email","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"displayText":"email","id":"8a7f3b12-cf4b-413c-9ac3-bc851a3651e0","sequence":1,"value":"email"}],"values":[{"displayText":"email","id":"8a7f3b12-cf4b-413c-9ac3-bc851a3651e0","sequence":1,"value":"email"}],"selectedItem":{"displayText":"email","id":"8a7f3b12-cf4b-413c-9ac3-bc851a3651e0","sequence":1,"value":"email"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CcPWGQA3","attributeid__c":"a369E000000VhIXQA0","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"agentList1_cdgIdentifyingNumber","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"agentList1_cdgIdentifyingNumber","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JxH3QAK","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CcPWGQA3","attributeid__c":"a369E000000VhIXQA0","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"usergroup1_name","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"usergroup1_name","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JxH3QAK","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CcPWGQA3","attributeid__c":"a369E000000VhIXQA0","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"directoryField1","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"directoryField1","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JxH3QAK","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CcPWGQA3","attributeid__c":"a369E000000VhI3QAK","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"Användarnamn","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Användarnamn","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JzcUQAS","isrequired__c":true,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test1"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CcPWGQA3","attributeid__c":"a369E000000VhIcQAK","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"agentList1_cdgAgentLoggedIn","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"agentList1_cdgAgentLoggedIn","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JzcoQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"N","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"N","sequence":2,"id":"e537051a-0eba-2764-e4a9-e5e472a920b6","displayText":"N"}],"values":[{"value":"Y","sequence":1,"id":"a936e2b9-92e3-7bc7-4ab9-cd0ad6f36a92","displayText":"Y"},{"value":"N","sequence":2,"id":"e537051a-0eba-2764-e4a9-e5e472a920b6","displayText":"N"}],"selectedItem":{"value":"N","sequence":2,"id":"e537051a-0eba-2764-e4a9-e5e472a920b6","displayText":"N"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CcPWGQA3","attributeid__c":"a369E000000VhIDQA0","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"roleUser","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"roleUser","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JzcPQAS","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedatatype__c":"Checkbox","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Checkbox","default":false,"value":true},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CcPWGQA3","attributeid__c":"a369E000000VhIwQAK","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"agentList3_cdgAgentLoggedIn","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"agentList3_cdgAgentLoggedIn","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JzctQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"N","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"N","sequence":2,"id":"f81d7519-4c1c-17d4-f510-06b21a28485d","displayText":"N"}],"values":[{"value":"Y","sequence":1,"id":"7814e6e4-8545-ef1a-9018-ebaf46f86b1e","displayText":"Y"},{"value":"N","sequence":2,"id":"f81d7519-4c1c-17d4-f510-06b21a28485d","displayText":"N"}],"selectedItem":{"value":"N","sequence":2,"id":"f81d7519-4c1c-17d4-f510-06b21a28485d","displayText":"N"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CcPWGQA3","attributeid__c":"a369E000000VhISQA0","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"callingLineType","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"callingLineType","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JzcZQAS","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"MOBILE","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"MOBILE","sequence":1,"id":"2b666904-3699-95e9-eadc-cfb35cbfa5bd","displayText":"MOBILE"}],"values":[{"value":"MOBILE","sequence":1,"id":"2b666904-3699-95e9-eadc-cfb35cbfa5bd","displayText":"MOBILE"},{"value":"FIXED","sequence":2,"id":"7583a0bd-2aba-7c27-6875-263df83f4d51","displayText":"FIXED"},{"value":"COMPANY_NUMBER","sequence":3,"id":"ca01acfe-6e03-4432-bc4a-c31cdac932c5","displayText":"COMPANY_NUMBER"}],"selectedItem":{"value":"MOBILE","sequence":1,"id":"2b666904-3699-95e9-eadc-cfb35cbfa5bd","displayText":"MOBILE"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CcPWGQA3","attributeid__c":"a369E000000VhI8QAK","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"roleCompanyAdmin","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"roleCompanyAdmin","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JzcjQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":"false","valuedatatype__c":"Checkbox","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Checkbox","default":false,"value":false},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"a4s9E000000V12yQAC","attributeid__c":"a369E000000VhImQAK","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"agentList2_cdgAgentLoggedIn","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"agentList2_cdgAgentLoggedIn","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JwsrQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"N","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"N","sequence":2,"id":"0045b39d-0b10-f562-eb7b-da99d64af5b1","displayText":"N"}],"values":[{"value":"Y","sequence":1,"id":"1ab58de7-3d22-cd11-d990-49e7925fa0aa","displayText":"Y"},{"value":"N","sequence":2,"id":"0045b39d-0b10-f562-eb7b-da99d64af5b1","displayText":"N"}],"selectedItem":{"value":"N","sequence":2,"id":"0045b39d-0b10-f562-eb7b-da99d64af5b1","displayText":"N"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CcPWGQA3","attributeid__c":"a369E000000VhHyQAK","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"instanceId","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"instanceId","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JzceQAC","isrequired__c":true,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test1"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CcPWGQA3","attributeid__c":"a369E000000VhIhQAK","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"agentList2_cdgIdentifyingNumber","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"agentList2_cdgIdentifyingNumber","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JxH4QAK","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"3847583758357"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CcPWGQA3","attributeid__c":"a369E000000VhIhQAK","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"agentList4_cdgIdentifyingNumber","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"agentList4_cdgIdentifyingNumber","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JxH4QAK","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"3745637465347"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CcPWGQA3","attributeid__c":"a369E000000VhIhQAK","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"agentList5_cdgIdentifyingNumber","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"agentList5_cdgIdentifyingNumber","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JxH4QAK","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"234234242434"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CcPWGQA3","attributeid__c":"a369E000000VhIhQAK","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"agentList6_cdgIdentifyingNumber","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"agentList6_cdgIdentifyingNumber","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JxH4QAK","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"2745386435"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CcPWGQA3","attributeid__c":"a369E000000VhIhQAK","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"agentList7_cdgIdentifyingNumber","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"agentList7_cdgIdentifyingNumber","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JxH4QAK","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"274583465"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CcPWGQA3","attributeid__c":"a369E000000VhIhQAK","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"agentList8_cdgIdentifyingNumber","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"agentList8_cdgIdentifyingNumber","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JxH4QAK","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"2748264386823"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CcPWGQA3","attributeid__c":"a369E000000VhIhQAK","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"agentList9_cdgIdentifyingNumber","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"agentList9_cdgIdentifyingNumber","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JxH4QAK","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"6243662346"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CcPWGQA3","attributeid__c":"a369E000000VhIhQAK","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"agentList10_cdgIdentifyingNumber","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"agentList10_cdgIdentifyingNumber","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JxH4QAK","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"2583453"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CcPWGQA3","attributeid__c":"a369E000000VhIrQAK","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"agentList3_cdgIdentifyingNumber","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"agentList3_cdgIdentifyingNumber","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JxH5QAK","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CbbHaQAJ","attributeid__c":"a369E000000Vfs5QAC","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"appartmentNumber","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"appartmentNumber","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JwbYQAS","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test1"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CbbHaQAJ","attributeid__c":"a369E000000VfsAQAS","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"careOf","attributeconfigurable__c":true,"attributedisplaysequence__c":"11","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"careOf","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JwbZQAS","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test1"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CbbHaQAJ","attributeid__c":"a369E000000VfrlQAC","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"city","attributeconfigurable__c":true,"attributedisplaysequence__c":"6","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"city","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JwbaQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test1"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CbbHaQAJ","attributeid__c":"a369E000000VfrqQAC","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"country","attributeconfigurable__c":true,"attributedisplaysequence__c":"7","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"country","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JwbbQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test1"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CbbHaQAJ","attributeid__c":"a369E000000Vfs0QAC","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"entrance","attributeconfigurable__c":true,"attributedisplaysequence__c":"9","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"entrance","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JwbcQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test1"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CbbHaQAJ","attributeid__c":"a369E000000VfrCQAS","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"firstName","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"firstName","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JwbdQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test1"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CbbHaQAJ","attributeid__c":"a369E000000VfrMQAS","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"lastName","attributeconfigurable__c":true,"attributedisplaysequence__c":"2","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"lastName","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JwbeQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test1"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CbbHaQAJ","attributeid__c":"a369E000000VfrvQAC","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"pointid","attributeconfigurable__c":true,"attributedisplaysequence__c":"8","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"pointid","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JwbfQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test1"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CbbHaQAJ","attributeid__c":"a369E000000VfrgQAC","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"postalCode","attributeconfigurable__c":true,"attributedisplaysequence__c":"5","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"postalCode","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JwbgQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test1"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CbbHaQAJ","attributeid__c":"a369E000000VfrWQAS","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"street","attributeconfigurable__c":true,"attributedisplaysequence__c":"3","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"street","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JwbhQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test1"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000CbbHaQAJ","attributeid__c":"a369E000000VfrbQAC","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"streetNumber","attributeconfigurable__c":true,"attributedisplaysequence__c":"4","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"streetNumber","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000JwbiQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test1"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000BLYO6QAP","attributeid__c":"a369E000000ZdqvQAC","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"External_reference","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"External_reference","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000NM06QAG","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"ext"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000BLYO6QAP","attributeid__c":"a369E000000XZDwQAO","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"Contact_telephone_number","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Contact_telephone_number","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000NLzzQAG","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"81238823"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000BLYO6QAP","attributeid__c":"a369E000000XZDmQAO","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"Current_MSISDN","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Current_MSISDN","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000NM00QAG","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"234283482"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000BLYO6QAP","attributeid__c":"a369E000000ZbOTQA0","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"Current_owner_last_name","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Current_owner_last_name","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000NM05QAG","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000BLYO6QAP","attributeid__c":"a369E000000XZDhQAO","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"Temporary_MSISDN","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Temporary_MSISDN","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000NM07QAG","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000BLYO6QAP","attributeid__c":"a367Z000000PDGHQA4","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"User_name","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"User_name","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000NM08QAG","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000BLYO6QAP","attributeid__c":"a369E000000O1pGQAS","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ownerPhoneNumber","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"ownerPhoneNumber","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000NM09QAG","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000BLYO6QAP","attributeid__c":"a369E000000XZE6QAO","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"Current_owner_Organization","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Current_owner_Organization","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000NM01QAG","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000BLYO6QAP","attributeid__c":"a369E000000XZE1QAO","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"Current_owner_SSN","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Current_owner_SSN","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000NM02QAG","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000BLYO6QAP","attributeid__c":"a369E000000XZEBQA4","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"Current_owner_email","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Current_owner_email","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000NM03QAG","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t9E00000BLYO6QAP","attributeid__c":"a369E000000ZbOOQA0","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"Current_owner_first_name","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Current_owner_first_name","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000NM04QAG","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test"},"$$AttributeDefinitionEnd$$":null}]}';
            orderItem.vlocity_cmt__RecurringCharge__c = 0;
        //orderItem.vlocity_cmt__AttributeSelectedValues__c = '{"agentList1_cdgIdentifyingNumber":"12345","agentList1_cdgAgentLoggedIn":"true","agentList2_cdgIdentifyingNumber":"123455","agentList2_cdgAgentLoggedIn":"true","agentList3_cdgIdentifyingNumber":"1234555","agentList3_cdgAgentLoggedIn":"true","agentList4_cdgIdentifyingNumber":"12345555","agentList4_cdgAgentLoggedIn":"true","agentList5_cdgIdentifyingNumber":"123455555","agentList5_cdgAgentLoggedIn":"false","agentList6_cdgIdentifyingNumber":"1234555555","agentList6_cdgAgentLoggedIn":"false","agentList7_cdgIdentifyingNumber":"123456666","agentList7_cdgAgentLoggedIn":"false","agentList8_cdgIdentifyingNumber":"123456789","agentList8_cdgAgentLoggedIn":"true","agentList10_cdgIdentifyingNumber":"12323442","agentList10_cdgAgentLoggedIn":"false","SIM_Format":"keep","ICC_number":"82349283423432","e-SIM_Method":"email","Email":"ag@gmail.com","User_name":"testUser","Current_owner_SSN":"orgSSN","Current_owner_Organization":"org","Current_owner_last_name":"lastName"}';
        orderItem.MCOnline_CommitmentPeriod__c = '0';
        orderItem.vlocity_cmt__OneTimeCharge__c = 190;
        orderItem.MCOnline_CommitmentUnit__c = 'Month';
        orderItem.Quantity = 1;
        orderItem.vlocity_cmt__Action__c = 'Add';   
        orderItem.vlocity_cmt__ParentItemId__c = '8024E000002GqmbQAC';
        orderItem.OrderId = m.Id;
        orderItem.UnitPrice = 1;
        orderItem.PricebookEntryId = objpricebookentry.Id;
        Insert orderItem;
        system.assert(orderItem.Id != null);
        
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
        Map<String, Object> conMap = new Map<String, Object>();
        Map<String, Object> salesMap = new Map<String, Object>();
        Map<String, Object> shipping = new Map<String, Object>();
        Map<String, Object> Billing = new Map<String, Object>();
        
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
        String orderNumber = [Select orderNumber from Order where Id =: m.Id].orderNumber;
        //List<SObject> updatedquoteItemList = new List<sObject>();
        Vlocity_cmt.JSONAttributeSupport jsonSupport = new Vlocity_cmt.JSONAttributeSupport();
        
        
        vlocity_cmt.PricingPlanService.putInPricingContext('Parent', quoteSObject);
        vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList', quoteItemList);
        system.assert(quoteSObject != null);
        
        Set<String> rangeAttrs = new Set<String>();
        rangeAttrs.add('abc');
        rangeAttrs.add('bcd');
        rangeAttrs.add('def');
        
        conMap.put('contactMethod', 'test');
        conMap.put('emailAddress', 'test@test.com');
        conMap.put('firstName', 'test');
        conMap.put('lastName', 'test');
        conMap.put('phoneNumber', '1234321');
        salesMap.put('resellerId', 'test');
        salesMap.put('salesChannel', 'test');
        salesMap.put('salesChannelId', 'test');
        salesMap.put('userId', 'test');
        shipping.put('shippingcity', 'test');
        shipping.put('shippingcountry', 'test');
        shipping.put('shippingpointId', 'test');
        shipping.put('shippingpostalcode', 'test');
        shipping.put('shippingstate', 'test');
        shipping.put('shippingstreet', 'test');
        Billing.put('billingAccountDetails','test');
        
        input18.put('childProducts',prod[0]);
        input19.add(input18);
        input16.put('ProductCode',prod[0]);
        input16.put('childProducts',input19);
        input17.add(input16);
        input14.put('ProductCode',prod[0]);
        input14.put('childProducts',input17);
        input15.add(input14);
        input12.put('ProductCode',prod[0]);
        input12.put('priceResult',input15);
        input12.put('childProducts',input17);
        input13.add(input12);
        input.put('Catalog','RangeAttributePricingMatrix');
        input8.put('ProductCode',prod[0]);
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
        input11.put('ProductCode',prod[0]);
        input11.put('priceResult',input10);
        input11.put('childProducts', input10);
        input4.put('offer',input11);
        input3.put('offerDetails',input4);
        input2.put('result',input3);
        input.put('HA_GetOffersFromDgCommerce',input2);  
        input.put('OrderNumber',orderNumber);
        input.put('orderId',m.id);
        input.put('contactDetails',conMap);
        input.put('salesTracking',salesMap);
        input.put('shippingAddress',shipping);
        input.put('billingAccountDetails',Billing);
        
        MCOnline_OrderProcessor_V3.ShippingAddress shippingAddressObj = new MCOnline_OrderProcessor_V3.ShippingAddress();
        shippingAddressObj.apartmentNumber = '';
        shippingAddressObj.streetNumber = '';
        shippingAddressObj.name = '';
        shippingAddressObj.entrance = '';
        //shippingAddressObj.State = '';
        
        MCOnline_OrderProcessor_V3.OrderRequestWrapper orderRequestWrapperObj = new MCOnline_OrderProcessor_V3.OrderRequestWrapper();
        orderRequestWrapperObj.orderStatus = '';
        orderRequestWrapperObj.orderRequest = '';
        
        MCOnline_OrderProcessor_V3.TracingDetails tracingDetailsObj = new MCOnline_OrderProcessor_V3.TracingDetails();
        tracingDetailsObj.originApplication = '';
        tracingDetailsObj.originClientUserId = '';
        tracingDetailsObj.originServerIP = '';
        tracingDetailsObj.originTracingId = '';
        
        MCOnline_OrderProcessor_V3 orderProcessor = new MCOnline_OrderProcessor_V3();
        
        MCOnline_OrderProcessor_V3.submitOrder(m.id, input, output);
        //orderProcessor.invokeMethod('getOrderDetails',input,output,options);
        string inputstr = JSON.serialize(input);
        string outputstr = JSON.serialize(output);
        MCOnline_OrderProcessor_V3.processOrderRouterFuture(inputstr, outputstr);
        MCOnline_OrderProcessor_V3.activateOrder(orderNumber,m,output,options);
        system.assert(true);
        Set<String> idstore = new Set<String>();
        idstore.add(m.Id);
        MCOnline_OrderProcessor_V3.updateMSISDNStatusWithoutFuture(idstore);
        String data = '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t7a000008E4a2AAC","attributeid__c":"a367Z000000PDGCQA4","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"TELIA_COMM_PERIOD","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment_period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":0,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a337a000000TdfpAAC","isrequired__c":true,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"0","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"displayText":"0","id":"e7e1d1c5-bb4e-0ca1-bd82-5f9b77216274","sequence":1,"value":"0"}],"values":[{"displayText":"0","id":"e7e1d1c5-bb4e-0ca1-bd82-5f9b77216274","sequence":1,"value":"0"},{"displayText":"12","id":"2946e54d-419b-62dd-358f-793ab153bed7","sequence":2,"value":"12"},{"displayText":"24","id":"2a44f701-88d4-3537-1a61-7a6a18991fe2","sequence":3,"value":"24"},{"displayText":"36","id":"f2b151d6-7c45-5a73-9d42-f32e81785d14","sequence":3,"value":"36"}],"selectedItem":{"displayText":"24","id":"2a44f701-88d4-3537-1a61-7a6a18991fe2","sequence":3,"value":"24"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t7a000008E4a2AAC","attributeid__c":"a367Z000000PDGCQA4","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"TELIA_COMM_UNIT","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment_period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":0,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a337a000000TdfpAAC","isrequired__c":true,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"0","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"displayText":"0","id":"e7e1d1c5-bb4e-0ca1-bd82-5f9b77216274","sequence":1,"value":"0"}],"values":[{"displayText":"0","id":"e7e1d1c5-bb4e-0ca1-bd82-5f9b77216274","sequence":1,"value":"0"},{"displayText":"12","id":"2946e54d-419b-62dd-358f-793ab153bed7","sequence":2,"value":"12"},{"displayText":"24","id":"2a44f701-88d4-3537-1a61-7a6a18991fe2","sequence":3,"value":"24"},{"displayText":"36","id":"f2b151d6-7c45-5a73-9d42-f32e81785d14","sequence":3,"value":"36"}],"selectedItem":{"displayText":"24","id":"2a44f701-88d4-3537-1a61-7a6a18991fe2","sequence":3,"value":"24"}},"$$AttributeDefinitionEnd$$":null}]}';
        MCOnline_OrderProcessor_V3.getAttribute('TELIA_COMM_PERIOD', data);
        MCOnline_OrderProcessor_V3.getAttribute('TELIA_COMM_UNIT', data);
        //MCOnline_OrderProcessor_V3.submitOrder(m.id, input, output);
        Order orde=[Select id,vlocity_cmt__OrderStatus__c from Order where id=:m.Id limit 1 ];
        orde.vlocity_cmt__OrderStatus__c='ACTIVATED';
        Update orde;
        MCOnline_OrderProcessor_V3.submitOrder(orde.Id, input, output);
        Test.stopTest(); 
    }
    
    @isTest
    public static void testpopulateBND()
    {
        Id orderId=[select id from order where vlocity_cmt__BillingName__c='TestingSuneel']?.Id;
        MCOnline_OrderProcessor_V3.populateBND(orderId);
        OrderItem Item =[select id,MCONL_Additional_Charge__c from OrderItem where Product2.Name='Sub' limit 1];
        System.assertEquals('BND39', Item.MCONL_Additional_Charge__c);
    }
    
    @isTest
    public static void test3()
    {
        string orderId='729418';
        Map<String,Object> inputMap=new Map<String,Object> () ; 
        Map<String,Object> outMap=new Map<String,Object>();
        MCOnline_OrderProcessor_V3.submitOrder(orderId,inputMap,outMap);
    }
    
    @isTest
    public static void test4()
    {
        string orderId=[select id from Order limit 1]?.Id;
        Map<String,Object> inputMap=new Map<String,Object>{'orderId'=>orderId}; 
        Map<String,Object> outMap=new Map<String,Object>();
        new MCOnline_OrderProcessor_V3().invokeMethod('processOrderRouterFuture',inputMap,outMap,null);
    }
    @isTest
    public static void test5()
    {
        MCOnline_OrderProcessor_V3.Attributes att= new MCOnline_OrderProcessor_V3.Attributes();
        att.ipRangeStart=null;
        att.siteId=null;
        att.requestedPortInDate=null;
        att.currentOwnerOrgName=null;
        att.portInDate=null;
        att.fixedPhoneNumber=null;
        att.costControlAmount=null;
        string orderId=[select id from Order limit 1]?.Id;
        Map<String,Object> inputMap=new Map<String,Object>{'orderId'=>null}; 
        Map<String,Object> outMap=new Map<String,Object>();
        new MCOnline_OrderProcessor_V3().invokeMethod('processOrderRouterFuture',inputMap,outMap,null);
    }
    
    
    @isTest
    public static void testCancelledServices()
    {
        Account acc = new Account();
        acc.RecordTypeId = '012240000008l9YAAQ';
        acc.Name='TestAccount';
        acc.TSCID__c = 'TSCID_1234';
        Insert acc;
        
        Contract contr=new Contract();
        contr.Name='Test';
        contr.AccountId=acc.id;
        contr.Status='Draft';
        contr.RecordTypeId = '0121p00000114BeAAI';
        contr.Solution_Area__c='Vxl';
        contr.StartDate=Date.today();
        contr.ContractTerm=24;
        insert contr;
        
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        
        Product2 prod1 = new Product2 (vlocity_cmt__SpecificationType__c = 'Product',Ordering_System__c='autovoice', Name='Office 365', ProductCode = 'C-OFFICE-365',C2BC_Category__c = 'offerbundle',Family ='Online Order',
                                       vlocity_cmt__JSONAttribute__c='{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1l000000pixdAAA","attributeid__c":"a2s1w00000005t7AAA","attributecategoryid__c":"a2r1w0000008xvuAAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Telia Mobile Agreements","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a2p1l0000008REzAAM","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Unspecified","valuedatatype__c":"Picklist","valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"Unspecified","id":10,"displayText":"Unspecified"}],"values":[{"value":"Unspecified","id":10,"displayText":"Unspecified"},{"value":"24","id":20,"displayText":"24 months"},{"value":"36","id":30,"displayText":"36 months"}]},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1l000000pixdAAA","attributeid__c":"a2s1w00000005tMAAQ","attributecategoryid__c":"a2r1w0000008xvuAAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Telia Mobile Agreements","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a2p1l0000008RF0AAM","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Number"},"$$AttributeDefinitionEnd$$":null}]}');
        insert prod1;
        
        PricebookEntry objpricebookentry =new PricebookEntry();
        objpricebookentry.Product2ID = prod1.id;
        objpricebookentry.Pricebook2ID = stdPriceBookRecId;
        objpricebookentry.UnitPrice=23.50;
        objpricebookentry.UseStandardPrice=false;
        objpricebookentry.isActive=true;//Add this line
        insert objpricebookentry;
        
        Order order = new Order();
        order.EffectiveDate = Date.today();
        order.Status = 'Draft';
        order.AccountId = acc.Id;  
        order.ContractId = contr.Id;
        order.Pricebook2Id=stdPriceBookRecId;
        order.MCOnline_FirstName__c = 'Testing';
        order.MCOnline_LastName__c = 'class';
        insert order;
        
        list<string> orderid = new list<String>();
        orderid.add(order.Id) ;
        
        OrderItem oitem = new OrderItem();
        oitem.Product2 = prod1;
        oitem.OrderId = order.Id;
        oitem.Quantity = 1;
        oitem.MCONL_Action_Code__c = 'Delete';
        oitem.PricebookEntryId = objpricebookentry.id;
        oitem.UnitPrice=12;
        oitem.MCONL_multiSubscriptionAssetIdentifier__c='123';
        oitem.vlocity_cmt__RecurringCharge__c=180;
        oitem.vlocity_cmt__OneTimeCharge__c = 190;
        
        insert oitem;
        
        MCOnline_OrderProcessor_V3.updateCancelledServices(orderid);
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String,Object>();
        
        Test.startTest();
        new MCOnline_OrderProcessor_V3().invokeMethod('MCOnline_OrderProcessor_V3',inputMap,outMap,options);
        new MCOnline_OrderProcessor_V3().invokeMethod('logError',inputMap,outMap,options);
        new MCOnline_OrderProcessor_V3().invokeMethod('generateCustomError',inputMap,outMap,options);
        Test.stopTest();
        
    }
}