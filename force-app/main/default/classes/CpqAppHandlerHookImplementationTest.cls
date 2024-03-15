/***************************************************************************************
Developer name: Vinay Sattaru
Date Created: 13 October 2020
Functionlity : Test Class to cover - CpqAppHandlerHookImplementation
User Story: MCONL-2221
Sprint/Release: 18
*****************************************************************************************/
@isTest
public class CpqAppHandlerHookImplementationTest {
    private static Id quoteId;
   
    @testSetup
    static void initTestData() {

        List < WebService__c > endpointURLs = new List < WebService__c > ();
        WebService__c wbTest = new WebService__c(Name = 'MCONLINE_ActivateOrder',  
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

        WebService__c wbTest3 = new WebService__c(Name = 'MCONLINE_UnReserveNumber',  
                                                 EndpointURL__c = 'https://apimarket-test.eam.telia.se/token',
                                                 Content_Type__c = 'application/x-www-form-urlencoded', 
                                                 userName__c = 'imStV5FaBfKqSeGuR6ff_BJR6Tga',
                                                 password__c = 'UAEkMX1YKQbplxPXhPVdcd2uxDEa', 
                                                 Authorization__c = 'Basic aW1TdFY1RmFCZktxU2VHdVI2ZmZfQkpSNlRnYTpVQUVrTVgxWUtRYnBseFBYaFBWZGNkMnV4REVh');
        endpointURLs.add(wbTest3);
        WebService__c wbTest4 = new WebService__c(Name = 'MCONLINE_ReserveNumber',  
                                                  EndpointURL__c = 'https://apimarket-test.eam.telia.se/token',
                                                  Content_Type__c = 'application/x-www-form-urlencoded', 
                                                  userName__c = 'imStV5FaBfKqSeGuR6ff_BJR6Tga',
                                                  password__c = 'UAEkMX1YKQbplxPXhPVdcd2uxDEa', 
                                                  Authorization__c = 'Basic aW1TdFY1RmFCZktxU2VHdVI2ZmZfQkpSNlRnYTpVQUVrTVgxWUtRYnBseFBYaFBWZGNkMnV4REVh');
        endpointURLs.add(wbTest4);
        insert endpointURLs;
        
        SObject sObj = [SELECT Id, SobjectType, DeveloperName FROM RecordType WHERE IsActive = TRUE
                        and SobjectType = 'vlocity_cmt__ObjectClass__c' and DeveloperName = 'ObjectType' LIMIT 1]; 
        vlocity_cmt__ObjectClass__c objType = new vlocity_cmt__ObjectClass__c(Name = 'Broadband Start Offering Spec', vlocity_cmt__ObjectApiName__c = 'Product2', RecordTypeId = sObj.Id);
        insert objType;
        
        List<Product2> prod = Test_DataFactory.createProducts(10);
        prod[0].name='Bredband Start 1 Gbit/s';
        prod[0].ProductCode='CO-BBSTART-1000MB';
        prod[0].vlocity_cmt__ObjectTypeId__c=objType.Id;
        insert prod;
        
        PricebookEntry objpricebookentry =new PricebookEntry();
        objpricebookentry.Product2ID = prod[0].id;
        objpricebookentry.Pricebook2ID = Test.getStandardPricebookId();
        objpricebookentry.UnitPrice=23.50;
        objpricebookentry.UseStandardPrice=false;
        objpricebookentry.isActive=true;//Add this line
        insert objpricebookentry;
    }
    
    @istest
    static  void test() {
        System.runAs(Test_DataFactory.getByPassUser()){
        
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        Account acc = new Account();
        acc.Name='TestAccount';
        acc.Org_Nr__c =  '1234567890';
        insert acc;
            
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
        update contr;
        
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
        
    /* // online code---------------------    
        order__c orc= new order__c();
        orc.MCOnline_Number_of_Days__c=7;
        orc.Name='MCOnline Order Inactive Days';
        insert orc;
        */
        List <Order> orderList = new List <Order>();

        order m= new order(Name = 'Order',AccountId= acc.id,status = 'Draft',EffectiveDate = system.today(),
                           Pricebook2Id = stdPriceBookRecId);
        insert m;
        Datetime yesterday = Datetime.now().addDays(-13);
        
        
        List<sObject> types=new List<sObject>();
        SObject sObj = [SELECT Id, SobjectType, DeveloperName FROM RecordType WHERE IsActive = TRUE and SobjectType = 'vlocity_cmt__ObjectClass__c' and DeveloperName = 'ObjectType' LIMIT 1];   
        vlocity_cmt__ObjectClass__c FiberType = new vlocity_cmt__ObjectClass__c(Name = 'Fiber Base Product Spec Type', vlocity_cmt__ObjectApiName__c = 'Product2', RecordTypeId = sObj.Id);
        vlocity_cmt__ObjectClass__c COType = new vlocity_cmt__ObjectClass__c(Name = 'Broadband Start Offering Spec', vlocity_cmt__ObjectApiName__c = 'Product2', RecordTypeId = sObj.Id);
        
        types.add(FiberType);
        types.add(COType);
        
        insert types;
        
        Account accountInfo = acc; 
        
        Test.setCreatedDate(m.Id, yesterday);  
        m.AccountId = accountInfo.Id;
        m.vlocity_cmt__OrderStatus__c = 'Draft';
       // update m;
        Quote testQuote = new Quote();
        Id userId = Userinfo.getUserId();
        Seller__c sellerInfo = Test_DataFactory.createBusinessAreaManagerSeller(userId);
        insert sellerInfo;
        Opportunity testOpportunity = Test_DataFactory.createSmeOpportunity();
        testOpportunity.AccountId = accountInfo.Id;
        //testOpportunity.Type_of_Address__c = 'MDU';
        insert testOpportunity;
        RecordType rt = [Select id,name, DeveloperName from RecordType where Name='Contract Quote'];
                     
        RecordType rtfiber = [Select id,name, DeveloperName from RecordType where Name='CA Quote of FA'];             
        
        Contract con=[select id,recordTypeId,status,AccountId from Contract where RecordType.Name = 'Ramavtal' limit 1];
        con.status = 'Active';
        con.AccountId = accountInfo.Id;
        update con;
        
        //Quote for Roll Down Test(Office 365)
        testQuote.Name= 'Test Quote';
        testQuote.OpportunityId = testOpportunity.Id;
        testQuote.Status = 'Draft';
        testQuote.Pricebook2Id = stdPriceBookRecId;
        testQuote.RecordTypeId = rt.Id; //RecordTypeIdQuote; //rt.Id;
        testQuote.vlocity_cmt__frameContractId__c=con.id;
        testQuote.TeliaSE_MC_Sales_Flow_Identifier__c='Inforhandling';
        insert testQuote; 
        List<Product2> prod = Test_DataFactory.createProducts(10);
        prod[0].name='Bredband Start 1 Gbit/s';
        prod[0].ProductCode='CO-BBSTART-1000MB';
        prod[0].vlocity_cmt__ObjectTypeId__c=COType.Id;
        
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
      
        QuoteLineItem qlitem = new QuoteLineItem();
        qlitem.QuoteId = testQuote.Id;
        qlitem.PriceBookentryId = objpricebookentry.Id;
        qlitem.Product2Id = prod[0].Id;
        qlitem.Quantity= 100.00;
        qlitem.UnitPrice = 0.00;
        
        insert qlitem;
      
        OrderItem orderItem = new OrderItem();
        orderItem.vlocity_cmt__JSONAttribute__c = '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4E000006ROTtQAO","attributeid__c":"a364E000000M1hoQAC","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"EXT_REF_ONLINE","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"External Reference Online","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a334E000000RSHUQA4","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4E000006ROTtQAO","attributeid__c":"a364E0000005SvrQAE","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"SIM_Format","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"SIM Format","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a334E000000RSvCQAW","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4E000006ROTtQAO","attributeid__c":"a364E0000005Sw1QAE","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ICC_number","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"ICC nummer","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a334E000000RSvDQAW","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4E000006ROTtQAO","attributeid__c":"a364E0000005TjKQAU","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"User_name","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"User_name","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a334E000000RTCGQA4","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"a4s4E000000nyuoQAA","attributeid__c":"a364E0000005SvwQAE","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"e-SIM_Method","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"e-SIM Method","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a334E000000RSw0QAG","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Email","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"Email","sequence":1,"id":"8a7f3b12-cf4b-413c-9ac3-bc851a3651e0","displayText":"Email"}],"values":[{"value":"Email","sequence":1,"id":"8a7f3b12-cf4b-413c-9ac3-bc851a3651e0","displayText":"Email"},{"value":"Printpdf","sequence":2,"id":"4505ebd8-5437-ead5-d2f9-3f6e57590ad3","displayText":"Printpdf"},{"value":"Printhtml","sequence":3,"id":"c85f2296-d69d-f781-d17e-48cb0c8020b2","displayText":"Printhtml"},{"value":"Portal","sequence":4,"id":"3dc0a245-7783-d1c9-4c45-dd7c6066876e","displayText":"Portal"}],"selectedItem":{"value":"Email","sequence":1,"id":"8a7f3b12-cf4b-413c-9ac3-bc851a3651e0","displayText":"Email"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4E000006ROTtQAO","attributeid__c":"a364E0000005SLgQAM","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"BILLING_ACCOUNT","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Billing Account Online","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a334E000000RSftQAG","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4E000006ROTtQAO","attributeid__c":"a364E000000M1hqQAC","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"TELIA_COMM_PERIOD","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period Online","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":0,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a334E000000RSHSQA4","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"0","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"0","sequence":1,"id":"e7e1d1c5-bb4e-0ca1-bd82-5f9b77216274","displayText":"0"}],"values":[{"value":"0","sequence":1,"id":"e7e1d1c5-bb4e-0ca1-bd82-5f9b77216274","displayText":"0"},{"value":"12","sequence":2,"id":"2946e54d-419b-62dd-358f-793ab153bed7","displayText":"12"},{"value":"24","sequence":3,"id":"2a44f701-88d4-3537-1a61-7a6a18991fe2","displayText":"24"},{"value":"36","sequence":3,"id":"f2b151d6-7c45-5a73-9d42-f32e81785d14","displayText":"36"}],"selectedItem":{"value":"0","sequence":1,"id":"e7e1d1c5-bb4e-0ca1-bd82-5f9b77216274","displayText":"0"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4E000006ROTtQAO","attributeid__c":"a364E000000M1hrQAC","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"TELIA_COMM_UNIT","attributeconfigurable__c":true,"attributedisplaysequence__c":"100","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Unit Online","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a334E000000RSHTQA4","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Month","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"Month","sequence":1,"id":"e0b4a920-3039-61e2-9bc3-9a8194f7270a","displayText":"Month"}],"values":[{"value":"Month","sequence":1,"id":"e0b4a920-3039-61e2-9bc3-9a8194f7270a","displayText":"Month"}],"selectedItem":{"value":"Month","sequence":1,"id":"e0b4a920-3039-61e2-9bc3-9a8194f7270a","displayText":"Month"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4E000006ROTtQAO","attributeid__c":"a364E0000005QwmQAE","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"EMAIL","attributeconfigurable__c":true,"attributedisplaysequence__c":"8","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Email Address","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a334E000000RSHNQA4","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4E000006ROTtQAO","attributeid__c":"a364E000000M1hpQAC","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"MSISDN","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"MSISDN","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a334E000000RSHOQA4","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":null},"$$AttributeDefinitionEnd$$":null}]}';                         
            orderItem.vlocity_cmt__RecurringCharge__c = 0;
        //orderItem.MCOnline_CommitmentPeriod__c = '0';
        //orderItem.MCOnline_CommitmentUnit__c = 'Month';
        orderItem.Quantity = 1;
        orderItem.vlocity_cmt__Action__c = 'Add';   
        orderItem.vlocity_cmt__ParentItemId__c = '8024E000002GqmbQAC';
        orderItem.OrderId = m.Id;
        orderItem.UnitPrice = 1;
        orderItem.PricebookEntryId = objpricebookentry.Id;
        Insert orderItem;
        system.assert(orderItem.Id != null);
        
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> output2 = new Map<String, Object>();
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
        Map<String, Object> output1 = new Map<String, Object>();
        List<Object> input20 = new List<Object>();
        Map<String, Object> input21 = new Map<String, Object>();
        List<Object> input22 = new List<Object>();
        Map<String, Object> input23 = new Map<String, Object>();
        List<Object> input24 = new List<Object>();
        Map<String, Object> input27 = new Map<String, Object>();
        List<Object> input26 = new List<Object>();
        Map<String, Object> input28 = new Map<String, Object>();
        Map<String, Object> input25 = new Map<String, Object>();
        
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
                                      //TeliaSE_Base_Quantity__c,
                                      TeliaSE_PriceTypeCategory__c
                                      FROM QuoteLineItem 
                                      WHERE QuoteId =: quoteId];
        String orderNumber = [Select orderNumber from Order where Id =: m.Id].orderNumber;
        //List<SObject> updatedquoteItemList = new List<sObject>();
        Vlocity_cmt.JSONAttributeSupport jsonSupport = new Vlocity_cmt.JSONAttributeSupport();
        
        
        vlocity_cmt.PricingPlanService.putInPricingContext('Parent', quoteSObject);
        vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList', quoteItemList);
        system.assert(quoteSObject != null);
     /*   
        MCONL_MSISDN__c msi = new MCONL_MSISDN__c();
        msi.CartContextKey__c = '12321';
        msi.Number__c = '212122';
        msi.LineItemKey__c = '22222';
        insert msi;
      */  
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
        
        List<Object> input31 = new List<Object>();
        Map<String, Object> input32 = new Map<String, Object>();
        Map<String, Object> input30 = new Map<String, Object>();
        Map<String, Object> input33 = new Map<String, Object>();
        Map<String, Object> inputAdjustmentPre = new Map<String, Object>();
        
        input33.put('productAttributes', prod[0]);
        input32.put('productAttributes', input33);
        
        input32.put('userValues', 'MSISDN');
        input32.put('code', 'MSISDN');
        input31.add(input32);
        input30.put('records',input31);

        input27.put('productAttributes', input30);
        input26.add(input27);
        input25.put('records',input26);
        input24.add(input25);
        input23.put('lineItemKey','12345');
        input23.put('attributeCategories',input25);
        input22.add(input23);
        input21.put('records',input22);
        input20.add(input23);
        input18.put('lineItems',prod[0]);
        input18.put('records',input20);
        input19.add(input18);
        input16.put('lineItems',input18);
        input17.add(input16);
        input14.put('lineItems',input16);
        input14.put('records',input17);
        input15.add(input14);
        input12.put('ProductCode',prod[0]);
        input12.put('priceResult',input15);
        input12.put('childProducts',input17);
        input13.add(input12);
        input.put('Catalog','RangeAttributePricingMatrix');
        input8.put('lineItems',input14);
        input8.put('cartId',m.Id);
        input8.put('itemId',m.id);
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
        input2.put('cartId','223232');
        input2.put('itemId','32323');
        input.put('HA_GetOffersFromDgCommerce',input2);  
        input.put('OrderNumber',orderNumber);
        input.put('orderId',m.id);
        input.put('contactDetails',conMap);
        input.put('cartId',salesMap);
        input.put('itemId',shipping);
        input.put('result',input3);
        input.put('lineItemKey','22222');
        input.put('items', input10);
        output1.put('records',input10);
        output1.put('itempricesupdated','addtocart');
        output.put('result', output1);
        vlocity_cmt.JSONResult res = (Vlocity_cmt.JSONResult) null;
        output2.put('result', res);        

      /*  
        FeaturesSetting__c festureSetting = new FeaturesSetting__c();
        festureSetting.Name = 'NumberReservation';
        festureSetting.flag__c = true;
        Insert festureSetting;
        
        FeaturesSetting__c festureSetting2 = new FeaturesSetting__c();
        festureSetting2.Name = 'NumberUnReservation';
        festureSetting2.flag__c = true;
        Insert festureSetting2;
      */  
        CpqAppHandlerHookImplementation hookImplementation = new CpqAppHandlerHookImplementation();
        List<id> itemIdList = new List<id>();
        itemIdList.add(qlitem.Id);
        input.put('cartId',quoteSObject.Id);
        input.put('itemId',qlitem.Id);
        input.put('id',qlitem.Id);
        input.put('item',itemIdList);
        input.put('myCustomValidationRuleFails',true);
        
        //new Map for sending input to applyAdjustment invoke
        inputAdjustmentPre.put('cartId',quoteSObject.Id);
        inputAdjustmentPre.put('itemId',qlitem.Id);
        inputAdjustmentPre.put('id',qlitem.Id);
        
        
        hookImplementation.invokeMethod('putCartsItems.postInvoke',input,output2,options);
        hookImplementation.invokeMethod('putCartsItems.postInvoke',input,output,options);
        hookImplementation.invokeMethod('addAfterConfig.PostInvoke',input,output,options);
        hookImplementation.invokeMethod('addAfterConfig.PreInvoke',input,output,options);
        hookImplementation.invokeMethod('putCartsItems.preInvoke',input,output,options);
        hookImplementation.invokeMethod('postCartsItems.postInvoke',input,output,options);
        hookImplementation.invokeMethod('getExpandedItems.postInvoke',input,output2,options);
        hookImplementation.invokeMethod('getExpandedItems.postInvoke',input,output,options);
        hookImplementation.invokeMethod('deleteCartsItems.preInvoke',input,output,options);
        hookImplementation.invokeMethod('deleteFromBasket.PreInvoke',input,output,options);
        hookImplementation.invokeMethod('NumberReservation',input,output,options);
        hookImplementation.invokeMethod('NumberUnReservation',input,output,options);
        hookImplementation.invokeMethod('deleteFromBasket.PostInvoke',input,output,options);
        hookImplementation.invokeMethod('getCartsItems.PreInvoke',input,output,options);
        hookImplementation.invokeMethod('getExpandedItems.PreInvoke',input,output,options);
        hookImplementation.invokeMethod('addAfterConfig.postInvoke',input,output,options);
        hookImplementation.invokeMethod('applyAdjustment.preInvoke',inputAdjustmentPre,output,options);
        hookImplementation.invokeMethod('applyAdjustment.postInvoke',input,output,options);
        hookImplementation.invokeMethod('getCartLineItemPrices.PreInvoke',input,output,options);
        hookImplementation.invokeMethod('deleteCartsItems.preInvoke',input,output,options);
        hookImplementation.invokeMethod('deleteCartsItems.postInvoke',input,output,options);       
        hookImplementation.invokeMethod('priceCart.preInvoke',input,output,options);       
        hookImplementation.generateRefreshPriceAction(quoteSObject.Id,res,qlitem.Id);
        
        input.put('cartId',Testquote.Id);
        CpqAppHandlerHookImplementation.sortproducts(input,output,'Halebop');
        CpqAppHandlerHookImplementation.sortproducts(input,output,'Zitius');
        CpqAppHandlerHookImplementation.sortproducts(input,output,'SDU');
        CpqAppHandlerHookImplementation.sortproducts(input,output,'MDU');
        hookImplementation.invokeMethod('getCartsProducts.postInvoke',input,output,options);
        hookImplementation.getObjectType(m.id);
        hookImplementation.getObjectType(quoteSObject.Id);
        System.assert(true);
        Test.stopTest();
        }
    }
    
    @istest
    static void test1() {  
        System.runAs(Test_DataFactory.getByPassUser()){ 
        RecordType rt = [Select id,name, DeveloperName from RecordType where Name='Contract Quote'];
        Account acc = new Account();
        acc.Name='TestAccount';
        acc.Org_Nr__c =  '1234567890';
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
        update contr;
        Id stdPriceBookRecId = Test.getStandardPricebookId();

        Opportunity testOpportunity = Test_DataFactory.createSmeOpportunity();
        testOpportunity.AccountId = acc.Id;
        insert testOpportunity;
            
        Quote testQuote = new Quote();
        testQuote.Name= 'Test Quote';
        testQuote.OpportunityId = testOpportunity.Id;
        testQuote.Status = 'Draft';
        testQuote.Pricebook2Id = stdPriceBookRecId;
        testQuote.RecordTypeId = rt.Id;
        testQuote.vlocity_cmt__frameContractId__c=contr.id;
        testQuote.TeliaSE_MC_Sales_Flow_Identifier__c='Tilläggsförhandling';
        insert testQuote; 

        sObject quoteSObject =[SELECT Id FROM Quote WHERE Id =: testQuote.Id];
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> input1 = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        Map<String, Object> Action = new Map<String, Object>();
        input.put('cartId',quoteSObject.Id);
            
        Test.startTest();
        CpqAppHandlerHookImplementation hookImplementation = new CpqAppHandlerHookImplementation();
        hookImplementation.invokeMethod('applyAdjustment.postInvoke',input,output,options);
        String itemId=null;
        input.put('itemId',itemId);
        input.put('CoDeleteFails', true);
        hookImplementation.invokeMethod('getCartLineItemPrices.PreInvoke',input,output,options); 
        input1.put('itempricesupdated','addtocart');
        Action.put('actions',input1);
        output.put('result', Action);
        hookImplementation.invokeMethod('getExpandedItems.postInvoke',input,output,options); 
        hookImplementation.invokeMethod('deleteCartsItems.postInvoke',input,output,options);
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry LIMIT 1];
        List<Object> inputList = new List<Object>();
        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('itemId',pbe.Id);
        inputList.add(inputMap);
        input.put('items', inputList);
        hookImplementation.invokeMethod('postCartsItems.preInvoke',input,output,options);
        input.put('COAddFails',true);
        input.put('TillaggsforhandlingError',true);   
        hookImplementation.validationForCOAdd(pbe.Id, input);
        hookImplementation.invokeMethod('postCartsItems.postInvoke',input,output,options);
        Test.stopTest();
        }
    }
}