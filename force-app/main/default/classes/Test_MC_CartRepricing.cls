@isTest 
public class Test_MC_CartRepricing {
    private static String namespace = 'vlocity_cmt__';    
    // Intitialized in Setup, used throughout
    public static vlocity_cmt__CalculationMatrixVersion__c version;
    public static vlocity_cmt__CalculationMatrix__c parent;
    public static List<vlocity_cmt__CalculationMatrixRow__c> lineItems;
    private static Id orderId;
    private static boolean flag;  //used to upload matrix row data for test1 or test2
    private static Id quoteId, quoteId2; // added by Dipanwita
    static TeliaSERecordTypeSetting__mdt TeliaSERecordTypeSetting;
    @testSetup static void setup(){      
        Id stdPriceBookRecId = Test.getStandardPricebookId();  
        Test_DataFactory.setUpOrg();        
        TeliaSERecordTypeSetting = returnTestingMetadataRecord();
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
        
        System.runAs(Test_DataFactory.getByPassUser()) {   
            
            vlocity_cmt__CpqConfigurationSetup__c cpqSetup1 = new vlocity_cmt__CpqConfigurationSetup__c();
            cpqSetup1.vlocity_cmt__SetupValue__c = 'true';
            cpqSetup1.name = 'PricingPlanHelperLogging';
            insert cpqSetup1;
            List<MC_RangeAttributePricingMatrixSettings__c> matrixsetting = new List<MC_RangeAttributePricingMatrixSettings__c>();
            MC_RangeAttributePricingMatrixSettings__c mcRange = new MC_RangeAttributePricingMatrixSettings__c();
            mcRange.Active__c = true;
            mcRange.Name = 'Large_Office365';
            mcRange.Customer_Segment__c = 'Enterprise Large';
            mcRange.Matrix_Name__c = 'PriceMatrix_Office365';
            mcRange.ProcedureName__c = 'Small_Office365_RangeAttributePricingProcedure';
            mcRange.Product_Family_Code__c = 'MOB_MULTI_TOTAL';    
            matrixsetting.add(mcRange);
            
            MC_RangeAttributePricingMatrixSettings__c mcRange1 = new MC_RangeAttributePricingMatrixSettings__c();
            mcRange1.Active__c = true;
            mcRange1.Name = 'ForcedBA_Mobile_Total_v1';
            mcRange1.Customer_Segment__c = 'Forced BA';
            mcRange1.Matrix_Name__c = 'PriceMatrix_Mobile_Total_1';
            mcRange1.ProcedureName__c = 'Small_Mobile_Total_1_RangeAttributePricingProcedure';
            mcRange1.Product_Family_Code__c = 'MOB_MULTI_TOTAL';    
            matrixsetting.add(mcRange1);
            insert matrixsetting;
            
            List<vlocity_cmt__CalculationProcedure__c> procList = new List<vlocity_cmt__CalculationProcedure__c>();
            
            vlocity_cmt__CalculationProcedure__c calculationProc1 = new vlocity_cmt__CalculationProcedure__c();
            calculationProc1.Name = 'Small_Office365_RangeAttributePricingProcedure';
            procList.add(calculationProc1);
            
            vlocity_cmt__CalculationProcedure__c calculationProc = new vlocity_cmt__CalculationProcedure__c();
            calculationProc.Name = 'Small_Mobile_Total_1_RangeAttributePricingProcedure';
            procList.add(calculationProc);
            insert procList;
            
            List<vlocity_cmt__CalculationMatrix__c> matrixList = new List<vlocity_cmt__CalculationMatrix__c>();
            
            vlocity_cmt__CalculationMatrix__c matrixname1 = new vlocity_cmt__CalculationMatrix__c();
            matrixname1.Name = 'PriceMatrix_Office365';
            matrixList.add(matrixname1);
            
            vlocity_cmt__CalculationMatrix__c matrixname = new vlocity_cmt__CalculationMatrix__c();
            matrixname.Name = 'PriceMatrix_Mobile_Total_1';
            matrixList.add(matrixname);
            insert matrixList;
            
            List<vlocity_cmt__CalculationMatrixVersion__c> matrixversionList = new List<vlocity_cmt__CalculationMatrixVersion__c>();
            
            vlocity_cmt__CalculationMatrixVersion__c matrixVersion1 =new vlocity_cmt__CalculationMatrixVersion__c();
            matrixVersion1.vlocity_cmt__CalculationMatrixId__c=matrixname1.id;
            matrixVersion1.vlocity_cmt__Priority__c = 100;
            matrixVersion1.vlocity_cmt__VersionNumber__c =100;
            matrixVersion1.vlocity_cmt__StartDateTime__c = System.now().addDays(-1);
            matrixVersion1.vlocity_cmt__IsEnabled__c=true;
            matrixversionList.add(matrixVersion1);
            
            vlocity_cmt__CalculationMatrixVersion__c matrixVersion =new vlocity_cmt__CalculationMatrixVersion__c();
            matrixVersion.vlocity_cmt__CalculationMatrixId__c=matrixname.id;
            matrixVersion.vlocity_cmt__Priority__c = 100;
            matrixVersion.vlocity_cmt__VersionNumber__c =100;
            matrixVersion.vlocity_cmt__StartDateTime__c = System.now().addDays(-1);
            matrixVersion.vlocity_cmt__IsEnabled__c=true;
            matrixversionList.add(matrixVersion);
            insert matrixversionList;
            
            List<vlocity_cmt__CalculationMatrixRow__c> mRowList = new List<vlocity_cmt__CalculationMatrixRow__c>();
            vlocity_cmt__CalculationMatrixRow__c matrixRow1 = new vlocity_cmt__CalculationMatrixRow__c();
            matrixRow1.Name = 'matrixRow11';
            matrixRow1.vlocity_cmt__CalculationMatrixVersionId__c = matrixVersion1.id;
            matrixRow1.vlocity_cmt__EndDateTime__c = System.now().addDays(1);
            matrixRow1.vlocity_cmt__StartDateTime__c = system.now();
            matrixRow1.vlocity_cmt__InputData__c  = '{"Characteristic Name":"Subsidized;Parent;Commitment Period","Characteristic Value":"Yes;Total;12 Months","Quantity":"501-1500","Source Product Code":"MOB_MULTI_3_V2","Source Product Name":"Jobbmobil 3 GB"}';
            matrixRow1.vlocity_cmt__OutputDataLong__c = '{"Target Product Name" : "Jobbmobil 3 GB","PricePlanCode" : "NA","MC CM Mandate Discount" : 28.68,"MC SD Mandate Discount" : 13.58,"MC AM Mandate Discount" : 6.04,"MC SM Mandate Discount" : 13.58,"MC Discount Percentage" : 0.0,"NRC" : "0","MRC" : "265"}';
            mRowList.add(matrixRow1);
            
            vlocity_cmt__CalculationMatrixRow__c matrixRow = new vlocity_cmt__CalculationMatrixRow__c();
            matrixRow.Name = 'matrixRow1';
            matrixRow.vlocity_cmt__CalculationMatrixVersionId__c = matrixVersion.id;
            matrixRow.vlocity_cmt__EndDateTime__c = System.now().addDays(1);
            matrixRow.vlocity_cmt__StartDateTime__c = system.now();
            matrixRow.vlocity_cmt__InputData__c  = '{"Characteristic Name":"Subsidized;Parent;Commitment Period","Characteristic Value":"Yes;Total;12 Months","Quantity":"501-1500","Source Product Code":"MOB_MULTI_3_V2","Source Product Name":"Jobbmobil 3 GB"}';
            matrixRow.vlocity_cmt__OutputDataLong__c = '{"Target Product Name" : "Jobbmobil 3 GB","PricePlanCode" : "NA","MC CM Mandate Discount" : 28.68,"MC SD Mandate Discount" : 13.58,"MC AM Mandate Discount" : 6.04,"MC SM Mandate Discount" : 13.58,"MC Discount Percentage" : 0.0,"NRC" : "0","MRC" : "265"}';
            mRowList.add(matrixRow);
            insert mRowList;
            
            List<vlocity_cmt__CalculationMatrixVersion__c> cmvList = [Select Id,vlocity_cmt__CalculationMatrixId__r.Name,vlocity_cmt__IsEnabled__c,vlocity_cmt__EndDateTime__c,vlocity_cmt__CalculationMatrixId__c,vlocity_cmt__Priority__c,vlocity_cmt__StartDateTime__c,vlocity_cmt__VersionNumber__c,Name from vlocity_cmt__CalculationMatrixVersion__c];  
            
            System.debug('cmvList'+json.serialize([Select Id,vlocity_cmt__CalculationMatrixId__r.Name,vlocity_cmt__IsEnabled__c,vlocity_cmt__EndDateTime__c,vlocity_cmt__CalculationMatrixId__c,vlocity_cmt__Priority__c,vlocity_cmt__StartDateTime__c,vlocity_cmt__VersionNumber__c,Name from vlocity_cmt__CalculationMatrixVersion__c]));
            
            List<Product2> prodList = new List<product2>();
            Product2 prod = Test_DataFactory.createProducts(1)[0];
            prod.ProductCode = 'MOB_SURF_BAS_V2';
            prod.TeliaSE_Product_Service_Code__c = 'ServiceTest';
            prod.name = 'Jobbsurf bas';
            prod.TeliaSE_Price_Flag__c=true;
            prodList.add(prod); 
            Product2 prodoffice = new Product2 (Name='Office 365',TeliaSE_Price_Flag__c=true, ProductCode = 'C-OFFICE-365', vlocity_cmt__AttributeMetadata__c='{"totalSize":1,"messages":[],"records":[{"messages":[],"displaySequence":10,"Code__c":"ATT_CODE_TELIAMOBAGGR","Name":"Attributes","id":"a350Q0000008HmWQAU","productAttributes":{"totalSize":2,"messages":[],"records":[{"messages":[],"code":"ATT_RT_NoU","dataType":"number","inputType":"number","multiselect":false,"required":true,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a360Q00000028v5QAA","label":"Antal för basnivå","displaySequence":10,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"readonly":false,"disabled":false}],"userValues":null},{"messages":[],"code":"ATT_RT_CMTP","dataType":"text","inputType":"dropdown","multiselect":false,"required":true,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a360Q00000028v2QAA","label":"Avtalstid","displaySequence":20,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"id":"aba9e042-0545-92b0-b0d0-16cd00888e83","name":"aba9e042-0545-92b0-b0d0-16cd00888e83","label":"24 months","readonly":false,"disabled":false,"value":"24 months","defaultSelected":false,"displaySequence":2},{"id":"cbdeb314-b13b-d53d-72ec-8e4c3370b908","name":"cbdeb314-b13b-d53d-72ec-8e4c3370b908","label":"36 months","readonly":false,"disabled":false,"value":"36 months","defaultSelected":false,"displaySequence":3},{"id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","name":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","label":"12 months","readonly":false,"disabled":false,"value":"12 months","defaultSelected":false,"displaySequence":1}],"userValues":null}]}}]}');
            prodList.add(prodoffice); 
            Product2 prod1 = Test_DataFactory.createProducts(1)[0];
            prod1.name = 'jobbmobil Total';
            prod1.productCode = 'MOB_MULTI_TOTAL';
            prod1.TeliaSE_Price_Flag__c=true;
            prodList.add(prod1);            
            
            Product2 prod2 = Test_DataFactory.createProducts(1)[0];
            prod2.Name = 'RoamingAddOn';
            prod2.productCode = 'MOB_CALL_TRAVEL';
            prod2.TeliaSE_Price_Flag__c=true;
            prodList.add(prod2);
            //CO-BBPRO-1000MB
            Product2 prod3 = Test_DataFactory.createProducts(1)[0];
            prod3.Name = 'CO-BBPRO-1000MB';
            prod3.productCode = 'CO-BBPRO-1000MB';
            prod3.TeliaSE_Product_Type__c = 'percentage';
            prod3.TeliaSE_Price_Flag__c=true;
            prodList.add(prod3);
            //hardware product
            Product2 prodt = new Product2();
            prodt.name='Mobiltelefoner';
            prodt.ProductCode='MOB_HARDWARE_OFFER';
            prodt.TeliaSE_Price_Flag__c=true;
            prodList.add(prodt);
            insert prodList;
            
            Account acc=Test_DataFactory.createOneSMEAccount();
            acc.MC_Commercial_Setup__c = 'Forced BA';
            insert acc;
            
            Opportunity opp = new Opportunity();
            opp.Name='opp1';
            opp.AccountId=acc.Id;
            opp.CloseDate = System.today();
            opp.StageName='Needs Analysis';
            opp.Pricebook2Id=Test.getStandardPricebookId();
            insert opp;
            
            List<PricebookEntry> pbelist = new List<PricebookEntry>();
            PricebookEntry objpricebookentry =new PricebookEntry();
            objpricebookentry.Product2ID = prod.id;            
            objpricebookentry.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry.UnitPrice=23.50;
            objpricebookentry.UseStandardPrice=false;
            objpricebookentry.isActive=true;//Add this line
            pbeList.add(objpricebookentry);
            
            PricebookEntry objpricebookentry1 =new PricebookEntry();
            objpricebookentry1.Product2ID = prod1.id;
            objpricebookentry1.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry1.UnitPrice=23.50;
            objpricebookentry1.UseStandardPrice=false;
            objpricebookentry1.isActive=true;//Add this line
            pbeList.add(objpricebookentry1);
            
            PricebookEntry objpricebookentry2 =new PricebookEntry();
            objpricebookentry2.Product2ID = prodt.Id;
            objpricebookentry2.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry2.UnitPrice=23.50;
            objpricebookentry2.UseStandardPrice=false;
            objpricebookentry2.isActive=true;           
            pbeList.add(objpricebookentry2);
            
            PricebookEntry objpricebookentry3 =new PricebookEntry();
            objpricebookentry3.Product2ID = prod3.Id;
            objpricebookentry3.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry3.UnitPrice=23.50;
            objpricebookentry3.UseStandardPrice=false;
            objpricebookentry3.isActive=true;           
            pbeList.add(objpricebookentry3);
            
            insert pbeList;
            
            Id recId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Contract Quote').getRecordTypeId();
            Id hardwareRecordId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Hardware Quote').getRecordTypeId();
            Id offerRecordId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Offer Quote').getRecordTypeId();
            
            test.startTest();
            
            List<Quote> qutList = new List<Quote>();
            Quote qut = new Quote();
            qut.Name='Sample Quote';
            qut.status = 'Draft';
            qut.TeliaSE_Type__c='Renegotiation';
            qut.opportunityId = opp.id;
            qut.Pricebook2ID = stdPriceBookRecId;
            qut.TeliaSE_Approval_Flag__c = False; 
            qut.TeliaSE_MC_Sales_Flow_Identifier__c='Omforhandling';
            qut.RecordTypeId = recId;
            qutList.add(qut);
            
            Quote qut1 = new Quote();
            qut1.Name='Sample Hardware Quote';
            qut1.status = 'Draft';
            qut1.TeliaSE_Type__c='Renegotiation';
            qut1.opportunityId = opp.id;
            qut1.Pricebook2ID = stdPriceBookRecId;
            qut1.TeliaSE_Approval_Flag__c = False; 
            qut1.TeliaSE_MC_Sales_Flow_Identifier__c='Omforhandling';
            qut1.RecordTypeId = hardwareRecordId;
            qutList.add(qut1);
            
            Quote qut3 = new Quote();
            qut3.Name='Sample Offer Quote';
            qut3.status = 'Draft';
            qut3.opportunityId = opp.id;
            qut3.Pricebook2ID = stdPriceBookRecId;
            qut3.TeliaSE_Approval_Flag__c = False; 
            qut3.TeliaSE_MC_Sales_Flow_Identifier__c='Omforhandling';
            qut3.RecordTypeId = offerRecordId;
            qutList.add(qut3);
            
            insert qutList;
            qut3.vlocity_cmt__ParentQuoteId__c = qut.Id;
            update qut3;
            
            String jsonAttrib = '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t5E000007arHEQAY","attributeid__c":"a363E0000005VknQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_PARENT","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Parent","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a335E000000V0HWQA0","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t5E000007arHEQAY","attributeid__c":"a363E0000005VkqQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a335E000000V0HIQA0","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":"12 months","sequence":1,"id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","displayText":"12 months"},{"value":"24 months","sequence":2,"id":"aba9e042-0545-92b0-b0d0-16cd00888e83","displayText":"24 months"},{"value":"36 months","sequence":3,"id":"cbdeb314-b13b-d53d-72ec-8e4c3370b908","displayText":"36 months"}],"default":[],"selectedItem":{}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t5E000007arHEQAY","attributeid__c":"a363E0000005VktQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a335E000000UtQuQAK","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Single Value","value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Number","uiDisplayType":"Single Value","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t5E000007arHEQAY","attributeid__c":"a363E0000005VkuQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_SUB","attributeconfigurable__c":true,"attributedisplaysequence__c":"50","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Subsidized","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a335E000000V0HbQAK","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":"Yes","sequence":1,"id":"2b5df0d6-eb1a-e9fa-950f-d6ca7614ee1e","displayText":"Yes"},{"value":"No","sequence":2,"id":"67dda21b-85c6-ce74-2955-5094c85f021c","displayText":"No"}],"default":[],"selectedItem":{}},"$$AttributeDefinitionEnd$$":null}]}';
            String jsonAttrib1 = '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t5E000007arHEQAY","attributeid__c":"a363E0000005VknQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_PARENT","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Parent","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a335E000000V0HWQA0","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t5E000007arHEQAY","attributeid__c":"a363E0000005VkqQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a335E000000V0HIQA0","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":"12 months","sequence":1,"id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","displayText":"12 months"},{"value":"24 months","sequence":2,"id":"aba9e042-0545-92b0-b0d0-16cd00888e83","displayText":"24 months"},{"value":"36 months","sequence":3,"id":"cbdeb314-b13b-d53d-72ec-8e4c3370b908","displayText":"36 months"}],"default":[],"selectedItem":{}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t5E000007arHEQAY","attributeid__c":"a363E0000005VktQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a335E000000UtQuQAK","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Single Value","value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Number","uiDisplayType":"Single Value","value":null},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t5E000007arHEQAY","attributeid__c":"a363E0000005VkuQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_SUB","attributeconfigurable__c":true,"attributedisplaysequence__c":"50","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Subsidized","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a335E000000V0HbQAK","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":"Yes","sequence":1,"id":"2b5df0d6-eb1a-e9fa-950f-d6ca7614ee1e","displayText":"Yes"},{"value":"No","sequence":2,"id":"67dda21b-85c6-ce74-2955-5094c85f021c","displayText":"No"}],"default":[],"selectedItem":{}},"$$AttributeDefinitionEnd$$":null}]}';
            string jsonSelectedValues = '{"ATT_RT_CMTP":"36 months","ATT_RT_NoU":"600"}';
            
            QuoteLineItem oli1 = new QuoteLineItem();
            oli1.PricebookEntryId = objpricebookentry1.Id;
            oli1.TeliaSE_MC_Customer_Requested_Percentage__c=10;
            oli1.QuoteId = qut.id;
            oli1.UnitPrice = 200;
            oli1.Quantity = 4;
            oli1.vlocity_cmt__Product2Id__c = prod1.id;
            oli1.Product2Id = prod1.id;
            oli1.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli1.TeliaSE_Approved__c = 5;
            oli1.vlocity_cmt__RecurringCharge__c  = 200;
            oli1.TeliaSE_Ceiling_Price__c = 400;
            oli1.TeliaSE_Root_Product__c=prod1.id;
            oli1.vlocity_cmt__ProductHierarchyPath__c = prod1.id;
            oli1.TeliaSE_Base_Quantity__c = '123';
            oli1.vlocity_cmt__OneTimeCharge__c = 200;
            oli1.MC_OT_AM_Mandate_Percentage__c = 10;
            oli1.MC_OT_SM_Mandate_Percentage__c = 10;
            oli1.MC_OT_SD_Mandate_Percentage__c = 10;
            oli1.MC_OT_CM_Mandate_Percentage__c = 10;
            oli1.TeliaSE_AM_Mandate_Percentage__c = 10;
            oli1.TeliaSE_SM_Mandate_Percentage__c = 10;
            oli1.TeliaSE_SD_Mandate_Percentage__c = 10;
            oli1.TeliaSE_CM_Mandate_Percentage__c = 10;
            oli1.vlocity_cmt__JSONAttribute__c = jsonAttrib;
            oli1.TeliaSE_ParentClusterCode__c = 'large';
            oli1.vlocity_cmt__AttributeSelectedValues__c = jsonSelectedValues;
            oli1.RoamingResAddOns__c = '15 kr, 15 kr, 15 kr';
            oli1.RoamingTillAddOns__c = '69 kr, 49 kr, 15 kr';
            oli1.TeliaSE_Nullify_Check__c = false;
            oli1.TeliaSE_Approved_Price__c=100;
            insert oli1;
            
            oli1.vlocity_cmt__RootItemId__c = oli1.id;
            update oli1;
            
            List<QuoteLineItem> oli = new List<QuoteLineItem>();
            
            QuoteLineItem oli2 = new QuoteLineItem();
            oli2.PricebookEntryId = objpricebookentry.Id;
            oli2.TeliaSE_MC_Customer_Requested_Percentage__c=0;
            oli2.QuoteId = qut.id;
            oli2.UnitPrice = 200;
            oli2.Quantity = 4;
            oli2.vlocity_cmt__Product2Id__c = prod2.id;
            oli2.Product2Id = prod2.id;
            oli2.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli2.TeliaSE_Approved__c = null;
            oli2.vlocity_cmt__RecurringCharge__c  = 200;
            oli2.TeliaSE_Ceiling_Price__c = 400;
            oli2.vlocity_cmt__RootItemId__c = oli1.id;
            oli2.vlocity_cmt__ParentItemId__c = oli1.id;
            oli2.TeliaSE_Root_Product__c=prod1.id;
            oli2.vlocity_cmt__ProductHierarchyPath__c = prod1.id+'<'+prod2.id;
            oli2.TeliaSE_Base_Quantity__c = '123';
            oli2.vlocity_cmt__JSONAttribute__c = jsonAttrib1;
            oli2.vlocity_cmt__AttributeSelectedValues__c = jsonSelectedValues;
            oli2.RoamingResAddOns__c = '15 kr, 15 kr, 15 kr';
            oli2.RoamingTillAddOns__c = '69 kr, 49 kr, 15 kr';
            oli2.MC_OT_AM_Mandate_Percentage__c = 10;
            oli2.MC_OT_SM_Mandate_Percentage__c = 20;
            oli2.MC_OT_SD_Mandate_Percentage__c = 30;
            oli2.MC_OT_CM_Mandate_Percentage__c = 40;
            oli2.TeliaSE_AM_Mandate_Percentage__c = 10;
            oli2.TeliaSE_SM_Mandate_Percentage__c = 20;
            oli2.TeliaSE_SD_Mandate_Percentage__c = 30;
            oli2.TeliaSE_CM_Mandate_Percentage__c = 40;
            oli2.TeliaSE_ParentClusterCode__c = 'large';
            oli.add(oli2);
            
            QuoteLineItem oli22 = new QuoteLineItem();
            oli22.PricebookEntryId = objpricebookentry.Id;
            oli22.TeliaSE_MC_Customer_Requested_Percentage__c=10;
            oli22.QuoteId = qut.id;
            oli22.UnitPrice = 200;
            oli22.Quantity = 4;
            oli22.vlocity_cmt__Product2Id__c = prod2.id;
            oli22.Product2Id = prod2.id;
            oli22.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli22.TeliaSE_Approved__c = null;
            oli22.vlocity_cmt__RecurringCharge__c  = 200;
            oli22.TeliaSE_Ceiling_Price__c = 400;
            oli22.vlocity_cmt__RootItemId__c = oli1.id;
            oli22.vlocity_cmt__ParentItemId__c = oli1.id;
            oli22.TeliaSE_Root_Product__c=prod1.id;
            oli22.vlocity_cmt__ProductHierarchyPath__c = prod1.id+'<'+prod2.id;
            oli22.TeliaSE_Base_Quantity__c = '123';
            oli22.vlocity_cmt__JSONAttribute__c = jsonAttrib1;
            oli22.vlocity_cmt__AttributeSelectedValues__c = jsonSelectedValues;            
            oli22.RoamingResAddOns__c = '15 kr, 15 kr, 15 kr';
            oli22.RoamingTillAddOns__c = '69 kr, 49 kr, 15 kr';
            oli22.MC_OT_AM_Mandate_Percentage__c = 10;
            oli22.MC_OT_SM_Mandate_Percentage__c = 20;
            oli22.MC_OT_SD_Mandate_Percentage__c = 30;
            oli22.MC_OT_CM_Mandate_Percentage__c = 40;
            oli22.TeliaSE_AM_Mandate_Percentage__c = 10;
            oli22.TeliaSE_SM_Mandate_Percentage__c = 20;
            oli22.TeliaSE_SD_Mandate_Percentage__c = 30;
            oli22.TeliaSE_CM_Mandate_Percentage__c = 40;
            oli22.TeliaSE_ParentClusterCode__c = 'large';
            oli.add(oli22);
            
            QuoteLineItem oli3 = new QuoteLineItem();
            oli3.PricebookEntryId = objpricebookentry.Id;
            oli3.QuoteId = qut.id;
            oli3.UnitPrice = 200;
            oli3.Quantity = 4;
            oli3.vlocity_cmt__Product2Id__c = prod3.id;
            oli3.Product2Id = prod3.id;
            oli3.TeliaSE_Approved__c = null;
            oli3.vlocity_cmt__RecurringCharge__c  = 200;
            oli3.TeliaSE_Ceiling_Price__c = 400;
            oli3.vlocity_cmt__ProductHierarchyPath__c = prod3.id;
            oli3.TeliaSE_Base_Quantity__c = '123';
            oli3.vlocity_cmt__JSONAttribute__c = jsonAttrib1;
            oli3.vlocity_cmt__AttributeSelectedValues__c = jsonSelectedValues;            
            oli3.vlocity_cmt__RootItemId__c = oli1.id;
            oli3.TeliaSE_ParentClusterCode__c = 'large';
            oli.add(oli3);
            
            QuoteLineItem quoteItems1= new QuoteLineItem();
            quoteItems1.PricebookEntryId = objpricebookentry2.Id;
            quoteItems1.QuoteId = qut1.id;
            quoteItems1.UnitPrice = 200;
            quoteItems1.Quantity = 1;
            quoteItems1.Product2Id = prodt.Id;  
            quoteItems1.TeliaSE_MC_Binding_Time__c='24 Månader';
            quoteItems1.Price_List_Setup__c ='Månadsavgift';
            oli.add(quoteItems1);
            
            QuoteLineItem quoteItems2= new QuoteLineItem();
            quoteItems2.PricebookEntryId = objpricebookentry2.Id;
            quoteItems2.QuoteId = qut3.id;
            quoteItems2.UnitPrice = 200;
            quoteItems2.Quantity = 4;
            quoteItems2.Product2Id = prodt.Id;
            quoteItems2.vlocity_cmt__Product2Id__c = prodt.Id; 
            quoteItems2.vlocity_cmt__ParentItemId__c = null;
            quoteItems2.vlocity_cmt__ProductHierarchyPath__c = prodt.Id;
            oli.add(quoteItems2);
            
            QuoteLineItem quoteItems3= new QuoteLineItem();
            quoteItems3.PricebookEntryId = objpricebookentry3.Id;
            quoteItems3.QuoteId = qut3.id;
            quoteItems3.UnitPrice = 200;
            quoteItems3.Quantity = 4;
            quoteItems3.Product2Id = prod3.Id;
            quoteItems3.vlocity_cmt__Product2Id__c = prod3.Id; 
            quoteItems3.vlocity_cmt__ParentItemId__c = null;
            quoteItems3.vlocity_cmt__ProductHierarchyPath__c = prod3.Id;
            quoteItems3.TeliaSE_ParentClusterCode__c = 'large';
            oli.add(quoteItems3);
            
            QuoteLineItem quoteItems4= new QuoteLineItem();
            quoteItems4.PricebookEntryId = objpricebookentry3.Id;
            quoteItems4.QuoteId = qut3.id;
            quoteItems4.UnitPrice = 200;
            quoteItems4.Quantity = 4;
            quoteItems4.Product2Id = prod3.Id;
            quoteItems4.vlocity_cmt__Product2Id__c = prod3.Id; 
            quoteItems4.vlocity_cmt__ParentItemId__c = null;
            quoteItems4.vlocity_cmt__ProductHierarchyPath__c = prod3.Id; 
            quoteItems4.TeliaSE_ParentClusterCode__c = 'large';
            oli.add(quoteItems4);
            
            insert oli;
            
            MC_PreCheck_Result__c preresult1 = new MC_PreCheck_Result__c();
            preresult1.Name = 'BredbandPro' ;
            preresult1.MC_Product_Code__c= 'CO-BBPRO-1000MB';
            preresult1.Price__c= 7300;
            preresult1.MC_PriceParameter__c = 'P5' ;
            preresult1.MC_PriceAverageFlag__c = true ;
            preresult1.Opportunity__c= opp.Id;
            preresult1.RecordTypeId = Schema.SObjectType.MC_PreCheck_Result__c.getRecordTypeInfosByName().get('AveragePrice').getRecordTypeId();
            insert preresult1;
            Test.stopTest();
        }
        
    }
    static public testmethod void updateflag_test(){
        Map<String,Object> inputMap = new Map<string,Object>();
        Map<String,Object> outputMap = new Map<string,Object>();
        Map<String,Object> options = new Map<string,Object>();        
        /*
String quoteQuery = PricingPlanHelper.queryBuilder('Quote');
quoteQuery +=' FROM Quote where name = \'Sample Quote\'';
Quote qut = Database.query(quoteQuery);

String qitemQuery = PricingPlanHelper.queryBuilder('QuoteLineItem');
qitemQuery +=' FROM QuotelineItem WHERE '+'QuoteId=\'' + String.escapeSingleQuotes(qut.Id)+'\'' ;

List<QuoteLineItem> qitems = Database.query(qitemQuery);

vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList',qitems);
vlocity_cmt.PricingPlanService.putInPricingContext('Parent',qut);
inputMap.put('Parent',qut);
inputMap.put('ItemList',qitems);
inputMap.put('MatrixName','PriceMatrix_Office365');
inputMap.put('externalPriceData', new List<Object>{new Map<String,Object>{'UOM'=>'UOM', 'ID'=>qut.id}});
inputMap.put('pricingVariableToFieldMap', new Map<String,String>{'UOM'=>'UOM'});
inputMap.put('timePlanPolicyList', new List<Object>{'tst'});
inputMap.put('priceDetailMessage', 'msj');
inputMap.put('CreateAdjustment', false);
inputMap.put('unitOfMeasureToIdMap', new Map<String,Id>{'UOM'=>qut.id});*/
        
        List<User> userList = new List<User>();
        user salesRep = Test_DataFactory.createAdminUser();
        salesRep.MassCustomized_Roles__c = 'SalesRep';
        userList.add(salesRep);
        user salesManager = Test_DataFactory.createAdminUser();
        salesManager.MassCustomized_Roles__c = 'SalesManager';
        userList.add(salesManager);
        user SalesDirector = Test_DataFactory.createAdminUser();
        SalesDirector.MassCustomized_Roles__c = 'SalesDirector';
        userList.add(SalesDirector);
        user CommercialManager = Test_DataFactory.createAdminUser();
        CommercialManager.MassCustomized_Roles__c = 'CommercialManager';
        userList.add(CommercialManager);
        user blank1 = Test_DataFactory.createAdminUser();
        blank1.MassCustomized_Roles__c = '';
        userList.add(blank1);
        insert userList;
        Id quoteId=[select id from Quote where name='Sample Quote'][0].id;
        inputMap.put('Id',quoteId);
        Test.startTest();
        System.runAs(salesRep){            
            MC_CartRepricing.updateFlag(inputMap,outputMap,options);            
        }
        System.runAs(salesManager){
            MC_CartRepricing.updateFlag(inputMap,outputMap,options);
        }
        System.runAs(SalesDirector){
            MC_CartRepricing.updateFlag(inputMap,outputMap,options);
        }
        System.runAs(CommercialManager){
            MC_CartRepricing.updateFlag(inputMap,outputMap,options);            
        }System.runAs(blank1){
            MC_CartRepricing pph = new MC_CartRepricing();
            pph.invokeMethod('updateFlag',inputMap,outputMap,options);            
        }
        System.runAs(CommercialManager){
            //MC_CartRepricing pph = new MC_CartRepricing();
			MC_CartRepricing.updateFlag(inputMap,outputMap,options);            
        }
        Test.stopTest();
    }
    static private TeliaSERecordTypeSetting__mdt  returnTestingMetadataRecord() {
        return [SELECT Id, MassCustomized__c, CRMFiber__c, QualifiedApiName, Label, NamespacePrefix, Language, MasterLabel, DeveloperName FROM TeliaSERecordTypeSetting__mdt WHERE  MasterLabel in ('Quote')];
    }
}