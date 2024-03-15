@isTest
public with sharing class UpdateCLIBatchJob_test {
    @isTest
    public static void testmethod1(){
        User salesManager;         
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        salesManager = Test_DataFactory.createAdminUser();
        salesManager.ForecastEnabled = true;
        salesManager.Bypass_VR__c = true;
        insert salesManager;
        System.runAs(salesManager){
            
            
            //Creating account
            Account acc=Test_DataFactory.createOneSMEAccount();
            acc.MC_Commercial_Setup__c = 'Forced RA';
            acc.Org_Nr__c  = '5564110665';
            acc.Name = 'R21.4_Test_CO_Acc_Grouping';
            insert acc;
            
            //Creating opportunity below
            Opportunity opp = new Opportunity();
            opp.Name='opp1';
            opp.AccountId=acc.Id;
            opp.CloseDate = System.today();
            opp.StageName='Needs Analysis';
            opp.Pricebook2Id=Test.getStandardPricebookId();
            insert opp;
            
            Quote offerQuote = new Quote();
            offerQuote.Name='Test Quote';
            offerQuote.status = 'Draft';
            offerQuote.opportunityId = opp.id;
            offerQuote.Pricebook2ID = stdPriceBookRecId;
            offerQuote.TeliaSE_Approval_Flag__c = false; 
            offerQuote.TeliaSE_Offer__c='Bredband Plus,Telia Datanet,Bredband Pro,Bredband Start,VPN SD-WAN,VPN WIFI';
            insert offerQuote;
            
            Product2 prod = new Product2();
            prod.name = 'Access Multi 10 Mbit/s';
            prod.productCode = 'CO-DATANET-ACCESS-MULTI-10MB';
            prod.TeliaSE_OfferTemplateFlag__c=true;
            prod.TeliaSE_TemplateCategory__c='CO_alone';
            prod.MC_Product_Name_Eng__c='Telia Datanet';
            insert prod;
            PricebookEntry objpricebookentry =new PricebookEntry();
            objpricebookentry.Product2ID = prod.id;            
            objpricebookentry.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry.UnitPrice=23.50;
            objpricebookentry.UseStandardPrice=false;
            objpricebookentry.isActive=true;//Add this line
            insert objpricebookentry;
            
            /*RecordType rec = new RecordType();
rec.Name='Ramavtal';
rec.IsActive = true;
insert rec;*/
            
            //Creating contract below
            /*Contract con=new Contract();
            con.Name='Test';
            con.Status='Active';
            con.Solution_Area__c='Vxl';
            con.StartDate=Date.today();
            con.ContractTerm=24;
            con.RecordType.Name = 'Ramavtal';
            insert con;*/
            
            
            Id stExam = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Ramavtal').getRecordTypeId();

            //Creating contract below
            Contract contract=new Contract();
            contract.Name='Test';
            contract.AccountId=acc.id;
            contract.Status='Draft';
            contract.Solution_Area__c='Vxl';
            contract.StartDate=Date.today();
            contract.ContractTerm=24;
            contract.RecordTypeId =stExam;
            insert contract;
            contract.status = 'Active';
            update contract;
            
            //Creating line items
            QuoteLineItem oli1 = new QuoteLineItem();
            oli1.PricebookEntryId = objpricebookentry.Id;
            oli1.TeliaSE_MC_Customer_Requested_Percentage__c=10;
            oli1.QuoteId = offerQuote.id;
            oli1.UnitPrice = 200;
            oli1.Quantity = 4;
            oli1.vlocity_cmt__Product2Id__c = prod.id;
            oli1.Product2Id = prod.id;
            oli1.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli1.TeliaSE_Approved__c = null;
            oli1.vlocity_cmt__RecurringCharge__c  = 200;
            oli1.TeliaSE_Ceiling_Price__c = 400;
            oli1.TeliaSE_Root_Product__c=prod.id;
            oli1.vlocity_cmt__ProductHierarchyPath__c = prod.id;
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
            oli1.vlocity_cmt__JSONAttribute__c = '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a367Z000000PDG0QAO","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_NEG_ROAMING_TILL","attributeconfigurable__c":true,"attributedisplaysequence__c":"90","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"MC Roaming Till AddOns","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5bQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Standard 89 kr, 49 kr, 19 kr","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"}],"values":[{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"},{"value":"69 kr, 49 kr, 19 kr","sequence":2,"id":"a63eccc4-e18f-75ec-42fb-2200074c064b","displayText":"69 kr, 49 kr, 19 kr"},{"value":"59 kr, 39 kr, 19 kr","sequence":3,"id":"f5f0a872-81aa-0e6d-69a5-cb7ed4d135dd","displayText":"59 kr, 39 kr, 19 kr"},{"value":"69 kr, 49 kr, 15 kr","sequence":4,"id":"e6cd61d3-92da-312e-a4b2-e70436ac950c","displayText":"69 kr, 49 kr, 15 kr"},{"value":"59 kr, 39 kr, 15 kr","sequence":5,"id":"e32ac4bd-6719-f23c-466b-738d35a2d65d","displayText":"59 kr, 39 kr, 15 kr"},{"value":"Europa - alla anv. 49 kr, 49 kr, 19 kr","sequence":6,"id":"ad9fcac8-bd33-8736-c1a2-3d18994136de","displayText":"Europa - alla anv. 49 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 39 kr, 49 kr, 19 kr","sequence":7,"id":"183b5d9d-f0d5-f30d-d58c-7a74b0a211c3","displayText":"Europa - alla anv. 39 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 29 kr, 49 kr, 19 kr","sequence":8,"id":"551aee5a-637e-9907-beed-05b0ec37b272","displayText":"Europa - alla anv. 29 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 0 kr, 49 kr, 19 kr","sequence":9,"id":"4d405be4-e94e-b0b5-314d-d4a27ba8f3cc","displayText":"Europa - alla anv. 0 kr, 49 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 29 kr, 19 kr","sequence":10,"id":"1ba0de8b-b225-49d5-c596-4874b84c4297","displayText":"Grannland - alla anv. 89 kr, 29 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 19 kr, 19 kr","sequence":11,"id":"789c7c6f-df0b-9c54-a865-f4d93215ca88","displayText":"Grannland - alla anv. 89 kr, 19 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 0 kr, 19 kr","sequence":12,"id":"d43f776a-90ac-2ccf-0dbb-a7a5b63f6eb8","displayText":"Grannland - alla anv. 89 kr, 0 kr, 19 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 12 kr","sequence":13,"id":"ccf729aa-485a-311b-a010-cd6727d8f27a","displayText":"Utland - alla anv. 89 kr, 49 kr, 12 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 12 kr","sequence":14,"id":"be39cb66-6a44-6372-d7bf-438f130eebc3","displayText":"Utland - alla anv. 69 kr, 39 kr, 12 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 9 kr","sequence":15,"id":"454ff5e3-64bb-ca6a-6af4-b9810ae53971","displayText":"Utland - alla anv. 89 kr, 49 kr, 9 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 9 kr","sequence":16,"id":"f8ad24c8-d0bf-b09b-06a3-55ccdfbb0c71","displayText":"Utland - alla anv. 69 kr, 39 kr, 9 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 0 kr","sequence":17,"id":"97d75109-a29f-8b72-96d0-e84149d77339","displayText":"Utland - alla anv. 89 kr, 49 kr, 0 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 0 kr","sequence":18,"id":"296f3be9-3b0e-3155-e177-2b1f466e9b56","displayText":"Utland - alla anv. 69 kr, 39 kr, 0 kr"},{"value":"Europa & Utland - alla anv.  49 kr, 49 kr, 12 kr","sequence":19,"id":"2eea7313-03cb-9da5-3741-48a98cd2636b","displayText":"Europa & Utland - alla anv.  49 kr, 49 kr, 12 kr"},{"value":"Europa & Utland - alla anv. 39 kr, 49 kr, 12 kr","sequence":20,"id":"e4b437ac-32bb-b61f-708a-43f3923d0723","displayText":"Europa & Utland - alla anv. 39 kr, 49 kr, 12 kr"},{"value":"Europa & Utland - alla anv. 29 kr, 49 kr, 9 kr","sequence":21,"id":"25190e10-0c3a-419f-7cd9-ed43fe36260c","displayText":"Europa & Utland - alla anv. 29 kr, 49 kr, 9 kr"},{"value":"Europa & Utland - alla anv. 0 kr, 49 kr, 0 kr","sequence":22,"id":"263d1bda-d9ae-d7ca-3f63-04093ff493da","displayText":"Europa & Utland - alla anv. 0 kr, 49 kr, 0 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 29 kr, 12 kr","sequence":23,"id":"c355e733-ee3c-6833-5aa4-c71196e19cdb","displayText":"Grannland & Utland - alla anv. 89 kr, 29 kr, 12 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 19 kr, 9 kr","sequence":24,"id":"23bd33c8-cd75-903a-d9cc-eb820e004ba6","displayText":"Grannland & Utland - alla anv. 89 kr, 19 kr, 9 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 0 kr, 0 kr","sequence":25,"id":"fe688552-297a-a1f2-5de1-3f2fd8c5b483","displayText":"Grannland & Utland - alla anv. 89 kr, 0 kr, 0 kr"}],"selectedItem":{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VknQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_PARENT","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Parent","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5dQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"All-In Plus"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VkqQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5aQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":"12 months","sequence":1,"id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","displayText":"12 months"},{"value":"24 months","sequence":2,"id":"aba9e042-0545-92b0-b0d0-16cd00888e83","displayText":"24 months"},{"value":"36 months","sequence":3,"id":"cbdeb314-b13b-d53d-72ec-8e4c3370b908","displayText":"36 months"}],"default":[],"selectedItem":{"value":"12 months","sequence":1,"id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","displayText":"12 months"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VktQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5cQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Single Value","value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Number","uiDisplayType":"Single Value","value":123},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VkuQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_SUB","attributeconfigurable__c":true,"attributedisplaysequence__c":"50","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Subsidized","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5eQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":"Yes","sequence":1,"id":"2b5df0d6-eb1a-e9fa-950f-d6ca7614ee1e","displayText":"Yes"},{"value":"No","sequence":2,"id":"67dda21b-85c6-ce74-2955-5094c85f021c","displayText":"No"}],"default":[],"selectedItem":{"value":"No","sequence":2,"id":"67dda21b-85c6-ce74-2955-5094c85f021c","displayText":"No"}},"$$AttributeDefinitionEnd$$":null}]}';
                oli1.RoamingResAddOns__c = '15 kr, 15 kr, 15 kr';
            oli1.RoamingTillAddOns__c = '69 kr, 49 kr, 15 kr';
            
            
            insert oli1;
            
            
            vlocity_cmt__ContractLineItem__c cli = new vlocity_cmt__ContractLineItem__c();
            cli.vlocity_cmt__ContractId__c = contract.Id;
            cli.vlocity_cmt__Product2Id__c = prod.Id;
            cli.TeliaSE_QuoteItemId__c = oli1.Id;
            cli.vlocity_cmt__QuoteLineItem__c = null;
            insert cli;
            
            
            
        }
        UpdateCLIBatchJob jobInst = new UpdateCLIBatchJob();
        Database.executeBatch(jobInst);
    }
    
}