@isTest
public with sharing class MC_CLIAgreementControlMigrateBatch_Test {
   @isTest
    public static void invokemethods()
    {
        User salesManager;        
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
       

        System.runAs(new User(Id = Userinfo.getUserId()))
        {
            salesManager = Test_DataFactory.createAdminUser();
            salesManager.Bypass_VR__c = true;
            salesManager.FirstName = 'TestRunUser';
            salesManager.IsActive = true;
            insert salesManager;
        }
        
        System.runAs(salesManager)
        {
                       
            
            vlocity_cmt__ObjectClass__c newObj=new vlocity_cmt__ObjectClass__c();
            newObj.Name = 'Mobile Offer Specification';
            newObj.vlocity_cmt__IsActive__c = true;
            newObj.vlocity_cmt__ObjectApiName__c ='Product2';
            insert newObj;
            
             Product2 prod = Test_DataFactory.createProducts(1)[0];
            prod.name = 'Mobile Total';
            prod.productCode = 'MOB_MULTI_TOTAL_V3';
            prod.vlocity_cmt__ObjectTypeId__c = newObj.Id;
           prod.family='Mobility Management';
            insert prod;
               Product2 prod1 = Test_DataFactory.createProducts(1)[0];
            prod1.name = 'Till Europa';
            prod1.productCode = 'MOB_CALL_TRAVEL_EUROPE';
            prod1.vlocity_cmt__ObjectTypeId__c = newObj.Id;
           prod1.family='Mobility Management';
            prod1.TeliaSE_Product_Category__c='F9UTLANDPP';
            //prod1.MC_Sales_FrameworkPriceEnabled__c=true;
            prod1.MC_Product_Negotiability__c = 'Framework';
            insert prod1;
              Product2 prod2 = Test_DataFactory.createProducts(1)[0];
            prod2.name = 'Res Söderut';
            prod2.productCode = 'MOB_CALL_TRAVEL_SOUTH';
            prod2.vlocity_cmt__ObjectTypeId__c = newObj.Id;
           prod2.family='Mobility Management';
            prod2.TeliaSE_Product_Category__c='A1VOICEROA';
            prod2.MC_Product_Negotiability__c = 'Framework';
            insert prod2;
             Product2 prod3 = Test_DataFactory.createProducts(1)[0];
            prod3.name = 'Jobbsurf 3 GB';
            prod3.productCode = 'MOB_SURF_3_V2';
            prod3.vlocity_cmt__ObjectTypeId__c = newObj.Id;
           // prod3.family='Mobility Management';
            prod3.TeliaSE_Product_Category__c='F5FAX/DATA';
            insert prod3;
            
            PricebookEntry objpricebookentry =new PricebookEntry();
            objpricebookentry.Product2ID = prod.id;            
            objpricebookentry.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry.UnitPrice=23.50;
            objpricebookentry.UseStandardPrice=false;
            objpricebookentry.isActive=true;//Add this line
            insert objpricebookentry;
             PricebookEntry objpricebookentry1 =new PricebookEntry();
            objpricebookentry1.Product2ID = prod1.id;            
            objpricebookentry1.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry1.UnitPrice=23.50;
            objpricebookentry1.UseStandardPrice=false;
            objpricebookentry1.isActive=true;//Add this line
            insert objpricebookentry1;
             PricebookEntry objpricebookentry2 =new PricebookEntry();
            objpricebookentry2.Product2ID = prod2.id;            
            objpricebookentry2.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry2.UnitPrice=23.50;
            objpricebookentry2.UseStandardPrice=false;
            objpricebookentry2.isActive=true;//Add this line
            insert objpricebookentry2;
            PricebookEntry objpricebookentry3 =new PricebookEntry();
            objpricebookentry3.Product2ID = prod3.id;            
            objpricebookentry3.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry3.UnitPrice=23.50;
            objpricebookentry3.UseStandardPrice=false;
            objpricebookentry3.isActive=true;//Add this line
            insert objpricebookentry3;

            
             
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
            
            
            
             
            //Creating contract below
            /*Contract contract=new Contract();
            contract.Name='Test';
            contract.AccountId=acc.id;
            contract.Status='Active';
            contract.Solution_Area__c='Vxl';
            contract.StartDate=Date.today();
            contract.ContractTerm=24;
            //contract.Contract_Record_Type__c='Ramavtal';
            insert contract;*/
            
            
            list<recordtype> offerQuoteRecId = [SELECT Id FROM recordtype where DeveloperName = 'Offer' AND SobjectType = 'Quote' limit 1];
            list<recordtype> faQuoteRecId = [SELECT Id FROM recordtype where DeveloperName = 'Contract' AND SobjectType = 'Quote' limit 1];
             list<recordtype> contractRecordType = [SELECT Id FROM recordtype where DeveloperName = 'TeliaSE_Framework_Agreement' AND SobjectType = 'Contract' limit 1];

             //Create FA quote
            Quote faQuote = new Quote();
            faQuote.Name='Test Quote';
            faQuote.status = 'Draft';
            faQuote.TeliaSE_Type__c='Renegotiation';
            faQuote.opportunityId = opp.id;
            faQuote.Pricebook2ID = stdPriceBookRecId;
            faQuote.TeliaSE_Approval_Flag__c = true; 
            faQuote.RecordTypeId = id.valueof((string)faQuoteRecId[0].get('id'));
            faQuote.TeliaSE_MC_Sales_Flow_Identifier__c = 'New Sales';
            //faQuote.Quote_Status__c='Draft';
            insert faQuote;
            /*contract.vlocity_cmt__QuoteId__c = faQuote.id;
            contract.RecordTypeId=id.valueof((string)contractRecordType[0].get('id'));
            update contract;*/
             String jsonAttrib ='{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t5E000007gw9YQAQ","attributeid__c":"a363E0000005VkcQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_ABR_CALL_DISC","attributeconfigurable__c":true,"attributedisplaysequence__c":"100","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Abroad Call Discount","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a335E000000UutuQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"displayText":"0%","id":"98f28bc0-ba05-7b3b-1929-5bc9f9dd2406","sequence":1,"value":"0%"},{"displayText":"10%","id":"ca1c01f3-c29b-6402-3d24-71901524a49e","sequence":2,"value":"10%"},{"displayText":"20%","id":"73edc571-d3e5-8530-16f2-5bc2883c6a46","sequence":3,"value":"20%"},{"displayText":"30%","id":"98f3989a-3b75-3f7d-8e81-2c86189bf90d","sequence":4,"value":"30%"},{"displayText":"40%","id":"8c2a3248-0048-1176-6c6e-049654492af9","sequence":5,"value":"40%"}],"default":[],"selectedItem":{}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t5E000007gw9YQAQ","attributeid__c":"a363E0000005VkdQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_BAS_PRICEPLAN_CAT","attributeconfigurable__c":true,"attributedisplaysequence__c":"60","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Datapaket för Bas","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a335E000000UutzQAC","isrequired__c":true,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"displayText":"Surf 3GB@109kr","id":"6431fb96-908c-205e-4033-90c8282abf3f","sequence":5,"value":"Surf 3GB@109kr"},{"displayText":"Surf 3GB@99kr","id":"6535456a-5ac7-e9bb-eed9-71e38f37c885","sequence":7,"value":"Surf 3GB@99kr"},{"displayText":"Surf 3GB@89kr","id":"6b49a0ea-02b0-60d6-530e-7fc7d76fc557","sequence":9,"value":"Surf 3GB@89kr"},{"displayText":"Surf 3GB@79kr","id":"9587c506-bd7d-25ed-75a0-5247ee7155be","sequence":11,"value":"Surf 3GB@79kr"},{"displayText":"Surf 3GB@69kr","id":"31277aaa-ffcb-9006-718c-b3e5c2503d16","sequence":12,"value":"Surf 3GB@69kr"}],"default":[],"selectedItem":{"displayText":"Surf 3GB@89kr","id":"6b49a0ea-02b0-60d6-530e-7fc7d76fc557","sequence":9,"value":"Surf 3GB@89kr"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t5E000007gw9YQAQ","attributeid__c":"a367Z000000PDFzQAO","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_NEG_ROAMING_RES","attributeconfigurable__c":true,"attributedisplaysequence__c":"91","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Res Söderut, Res Västerut, och Res Österut","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a335E000000Uuu4QAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"AM : 19 kr, 19 kr, 19 kr","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"AM : 19 kr, 19 kr, 19 kr","sequence":1,"id":"143032da-37b3-c5ec-af7f-64c34ac0454a","displayText":"AM : 19 kr, 19 kr, 19 kr"}],"values":[{"value":"AM : 19 kr, 19 kr, 19 kr","sequence":1,"id":"143032da-37b3-c5ec-af7f-64c34ac0454a","displayText":"AM : 19 kr, 19 kr, 19 kr"},{"value":"SM : 15 kr, 15 kr, 15 kr","sequence":2,"id":"48550f57-a0f1-f0e7-a95d-f5118291bcc6","displayText":"SM : 15 kr, 15 kr, 15 kr"},{"value":"SM : 10 kr, 10 kr, 10 kr","sequence":3,"id":"daa79e32-0c91-b449-12f9-5b1e9462336d","displayText":"SM : 10 kr, 10 kr, 10 kr"},{"value":"SD : Alla användare, alla tjänster. [5 kr, 5 kr, 5 kr]","sequence":4,"id":"ea4adb3c-8605-824a-b737-0cfea76b87f1","displayText":"SD : Alla användare, alla tjänster. [5 kr, 5 kr, 5 kr]"},{"value":"CM : Alla användare, alla tjänster. [0 kr, 0 kr, 0 kr]","sequence":5,"id":"8cb612bc-5bb4-d606-7193-282affd20504","displayText":"CM : Alla användare, alla tjänster. [0 kr, 0 kr, 0 kr]"}],"selectedItem":{"value":"AM : 19 kr, 19 kr, 19 kr","sequence":1,"id":"143032da-37b3-c5ec-af7f-64c34ac0454a","displayText":"AM : 19 kr, 19 kr, 19 kr"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t5E000007gw9YQAQ","attributeid__c":"a367Z000000PDG0QAO","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_NEG_ROAMING_TILL","attributeconfigurable__c":true,"attributedisplaysequence__c":"90","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Till Europa, Till Grannland Företag, och Till Utland Företag","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a335E000000UuuJQAS","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"AM : 89 kr, 49 kr, 19 kr","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"displayText":"AM : 89 kr, 49 kr, 19 kr","id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","sequence":1,"value":"AM : 89 kr, 49 kr, 19 kr"}],"values":[{"displayText":"AM : 89 kr, 49 kr, 19 kr","id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","sequence":1,"value":"AM : 89 kr, 49 kr, 19 kr"},{"displayText":"SM : 59 kr, 39 kr, 19 kr","id":"f5f0a872-81aa-0e6d-69a5-cb7ed4d135dd","sequence":3,"value":"SM : 59 kr, 39 kr, 19 kr"},{"displayText":"SM : 59 kr, 39 kr, 15 kr","id":"e32ac4bd-6719-f23c-466b-738d35a2d65d","sequence":5,"value":"SM : 59 kr, 39 kr, 15 kr"},{"displayText":"SM : 69 kr, 49 kr, 19 kr","id":"6f7f368f-45ac-42f1-96dc-fd2f2150f33a","sequence":6,"value":"SM : 69 kr, 49 kr, 19 kr"},{"displayText":"SD : Europa - alla anv. [49 kr, 49 kr, 19 kr]","id":"ad9fcac8-bd33-8736-c1a2-3d18994136de","sequence":6,"value":"SD : Europa - alla anv. [49 kr, 49 kr, 19 kr]"},{"displayText":"SM : 69 kr, 49 kr, 15 kr","id":"a4fdeaee-1074-5189-ddfd-712b184e7c37","sequence":7,"value":"SM : 69 kr, 49 kr, 15 kr"},{"displayText":"SD : Europa - alla anv. [39 kr, 49 kr, 19 kr]","id":"183b5d9d-f0d5-f30d-d58c-7a74b0a211c3","sequence":7,"value":"SD : Europa - alla anv. [39 kr, 49 kr, 19 kr]"},{"displayText":"SD : Europa - alla anv. [29 kr, 49 kr, 19 kr]","id":"551aee5a-637e-9907-beed-05b0ec37b272","sequence":8,"value":"SD : Europa - alla anv. [29 kr, 49 kr, 19 kr]"},{"displayText":"CM : Europa - alla anv. [0 kr, 49 kr, 19 kr]","id":"4d405be4-e94e-b0b5-314d-d4a27ba8f3cc","sequence":9,"value":"CM : Europa - alla anv. [0 kr, 49 kr, 19 kr]"},{"displayText":"SD : Grannland - alla anv. [89 kr, 29 kr, 19 kr]","id":"1ba0de8b-b225-49d5-c596-4874b84c4297","sequence":10,"value":"SD : Grannland - alla anv. [89 kr, 29 kr, 19 kr]"},{"displayText":"SD : Grannland - alla anv. [89 kr, 19 kr, 19 kr]","id":"789c7c6f-df0b-9c54-a865-f4d93215ca88","sequence":11,"value":"SD : Grannland - alla anv. [89 kr, 19 kr, 19 kr]"},{"displayText":"CM : Grannland - alla anv. [89 kr, 0 kr, 19 kr]","id":"d43f776a-90ac-2ccf-0dbb-a7a5b63f6eb8","sequence":12,"value":"CM : Grannland - alla anv. [89 kr, 0 kr, 19 kr]"},{"displayText":"SD : Utland - alla anv. [69 kr, 39 kr, 9 kr]","id":"19ea1921-cafb-b39d-ec65-ab6c2470dc11","sequence":14,"value":"SD : Utland - alla anv. [69 kr, 39 kr, 9 kr]"},{"displayText":"SD : Utland - alla anv. [89 kr, 49 kr, 9 kr]","id":"be39cb66-6a44-6372-d7bf-438f130eebc3","sequence":14,"value":"SD : Utland - alla anv. [89 kr, 49 kr, 9 kr]"},{"displayText":"SD : Utland - alla anv. [89 kr, 49 kr, 0 kr]","id":"454ff5e3-64bb-ca6a-6af4-b9810ae53971","sequence":15,"value":"SD : Utland - alla anv. [89 kr, 49 kr, 0 kr]"},{"displayText":"SD : Utland - alla anv. [69 kr, 39 kr, 12 kr]","id":"e29a3e9f-2db7-3ab0-277d-7f367c7ad038","sequence":17,"value":"SD : Utland - alla anv. [69 kr, 39 kr, 12 kr]"},{"displayText":"SD : Utland - alla anv. [89 kr, 49 kr, 12 kr]","id":"f1ef630f-2a9c-9b94-f60b-c78eb4838f99","sequence":18,"value":"SD : Utland - alla anv. [89 kr, 49 kr, 12 kr]"},{"displayText":"SD : Europa & Utland - alla anv. [29 kr, 49 kr, 9 kr]","id":"296f3be9-3b0e-3155-e177-2b1f466e9b56","sequence":18,"value":"SD : Europa & Utland - alla anv. [29 kr, 49 kr, 9 kr]"},{"displayText":"SD : Utland - alla anv. [69 kr, 39 kr, 0 kr]","id":"1285c1df-a628-596a-6714-8cb8ad430326","sequence":19,"value":"SD : Utland - alla anv. [69 kr, 39 kr, 0 kr]"},{"displayText":"CM : Europa & Utland - alla anv. [0 kr, 49 kr, 0 kr]","id":"2eea7313-03cb-9da5-3741-48a98cd2636b","sequence":19,"value":"CM : Europa & Utland - alla anv. [0 kr, 49 kr, 0 kr]"},{"displayText":"SD : Grannland & Utland - alla anv. [89 kr, 19 kr, 9 kr]","id":"25190e10-0c3a-419f-7cd9-ed43fe36260c","sequence":21,"value":"SD : Grannland & Utland - alla anv. [89 kr, 19 kr, 9 kr]"},{"displayText":"SD : Europa & Utland - alla anv.  [49 kr, 49 kr, 12 kr]","id":"98237ae2-732d-d588-66cf-8d75177e88a9","sequence":22,"value":"SD : Europa & Utland - alla anv.  [49 kr, 49 kr, 12 kr]"},{"displayText":"SD : Europa & Utland - alla anv. [39 kr, 49 kr, 12 kr]","id":"5f5bddd6-969a-2ae1-bdc6-6fb564496526","sequence":23,"value":"SD : Europa & Utland - alla anv. [39 kr, 49 kr, 12 kr]"},{"displayText":"SD : Grannland & Utland - alla anv. [89 kr, 29 kr, 12 kr]","id":"c355e733-ee3c-6833-5aa4-c71196e19cdb","sequence":23,"value":"SD : Grannland & Utland - alla anv. [89 kr, 29 kr, 12 kr]"},{"displayText":"CM : Grannland & Utland - alla anv. [89 kr, 0 kr, 0 kr]","id":"dd5f0a1a-922b-972e-bc15-1fbc36fbb0eb","sequence":24,"value":"CM : Grannland & Utland - alla anv. [89 kr, 0 kr, 0 kr]"}],"selectedItem":{"displayText":"AM : 89 kr, 49 kr, 19 kr","id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","sequence":1,"value":"AM : 89 kr, 49 kr, 19 kr"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t5E000007gw9YQAQ","attributeid__c":"a363E0000005VkpQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_QUARANTINE_PERIOD","attributeconfigurable__c":true,"attributedisplaysequence__c":"40","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Tid för att uppfylla basnivå","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":3,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a335E000000NIU4QAO","isrequired__c":true,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"3","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"displayText":"3 månader","id":"7e2d3a6a-20e4-1eca-684d-d2302218d798","sequence":10,"value":"3"}],"values":[{"displayText":"3 månader","id":"7e2d3a6a-20e4-1eca-684d-d2302218d798","sequence":10,"value":"3"},{"displayText":"6 månader","id":"872b31b5-0782-c189-583f-13eade73dee5","sequence":20,"value":"6"}],"selectedItem":{"displayText":"3 månader","id":"7e2d3a6a-20e4-1eca-684d-d2302218d798","sequence":10,"value":"3"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t5E000007gw9YQAQ","attributeid__c":"a363E0000005VksQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_MINC","attributeconfigurable__c":true,"attributedisplaysequence__c":"30","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Basnivå (%)","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":75,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a335E000000Uuv2QAC","isrequired__c":true,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"75","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"75","sequence":1,"id":"aec826dc-a3fd-6d83-8910-7f8da79f8615","displayText":"75%"}],"values":[{"value":"75","sequence":1,"id":"aec826dc-a3fd-6d83-8910-7f8da79f8615","displayText":"75%"},{"value":"50","sequence":2,"id":"fde6a488-a095-8c45-c80c-9f419a1c9c12","displayText":"50%"},{"value":"0","sequence":3,"id":"0890f600-a12e-a509-9e4f-ce9aacfb255a","displayText":"0%"}],"selectedItem":{"value":"75","sequence":1,"id":"aec826dc-a3fd-6d83-8910-7f8da79f8615","displayText":"75%"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t5E000007gw9YQAQ","attributeid__c":"a363E0000005VknQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_PARENT","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Parent","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a335E000000UutfQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"Total","valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"Total","value":"Total"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t5E000007gw9YQAQ","attributeid__c":"a363E0000005VkqQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Avtalstid","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a335E000000UutpQAC","isrequired__c":true,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"displayText":"12 months","id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","sequence":1,"value":"12 months"},{"displayText":"24 months","id":"aba9e042-0545-92b0-b0d0-16cd00888e83","sequence":2,"value":"24 months"},{"displayText":"36 months","id":"cbdeb314-b13b-d53d-72ec-8e4c3370b908","sequence":3,"value":"36 months"}],"default":[],"selectedItem":{"displayText":"24 months","id":"aba9e042-0545-92b0-b0d0-16cd00888e83","sequence":2,"value":"24 months"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t5E000007gw9YQAQ","attributeid__c":"a363E0000005VktQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Antal för basnivå","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a335E000000UutLQAS","isrequired__c":true,"rulemessage__c":null,"uidisplaytype__c":"Single Value","value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Number","uiDisplayType":"Single Value","value":212},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t5E000007gw9YQAQ","attributeid__c":"a363E0000005VkuQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_SUB","attributeconfigurable__c":true,"attributedisplaysequence__c":"50","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Subventionerat","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a335E000000Uuu9QAC","isrequired__c":true,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"displayText":"Yes","id":"2b5df0d6-eb1a-e9fa-950f-d6ca7614ee1e","sequence":1,"value":"Yes"},{"displayText":"No","id":"67dda21b-85c6-ce74-2955-5094c85f021c","sequence":2,"value":"No"}],"default":[],"selectedItem":{"displayText":"Yes","id":"2b5df0d6-eb1a-e9fa-950f-d6ca7614ee1e","sequence":1,"value":"Yes"}},"$$AttributeDefinitionEnd$$":null}]}';
           MC_Sales_FrameworkProductCategoryMaster__c pct=new MC_Sales_FrameworkProductCategoryMaster__c();
            pct.Name='F5FAX/DATA';
            pct.MC_Sales_Product_Codes__c='MOB_SURF_BAS_V2;MOB_SURF_1_V2;MOB_SURF_3_V2;MOB_SURF_5_V2;MOB_SURF_15_V2;MOB_SURF_25_V2;MOB_SURF_40_V2;MOB_SURF_120_V2';
            insert pct;
            MC_Sales_FrameworkPricePlanMaster__c  ppm=new MC_Sales_FrameworkPricePlanMaster__c();
            ppm.Name='0,55,79,99,149,189,229,289';
            ppm.MC_Sales_StartDate__c=Date.valueOf('2022-01-03');
            ppm.MC_Sales_Product_Category_Master__c=pct.id;
            ppm.MC_Agreement_Control_Service__c='Optional;Optional;Optional';
            insert ppm;
            MC_Sales_FrameworkPricingMaster__c fpm=new MC_Sales_FrameworkPricingMaster__c();
            fpm.MC_Sales_Approver_Level__c='1';
            fpm.MC_Sales_Cluster__c='ALL';
            fpm.MC_Sales_Commitment_Period__c='ALL';
            fpm.MC_Sales_Customer_Segment__c='ALL';
            fpm.MC_Sales_Default_Price_Plan__c=true;
            fpm.MC_Sales_High_Base_Quantity__c=9999;
                fpm.MC_Sales_Low_Base_Quantity__c=1;
            fpm.MC_Sales_Object_Type__c='Mobile Offer Specification';
            fpm.MC_Sales_Parent__c='MOB_MULTI_TOTAL_V3';
            fpm.MC_Sales_FrameworkPricePlanMaster__c=ppm.id;
            fpm.MC_Sales_FrameworkProductCategoryMaster__c=pct.id;
            insert fpm;

                 QuoteLineItem oli1 = new QuoteLineItem();
            oli1.PricebookEntryId = objpricebookentry.Id;
            oli1.TeliaSE_MC_Customer_Requested_Percentage__c=10;
            oli1.QuoteId = faQuote.id;
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
            oli1.TeliaSE_CommitmentPeriod__c = '24 months';
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
            oli1.RoamingResAddOns__c = '15 kr, 15 kr, 15 kr';
            oli1.RoamingTillAddOns__c = '69 kr, 49 kr, 15 kr';
            oli1.TeliaSE_PriceTypeCategory__c='Surf 3GB@99kr';
            oli1.MC_Sales_FrameworkPricingMaster__c=null;
            insert oli1;
            QuoteLineItem oli12 = new QuoteLineItem();
            oli12.PricebookEntryId = objpricebookentry1.Id;
            oli12.TeliaSE_MC_Customer_Requested_Percentage__c=10;
            oli12.QuoteId = faQuote.id;
            oli12.UnitPrice = 200;
            oli12.Quantity = 4;
            oli12.vlocity_cmt__Product2Id__c = prod1.id;
            oli12.Product2Id = prod1.id;
            oli12.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli12.TeliaSE_Approved__c = null;
            oli12.vlocity_cmt__RecurringCharge__c  = 200;
            oli12.TeliaSE_Ceiling_Price__c = 400;
            oli12.TeliaSE_Root_Product__c=prod1.id;
            oli12.vlocity_cmt__RootItemId__c=oli1.id;
          //  oli12.vlocity_cmt__ProductHierarchyPath__c = prod.id;
            oli12.TeliaSE_Base_Quantity__c = '123';
            oli12.vlocity_cmt__OneTimeCharge__c = 200;
            oli12.MC_OT_AM_Mandate_Percentage__c = 10;
            oli12.MC_OT_SM_Mandate_Percentage__c = 10;
            oli12.MC_OT_SD_Mandate_Percentage__c = 10;
            oli12.MC_OT_CM_Mandate_Percentage__c = 10;
            oli12.TeliaSE_AM_Mandate_Percentage__c = 10;
            oli12.TeliaSE_SM_Mandate_Percentage__c = 10;
            oli12.TeliaSE_SD_Mandate_Percentage__c = 10;
            oli12.TeliaSE_CM_Mandate_Percentage__c = 10;
            oli12.vlocity_cmt__JSONAttribute__c = jsonAttrib;
           // oli12.RoamingResAddOns__c = '15 kr, 15 kr, 15 kr';
            oli12.RoamingTillAddOns__c = '69 kr, 49 kr, 15 kr';
           oli12.MC_Sales_FrameworkPricingMaster__c=fpm.Id;
            //oli12.MC_Sales_FrameworkPriceEnabled__c=true;
            //oli12.Quote_Status__c='Draft';
               insert oli12;
               QuoteLineItem oli123 = new QuoteLineItem();
            oli123.PricebookEntryId = objpricebookentry2.Id;
            oli123.TeliaSE_MC_Customer_Requested_Percentage__c=10;
            oli123.QuoteId = faQuote.id;
            oli123.UnitPrice = 200;
            oli123.Quantity = 4;
            oli123.vlocity_cmt__Product2Id__c = prod2.id;
            oli123.Product2Id = prod2.id;
            oli123.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli123.TeliaSE_Approved__c = null;
            oli123.vlocity_cmt__RecurringCharge__c  = 200;
            oli123.TeliaSE_Ceiling_Price__c = 400;
            oli123.TeliaSE_Root_Product__c=prod.id;
            oli123.vlocity_cmt__RootItemId__c=oli1.id;
          //  oli123.vlocity_cmt__ProductHierarchyPath__c = prod.id;
            oli123.TeliaSE_Base_Quantity__c = '123';
            oli123.vlocity_cmt__OneTimeCharge__c = 200;
            oli123.MC_OT_AM_Mandate_Percentage__c = 10;
            oli123.MC_OT_SM_Mandate_Percentage__c = 10;
            oli123.MC_OT_SD_Mandate_Percentage__c = 10;
            oli123.MC_OT_CM_Mandate_Percentage__c = 10;
            oli123.TeliaSE_AM_Mandate_Percentage__c = 10;
            oli123.TeliaSE_SM_Mandate_Percentage__c = 10;
            oli123.TeliaSE_SD_Mandate_Percentage__c = 10;
            oli123.TeliaSE_CM_Mandate_Percentage__c = 10;
            oli123.vlocity_cmt__JSONAttribute__c = jsonAttrib;
            oli123.RoamingResAddOns__c = '15 kr, 15 kr, 15 kr';
           // oli123.RoamingTillAddOns__c = '69 kr, 49 kr, 15 kr';
         //oli123.MC_Sales_FrameworkPricingMaster__c=null;
            oli12.MC_Sales_FrameworkPricingMaster__c=fpm.Id;
            insert oli123;
     QuoteLineItem oli1234 = new QuoteLineItem();
            oli1234.PricebookEntryId = objpricebookentry3.Id;
            oli1234.TeliaSE_MC_Customer_Requested_Percentage__c=10;
            oli1234.QuoteId = faQuote.id;
            oli1234.UnitPrice = 200;
            oli1234.Quantity = 4;
            oli1234.vlocity_cmt__Product2Id__c = prod3.id;
            oli1234.Product2Id = prod3.id;
            oli1234.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli1234.TeliaSE_Approved__c = null;
            oli1234.vlocity_cmt__RecurringCharge__c  = 200;
            oli1234.TeliaSE_Ceiling_Price__c = 400;
            oli1234.TeliaSE_Root_Product__c=prod.id;
            oli1234.vlocity_cmt__RootItemId__c=oli1.id;
          //  oli1234.vlocity_cmt__ProductHierarchyPath__c = prod.id;
            oli1234.TeliaSE_Base_Quantity__c = '123';
            oli1234.vlocity_cmt__OneTimeCharge__c = 200;
            oli1234.MC_OT_AM_Mandate_Percentage__c = 10;
            oli1234.MC_OT_SM_Mandate_Percentage__c = 10;
            oli1234.MC_OT_SD_Mandate_Percentage__c = 10;
            oli1234.MC_OT_CM_Mandate_Percentage__c = 10;
            oli1234.TeliaSE_AM_Mandate_Percentage__c = 10;
            oli1234.TeliaSE_SM_Mandate_Percentage__c = 10;
            oli1234.TeliaSE_SD_Mandate_Percentage__c = 10;
            oli1234.TeliaSE_CM_Mandate_Percentage__c = 10;
            oli1234.vlocity_cmt__JSONAttribute__c = jsonAttrib;
           // oli1234.RoamingResAddOns__c = '15 kr, 15 kr, 15 kr';
           // oli1234.RoamingTillAddOns__c = '69 kr, 49 kr, 15 kr';
            insert oli1234;
            //Creating contract below
            Contract contract=new Contract();
            contract.Name='Test';
            contract.AccountId=acc.id;
            contract.Status='Draft';
            contract.Solution_Area__c='Vxl';
            contract.StartDate=Date.today();
            contract.ContractTerm=24;
            contract.vlocity_cmt__QuoteId__c = faQuote.id;
            contract.RecordTypeId=id.valueof((string)contractRecordType[0].get('id'));
            //contract.Contract_Record_Type__c='Ramavtal';
            insert contract;
            contract.Status='Active';
            update contract;
            
            List<vlocity_cmt__ContractLineItem__c> cliList = new List<vlocity_cmt__ContractLineItem__c>();
            vlocity_cmt__ContractLineItem__c cli1 = new vlocity_cmt__ContractLineItem__c();
            cli1.vlocity_cmt__ContractId__c = [select id from contract where Name='Test'][0].id;
            cli1.vlocity_cmt__Product2Id__c = prod1.Id;
            cli1.Name ='Till Europa';
      //cli1.TeliaSE_Product_Object_Type__c='TouchPoint Plus Offer Spec';
            cli1.vlocity_cmt__LineStatus__c = 'Added';
      //cli1.vlocity_cmt__QuoteId__c=
            cli1.TeliaSE_Base_Quantity__c =5;
            cli1.vlocity_cmt__QuoteLineItem__c=oli12.id;
            cli1.vlocity_cmt__RecurringCharge__c = 35;
            cli1.MC_Agreement_Control_Service__c='';
            //cli1.vlocity_cmt__ProductCode__c='MOB_CALL_TRAVEL_EUROPE';
            cliList.add(cli1);
            vlocity_cmt__ContractLineItem__c cli2 = new vlocity_cmt__ContractLineItem__c();
            cli2.vlocity_cmt__ContractId__c = [select id from contract where Name='Test'][0].id;
            cli2.vlocity_cmt__Product2Id__c = prod2.Id;
            cli2.Name ='Till Europa';
      //cli1.TeliaSE_Product_Object_Type__c='TouchPoint Plus Offer Spec';
            cli2.vlocity_cmt__LineStatus__c = 'Added';
      //cli1.vlocity_cmt__QuoteId__c=
            cli2.TeliaSE_Base_Quantity__c =5;
            cli2.vlocity_cmt__QuoteLineItem__c=oli123.id;
            cli2.vlocity_cmt__RecurringCharge__c = 35;
            cli2.MC_Agreement_Control_Service__c='';
            //cli1.vlocity_cmt__ProductCode__c='MOB_CALL_TRAVEL_EUROPE';
            cliList.add(cli2);
            /*
            vlocity_cmt__ContractLineItem__c cli2 = new vlocity_cmt__ContractLineItem__c();
            cli2.vlocity_cmt__ContractId__c = contract.id;
            cli2.vlocity_cmt__Product2Id__c = prod1.Id;
            cli2.Name ='Datanet';

            cli2.vlocity_cmt__AttributesData__c = '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t3N000004mRRoQAM","attributeid__c":"a363N000000BLlXQAW","attributecategoryid__c":"a353N000000cZcpQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_OCN_DISCOUNT","attributeconfigurable__c":true,"attributedisplaysequence__c":"40","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Rabatt på externa stadsnät","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a333N000000E4KLQA0","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"displayText":"0 SEK/Month","id":"30918e08-0d89-5a02-0ccb-6359b19c9345","sequence":1,"value":"0"},{"displayText":"50 SEK/Month","id":"ffc27328-5fba-e5ce-63b4-95e1e3860a2a","sequence":2,"value":"50"},{"displayText":"100 SEK/Month","id":"67ea517b-e408-57da-652f-12242ecff251","sequence":3,"value":"100"},{"displayText":"150 SEK/Month","id":"f28e74cd-7869-cb44-88fe-63c68e61e856","sequence":4,"value":"150"},{"displayText":"200 SEK/Month","id":"a039de78-b8a4-eeef-229e-7d529d223e6a","sequence":5,"value":"200"}],"default":[],"selectedItem":{"displayText":"50 SEK/Month","id":"ffc27328-5fba-e5ce-63b4-95e1e3860a2a","sequence":2,"value":"50"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"a4s3N0000004bUoQAI","attributeid__c":"a363N000000BLfPQAW","attributecategoryid__c":"a353N000000cZcpQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_PRICE_ATTR","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"CO Price Attribute","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a333N000000E2UgQAK","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"CO","valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"CO","value":"CO"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t3N000004mRRoQAM","attributeid__c":"a363N000000BKoqQAG","attributecategoryid__c":"a353N000000cZcpQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Avtalstid","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a333N000000E4KJQA0","isrequired__c":true,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"displayText":"12 months","id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","sequence":1,"value":"12 months"},{"displayText":"24 months","id":"aba9e042-0545-92b0-b0d0-16cd00888e83","sequence":2,"value":"24 months"},{"displayText":"36 months","id":"cbdeb314-b13b-d53d-72ec-8e4c3370b908","sequence":3,"value":"36 months"}],"default":[],"selectedItem":{"displayText":"24 months","id":"aba9e042-0545-92b0-b0d0-16cd00888e83","sequence":2,"value":"24 months"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t3N000004mRRoQAM","attributeid__c":"a363N000000BKotQAG","attributecategoryid__c":"a353N000000cZcpQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Total antal siter","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a333N000000E4KMQA0","isrequired__c":true,"rulemessage__c":null,"uidisplaytype__c":"Single Value","value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Number","uiDisplayType":"Single Value","value":500},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t3N000004mRRoQAM","attributeid__c":"a363N000000BKrkQAG","attributecategoryid__c":"a353N000000cZcpQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_PRECHECK","attributeconfigurable__c":true,"attributedisplaysequence__c":"50","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"MC PreCheck Flag","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a333N000000E4KKQA0","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":"false","valuedatatype__c":"Checkbox","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Checkbox","default":false,"value":false},"$$AttributeDefinitionEnd$$":null}]}';

            cli2.TeliaSE_Product_Object_Type__c=newObj1.Name;
            cli2.TeliaSE_Base_Quantity__c =5;
            cli2.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli2);
            
            vlocity_cmt__ContractLineItem__c cli3 = new vlocity_cmt__ContractLineItem__c();
            cli3.vlocity_cmt__ContractId__c = contract.id;
            cli3.vlocity_cmt__Product2Id__c = prod7.Id;
            cli3.Name ='Användarpaket';
            cli3.TeliaSE_Product_Object_Type__c=newObj2.Name;
            cli3.TeliaSE_Base_Quantity__c =5;
            cli3.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli3);
            
            vlocity_cmt__ContractLineItem__c cli4 = new vlocity_cmt__ContractLineItem__c();
            cli4.vlocity_cmt__ContractId__c = contract.id;
            cli4.vlocity_cmt__Product2Id__c = prod8.Id;
            cli4.Name ='Svarsservice 20';
            cli4.vlocity_cmt__QuoteLineItem__c = oli3.Id;
            cli4.vlocity_cmt__LineStatus__c = 'Updated';
            cli4.TeliaSE_Product_Object_Type__c=newObj2.Name;
            cli4.TeliaSE_Base_Quantity__c =5;
            cli4.vlocity_cmt__OneTimeCharge__c = 200;
            cli4.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli4);
            

            vlocity_cmt__ContractLineItem__c cli5 = new vlocity_cmt__ContractLineItem__c();
            cli5.vlocity_cmt__ContractId__c = contract.id;
            cli5.vlocity_cmt__Product2Id__c = prod12.Id;
            cli5.Name ='Jobbmobil 10 GB';
            cli5.vlocity_cmt__LineStatus__c = 'Updated';
            cli5.TeliaSE_Product_Object_Type__c=newObj8.Name;
            cli5.TeliaSE_Base_Quantity__c =5;
            cli5.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli5);
            
            vlocity_cmt__ContractLineItem__c cli6 = new vlocity_cmt__ContractLineItem__c();
            cli6.vlocity_cmt__ContractId__c = contract.id;
            cli6.vlocity_cmt__Product2Id__c = prod13.Id;
            cli6.Name ='Smart Connect Standardanvändare';
            cli6.vlocity_cmt__LineStatus__c = 'Updated';
            cli6.TeliaSE_Product_Object_Type__c=newObj9.Name;
            cli6.TeliaSE_Base_Quantity__c =5;
            cli6.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli6);
            
            vlocity_cmt__ContractLineItem__c cli7 = new vlocity_cmt__ContractLineItem__c();
            cli7.vlocity_cmt__ContractId__c = contract.id;
            cli7.vlocity_cmt__Product2Id__c = prod14.Id;
            cli7.Name ='Smart Connect';
            cli7.vlocity_cmt__LineStatus__c = 'Updated';
            cli7.TeliaSE_Product_Object_Type__c=newObj9.Name;
            cli7.TeliaSE_Base_Quantity__c =5;
            cli7.TeliaSE_ParentClusterCode__c='SC_KLU_BAS';
            cli7.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli7);
            
            vlocity_cmt__ContractLineItem__c cli8 = new vlocity_cmt__ContractLineItem__c();
            cli8.vlocity_cmt__ContractId__c = contract.id;
            cli8.vlocity_cmt__Product2Id__c = prod15.Id;
            cli8.Name ='Kluster BAS';
            cli8.vlocity_cmt__LineStatus__c = 'Added';
            cli8.TeliaSE_Product_Object_Type__c=newObj10.Name;
            cli8.TeliaSE_Base_Quantity__c =5;
            cli8.vlocity_cmt__RecurringCharge__c = 0;
            cliList.add(cli8);
            
            vlocity_cmt__ContractLineItem__c cli9 = new vlocity_cmt__ContractLineItem__c();
            cli9.vlocity_cmt__ContractId__c = contract.id;
            cli9.vlocity_cmt__Product2Id__c = prod14.Id;
            cli9.Name ='Smart Connect';
            cli9.vlocity_cmt__LineStatus__c = 'Updated';
            cli9.TeliaSE_Product_Object_Type__c=newObj9.Name;
            cli9.TeliaSE_Base_Quantity__c =5;
            cli9.TeliaSE_ParentClusterCode__c='SC_KLU_SMALL';
            cli9.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli9);
*/
            insert cliList;

        }
         List<vlocity_cmt__ContractLineItem__c> clisList=[select id,name,vlocity_cmt__ProductCode__c,vlocity_cmt__QuoteLineItem__r.MC_Sales_FrameworkPricingMaster__c,vlocity_cmt__ContractId__r.RecordType.name,vlocity_cmt__ContractId__c,MC_Agreement_Control_Service__c, TeliaSE_QuoteItemId__c,vlocity_cmt__QuoteLineItem__c,vlocity_cmt__QuoteLineItem__r.MC_Sales_FrameworkPricingMaster__r.MC_Sales_FrameworkPricePlanMaster__r.MC_Agreement_Control_Service__c
                                         from vlocity_cmt__ContractLineItem__c where  vlocity_cmt__ProductCode__c like 'MOB_CALL_TRAVEL%' and vlocity_cmt__Product2Id__r.Family <> 'Online Order' 
                                         and vlocity_cmt__ContractId__r.Status <>'Cancelled' and vlocity_cmt__ContractId__r.Status <>'Rejected' and vlocity_cmt__QuoteLineItem__c<>'' and vlocity_cmt__QuoteLineItem__r.Quote_Status__c <>'Cancelled' 
                                         and vlocity_cmt__QuoteLineItem__r.TeliaSE_Quote_RecordType__c ='Contract' and vlocity_cmt__ContractId__r.RecordType.Name='Ramavtal' and (vlocity_cmt__QuoteLineItem__r.vlocity_cmt__Product2Id__r.MC_Product_Negotiability__c ='Framework' or vlocity_cmt__QuoteLineItem__r.vlocity_cmt__Product2Id__r.MC_Product_Negotiability__c ='Hybrid') and vlocity_cmt__QuoteLineItem__r.MC_Sales_FrameworkPricingMaster__c <>'' and MC_Agreement_Control_Service__c=''];
         MC_CLIAgreementControlMigrateBatch jobInst = new MC_CLIAgreementControlMigrateBatch();
       Database.executeBatch(jobInst);
    }
  
    
}