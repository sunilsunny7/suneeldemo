@isTest 
public class PricingPlanhelper_test {
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
            prodList.add(prod); 
            Product2 prodoffice = new Product2 (Name='Office 365', ProductCode = 'C-OFFICE-365', vlocity_cmt__AttributeMetadata__c='{"totalSize":1,"messages":[],"records":[{"messages":[],"displaySequence":10,"Code__c":"ATT_CODE_TELIAMOBAGGR","Name":"Attributes","id":"a350Q0000008HmWQAU","productAttributes":{"totalSize":2,"messages":[],"records":[{"messages":[],"code":"ATT_RT_NoU","dataType":"number","inputType":"number","multiselect":false,"required":true,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a360Q00000028v5QAA","label":"Antal för basnivå","displaySequence":10,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"readonly":false,"disabled":false}],"userValues":null},{"messages":[],"code":"ATT_RT_CMTP","dataType":"text","inputType":"dropdown","multiselect":false,"required":true,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a360Q00000028v2QAA","label":"Avtalstid","displaySequence":20,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"id":"aba9e042-0545-92b0-b0d0-16cd00888e83","name":"aba9e042-0545-92b0-b0d0-16cd00888e83","label":"24 months","readonly":false,"disabled":false,"value":"24 months","defaultSelected":false,"displaySequence":2},{"id":"cbdeb314-b13b-d53d-72ec-8e4c3370b908","name":"cbdeb314-b13b-d53d-72ec-8e4c3370b908","label":"36 months","readonly":false,"disabled":false,"value":"36 months","defaultSelected":false,"displaySequence":3},{"id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","name":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","label":"12 months","readonly":false,"disabled":false,"value":"12 months","defaultSelected":false,"displaySequence":1}],"userValues":null}]}}]}');
            prodList.add(prodoffice); 
            Product2 prod1 = Test_DataFactory.createProducts(1)[0];
            prod1.name = 'jobbmobil Total';
            prod1.productCode = 'MOB_MULTI_TOTAL';
            prodList.add(prod1);            
            
            Product2 prod2 = Test_DataFactory.createProducts(1)[0];
            prod2.Name = 'RoamingAddOn';
            prod2.productCode = 'MOB_CALL_TRAVEL';
            prodList.add(prod2);
            //CO-BBPRO-1000MB
            Product2 prod3 = Test_DataFactory.createProducts(1)[0];
            prod3.Name = 'CO-BBPRO-1000MB';
            prod3.productCode = 'CO-BBPRO-1000MB';
            prod3.TeliaSE_Product_Type__c = 'percentage';
            prodList.add(prod3);
            //hardware product
            Product2 prodt = new Product2();
            prodt.name='Mobiltelefoner';
            prodt.ProductCode='MOB_HARDWARE_OFFER';
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
            oli1.TeliaSE_Approved__c = null;
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
            insert oli1;
            
            oli1.vlocity_cmt__RootItemId__c = oli1.vlocity_cmt__AssetReferenceId__c;
            update oli1;
            
            List<QuoteLineItem> oli = new List<QuoteLineItem>();
            
            QuoteLineItem oli2 = new QuoteLineItem();
            oli2.PricebookEntryId = objpricebookentry.Id;
            oli2.TeliaSE_MC_Customer_Requested_Percentage__c=10;
            oli2.QuoteId = qut.id;
            oli2.UnitPrice = 200;
            oli2.Quantity = 4;
            oli2.vlocity_cmt__Product2Id__c = prod2.id;
            oli2.Product2Id = prod2.id;
            oli2.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli2.TeliaSE_Approved__c = null;
            oli2.vlocity_cmt__RecurringCharge__c  = 200;
            oli2.TeliaSE_Ceiling_Price__c = 400;
            oli2.vlocity_cmt__RootItemId__c = oli1.vlocity_cmt__AssetReferenceId__c;
            oli2.vlocity_cmt__ParentItemId__c = oli1.vlocity_cmt__AssetReferenceId__c;
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
            oli22.vlocity_cmt__RootItemId__c = oli1.vlocity_cmt__AssetReferenceId__c;
            oli22.vlocity_cmt__ParentItemId__c = oli1.vlocity_cmt__AssetReferenceId__c;
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
            oli3.vlocity_cmt__RootItemId__c = oli1.vlocity_cmt__AssetReferenceId__c;
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
    static private TeliaSERecordTypeSetting__mdt  returnTestingMetadataRecord() {
        return [SELECT Id, MassCustomized__c, CRMFiber__c, QualifiedApiName, Label, NamespacePrefix, Language, MasterLabel, DeveloperName FROM TeliaSERecordTypeSetting__mdt WHERE  MasterLabel in ('Quote')];
    }
    static testmethod void createAccount(){
        test.startTest();
        Account testAcc;
        System.runAs(new User(Id = Userinfo.getUserId())){
            testAcc =Test_DataFactory.createOneKundkontoAccount();
            insert testAcc;
        }   
        Test.stopTest(); 
    }
    static private void testMatrixSetup() {
        insert new vlocity_cmt__TriggerSetup__c(Name = 'AllTriggers', vlocity_cmt__IsTriggerOn__c = true);        
        parent = new vlocity_cmt__CalculationMatrix__c(Name = 'RangeAttributePricingMatrix');
        insert parent;
        
        version = new vlocity_cmt__CalculationMatrixVersion__c(Name = 'RangeAttributePricingMatrix V2', vlocity_cmt__VersionNumber__c = 2,
                                                               vlocity_cmt__IsEnabled__c = false, vlocity_cmt__CalculationMatrixId__c = parent.Id,
                                                               vlocity_cmt__StartDateTime__c = DateTime.now().addDays(-10), vlocity_cmt__EndDateTime__c = DateTime.now().addDays(10),vlocity_cmt__Priority__c = 2);
        insert version;
        
        //Populating Headers
        lineItems = new List<vlocity_cmt__CalculationMatrixRow__c>();
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                                                               vlocity_cmt__InputData__c ='{"name":"Characteristic Name","listValues":null,"lineItemId":"a311l0000000DnLAAU","label":null,"headerType":"Input","displayOrder":3,"dataType":"Text","columnKey":"26ee5f"}'
                                                              ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                                                               vlocity_cmt__InputData__c ='{"name":"Source Product Code","listValues":null,"lineItemId":"a311l0000000DnKAAU","label":null,"headerType":"Input","displayOrder":2,"dataType":"Text","columnKey":"3a0611"}'
                                                              ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                                                               vlocity_cmt__InputData__c ='{"name":"Source Product Name","listValues":null,"lineItemId":"a311l0000000DnJAAU","label":null,"headerType":"Input","displayOrder":1,"dataType":"Text","columnKey":"13c541"}'
                                                              ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                                                               vlocity_cmt__InputData__c ='{"name":"Characteristic Value","listValues":null,"lineItemId":"a311l0000000DnMAAU","label":null,"headerType":"Input","displayOrder":4,"dataType":"Text","columnKey":"2a0cd2"}'
                                                              ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                                                               vlocity_cmt__InputData__c ='{"name":"Quantity","listValues":null,"lineItemId":"a311l0000000DnNAAU","label":null,"headerType":"Input","displayOrder":5,"dataType":"Text","columnKey":"bd81e8"}'
                                                              ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                                                               vlocity_cmt__InputData__c ='{"name":"Target Product Name","listValues":null,"lineItemId":"a311l0000000DnVAAU","label":null,"headerType":"Output","displayOrder":14,"dataType":"Text","columnKey":"1f3956"}'
                                                              ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                                                               vlocity_cmt__InputData__c ='{"name":"MRC","listValues":null,"lineItemId":"a311l0000000DnOAAU","label":null,"headerType":"Output","displayOrder":6,"dataType":"Text","columnKey":"7cdae9"}'
                                                              ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                                                               vlocity_cmt__InputData__c ='{"name":"NRC","listValues":null,"lineItemId":"a311l0000000DnIAAU","label":null,"headerType":"Output","displayOrder":7,"dataType":"Text","columnKey":"7cea71"}'
                                                              ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                                                               vlocity_cmt__InputData__c ='{"name":"MC Discount Percentage","listValues":null,"lineItemId":"a311l0000000DnQAAU","label":null,"headerType":"Output","displayOrder":8,"dataType":"Percent","columnKey":"bf59bc"}'
                                                              ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                                                               vlocity_cmt__InputData__c ='{"name":"MC CM Mandate Discount","listValues":null,"lineItemId":"a311l0000000DnRAAU","label":null,"headerType":"Output","displayOrder":9,"dataType":"Percent","columnKey":"b295c3"}'
                                                              ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                                                               vlocity_cmt__InputData__c ='{"name":"MC SM Mandate Discount","listValues":null,"lineItemId":"a311l0000000DnSAAU","label":null,"headerType":"Output","displayOrder":10,"dataType":"Percent","columnKey":"f00e31"}'
                                                              ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                                                               vlocity_cmt__InputData__c ='{"name":"MC AM Mandate Discount","listValues":null,"lineItemId":"a311l0000000DnTAAU","label":null,"headerType":"Output","displayOrder":11,"dataType":"Percent","columnKey":"ca485a"}'
                                                              ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                                                               vlocity_cmt__InputData__c ='{"name":"MC SD Mandate Discount","listValues":null,"lineItemId":"a311l0000000DnUAAU","label":null,"headerType":"Output","displayOrder":12,"dataType":"Percent","columnKey":"b1664a"}'
                                                              ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                                                               vlocity_cmt__InputData__c ='{"name":"PricePlanCode","listValues":null,"lineItemId":"a311l0000000DnPAAU","label":null,"headerType":"Output","displayOrder":13,"dataType":"Text","columnKey":"4b11bf"}'
                                                              ));
        insert lineItems;
        
        //Populating Row Data
        lineItems = new List<vlocity_cmt__CalculationMatrixRow__c>();
        
        if(flag)  //running test2
        {
            lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id,
                                                                   vlocity_cmt__InputData__c ='{"Quantity":"1-5","Characteristic Value":"Unspecified","Characteristic Name":"Commitment Period","Source Product Code":"C-BUS-ESSEN-OFFER","Source Product Name":"Business Essential Offer"}',
                                                                   vlocity_cmt__OutputData__c = '{"Target Product Name":"Business Essential Offer","PricePlanCode":"NA","MC SD Mandate Discount":0.0,"MC AM Mandate Discount":0.0,"MC SM Mandate Discount":0.0,"MC CM Mandate Discount":0.0,"MC Discount Percentage":0.0,"NRC":"0","MRC":"44"}'
                                                                  ));
            lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id,
                                                                   vlocity_cmt__InputData__c ='{"Quantity":"6-10","Characteristic Value":"Unspecified","Characteristic Name":"Commitment Period","Source Product Code":"C-BUS-ESSEN-OFFER","Source Product Name":"Business Essential Offer"}',
                                                                   vlocity_cmt__OutputData__c = '{"Target Product Name":"Business Essential Offer","PricePlanCode":"NA","MC SD Mandate Discount":0.0,"MC AM Mandate Discount":0.0,"MC SM Mandate Discount":0.0,"MC CM Mandate Discount":0.0,"MC Discount Percentage":0.0,"NRC":"0","MRC":"44"}'
                                                                  ));
            lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id,
                                                                   vlocity_cmt__InputData__c ='{"Quantity":"11-20","Characteristic Value":"Unspecified","Characteristic Name":"Commitment Period","Source Product Code":"C-BUS-ESSEN-OFFER","Source Product Name":"Business Essential Offer"}',
                                                                   vlocity_cmt__OutputData__c = '{"Target Product Name":"Business Essential Offer","PricePlanCode":"NA","MC SD Mandate Discount":0.0,"MC AM Mandate Discount":0.0,"MC SM Mandate Discount":0.0,"MC CM Mandate Discount":0.0,"MC Discount Percentage":0.0,"NRC":"0","MRC":"44"}'
                                                                  ));
            lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id,
                                                                   vlocity_cmt__InputData__c ='{"Quantity":"21-50","Characteristic Value":"Unspecified","Characteristic Name":"Commitment Period","Source Product Code":"C-BUS-ESSEN-OFFER","Source Product Name":"Business Essential Offer"}',
                                                                   vlocity_cmt__OutputData__c = '{"Target Product Name":"Business Essential Offer","PricePlanCode":"NA","MC SD Mandate Discount":0.0,"MC AM Mandate Discount":0.0,"MC SM Mandate Discount":0.0,"MC CM Mandate Discount":0.0,"MC Discount Percentage":5.0,"NRC":"0","MRC":"44"}'
                                                                  ));
        }
        
        insert lineItems;
        
        //lineItems = [SELECT Name, vlocity_cmt__InputData__c, vlocity_cmt__OutputData__c FROM vlocity_cmt__CalculationMatrixRow__c WHERE Name != 'Header'];
        update new vlocity_cmt__CalculationMatrixVersion__c(Id = version.Id, vlocity_cmt__IsEnabled__c = true);
        
        //service
        vlocity_cmt__CalculationProcedure__c calcProcedure = new vlocity_cmt__CalculationProcedure__c(Name='RangeAttributePricingProcedure');
        insert calcProcedure;
        
        //Making isEnabled = false due to ERROR="Please add steps before enabling this procedure configuration."
        vlocity_cmt__CalculationProcedureVersion__c procVersion = new vlocity_cmt__CalculationProcedureVersion__c(Name='RangeAttributePricingProcedure v2', vlocity_cmt__VersionNumber__c=2, vlocity_cmt__IsEnabled__c=false,
                                                                                                                  vlocity_cmt__CalculationProcedureId__c=calcProcedure.Id, vlocity_cmt__StartDateTime__c = DateTime.now().addDays(-5), vlocity_cmt__EndDateTime__c = DateTime.now().addDays(5), vlocity_cmt__Priority__c=2);
        insert procVersion;
        
        List<vlocity_cmt__CalculationProcedureStep__c> steps = new List<vlocity_cmt__CalculationProcedureStep__c> ();
        vlocity_cmt__CalculationProcedureStep__c step1 = new vlocity_cmt__CalculationProcedureStep__c (Name='a1L46000001ASQm', vlocity_cmt__Sequence__c=1,vlocity_cmt__Function__c='Matrix Lookup', vlocity_cmt__CalculationMatrixId__c=parent.Id, vlocity_cmt__IsIncludedInResult__c=true, vlocity_cmt__CalculationProcedureVersionId__c= procVersion.Id,
                                                                                                       vlocity_cmt__Input__c='[{"name":"Source Product Name","listValues":null,"label":null,"dataType":"Text","columnKey":"13c541"},{"name":"Source Product Code","listValues":null,"label":null,"dataType":"Text","columnKey":"3a0611"},{"name":"Characteristic Name","listValues":null,"label":null,"dataType":"Text","columnKey":"26ee5f"},{"name":"Characteristic Value","listValues":null,"label":null,"dataType":"Text","columnKey":"2a0cd2"},{"name":"Quantity","listValues":null,"label":null,"dataType":"Text","columnKey":"bd81e8"}]',
                                                                                                       vlocity_cmt__OutputMappingJSON__c ='{"NRC":"RangeAttributePricingMatrix__NRC","MRC":"RangeAttributePricingMatrix__MRC","PricePlanCode":"RangeAttributePricingMatrix__PricePlanCode","MC Discount Percentage":"RangeAttributePricingMatrix__MCDiscountPercentage","MC CM Mandate Discount":"RangeAttributePricingMatrix__MCCMMandateDiscount","MC SM Mandate Discount":"RangeAttributePricingMatrix__MCSMMandateDiscount","MC AM Mandate Discount":"RangeAttributePricingMatrix__MCAMMandateDiscount","MC SD Mandate Discount":"RangeAttributePricingMatrix__MCSDMandateDiscount","Target Product Name":"RangeAttributePricingMatrix__TargetProductName"}',
                                                                                                       vlocity_cmt__OutputJSON__c='[{"name":"NRC","listValues":null,"label":null,"dataType":"Text","columnKey":"7cea71"},{"name":"MRC","listValues":null,"label":null,"dataType":"Text","columnKey":"7cdae9"},{"name":"PricePlanCode","listValues":null,"label":null,"dataType":"Text","columnKey":"4b11bf"},{"name":"MC Discount Percentage","listValues":null,"label":null,"dataType":"Percent","columnKey":"bf59bc"},{"name":"MC CM Mandate Discount","listValues":null,"label":null,"dataType":"Percent","columnKey":"b295c3"},{"name":"MC SM Mandate Discount","listValues":null,"label":null,"dataType":"Percent","columnKey":"f00e31"},{"name":"MC AM Mandate Discount","listValues":null,"label":null,"dataType":"Percent","columnKey":"ca485a"},{"name":"MC SD Mandate Discount","listValues":null,"label":null,"dataType":"Percent","columnKey":"b1664a"},{"name":"Target Product Name","listValues":null,"label":null,"dataType":"Text","columnKey":"1f3956"}]');
        
        vlocity_cmt__CalculationProcedureStep__c step2 = new vlocity_cmt__CalculationProcedureStep__c (Name='a1L46000001ASQn', vlocity_cmt__Sequence__c=2,vlocity_cmt__Function__c='Calculation', vlocity_cmt__IsIncludedInResult__c=true, vlocity_cmt__CalculationProcedureVersionId__c= procVersion.Id,
                                                                                                       vlocity_cmt__CalculationFormulaLong__c='RangeAttributePricingMatrix__MRC', 
                                                                                                       vlocity_cmt__OutputJSON__c='{"name":"REC_MNTH_STD_PRC","dataType":"Currency","alias":"REC_MNTH_STD_PRC"}',
                                                                                                       vlocity_cmt__OutputMappingJSON__c = '{"REC_MNTH_STD_PRC":"REC_MNTH_STD_PRC"}', 
                                                                                                       vlocity_cmt__CalculationFormulaTags__c='[{"text":"MRC ( RangeAttributePricingMatrix )","alias":"RangeAttributePricingMatrix__MRC","userDefined":false,"dataType":"Text"}]');
        
        vlocity_cmt__CalculationProcedureStep__c step3 = new vlocity_cmt__CalculationProcedureStep__c (Name='a1L46000001ASQo', vlocity_cmt__Sequence__c=3,vlocity_cmt__Function__c='Calculation', vlocity_cmt__IsIncludedInResult__c=true, vlocity_cmt__CalculationProcedureVersionId__c= procVersion.Id,
                                                                                                       vlocity_cmt__CalculationFormulaLong__c='RangeAttributePricingMatrix__NRC',
                                                                                                       vlocity_cmt__OutputMappingJSON__c = '{"OT_STD_PRC":"OT_STD_PRC"}',
                                                                                                       vlocity_cmt__OutputJSON__c='{"name":"OT_STD_PRC","dataType":"Currency","alias":"OT_STD_PRC"}',
                                                                                                       vlocity_cmt__CalculationFormulaTags__c='[{"text":"NRC ( RangeAttributePricingMatrix )","alias":"RangeAttributePricingMatrix__NRC","userDefined":false,"dataType":"Text"}]' );
        
        vlocity_cmt__CalculationProcedureStep__c step4 = new vlocity_cmt__CalculationProcedureStep__c (Name='a1L46000001ASQp', vlocity_cmt__Sequence__c=4,vlocity_cmt__Function__c='Calculation', vlocity_cmt__IsIncludedInResult__c=true, vlocity_cmt__CalculationProcedureVersionId__c= procVersion.Id,
                                                                                                       vlocity_cmt__CalculationFormulaLong__c='RangeAttributePricingMatrix__MCDiscountPercentage',
                                                                                                       vlocity_cmt__OutputMappingJSON__c = '{"REC_MNTH_DISC_PERCENTAGE":"REC_MNTH_DISC_PERCENTAGE"}',
                                                                                                       vlocity_cmt__OutputJSON__c='{"name":"REC_MNTH_DISC_PERCENTAGE","dataType":"Percent","alias":"REC_MNTH_DISC_PERCENTAGE"}',
                                                                                                       vlocity_cmt__CalculationFormulaTags__c='[{"text":"MC Discount Percentage ( RangeAttributePricingMatrix )","alias":"RangeAttributePricingMatrix__MCDiscountPercentage","userDefined":false,"dataType":"Percent"}]' );
        
        vlocity_cmt__CalculationProcedureStep__c step5 = new vlocity_cmt__CalculationProcedureStep__c(Name ='a1L46000001ASQq', vlocity_cmt__Sequence__c=5, vlocity_cmt__Function__c='Calculation',vlocity_cmt__IsIncludedInResult__c=true, vlocity_cmt__CalculationProcedureVersionId__c= procVersion.Id,
                                                                                                      vlocity_cmt__CalculationFormulaLong__c ='RangeAttributePricingMatrix__MCAMMandateDiscount', 
                                                                                                      vlocity_cmt__OutputMappingJSON__c ='{"REC_MNTH_AM_MANDATE_DISC":"REC_MNTH_AM_MANDATE_DISC"}',
                                                                                                      vlocity_cmt__OutputJSON__c ='{"name":"REC_MNTH_AM_MANDATE_DISC","dataType":"Percent","alias":"REC_MNTH_AM_MANDATE_DISC"}' ,
                                                                                                      vlocity_cmt__CalculationFormulaTags__c= '[{"text":"MC AM Mandate Discount ( RangeAttributePricingMatrix )","alias":"RangeAttributePricingMatrix__MCAMMandateDiscount","userDefined":false,"dataType":"Percent"}]' );
        
        vlocity_cmt__CalculationProcedureStep__c step6 = new vlocity_cmt__CalculationProcedureStep__c(Name ='a1L46000001ASQq', vlocity_cmt__Sequence__c=6, vlocity_cmt__Function__c='Calculation',vlocity_cmt__IsIncludedInResult__c=true, vlocity_cmt__CalculationProcedureVersionId__c= procVersion.Id,
                                                                                                      vlocity_cmt__CalculationFormulaLong__c ='RangeAttributePricingMatrix__MCSDMandateDiscount', 
                                                                                                      vlocity_cmt__OutputMappingJSON__c ='{"REC_MNTH_SD_MANDATE_DISC":"REC_MNTH_SD_MANDATE_DISC"}',
                                                                                                      vlocity_cmt__OutputJSON__c ='{"name":"REC_MNTH_SD_MANDATE_DISC","dataType":"Percent","alias":"REC_MNTH_SD_MANDATE_DISC"}' ,
                                                                                                      vlocity_cmt__CalculationFormulaTags__c= '[{"text":"MC SD Mandate Discount ( RangeAttributePricingMatrix )","alias":"RangeAttributePricingMatrix__MCSDMandateDiscount","userDefined":false,"dataType":"Percent"}]');
        
        vlocity_cmt__CalculationProcedureStep__c step7 = new vlocity_cmt__CalculationProcedureStep__c(Name ='a1L46000001ASQq', vlocity_cmt__Sequence__c=7, vlocity_cmt__Function__c='Calculation',vlocity_cmt__IsIncludedInResult__c=true, vlocity_cmt__CalculationProcedureVersionId__c= procVersion.Id,
                                                                                                      vlocity_cmt__CalculationFormulaLong__c ='RangeAttributePricingMatrix__MCCMMandateDiscount', 
                                                                                                      vlocity_cmt__OutputMappingJSON__c ='{"REC_MNTH_CM_MANDATE_DISC":"REC_MNTH_CM_MANDATE_DISC"}',
                                                                                                      vlocity_cmt__OutputJSON__c ='{"name":"REC_MNTH_CM_MANDATE_DISC","dataType":"Percent","alias":"REC_MNTH_CM_MANDATE_DISC"}' ,
                                                                                                      vlocity_cmt__CalculationFormulaTags__c= '[{"text":"MC CM Mandate Discount ( RangeAttributePricingMatrix )","alias":"RangeAttributePricingMatrix__MCCMMandateDiscount","userDefined":false,"dataType":"Percent"}]');
        
        vlocity_cmt__CalculationProcedureStep__c step8 = new vlocity_cmt__CalculationProcedureStep__c(Name ='a1L46000001ASQq', vlocity_cmt__Sequence__c=8, vlocity_cmt__Function__c='Calculation',vlocity_cmt__IsIncludedInResult__c=true, vlocity_cmt__CalculationProcedureVersionId__c= procVersion.Id,
                                                                                                      vlocity_cmt__CalculationFormulaLong__c ='RangeAttributePricingMatrix__MCSMMandateDiscount', 
                                                                                                      vlocity_cmt__OutputMappingJSON__c ='{"REC_MNTH_SM_MANDATE_DISC":"REC_MNTH_SM_MANDATE_DISC"}',
                                                                                                      vlocity_cmt__OutputJSON__c ='{"name":"REC_MNTH_SM_MANDATE_DISC","dataType":"Percent","alias":"REC_MNTH_SM_MANDATE_DISC"}' ,
                                                                                                      vlocity_cmt__CalculationFormulaTags__c= '[{"text":"MC SM Mandate Discount ( RangeAttributePricingMatrix )","alias":"RangeAttributePricingMatrix__MCSMMandateDiscount","userDefined":false,"dataType":"Percent"}]');
        
        steps.add(step1);
        steps.add(step2);
        steps.add(step3);
        steps.add(step4);
        steps.add(step5);
        steps.add(step6);
        steps.add(step7);
        steps.add(step8);        
        insert steps;
        
        List<vlocity_cmt__CalculationProcedureVariable__c> calcProcVariableList = new List<vlocity_cmt__CalculationProcedureVariable__c>{
            new vlocity_cmt__CalculationProcedureVariable__c(name='REC_MNTH_STD_PRC',vlocity_cmt__alias__c='REC_MNTH_STD_PRC',vlocity_cmt__datatype__c='Currency',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='OT_STD_PRC',vlocity_cmt__alias__c='OT_STD_PRC',vlocity_cmt__datatype__c='Currency',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='Source Product Name',vlocity_cmt__alias__c='SourceProductName',vlocity_cmt__datatype__c='Text',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='Source Product Code',vlocity_cmt__alias__c='SourceProductCode',vlocity_cmt__datatype__c='Text',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='Characteristic Name',vlocity_cmt__alias__c='CharacteristicName',vlocity_cmt__datatype__c='Text',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='Characteristic Value',vlocity_cmt__alias__c='CharacteristicValue',vlocity_cmt__datatype__c='Text',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='Quantity',vlocity_cmt__alias__c='Quantity',vlocity_cmt__datatype__c='Text',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='MRC',vlocity_cmt__alias__c='MRC',vlocity_cmt__datatype__c='Text',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='NRC',vlocity_cmt__alias__c='NRC',vlocity_cmt__datatype__c='Text',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='MC Discount Percentage',vlocity_cmt__alias__c='MCDiscountPercentage',vlocity_cmt__datatype__c='Percent',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='MC SD Mandate Discount',vlocity_cmt__alias__c='MCSDMandateDiscount',vlocity_cmt__datatype__c='Percent',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='MC AM Mandate Discount',vlocity_cmt__alias__c='MCAMMandateDiscount',vlocity_cmt__datatype__c='Percent',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='MC SM Mandate Discount',vlocity_cmt__alias__c='MCSMMandateDiscount',vlocity_cmt__datatype__c='Percent',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='MC CM Mandate Discount',vlocity_cmt__alias__c='MCCMMandateDiscount',vlocity_cmt__datatype__c='Percent',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='REC_MNTH_AM_MANDATE_DISC',vlocity_cmt__alias__c='REC_MNTH_AM_MANDATE_DISC',vlocity_cmt__datatype__c='Percent',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='REC_MNTH_SM_MANDATE_DISC',vlocity_cmt__alias__c='REC_MNTH_SM_MANDATE_DISC',vlocity_cmt__datatype__c='Percent',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='REC_MNTH_CM_MANDATE_DISC',vlocity_cmt__alias__c='REC_MNTH_CM_MANDATE_DISC',vlocity_cmt__datatype__c='Percent',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='REC_MNTH_SD_MANDATE_DISC',vlocity_cmt__alias__c='REC_MNTH_SD_MANDATE_DISC',vlocity_cmt__datatype__c='Percent',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='REC_MNTH_DISC_PERCENTAGE',vlocity_cmt__alias__c='REC_MNTH_DISC_PERCENTAGE',vlocity_cmt__datatype__c='Percent',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='Target Product Name',vlocity_cmt__alias__c='RangeAttributePricingMatrix__TargetProductName',vlocity_cmt__datatype__c='Text',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='MRC',vlocity_cmt__alias__c='RangeAttributePricingMatrix__MRC',vlocity_cmt__datatype__c='Text',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='NRC',vlocity_cmt__alias__c='  RangeAttributePricingMatrix__NRC',vlocity_cmt__datatype__c='Text',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='PricePlanCode',vlocity_cmt__alias__c='RangeAttributePricingMatrix__PricePlanCode',vlocity_cmt__datatype__c='Text',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='MC Discount Percentage',vlocity_cmt__alias__c='RangeAttributePricingMatrix__MCDiscountPercentage',vlocity_cmt__datatype__c='Percent',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='MC CM Mandate Discount',vlocity_cmt__alias__c='RangeAttributePricingMatrix__MCCMMandateDiscount',vlocity_cmt__datatype__c='Percent',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='MC SM Mandate Discount',vlocity_cmt__alias__c='RangeAttributePricingMatrix__MCSMMandateDiscount',vlocity_cmt__datatype__c='Percent',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='MC AM Mandate Discount',vlocity_cmt__alias__c='RangeAttributePricingMatrix__MCAMMandateDiscount',vlocity_cmt__datatype__c='Percent',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='MC SD Mandate Discount',vlocity_cmt__alias__c='RangeAttributePricingMatrix__MCSDMandateDiscount',vlocity_cmt__datatype__c='Percent',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id)
                };
                    insert calcProcVariableList;
        
        //Creating and enabling CalculationProcedureVersion
        update new vlocity_cmt__CalculationProcedureVersion__c(Id = procVersion.Id, vlocity_cmt__IsEnabled__c = true);
        
    }
    static private void testProductSetup(){
        
        MC_RangeAttributePricingMatrixSettings__c mat = new MC_RangeAttributePricingMatrixSettings__c();
        mat.Active__c = true;
        mat.Customer_Segment__c = 'Forced RA';
        mat.Matrix_Name__c = 'PriceMatrix_Office365';
        mat.ProcedureName__c = 'Small_Office365_RangeAttributePricingProcedure';
        mat.Name = 'C-OFFICE-365';
        mat.Product_Family_Code__c = 'C-OFFICE-365';
        insert mat;
        
        vlocity_cmt__TriggerSetup__c itemTrigger = new vlocity_cmt__TriggerSetup__c(Name='AllTriggers', vlocity_cmt__IsTriggerOn__c=true);
        insert itemTrigger;
        
        List<SObject> sObjList = new List<sObject>();
        Product2 prod1 = new Product2 (Name='Office 365', ProductCode = 'C-OFFICE-365', vlocity_cmt__AttributeMetadata__c='{"totalSize":1,"messages":[],"records":[{"messages":[],"displaySequence":10,"Code__c":"ATT_CODE_TELIAMOBAGGR","Name":"Attributes","id":"a350Q0000008HmWQAU","productAttributes":{"totalSize":2,"messages":[],"records":[{"messages":[],"code":"ATT_RT_NoU","dataType":"number","inputType":"number","multiselect":false,"required":true,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a360Q00000028v5QAA","label":"Antal för basnivå","displaySequence":10,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"readonly":false,"disabled":false}],"userValues":null},{"messages":[],"code":"ATT_RT_CMTP","dataType":"text","inputType":"dropdown","multiselect":false,"required":true,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a360Q00000028v2QAA","label":"Avtalstid","displaySequence":20,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"id":"aba9e042-0545-92b0-b0d0-16cd00888e83","name":"aba9e042-0545-92b0-b0d0-16cd00888e83","label":"24 months","readonly":false,"disabled":false,"value":"24 months","defaultSelected":false,"displaySequence":2},{"id":"cbdeb314-b13b-d53d-72ec-8e4c3370b908","name":"cbdeb314-b13b-d53d-72ec-8e4c3370b908","label":"36 months","readonly":false,"disabled":false,"value":"36 months","defaultSelected":false,"displaySequence":3},{"id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","name":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","label":"12 months","readonly":false,"disabled":false,"value":"12 months","defaultSelected":false,"displaySequence":1}],"userValues":null}]}}]}');
        sObjList.add(prod1);
        
        Product2 prod2 = new Product2 (Name='Business Essential Offer', ProductCode = 'C-BUS-ESSEN-OFFER', vlocity_cmt__AttributeMetadata__c='{"totalSize":1,"messages":[],"records":[{"messages":[],"displaySequence":10,"Code__c":"ATT_CODE_TELIAMOBAGGR","Name":"Attributes","id":"a350Q0000008HmWQAU","productAttributes":{"totalSize":2,"messages":[],"records":[{"messages":[],"code":"ATT_RT_NoU","dataType":"number","inputType":"number","multiselect":false,"required":true,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a360Q00000028v5QAA","label":"Antal för basnivå","displaySequence":10,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"readonly":false,"disabled":false}],"userValues":null},{"messages":[],"code":"ATT_RT_CMTP","dataType":"text","inputType":"dropdown","multiselect":false,"required":true,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a360Q00000028v2QAA","label":"Avtalstid","displaySequence":20,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"id":"aba9e042-0545-92b0-b0d0-16cd00888e83","name":"aba9e042-0545-92b0-b0d0-16cd00888e83","label":"24 months","readonly":false,"disabled":false,"value":"24 months","defaultSelected":false,"displaySequence":2},{"id":"cbdeb314-b13b-d53d-72ec-8e4c3370b908","name":"cbdeb314-b13b-d53d-72ec-8e4c3370b908","label":"36 months","readonly":false,"disabled":false,"value":"36 months","defaultSelected":false,"displaySequence":3},{"id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","name":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","label":"12 months","readonly":false,"disabled":false,"value":"12 months","defaultSelected":false,"displaySequence":1}],"userValues":null}]}}]}');
        sObjList.add(prod2);
        
        Product2 prod3 = new Product2 (Name='Business Premium Offer', ProductCode = 'C-BUS-PREM-OFFER', vlocity_cmt__AttributeMetadata__c='{"totalSize":1,"messages":[],"records":[{"messages":[],"displaySequence":10,"Code__c":"ATT_CODE_TELIAMOBAGGR","Name":"Attributes","id":"a350Q0000008HmWQAU","productAttributes":{"totalSize":2,"messages":[],"records":[{"messages":[],"code":"ATT_RT_NoU","dataType":"number","inputType":"number","multiselect":false,"required":true,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a360Q00000028v5QAA","label":"Antal för basnivå","displaySequence":10,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"readonly":false,"disabled":false}],"userValues":null},{"messages":[],"code":"ATT_RT_CMTP","dataType":"text","inputType":"dropdown","multiselect":false,"required":true,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a360Q00000028v2QAA","label":"Avtalstid","displaySequence":20,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"id":"aba9e042-0545-92b0-b0d0-16cd00888e83","name":"aba9e042-0545-92b0-b0d0-16cd00888e83","label":"24 months","readonly":false,"disabled":false,"value":"24 months","defaultSelected":false,"displaySequence":2},{"id":"cbdeb314-b13b-d53d-72ec-8e4c3370b908","name":"cbdeb314-b13b-d53d-72ec-8e4c3370b908","label":"36 months","readonly":false,"disabled":false,"value":"36 months","defaultSelected":false,"displaySequence":3},{"id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","name":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","label":"12 months","readonly":false,"disabled":false,"value":"12 months","defaultSelected":false,"displaySequence":1}],"userValues":null}]}}]}');
        sObjList.add(prod3);
        
        Product2 prod4 = new Product2 (Name='Office 365 Abonnemang Add-On', ProductCode = 'C-OFF-AB-ADDON-OFFER',vlocity_cmt__AttributeMetadata__c='{"totalSize":1,"messages":[],"records":[{"messages":[],"displaySequence":10,"Code__c":"ATT_CODE_TELIAMOBAGGR","Name":"Attributes","id":"a350Q0000008HmWQAU","productAttributes":{"totalSize":2,"messages":[],"records":[{"messages":[],"code":"ATT_RT_NoU","dataType":"number","inputType":"number","multiselect":false,"required":true,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a360Q00000028v5QAA","label":"Antal för basnivå","displaySequence":10,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"readonly":false,"disabled":false}],"userValues":null},{"messages":[],"code":"ATT_RT_CMTP","dataType":"text","inputType":"dropdown","multiselect":false,"required":true,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a360Q00000028v2QAA","label":"Avtalstid","displaySequence":20,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"id":"aba9e042-0545-92b0-b0d0-16cd00888e83","name":"aba9e042-0545-92b0-b0d0-16cd00888e83","label":"24 months","readonly":false,"disabled":false,"value":"24 months","defaultSelected":false,"displaySequence":2},{"id":"cbdeb314-b13b-d53d-72ec-8e4c3370b908","name":"cbdeb314-b13b-d53d-72ec-8e4c3370b908","label":"36 months","readonly":false,"disabled":false,"value":"36 months","defaultSelected":false,"displaySequence":3},{"id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","name":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","label":"12 months","readonly":false,"disabled":false,"value":"12 months","defaultSelected":false,"displaySequence":1}],"userValues":null}]}}]}' );
        sObjList.add(prod4);
        
        Product2 prod5 = new Product2 (Name='Audio Conferencing', ProductCode = 'C-AUD-CONF', vlocity_cmt__AttributeMetadata__c='{"totalSize":1,"messages":[],"records":[{"messages":[],"displaySequence":10,"Code__c":"ATT_CODE_TELIAMOBAGGR","Name":"Attributes","id":"a350Q0000008HmWQAU","productAttributes":{"totalSize":2,"messages":[],"records":[{"messages":[],"code":"ATT_RT_NoU","dataType":"number","inputType":"number","multiselect":false,"required":true,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a360Q00000028v5QAA","label":"Antal för basnivå","displaySequence":10,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"readonly":false,"disabled":false}],"userValues":null},{"messages":[],"code":"ATT_RT_CMTP","dataType":"text","inputType":"dropdown","multiselect":false,"required":true,"readonly":false,"disabled":false,"filterable":false,"attributeId":"a360Q00000028v2QAA","label":"Avtalstid","displaySequence":20,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"id":"aba9e042-0545-92b0-b0d0-16cd00888e83","name":"aba9e042-0545-92b0-b0d0-16cd00888e83","label":"24 months","readonly":false,"disabled":false,"value":"24 months","defaultSelected":false,"displaySequence":2},{"id":"cbdeb314-b13b-d53d-72ec-8e4c3370b908","name":"cbdeb314-b13b-d53d-72ec-8e4c3370b908","label":"36 months","readonly":false,"disabled":false,"value":"36 months","defaultSelected":false,"displaySequence":3},{"id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","name":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","label":"12 months","readonly":false,"disabled":false,"value":"12 months","defaultSelected":false,"displaySequence":1}],"userValues":null}]}}]}');
        sObjList.add(prod5);
        
        
        insert sObjList;
        sObjList.clear();
        
        Account acc=[select id from Account limit 1];
        Date today=Date.today();
        Contract contract=new Contract();
        contract.Name='Test';
        contract.AccountId=acc.id;
        contract.Status='Draft';
        contract.Solution_Area__c='Vxl';
        contract.StartDate=Date.today();
        contract.EndDate=today.addDays(10);
        contract.ContractTerm=24;
        insert contract;
        
        contract.Status='Active';
        update contract;
        
        vlocity_cmt__ContractLineItem__c cli=new vlocity_cmt__ContractLineItem__c();
        cli.name='Office';
        cli.vlocity_cmt__product2id__c=prod1.id;
        cli.vlocity_cmt__ContractId__c=contract.id;
        cli.TeliaSE_MC_Customer_Requested_Percentage__c=5;
        cli.TeliaSE_End_Date__C=today.addDays(10);
        cli.TeliaSE_ProductHierarchy__c='ABC';
        cli.TeliasSETargetPercentage__c=5;
        cli.vlocity_cmt__RecurringCharge__c=200;
        insert cli;
        
        
        // Create Product Child Item
        //Office 365
        vlocity_cmt__ProductChildItem__c pci1 = new vlocity_cmt__ProductChildItem__c();
        pci1.vlocity_cmt__ParentProductId__c = prod1.Id;
        pci1.vlocity_cmt__ChildProductId__c = prod2.Id;
        pci1.Name = 'Test PCI1';
        pci1.vlocity_cmt__Quantity__c = 1;
        pci1.vlocity_cmt__MinQuantity__c = 1;
        pci1.vlocity_cmt__MaxQuantity__c = 25;
        pci1.vlocity_cmt__IsRootProductChildItem__c = false;
        pci1.vlocity_cmt__IsOverride__c = false;
        pci1.vlocity_cmt__ChildLineNumber__c = '10';
        pci1.vlocity_cmt__IsVirtualItem__c = false;
        sObjList.add(pci1);
        
        vlocity_cmt__ProductChildItem__c pci2 = new vlocity_cmt__ProductChildItem__c();
        pci2.vlocity_cmt__ParentProductId__c = prod1.Id;
        pci2.vlocity_cmt__ChildProductId__c = prod3.Id;
        pci2.Name = 'Test PCI2';
        pci2.vlocity_cmt__Quantity__c = 1;
        pci2.vlocity_cmt__MinQuantity__c = 1;
        pci2.vlocity_cmt__MaxQuantity__c = 1;
        pci2.vlocity_cmt__IsRootProductChildItem__c = false;
        pci2.vlocity_cmt__IsOverride__c = false;
        pci2.vlocity_cmt__ChildLineNumber__c = '20';
        pci2.vlocity_cmt__IsVirtualItem__c = false;
        sObjList.add(pci2);
        
        vlocity_cmt__ProductChildItem__c pci3 = new vlocity_cmt__ProductChildItem__c();
        pci3.vlocity_cmt__ParentProductId__c = prod1.Id;
        pci3.vlocity_cmt__ChildProductId__c = prod4.Id;
        pci3.Name = 'Test PCI3';
        pci3.vlocity_cmt__Quantity__c = 1;
        pci3.vlocity_cmt__MinQuantity__c = 1;
        pci3.vlocity_cmt__MaxQuantity__c = 1;
        pci3.vlocity_cmt__IsRootProductChildItem__c = false;
        pci3.vlocity_cmt__IsOverride__c = false;
        pci3.vlocity_cmt__ChildLineNumber__c = '30';
        pci3.vlocity_cmt__IsVirtualItem__c = false;
        sObjList.add(pci3);
        
        vlocity_cmt__ProductChildItem__c pci4 = new vlocity_cmt__ProductChildItem__c();
        pci4.vlocity_cmt__ParentProductId__c = prod4.Id;
        pci4.vlocity_cmt__ChildProductId__c = prod5.Id;
        pci4.Name = 'Test PCI4';
        pci4.vlocity_cmt__Quantity__c = 1;
        pci4.vlocity_cmt__MinQuantity__c = 1;
        pci4.vlocity_cmt__MaxQuantity__c = 20;
        pci4.vlocity_cmt__IsRootProductChildItem__c = false;
        pci4.vlocity_cmt__IsOverride__c = false;
        pci4.vlocity_cmt__ChildLineNumber__c = '10';
        pci4.vlocity_cmt__IsVirtualItem__c = false;
        sObjList.add(pci4);
        
        insert sObjList;
        System.debug(LoggingLevel.ERROR,'Prods-->'+sObjList);       
        sObjList.clear();
        
        
        Pricebook2 standardBook =  new Pricebook2(Id = Test.getStandardPricebookId(), Name = 'TestPricebook5', IsActive = true);
        
        Quote testQuote = new Quote();
        testQuote = [select Id,Pricebook2Id from Quote where Pricebook2Id != null limit 1];
        
        
        Pricebook2 testPricebook = new Pricebook2(Id = testQuote.Pricebook2Id, IsActive = true);
        
        
        //Inserting into Custom Pricebook
        PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id = testPricebook.Id,
                                                 Product2Id = prod1.Id, UnitPrice = 10, vlocity_cmt__RecurringPrice__c = 5, IsActive = true, UseStandardPrice = false);
        sObjList.add(pbe1);
        
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = testPricebook.Id,
                                                 Product2Id = prod2.Id, UnitPrice = 20, vlocity_cmt__RecurringPrice__c = 10, IsActive = true, UseStandardPrice = false);
        sObjList.add(pbe2);
        
        PricebookEntry pbe3 = new PricebookEntry(Pricebook2Id = testPricebook.Id,
                                                 Product2Id = prod3.Id, UnitPrice = 30, vlocity_cmt__RecurringPrice__c = 15, IsActive = true, UseStandardPrice = false);
        sObjList.add(pbe3);
        
        PricebookEntry pbe4 = new PricebookEntry(Pricebook2Id = testPricebook.Id,
                                                 Product2Id = prod4.Id, UnitPrice = 40, vlocity_cmt__RecurringPrice__c = 20, IsActive = true, UseStandardPrice = false);
        sObjList.add(pbe4);
        
        PricebookEntry pbe5 = new PricebookEntry(Pricebook2Id = testPricebook.Id,
                                                 Product2Id = prod5.Id, UnitPrice = 45, vlocity_cmt__RecurringPrice__c = 25, IsActive = true, UseStandardPrice = false);
        sObjList.add(pbe5);
        
        insert sObjList;
        System.debug(LoggingLevel.ERROR,'PBE-->'+sObjList);
        sObjList.clear();
        
        vlocity_cmt__PriceList__c pl1 = new vlocity_cmt__PriceList__c(vlocity_cmt__Pricebook2Id__c = testPricebook.Id, vlocity_cmt__IsActive__c = true, vlocity_cmt__Code__c = 'TestPricebook5');
        insert pl1;
        
        // Create Object Type
        SObject sObj = [SELECT Id, SobjectType, DeveloperName FROM RecordType WHERE IsActive = TRUE and SobjectType = 'vlocity_cmt__ObjectClass__c' and DeveloperName = 'ObjectType' LIMIT 1];
        vlocity_cmt__ObjectClass__c chargeObjType = new vlocity_cmt__ObjectClass__c(Name = 'Charge', vlocity_cmt__ObjectApiName__c = 'PricingElement__c', RecordTypeId = sObj.Id);
        vlocity_cmt__ObjectClass__c discObjType = new vlocity_cmt__ObjectClass__c(Name = 'Discount', vlocity_cmt__ObjectApiName__c = 'PricingElement__c', RecordTypeId = sObj.Id);
        vlocity_cmt__ObjectClass__c officeObjType = new vlocity_cmt__ObjectClass__c(Name = 'OFFICE365 Offer Spec', vlocity_cmt__ObjectApiName__c = 'Product2', RecordTypeId = sObj.Id);
        
        sObjList.clear();
        sObjList.add(chargeObjType);
        sObjList.add(discObjType);
        sObjList.add(officeObjType);
        insert sObjList; 
        sObjList.clear();
        
        vlocity_cmt__PricingVariable__c oneTimeStdPriceVar = new vlocity_cmt__PricingVariable__c(Name = 'One Time Std Price', vlocity_cmt__Code__c = 'OT_STD_PRC',vlocity_cmt__Aggregation__c = 'Unit',
                                                                                                 vlocity_cmt__ChargeType__c='One-time',vlocity_cmt__IsActive__c = true,vlocity_cmt__Scope__c = 'Line',vlocity_cmt__SubType__c = 'Standard',vlocity_cmt__Type__c = 'Price',
                                                                                                 vlocity_cmt__ValueType__c='Pricing Element',vlocity_cmt__CurrencyType__c='Currency');
        sObjList.add(oneTimeStdPriceVar);
        
        vlocity_cmt__PricingVariable__c mrcPriceVar = new vlocity_cmt__PricingVariable__c(Name = 'Recurring Monthly Std Price', vlocity_cmt__Code__c = 'REC_MNTH_STD_PRC',vlocity_cmt__Aggregation__c = 'Unit',
                                                                                          vlocity_cmt__ChargeType__c='Recurring', vlocity_cmt__RecurringFrequency__c ='Monthly',vlocity_cmt__IsActive__c = true,vlocity_cmt__Scope__c = 'Line',vlocity_cmt__SubType__c = 'Standard',vlocity_cmt__Type__c = 'Price',
                                                                                          vlocity_cmt__ValueType__c='Pricing Element',vlocity_cmt__CurrencyType__c='Currency');
        sObjList.add(mrcPriceVar);
        
        vlocity_cmt__PricingVariable__c mCAMMandateDiscount = new vlocity_cmt__PricingVariable__c(Name = 'MC AM Mandate Discount', vlocity_cmt__Code__c = 'REC_MNTH_AM_MANDATE_DISC',vlocity_cmt__Aggregation__c = 'Unit',
                                                                                                  vlocity_cmt__ChargeType__c='Adjustment', vlocity_cmt__RecurringFrequency__c ='Monthly',vlocity_cmt__IsActive__c = true,vlocity_cmt__Scope__c = 'Line',vlocity_cmt__SubType__c = 'Standard',vlocity_cmt__Type__c = 'Price',
                                                                                                  vlocity_cmt__ValueType__c='Pricing Element',vlocity_cmt__CurrencyType__c='Currency');
        sObjList.add(mCAMMandateDiscount);
        
        vlocity_cmt__PricingVariable__c mCDiscountPercent = new vlocity_cmt__PricingVariable__c(Name = 'MC Discount Percent', vlocity_cmt__Code__c = 'REC_MNTH_DISC_PERCENTAGE',vlocity_cmt__Aggregation__c = 'Unit',
                                                                                                vlocity_cmt__ChargeType__c='Adjustment', vlocity_cmt__RecurringFrequency__c ='Monthly',vlocity_cmt__IsActive__c = true,vlocity_cmt__Scope__c = 'Line',vlocity_cmt__SubType__c = 'Standard',vlocity_cmt__Type__c = 'Price',
                                                                                                vlocity_cmt__ValueType__c='Pricing Element',vlocity_cmt__CurrencyType__c='Currency');
        sObjList.add(mCDiscountPercent);
        
        vlocity_cmt__PricingVariable__c mCCMMandateDiscount = new vlocity_cmt__PricingVariable__c(Name = 'MC CM Mandate Discount', vlocity_cmt__Code__c = 'REC_MNTH_CM_MANDATE_DISC',vlocity_cmt__Aggregation__c = 'Unit',
                                                                                                  vlocity_cmt__ChargeType__c='Adjustment', vlocity_cmt__RecurringFrequency__c ='Monthly',vlocity_cmt__IsActive__c = true,vlocity_cmt__Scope__c = 'Line',vlocity_cmt__SubType__c = 'Standard',vlocity_cmt__Type__c = 'Price',
                                                                                                  vlocity_cmt__ValueType__c='Pricing Element',vlocity_cmt__CurrencyType__c='Currency');
        sObjList.add(mCCMMandateDiscount);
        
        vlocity_cmt__PricingVariable__c mCSDMandateDiscount = new vlocity_cmt__PricingVariable__c(Name = 'MC SD Mandate Discount', vlocity_cmt__Code__c = 'REC_MNTH_SD_MANDATE_DISC',vlocity_cmt__Aggregation__c = 'Unit',
                                                                                                  vlocity_cmt__ChargeType__c='Adjustment', vlocity_cmt__RecurringFrequency__c ='Monthly',vlocity_cmt__IsActive__c = true,vlocity_cmt__Scope__c = 'Line',vlocity_cmt__SubType__c = 'Standard',vlocity_cmt__Type__c = 'Price',
                                                                                                  vlocity_cmt__ValueType__c='Pricing Element',vlocity_cmt__CurrencyType__c='Currency');
        sObjList.add(mCSDMandateDiscount);
        
        vlocity_cmt__PricingVariable__c mCSMMandateDiscount = new vlocity_cmt__PricingVariable__c(Name = 'MC SM Mandate Discount', vlocity_cmt__Code__c = 'REC_MNTH_SM_MANDATE_DISC',vlocity_cmt__Aggregation__c = 'Unit',
                                                                                                  vlocity_cmt__ChargeType__c='Adjustment', vlocity_cmt__RecurringFrequency__c ='Monthly',vlocity_cmt__IsActive__c = true,vlocity_cmt__Scope__c = 'Line',vlocity_cmt__SubType__c = 'Standard',vlocity_cmt__Type__c = 'Price',
                                                                                                  vlocity_cmt__ValueType__c='Pricing Element',vlocity_cmt__CurrencyType__c='Currency');
        sObjList.add(mCSMMandateDiscount);
        
        insert sObjList;
        System.debug(LoggingLevel.ERROR,'PricingVariable-->'+sObjList);
        sObjList.clear();
        
        insert sObjList;
        
        // Create Pricing Element
        vlocity_cmt__PricingElement__c pElem1 = new vlocity_cmt__PricingElement__c(Name = '44 SEK', vlocity_cmt__ObjectTypeId__c = chargeObjType.Id, vlocity_cmt__Amount__c = 44,
                                                                                   vlocity_cmt__Code__c = 'PELEM1', vlocity_cmt__EffectiveFromDate__c = Datetime.now(), vlocity_cmt__IsActive__c = true, vlocity_cmt__IsReusable__c = true, vlocity_cmt__PricingVariableId__c = oneTimeStdPriceVar.Id, vlocity_cmt__PriceListId__c = pl1.Id);
        vlocity_cmt__PricingElement__c pElem2 = new vlocity_cmt__PricingElement__c(Name = '20 SEK', vlocity_cmt__ObjectTypeId__c = chargeObjType.Id, vlocity_cmt__Amount__c = 20,
                                                                                   vlocity_cmt__Code__c = 'PELEM2', vlocity_cmt__EffectiveFromDate__c = Datetime.now(), vlocity_cmt__IsActive__c = true, vlocity_cmt__IsReusable__c = true, vlocity_cmt__PricingVariableId__c = mrcPriceVar.Id, vlocity_cmt__PriceListId__c = pl1.Id);
        vlocity_cmt__PricingElement__c pElem4 = new vlocity_cmt__PricingElement__c(Name = '400 SEK', vlocity_cmt__ObjectTypeId__c = chargeObjType.Id, vlocity_cmt__Amount__c = 400,
                                                                                   vlocity_cmt__Code__c = 'PELEM4', vlocity_cmt__EffectiveFromDate__c = Datetime.now(), vlocity_cmt__IsActive__c = true, vlocity_cmt__IsReusable__c = false, vlocity_cmt__PricingVariableId__c = oneTimeStdPriceVar.Id, vlocity_cmt__PriceListId__c = pl1.Id);
        vlocity_cmt__PricingElement__c pElem5 = new vlocity_cmt__PricingElement__c(Name = '50 SEK', vlocity_cmt__ObjectTypeId__c = chargeObjType.Id, vlocity_cmt__Amount__c = 50,
                                                                                   vlocity_cmt__Code__c = 'PELEM5', vlocity_cmt__EffectiveFromDate__c = Datetime.now(), vlocity_cmt__IsActive__c = true, vlocity_cmt__IsReusable__c = false, vlocity_cmt__PricingVariableId__c = mrcPriceVar.Id, vlocity_cmt__PriceListId__c = pl1.Id);
        sObjList.clear();
        sObjList.add(pElem1);
        sObjList.add(pElem2);
        sObjList.add(pElem4);
        sObjList.add(pElem5);
        
        insert sObjList;
        sObjList.clear();
        
        
        List<vlocity_cmt__PricingElement__c> pricingElement = [SELECT Id, Name FROM vlocity_cmt__PricingElement__c];
        vlocity_cmt__PriceListEntry__c ple1 = new vlocity_cmt__PriceListEntry__c(vlocity_cmt__PriceListId__c=pl1.Id, vlocity_cmt__ProductId__c=prod1.Id, vlocity_cmt__PricingElementId__c = pElem1.Id, vlocity_cmt__EffectiveFromDate__c=Datetime.now(), vlocity_cmt__IsActive__c=true);
        sObjList.add(ple1);
        vlocity_cmt__PriceListEntry__c ple2 = new vlocity_cmt__PriceListEntry__c(vlocity_cmt__PriceListId__c=pl1.Id, vlocity_cmt__ProductId__c=prod2.Id, vlocity_cmt__PricingElementId__c = pElem4.Id, vlocity_cmt__EffectiveFromDate__c=Datetime.now(), vlocity_cmt__IsActive__c=true);
        sObjList.add(ple2);
        vlocity_cmt__PriceListEntry__c ple5 = new vlocity_cmt__PriceListEntry__c(vlocity_cmt__PriceListId__c=pl1.Id, vlocity_cmt__ProductId__c=prod3.Id, vlocity_cmt__PricingElementId__c = pElem1.Id, vlocity_cmt__EffectiveFromDate__c=Datetime.now(), vlocity_cmt__IsActive__c=true);
        sObjList.add(ple5);
        vlocity_cmt__PriceListEntry__c ple7 = new vlocity_cmt__PriceListEntry__c(vlocity_cmt__PriceListId__c=pl1.Id, vlocity_cmt__ProductId__c=prod4.Id, vlocity_cmt__PricingElementId__c = pElem1.Id, vlocity_cmt__EffectiveFromDate__c=Datetime.now(), vlocity_cmt__IsActive__c=true);
        sObjList.add(ple7);
        vlocity_cmt__PriceListEntry__c ple8 = new vlocity_cmt__PriceListEntry__c(vlocity_cmt__PriceListId__c=pl1.Id, vlocity_cmt__ProductId__c=prod5.Id, vlocity_cmt__PricingElementId__c = pElem1.Id, vlocity_cmt__EffectiveFromDate__c=Datetime.now(), vlocity_cmt__IsActive__c=true);
        sObjList.add(ple8);
        
        insert sObjList;
        sObjList.clear();
        
        //Creating PricingVariableBinding
        vlocity_cmt__PricingVariableBinding__c pvb1 = new vlocity_cmt__PricingVariableBinding__c(Name='One Time Std Price - QuoteLineItem',vlocity_cmt__DestinationSObjectType__c='QuoteLineItem',
                                                                                                 vlocity_cmt__DestinationFieldApiName__c = 'OneTimeCharge__c', vlocity_cmt__PricingVariableId__c = oneTimeStdPriceVar.Id);
        sObjList.add(pvb1);
        vlocity_cmt__PricingVariableBinding__c pvb2 = new vlocity_cmt__PricingVariableBinding__c(Name='Recurring Monthly Std Price - QuoteLineItem',vlocity_cmt__DestinationSObjectType__c='QuoteLineItem',
                                                                                                 vlocity_cmt__DestinationFieldApiName__c = 'RecurringCharge__c', vlocity_cmt__PricingVariableId__c = mrcPriceVar.Id);
        sObjList.add(pvb2);        
        vlocity_cmt__PricingVariableBinding__c pvb3 = new vlocity_cmt__PricingVariableBinding__c(Name='MC Discount Percentage - QuoteLineItem',vlocity_cmt__DestinationSObjectType__c='QuoteLineItem',
                                                                                                 vlocity_cmt__DestinationFieldApiName__c = 'TeliaSE_Discount_Percentage__c', vlocity_cmt__PricingVariableId__c = mCDiscountPercent.Id);
        sObjList.add(pvb3);
        vlocity_cmt__PricingVariableBinding__c pvb4 = new vlocity_cmt__PricingVariableBinding__c(Name='MC AM Mandate Discount- QuoteLineItem',vlocity_cmt__DestinationSObjectType__c='QuoteLineItem',
                                                                                                 vlocity_cmt__DestinationFieldApiName__c = 'TeliaSE_AM_Mandate_Percentage__c', vlocity_cmt__PricingVariableId__c = mCAMMandateDiscount.Id);
        sObjList.add(pvb4);
        vlocity_cmt__PricingVariableBinding__c pvb5 = new vlocity_cmt__PricingVariableBinding__c(Name='MC CM Mandate Discount- QuoteLineItem',vlocity_cmt__DestinationSObjectType__c='QuoteLineItem',
                                                                                                 vlocity_cmt__DestinationFieldApiName__c = 'TeliaSE_CM_Mandate_Percentage__c', vlocity_cmt__PricingVariableId__c = mCCMMandateDiscount.Id);
        sObjList.add(pvb5);
        vlocity_cmt__PricingVariableBinding__c pvb6 = new vlocity_cmt__PricingVariableBinding__c(Name='MC SM Mandate Discount- QuoteLineItem',vlocity_cmt__DestinationSObjectType__c='QuoteLineItem',
                                                                                                 vlocity_cmt__DestinationFieldApiName__c = 'TeliaSE_SM_Mandate_Percentage__c', vlocity_cmt__PricingVariableId__c = mCSMMandateDiscount.Id);
        sObjList.add(pvb6);
        vlocity_cmt__PricingVariableBinding__c pvb7 = new vlocity_cmt__PricingVariableBinding__c(Name='MC SD Mandate Discount- QuoteLineItem',vlocity_cmt__DestinationSObjectType__c='QuoteLineItem',
                                                                                                 vlocity_cmt__DestinationFieldApiName__c = 'TeliaSE_SD_Mandate_Percentage__c', vlocity_cmt__PricingVariableId__c = mCSDMandateDiscount.Id);
        sObjList.add(pvb7);
        
        insert sObjList;
        System.debug(LoggingLevel.ERROR, 'PVB-->'+sObjList);
        sObjList.clear();
        
        vlocity_cmt__InterfaceImplementation__c iit1 = new vlocity_cmt__InterfaceImplementation__c (Name='PricingInterface');
        insert iit1;
        vlocity_cmt__InterfaceImplementationDetail__c iid1 = new vlocity_cmt__InterfaceImplementationDetail__c (Name = 'PricingElementServiceImplementation',
                                                                                                                vlocity_cmt__InterfaceId__c=iit1.Id, vlocity_cmt__IsActive__c=true);
        insert iid1;
        
        vlocity_cmt__InterfaceImplementation__c intImpl = new vlocity_cmt__InterfaceImplementation__c (Name='TightestMatchInterface');
        insert intImpl;
        
        vlocity_cmt__InterfaceImplementationDetail__c iit004_001 = new vlocity_cmt__InterfaceImplementationDetail__c
            (Name = 'TightestMatchServiceImplementation', vlocity_cmt__InterfaceId__c=intImpl.Id, vlocity_cmt__IsDefault__c=true,vlocity_cmt__IsActive__c=true);
        insert iit004_001;
        
        vlocity_cmt__TriggerSetup__c myTrigger = new vlocity_cmt__TriggerSetup__c(Name='AllTriggers', vlocity_cmt__IsTriggerOn__c=true);
        insert myTrigger;
        vlocity_cmt__InterfaceImplementation__c iit = new vlocity_cmt__InterfaceImplementation__c (Name='ContextRuleService');
        insert iit;
        List<vlocity_cmt__InterfaceImplementationDetail__c> iidList = new List<vlocity_cmt__InterfaceImplementationDetail__c> ();
        vlocity_cmt__InterfaceImplementationDetail__c iit_001 = new vlocity_cmt__InterfaceImplementationDetail__c  (Name = 'ContextRuleService', vlocity_cmt__InterfaceId__c=iit.Id, vlocity_cmt__IsDefault__c=true,vlocity_cmt__IsActive__c=true);
        
        iidList.add(iit_001);
        insert iidList;
        
        Account accountInfo = [SELECT Id FROM Account LIMIT 1];  
        accountInfo.MC_Commercial_Setup__c = 'Forced RA';
        update accountInfo;
        
        
        Id userId = Userinfo.getUserId();
        Seller__c sellerInfo = Test_DataFactory.createBusinessAreaManagerSeller(userId);
        insert sellerInfo;
        Opportunity testOpportunity = new Opportunity();//Test_DataFactory.createSmeOpportunity();
        //testOpportunity.AccountId = accountInfo.Id;
        //insert testOpportunity;
        testOpportunity = [select id from Opportunity limit 1];
        RecordType rt = [Select id,name, DeveloperName from RecordType where Name='Contract Quote'];               
        
        Contract con=[select id from Contract limit 1];
        //Quote for Roll Down Test(Office 365)
        
        
        
        Quote quoteAfterInsert = [SELECT Id, RecordTypeId, RecordType.DeveloperName FROM Quote WHERE Id =: testQuote.Id LIMIT 1]; 
        System.debug(LoggingLevel.ERROR,'Quote-->'+quoteAfterInsert);  
        
        String recordtypeName = SEUtility.getRecordTypeDevName(quoteAfterInsert.RecordTypeId);
        // System.assertEquals(recordtypeName, quoteAfterInsert.RecordType.DeveloperName);
        
        quoteId = testQuote.Id;  
        
        List<priceBookEntry> priceBookEntry = [SELECT Id FROM PricebookEntry WHERE Product2Id =: prod1.Id];
        Id priceBookEntryId = priceBookEntry[0].Id;
        
        //creating QuoteItem
        QuoteLineItem quoteItem = new QuoteLineItem();
        quoteItem.QuoteId = testQuote.Id;
        quoteItem.PricebookEntryId = pbe1.Id;
        quoteItem.Quantity = 1;
        quoteItem.vlocity_cmt__LineNumber__c = '0001';
        quoteItem.UnitPrice = 100;
        quoteItem.vlocity_cmt__ProvisioningStatus__c = 'New';
        quoteItem.vlocity_cmt__BillingAccountId__c = accountInfo.Id;
        quoteItem.vlocity_cmt__ServiceAccountId__c = accountInfo.Id; 
        quoteItem.vlocity_cmt__EffectiveQuantity__c= 1 ;
        quoteItem.vlocity_cmt__JSONAttribute__c =  '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1l000000pixdAAA","attributeid__c":"a2s1w00000005t7AAA","attributecategoryid__c":"a2r1w0000008xvuAAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Telia Mobile Agreements","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a2p1l0000008REzAAM","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Unspecified","valuedatatype__c":"Picklist","valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"displayText":"Unspecified","id":10,"value":"Unspecified"}],"values":[{"displayText":"Unspecified","id":10,"value":"Unspecified"},{"displayText":"24 months","id":20,"value":"24"},{"displayText":"36 months","id":30,"value":"36"}],"selectedItem":{"displayText":"Unspecified","id":10,"value":"Unspecified"}},"isnottranslatable__c":false,"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1l000000pixdAAA","attributeid__c":"a2s1w00000005tMAAQ","attributecategoryid__c":"a2r1w0000008xvuAAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Telia Mobile Agreements","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a2p1l0000008RF0AAM","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Number","value":22},"isnottranslatable__c":false,"$$AttributeDefinitionEnd$$":null}]}';
        quoteitem.vlocity_cmt__AttributeSelectedValues__c = '{"ATT_RT_CMTP":"36 months","ATT_RT_NoU":"600"}';
        quoteItem.TeliaSE_Base_Quantity__c = '22';
        quoteItem.TeliaSE_ParentClusterCode__c = 'large';
        quoteItem.vlocity_cmt__RecurringCharge__c =1000;
        quoteItem.Fiber_Customer_Requested_Price__c =332;
        sObjList.add(quoteItem);
        
        QuoteLineItem quoteItem2 = new QuoteLineItem();
        quoteItem2.QuoteId = testQuote.Id;
        quoteItem2.PricebookEntryId = pbe2.Id;
        quoteItem2.Quantity = 1;
        quoteItem2.vlocity_cmt__LineNumber__c = '0001.0001';
        quoteItem2.UnitPrice = 100;
        quoteItem2.vlocity_cmt__ProvisioningStatus__c = 'New';
        quoteItem2.vlocity_cmt__BillingAccountId__c = accountInfo.Id;
        quoteItem2.vlocity_cmt__ServiceAccountId__c = accountInfo.Id;  
        quoteItem2.vlocity_cmt__EffectiveQuantity__c= 1 ;
        quoteItem2.vlocity_cmt__JSONAttribute__c = '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t6E000004jFiHQAU","attributeid__c":"a366E0000006QGZQA2","attributecategoryid__c":"a356E0000006u99QAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a336E0000002NanQAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"displayText":"24 months","id":20,"value":"24 months"},{"displayText":"36 months","id":30,"value":"36 months"},{"displayText":"Unspecified","id":10,"value":"Unspecified"}],"default":[],"selectedItem":{}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t6E000004jFiHQAU","attributeid__c":"a366E0000006QGcQAM","attributecategoryid__c":"a356E0000006u99QAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a336E0000002NaoQAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Single Value","value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"isnottranslatable__c":false,"attributeRunTimeInfo":{"dataType":"Number","uiDisplayType":"Single Value","value":null},"$$AttributeDefinitionEnd$$":null}]}';
        quoteitem2.vlocity_cmt__AttributeSelectedValues__c = '{"ATT_RT_CMTP":"36 months","ATT_RT_NoU":"600"}';
        quoteItem2.TeliaSE_ParentClusterCode__c = 'large';
        sObjList.add(quoteItem2);
        
        
        QuoteLineItem quoteItem3 = new QuoteLineItem();
        quoteItem3.QuoteId = testQuote.Id;
        quoteItem3.PricebookEntryId = pbe3.Id;
        quoteItem3.Quantity = 1;
        quoteItem3.vlocity_cmt__LineNumber__c = '0001.0002';
        quoteItem3.UnitPrice = 100;
        quoteItem3.vlocity_cmt__ProvisioningStatus__c = 'New';
        quoteItem3.vlocity_cmt__BillingAccountId__c = accountInfo.Id;
        quoteItem3.vlocity_cmt__ServiceAccountId__c = accountInfo.Id;  
        quoteItem3.vlocity_cmt__EffectiveQuantity__c= 1 ;
        quoteItem3.vlocity_cmt__JSONAttribute__c= '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t6E000004jFiHQAU","attributeid__c":"a366E0000006QGZQA2","attributecategoryid__c":"a356E0000006u99QAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a336E0000002NanQAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"displayText":"24 months","id":20,"value":"24 months"},{"displayText":"36 months","id":30,"value":"36 months"},{"displayText":"Unspecified","id":10,"value":"Unspecified"}],"default":[],"selectedItem":{}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t6E000004jFiHQAU","attributeid__c":"a366E0000006QGcQAM","attributecategoryid__c":"a356E0000006u99QAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a336E0000002NaoQAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Single Value","value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"isnottranslatable__c":false,"attributeRunTimeInfo":{"dataType":"Number","uiDisplayType":"Single Value","value":null},"$$AttributeDefinitionEnd$$":null}]}';
        quoteitem3.vlocity_cmt__AttributeSelectedValues__c = '{"ATT_RT_CMTP":"36 months","ATT_RT_NoU":"600"}';
        quoteItem3.TeliaSE_ParentClusterCode__c = 'large';
        sObjList.add(quoteItem3);
        
        
        QuoteLineItem quoteItem4 = new QuoteLineItem();
        quoteItem4.QuoteId = testQuote.Id;
        quoteItem4.PricebookEntryId = pbe4.Id;
        quoteItem4.Quantity = 1;
        quoteItem4.vlocity_cmt__LineNumber__c = '0001.0003';
        quoteItem4.UnitPrice = 100;
        quoteItem4.vlocity_cmt__ProvisioningStatus__c = 'New';
        quoteItem4.vlocity_cmt__BillingAccountId__c = accountInfo.Id;
        quoteItem4.vlocity_cmt__ServiceAccountId__c = accountInfo.Id; 
        quoteItem4.vlocity_cmt__EffectiveQuantity__c= 1 ;
        sObjList.add(quoteItem4);
        
        QuoteLineItem quoteItem5 = new QuoteLineItem();
        quoteItem5.QuoteId = testQuote.Id;
        quoteItem5.PricebookEntryId = pbe5.Id;
        quoteItem5.Quantity = 5;
        quoteItem5.vlocity_cmt__LineNumber__c = '0001.0003.0001';
        quoteItem5.UnitPrice = 100;
        quoteItem5.vlocity_cmt__ProvisioningStatus__c = 'New';
        quoteItem5.vlocity_cmt__BillingAccountId__c = accountInfo.Id;
        quoteItem5.vlocity_cmt__ServiceAccountId__c = accountInfo.Id; 
        quoteItem5.vlocity_cmt__EffectiveQuantity__c= 1 ;
        quoteItem5.vlocity_cmt__JSONAttribute__c= '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t6E000004jFiHQAU","attributeid__c":"a366E0000006QGZQA2","attributecategoryid__c":"a356E0000006u99QAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a336E0000002NanQAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"displayText":"24 months","id":20,"value":"24 months"},{"displayText":"36 months","id":30,"value":"36 months"},{"displayText":"Unspecified","id":10,"value":"Unspecified"}],"default":[],"selectedItem":{}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t6E000004jFiHQAU","attributeid__c":"a366E0000006QGcQAM","attributecategoryid__c":"a356E0000006u99QAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a336E0000002NaoQAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Single Value","value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"isnottranslatable__c":false,"attributeRunTimeInfo":{"dataType":"Number","uiDisplayType":"Single Value","value":null},"$$AttributeDefinitionEnd$$":null}]}';
        quoteitem5.vlocity_cmt__AttributeSelectedValues__c = '{"ATT_RT_CMTP":"36 months","ATT_RT_NoU":"600"}';
        quoteItem5.TeliaSE_ParentClusterCode__c = 'large';
        sObjList.add(quoteItem5);      
        insert sObjList;        
        sObjList.clear();        
        
        // Create Pricing Plan
        vlocity_cmt__PricingPlan__c plan = new vlocity_cmt__PricingPlan__c(Name = 'Default Pricing Plan', vlocity_cmt__Code__c = 'DEFAULT_PRICING_PLAN', vlocity_cmt__IsActive__c = true);
        insert plan;
        
        //PricingPlanStep__c planStep11 = new PricingPlanStep__c(Name = 'Target Pricing Demo', ImplementationName__c = 'CustomPricingPlanStepImpl', IsActive__c = true, MethodName__c = 'GetMatrixPrice', Sequence__c = 101.0, PricingPlanId__c = plan.Id);
        //PricingPlanStep__c planStep12 = new PricingPlanStep__c(Name = 'Target Path Range Pricing Demo', ImplementationName__c = 'CustomPricingPlanStepImpl', IsActive__c = true, MethodName__c = 'GetMatrixPrice', Sequence__c = 102.0, PricingPlanId__c = plan.Id);
        vlocity_cmt__PricingPlanStep__c planStep13 = new vlocity_cmt__PricingPlanStep__c(Name = 'RangeAttributePricingMatrix', vlocity_cmt__ImplementationName__c = 'CustomPricingPlanStepImpl', vlocity_cmt__IsActive__c = true, vlocity_cmt__MethodName__c = 'GetMatrixPrice', vlocity_cmt__Sequence__c = 103, vlocity_cmt__PricingPlanId__c = plan.Id, vlocity_cmt__Parameters__c ='{"ProcedureName":"RangeAttributePricingProcedure","MatrixName":"RangeAttributePricingMatrix","RangeFields":"Quantity"}');
        //PricingPlanStep__c planStep14 = new PricingPlanStep__c(Name = 'Attribute Matrix Pricing Demo', ImplementationName__c = 'CustomPricingPlanStepImpl', IsActive__c = true, MethodName__c = 'GetMatrixPrice', Sequence__c = 104.0, PricingPlanId__c = plan.Id);
        
        //sObjList.add(planStep11);
        //sObjList.add(planStep12);
        sObjList.add(planStep13);
        //sObjList.add(planStep14);
        insert sObjList;        
        sObjList.clear();
    }
    static public testmethod void getMatrixPrice_test(){
        Map<String,Object> inputMap = new Map<string,Object>();
        Map<String,Object> outputMap = new Map<string,Object>();
        Map<String,Object> options = new Map<string,Object>();        
        
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
        
        Test.startTest();
        CustomPricingPlanStepImpl obj = new CustomPricingPlanStepImpl();
        obj.invokeMethod('GetMatrixPrice',inputMap,outputMap,options);     
        
        PricingPlanhelper obj1 = new PricingPlanHelper();
        obj1.invokeMethod('GetCalculationProcedurePrice',outputMap,outputMap,options);
        Test.stopTest();
    }
    static public testmethod void InvokeCalculationProcedure_test(){
        Map<String,Object> inputMap = new Map<string,Object>();
        Map<String,Object> outputMap = new Map<string,Object>();
        Map<String,Object> options = new Map<string,Object>();        
        
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
        inputMap.put('InputData',qitems);
        inputMap.put('ProcedureName','Small_Office365_RangeAttributePricingProcedure');
        Test.startTest(); 
        PricingPlanhelper obj1 = new PricingPlanHelper();
        obj1.invokeMethod('InvokeCalculationProcedure',outputMap,outputMap,options);
        Test.stopTest();
    }
    static public testmethod void updateflag_test(){
        Map<String,Object> inputMap = new Map<string,Object>();
        Map<String,Object> outputMap = new Map<string,Object>();
        Map<String,Object> options = new Map<string,Object>();        
        
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
        inputMap.put('unitOfMeasureToIdMap', new Map<String,Id>{'UOM'=>qut.id});
        
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
        insert userList;
        Test.startTest();
        System.runAs(salesRep){            
            PricingPlanHelper pph = new PricingPlanHelper();
            pph.invokeMethod('updateFlag',inputMap,outputMap,options);            
        }
        System.runAs(salesManager){
            PricingPlanHelper pph = new PricingPlanHelper();
            pph.invokeMethod('updateFlag',inputMap,outputMap,options);
        }
        System.runAs(SalesDirector){
            PricingPlanHelper pph = new PricingPlanHelper();
            pph.invokeMethod('updateFlag',inputMap,outputMap,options);
        }
        System.runAs(CommercialManager){
            PricingPlanHelper pph = new PricingPlanHelper();
            pph.invokeMethod('updateFlag',inputMap,outputMap,options);            
        }
        Test.stopTest();
    }
    static public testmethod void SetExternalPrice_Test(){
        Map<String,Object> inputMap = new Map<string,Object>();
        Map<String,Object> outputMap = new Map<string,Object>();
        Map<String,Object> options = new Map<string,Object>();        
        
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
        inputMap.put('unitOfMeasureToIdMap', new Map<String,Id>{'UOM'=>qut.id});
        Test.startTest();
        PricingPlanHelper pph = new PricingPlanHelper();
        pph.invokeMethod('SetExternalPrice',inputMap,outputMap,options);
        Test.stopTest();
    }
    Static public testmethod void updateApprovalFlag_test() {
        test.startTest();
        user salesManager = Test_DataFactory.createAdminUser();
        salesManager.MassCustomized_Roles__c = 'SalesManager';
        insert salesManager;
        System.runAs(salesManager)
        {
            Id pricebookId;
            Id stdPriceBookRecId = Test.getStandardPricebookId();
            Id AccRtid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
            Account acc = new Account(Name='Test Account', recordtypeid = AccRtid);
            insert acc;
            
            Id OppRtid =Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Connected & Smart Building').getRecordTypeId();
            
            Opportunity opp = new Opportunity();
            opp.Name='opp1';
            opp.AccountId=acc.Id;
            opp.CloseDate = System.today();
            opp.StageName='Needs Analysis';
            opp.Pricebook2Id=Test.getStandardPricebookId();
            insert opp;
            
            ID rtd=[select Id from RecordType where sObjectType = 'Quote' And Name = 'Offer Quote'].Id;
            Quote qut = new Quote();
            qut.RecordTypeId=rtd;
            qut.Name='Test Quote';
            qut.status = 'Price Approved';
            qut.opportunityId = opp.id;
            qut.Pricebook2ID = stdPriceBookRecId;
            qut.TeliaSE_Approval_Flag__c = False;     
            insert qut;
            
            
            List<sObject> types=new List<sObject>();
            SObject sObj = [SELECT Id, SobjectType, DeveloperName FROM RecordType WHERE IsActive = TRUE and SobjectType = 'vlocity_cmt__ObjectClass__c' and DeveloperName = 'ObjectType' LIMIT 1];   
            vlocity_cmt__ObjectClass__c FiberType = new vlocity_cmt__ObjectClass__c(Name = 'Fiber Base Product Spec Type', vlocity_cmt__ObjectApiName__c = 'Product2', RecordTypeId = sObj.Id);
            
            types.add(FiberType);
            
            insert types;
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
            
            List<QuoteLineItem> preQLines = new List<QuoteLineItem>();
            
            
            QuoteLineItem oli1 = new QuoteLineItem();
            oli1.PricebookEntryId = objpricebookentry.Id;
            oli1.QuoteId = qut.id;
            oli1.UnitPrice = 200;
            oli1.Quantity = 4; 
            oli1.TeliaSE_Approved__c = 12.12; 
            oli1.TeliaSE_Nullify_Check__c = false; 
            //oli1.TeliaSE_MC_Customer_Requested_Price__c = 399; 
            oli1.TeliaSE_MC_Customer_Requested_Percentage__c = 1; 
            //TeliaSE_MC_Customer_Requested_Price__c TeliaSE_Approved__c
            oli1.vlocity_cmt__Product2Id__c = prod[1].id;
            oli1.TeliaSE_Ceiling_Price__c = 400;//TeliaSE_MC_Customer_Requested_Percentage__c
            oli1.TeliaSE_Root_Product__c=prod[1].id;
            oli1.TeliaSE_Approved_Price__c = 20; 
            oli1.TeliaSE_ParentClusterCode__c = 'large';
            insert oli1;
            
            QuoteLineItem oli11 = new QuoteLineItem();
            oli11.PricebookEntryId = objpricebookentry.Id;
            oli11.QuoteId = qut.id;
            oli11.UnitPrice = 200;
            oli11.Quantity = 4; 
            oli11.TeliaSE_Approved__c = 12.12; 
            oli11.TeliaSE_Nullify_Check__c = false; 
            //oli1.TeliaSE_MC_Customer_Requested_Price__c = 399; 
            oli11.TeliaSE_MC_Customer_Requested_Price__c = 20;
            //TeliaSE_MC_Customer_Requested_Price__c TeliaSE_Approved__c
            oli11.vlocity_cmt__Product2Id__c = prod[1].id;
            oli11.TeliaSE_Ceiling_Price__c = 400;//TeliaSE_MC_Customer_Requested_Percentage__c
            oli11.TeliaSE_Root_Product__c=prod[1].id;
            oli11.TeliaSE_Approved_Price__c = 20;  
            oli11.MC_OT_Approved_Price__c = 200;
            oli11.vlocity_cmt__OneTimeCharge__c = 200;
            oli11.TeliaSE_ParentClusterCode__c = 'large';
            insert oli11;
            
            QuoteLineItem oli12 = new QuoteLineItem();
            oli12.PricebookEntryId = objpricebookentry.Id;
            oli12.QuoteId = qut.id;
            oli12.UnitPrice = 200;
            oli12.Quantity = 4; 
            oli12.TeliaSE_Approved__c = 12.12; 
            oli12.TeliaSE_Nullify_Check__c = false; 
            oli12.TeliaSE_MC_Customer_Requested_Percentage__c = 25;
            oli12.vlocity_cmt__Product2Id__c = prod[1].id;
            oli12.TeliaSE_Ceiling_Price__c = 400;
            oli12.TeliaSE_Root_Product__c=prod[1].id;
            oli12.TeliaSE_Approved__c = 20;   
            oli12.MC_OT_Approved_Price__c = null;
            oli12.vlocity_cmt__OneTimeCharge__c = 200;
            oli12.TeliaSE_ParentClusterCode__c = 'large';
            insert oli12;
            
            QuoteLineItem oli13 = new QuoteLineItem();
            oli13.PricebookEntryId = objpricebookentry.Id;
            oli13.QuoteId = qut.id;
            oli13.UnitPrice = 200;
            oli13.Quantity = 4; 
            oli13.TeliaSE_Approved__c = 12.12; 
            oli13.TeliaSE_Nullify_Check__c = false; 
            oli13.TeliaSE_MC_Customer_Requested_Percentage__c = 25;
            oli13.vlocity_cmt__Product2Id__c = prod[1].id;
            oli13.TeliaSE_Ceiling_Price__c = 400;
            oli13.TeliaSE_Root_Product__c=prod[1].id;
            oli13.TeliaSE_Approved__c = null;    
            oli13.MC_OT_Approved_Price__c = 200;
            oli13.vlocity_cmt__OneTimeCharge__c = 20;
            oli13.TeliaSE_ParentClusterCode__c = 'large';
            insert oli13;
            
            QuoteLineItem oli14 = new QuoteLineItem();
            oli14.PricebookEntryId = objpricebookentry.Id;
            oli14.QuoteId = qut.id;
            oli14.UnitPrice = 200;
            oli14.Quantity = 4; 
            oli14.TeliaSE_Approved__c = 12.12; 
            oli14.TeliaSE_Nullify_Check__c = false; 
            oli14.TeliaSE_MC_Customer_Requested_Percentage__c = 2;
            oli14.vlocity_cmt__Product2Id__c = prod[1].id;
            oli14.TeliaSE_Ceiling_Price__c = 400;
            oli14.TeliaSE_Root_Product__c=prod[1].id;
            oli14.TeliaSE_Approved__c = null;  
            oli14.MC_OT_Approved_Price__c = null;
            oli14.vlocity_cmt__OneTimeCharge__c = 20;
            oli14.TeliaSE_ParentClusterCode__c = 'large';
            insert oli14;
            //preQLines.add(oli);
            preQLines.add(oli1);
            preQLines.add(oli11);
            preQLines.add(oli12);   
            preQLines.add(oli13);
            preQLines.add(oli14);
            List<QuoteLineItem> qlist = new List<QuoteLineItem>();
            Map<ID, QuoteLineItem> qItemMap = new Map<ID, QuoteLineItem>([Select id,TeliaSE_Floor_Percentage__c,TeliaSE_Ceiling_Price__c from QuoteLineItem where QuoteId =: qut.Id]);             
            List<QuoteLineItem> abc = new List<QuoteLineItem>([SELECT Id FROM Quotelineitem LIMIT 10]);
            for (QuoteLineItem qli : abc) {
                qli.TeliaSE_Approved_Price__c = 20;
                qli.TeliaSE_Nullify_Check__c =false;
                qlist.add(qli);
            }
            
            Double fprice = 5;
            Double floorper = 10;
            
            PricingPlanHelper.updateApprovalFlag(preQLines,fprice,floorper,200,210,qItemMap);
            test.stopTest();
        }
    }
    static private testmethod void EvaluateTarget_Test(){
        OrderItem oi = new OrderItem(vlocity_cmt__LineNumber__c = '1', vlocity_cmt__PricingLogData__c = '{"ExternalPrices":"Test","Key":"Test"}');
        List<SObject> itemList = new List<SObject>{oi};
            vlocity_cmt__ChargeMeasurement__c cm = new vlocity_cmt__ChargeMeasurement__c(Name='Test');
        insert cm;
        
        List<Object> procResult = new List<Object>();
        Map<Id,SObject> itemIdToItem = new Map<Id,SObject>();
        Map<Id,String> itemIdToPathKeyMapping = new Map<Id,String>{cm.Id=>'pathKey'};
            Map<String,List<SObject>> prodNameToItems = new Map<String,List<SObject>>();
        
        Map<String,Object> firstObj = new Map<String,Object>{'TargetProductName'=>cm.Id};
            Map<String,Object> secndObj = new Map<String,Object>{'ID'=>cm.Id};    
                procResult.add(firstObj);
        procResult.add(secndObj);
        
        itemIdToItem.put(cm.Id,oi);
        itemIdToItem.put(null,oi);
        
        prodNameToItems.put(cm.Id, new List<SObject>{oi});
        
        Test.startTest();
        PricingPlanHelper pph = new PricingPlanHelper();
        pph.evaluateTarget(procResult,null,null,itemIdToItem,itemIdToPathKeyMapping,prodNameToItems);
        pph.clearExternalPriceFlag(itemList);
        Test.stopTest();
    }
    static private testmethod void UpdateBindingTime_Test(){
        Map<String,Object> inputMap = new Map<string,Object>();
        Map<String,Object> outputMap = new Map<string,Object>();
        Map<String,Object> options = new Map<string,Object>();        
        
        String quoteQuery = PricingPlanHelper.queryBuilder('Quote');
        String quoteQuery1 = quoteQuery;
        quoteQuery1 +=' FROM Quote where name = \'Sample Hardware Quote\'';
        Quote qut = Database.query(quoteQuery1);
        
        String quoteQuery2 = quoteQuery;
        quoteQuery2 +=' FROM Quote where name = \'Sample Offer Quote\'';
        Quote qut1 = Database.query(quoteQuery2);
        
        Map<ID,Product2> prodMap = new Map<ID, Product2>([SELECT id,ProductCode FROM Product2 WHERE ProductCode='MOB_HARDWARE_OFFER']);
        List<Id> prodid = new List<Id>();
        List<String> prodCode = new List<String>();
        prodid.addAll(prodMap.keySet());
        prodCode.add('MOB_HARDWARE_OFFER');
        Test.startTest();
        PricingPlanHelper pphelper = new PricingPlanHelper();
        // pphelper.getBindingTimeAndPricelistSetup(prodid,qut.Id,qut);
        // pphelper.getBindingTimeAndPricelistSetup(prodid,qut1.Id,qut1);
        // pphelper.getBindingTimeAndPricelistSetup(null,null,null);
        Test.stopTest();
    }
    static public testmethod void getQuoteLineItems_test(){
        Map<String,Object> inputMap = new Map<string,Object>();
        Map<String,Object> outputMap = new Map<string,Object>();
        Map<String,Object> options = new Map<string,Object>();        
        
        String quoteQuery = PricingPlanHelper.queryBuilder('Quote');
        quoteQuery +=' FROM Quote where name = \'Sample Offer Quote\'';
        Quote qut = Database.query(quoteQuery);
        
        String qitemQuery = PricingPlanHelper.queryBuilder('QuoteLineItem');
        qitemQuery +=',PricebookEntry.Product2.ProductCode FROM QuotelineItem WHERE '+'QuoteId=\'' + String.escapeSingleQuotes(qut.Id)+'\'' ;
        
        List<QuoteLineItem> qitems = Database.query(qitemQuery);
        
        vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList',qitems);
        vlocity_cmt.PricingPlanService.putInPricingContext('Parent',qut);
        inputMap.put('Parent',qut);
        inputMap.put('ItemList',qitems);
        
        List<Product2> prodList = [Select id, ProductCode from product2];
        List<String> prodCodeList = new List<String>();
        List<Id> prodIdList = new List<Id>();
        for(Product2 prod:prodList)
        {
            prodCodeList.add(prod.ProductCode);
            prodIdList.add(prod.id);
        }
        
        Test.startTest();
        PricingPlanHelper pphelper = new PricingPlanHelper();
        pphelper.getQuoteLineItems(prodCodeList, prodIdList, null, 'Quote', qut.id); 
        Map<String,Boolean> singleCart = new Map<String,Boolean>();
        singleCart.put('flag',true);
        List<Sobject> sobjectList= pphelper.getFrameContractLineItems(prodCodeList, prodIdList,qut.id,'Quote',qut,singleCart);
        pphelper.invokeMethod('priceItems',inputMap,outputmap,options);
        Test.stopTest();
    }
    @isTest
    static private void getRangeFieldsMapping_Test() {
        Map<String, Object> inputDataMap = new Map<String, Object>{'Characteristic Value'=>'1-5;6'};
            Set<String> charNameSet = new Set<String>{'attrName','attrName2'};
                Set<String> rangeAttrs = new Set<String>{'attrName','attrName2'};
                    Map<String, Object> rangeAttrMapping = new Map<String, Object>{'attrName'=>new Map<String, Object>{'attrName'=>new Map<String, Object>{'attrName'=>'attrName'}}};
                        
                        Map<String, Object> inputDataMap2 = new Map<String, Object>{'1-5'=>'1-5','attrName'=>'1'};
                            Set<String> rangeFields = new Set<String>{'1-5','attrName'};
                                Map<String, Object> rangeFieldMapping = new Map<String, Object>{'attrName'=>new Map<String, Object>{'attrName'=>new Map<String, Object>{'attrName'=>'1'}}};
                                    
                                    Test.startTest();
        PricingPlanHelper.getRangeAttributesMapping('1',inputDataMap,charNameSet,rangeAttrs,rangeAttrMapping);
        PricingPlanHelper.getRangeFieldsMapping('1',inputDataMap2,rangeFields,rangeFieldMapping);
        Test.stopTest();
    }
    @isTest
    static private void invokeMethodsNoParams_Test(){        
        Map<String, object> priceHelperInput = new Map<String, object>();
        Map<String, object> priceHelperOutput = new Map<String, object>();
        Map<String, object> priceHelperOptions = new Map<String, object>();
        
        // create the matrix input rows from the itemList
        PricingPlanHelper priceHelper = new PricingPlanHelper();
        
        //Should return false because of invalid inputs
        boolean flag = priceHelper.invokeMethod('GetCalculationProcedurePrice', priceHelperInput, priceHelperOutput, priceHelperOptions);
        flag = priceHelper.invokeMethod('SetExternalPrice', priceHelperInput, priceHelperOutput, priceHelperOptions);
        flag = priceHelper.invokeMethod('GetMatrixProductCodeMapping', priceHelperInput, priceHelperOutput, priceHelperOptions);
        flag = priceHelper.invokeMethod('Test', priceHelperInput, priceHelperOutput, priceHelperOptions);
        
        //Input not needed, should return true
        flag = priceHelper.invokeMethod('GetMatrixRow', priceHelperInput, priceHelperOutput, priceHelperOptions);
        flag = priceHelper.invokeMethod('InvokeCalculationProcedure', priceHelperInput, priceHelperOutput, priceHelperOptions);
        flag = priceHelper.invokeMethod('InvokeIntegrationProcedure', priceHelperInput, priceHelperOutput, priceHelperOptions);
    }
    @isTest
    static private void test1(){
        
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String,Object>();
        Map<String, Object> input = new Map<String, Object>();
        flag = true;
        
        Test.startTest();
        testProductSetup();
        System.debug(LoggingLevel.ERROR,'After Product Setup');
        testMatrixSetup();
        
        Contract con=[select id from Contract limit 1];
        sObject targetProduct1 = [ SELECT Id, Name, vlocity_cmt__JSONAttribute__c FROM Product2 WHERE Name = 'Office 365' limit 1];
        /*
Quote quote=[Select Id, RecordTypeId, RecordType.DeveloperName FROM Quote WHERE Id =: quoteId];
quote.vlocity_cmt__frameContractId__c=con.id;
update quote;
*/
        sObject quoteSObject =[Select Id, RecordTypeId, RecordType.DeveloperName FROM Quote WHERE Id =: quoteId];
        Quote quote1 = (Quote)quoteSObject;
        quote1.vlocity_cmt__ParentQuoteId__c = quote1.id;        
        Sobject quoteSobject1 = (Sobject) quote1;
        List<SObject> quoteItemList =[SELECT Id, PricebookEntryId, PricebookEntry.Product2.Name, PricebookEntry.Product2.ProductCode,
                                      PricebookEntry.Product2.vlocity_cmt__JSONAttribute__c,vlocity_cmt__RootItemId__c,vlocity_cmt__AssetReferenceId__c,
                                      vlocity_cmt__JSONAttribute__c, vlocity_cmt__ProvisioningStatus__c, vlocity_cmt__RecurringCharge__c,
                                      vlocity_cmt__LineNumber__c, vlocity_cmt__PricingLogData__c, vlocity_cmt__OneTimeCharge__c,
                                      vlocity_cmt__Product2Id__c, Quantity, ListPrice, UnitPrice,
                                      vlocity_cmt__ProductHierarchyPath__c, Product2Id, vlocity_cmt__EffectiveQuantity__c,
                                      vlocity_cmt__InCartQuantityMap__c, vlocity_cmt__ServiceAccountId__c, vlocity_cmt__ServiceAccountId__r.Id,
                                      vlocity_cmt__ServiceAccountId__r.Name, vlocity_cmt__ServiceAccountId__r.RecordTypeId,
                                      vlocity_cmt__BillingAccountId__c, vlocity_cmt__BillingAccountId__r.Id,
                                      vlocity_cmt__BillingAccountId__r.Name, vlocity_cmt__BillingAccountId__r.RecordTypeId,
                                      TeliaSE_Base_Quantity__c,TeliaSE_PriceTypeCategory__c,Fiber_Customer_Requested_Price__c,TeliaSE_ParentClusterCode__c
                                      FROM QuoteLineItem 
                                      WHERE QuoteId =: quoteId];
        List<SObject> updatedQuoteItemList = new List<SObject>();
        for(SObject eachQLI : quoteItemList){
            QuoteLineItem qLI = (QuoteLineItem)eachQLI;
            //qLI.QuoteId = quoteSObject.Id;
            qLI.Fiber_Customer_Requested_Price__c = 120;
            if(qLI.vlocity_cmt__AssetReferenceId__c == qLI.vlocity_cmt__RootItemId__c){
                qLI.vlocity_cmt__JSONAttribute__c = '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1l000000pixdAAA","attributeid__c":"a2s1w00000005t7AAA","attributecategoryid__c":"a2r1w0000008xvuAAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Telia Mobile Agreements","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a2p1l0000008REzAAM","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Unspecified","valuedatatype__c":"Picklist","valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"displayText":"Unspecified","id":10,"value":"Unspecified"}],"values":[{"displayText":"Unspecified","id":10,"value":"Unspecified"},{"displayText":"24 months","id":20,"value":"24"},{"displayText":"36 months","id":30,"value":"36"}],"selectedItem":{"displayText":"Unspecified","id":10,"value":"Unspecified"}},"isnottranslatable__c":false,"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1l000000pixdAAA","attributeid__c":"a2s1w00000005tMAAQ","attributecategoryid__c":"a2r1w0000008xvuAAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Telia Mobile Agreements","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a2p1l0000008RF0AAM","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Number","value":8},"isnottranslatable__c":false,"$$AttributeDefinitionEnd$$":null}]}';
                qLI.vlocity_cmt__AttributeSelectedValues__c = '{"ATT_RT_CMTP":"36 months","ATT_RT_NoU":"600"}';
                qLI.RoamingTillAddOns__c = 'Roaming1';
                qli.RoamingResAddOns__c = 'Roaming2';
            }
            updatedQuoteItemList.add(qLI);
        }
        
        update updatedQuoteItemList;     
        
        //List<SObject> updatedquoteItemList = new List<sObject>();
        Vlocity_cmt.JSONAttributeSupport jsonSupport = new Vlocity_cmt.JSONAttributeSupport();
        
        
        vlocity_cmt.PricingPlanService.putInPricingContext('Parent', quoteSobject1);
        vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList', updatedQuoteItemList);
        
        Set<String> rangeAttrs = new Set<String>();
        rangeAttrs.add('abc');
        rangeAttrs.add('bcd');
        rangeAttrs.add('def');
        
        input.put('ProcedureName','RangeAttributePricingProcedure');
        input.put('MatrixName','RangeAttributePricingMatrix');        
        input.put('RangeFields','Quantity');               
        input.put('RangeFieldMapping',rangeAttrs);               
        
        CustomPricingPlanStepImpl testing = new CustomPricingPlanStepImpl();
        testing.invokeMethod('GetMatrixPrice',input,output,options);
        
        for(SObject quoteItem : quoteItemList){
            if(quoteItem.get('vlocity_cmt__RecurringCharge__c')!=null)
            {
                // System.assert(quoteItem.get('vlocity_cmt__RecurringCharge__c') == 300);
                //  System.assert(quoteItem.get('vlocity_cmt__OneTimeCharge__c') == 125);
            }
        }
        
        PricingPlanHelper helper=new PricingPlanHelper();
        helper.invokeMethod('priceItems',input,output,options);
        helper.invokeMethod('GetCalculationProcedurePrice',input,output,options);
        helper.invokeMethod('GetMatrixRow',input,output,options);
        helper.invokeMethod('InvokeCalculationProcedure',input,output,options);
        helper.invokeMethod('InvokeIntegrationProcedure',input,output,options);
        helper.invokeMethod('SetExternalPrice',input,output,options);
        helper.invokeMethod('GetMatrixProductCodeMapping',input,output,options);
        helper.invokeMethod('priceItems',input,output,options);
        helper.invokeMethod('updateFlag',input,output,options);
        helper.invokeMethod('updateDiscount',input,output,options);
        
        Test.stopTest();
    }    
    @isTest
    static private void updateDiscount_test(){
        
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String,Object>();
        Map<String, Object> input = new Map<String, Object>();
        flag = true;
        
        testProductSetup();
        testMatrixSetup();
        Id quoRtid = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Individual Quote').getRecordTypeId();
        
        Id OppRtid =Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Connected & Smart Building').getRecordTypeId();
        
        Id AccRtid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        Account acc = new Account(Name='Test Account', recordtypeid = AccRtid);
        Test.startTest();
        insert acc;
        //Test.startTest();
        Opportunity opp = new Opportunity(Name='opp1',AccountId=acc.Id,CloseDate=system.today(),stageName='01 Prospect',recordtypeid = OppRtid);
        insert opp;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        
        Quote quoteSObject = new Quote();
        quoteSObject.Name='Test Quote';
        quoteSObject.status = 'Draft';
        quoteSObject.RecordTypeId = quoRtid;
        quoteSObject.opportunityId = opp.id;
        quoteSObject.Pricebook2ID = stdPriceBookRecId;
        quoteSObject.TeliaSE_Approval_Flag__c = False;        
        quoteSObject.TeliaSE_Fiber_Number_of_Households__c = 5;
        //quoteSObject.Number_of_other_Ports__c = 5;
        quoteSObject.Amount_of_ports_Smart_Home__c = 5;
        quoteSObject.TeliaSE_Fiber_Number_of_Ports__c = 5;
        quoteSObject.TeliaSE_Pris_BB_exkl_moms__c = 5;
        quoteSObject.TeliaSE_Pris_TV_exkl_moms__c = 5;
        insert quoteSObject;

        sObject targetProduct1 = [ SELECT Id, Name, vlocity_cmt__JSONAttribute__c,vlocity_cmt__AttributeMetadata__c FROM Product2 WHERE Name = 'Office 365' limit 1];
        
        //sObject quoteSObject =[Select Id , RecordTypeId, RecordType.DeveloperName FROM Quote WHERE Id =: quoteId];
        List<SObject> quoteItemList =[SELECT Id, PricebookEntryId, PricebookEntry.Product2.Name, PricebookEntry.Product2.ProductCode,
                                      PricebookEntry.Product2.vlocity_cmt__JSONAttribute__c, PricebookEntry.Product2.vlocity_cmt__AttributeMetadata__c ,vlocity_cmt__AssetReferenceId__c, vlocity_cmt__RootItemId__c,
                                      vlocity_cmt__JSONAttribute__c,vlocity_cmt__AttributeSelectedValues__c, vlocity_cmt__ProvisioningStatus__c, vlocity_cmt__RecurringCharge__c,
                                      vlocity_cmt__LineNumber__c, vlocity_cmt__PricingLogData__c, vlocity_cmt__OneTimeCharge__c,
                                      vlocity_cmt__Product2Id__c, Quantity, ListPrice, UnitPrice,
                                      vlocity_cmt__ProductHierarchyPath__c, Product2Id, vlocity_cmt__EffectiveQuantity__c,
                                      vlocity_cmt__InCartQuantityMap__c, vlocity_cmt__ServiceAccountId__c, vlocity_cmt__ServiceAccountId__r.Id,
                                      vlocity_cmt__ServiceAccountId__r.Name, vlocity_cmt__ServiceAccountId__r.RecordTypeId,
                                      vlocity_cmt__BillingAccountId__c, vlocity_cmt__BillingAccountId__r.Id,Fiber_Customer_Requested_Price__c,
                                      vlocity_cmt__BillingAccountId__r.Name, vlocity_cmt__BillingAccountId__r.RecordTypeId,
                                      TeliaSE_PriceTypeCategory__c
                                      FROM QuoteLineItem 
                                      WHERE QuoteId =: quoteId];
        List<SObject> updatedQuoteItemList = new List<SObject>();
        for(SObject eachQLI : quoteItemList){
            QuoteLineItem qLI = (QuoteLineItem)eachQLI;
            qli.Fiber_Customer_Requested_Price__c = 14;
            qli.vlocity_cmt__RecurringCharge__c = 100;
            if(qLI.vlocity_cmt__AssetReferenceId__c == qLI.vlocity_cmt__RootItemId__c){
                qLI.vlocity_cmt__JSONAttribute__c = '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1l000000pixdAAA","attributeid__c":"a2s1w00000005t7AAA","attributecategoryid__c":"a2r1w0000008xvuAAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Telia Mobile Agreements","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a2p1l0000008REzAAM","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Unspecified","valuedatatype__c":"Picklist","valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"displayText":"Unspecified","id":10,"value":"Unspecified"}],"values":[{"displayText":"Unspecified","id":10,"value":"Unspecified"},{"displayText":"24 months","id":20,"value":"24"},{"displayText":"36 months","id":30,"value":"36"}],"selectedItem":{"displayText":"Unspecified","id":10,"value":"Unspecified"}},"isnottranslatable__c":false,"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1l000000pixdAAA","attributeid__c":"a2s1w00000005tMAAQ","attributecategoryid__c":"a2r1w0000008xvuAAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Telia Mobile Agreements","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a2p1l0000008RF0AAM","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Number","value":8},"isnottranslatable__c":false,"$$AttributeDefinitionEnd$$":null}]}';
                qLI.vlocity_cmt__AttributeSelectedValues__c = '{"ATT_RT_CMTP":"36 months","ATT_RT_NoU":"600"}';
            }
            updatedQuoteItemList.add(qLI);
        }
        
        update updatedQuoteItemList;        
        
        vlocity_cmt.PricingPlanService.putInPricingContext('Parent', quoteSObject);
        vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList', updatedQuoteItemList);
        
        
        input.put('ProcedureName','RangeAttributePricingProcedure');
        input.put('MatrixName','RangeAttributePricingMatrix');        
        input.put('RangeFields','Quantity');       
        
        CustomPricingPlanStepImpl testing = new CustomPricingPlanStepImpl();
        testing.invokeMethod('GetMatrixPrice',input,output,options);
        
        TeliaSERecordTypeSetting = returnTestingMetadataRecord();
        
        PricingPlanHelper helper=new PricingPlanHelper();
        helper.invokeMethod('abc',input,output,options);
        helper.invokeMethod('updateDiscount',input,output,options);
        helper.invokeMethod('updateFlag',input,output,options);
        
        helper.invokeMethod('getProcedureName',input,output,options);
        helper.invokeMethod('GetMatrixRow',input,output,options);
        helper.invokeMethod('InvokeCalculationProcedure',input,output,options);
        helper.invokeMethod('InvokeIntegrationProcedure',input,output,options);
        helper.invokeMethod('SetExternalPrice',input,output,options);
        helper.invokeMethod('GetMatrixProductCodeMapping',input,output,options);
        helper.invokeMethod('priceItems',input,output,options);
        Test.stopTest();
    }
    
  @isTest
    static private void test3()
    {
        Map<Id,String> inputs = new Map<Id,String>();
        
        Test.startTest();
        Account acc=[select id from Account limit 1];
        inputs.put(acc.id,'Path2');
        pricingPlanhelper.replaceNameWithPath('Product2',acc.id,inputs);
        test.stopTest();
    }   
    
    @isTest
    static private void test_OrderItem(){
        FeaturesSetting__c settings = new FeaturesSetting__c();
        settings.Name = 'PriceOverride';
        settings.flag__c = true;
        insert settings;
        OrderItem oi = new OrderItem(vlocity_cmt__LineNumber__c = '1', vlocity_cmt__PricingLogData__c = '{"ExternalPrices":"Test","Key":"Test"}');
        List<SObject> itemList = new List<SObject>{oi};
            Map<String, object> priceHelperInput = new Map<String, object>();
        Map<String, object> priceHelperOutput = new Map<String, object>();
        Map<String, object> priceHelperOptions = new Map<String, object>();
        
        // create the matrix input rows from the itemList
        PricingPlanHelper priceHelper = new PricingPlanHelper();
        vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList',itemList);
        priceHelperInput.put('ItemList',itemList);
        //Should return false because of invalid inputs
        Test.startTest();
        boolean flag = priceHelper.invokeMethod('priceItems', priceHelperInput, priceHelperOutput, priceHelperOptions);
        Test.stopTest();
    }
    
    @isTest
    static private void test_OrderItemFalse(){
        FeaturesSetting__c settings = new FeaturesSetting__c();
        settings.Name = 'PriceOverride';
        settings.flag__c = true;
        insert settings;
        OrderItem oi = new OrderItem(vlocity_cmt__LineNumber__c = '1', vlocity_cmt__PricingLogData__c = '{"ExternalPrices":"Test","Key":"Test"}');
        List<SObject> itemList = new List<SObject>{oi};
            Map<String, object> priceHelperInput = new Map<String, object>();
        Map<String, object> priceHelperOutput = new Map<String, object>();
        Map<String, object> priceHelperOptions = new Map<String, object>();
        
        PricingPlanHelper priceHelper = new PricingPlanHelper();
        vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList',itemList);
        priceHelperInput.put('ItemList',itemList);
        
        Test.startTest();
        boolean flag = priceHelper.invokeMethod('incorrectMethodName', priceHelperInput, priceHelperOutput, priceHelperOptions);
        Test.stopTest();
        System.assertEquals(false, flag);
    }
    
    @isTest
    static private void test_invokeCalculationProcedure(){
        
        Map<String, object> priceHelperInput = new Map<String, object>();
        Map<String, object> priceHelperOutput = new Map<String, object>();
        Map<String, object> priceHelperOptions = new Map<String, object>();
        String quoteQuery = PricingPlanHelper.queryBuilder('Quote');
        quoteQuery +=' FROM Quote where name = \'Sample Offer Quote\'';
        Quote qut = Database.query(quoteQuery);
        
        String qitemQuery = PricingPlanHelper.queryBuilder('QuoteLineItem');
        qitemQuery +=',PricebookEntry.Product2.ProductCode FROM QuotelineItem WHERE '+'QuoteId=\'' + String.escapeSingleQuotes(qut.Id)+'\'' ;
        
        List<QuoteLineItem> qitems = Database.query(qitemQuery);
        
        vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList',qitems);
        vlocity_cmt.PricingPlanService.putInPricingContext('Parent',qut);
        priceHelperInput.put('Parent',qut);
        priceHelperInput.put('ItemList',qitems);
        priceHelperInput.put('InputData',JSON.deserializeUntyped('[{"ExternalPrices":"Test","Key":"Test"}]'));
        PricingPlanHelper priceHelper = new PricingPlanHelper();
        priceHelperInput.put('ProcedureName','TestProcedure');
        
        Test.startTest();
        boolean flag = priceHelper.invokeMethod('InvokeCalculationProcedure', priceHelperInput, priceHelperOutput, priceHelperOptions);
        Test.stopTest();
        
    }
}