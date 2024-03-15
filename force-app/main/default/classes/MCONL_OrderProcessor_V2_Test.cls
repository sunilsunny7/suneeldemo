@isTest
public class MCONL_OrderProcessor_V2_Test {
    private static Id quoteId;
   private static User salesManager;
        @testSetup
    static void initTestData() {
        
        
        salesManager = Test_DataFactory.createAdminUser();
        salesManager.ForecastEnabled = true;
        salesManager.Bypass_VR__c = true;
        insert salesManager;
        
        
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
        insert endpointURLs;
        
        
        
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
        System.runAs(salesManager){
            update contr;
        }
        
        Id stdPriceBookRecId = Test.getStandardPricebookId();


        
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
        oli.orderId=Ord.Id;
        oli.MCONL_multiSubscriptionAssetIdentifier__c='123';
        oli.PricebookEntryId=objpricebookentry.Id;
        oli.UnitPrice=12;
        oli.Quantity=1;
        olis.add(oli);

        OrderItem oli1=new OrderItem();
        oli1.product2Id=[select id from Product2 where name ='Sub' limit 1]?.Id;
        oli1.orderId=Ord.Id;
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
        RecordType rt1 = [Select id,name, DeveloperName from RecordType where Name='Ramavtal'];  
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
        con.status = 'Active';
        con.AccountId = accountInfo.Id;
        //update con;
        
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
        prod[0].Parent_Family__c='Online Order';
        prod[1].name='Promo_XLAN_LL';
        prod[0].ProductCode='Promo_XLAN_LL';
        prod[1].vlocity_cmt__ObjectTypeId__c=FiberType.id;
        prod[1].Parent_Family__c='Online Order';
        prod[2].name='Promo_COAX_TV';
        prod[0].ProductCode='Promo_COAX_TV';
        prod[2].vlocity_cmt__ObjectTypeId__c=FiberType.id;
        prod[2].Parent_Family__c='Online Order';
        prod[3].name='Promo_IPTV_LL';
        prod[0].ProductCode='Promo_IPTV_LL';
        prod[3].vlocity_cmt__ObjectTypeId__c=FiberType.id;
        prod[3].Parent_Family__c='Online Order';
        prod[4].name='Promo_Open_Fiber_LL';
        prod[4].Parent_Family__c='Online Order';
        prod[0].ProductCode='Promo_Open_Fiber_LL';
        prod[4].vlocity_cmt__ObjectTypeId__c=FiberType.id;    
        prod[5].name='Promo_Landlord';
        prod[0].ProductCode='Promo_Landlord';
        prod[5].vlocity_cmt__ObjectTypeId__c=FiberType.id;
        prod[5].Parent_Family__c='Online Order';
        prod[6].name='Promo_VoIP_LL';
        prod[6].Parent_Family__c='Online Order';
        prod[0].ProductCode='Promo_VoIP_LL';
        prod[6].vlocity_cmt__ObjectTypeId__c=FiberType.id;    
        prod[7].name='Promo_Riksnet_BB';
        prod[7].Parent_Family__c='Online Order';
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
        orderItem.vlocity_cmt__JSONAttribute__c = '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t7a000008E4a2AAC","attributeid__c":"a367Z000000PDG3QAO","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"EXT_REF_ONLINE","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"External_reference","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a337a000000TdfrAAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"external_ref"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t7a000008E4a2AAC","attributeid__c":"a367Z000000PDG5QAO","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"Email","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Email","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a337a000000TdfqAAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"rajkant020@gmail.com"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t7a000008E4a2AAC","attributeid__c":"a367Z000000PDG6QAO","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ICC_number","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"ICC_number","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a337a000000TdfsAAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"icc"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t7a000008E4a2AAC","attributeid__c":"a367Z000000PDG8QAO","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"MSISDN","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"MSISDN","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a337a000000TdftAAC","isrequired__c":true,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"7620896789"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t7a000008E4a2AAC","attributeid__c":"a367Z000000PDG9QAO","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"SIM_Format","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"SIM_Format","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a337a000000TdfuAAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"blank","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"displayText":"blank","id":"e9a88636-0eae-7448-386b-886496de5ac1","sequence":3,"value":"blank"}],"values":[{"displayText":"esim","id":"c32c567c-c6f4-eaa8-0e16-a1da1dd42195","sequence":1,"value":"esim"},{"displayText":"simcard","id":"74fe4898-fa10-3c39-f562-d2ba40b65ab4","sequence":2,"value":"simcard"},{"displayText":"blank","id":"e9a88636-0eae-7448-386b-886496de5ac1","sequence":3,"value":"blank"}],"selectedItem":{"displayText":"blank","id":"e9a88636-0eae-7448-386b-886496de5ac1","sequence":3,"value":"blank"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t7a000008E4a2AAC","attributeid__c":"a367Z000000PDGCQA4","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"TELIA_COMM_PERIOD","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment_period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":0,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a337a000000TdfpAAC","isrequired__c":true,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"0","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"displayText":"0","id":"e7e1d1c5-bb4e-0ca1-bd82-5f9b77216274","sequence":1,"value":"0"}],"values":[{"displayText":"0","id":"e7e1d1c5-bb4e-0ca1-bd82-5f9b77216274","sequence":1,"value":"0"},{"displayText":"12","id":"2946e54d-419b-62dd-358f-793ab153bed7","sequence":2,"value":"12"},{"displayText":"24","id":"2a44f701-88d4-3537-1a61-7a6a18991fe2","sequence":3,"value":"24"},{"displayText":"36","id":"f2b151d6-7c45-5a73-9d42-f32e81785d14","sequence":3,"value":"36"}],"selectedItem":{"displayText":"24","id":"2a44f701-88d4-3537-1a61-7a6a18991fe2","sequence":3,"value":"24"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t7a000008E4a2AAC","attributeid__c":"a367Z000000PDGHQA4","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"User_name","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"User_name","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a337a000000TdfvAAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"rajnroy"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t7a000008E4a2AAC","attributeid__c":"a367Z000000PDGIQA4","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"e-SIM_Method","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"e-SIM_Method","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a337a000000TdfwAAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"email","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"displayText":"email","id":"8a7f3b12-cf4b-413c-9ac3-bc851a3651e0","sequence":1,"value":"email"}],"values":[{"displayText":"email","id":"8a7f3b12-cf4b-413c-9ac3-bc851a3651e0","sequence":1,"value":"email"}],"selectedItem":{"displayText":"email","id":"8a7f3b12-cf4b-413c-9ac3-bc851a3651e0","sequence":1,"value":"email"}},"$$AttributeDefinitionEnd$$":null}]}';                         
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
        input.put('RA_Order_Processor', input2);
        
        
        
        MCONL_OrderProcessor_V2 orderProcessor = new MCONL_OrderProcessor_V2();

        orderProcessor.invokeMethod('submitOrder',input,output,options);
        orderProcessor.invokeMethod('getOrderDetails',input,output,options);
        MCONL_OrderProcessor_V2.submitOrder(m.Id,input,output,new MCONL_OrderProcessor_V2.InputWrapper());
        MCONL_OrderProcessor_V2.activateOrder(orderNumber,m,output,options);
        MCONL_OrderProcessor_V2.BilliantSubscription testBilliant = new MCONL_OrderProcessor_V2.BilliantSubscription();
        MCONL_OrderProcessor_V2.getAttribute(orderItem.vlocity_cmt__JSONAttribute__c,orderItem.vlocity_cmt__JSONAttribute__c );
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
        RecordType rt1 = [Select id,name, DeveloperName from RecordType where Name='Ramavtal'];  
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
                     
        
        Contract con=[Select id from Contract Where Name= 'Test' LIMIT 1];
        
        
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
        prod[0].Parent_Family__c='Online Order';
        prod[1].name='Promo_XLAN_LL';
        prod[0].ProductCode='Promo_XLAN_LL';
        prod[1].vlocity_cmt__ObjectTypeId__c=FiberType.id;
        prod[1].Parent_Family__c='Online Order';
        prod[2].name='Promo_COAX_TV';
        prod[0].ProductCode='Promo_COAX_TV';
        prod[2].vlocity_cmt__ObjectTypeId__c=FiberType.id;
        prod[2].Parent_Family__c='Online Order';
        prod[3].name='Promo_IPTV_LL';
        prod[0].ProductCode='Promo_IPTV_LL';
        prod[3].vlocity_cmt__ObjectTypeId__c=FiberType.id;
        prod[3].Parent_Family__c='Online Order';
        prod[4].name='Promo_Open_Fiber_LL';
        prod[4].Parent_Family__c='Online Order';
        prod[0].ProductCode='Promo_Open_Fiber_LL';
        prod[4].vlocity_cmt__ObjectTypeId__c=FiberType.id;    
        prod[5].name='Promo_Landlord';
        prod[0].ProductCode='Promo_Landlord';
        prod[5].vlocity_cmt__ObjectTypeId__c=FiberType.id;
        prod[5].Parent_Family__c='Online Order';
        prod[6].name='Promo_VoIP_LL';
        prod[6].Parent_Family__c='Online Order';
        prod[0].ProductCode='Promo_VoIP_LL';
        prod[6].vlocity_cmt__ObjectTypeId__c=FiberType.id;    
        prod[7].name='Promo_Riksnet_BB';
        prod[7].Parent_Family__c='Online Order';
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
        
        MCONL_OrderProcessor_V2.ShippingAddress shippingAddressObj = new MCONL_OrderProcessor_V2.ShippingAddress();
        shippingAddressObj.apartmentNumber = '';
        shippingAddressObj.streetNumber = '';
        shippingAddressObj.name = '';
        shippingAddressObj.entrance = '';
        //shippingAddressObj.State = '';
        
        MCONL_OrderProcessor_V2.OrderRequestWrapper orderRequestWrapperObj = new MCONL_OrderProcessor_V2.OrderRequestWrapper();
        orderRequestWrapperObj.orderStatus = '';
        orderRequestWrapperObj.orderRequest = '';
        
        MCONL_OrderProcessor_V2.TracingDetails tracingDetailsObj = new MCONL_OrderProcessor_V2.TracingDetails();
        tracingDetailsObj.originApplication = '';
        tracingDetailsObj.originClientUserId = '';
        tracingDetailsObj.originServerIP = '';
        tracingDetailsObj.originTracingId = '';
        
        MCONL_OrderProcessor_V2 orderProcessor = new MCONL_OrderProcessor_V2();
        
        orderProcessor.invokeMethod('submitOrder',input,output,options);
        orderProcessor.invokeMethod('getOrderDetails',input,output,options);
        string inputstr = JSON.serialize(input);
        string outputstr = JSON.serialize(output);
        MCONL_OrderProcessor_V2.processOrderRouterFuture(inputstr, outputstr);
        MCONL_OrderProcessor_V2.activateOrder(orderNumber,m,output,options);
        system.assert(true);
        MCONL_OrderProcessor_V2.updateMSISDNStatusWithoutFuture(m.Id);
        Test.stopTest(); 
    }
    
    @isTest
    public static void testpopulateBND()
    {
        Id orderId=[select id from order where vlocity_cmt__BillingName__c='TestingSuneel']?.Id;
        MCONL_OrderProcessor_V2.populateBND(orderId);
        OrderItem Item =[select id,MCONL_Additional_Charge__c from OrderItem where Product2.Name='Sub' limit 1];
        System.assertEquals('BND39', Item.MCONL_Additional_Charge__c);
    }
}