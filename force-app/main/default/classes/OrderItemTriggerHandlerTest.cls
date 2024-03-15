@isTest
public class OrderItemTriggerHandlerTest {

    @istest
    static  void test() {

        FeaturesSetting__c festureSetting = new FeaturesSetting__c();
        festureSetting.Name = 'PriceOverride';
        festureSetting.flag__c = true;
        Insert festureSetting;
        
        //Attempt 1 - No fileName
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
         Account acc = new Account();
        acc.Name='TestAccount';
        acc.Org_Nr__c =  '1234567890';
        //acc.CreatedDate = Date.today().addDays(-30);
        System.runAs(Test_DataFactory.getByPassUser()){
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
        contr.Status = 'Active';
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
        
        
        order__c orc= new order__c();
        orc.MCOnline_Number_of_Days__c=7;
        orc.Name='MCOnline Order Inactive Days';
        insert orc;
        
        List <Order> orderList = new List <Order>();

        order m= new order(Name = 'Order',AccountId= acc.id,status = 'Draft',EffectiveDate = system.today(),
                           Pricebook2Id = stdPriceBookRecId);
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
        update con;
        
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
        List<OrderItem> orderitems = new List<OrderItem>();
        OrderItem orderItem = new OrderItem();
        orderItem.vlocity_cmt__JSONAttribute__c = '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4E000006ROTtQAO","attributeid__c":"a364E000000M1hoQAC","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"EXT_REF_ONLINE","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"External Reference Online","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a334E000000RSHUQA4","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4E000006ROTtQAO","attributeid__c":"a364E0000005SvrQAE","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"SIM_Format","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"SIM Format","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a334E000000RSvCQAW","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4E000006ROTtQAO","attributeid__c":"a364E0000005Sw1QAE","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ICC_number","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"ICC nummer","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a334E000000RSvDQAW","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4E000006ROTtQAO","attributeid__c":"a364E0000005TjKQAU","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"User_name","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"User_name","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a334E000000RTCGQA4","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"test"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4E000006ROTtQAO","attributeid__c":"a364E0000005TjKQAU","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"Relation_Id","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Relation_Id","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a334E000000RTCGQA4","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"123456"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"a4s4E000000nyuoQAA","attributeid__c":"a364E0000005SvwQAE","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"e-SIM_Method","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"e-SIM Method","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a334E000000RSw0QAG","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Email","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"Email","sequence":1,"id":"8a7f3b12-cf4b-413c-9ac3-bc851a3651e0","displayText":"Email"}],"values":[{"value":"Email","sequence":1,"id":"8a7f3b12-cf4b-413c-9ac3-bc851a3651e0","displayText":"Email"},{"value":"Printpdf","sequence":2,"id":"4505ebd8-5437-ead5-d2f9-3f6e57590ad3","displayText":"Printpdf"},{"value":"Printhtml","sequence":3,"id":"c85f2296-d69d-f781-d17e-48cb0c8020b2","displayText":"Printhtml"},{"value":"Portal","sequence":4,"id":"3dc0a245-7783-d1c9-4c45-dd7c6066876e","displayText":"Portal"}],"selectedItem":{"value":"Email","sequence":1,"id":"8a7f3b12-cf4b-413c-9ac3-bc851a3651e0","displayText":"Email"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4E000006ROTtQAO","attributeid__c":"a364E0000005SLgQAM","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"BILLING_ACCOUNT","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Billing Account Online","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a334E000000RSftQAG","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4E000006ROTtQAO","attributeid__c":"a364E000000M1hqQAC","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"TELIA_COMM_PERIOD","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period Online","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":0,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a334E000000RSHSQA4","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"0","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"0","sequence":1,"id":"e7e1d1c5-bb4e-0ca1-bd82-5f9b77216274","displayText":"0"}],"values":[{"value":"0","sequence":1,"id":"e7e1d1c5-bb4e-0ca1-bd82-5f9b77216274","displayText":"0"},{"value":"12","sequence":2,"id":"2946e54d-419b-62dd-358f-793ab153bed7","displayText":"12"},{"value":"24","sequence":3,"id":"2a44f701-88d4-3537-1a61-7a6a18991fe2","displayText":"24"},{"value":"36","sequence":3,"id":"f2b151d6-7c45-5a73-9d42-f32e81785d14","displayText":"36"}],"selectedItem":{"value":"0","sequence":1,"id":"e7e1d1c5-bb4e-0ca1-bd82-5f9b77216274","displayText":"0"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4E000006ROTtQAO","attributeid__c":"a364E000000M1hrQAC","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"TELIA_COMM_UNIT","attributeconfigurable__c":true,"attributedisplaysequence__c":"100","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Unit Online","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a334E000000RSHTQA4","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Month","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"Month","sequence":1,"id":"e0b4a920-3039-61e2-9bc3-9a8194f7270a","displayText":"Month"}],"values":[{"value":"Month","sequence":1,"id":"e0b4a920-3039-61e2-9bc3-9a8194f7270a","displayText":"Month"}],"selectedItem":{"value":"Month","sequence":1,"id":"e0b4a920-3039-61e2-9bc3-9a8194f7270a","displayText":"Month"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4E000006ROTtQAO","attributeid__c":"a364E0000005QwmQAE","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"EMAIL","attributeconfigurable__c":true,"attributedisplaysequence__c":"8","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Email Address","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a334E000000RSHNQA4","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4E000006ROTtQAO","attributeid__c":"a364E000000M1hpQAC","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"MSISDN","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"MSISDN","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a334E000000RSHOQA4","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"4635655245265"},"$$AttributeDefinitionEnd$$":null}]}orderItem.vlocity_cmt__RecurringCharge__c=0;';
        orderItem.vlocity_cmt__AttributeSelectedValues__c = '{"MSISDN":"468237233743","TELIA_COMM_PERIOD":"24","BILLING_ACCOUNT":"testBill","TELIA_COMM_UNIT":"month","User_name":"testUser"}';
        orderItem.vlocity_cmt__RecurringCharge__c = 0;
        orderItem.MCOnline_CommitmentPeriod__c = '0';
        orderItem.MCOnline_CommitmentUnit__c = 'Month';
        orderItem.Quantity = 1;
        orderItem.vlocity_cmt__Action__c = 'Add';   
        orderItem.vlocity_cmt__ParentItemId__c = '8024E000002GqmbQAC';
        orderItem.vlocity_cmt__RootItemId__c = '8024E000002GqmbQAC';
        orderItem.OrderId = m.Id;
        orderItem.UnitPrice = 1;
        orderItem.PricebookEntryId = objpricebookentry.Id;
        orderitems.add(orderItem);
        
        OrderItem orderItem1 = new OrderItem();
        orderItem1.vlocity_cmt__JSONAttribute__c = '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4E000006ROTtQAO","attributeid__c":"a364E000000M1hoQAC","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"EXT_REF_ONLINE","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"External Reference Online","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a334E000000RSHUQA4","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4E000006ROTtQAO","attributeid__c":"a364E0000005SvrQAE","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"SIM_Format","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"SIM Format","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a334E000000RSvCQAW","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4E000006ROTtQAO","attributeid__c":"a364E0000005Sw1QAE","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ICC_number","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"ICC nummer","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a334E000000RSvDQAW","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4E000006ROTtQAO","attributeid__c":"a364E0000005TjKQAU","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"User_name","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"User_name","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a334E000000RTCGQA4","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"a4s4E000000nyuoQAA","attributeid__c":"a364E0000005SvwQAE","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"e-SIM_Method","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"e-SIM Method","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a334E000000RSw0QAG","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Email","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"Email","sequence":1,"id":"8a7f3b12-cf4b-413c-9ac3-bc851a3651e0","displayText":"Email"}],"values":[{"value":"Email","sequence":1,"id":"8a7f3b12-cf4b-413c-9ac3-bc851a3651e0","displayText":"Email"},{"value":"Printpdf","sequence":2,"id":"4505ebd8-5437-ead5-d2f9-3f6e57590ad3","displayText":"Printpdf"},{"value":"Printhtml","sequence":3,"id":"c85f2296-d69d-f781-d17e-48cb0c8020b2","displayText":"Printhtml"},{"value":"Portal","sequence":4,"id":"3dc0a245-7783-d1c9-4c45-dd7c6066876e","displayText":"Portal"}],"selectedItem":{"value":"Email","sequence":1,"id":"8a7f3b12-cf4b-413c-9ac3-bc851a3651e0","displayText":"Email"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4E000006ROTtQAO","attributeid__c":"a364E0000005SLgQAM","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"BILLING_ACCOUNT","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Billing Account Online","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a334E000000RSftQAG","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4E000006ROTtQAO","attributeid__c":"a364E000000M1hqQAC","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"TELIA_COMM_PERIOD","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period Online","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":0,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a334E000000RSHSQA4","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"0","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"0","sequence":1,"id":"e7e1d1c5-bb4e-0ca1-bd82-5f9b77216274","displayText":"0"}],"values":[{"value":"0","sequence":1,"id":"e7e1d1c5-bb4e-0ca1-bd82-5f9b77216274","displayText":"0"},{"value":"12","sequence":2,"id":"2946e54d-419b-62dd-358f-793ab153bed7","displayText":"12"},{"value":"24","sequence":3,"id":"2a44f701-88d4-3537-1a61-7a6a18991fe2","displayText":"24"},{"value":"36","sequence":3,"id":"f2b151d6-7c45-5a73-9d42-f32e81785d14","displayText":"36"}],"selectedItem":{"value":"0","sequence":1,"id":"e7e1d1c5-bb4e-0ca1-bd82-5f9b77216274","displayText":"0"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4E000006ROTtQAO","attributeid__c":"a364E000000M1hrQAC","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"TELIA_COMM_UNIT","attributeconfigurable__c":true,"attributedisplaysequence__c":"100","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Unit Online","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a334E000000RSHTQA4","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Month","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"Month","sequence":1,"id":"e0b4a920-3039-61e2-9bc3-9a8194f7270a","displayText":"Month"}],"values":[{"value":"Month","sequence":1,"id":"e0b4a920-3039-61e2-9bc3-9a8194f7270a","displayText":"Month"}],"selectedItem":{"value":"Month","sequence":1,"id":"e0b4a920-3039-61e2-9bc3-9a8194f7270a","displayText":"Month"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4E000006ROTtQAO","attributeid__c":"a364E0000005QwmQAE","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"EMAIL","attributeconfigurable__c":true,"attributedisplaysequence__c":"8","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Email Address","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a334E000000RSHNQA4","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4E000006ROTtQAO","attributeid__c":"a364E000000M1hpQAC","attributecategoryid__c":"a351w000000Amr6AAC","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"MSISDN","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"MSISDN","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a334E000000RSHOQA4","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":null},"$$AttributeDefinitionEnd$$":null}]}';        orderItem1.MCOnline_CommitmentPeriod__c = '0';
        orderItem1.vlocity_cmt__AttributeSelectedValues__c = '{"MSISDN":null,"TELIA_COMM_PERIOD":null,"Relation_Id":"123456","BILLING_ACCOUNT":"testBill","TELIA_COMM_UNIT":"month","User_name":null}';
        orderItem1.vlocity_cmt__RecurringCharge__c = 0;
        //orderItem1.MCOnline_CommitmentPeriod__c = '0';
        orderItem1.MCOnline_CommitmentUnit__c = 'Month';
        orderItem1.Quantity = 1;
        orderItem1.vlocity_cmt__Action__c = 'Add';   
        orderItem1.vlocity_cmt__ParentItemId__c = '8024E000002GqmbQAC';
        orderItem1.vlocity_cmt__RootItemId__c = '8024E000002GqmbQAC';
        orderItem1.OrderId = m.Id;
        orderItem1.UnitPrice = 1;
        orderItem1.PricebookEntryId = objpricebookentry.Id;
        orderitems.add(orderItem1);
        Insert orderitems;
        update orderitems;
        system.assert(orderItem.Id != null);
    }

        
    }
      @istest
    static  void test1() {
        List<OrderItem> oItemList = new List<OrderItem>();
        
        OrderItemTriggerHandler.afterUpdate(oItemList);
        OrderItemTriggerHandler.afterInsert(oItemList);
        OrderItemTriggerHandler.beforeUpdate(oItemList);


    }
}