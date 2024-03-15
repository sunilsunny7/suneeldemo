@IsTest
/*-----------------------------------------------------------------------------------------------------------
**Name: TeliaSE_QuoteLineHandler
**Created By: Vaishali Srivastava
**Sprint: Sprint-2
**User Story:MCSTO-423
**Description:Test class for class TeliaSE_QuoteLineHandler.
-----------------------------------------------------------------------------------------------------------*/
private class Test_TeliaSE_QuoteLineHandler{
    @testSetup static void setup(){
        User salesManager;         
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        
        
        System.runAs(new User(Id = Userinfo.getUserId())){
            salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManager.Bypass_VR__c = true;
            insert salesManager;
        }
        FiberDiscountMandate__c fb = new FiberDiscountMandate__c();
        fb.Role__c = 'Manager';
        fb.Name = 'Manager';
        fb.EBIT_Max_Mandate__c = 12;
        fb.EBIT_Min_Mandate__c = 1;
        fb.ProductDiscountMaxMandate__c = 12;
        fb.ProductDiscountMinMandate__c = 12;
        insert fb;
        
        FiberDiscountMandate__c fb1 = new FiberDiscountMandate__c();
        fb1.Role__c = 'Director';
        fb1.Name = 'Director';
        fb1.EBIT_Max_Mandate__c = 12;
        fb1.EBIT_Min_Mandate__c = 1;
        fb1.ProductDiscountMaxMandate__c = 12;
        fb1.ProductDiscountMinMandate__c = 12;
        insert fb1; 
        System.runAs(salesManager){
            List<Product2> prodList = new List<Product2>();
            Product2 prod = Test_DataFactory.createProducts(1)[0];
            prod.ProductCode = 'Fiber Sales (Lägenhet)';
            prodList.add(prod);
            Product2 prodtill = Test_DataFactory.createProducts(1)[0];
            prodtill.ProductCode = 'PT_PLUS';
            prodList.add(prodtill);
            Product2 prodRes = Test_DataFactory.createProducts(1)[0];
            prodRes.ProductCode = 'MOB_CALL_TRAVEL_EAST';
            prodList.add(prodRes);
            Product2 prodSub = Test_DataFactory.createProducts(1)[0];
            prodSub.ProductCode = 'dummy';
            prodSub.TeliaSE_Product_Type__c = 'Price';
            prodList.add(prodSub);
            
            Product2 prodIPTV = Test_DataFactory.createProducts(1)[0];
            prodList.add(prodIPTV);
            insert prodList;
            prodIPTV.vlocity_cmt__SpecificationType__c = 'Product';
            prodIPTV.ProductCode = 'MDU_CollIPTV_Start_1707';
            update prodIPTV;
            
            pricebookId = stdPriceBookRecId ;
            
            Opportunity opp = new Opportunity();
            opp.Name='opp1';
            opp.CloseDate = System.today();
            opp.StageName='Needs Analysis';
            opp.Pricebook2Id=Test.getStandardPricebookId();
            insert opp;
            
            Id AccRtid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SME/SOHO Organisation').getRecordTypeId();
            
            Account testAccount = new Account();
            testAccount.recordtypeid = AccRtid;
            testAccount.Name = 'Sangram test12';
            insert testAccount;
            
            PricebookEntry objpricebookentry =new PricebookEntry();
            objpricebookentry.Product2ID = prod.id;
            objpricebookentry.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry.UnitPrice=23.50;
            objpricebookentry.UseStandardPrice=false;
            objpricebookentry.isActive=true;//Add this line
            insert objpricebookentry;
            PricebookEntry objpricebookentryIPTV =new PricebookEntry();
            objpricebookentryIPTV.Product2ID = prodIPTV.id;
            objpricebookentryIPTV.Pricebook2ID = stdPriceBookRecId;
            objpricebookentryIPTV.UnitPrice=23.50;
            objpricebookentryIPTV.UseStandardPrice=false;
            objpricebookentryIPTV.isActive=true;//Add this line
            insert objpricebookentryIPTV;
            Test.startTest();
           /**
            * Query record types---------------------------------------------------------------------------------------------------------------
            */ 
            RecordType rt = [Select id,name, DeveloperName from RecordType where Name='FA Quote'];
            RecordType CA_Quote_of_FA = [Select id,name, DeveloperName from RecordType where DeveloperName='TeliaSE_Fiber_CA_Quote_of_FA'];
            RecordType rtOffer = [Select id,name, DeveloperName from RecordType where DeveloperName='Offer'];
            RecordType rtContract = [Select id,name, DeveloperName from RecordType where DeveloperName='Contract'and Name = 'Contract Quote'];
            
            // insert parent Quote
            Quote parentQuote = new Quote();
            parentQuote.Name='Test Quote';
            parentQuote.status = 'Draft';
            parentQuote.RecordTypeId = rt.Id;
            parentQuote.opportunityId = opp.id;
            parentQuote.Pricebook2ID = stdPriceBookRecId;
            parentQuote.TeliaSE_Approval_Flag__c = False;        
            insert parentQuote;
                     
            List<QuoteLineItem> parentQLIList = new List<QuoteLineItem>();
            QuoteLineItem parentQli = new QuoteLineItem();
            parentQli.PricebookEntryId = objpricebookentry.Id;
            parentQli.QuoteId = parentQuote.id;
            parentQli.UnitPrice = 200;
            parentQli.TeliaSE_Root_Product__c = prod.id;
            parentQli.Quantity = 4;
            parentQli.Product2Id = prod.id;
            parentQli.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            parentQli.TeliaSE_Approved__c = null;
            parentQli.vlocity_cmt__RecurringCharge__c  = 200;
            parentQli.TeliaSE_Ceiling_Price__c = 400;
            parentQli.vlocity_cmt__RecurringCharge__c = 50;
            parentQli.vlocity_cmt__OneTimeCharge__c = 45;
            parentQli.TeliaSE_Fiber_Frame_Agreement__c = 10;
            parentQli.Fiber_Customer_Requested_Price__c = 50;            
            parentQLIList.add(parentQli);
            
            QuoteLineItem parentQli1 = new QuoteLineItem();
            parentQli1.PricebookEntryId = objpricebookentry.Id;
            parentQli1.QuoteId = parentQuote.id;
            parentQli1.UnitPrice = 200;
            parentQli1.TeliaSE_Root_Product__c = prod.id;
            parentQli1.Quantity = 4;
            parentQli1.Product2Id = prod.id;
            parentQli1.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            parentQli1.TeliaSE_Approved__c = null;
            parentQli1.vlocity_cmt__RecurringCharge__c  = 200;
            parentQli1.TeliaSE_Ceiling_Price__c = 400;
            parentQli1.vlocity_cmt__RecurringCharge__c = 50;
            parentQli1.vlocity_cmt__OneTimeCharge__c = 45;
            parentQli1.TeliaSE_Fiber_Frame_Agreement__c = 10;
            parentQli1.Fiber_Customer_Requested_Price__c = 50;
            parentQLIList.add(parentQli1);            
            
            insert parentQLIList;
            
            MC_CommercialNegotiation__c cn = new MC_CommercialNegotiation__c();
            cn.Default_Value__c = '12';
            cn.Name = 'MinimumCommitment';
            cn.Approved_By__c = 'CommercialManager';
            insert cn;
            
            Contract contr = new Contract();
            contr.AccountId = testAccount.Id;
            contr.StartDate = date.today();
            contr.Actionneeded__c = false;
            contr.Large_dataload__c = false;
            contr.vlocity_cmt__IsAutoRenew__c = false;
            contr.vlocity_cmt__IsFrameContract__c = false;
            contr.vlocity_cmt__QuoteId__c=parentQuote.Id;
            insert contr;
            
            List<Quote> quoteToInsert = new List<Quote>();
            Quote qut = new Quote();
            qut.Name='Test Quote';
            qut.status = 'Draft';
            qut.RecordTypeId = CA_Quote_of_FA.Id;
            qut.vlocity_cmt__FrameContractId__c = contr.Id;
            qut.opportunityId = opp.id;
            qut.Pricebook2ID = stdPriceBookRecId;
            qut.TeliaSE_Approval_Flag__c = False;       
            quoteToInsert.add(qut);
            
            Quote qut10 = new Quote();
            qut10.Name='Test Quote';
            qut10.status = 'Draft';
            qut10.RecordTypeId = rtContract.Id;
            qut10.vlocity_cmt__FrameContractId__c = contr.Id;
            qut10.opportunityId = opp.id;
            qut10.Pricebook2ID = stdPriceBookRecId;
            qut10.TeliaSE_Approval_Flag__c = False;       
            quoteToInsert.add(qut10);
            
            Quote qutCT = new Quote();
            qutCT.Name='Test QuoteCT';
            qutCT.status = 'Approved';
            qutCT.opportunityId = opp.id;
            qutCT.Pricebook2ID = stdPriceBookRecId;
            qutCT.TeliaSE_Approval_Flag__c = true; 
            quoteToInsert.add(qutCT);
            
            Quote offerQuote = new Quote();
            offerQuote.Name='Test Quote';
            offerQuote.status = 'Draft';
            offerQuote.RecordTypeId = rtOffer.Id;
            offerQuote.opportunityId = opp.id;
            offerQuote.Pricebook2ID = stdPriceBookRecId; 
            quoteToInsert.add(offerQuote);
            
            Quote qut11 = new Quote();
            qut11.Name='Test Quote';
            qut11.status = 'Draft';
            qut11.RecordTypeId = CA_Quote_of_FA.Id;
            qut11.vlocity_cmt__FrameContractId__c = contr.Id;
            qut11.opportunityId = opp.id;
            qut11.Pricebook2ID = stdPriceBookRecId;      
            quoteToInsert.add(qut11);
            
            insert quoteToInsert;
            
            List<QuoteLineItem> qliListtoInsert = new List<QuoteLineItem>();
            QuoteLineItem oli1 = new QuoteLineItem();
            oli1.PricebookEntryId = objpricebookentry.Id;
            oli1.QuoteId = qut.id;
            oli1.UnitPrice = 200;
            oli1.Quantity = 4;
            oli1.Product2Id = prod.id;
            oli1.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli1.TeliaSE_Approved__c = null;
            oli1.vlocity_cmt__RecurringCharge__c  = 200;
            oli1.TeliaSE_Ceiling_Price__c = 400;
            oli1.vlocity_cmt__RecurringCharge__c = 50;
            oli1.vlocity_cmt__OneTimeCharge__c = 45;
            oli1.TeliaSE_Fiber_Frame_Agreement__c = 10;
            oli1.Fiber_Customer_Requested_Price__c = 50;
            //insert oli1;
            qliListtoInsert.add(oli1);
            Test.stopTest();
            
            QuoteLineItem oliCT = new QuoteLineItem();
            oliCT.PricebookEntryId = objpricebookentry.Id;
            oliCT.QuoteId = qut.id;
            oliCT.UnitPrice = 200;
            oliCT.Quantity = 4;
            oliCT.Product2Id = prod.id;
            oliCT.TeliaSE_Approved__c = null;
            oliCT.vlocity_cmt__RecurringCharge__c  = 200;
            oliCT.TeliaSE_Ceiling_Price__c = 400;
            oliCT.vlocity_cmt__RecurringCharge__c = 50;
            oliCT.vlocity_cmt__OneTimeCharge__c = 45;
            oliCT.TeliaSE_Minimum_Value_Commit__c = '75';
           // insert oliCT;
            qliListtoInsert.add(oliCT);
            
            QuoteLineItem nliCT = new QuoteLineItem();
            nliCT.PricebookEntryId = objpricebookentry.Id;
            nliCT.QuoteId = qutCT.id;
            nliCT.UnitPrice = 200;
            nliCT.Quantity = 4;
            nliCT.Product2Id = prod.id;
            nliCT.TeliaSE_Approved__c = null;
            nliCT.vlocity_cmt__RecurringCharge__c  = 200;
            nliCT.TeliaSE_Ceiling_Price__c = 400;
            nliCT.vlocity_cmt__RecurringCharge__c = 50;
            nliCT.vlocity_cmt__OneTimeCharge__c = 45;
            nliCT.TeliaSE_Minimum_Value_Commit__c = '75';
            qliListtoInsert.add(nliCT);
           // insert nliCT;
            
            String jsonstring = '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000095vXTAAY","attributeid__c":"a363E0000005VknQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_PARENT","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Parent","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie6PQAS","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000095vXTAAY","attributeid__c":"a363E0000005VkqQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie6NQAS","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"displayText":"12 months","id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","sequence":1,"value":"12 months"},{"displayText":"24 months","id":"aba9e042-0545-92b0-b0d0-16cd00888e83","sequence":2,"value":"24 months"},{"displayText":"36 months","id":"cbdeb314-b13b-d53d-72ec-8e4c3370b908","sequence":3,"value":"36 months"}],"default":[],"selectedItem":{}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000095vXTAAY","attributeid__c":"a363E0000005VktQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie6OQAS","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Single Value","value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Number","uiDisplayType":"Single Value","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000095vXTAAY","attributeid__c":"a363E0000005VkuQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_SUB","attributeconfigurable__c":true,"attributedisplaysequence__c":"50","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Subsidized","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie6QQAS","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"displayText":"Yes","id":"2b5df0d6-eb1a-e9fa-950f-d6ca7614ee1e","sequence":1,"value":"Yes"},{"displayText":"No","id":"67dda21b-85c6-ce74-2955-5094c85f021c","sequence":2,"value":"No"}],"default":[],"selectedItem":{}},"$$AttributeDefinitionEnd$$":null}]}';
            QuoteLineItem oliOffer = new QuoteLineItem();
            oliOffer.PricebookEntryId = objpricebookentry.Id;
            oliOffer.QuoteId = offerQuote.id;
            //oli1.TeliaSE_Quote_RecordType__c = [Select TeliaSE_Quote_RecordType__c from QuoteLineItem where TeliaSE_Quote_RecordType__c = 'Individual Quote'];
            oliOffer.UnitPrice = 200;
            oliOffer.Quantity = 4;
            oliOffer.Product2Id = prod.id;
            oliOffer.vlocity_cmt__RecurringCharge__c  = 200;
            //oliOffer.TeliaSE_Ceiling_Price__c = 400;
            oliOffer.vlocity_cmt__RecurringCharge__c = 50;
            oliOffer.vlocity_cmt__OneTimeCharge__c = 45;
            oliOffer.TeliaSE_Fiber_Frame_Agreement__c = 10;
            oliOffer.Fiber_Customer_Requested_Price__c = 50;
            oliOffer.vlocity_cmt__JSONAttribute__c = jsonstring;
           // insert oliOffer;
            qliListtoInsert.add(oliOffer);
                        
            QuoteLineItem oliOffer1 = new QuoteLineItem();
            oliOffer1.PricebookEntryId = objpricebookentry.Id;
            oliOffer1.QuoteId = offerQuote.id;
            oliOffer1.UnitPrice = 200;
            oliOffer1.Quantity = 4;
            oliOffer1.Product2Id = prod.id;
            oliOffer1.vlocity_cmt__RecurringCharge__c  = 200;
            oliOffer1.TeliaSE_Ceiling_Price__c = 400;
            oliOffer1.vlocity_cmt__RecurringCharge__c = 50;
            oliOffer1.vlocity_cmt__OneTimeCharge__c = 45;
            oliOffer1.TeliaSE_Fiber_Frame_Agreement__c = 10;
            oliOffer1.Fiber_Customer_Requested_Price__c = 50;
           // insert oliOffer1;
            qliListtoInsert.add(oliOffer1);
            
            
            
            QuoteLineItem oliFA1 = new QuoteLineItem();
            oliFA1.PricebookEntryId = objpricebookentry.Id;
            oliFA1.QuoteId = qut.id;
            oliFA1.UnitPrice = 200;
            oliFA1.Quantity = 4;
            oliFA1.Product2Id = prod.id;
            oliFA1.TeliaSE_Approved__c = null;
            oliFA1.TeliaSE_Ceiling_Price__c = 400;
            oliFA1.vlocity_cmt__RecurringCharge__c = 50;
            oliFA1.vlocity_cmt__OneTimeCharge__c = 45;
            oliFA1.TeliaSE_Minimum_Value_Commit__c = '24';
           // insert oliFA1;
            qliListtoInsert.add(oliFA1);
            insert qliListtoInsert;
            
            List<QuoteLineItem> qliList = new List<QuoteLineItem>();
            QuoteLineItem oliFA2 = new QuoteLineItem();
            oliFA2.PricebookEntryId = objpricebookentry.Id;
            oliFA2.QuoteId = qut10.id;
            oliFA2.UnitPrice = 200;
            oliFA2.Quantity = 4;
            oliFA2.Product2Id = prodtill.id;
            oliFA2.TeliaSE_Approved__c = null;
            oliFA2.vlocity_cmt__RecurringCharge__c  = 200;
            //oliFA2.TeliaSE_Ceiling_Price__c = 400;
            oliFA2.vlocity_cmt__RecurringCharge__c = 50;
            oliFA2.vlocity_cmt__OneTimeCharge__c = 45;
            oliFA2.vlocity_cmt__ParentItemId__c = oliFA1.Id;
            oliFA2.TeliaSE_Minimum_Value_Commit__c = '24';
           // insert oliFA2;
            qliList.add(oliFA2);
            
            QuoteLineItem oliFA3 = new QuoteLineItem();
            oliFA3.PricebookEntryId = objpricebookentry.Id;
            oliFA3.QuoteId = qut10.id;
            oliFA3.UnitPrice = 200;
            oliFA3.Quantity = 4;
            oliFA3.Product2Id = prodRes.id;
            oliFA3.TeliaSE_Approved__c = null;
            oliFA3.vlocity_cmt__RecurringCharge__c  = 200;
            oliFA3.TeliaSE_Ceiling_Price__c = 400;
            oliFA3.vlocity_cmt__RecurringCharge__c = 50;
            oliFA3.vlocity_cmt__OneTimeCharge__c = 45;
            oliFA3.vlocity_cmt__ParentItemId__c = oliFA1.Id;
            qliList.add(oliFA3);
            
            QuoteLineItem oliFA4 = new QuoteLineItem();
            oliFA4.PricebookEntryId = objpricebookentry.Id;
            oliFA4.QuoteId = qut10.id;
            oliFA4.UnitPrice = 200;
            oliFA4.Quantity = 1;
            oliFA4.Product2Id = prodSub.id;
            oliFA4.TeliaSE_Ceiling_Price__c = 400;
            oliFA4.vlocity_cmt__RecurringCharge__c = 365;
            oliFA4.vlocity_cmt__OneTimeCharge__c = 45;
            oliFA4.vlocity_cmt__ParentItemId__c = oliFA1.Id;
            oliFA4.TeliaSE_AM_Mandate_Percentage__c = 4.38;
            oliFA4.TeliaSE_SM_Mandate_Percentage__c = 12.6;
            oliFA4.TeliaSE_SD_Mandate_Percentage__c = 26.3;
            oliFA4.TeliaSE_CM_Mandate_Percentage__c = 34.52;
            oliFA4.TeliaSE_MC_Customer_Requested_Price__c = 365;
            qliList.add(oliFA4);
            
            QuoteLineItem oliIPTV = new QuoteLineItem();
            oliIPTV.PricebookEntryId = objpricebookentryIPTV.Id;
            oliIPTV.QuoteId = qut.id;
            oliIPTV.Quantity = 4;
            oliIPTV.Product2Id = prodIPTV.id;
            oliIPTV.UnitPrice = 200;
            oliIPTV.vlocity_cmt__Filter__c = null;
            oliIPTV.vlocity_cmt__ParentItemId__c = null;
            oliIPTV.vlocity_cmt__RootItemId__c = null;
            oliIPTV.TeliaSE_Root_Product__c = null;
            qliList.add(oliIPTV);
            insert qliList;
            
            nliCT.TeliaSE_Minimum_Value_Commit__c = '50';
            update nliCT;
            
            
            oliFA4.TeliaSE_MC_Customer_Requested_Price__c = 270;
            oliFA4.TeliaSE_Minimum_Value_Commit__c = '75';
            update oliFA4;
            
            delete oliIPTV;
            
        }
    }
    
    public static testmethod void Test_AmountBasedProduct(){        
        Test.startTest();
        Quotelineitem Qli = [select Id FROM quotelineitem limit 1];
        Qli.TeliaSE_MC_Customer_Requested_Price__c = 15;
        Qli.TeliaSE_MC_Customer_Requested_Percentage__c = 150;
        Update Qli ;
        Test.stopTest();
    }    
   /* public static testmethod void Test_UpdateApprover1(){
        Test.startTest();
        Quotelineitem Qli = [select Id FROM quotelineitem where TeliaSE_Product_Code__c like '%MOB_CALL_TRAVEL_EUROPE%' limit 1];
        Qli.TeliaSE_Flag__c = '/resource/1549883728000/TeliaSE_Sad_Face';
        Qli.RoamingTillAddOns__c = '5 kr, 5 kr, 5 kr';
        Update Qli ;      
        Test.stopTest();
    }*/
    public static testmethod void Test_UpdateApprover2(){
        Test.startTest();
        Quotelineitem Qli1 = [select Id FROM quotelineitem where TeliaSE_Product_Code__c like '%MOB_CALL_TRAVEL_EAST%' limit 1];
        Qli1.RoamingTillAddOns__c = '0 kr, 0 kr, 0 kr';
        Update Qli1 ;        
        Test.stopTest();        
    }public static testmethod void Test_UpdateApprover3(){
        Test.startTest();
        Quotelineitem oliFA4 = [select Id FROM quotelineitem where TeliaSE_Product_Code__c like '%dummy%' limit 1];
        oliFA4.TeliaSE_MC_Customer_Requested_Price__c = 318;
        update oliFA4;     
        Test.stopTest();
    }public static testmethod void Test_UpdateApprover4(){
        Test.startTest();
        Quotelineitem oliFA4 = [select Id FROM quotelineitem where TeliaSE_Product_Code__c like '%dummy%' limit 1];
        oliFA4.TeliaSE_MC_Customer_Requested_Price__c = 250;
        update oliFA4;       
        Test.stopTest();
    }public static testmethod void Test_UpdateApprover5(){
        Test.startTest();
        Quotelineitem oliFA4 = [select Id FROM quotelineitem where TeliaSE_Product_Code__c like '%dummy%' limit 1];
        oliFA4.TeliaSE_MC_Customer_Requested_Price__c = 320;
        update oliFA4;  
        oliFA4.TeliaSE_MC_Customer_Requested_Price__c = 365;
        update oliFA4;
        Test.stopTest();
    }   
    public static testmethod void updateFiberTotalRecurringCharge(){ 
        Test.startTest();
        Quotelineitem Qli = [select Id FROM quotelineitem limit 1];
        Qli.Fiber_Customer_Requested_Price__c = 50;
        Update Qli ;
        set<Id> ids = new set<Id>();
        ids.add(Qli.Id);
        TeliaSE_QuoteLineHandler.updateRootItemForMc(ids);
        Test.stopTest();
    }
    public static testmethod void Test_PercentageBasedProduct(){        
        Test.startTest();
        Quotelineitem Qli = [select Id FROM quotelineitem limit 1];
        Qli.TeliaSE_MC_Customer_Requested_Percentage__c = 5;
        Qli.TeliaSE_MC_Customer_Requested_Price__c = 15;
        Update Qli ;
        Test.stopTest();
    }
    

    public static testmethod void Test_updateFiberFAPrice(){ 
        
        List<QuoteLineItem> olii = new List<QuoteLineItem>([select Id,TeliaSE_Root_Product__c,Fiber_Customer_Requested_Price__c,vlocity_cmt__RecurringCharge__c,vlocity_cmt__OneTimeCharge__c,QuoteId,QuoteLineItem.TeliaSE_Quote_RecordType__c,TeliaSE_Fiber_Frame_Agreement__c,TeliaSE_Product_Code__c FROM quotelineitem]);
        TeliaSE_QuoteLineHandler.updateFiberFAPrice(olii);
        QuoteLineItem oli = new QuoteLineItem();
        oli = olii[0];
        oli.Fiber_Customer_Requested_Price__c = null;
        oli.Fiber_Customer_Requested_Price__c = null;
        Test.startTest();
        update oli;
        olii.add(oli);
        TeliaSE_QuoteLineHandler.updateFiberFAPrice(olii);
        List<QuoteLineItem> olii1;
        TeliaSE_QuoteLineHandler.updateFiberFAPrice(olii1);
        Test.stopTest();
    }
    
    public static testmethod void Test_updateDiscount()
    {
        QuoteLineItem oli2 = new QuoteLineItem();
        oli2 = [SELECT Id, QuoteId, QuoteLineItem.TeliaSE_Ceiling_Price__c FROM quotelineitem limit 1];
        QuoteLineItem oli1 = new QuoteLineItem();
        oli1 = [SELECT Id, QuoteId ,  QuoteLineItem.TeliaSE_Ceiling_Price__c FROM quotelineitem limit 1];
        oli2.Fiber_Customer_Requested_Price__c = 15;
        oli1.Fiber_Customer_Requested_Price__c = 10;
        Map<Id,QuoteLineItem> olditems = new Map<Id,QuoteLineItem>();
        olditems.put(oli2.Id,oli2);
        Map<Id,QuoteLineItem> newitems = new Map<Id,QuoteLineItem>();
        newitems.put(oli1.Id,oli1);
        TeliaSE_QuoteLineHandler.updateDiscount(olditems, newitems);       
    }
    
    public static testmethod void Test_updateRootProductId()
    {
        Set<Id> mySet = new Set<Id>();
        TeliaSE_QuoteLineHandler.updateRootProductId(mySet);
    }
    public static testmethod void Test_HidePTPlusAttributes(){        
        
        List<Quotelineitem> QliList = [select Id from QuoteLineItem where Quote.RecordType.DeveloperName = 'Offer' limit 1];
        Set<Id> ids = new set<Id>();
        for(Quotelineitem q:QliList){
            ids.add(q.Id);
        }
        Test.startTest();
        TeliaSE_QuoteLineHandler.HidePTPlusAttributes(ids);   
        Test.stopTest();
    }    
}