/**-----------------------------------------------------------------------------------------------------------
 * Name: Test_TeliaSE_QuoteTrigger
 * Created By: Vaishali Srivastava
 * Sprint: Sprint-2
 * User Story:MCSTO-423
 * Description:Test class for Trigger Telia SE_QuoteTrigger.
 * 
 * Modifications:
 * 09.12.2022 [Tomass Brazovskis] SALEF-7206 - Replaced Almond package TestUtilClass' createUsersOriginal() method with the Telia-built
 *              Test_DataFactory's createAdminUser() method to enable the removal of the obsolete Almond package.
-----------------------------------------------------------------------------------------------------------*/
@isTest
private class Test_TeliaSE_QuoteTrigger{   
    //public Boolean testClassVar=true;
    public class MyException extends Exception {}
    static TeliaSERecordTypeSetting__mdt TeliaSERecordTypeSetting ;
    @testSetup static void setup(){
        Test.startTest();        
        User salesManager; 
        User salesRep;
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        
        System.runAs(new User(Id = Userinfo.getUserId())){
            salesRep = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesRep.Bypass_VR__c = true;
            salesRep.Telia_Id__c = 'xyz143';
            salesRep.MassCustomized_Roles__c = 'SalesManager';
            insert salesRep;
            
            salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManager.Bypass_VR__c = true;
            salesManager.Telia_Id__c = 'xyz123';
            salesManager.MassCustomized_Roles__c = 'SalesRep';
            salesManager.TeliaSE_Role_based_Approver__c = salesRep.Id;
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
        List<sObject> types=new List<sObject>();
        SObject sObj = [SELECT Id, SobjectType, DeveloperName FROM RecordType WHERE IsActive = TRUE and SobjectType = 'vlocity_cmt__ObjectClass__c' and DeveloperName = 'ObjectType' LIMIT 1];   
        vlocity_cmt__ObjectClass__c COType = new vlocity_cmt__ObjectClass__c(Name = 'Broadband Start Offering Spec', vlocity_cmt__ObjectApiName__c = 'Product2', RecordTypeId = sObj.Id);
        
        vlocity_cmt__ObjectClass__c NonCO = new vlocity_cmt__ObjectClass__c(Name = 'Mobile Offer Specification', vlocity_cmt__ObjectApiName__c = 'Product2', RecordTypeId = sObj.Id);
        types.add(COType);
        types.add(NonCO);
        insert types;
        
        
        
        System.runAs(salesManager){
            ByPassTrigger__c byPassQuote = new ByPassTrigger__c();
            byPassQuote.QuoteTrigger__c = true;
            byPassQuote.QuoteLineItemTrigger__c = true;
            byPassQuote.setupownerid = userinfo.getUserId();
            insert byPassQuote;
            
            List<Product2> proList=new List<Product2>();    
            Product2 prod = Test_DataFactory.createProducts(1)[0];
            
            prod.ProductCode = 'MOB_SURF';
            prod.Parent_Family__c = 'ICT';
            proList.add(prod);
            
            Product2 prod1 = Test_DataFactory.createProducts(1)[0];
            
            prod1.ProductCode = 'MOB_MULTI';
            prod1.Parent_Family__c = 'ICT';
            proList.add(prod1);
            
            Product2 prod2 = Test_DataFactory.createProducts(1)[0];
            
            prod2.ProductCode = 'PT_PLUS';
            prod2.Parent_Family__c = 'ICT';
            proList.add(prod2);
            
            Product2 prod3 = Test_DataFactory.createProducts(1)[0];
            prod3.name = 'Telia Bredband Start';
            prod3.productCode = 'CO-BBPRO';
            prod3.vlocity_cmt__ObjectTypeId__c=COType.Id;
            prod3.Parent_Family__c = 'ICT';
            proList.add(prod3);  
            
            Product2 prod4 = Test_DataFactory.createProducts(1)[0];
            prod4.name = 'abc';
            prod4.productCode = 'NonCO-BBPRO';
            prod4.vlocity_cmt__ObjectTypeId__c=NonCO.Id;
            prod4.Parent_Family__c = 'ICT';
            proList.add(prod4);
            
            insert proList;
            
            pricebookId = stdPriceBookRecId ;
            
            Opportunity opp = new Opportunity();
            opp.Name='opp1';
            opp.CloseDate = System.today();
            opp.StageName='Needs Analysis';  
            opp.Pricebook2Id=Test.getStandardPricebookId();
            opp.TeliaSE_SharingSetting_Flag__c = false;
            
            insert opp;
            
            
            
            List<PricebookEntry> priceList=new List<PricebookEntry>();
            PricebookEntry objpricebookentry =new PricebookEntry();
            objpricebookentry.Product2ID = prod.id;
            objpricebookentry.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry.UnitPrice=23.50;
            objpricebookentry.UseStandardPrice=false;
            objpricebookentry.isActive=true;//Add this line
            priceList.add(objpricebookentry);
            
            PricebookEntry objpricebookentry1 =new PricebookEntry();
            objpricebookentry1.Product2ID = prod1.id;
            objpricebookentry1.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry1.UnitPrice=23.50;
            objpricebookentry1.UseStandardPrice=false;
            objpricebookentry1.isActive=true;//Add this line
            priceList.add(objpricebookentry1);
            
            PricebookEntry objpricebookentry3 =new PricebookEntry();
            objpricebookentry3.Product2ID = prod3.id;
            objpricebookentry3.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry3.UnitPrice=23.50;
            objpricebookentry3.UseStandardPrice=false;
            objpricebookentry3.isActive=true;//Add this line
            priceList.add(objpricebookentry3);
            
            
            PricebookEntry objpricebookentry4 =new PricebookEntry();
            objpricebookentry4.Product2ID = prod4.id;
            objpricebookentry4.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry4.UnitPrice=23.50;
            objpricebookentry4.UseStandardPrice=false;
            objpricebookentry4.isActive=true;//Add this line
            priceList.add(objpricebookentry4);
            insert priceList;
            
            
            
            TeliaSERecordTypeSetting = returnTestingMetadataRecord();
            Quote qut = new Quote();
            qut.Name='Test Quote';
            qut.status = 'Draft';
            qut.Recordtypeid   = SEUTility.getRecordTypeId('Individual_Quote');
            qut.opportunityId = opp.id;
            qut.Pricebook2ID = stdPriceBookRecId;
            qut.TeliaSE_Approval_Flag__c = False;
            qut.TeliaSE_Fiber_EBIT_Percentage__c = 26;
            //qut.TeliaSE_fiber_Rabatt__c = 123;
            qut.BlaKalkyl_Description__c  = 'EBIT %  34.36 \n Revenue contract  663527706 \n Revenue contract årligen  132705541 \n OPEX  357219461 \n Capex Infra  22828257 \n Avtalstid  5 \n Upsell/Singeltjänster  422444497 \n Depr  78332172 \n Kundplacerad utrustning  46872000 \n ACK DCF  187146402 \n ACK DCF årligen  37429280 \n Return of Investment  198.56 \n PayBack WACC  2.1 \n Engång Fastighetsägare  0 \n Kollektiva intäkter  20563200 \n Pris 3Play exkl moms  0 \n Pris BB exkl. moms  0 \n Pris TV exkl moms  16 \n As is avtalstid kvar  1 \n Rev As is kvarvarande tid  686176 \n Rev As is kvarv. tid årligen  686176 \n As is ACK DCF  145236 \n As is ACK DCF årligen  145236 \n 3Play Pris As is exkl moms  0.00 \n Pris BB exkl. moms As is case  0.00 \n Pris TV exkl moms As is case  0.00 \n Revenue B2C  439019293 \n Revenue B2B   0 \n External Revenue INFRA  0 \n Rev. Smart Building Services  90508530 \n Rev. Fastighets IT   3988404 \n Rev. WiFi i Allmänna utr.  38556000 \n Rev. Telia Smart Home  73513440 \n Rev. Mobile X-sell  17942039 \n Byggnader med Fastighets-IT  532 \n Accespunkter WiFi  2660';
            insert qut;
            
            qut.status = 'Sent For Approval';
            qut.BlaKalkyl_Description__c  = 'EBIT %  34.36 \n Revenue contract  663527706 \n Revenue contract årligen  132705541 \n OPEX  357219461 \n Capex Infra  22828257 \n Avtalstid  5 \n Upsell/Singeltjänster  422444497 \n Depr  78332172 \n Kundplacerad utrustning  46872000 \n ACK DCF  187146402 \n ACK DCF årligen  37429280 \n Return of Investment  198.56 \n PayBack WACC  2.1 \n Engång Fastighetsägare  0 \n Kollektiva intäkter  20563200 \n Pris 3Play exkl moms  0 \n Pris BB exkl. moms  0 \n Pris TV exkl moms  16 \n As is avtalstid kvar  1 \n Rev As is kvarvarande tid  686176 \n Rev As is kvarv. tid årligen  686176 \n As is ACK DCF  145236 \n As is ACK DCF årligen  145236 \n 3Play Pris As is exkl moms  0.00 \n Pris BB exkl. moms As is case  0.00 \n Pris TV exkl moms As is case  0.00 \n Revenue B2C  439019293 \n Revenue B2B   0 \n External Revenue INFRA  0 \n Rev. Smart Building Services  90508530 \n Rev. Fastighets IT   3988404 \n Rev. WiFi i Allmänna utr.  38556000 \n Rev. Telia Smart Home  73513440 \n Rev. Mobile X-sell  17942039 \n Byggnader med Fastighets-IT  532 \n Accespunkter WiFi  2660';
            update qut;
            
            qut.status = 'Price Approved';
            update qut;
            
            List<QuoteLineItem> qliList=new List<QuoteLineItem>();   
            QuoteLineItem oli1 = new QuoteLineItem();
            oli1.PricebookEntryId = objpricebookentry.Id;
            oli1.QuoteId = qut.id;
            oli1.UnitPrice = 200;
            oli1.Quantity = 4;
            oli1.Product2Id = prod.id;
            oli1.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli1.TeliaSE_MC_Customer_Requested_Percentage__c = 5;
            oli1.TeliaSE_MC_Customer_Requested_Price__c = 150;
            oli1.TeliaSE_Approved__c = null;
            oli1.Fiber_Approved_Price__c = null;
            oli1.TeliaSE_fiber_Rabatt__c = 10;
            oli1.Fiber_Customer_Requested_Price__c = 120;
            qliList.add(oli1);
            
            RecordType rr = [Select id from recordType where developerName = 'Offer'];    
            QuoteLineItem oli11 = new QuoteLineItem();
            oli11.PricebookEntryId = objpricebookentry1.Id;
            oli11.QuoteId = qut.id;
            oli11.UnitPrice = 200;
            oli11.Quantity = 4;
            oli11.Product2Id = prod1.id;
            oli11.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli11.TeliaSE_MC_Customer_Requested_Percentage__c = 5;
            oli11.TeliaSE_MC_Customer_Requested_Price__c = 150;
            oli11.vlocity_cmt__OneTimeCharge__c = 213;
            oli11.MC_OT_Approved_Price__c =216;
            oli11.TeliaSE_Approved__c = null;
            qliList.add(oli11);
            
            QuoteLineItem oli111 = new QuoteLineItem(); 
            oli111.PricebookEntryId = objpricebookentry3.Id;
            oli111.QuoteId = qut.id;
            oli111.UnitPrice = 200;
            oli111.Quantity = 4;
            oli111.Product2Id = prod3.id;
            oli111.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli111.TeliaSE_MC_Customer_Requested_Percentage__c = 5;
            oli111.TeliaSE_MC_Customer_Requested_Price__c = 150;
            oli111.vlocity_cmt__OneTimeCharge__c = 213;
            oli111.MC_OT_Approved_Price__c =216;
            oli111.TeliaSE_Approved__c = null;
            oli111.vlocity_cmt__ParentItemId__c = null;
            qliList.add(oli111);
            
            QuoteLineItem oli1112 = new QuoteLineItem(); 
            oli1112.PricebookEntryId = objpricebookentry4.Id;
            oli1112.QuoteId = qut.id;
            oli1112.UnitPrice = 200;
            oli1112.Quantity = 4;
            oli1112.Product2Id = prod4.id;
            oli1112.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli1112.TeliaSE_MC_Customer_Requested_Percentage__c = 5;
            oli1112.TeliaSE_MC_Customer_Requested_Price__c = 150;
            oli1112.vlocity_cmt__OneTimeCharge__c = 213;
            oli1112.MC_OT_Approved_Price__c =216;
            oli1112.TeliaSE_Approved__c = null;
            oli1112.vlocity_cmt__ParentItemId__c = null;
            oli1112.TeliaSE_Approved_Price__c = null;
            qliList.add(oli1112);
            insert qliList;
            
            list<quote> quoteList = new list<quote>();
            Quote qut2 = new Quote();
            qut2.Name='Test Quote2';
            qut2.status = 'Draft';
            qut2.opportunityId = opp.id;
            qut2.Pricebook2ID = stdPriceBookRecId;
            qut2.TeliaSE_Approval_Flag__c = False;  
            //insert qut2; 
            quoteList.add(qut2);
            
            Quote qut4 = new Quote();
            qut4.Name='Test Quote4';
            qut4.status = 'Draft';
            qut4.opportunityId = opp.id;
            qut4.Pricebook2ID = stdPriceBookRecId;
            qut4.TeliaSE_Approval_Flag__c = False;
            qut4.RecordTypeId = rr.Id;
            qut4.TeliaSE_Approval_Flag__c = True;
            //insert qut4;     
            quoteList.add(qut4);
            
            Quote qut3 = new Quote();
            qut3.Name='Test Quote3';
            qut3.status = 'Sent For Approval';
            qut3.opportunityId = opp.id;
            
            qut3.Pricebook2ID = stdPriceBookRecId;
            qut3.TeliaSE_Approval_Flag__c = False;        
            //insert qut3;
            quoteList.add(qut3);
            insert quoteList;
            
            
            QuoteLineItem oli2 = new QuoteLineItem();
            oli2.PricebookEntryId = objpricebookentry.Id;
            oli2.QuoteId = qut2.id;
            oli2.UnitPrice = 200;
            oli2.Quantity = 4;
            oli2.Product2Id = prod.id;
            oli2.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli2.TeliaSE_Approved_Flag__c = '/resource/1549546732000/TeliaSE_Sad_Face';
            oli2.TeliaSE_MC_Customer_Requested_Percentage__c = 5;
            oli2.TeliaSE_MC_Customer_Requested_Price__c = 150;
            oli2.vlocity_cmt__OneTimeCharge__c = 213;
            oli2.MC_OT_Approved_Price__c =212;
            oli2.TeliaSE_Approved__c = null;
            oli2.TeliaSE_Approved__c = 3;
            oli2.TeliaSE_Nullify_Check__c = true;
            oli2.TeliaSE_Approved_Price__c = null;
            insert oli2;
            
            list<QuoteLineItem> qliList1 = new list<QuoteLineItem>();
            QuoteLineItem oli22 = new QuoteLineItem();
            oli22.PricebookEntryId = objpricebookentry1.Id;
            oli22.QuoteId = qut2.id;
            oli22.UnitPrice = 200;
            oli22.Quantity = 4;
            oli22.Product2Id = prod1.id;
            oli22.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli22.TeliaSE_Approved_Flag__c = '/resource/1549546732000/TeliaSE_Sad_Face';
            oli22.TeliaSE_MC_Customer_Requested_Percentage__c = 5;
            oli22.TeliaSE_MC_Customer_Requested_Price__c = 150;
            oli22.TeliaSE_Approved__c = 3;
            oli2.TeliaSE_Approved__c = null;
            oli22.vlocity_cmt__OneTimeCharge__c = 213;
            oli22.TeliaSE_Approved_Price__c = 152;
            //insert oli22;
            qliList1.add(oli22);
            
            QuoteLineItem oli23 = new QuoteLineItem();
            oli23.PricebookEntryId = objpricebookentry1.Id;
            oli23.QuoteId = qut4.id;
            oli23.UnitPrice = 200;
            oli23.Quantity = 4;
            oli23.Product2Id = prod1.id;
            oli23.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli23.TeliaSE_Approved_Flag__c = '/resource/1549546732000/TeliaSE_Sad_Face';
            oli23.TeliaSE_MC_Customer_Requested_Percentage__c = 5;
            oli23.TeliaSE_MC_Customer_Requested_Price__c = 150;
            oli23.TeliaSE_Approved__c = 3;
            oli23.vlocity_cmt__OneTimeCharge__c = 213;
            oli23.TeliaSE_Approved_Price__c = 152;
            oli23.vlocity_cmt__JSONAttribute__c = '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1l000003h58QAAQ","attributeid__c":"a364E0000001ES2QAM","attributecategoryid__c":"a354E0000002E2zQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a331l000000AJK0AAO","isrequired__c":true,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"displayText":"12 months","id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","sequence":1,"value":"12 months"},{"displayText":"24 months","id":"aba9e042-0545-92b0-b0d0-16cd00888e83","sequence":2,"value":"24 months"},{"displayText":"36 months","id":"cbdeb314-b13b-d53d-72ec-8e4c3370b908","sequence":3,"value":"36 months"}],"default":[],"selectedItem":{"displayText":"12 months","id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","sequence":1,"value":"12 months"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1l000003h58QAAQ","attributeid__c":"a364E0000001ES5QAM","attributecategoryid__c":"a354E0000002E2zQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a331l000000AJK3AAO","isrequired__c":true,"rulemessage__c":null,"uidisplaytype__c":"Single Value","value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Number","uiDisplayType":"Single Value","value":88},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1l000003h58QAAQ","attributeid__c":"a364E0000001ES6QAM","attributecategoryid__c":"a354E0000002E2zQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_SUB","attributeconfigurable__c":true,"attributedisplaysequence__c":"50","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Subsidized","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a331l000000AJK6AAO","isrequired__c":true,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"displayText":"Yes","id":"2b5df0d6-eb1a-e9fa-950f-d6ca7614ee1e","sequence":1,"value":"Yes"},{"displayText":"No","id":"67dda21b-85c6-ce74-2955-5094c85f021c","sequence":2,"value":"No"}],"default":[],"selectedItem":{"displayText":"Yes","id":"2b5df0d6-eb1a-e9fa-950f-d6ca7614ee1e","sequence":1,"value":"Yes"}},"$$AttributeDefinitionEnd$$":null}]}';
            // insert oli23;
            qliList1.add(oli23);
            insert qliList1;
            
            
            Test.stopTest();
        }
    }
    public static testmethod void Test_checkPrimaryQuotes(){ 
        ByPassTrigger__c byPassQuote = new ByPassTrigger__c();
        byPassQuote.QuoteTrigger__c = true;
        byPassQuote.QuoteLineItemTrigger__c = true;
        byPassQuote.setupownerid = userinfo.getUserId();
        insert byPassQuote;
        Test.startTest();
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        
        Product2 prod = Test_DataFactory.createProducts(1)[0];
        prod.Parent_Family__c = 'ICT';
        insert prod;
        pricebookId = stdPriceBookRecId ;
        
        /* Opportunity opp1 = new Opportunity();
opp1.Name='opp333';
opp1.CloseDate = System.today();
opp1.StageName='Needs Analysis';  
opp1.Pricebook2Id=Test.getStandardPricebookId();
opp1.TeliaSE_SharingSetting_Flag__c = false;    

insert opp1;*/
        Opportunity opp1 = [Select TeliaSE_SharingSetting_Flag__c, id from Opportunity where name = 'opp1' ];
        
        
        
        PricebookEntry objpricebookentry =new PricebookEntry();
        objpricebookentry.Product2ID = prod.id;
        objpricebookentry.Pricebook2ID = stdPriceBookRecId;
        objpricebookentry.UnitPrice=23.50;
        objpricebookentry.UseStandardPrice=false;
        objpricebookentry.isActive=true;//Add this line
        insert objpricebookentry;
        
        
        TeliaSERecordTypeSetting = returnTestingMetadataRecord();
        list<quote> quoteList1 = new list<quote>();
        Quote qut = new Quote();
        qut.Name='Test Quote';
        qut.status = 'Sent For Approval';
        qut.Recordtypeid   = SEUTility.getRecordTypeId('Individual_Quote');
        qut.opportunityId = opp1.id;
        qut.Pricebook2ID = stdPriceBookRecId;
        qut.TeliaSE_Approval_Flag__c = False;
        qut.TeliaSE_Fiber_EBIT_Percentage__c = 26;
        qut.TeliaSWE_Primary_Quote__c = true;
        //insert qut;
        quoteList1.add(qut);
        
        Quote qut2 = new Quote();
        qut2.Name='Test Quote2';
        qut2.status = 'Draft';
        qut2.opportunityId = opp1.id;
        qut2.Pricebook2ID = stdPriceBookRecId;
        qut2.TeliaSE_Approval_Flag__c = False;  
        qut2.TeliaSWE_Primary_Quote__c=true;
        //insert qut2;
        quoteList1.add(qut2);
        insert quoteList1;
        /*Map<Id,Quote> mapQuote=new Map<Id,Quote>();
Quote q=([select id,TeliaSWE_Primary_Quote__c,OpportunityId from quote where Name='Test Quote2'])[0];
mapQuote.put(q.id,q);
Telia_SEQuoteHandler.checkPrimaryQuotes(mapQuote);*/
        Test.stopTest();
    }
    public static testmethod void Test_PreventDeletion(){ 
        ByPassTrigger__c byPassQuote = new ByPassTrigger__c();
        byPassQuote.QuoteTrigger__c = true;
        byPassQuote.QuoteLineItemTrigger__c = true;
        byPassQuote.setupownerid = userinfo.getUserId();
        insert byPassQuote;
        test.startTest();
        Quote Ql = [select name, Id,status,TeliaSE_Approval_Flag__c   FROM quote where name = 'Test Quote'];
        // Perform test
        Database.DeleteResult result = Database.delete(ql, false);
        test.stopTest();
        
    }
    public static testmethod void Test_UpdateApproval(){ 
        try{
            ByPassTrigger__c byPassQuote = new ByPassTrigger__c();
            byPassQuote.QuoteTrigger__c = true;
            byPassQuote.QuoteLineItemTrigger__c = true;
            byPassQuote.setupownerid = userinfo.getUserId();
            insert byPassQuote;
            test.startTest();
            Quote Ql = [select name, Id,status,TeliaSE_Approval_Flag__c,TeliaSE_Approval_Count__c   FROM quote where name = 'Test Quote4'];
            List<QuoteLineItem> qlist = new List<QuoteLineItem>();
            qlist = [select Id,TeliaSE_Product_Code__c from QuoteLineItem where QuoteId =: Ql.Id];
            Map<Id,QuoteLineItem> qliMap = new MAp<Id,QuoteLineItem>();
            
            for(QuoteLineItem q: qlist){
                qliMap.put(q.Id,q);
            }
            Telia_SEQuoteHandler.updatePTAttribute(qliMap);
            Telia_SEQuoteHandler.HidePTPlusAttributes(qliMap.keySet());
            Ql.Status = 'Sent For Approval';
            update Ql;
            Ql.Status = 'Approved';
            update Ql;
            List<Quote> quotesList=new List<Quote>();
            quotesList.add(Ql);
            Telia_SEQuoteHandler.checkDeletion(quotesList);
            
            test.stopTest();
        }
        catch(exception e){
            
        }
        
        
    }

    /**@Description:
     * Modifications:
     *  09.12.2022 [TB] SALEF-7206 - Use Test_DataFactory.createAdminUser(), instead of the Almond packages TestUtilClass.createUsersOriginal(),
     *             to create Admin test Users.
     **/ 
    public static testmethod void Test_ApprovalFlag(){ 
        ByPassTrigger__c byPassQuote = new ByPassTrigger__c();
        byPassQuote.QuoteTrigger__c = true;
        byPassQuote.QuoteLineItemTrigger__c = true;
        byPassQuote.setupownerid = userinfo.getUserId();
        insert byPassQuote;
        
        Test.StartTest();
        
        Quote Q2 = [select name, Id,status,TeliaSE_Approval_Flag__c   FROM quote where name = 'Test Quote'];
        //q2.status = 'Sent For Approval';
        q2.status = 'Price Approved';
        q2.TeliaSE_Fiber_EBIT_Percentage__c = 2;
        q2.TeliaSE_Approval_Flag__c = True;
        
        List<User> adminUsers = new List<User>();
        for(Integer i = 0; i < 4; i++){
            adminUsers.add(Test_DataFactory.createAdminUser());
        }
        insert adminUsers;
        
        adminUsers[0].ManagerId = adminUsers[1].Id;
        adminUsers[0].Bypass_VR__c = true;
        
        
        adminUsers[1].ManagerId = adminUsers[2].Id;
        adminUsers[2].ManagerId = adminUsers[3].Id;
        //update 
        update adminUsers;
        Opportunity opp1 = [Select TeliaSE_SharingSetting_Flag__c, id from Opportunity where name = 'opp1' ];
        opp1.ownerId = adminUsers[0].Id;
        //update opp1;
        system.runAs(adminUsers[1]){
            // Create an approval request for the account
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setProcessDefinitionNameOrId('Fiber_Quote_Approval_Process');
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(q2.id);
            
            // Submit on behalf of a specific submitter
            req1.setSubmitterId(adminUsers[0].Id);
            
            // Submit the record to specific process and skip the criteria evaluation
            req1.setProcessDefinitionNameOrId('Fiber_Quote_Approval_Process');
            req1.setSkipEntryCriteria(true);
            
            // Submit the approval request for the account
            Approval.ProcessResult result = Approval.process(req1);
            //Update Q2;
            //Test.StopTest();
            
            //Test.StartTest();
            QuoteLineItem oli1 = new QuoteLineItem();
            oli1.PricebookEntryId = [select id from PricebookEntry where IsActive=true limit 1][0].Id;
            oli1.QuoteId = q2.id;
            oli1.UnitPrice = 200;
            oli1.Quantity = 4;
            oli1.Product2Id = [select id from Product2 limit 1][0].Id;
            oli1.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli1.TeliaSE_MC_Customer_Requested_Percentage__c = 5;
            oli1.TeliaSE_MC_Customer_Requested_Price__c = 150;
            oli1.TeliaSE_Approved__c = null;
            oli1.Fiber_Approved_Price__c = null;
            oli1.TeliaSE_fiber_Rabatt__c = 10;
            oli1.Fiber_Customer_Requested_Price__c = 120;
            insert oli1;
            
            Update Q2;
            Test.StopTest();
        }
        
    }
    
    
    @isTest
    static void Test_ApprovalProcess(){
        ByPassTrigger__c byPassQuote = new ByPassTrigger__c();
        byPassQuote.QuoteTrigger__c = true;
        byPassQuote.QuoteLineItemTrigger__c = true;
        byPassQuote.setupownerid = userinfo.getUserId();
        insert byPassQuote;
        test.startTest();
        Quote[] q2 = [select name, Id, status, TeliaSE_Approval_Flag__c   FROM quote where name = 'Test Quote2'];        
        Quote[] q3 = [select name, Id, status, TeliaSE_Approval_Flag__c   FROM quote where name = 'Test Quote2'];
        
        q2[0].status = 'new';
        update q2;
        
        approveQuote(q2[0].id);
        q2[0].status = 'new';
        update q2;
        
        Map<Id,Quote>MapOldQuotes = new Map<Id,Quote>(q2);
        Map<Id,Quote>MapNewQuotes = new Map<Id,Quote>(q3);
        Telia_SEQuoteHandler.postFeedOnApproveReject(q2,MapOldQuotes,MapNewQuotes);
        test.stopTest();
    }
    
    private static void approveQuote(Id quoteId){
        try{
            User salesManager = [select id from User where Telia_Id__c =: 'xyz123'];
            user salesrep = [select id from User where Telia_Id__c =: 'xyz143'];
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setProcessDefinitionNameOrId('TeliaSE_RoleBasedQuoteApproval');
            req.setComments('Submitting request for approval.');
            req.setSubmitterId(salesManager.id);
            req.setSkipEntryCriteria(true);
            req.setNextApproverIds(new Id[] {salesRep.id});
            req.setObjectId(quoteId);
            
            Approval.ProcessResult resu = Approval.process(req);
            
            // Verify the result
            System.assert(resu.isSuccess());
            
            System.assertEquals('Pending', resu.getInstanceStatus(),'Instance Status'+resu.getInstanceStatus());
            List<Id> newWorkItemIds = resu.getNewWorkitemIds();
            
            Approval.ProcessWorkitemRequest req2 =  new Approval.ProcessWorkitemRequest();
            req2.setComments('Approving request.');
            req2.setAction('Approve');
            req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});//UserInfo.getUserId()
            // Use the ID from the newly created item to specify the item to be worked
            req2.setWorkitemId(newWorkItemIds.get(0));
            // Submit the request for approval
            Approval.ProcessResult result2 =  Approval.process(req2);
            
            // Verify the results
            System.assert(result2.isSuccess(), 'Result Status:'+result2.isSuccess());
            
            System.assertEquals(  'Approved', result2.getInstanceStatus(),'Instance Status'+result2.getInstanceStatus());
        } catch(exception e){
            
        }
    }
    
    public static testmethod void CheckMandate(){
        ByPassTrigger__c byPassQuote = new ByPassTrigger__c();
        byPassQuote.QuoteTrigger__c = true;
        byPassQuote.QuoteLineItemTrigger__c = true;
        byPassQuote.setupownerid = userinfo.getUserId();
        insert byPassQuote;
        test.startTest();
        //ProcessInstance
        //User
        //MC_CommercialNegotiation__c
        //MC_RolePrecedence__c
        User salesManag;
        System.runAs(new User(Id = Userinfo.getUserId())){
            salesManag = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManag.Telia_Id__c = 'xyz124';
            salesManag.MassCustomized_Roles__c = 'SalesManager';
            //salesManag.TeliaSE_Role_based_Approver__c = SalesDirctr.id;   
            insert salesManag;
        } 
        User salesRep;
        System.runAs(new User(Id = Userinfo.getUserId())){
            salesRep = Test_DataFactory.createSalesRepUsers(1)[0];
            salesRep.Telia_Id__c = 'XXX124';
            salesRep.MassCustomized_Roles__c = 'SalesRep';
            salesRep.TeliaSE_Role_based_Approver__c = salesManag.id;
            insert salesRep;
        }
        MC_RolePrecedence__c srep = new MC_RolePrecedence__c();
        srep.Name = 'SalesRep';
        srep.Precedence__c = 1;
        insert srep;
        
        MC_RolePrecedence__c mcr = new MC_RolePrecedence__c();
        mcr.Name = 'SalesManager';
        mcr.Precedence__c = 2;
        insert mcr;
        
        MC_RolePrecedence__c mcr1 = new MC_RolePrecedence__c();
        mcr1.Name = 'SalesDirector';
        mcr1.Precedence__c = 3;
        insert mcr1;
        
        MC_CommercialNegotiation__c MCC = new MC_CommercialNegotiation__c();
        MCC.Name='Payment Terms';
        MCC.Approved_By__c='SalesDirector';
        MCC.Default_Value__c='30';
        MCC.Approval_Required__c= true;
        insert MCC;
        
        MC_CommercialNegotiation__c MCC1 = new MC_CommercialNegotiation__c();
        MCC1.Name='Invoice Fee';
        MCC1.Approved_By__c='SalesManager';
        MCC1.Default_Value__c='Ja';
        MCC1.Approval_Required__c= true;
        insert MCC1;
        
        MC_CommercialNegotiation__c MCC2 = new MC_CommercialNegotiation__c();
        MCC2.Name='Benchmarking Agreements';
        MCC2.Approved_By__c='SalesRep';
        MCC2.Default_Value__c='Nej';
        MCC2.Approval_Required__c= false;
        insert MCC2;
        
        MC_CommercialNegotiation__c MCC3 = new MC_CommercialNegotiation__c();
        MCC3.Name='TimeToReachBaseLevel';
        MCC3.Approved_By__c='SalesRep';
        MCC3.Default_Value__c='3';
        MCC3.Approval_Required__c= false;
        insert MCC3;
        
        MC_CommercialNegotiation__c MCC4 = new MC_CommercialNegotiation__c();
        MCC4.Name='MinimumCommitment';
        MCC4.Approved_By__c='SalesManager';
        MCC4.Default_Value__c='75';
        MCC4.Approval_Required__c= true;
        insert MCC4;
        
        Product2 prod = Test_DataFactory.createProducts(1)[0];
        prod.Parent_Family__c = 'ICT';
        insert prod;
        
        User salesManager;         
        //  Id pricebookId;
        // Id stdPriceBookRecId = Test.getStandardPricebookId();    
        //pricebookId = stdPriceBookRecId ;
        //List<String> stdPriceBookRecId = new List<String>([SELECT Id, isstandard FROM Pricebook2 WHERE IsStandard=true]);
        String pricebookId = '01s24000000BkpHAAS';
        
        
        Opportunity opp2 = new Opportunity();
        opp2 = [Select Id from Opportunity Limit 1];
        /*     opp.Name='opp1';
opp.CloseDate = System.today();
opp.StageName='Needs Analysis';  
opp.Pricebook2Id=Test.getStandardPricebookId();
opp.TeliaSE_SharingSetting_Flag__c = false;

insert opp;    */
        
        PricebookEntry objpricebookentry =new PricebookEntry();
        objpricebookentry.Product2ID = prod.id;
        objpricebookentry.Pricebook2ID = pricebookId;
        objpricebookentry.UnitPrice=23.50;
        objpricebookentry.UseStandardPrice=false;
        objpricebookentry.isActive=true;//Add this line
        insert objpricebookentry;
        List<Quote> quoteList = new List<Quote>();
        Quote myqut = new Quote();
        myqut.Name='Test Quote';
        myqut.status = 'Draft';
        myqut.Recordtypeid = SEUTility.getRecordTypeId('Offer');
        myqut.opportunityId = opp2.id;      
        myqut.Pricebook2ID = pricebookId;
        myqut.TeliaSE_Approval_Flag__c = False; 
        myqut.Type_of_Address__c = 'MDU';
        //myqut.TeliaSE_Invoice_Fee__c = 'Yes';
        insert myqut;
        quoteList.add(myqut);
        QuoteLineItem oli1 = new QuoteLineItem();
        oli1.PricebookEntryId = objpricebookentry.Id;
        oli1.QuoteId = myqut.id;
        oli1.UnitPrice = 200;
        oli1.Quantity = 4;
        oli1.Product2Id = prod.id;
        oli1.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
        oli1.TeliaSE_MC_Customer_Requested_Percentage__c = 50000000;
        
        oli1.TeliaSE_MC_Customer_Requested_Price__c = 0;
        oli1.TeliaSE_Approved__c = null;
        insert oli1;
        
        QuoteLineItem oli12 = new QuoteLineItem();
        oli12.PricebookEntryId = objpricebookentry.Id;
        oli12.QuoteId = myqut.id;
        oli12.UnitPrice = 200;
        oli12.Quantity = 4;
        oli12.Product2Id = prod.id;
        oli12.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
        oli12.TeliaSE_MC_Customer_Requested_Percentage__c = 50000000;
        oli12.vlocity_cmt__ParentItemId__c = oli1.Id;
        oli12.TeliaSE_MC_Customer_Requested_Price__c = 0;
        oli12.TeliaSE_Approved__c = null;
        insert oli12;
        myqut.Status = 'Sent For Approval';
        myqut.TeliaSE_Comments__c = 'Approval request for Pre-Mature Renegotiation';
        
        update myqut;
        
        
        myqut.Status = 'Approved';   
        update myqut;
        
        
        Quote myqut1 = new Quote();
        myqut1.Name='Test Quote';
        myqut1.status = 'Draft';
        
        myqut1.opportunityId = opp2.id;
        
        
        myqut1.Pricebook2ID = pricebookId;
        myqut1.TeliaSE_Approval_Flag__c = False;        
        insert myqut1;
        quoteList.add(myqut1);
        QuoteLineItem oli11 = new QuoteLineItem();
        oli11.PricebookEntryId = objpricebookentry.Id;
        oli11.QuoteId = myqut1.id;
        oli11.UnitPrice = 200;
        oli11.Quantity = 4;
        oli11.Product2Id = prod.id;
        oli11.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
        oli11.TeliaSE_MC_Customer_Requested_Percentage__c = 50000000;
        
        oli11.TeliaSE_MC_Customer_Requested_Price__c = 0;
        oli11.TeliaSE_Approved__c = null;
        insert oli11;
        
        myqut1.Status = 'Sent For Approval';
        myqut1.TeliaSE_Comments__c = 'Approval request for Pre-Mature Renegotiation';
        myqut1.TeliaSWE_Primary_Quote__c = true;
        test.stopTest();
        
        try{
            update myqut1;
            
            myqut1.Status = 'Approved';
            myqut1.TeliaSE_Comments__c = 'TeliaSE_Comments__c';
            
            
            update myqut1;
            ProcessInstance[] instances = [select Id,TargetObjectId,CreatedById
                                           from ProcessInstance where TargetObjectId =: myqut.Id  order by LastmodifiedDate DESC LIMIT 1];
            
        }
        
        catch(exception e){
            
        }
        
    }
    public static testmethod void Test_ApprovedPrice(){
        ByPassTrigger__c byPassQuote = new ByPassTrigger__c();
        byPassQuote.QuoteTrigger__c = true;
        byPassQuote.QuoteLineItemTrigger__c = true;
        byPassQuote.setupownerid = userinfo.getUserId();
        insert byPassQuote;
        Test.StartTest();
        Quote Q3 = [select name, Id,status,TeliaSE_Approval_Flag__c   FROM quote where name = 'Test Quote2'];
        q3.status = 'Sent For Approval';
        q3.Recordtypeid = SEUTility.getRecordTypeId('Offer');
        q3.TeliaSE_Approval_Flag__c = True;
        q3.Type_of_Address__c = 'MDU';
        
        Update Q3;
        Test.StopTest();
        
    }
    
    private static TeliaSERecordTypeSetting__mdt  returnTestingMetadataRecord() {
        return [SELECT Id, 
                MassCustomized__c, 
                CRMFiber__c, 
                QualifiedApiName, 
                Label, 
                NamespacePrefix, 
                Language, 
                MasterLabel, 
                DeveloperName 
                FROM TeliaSERecordTypeSetting__mdt
                WHERE  MasterLabel in ('Quote')];
    }
    
    public static testmethod void Test_setFlagField()
    {   
        ByPassTrigger__c byPassQuote = new ByPassTrigger__c();
        byPassQuote.QuoteTrigger__c = true;
        byPassQuote.QuoteLineItemTrigger__c = true;
        byPassQuote.setupownerid = userinfo.getUserId();
        insert byPassQuote;
        Test.StartTest();
        Opportunity opp4 = [Select TeliaSE_SharingSetting_Flag__c, id from Opportunity where name = 'opp1' ];
        
        Quote quote = new Quote();
        quote.Name='Test Quote Flag';
        quote.opportunityId = opp4.id;
        quote.Recordtypeid=SEUTility.getRecordTypeId('Contract');
        quote.Type_of_Address__c = 'MDU';
        insert quote;
        
        Quote Q4 = [Select name,id,TeliaSE_Record_Type_Name__c,RecordType.DeveloperName, opportunityId  FROM Quote where name = 'Test Quote Flag'];
        
        opp4.TeliaSE_SharingSetting_Flag__c = false;
        update opp4;
        Test.StopTest();
    }
    
    
    public static testmethod void Test_FiberUpdateApprovedPrice(){ 
        ByPassTrigger__c byPassQuote = new ByPassTrigger__c();
        byPassQuote.QuoteTrigger__c = true;
        byPassQuote.QuoteLineItemTrigger__c = true;
        byPassQuote.setupownerid = userinfo.getUserId();
        insert byPassQuote;
        //List<Quote> QtList,Map<Id,Quote> oldMap,Map<Id,Quote> newMap
        TeliaSERecordTypeSetting = returnTestingMetadataRecord();
        
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        Product2 prod = Test_DataFactory.createProducts(1)[0];
        prod.Parent_Family__c = 'ICT';
        //prod.ProductCode = 'Fiber Sales (LÃ¤genhet)';
        insert prod;
        Opportunity opp53 = [Select TeliaSE_SharingSetting_Flag__c, id from Opportunity where name = 'opp1' ];
        
        Quote qut = new Quote();
        qut.Name='Test Quote';
        qut.status = 'Sent For Approval';
        qut.Recordtypeid   = SEUTility.getRecordTypeId('Individual_Quote');
        qut.opportunityId = opp53.id;
        qut.Pricebook2ID = stdPriceBookRecId;
        qut.TeliaSE_Approval_Flag__c = False;
        qut.TeliaSE_Fiber_EBIT_Percentage__c = 26;
        qut.Type_of_Address__c = 'MDU';
        //qut.TeliaSE_fiber_Rabatt__c = 123;
        //insert qut;
        
        Quote NewQuote = qut;
        NewQuote.status = 'Price Approved';
        insert NewQuote;
        
        Test.StartTest();
        Quote Q2 = [select name, Id,status,TeliaSE_Approval_Flag__c   FROM quote where name = 'Test Quote' limit 1];
        q2.status = 'Sent For Approval';
        q2.TeliaSE_Approval_Flag__c = True;
        q2.Type_of_Address__c = 'MDU';
        
        Update Q2;
        
        List<Quote> QtList = new  List<Quote>();
        QtList.add(NewQuote);
        QtList.add(Q2);
        
        Map<Id,Quote> oldMap = new  Map<Id,Quote>();
        oldMap.put(NewQuote.Id, qut);
        oldMap.put(Q2.Id, Q2);
        //oldMap.put(qut.Id, qut);
        
        Map<Id,Quote> newMap = new Map<Id,Quote>();
        newMap.put(NewQuote.Id, NewQuote);
        newMap.put(Q2.Id, Q2);
        Telia_SEQuoteHandler.FiberUpdateApprovedPrice(QtList, oldMap, newMap);
        Test.StopTest();
    }
    
    public static testmethod void Test_MCUpdateApprovedPrice(){ 
        //TeliaSERecordTypeSetting = returnTestingMetadataRecord();
        ByPassTrigger__c byPassQuote = new ByPassTrigger__c();
        byPassQuote.QuoteTrigger__c = true;
        byPassQuote.QuoteLineItemTrigger__c = true;
        byPassQuote.setupownerid = userinfo.getUserId();
        insert byPassQuote;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        Product2 prod = Test_DataFactory.createProducts(1)[0];
        prod.Parent_Family__c = 'ICT';
        insert prod;
        Opportunity opp53 = [Select TeliaSE_SharingSetting_Flag__c, id from Opportunity where name = 'opp1' ];
        
        Quote qut = new Quote();
        qut.Name='Test Quote';
        qut.status = 'Sent For Approval';
        qut.Recordtypeid = SEUTility.getRecordTypeId('Offer');
        qut.opportunityId = opp53.id;
        qut.Pricebook2ID = stdPriceBookRecId;
        qut.TeliaSE_Approval_Flag__c = False;
        qut.Type_of_Address__c = 'MDU';
        
        Quote NewQuote = qut;
        //NewQuote.Recordtypeid = SEUTility.getRecordTypeId('Offer');
        NewQuote.status = 'Price Approved';
        NewQuote.Type_of_Address__c = 'MDU';
        insert NewQuote;
        
        Test.StartTest();
        Quote Q2 = [select name, Id,status,TeliaSE_Approval_Flag__c FROM quote where name = 'Test Quote' limit 1];
        q2.status = 'Sent For Approval';
        q2.Recordtypeid = SEUTility.getRecordTypeId('Offer');
        q2.TeliaSE_Approval_Flag__c = True;
        q2.Type_of_Address__c = 'MDU';
        Update Q2;
        
        Test.StopTest();
    }
    
    public static testmethod void testTypeOfAddress() {
        ByPassTrigger__c byPassQuote = new ByPassTrigger__c();
        byPassQuote.QuoteTrigger__c = true;
        byPassQuote.QuoteLineItemTrigger__c = true;
        byPassQuote.setupownerid = userinfo.getUserId();
        insert byPassQuote;
        Test.startTest();
        Opportunity opp = new Opportunity();
        opp.Name = 'opp69';
        opp.CloseDate = System.today();
        opp.StageName = 'Needs Analysis';
        opp.Pricebook2Id = Test.getStandardPricebookId();
        opp.TeliaSE_SharingSetting_Flag__c = false;
        opp.RecordTypeId = '0121p000000wsYcAAI';
        insert opp;
        Quote quote = new Quote();
        quote.Name = 'Test Type Of Address';
        quote.opportunityId = opp.id;
        quote.Recordtypeid = SEUTility.getRecordTypeId('Contract');
        insert quote;
        Test.StopTest();
        
        system.assertEquals(opp.Type_of_Address__c, quote.Type_of_Address__c, 'Quote\'s Type Of Address doesn\'t match Opportunity');
    }
    public static testmethod void testDataFlowToOppoAndContract() {
        ByPassTrigger__c byPassQuote = new ByPassTrigger__c();
        byPassQuote.QuoteTrigger__c = true;
        byPassQuote.QuoteLineItemTrigger__c = true;
        byPassQuote.setupownerid = userinfo.getUserId();
        insert byPassQuote;
        Test.startTest();
        System.runAs(Test_DataFactory.getByPassUser()) {
            User salesRep;
            salesRep = Test_DataFactory.createFiberUser();
            salesRep.Bypass_VR__c = true;
            insert salesRep;
            Account acc;
            acc = Test_DataFactory.createOneAccount();
            acc.OwnerId = salesRep.Id;
            insert acc;
            Opportunity oppDataFlow = new Opportunity();
            oppDataFlow.Name = 'opp69';
            oppDataFlow.CloseDate = System.today();
            oppDataFlow.StageName = 'Needs Analysis';
            oppDataFlow.Pricebook2Id = Test.getStandardPricebookId();
            oppDataFlow.TeliaSE_SharingSetting_Flag__c = false;
            oppDataFlow.RecordTypeId = '0121p000000wsYcAAI';
            
            insert oppDataFlow;
            Quote quote = new Quote();
            quote.Name = 'Test data flow';
            quote.opportunityId = oppDataFlow.id;
            quote.Type_of_Address__c = 'MDU';
            quote.Recordtypeid = SEUTility.getRecordTypeId('Contract');
            insert quote;
            Contract conObj = new Contract();
            conObj.recordtypeId = '0121p000000wsYb';
            conObj.vlocity_cmt__QuoteId__c = quote.id;
            conobj.vlocity_cmt__OpportunityId__c = oppDataFlow.Id;
            conObj.StartDate = system.today();
            conObj.enddate = system.today() + 50;
            conObj.TeliaSE_Fiber_Installation_Date__c = system.today() + 5;
            conObj.status = 'Draft';
            conObj.accountId = acc.Id;
            conObj.Type_of_Address__c = 'MDU';
            conObj.Region__c = 'MDU Väst';
            
            insert conObj;
            quote.TeliaSE_Fiber_Number_of_Households__c = 2;
            quote.Number_of_other_Ports__c = 2;
            quote.TeliaSE_Fiber_Number_of_Ports__c = 2;
            quote.TeliaSE_Fiber_Number_of_Premises__c = 2;
            quote.Type_of_Address__c = 'MDU';
            quote.TeliaSE_Fiber_Number_of_Facilities__c = 2;
            quote.Wished_delivery_date_not_guaranteed__c = Date.Today();
            update quote;
            Test.StopTest();
        }
        Contract updatedContract = [SELECT Number_of_Households__c, Number_of_other_Ports__c,Number_of_Ports__c, Number_of_Premises__c,Wished_delivery_date_not_guaranteed__c,Number_of_Facilities__c FROM Contract ];
        Opportunity updatedOpportunity = [SELECT Number_of_Households__c, Number_of_other_Ports__c,Number_of_Ports__c, Number_of_Premises__c,Wished_delivery_date_not_guaranteed__c,Number_of_Facilities__c FROM Opportunity WHERE name = 'opp69'];
        
        
        /*
System.assertEquals(2, updatedContract.Number_of_Households__c, 'Contract wasn\'t updated number of households');
System.assertEquals(2, updatedContract.Number_of_other_Ports__c, 'Contract wasn\'t updated number of other ports');
System.assertEquals(2, updatedContract.Number_of_Ports__c, 'Contract wasn\'t updated number of ports');
System.assertEquals(2, updatedContract.Number_of_Premises__c, 'Contract wasn\'t updated number of premises');

System.assertEquals(2, updatedContract.Number_of_Facilities__c, 'Contract wasn\'t updated number of facilities');
System.assertEquals(Date.Today(), updatedContract.Wished_delivery_date_not_guaranteed__c, 'Contract wasn\'t updated wished delivery date not guaranteed');


System.assertEquals(2, updatedOpportunity.Number_of_Households__c, 'Opportunity wasn\'t updated number of households');
System.assertEquals(2, updatedOpportunity.Number_of_other_Ports__c, 'Opportunity wasn\'t updated number of other ports');
System.assertEquals(2, updatedOpportunity.Number_of_Ports__c, 'Opportunity wasn\'t updated number of ports');
System.assertEquals(2, updatedOpportunity.Number_of_Premises__c, 'Opportunity wasn\'t updated number of premises');


System.assertEquals(2, updatedOpportunity.Number_of_Facilities__c, 'Opportunity wasn\'t updated number of facilities');
System.assertEquals(Date.Today(), updatedOpportunity.Wished_delivery_date_not_guaranteed__c, 'Opportunity wasn\'t updated wished delivery date not guaranteed');
*/
    }
    public static testmethod void Test_errorLogging(){ 
        ByPassTrigger__c byPassQuote = new ByPassTrigger__c();
        byPassQuote.QuoteTrigger__c = true;
        byPassQuote.QuoteLineItemTrigger__c = true;
        byPassQuote.setupownerid = userinfo.getUserId();
        insert byPassQuote;
        Test.startTest();
        MyException ex=new MyException();
        Telia_SEQuoteHandler.errorHandling(ex,'Exception', 'ContractTriggerHandler', 'Contract');
        Test.stopTest();
    }
    public static testmethod void Test_SetBlaKalkylFieldVaues(){ 
        ByPassTrigger__c byPassQuote = new ByPassTrigger__c();
        byPassQuote.QuoteTrigger__c = true;
        byPassQuote.QuoteLineItemTrigger__c = true;
        byPassQuote.setupownerid = userinfo.getUserId();
        insert byPassQuote;
        Test.startTest();
        Map<Id,Quote> newMapValues=new Map<Id,Quote>();        
        Quote Q2 = [select name,BlaKalkyl_Description__c, Id,status,TeliaSE_Approval_Flag__c FROM quote where name = 'Test Quote' limit 1];
        newMapValues.put(Q2.Id,Q2);
        Telia_SEQuoteHandler.SetBlaKalkylFieldVaues(newMapValues);
        Test.stopTest();
    }
    public static testmethod void Test_UpdateApprovePrice(){
        ByPassTrigger__c byPassQuote = new ByPassTrigger__c();
        byPassQuote.QuoteTrigger__c = true;
        byPassQuote.QuoteLineItemTrigger__c = true;
        byPassQuote.setupownerid = userinfo.getUserId();
        insert byPassQuote;
        SObject sObj = [SELECT Id, SobjectType, DeveloperName FROM RecordType WHERE IsActive = TRUE and SobjectType = 'vlocity_cmt__ObjectClass__c' and DeveloperName = 'ObjectType' LIMIT 1];   
        
        vlocity_cmt__ObjectClass__c NonCO = new vlocity_cmt__ObjectClass__c(Name = 'Mobile Offer Specification', vlocity_cmt__ObjectApiName__c = 'Product2', RecordTypeId = sObj.Id);
        vlocity_cmt__ObjectClass__c NonCO1 = new vlocity_cmt__ObjectClass__c(Name = 'WIFI/LAN Offering Spec', vlocity_cmt__ObjectApiName__c = 'Product2', RecordTypeId = sObj.Id);
        List<vlocity_cmt__ObjectClass__c> obclss=new List<vlocity_cmt__ObjectClass__c>();
        obclss.add(NonCO);
        obclss.add(NonCO1);
        
        insert obclss;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        Product2 prod = Test_DataFactory.createProducts(1)[0];
        prod.Parent_Family__c = 'ICT';
        insert prod;
        prod.ProductCode='MOB_CALL_TRAVEL';
        //prod.MC_Sales_FrameworkPricing__c=true;
        prod.vlocity_cmt__ObjectTypeId__c=([select id,name from vlocity_cmt__ObjectClass__c where name='Mobile Offer Specification'][0]).id;
        update prod;
        
        Product2 prod1 = Test_DataFactory.createProducts(1)[0];
        prod1.Parent_Family__c = 'ICT';
        insert prod1;
        prod1.ProductCode='MOB_CALL_NONTRAVEL';
        //prod1.MC_Sales_FrameworkPricing__c=true;
        prod1.vlocity_cmt__ObjectTypeId__c=([select id,name from vlocity_cmt__ObjectClass__c where name='WIFI/LAN Offering Spec'][0]).id;
        update prod1;
        Opportunity opp53 = [Select TeliaSE_SharingSetting_Flag__c, id from Opportunity where name = 'opp1' ];
        List<PricebookEntry> priceList=new List<PricebookEntry>();
        PricebookEntry objpricebookentry =new PricebookEntry();
        objpricebookentry.Product2ID = prod.id;
        objpricebookentry.Pricebook2ID = stdPriceBookRecId;
        objpricebookentry.UnitPrice=23.50;
        objpricebookentry.UseStandardPrice=false;
        objpricebookentry.isActive=true;//Add this line
        insert objpricebookentry;
        Test.startTest();
        //TeliaSERecordTypeSetting = returnTestingMetadataRecord();
        
        RecordType rt = [Select id,name, DeveloperName from RecordType where name='Contract Quote'];
        
        Quote NewQuote = new Quote();
        NewQuote.Name='Test Quote ABhi';
        NewQuote.status = 'Sent For Approval';
        NewQuote.Recordtypeid = rt.id;
        NewQuote.opportunityId = opp53.id;
        NewQuote.Pricebook2ID = stdPriceBookRecId;
        //qut.TeliaSE_Approval_Flag__c = False;
        NewQuote.Type_of_Address__c = 'MDU';
        NewQuote.Recordtypeid=rt.id;
        NewQuote.TeliaSE_Approval_Flag__c=true;
        //NewQuote.TeliaSE_Record_Type_Name__c='Contract Quote';
        //Quote NewQuote = qut;
        //NewQuote.Recordtypeid = SEUTility.getRecordTypeId('Contract Quote');
        NewQuote.status = 'Approved';
        NewQuote.Type_of_Address__c = 'MDU';
        insert NewQuote;
        List<Quote> newquotelist=new List<Quote>();
        newquotelist=   [select id,TeliaSE_Record_Type_Name__c,TeliaSE_Approval_Flag__c from quote where name='Test Quote ABhi'] ;
        
        //newquotelist.add(NewQuote);       
        
        //Quote qt=new Quote();
        Quote qt=([select id from quote where name='Test Quote ABhi'][0]);
        qt.TeliaSE_Approval_Flag__c=false;
        update qt;
        Map<Id,Quote> oldMapList=new Map<Id,Quote>();
        oldMapList.put(qt.id,qt);
        
        QuoteLineItem qlis=new QuoteLineItem();
        qlis.PricebookEntryId = objpricebookentry.Id;           
        qlis.UnitPrice = 200;
        qlis.Quantity = 4;
        //qlis.Product2Id = prod.id;
        qlis.TeliaSE_Nullify_Check__c=true;
        qlis.Quantity = 4;
        qlis.Product2Id = ([select id,productcode,vlocity_cmt__ObjectTypeId__c from product2 where productcode='MOB_CALL_TRAVEL'][0]).id;
        qlis.vlocity_cmt__Product2Id__c=([select id,productcode,vlocity_cmt__ObjectTypeId__c from product2 where productcode='MOB_CALL_TRAVEL'][0]).id;
        qlis.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
        qlis.TeliaSE_MC_Customer_Requested_Percentage__c = 5;
        qlis.TeliaSE_MC_Customer_Requested_Price__c = 150;
        qlis.TeliaSE_Approved__c = null;
        qlis.Fiber_Approved_Price__c = null;
        qlis.vlocity_cmt__OneTimeCharge__c=23;
        qlis.vlocity_cmt__ParentItemId__c=null;
        //qlis.MC_Sales_FrameworkPriceEnabled__c=true;
        qlis.quoteid=([select id from quote where name='Test Quote ABhi'][0]).id;
        // insert qlis;
        
        QuoteLineItem qlis1=new QuoteLineItem();
        qlis1.PricebookEntryId = objpricebookentry.Id;           
        qlis1.UnitPrice = 200;
        qlis1.Quantity = 4;
        //qlis.Product2Id = prod.id;
        qlis1.TeliaSE_Nullify_Check__c=false;
        qlis1.Quantity = 4;
        qlis1.Product2Id = ([select id,productcode,vlocity_cmt__ObjectTypeId__c from product2 where productcode='MOB_CALL_NONTRAVEL'][0]).id;
        qlis1.vlocity_cmt__Product2Id__c=([select id,productcode,vlocity_cmt__ObjectTypeId__c from product2 where productcode='MOB_CALL_NONTRAVEL'][0]).id;
        qlis1.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
        qlis1.TeliaSE_MC_Customer_Requested_Percentage__c = 5;
        qlis1.TeliaSE_MC_Customer_Requested_Price__c = 150;
        qlis1.TeliaSE_Approved__c = 4;
        qlis1.TeliaSE_Approved_Price__c = 160;
        //qlis1.vlocity_cmt__OneTimeCharge__c=23;
        qlis1.vlocity_cmt__ParentItemId__c=null;
        qlis1.MC_OT_Approved_Price__c=10;
        qlis1.vlocity_cmt__OneTimeCharge__c=9;
        //qlis.MC_Sales_FrameworkPriceEnabled__c=true;
        qlis1.quoteid=([select id from quote where name='Test Quote ABhi'][0]).id;
        //insert qlis1;
        
        QuoteLineItem qlis2=new QuoteLineItem();
        qlis2.PricebookEntryId = objpricebookentry.Id;           
        qlis2.UnitPrice = 200;
        qlis2.Quantity = 4;
        //qlis.Product2Id = prod.id;
        qlis2.TeliaSE_Nullify_Check__c=false;
        qlis2.Quantity = 4;
        qlis2.Product2Id = ([select id,productcode,vlocity_cmt__ObjectTypeId__c from product2 where productcode='MOB_CALL_NONTRAVEL'][0]).id;
        qlis2.vlocity_cmt__Product2Id__c=([select id,productcode,vlocity_cmt__ObjectTypeId__c from product2 where productcode='MOB_CALL_NONTRAVEL'][0]).id;
        qlis2.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
        qlis2.TeliaSE_MC_Customer_Requested_Percentage__c = 5;
        qlis2.TeliaSE_MC_Customer_Requested_Price__c = 150;
        qlis2.TeliaSE_Approved__c = 4;
        qlis2.TeliaSE_Approved_Price__c = null;
        //qlis1.vlocity_cmt__OneTimeCharge__c=23;
        qlis2.vlocity_cmt__ParentItemId__c=null;
        qlis2.MC_OT_Approved_Price__c=10;
        qlis2.vlocity_cmt__OneTimeCharge__c=9;
        //qlis.MC_Sales_FrameworkPriceEnabled__c=true;
        qlis2.quoteid=([select id from quote where name='Test Quote ABhi'][0]).id;
        //insert qlis2;
        List<QuoteLineItem> qisList=new List<QuoteLineItem>();
        qisList.add(qlis2);
        qisList.add(qlis1);
        qisList.add(qlis);
        insert qisList;
        Telia_SEQuoteHandler.UpdateApprovePrice(newquotelist,oldMapList,oldMapList);
        Test.stopTest();
    }
    
    
    public static testmethod void Test_checkPrimaryQuotes2(){ 
        ByPassTrigger__c byPassQuote = new ByPassTrigger__c();
        byPassQuote.QuoteTrigger__c = true;
        byPassQuote.QuoteLineItemTrigger__c = true;
        byPassQuote.setupownerid = userinfo.getUserId();
        insert byPassQuote;
        Test.startTest();
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        
        Product2 prod = Test_DataFactory.createProducts(1)[0];
        prod.Parent_Family__c = 'ICT';
        insert prod;
        pricebookId = stdPriceBookRecId ;        
        Opportunity opp1 = [Select TeliaSE_SharingSetting_Flag__c, id from Opportunity where name = 'opp1' ];     
        
        
        PricebookEntry objpricebookentry =new PricebookEntry();
        objpricebookentry.Product2ID = prod.id;
        objpricebookentry.Pricebook2ID = stdPriceBookRecId;
        objpricebookentry.UnitPrice=23.50;
        objpricebookentry.UseStandardPrice=false;
        objpricebookentry.isActive=true;//Add this line
        insert objpricebookentry;
        
        
        TeliaSERecordTypeSetting = returnTestingMetadataRecord();
        
        List<Quote> quoteList1=new List<Quote>();
        Quote qut2 = new Quote();
        qut2.Name='Test Quote2 Test';
        qut2.status = 'Draft';
        qut2.opportunityId = opp1.id;
        qut2.Pricebook2ID = stdPriceBookRecId;
        qut2.TeliaSE_Approval_Flag__c = False;  
        qut2.TeliaSWE_Primary_Quote__c=true;
        Quote qut3 = new Quote();
        qut3.Name='Test Quote2 Test2';
        qut3.status = 'Draft';
        qut3.opportunityId = opp1.id;
        qut3.Pricebook2ID = stdPriceBookRecId;
        qut3.TeliaSE_Approval_Flag__c = False;  
        qut3.TeliaSWE_Primary_Quote__c=true;
        //insert qut2;
        quoteList1.add(qut2);
        quoteList1.add(qut3);
        insert quoteList1;
        Map<Id,Quote> mapQuote=new Map<Id,Quote>();
        Quote q=new Quote();
        q=([select id,TeliaSWE_Primary_Quote__c,OpportunityId from quote where Name='Test Quote2 Test'])[0];
        mapQuote.put(q.id,q);
        Telia_SEQuoteHandler.checkPrimaryQuotes(mapQuote);
        Test.stopTest();
    }
    public static testmethod void Test_UpdateApprovalFlag(){
        ByPassTrigger__c byPassQuote = new ByPassTrigger__c();
        byPassQuote.QuoteTrigger__c = true;
        byPassQuote.QuoteLineItemTrigger__c = true;
        byPassQuote.setupownerid = userinfo.getUserId();
        insert byPassQuote;
        Test.startTest();
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        
        Opportunity opp53 = [Select TeliaSE_SharingSetting_Flag__c, id from Opportunity where name = 'opp1' ];
        
        Quote NewQuote = new Quote();
        NewQuote.Name='Test Quote Approval';
        NewQuote.status = 'Sent For Approval'; 
        //NewQuote.TeliaSE_Approval_Count__c=1;
        NewQuote.TeliaSE_Approval_Flag__c=true;
        NewQuote.OpportunityId=opp53.id;
        NewQuote.Pricebook2ID = stdPriceBookRecId;
        insert NewQuote;
        List<Quote> QtList=new List<Quote>();
        Map<Id,Quote> oldMap=new Map<Id,Quote>();
        
        //Quote qt=([select id from quote where name='Test Quote Approval'][0]);        
        
        Product2 prod = Test_DataFactory.createProducts(1)[0];
        prod.Parent_Family__c = 'ICT';
        insert prod;
        List<PricebookEntry> priceList=new List<PricebookEntry>();
        PricebookEntry objpricebookentry =new PricebookEntry();
        objpricebookentry.Product2ID = prod.id;
        objpricebookentry.Pricebook2ID = stdPriceBookRecId;
        objpricebookentry.UnitPrice=23.50;
        objpricebookentry.UseStandardPrice=false;
        objpricebookentry.isActive=true;//Add this line
        insert objpricebookentry;
        
        QuoteLineItem qlis=new QuoteLineItem();
        qlis.PricebookEntryId = objpricebookentry.Id;           
        qlis.UnitPrice = 200;
        qlis.Quantity = 4;
        //qlis.Product2Id = prod.id;
        qlis.TeliaSE_Nullify_Check__c=true;
        qlis.Quantity = 4;
        qlis.Product2Id = prod.id;
        qlis.vlocity_cmt__Product2Id__c=prod.id;
        qlis.TeliaSE_Flag__c= '/resource/1555137213000/TeliaSE_Sad_Face';
        qlis.TeliaSE_MC_Customer_Requested_Percentage__c = 5;
        qlis.TeliaSE_MC_Customer_Requested_Price__c = 150;
        qlis.TeliaSE_Approved__c = null;
        qlis.Fiber_Approved_Price__c = null;
        qlis.vlocity_cmt__OneTimeCharge__c=23;
        qlis.vlocity_cmt__ParentItemId__c=null;
        //qlis.MC_Sales_FrameworkPriceEnabled__c=true;
        qlis.quoteid=NewQuote.id;
        insert qlis;
        QtList=[select id,TeliaSE_Approval_Count__c,TeliaSE_Approval_Flag__c from quote where name='Test Quote Approval'];       
        oldMap.put(QtList[0].id,QtList[0]);
        Telia_SEQuoteHandler.UpdateApprovalFlag(QtList,oldMap,oldMap);
        Test.stopTest();
    }   
    
    
    
    public static testmethod void Test_checkMandate(){
        ByPassTrigger__c byPassQuote = new ByPassTrigger__c();
        byPassQuote.QuoteTrigger__c = true;
        byPassQuote.QuoteLineItemTrigger__c = true;
        byPassQuote.setupownerid = userinfo.getUserId();
        insert byPassQuote;
        Test.startTest();
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        
        Opportunity opp53 = [Select TeliaSE_SharingSetting_Flag__c, id from Opportunity where name = 'opp1' ];
        
        Quote NewQuote = new Quote();
        NewQuote.Name='Test Quote Approval3';
        NewQuote.status = 'Sent For Approval'; 
        //NewQuote.TeliaSE_Approval_Count__c=1;
        NewQuote.TeliaSE_Approval_Flag__c=true;
        NewQuote.OpportunityId=opp53.id;
        NewQuote.Pricebook2ID = stdPriceBookRecId;
        NewQuote.MC_CommercialTerms__c='';
        NewQuote.MC_Payment_Term__c=30;
        NewQuote.TeliaSE_Invoice_Fee__c='Ja';
        NewQuote.MC_Commercial_Benchmark__c='Nej';
        NewQuote.MC_Indexation_Clause__c = 'Ja';
        insert NewQuote;
        List<Quote> QtList=new List<Quote>();
        Map<Id,Quote> oldMap=new Map<Id,Quote>();
        oldMap.put(NewQuote.id,NewQuote);
        //Quote qt=([select id from quote where name='Test Quote Approval'][0]);        
        
        Product2 prod = Test_DataFactory.createProducts(1)[0];
        prod.Parent_Family__c = 'ICT';
        insert prod;
        List<PricebookEntry> priceList=new List<PricebookEntry>();
        PricebookEntry objpricebookentry =new PricebookEntry();
        objpricebookentry.Product2ID = prod.id;
        objpricebookentry.Pricebook2ID = stdPriceBookRecId;
        objpricebookentry.UnitPrice=23.50;
        objpricebookentry.UseStandardPrice=false;
        objpricebookentry.isActive=true;//Add this line
        insert objpricebookentry;
        
        QuoteLineItem qlis=new QuoteLineItem();
        qlis.PricebookEntryId = objpricebookentry.Id;           
        qlis.UnitPrice = 200;
        qlis.Quantity = 4;
        //qlis.Product2Id = prod.id;
        qlis.TeliaSE_Nullify_Check__c=true;
        qlis.Quantity = 4;
        qlis.Product2Id = prod.id;
        qlis.vlocity_cmt__Product2Id__c=prod.id;
        qlis.TeliaSE_Flag__c= '/resource/1555137213000/TeliaSE_Sad_Face';
        qlis.TeliaSE_MC_Customer_Requested_Percentage__c = 5;
        qlis.TeliaSE_MC_Customer_Requested_Price__c = 150;
        qlis.TeliaSE_Approved__c = null;
        qlis.Fiber_Approved_Price__c = null;
        qlis.vlocity_cmt__OneTimeCharge__c=23;
        qlis.vlocity_cmt__ParentItemId__c=null;
        //qlis.MC_Sales_FrameworkPriceEnabled__c=true;
        qlis.quoteid=NewQuote.id;
        insert qlis;
        QtList=[select id,TeliaSE_Approval_Count__c,MC_Indexation_Clause__c,TeliaSE_Approval_Flag__c,Status,MC_CommercialTerms__c,MC_Payment_Term__c,TeliaSE_Invoice_Fee__c,MC_Commercial_Benchmark__c from quote where name='Test Quote Approval3']; 
        //QtList[0].Status='Sent for Approval';
        //update (QtList[0]);
        //oldMap.put(QtList[0].id,QtList[0]);
        Map<Id,Quote> newMap=new Map<Id,Quote>();
        QtList[0].Status='Approved';
        QtList[0].TeliaSE_Comments__c='Approval request for Pre-Mature Renegotiation';
        update (QtList[0]);
        newMap.put(QtList[0].id,QtList[0]);
        Telia_SEQuoteHandler.checkMandate(QtList,oldMap,newMap);
        QtList[0].TeliaSE_Comments__c=null;
        update (QtList[0]);
        Quote qts=new Quote();
        qts=newMap.get(QtList[0].id);
        qts.status='Approved';
        update qts;
        newMap.put((QtList[0].id),qts);
        Telia_SEQuoteHandler.checkMandate(QtList,oldMap,newMap);
        
        Test.stopTest();
    }
    
}