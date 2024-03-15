@isTest
public class Test_TeliaSE_QuoteConfig{
    
    public static testmethod void invokeMethod(){
        User salesManager;         
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        
        System.runAs(new User(Id = Userinfo.getUserId())){
            salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManager.Bypass_VR__c = true;
            insert salesManager;
        }
        System.runAs(salesManager){
            List<Product2> prodList = new List<product2>();
            
            vlocity_cmt__ObjectClass__c objClass = new vlocity_cmt__ObjectClass__c();
            objClass.Name = 'Mobile Offer Specification';    
            objClass.vlocity_cmt__IsActive__c = True;
            objClass.vlocity_cmt__ObjectApiName__c = 'Product2';
            insert objClass;
            Product2 prod = Test_DataFactory.createProducts(1)[0];
            prod.vlocity_cmt__ObjectTypeId__c = objClass.Id;
            prod.ProductCode = 'MOB_MULTI';
            prodList.add(prod); 
            
            Product2 prod1 = Test_DataFactory.createProducts(1)[0];
            prod1.name = 'Data Paket (BAS)';
            prod1.productCode = 'MOB_DATA_PORTFOLIO';
            prodList.add(prod1);            
            
            Product2 prod2 = Test_DataFactory.createProducts(1)[0];
            prod2.Name = 'Jobbmobil Total';
            prod2.productCode = 'MOB_MULTI_TOTAL';
            prodList.add(prod2);
            
            insert prodList;
            
            pricebookId = stdPriceBookRecId ;
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
            objpricebookentry2.Product2ID = prod2.id;            
            objpricebookentry2.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry2.UnitPrice=23.50;
            objpricebookentry2.UseStandardPrice=false;
            objpricebookentry2.isActive=true;//Add this line
            pbeList.add(objpricebookentry2);
            
            insert pbeList;
            
            
            Opportunity opp = new Opportunity();
            opp.Name='opp1';
            opp.CloseDate = System.today();
            opp.StageName='Needs Analysis';  
            opp.Pricebook2Id=Test.getStandardPricebookId();
            opp.TeliaSE_SharingSetting_Flag__c = false;
            //opp.Type_of_Address__c = 'MDU';
            insert opp;
            
            Quote qut = new Quote();
            qut.Name='Test Quote';
            qut.status = 'Draft';
            
            qut.opportunityId = opp.id;
            qut.TeliaSE_Type__c='New';
            qut.Pricebook2ID = stdPriceBookRecId;
            qut.TeliaSE_Approval_Flag__c = False;        
            qut.TeliaSE_MC_Sales_Flow_Identifier__c='New Sales';
            insert qut;
            
            RecordType r = new RecordType();   
            r.Name = 'Discount';
            //insert r;
            
            RecordType rr = [select id, name from RecordType where Name='Discount'];
            
            vlocity_cmt__TimePlan__c timePlan = new vlocity_cmt__TimePlan__c();
            timePlan.Name = '3 Month';
            timePlan.vlocity_cmt__Description__c = 'new';
            insert timePlan;
            vlocity_cmt__Promotion__c campaign = new vlocity_cmt__Promotion__c();
            campaign.Name = '3 fria månader';
            campaign.MC_Product_Name_Eng__c = '3 Month Free';
            campaign.vlocity_cmt__Code__c='MOBILE_CAMPAIGN_DISC_100_3';
            campaign.RecordType = rr;
            campaign.TeliaSE_MC_Campaign_Type__c = 'New';
            campaign.vlocity_cmt__Duration__c = 3;
            campaign.vlocity_cmt__DiscountType__c = 'Contract';
            campaign.vlocity_cmt__DurationTimePlanId__c = timePlan.Id;
            insert campaign;
            
            list<QuoteLineItem> offerQLI = new list<QuoteLineItem>();
            QuoteLineItem oli1 = new QuoteLineItem();
            oli1.PricebookEntryId = objpricebookentry.Id;
            oli1.QuoteId = qut.id;
            oli1.UnitPrice = 200;
            oli1.Quantity = 4;
            oli1.TeliaSE_MC_Campaign_Id__c = campaign.Id;
            oli1.Product2Id = prod.id;
            oli1.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli1.TeliaSE_MC_Customer_Requested_Percentage__c = 5;
            oli1.TeliaSE_MC_Customer_Requested_Price__c = 150;
            oli1.TeliaSE_Approved__c = 1;
            oli1.TeliaSE_Approved_Price__c = 0;
            oli1.MC_OT_Approved_Price__c = 7;
            oli1.TeliaSE_Nullify_Check__c = true;
            oli1.vlocity_cmt__Product2Id__c = prod.id;
            oli1.vlocity_cmt__RootItemId__c = prod.id;
            //insert oli1;
            offerQLI.add(oli1);
            
            
            QuoteLineItem oli2 = new QuoteLineItem();
            oli2.PricebookEntryId = objpricebookentry1.Id;
            oli2.TeliaSE_MC_Customer_Requested_Percentage__c=10;
            oli2.QuoteId = qut.id;
            oli2.UnitPrice = 200;
            oli2.Quantity = 4;
            oli2.vlocity_cmt__Product2Id__c = prod1.id;
            oli2.Product2Id = prod.id;
            oli2.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli2.TeliaSE_Approved__c = null;
            oli2.vlocity_cmt__RecurringCharge__c  = 200;
            oli2.TeliaSE_Ceiling_Price__c = 400;
            oli2.MC_OT_Approved_Price__c = null;
            oli2.TeliaSE_Root_Product__c=prod1.id;
            oli2.vlocity_cmt__ProductHierarchyPath__c = prod1.id;
            oli2.TeliaSE_Base_Quantity__c = '123';
            oli2.vlocity_cmt__OneTimeCharge__c = 200;
            oli2.MC_OT_AM_Mandate_Percentage__c = 10;
            oli2.MC_OT_SM_Mandate_Percentage__c = 10;
            oli2.MC_OT_SD_Mandate_Percentage__c = 10;
            oli2.MC_OT_CM_Mandate_Percentage__c = 10;
            oli2.TeliaSE_AM_Mandate_Percentage__c = 10;
            oli2.TeliaSE_SM_Mandate_Percentage__c = 10;
            oli2.TeliaSE_SD_Mandate_Percentage__c = 10;
            oli2.TeliaSE_CM_Mandate_Percentage__c = 10;
            oli2.vlocity_cmt__AssetReferenceId__c='000ac887-f516-d356-7222-d1ee77a728b3';
            oli2.vlocity_cmt__JSONAttribute__c = '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a367Z000000PDG0QAO","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_NEG_ROAMING_TILL","attributeconfigurable__c":true,"attributedisplaysequence__c":"90","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"MC Roaming Till AddOns","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5bQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Standard 89 kr, 49 kr, 19 kr","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"}],"values":[{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"},{"value":"69 kr, 49 kr, 19 kr","sequence":2,"id":"a63eccc4-e18f-75ec-42fb-2200074c064b","displayText":"69 kr, 49 kr, 19 kr"},{"value":"59 kr, 39 kr, 19 kr","sequence":3,"id":"f5f0a872-81aa-0e6d-69a5-cb7ed4d135dd","displayText":"59 kr, 39 kr, 19 kr"},{"value":"69 kr, 49 kr, 15 kr","sequence":4,"id":"e6cd61d3-92da-312e-a4b2-e70436ac950c","displayText":"69 kr, 49 kr, 15 kr"},{"value":"59 kr, 39 kr, 15 kr","sequence":5,"id":"e32ac4bd-6719-f23c-466b-738d35a2d65d","displayText":"59 kr, 39 kr, 15 kr"},{"value":"Europa - alla anv. 49 kr, 49 kr, 19 kr","sequence":6,"id":"ad9fcac8-bd33-8736-c1a2-3d18994136de","displayText":"Europa - alla anv. 49 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 39 kr, 49 kr, 19 kr","sequence":7,"id":"183b5d9d-f0d5-f30d-d58c-7a74b0a211c3","displayText":"Europa - alla anv. 39 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 29 kr, 49 kr, 19 kr","sequence":8,"id":"551aee5a-637e-9907-beed-05b0ec37b272","displayText":"Europa - alla anv. 29 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 0 kr, 49 kr, 19 kr","sequence":9,"id":"4d405be4-e94e-b0b5-314d-d4a27ba8f3cc","displayText":"Europa - alla anv. 0 kr, 49 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 29 kr, 19 kr","sequence":10,"id":"1ba0de8b-b225-49d5-c596-4874b84c4297","displayText":"Grannland - alla anv. 89 kr, 29 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 19 kr, 19 kr","sequence":11,"id":"789c7c6f-df0b-9c54-a865-f4d93215ca88","displayText":"Grannland - alla anv. 89 kr, 19 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 0 kr, 19 kr","sequence":12,"id":"d43f776a-90ac-2ccf-0dbb-a7a5b63f6eb8","displayText":"Grannland - alla anv. 89 kr, 0 kr, 19 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 12 kr","sequence":13,"id":"ccf729aa-485a-311b-a010-cd6727d8f27a","displayText":"Utland - alla anv. 89 kr, 49 kr, 12 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 12 kr","sequence":14,"id":"be39cb66-6a44-6372-d7bf-438f130eebc3","displayText":"Utland - alla anv. 69 kr, 39 kr, 12 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 9 kr","sequence":15,"id":"454ff5e3-64bb-ca6a-6af4-b9810ae53971","displayText":"Utland - alla anv. 89 kr, 49 kr, 9 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 9 kr","sequence":16,"id":"f8ad24c8-d0bf-b09b-06a3-55ccdfbb0c71","displayText":"Utland - alla anv. 69 kr, 39 kr, 9 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 0 kr","sequence":17,"id":"97d75109-a29f-8b72-96d0-e84149d77339","displayText":"Utland - alla anv. 89 kr, 49 kr, 0 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 0 kr","sequence":18,"id":"296f3be9-3b0e-3155-e177-2b1f466e9b56","displayText":"Utland - alla anv. 69 kr, 39 kr, 0 kr"},{"value":"Europa & Utland - alla anv.  49 kr, 49 kr, 12 kr","sequence":19,"id":"2eea7313-03cb-9da5-3741-48a98cd2636b","displayText":"Europa & Utland - alla anv.  49 kr, 49 kr, 12 kr"},{"value":"Europa & Utland - alla anv. 39 kr, 49 kr, 12 kr","sequence":20,"id":"e4b437ac-32bb-b61f-708a-43f3923d0723","displayText":"Europa & Utland - alla anv. 39 kr, 49 kr, 12 kr"},{"value":"Europa & Utland - alla anv. 29 kr, 49 kr, 9 kr","sequence":21,"id":"25190e10-0c3a-419f-7cd9-ed43fe36260c","displayText":"Europa & Utland - alla anv. 29 kr, 49 kr, 9 kr"},{"value":"Europa & Utland - alla anv. 0 kr, 49 kr, 0 kr","sequence":22,"id":"263d1bda-d9ae-d7ca-3f63-04093ff493da","displayText":"Europa & Utland - alla anv. 0 kr, 49 kr, 0 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 29 kr, 12 kr","sequence":23,"id":"c355e733-ee3c-6833-5aa4-c71196e19cdb","displayText":"Grannland & Utland - alla anv. 89 kr, 29 kr, 12 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 19 kr, 9 kr","sequence":24,"id":"23bd33c8-cd75-903a-d9cc-eb820e004ba6","displayText":"Grannland & Utland - alla anv. 89 kr, 19 kr, 9 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 0 kr, 0 kr","sequence":25,"id":"fe688552-297a-a1f2-5de1-3f2fd8c5b483","displayText":"Grannland & Utland - alla anv. 89 kr, 0 kr, 0 kr"}],"selectedItem":{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VknQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_PARENT","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Parent","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5dQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"All-In Plus"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VkqQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5aQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":"12 months","sequence":1,"id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","displayText":"12 months"},{"value":"24 months","sequence":2,"id":"aba9e042-0545-92b0-b0d0-16cd00888e83","displayText":"24 months"},{"value":"36 months","sequence":3,"id":"cbdeb314-b13b-d53d-72ec-8e4c3370b908","displayText":"36 months"}],"default":[],"selectedItem":{"value":"12 months","sequence":1,"id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","displayText":"12 months"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VktQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5cQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Single Value","value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Number","uiDisplayType":"Single Value","value":123},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VkuQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_SUB","attributeconfigurable__c":true,"attributedisplaysequence__c":"50","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Subsidized","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5eQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":"Yes","sequence":1,"id":"2b5df0d6-eb1a-e9fa-950f-d6ca7614ee1e","displayText":"Yes"},{"value":"No","sequence":2,"id":"67dda21b-85c6-ce74-2955-5094c85f021c","displayText":"No"}],"default":[],"selectedItem":{"value":"No","sequence":2,"id":"67dda21b-85c6-ce74-2955-5094c85f021c","displayText":"No"}},"$$AttributeDefinitionEnd$$":null}]}';
                oli2.RoamingResAddOns__c = '15 kr, 15 kr, 15 kr';
            oli2.RoamingTillAddOns__c = '69 kr, 49 kr, 15 kr';
            offerQLI.add(oli2);
            
            QuoteLineItem oli3 = new QuoteLineItem();
            oli3.PricebookEntryId = objpricebookentry2.Id;
            oli3.TeliaSE_MC_Customer_Requested_Percentage__c=10;
            oli3.QuoteId = qut.id;
            oli3.UnitPrice = 200;
            oli3.vlocity_cmt__AssetReferenceId__c='378273euidkns';
            oli3.Quantity = 4;
            oli3.vlocity_cmt__Product2Id__c = prod2.id;
            oli3.Product2Id = prod2.id;
            oli3.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli3.TeliaSE_Approved__c = null;
            oli3.vlocity_cmt__RecurringCharge__c  = 200;
            oli3.TeliaSE_Ceiling_Price__c = 400;
            oli3.TeliaSE_Root_Product__c=prod2.id;
            oli3.vlocity_cmt__ProductHierarchyPath__c = prod2.id;
            oli3.TeliaSE_Base_Quantity__c = '123';
            oli3.vlocity_cmt__OneTimeCharge__c = 200;
            oli3.MC_OT_AM_Mandate_Percentage__c = 10;
            oli3.MC_OT_SM_Mandate_Percentage__c = 10;
            oli3.MC_OT_SD_Mandate_Percentage__c = 10;
            oli3.MC_OT_CM_Mandate_Percentage__c = 10;
            oli3.TeliaSE_AM_Mandate_Percentage__c = 10;
            oli3.TeliaSE_SM_Mandate_Percentage__c = 10;
            oli3.TeliaSE_SD_Mandate_Percentage__c = 10;
            oli3.TeliaSE_CM_Mandate_Percentage__c = 10;
            oli3.vlocity_cmt__JSONAttribute__c = '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a367Z000000PDG0QAO","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_NEG_ROAMING_TILL","attributeconfigurable__c":true,"attributedisplaysequence__c":"90","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"MC Roaming Till AddOns","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5bQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Standard 89 kr, 49 kr, 19 kr","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"}],"values":[{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"},{"value":"69 kr, 49 kr, 19 kr","sequence":2,"id":"a63eccc4-e18f-75ec-42fb-2200074c064b","displayText":"69 kr, 49 kr, 19 kr"},{"value":"59 kr, 39 kr, 19 kr","sequence":3,"id":"f5f0a872-81aa-0e6d-69a5-cb7ed4d135dd","displayText":"59 kr, 39 kr, 19 kr"},{"value":"69 kr, 49 kr, 15 kr","sequence":4,"id":"e6cd61d3-92da-312e-a4b2-e70436ac950c","displayText":"69 kr, 49 kr, 15 kr"},{"value":"59 kr, 39 kr, 15 kr","sequence":5,"id":"e32ac4bd-6719-f23c-466b-738d35a2d65d","displayText":"59 kr, 39 kr, 15 kr"},{"value":"Europa - alla anv. 49 kr, 49 kr, 19 kr","sequence":6,"id":"ad9fcac8-bd33-8736-c1a2-3d18994136de","displayText":"Europa - alla anv. 49 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 39 kr, 49 kr, 19 kr","sequence":7,"id":"183b5d9d-f0d5-f30d-d58c-7a74b0a211c3","displayText":"Europa - alla anv. 39 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 29 kr, 49 kr, 19 kr","sequence":8,"id":"551aee5a-637e-9907-beed-05b0ec37b272","displayText":"Europa - alla anv. 29 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 0 kr, 49 kr, 19 kr","sequence":9,"id":"4d405be4-e94e-b0b5-314d-d4a27ba8f3cc","displayText":"Europa - alla anv. 0 kr, 49 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 29 kr, 19 kr","sequence":10,"id":"1ba0de8b-b225-49d5-c596-4874b84c4297","displayText":"Grannland - alla anv. 89 kr, 29 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 19 kr, 19 kr","sequence":11,"id":"789c7c6f-df0b-9c54-a865-f4d93215ca88","displayText":"Grannland - alla anv. 89 kr, 19 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 0 kr, 19 kr","sequence":12,"id":"d43f776a-90ac-2ccf-0dbb-a7a5b63f6eb8","displayText":"Grannland - alla anv. 89 kr, 0 kr, 19 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 12 kr","sequence":13,"id":"ccf729aa-485a-311b-a010-cd6727d8f27a","displayText":"Utland - alla anv. 89 kr, 49 kr, 12 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 12 kr","sequence":14,"id":"be39cb66-6a44-6372-d7bf-438f130eebc3","displayText":"Utland - alla anv. 69 kr, 39 kr, 12 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 9 kr","sequence":15,"id":"454ff5e3-64bb-ca6a-6af4-b9810ae53971","displayText":"Utland - alla anv. 89 kr, 49 kr, 9 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 9 kr","sequence":16,"id":"f8ad24c8-d0bf-b09b-06a3-55ccdfbb0c71","displayText":"Utland - alla anv. 69 kr, 39 kr, 9 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 0 kr","sequence":17,"id":"97d75109-a29f-8b72-96d0-e84149d77339","displayText":"Utland - alla anv. 89 kr, 49 kr, 0 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 0 kr","sequence":18,"id":"296f3be9-3b0e-3155-e177-2b1f466e9b56","displayText":"Utland - alla anv. 69 kr, 39 kr, 0 kr"},{"value":"Europa & Utland - alla anv.  49 kr, 49 kr, 12 kr","sequence":19,"id":"2eea7313-03cb-9da5-3741-48a98cd2636b","displayText":"Europa & Utland - alla anv.  49 kr, 49 kr, 12 kr"},{"value":"Europa & Utland - alla anv. 39 kr, 49 kr, 12 kr","sequence":20,"id":"e4b437ac-32bb-b61f-708a-43f3923d0723","displayText":"Europa & Utland - alla anv. 39 kr, 49 kr, 12 kr"},{"value":"Europa & Utland - alla anv. 29 kr, 49 kr, 9 kr","sequence":21,"id":"25190e10-0c3a-419f-7cd9-ed43fe36260c","displayText":"Europa & Utland - alla anv. 29 kr, 49 kr, 9 kr"},{"value":"Europa & Utland - alla anv. 0 kr, 49 kr, 0 kr","sequence":22,"id":"263d1bda-d9ae-d7ca-3f63-04093ff493da","displayText":"Europa & Utland - alla anv. 0 kr, 49 kr, 0 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 29 kr, 12 kr","sequence":23,"id":"c355e733-ee3c-6833-5aa4-c71196e19cdb","displayText":"Grannland & Utland - alla anv. 89 kr, 29 kr, 12 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 19 kr, 9 kr","sequence":24,"id":"23bd33c8-cd75-903a-d9cc-eb820e004ba6","displayText":"Grannland & Utland - alla anv. 89 kr, 19 kr, 9 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 0 kr, 0 kr","sequence":25,"id":"fe688552-297a-a1f2-5de1-3f2fd8c5b483","displayText":"Grannland & Utland - alla anv. 89 kr, 0 kr, 0 kr"}],"selectedItem":{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VknQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_PARENT","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Parent","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5dQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"All-In Plus"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VkqQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5aQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":"12 months","sequence":1,"id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","displayText":"12 months"},{"value":"24 months","sequence":2,"id":"aba9e042-0545-92b0-b0d0-16cd00888e83","displayText":"24 months"},{"value":"36 months","sequence":3,"id":"cbdeb314-b13b-d53d-72ec-8e4c3370b908","displayText":"36 months"}],"default":[],"selectedItem":{"value":"12 months","sequence":1,"id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","displayText":"12 months"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VktQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5cQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Single Value","value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Number","uiDisplayType":"Single Value","value":123},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VkuQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_SUB","attributeconfigurable__c":true,"attributedisplaysequence__c":"50","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Subsidized","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5eQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":"Yes","sequence":1,"id":"2b5df0d6-eb1a-e9fa-950f-d6ca7614ee1e","displayText":"Yes"},{"value":"No","sequence":2,"id":"67dda21b-85c6-ce74-2955-5094c85f021c","displayText":"No"}],"default":[],"selectedItem":{"value":"No","sequence":2,"id":"67dda21b-85c6-ce74-2955-5094c85f021c","displayText":"No"}},"$$AttributeDefinitionEnd$$":null}]}';
                oli3.RoamingResAddOns__c = '15 kr, 15 kr, 15 kr';
            oli3.RoamingTillAddOns__c = '69 kr, 49 kr, 15 kr';
            offerQLI.add(oli3);
            insert offerQLI;
            
            
            TeliaSE_MC_Product_Object_Type__c cusSetting = new TeliaSE_MC_Product_Object_Type__c();
            cusSetting.Object_Type_Value__c = '%MOBILE_CAMPAIGN_DISC%';
            cusSetting.Product_Object_Type__c = 'Mobile Offer Specification';
            cusSetting.Name = 'Mobile Offer Specification';  
            insert cusSetting;
            
            Map<String,Object> inputMap = new Map<String,Object>();
            inputMap.put('quoteId', qut.id);
            inputMap.put('rootItemId', oli1.id);
            //inputMap.put('rootItemId', prod.id);
            inputMap.put('promoId', campaign.Id);
            inputMap.put('fieldName','TeliaSE_MC_Customer_Requested_Price__c');
            
            TeliaSE_QuoteConfig tq = new TeliaSE_QuoteConfig();
            //tq.invokeMethod('updateCampaign', inputMap, inputMap, inputMap);
            //tq.invokeMethod('searchCampaigns', inputMap, inputMap, inputMap);
            tq.invokeMethod('modifyQuote', inputMap, inputMap, inputMap);
            tq.invokeMethod('modifyQuote1', inputMap, inputMap, inputMap);
            tq.invokeMethod('priceCart', inputMap, inputMap, inputMap);
        }
    }
    public static testmethod void invokeMethod2(){
        User salesManager;         
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        
        System.runAs(new User(Id = Userinfo.getUserId())){
            salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManager.Bypass_VR__c = true;
            insert salesManager;
        }
        System.runAs(salesManager){
            
            Product2 prod = Test_DataFactory.createProducts(1)[0];
            insert prod;
            pricebookId = stdPriceBookRecId ;
            
            Opportunity opp = new Opportunity();
            opp.Name='opp1';
            opp.CloseDate = System.today();
            opp.StageName='Needs Analysis';  
            opp.Pricebook2Id=Test.getStandardPricebookId();
            opp.TeliaSE_SharingSetting_Flag__c = false;
            //opp.Type_of_Address__c = 'MDU';
            insert opp;
            
            PricebookEntry objpricebookentry =new PricebookEntry();
            objpricebookentry.Product2ID = prod.id;
            objpricebookentry.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry.UnitPrice=23.50;
            objpricebookentry.UseStandardPrice=false;
            objpricebookentry.isActive=true;//Add this line
            insert objpricebookentry;
            
            
            
            Quote qut = new Quote();
            qut.Name='Test Quote';
            qut.status = 'Draft';
            qut.opportunityId = opp.id;
            
            qut.Pricebook2ID = stdPriceBookRecId;
            qut.TeliaSE_Approval_Flag__c = False;        
            insert qut;
            
            list<QuoteLineItem> qliList1 = new list<QuoteLineItem>();
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
            oli1.TeliaSE_Approved_Price__c = 0;
            oli1.TeliaSE_Nullify_Check__c = false;
            oli1.vlocity_cmt__RootItemId__c = prod.id;
            
            //insert oli1;
            qliList1.add(oli1);
            
            
            QuoteLineItem oli2 = new QuoteLineItem();
            oli2.PricebookEntryId = objpricebookentry.Id;
            oli2.QuoteId = qut.id;
            oli2.UnitPrice = 200;
            oli2.Quantity = 4;
            oli2.Product2Id = prod.id;
            oli2.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli2.TeliaSE_MC_Customer_Requested_Percentage__c = 5;
            oli2.TeliaSE_MC_Customer_Requested_Price__c = 150;
            oli2.TeliaSE_Approved__c = 1;
            oli2.TeliaSE_Approved_Price__c = Null;
            oli2.TeliaSE_Nullify_Check__c = false;
            oli2.vlocity_cmt__RootItemId__c = prod.id;
            //oli1.TeliaSE_Product_Object_Type__c = 'Mobile Subscription Offer';
            
            //insert oli2;
            qliList1.add(oli2);
            insert qliList1;
            
            Map<String,Object> inputMap = new Map<String,Object>();
            inputMap.put('quoteId', qut.id);
            inputMap.put('rootItemId', prod.id);
            inputMap.put('fieldName','TeliaSE_MC_Customer_Requested_Price__c');
            
            TeliaSE_QuoteConfig tq = new TeliaSE_QuoteConfig();
            tq.invokeMethod('modifyQuote', inputMap, inputMap, inputMap);
            tq.invokeMethod('modifyQuote1', inputMap, inputMap, inputMap);
        }
    }
    public static testmethod void hardwareInvoke(){
        User salesManager;         
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        
        
        System.runAs(new User(Id = Userinfo.getUserId())){
            salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManager.Bypass_VR__c = true;
            insert salesManager;
        }
        System.runAs(salesManager){
            
            Product2 prod = Test_DataFactory.createProducts(1)[0];
            insert prod;
            pricebookId = stdPriceBookRecId ;
            
            Opportunity opp = new Opportunity();
            opp.Name='opp1';
            opp.CloseDate = System.today();
            opp.StageName='Needs Analysis';  
            opp.Pricebook2Id=Test.getStandardPricebookId();
            opp.TeliaSE_SharingSetting_Flag__c = false;
            //opp.Type_of_Address__c = 'MDU';
            insert opp;
            
            PricebookEntry objpricebookentry =new PricebookEntry();
            objpricebookentry.Product2ID = prod.id;
            objpricebookentry.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry.UnitPrice=23.50;
            objpricebookentry.UseStandardPrice=false;
            objpricebookentry.isActive=true;//Add this line
            insert objpricebookentry;
            
            
            
            Quote qut = new Quote();
            qut.Name='Test Quote';
            qut.status = 'Draft';
            qut.opportunityId = opp.id;
            
            qut.Pricebook2ID = stdPriceBookRecId;
            qut.TeliaSE_Approval_Flag__c = False;        
            insert qut;
            
            list<QuoteLineItem> qliList2 = new list<QuoteLineItem>();
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
            oli1.TeliaSE_Approved_Price__c = 0;
            oli1.TeliaSE_Nullify_Check__c = true;
            oli1.vlocity_cmt__RootItemId__c = prod.id;
            oli1.Subscription__c = 'Jobbmobil 15 GB';
            oli1.TeliaSE_MC_Binding_Time__c = '24 Månader';
            oli1.TeliaSE_MC_Sales_Type__c = 'New Sales - Nya tjänsteras';
            
            //insert oli1;
            qliList2.add(oli1);
            
            QuoteLineItem oli2 = new QuoteLineItem();
            oli2.PricebookEntryId = objpricebookentry.Id;
            oli2.QuoteId = qut.id;
            oli2.UnitPrice = 200;
            oli2.Quantity = 4;
            oli2.Product2Id = prod.id;
            oli2.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli2.TeliaSE_MC_Customer_Requested_Percentage__c = 5;
            oli2.TeliaSE_MC_Customer_Requested_Price__c = 150;
            oli2.TeliaSE_Approved__c = null;
            oli2.TeliaSE_Approved_Price__c = 0;
            oli2.TeliaSE_Nullify_Check__c = true;
            oli2.vlocity_cmt__RootItemId__c = prod.id;
            oli2.Subscription__c = 'Jobbmobil 15 GB';
            oli2.TeliaSE_MC_Binding_Time__c = '12 Månader';
            oli2.TeliaSE_MC_Sales_Type__c = 'New Sales - Nya tjänster';
            oli2.vlocity_cmt__ParentItemId__c = oli1.id;
            
            //insert oli2;
            qliList2.add(oli2);
            
            Map<String,Object> inputMap = new Map<String,Object>();
            inputMap.put('quoteId', qut.id);
            inputMap.put('qliId', oli1.id);
            inputMap.put('subscription',oli1.Subscription__c);
            inputMap.put('bindingTime',oli1.TeliaSE_MC_Binding_Time__c);
            inputMap.put('salesTypeSetup',oli1.TeliaSE_MC_Sales_Type__c);
            inputMap.put('fieldName','TeliaSE_MC_Customer_Requested_Price__c');
            
            TeliaSE_QuoteConfig tq = new TeliaSE_QuoteConfig();
            tq.invokeMethod('modifyQuote', inputMap, inputMap, inputMap);
            tq.invokeMethod('modifyQuote1', inputMap, inputMap, inputMap);
            tq.invokeMethod('updateHardwareProductDetails', inputMap, inputMap, inputMap);
        }
    }
    
    public static testmethod void campaingMethod(){
        User salesManager;         
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        
        
        System.runAs(new User(Id = Userinfo.getUserId())){
            salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManager.Bypass_VR__c = true;
            insert salesManager;
        }
        System.runAs(salesManager){
            
            vlocity_cmt__ObjectClass__c objClass = new vlocity_cmt__ObjectClass__c();
            objClass.Name = 'Mobile Offer Specification';    
            objClass.vlocity_cmt__IsActive__c = True;
            objClass.vlocity_cmt__ObjectApiName__c = 'Product2';
            insert objClass;
            Product2 prod = Test_DataFactory.createProducts(1)[0];
            prod.vlocity_cmt__ObjectTypeId__c = objClass.Id;                    
            insert prod;    
            pricebookId = stdPriceBookRecId ;
            
            Opportunity opp = new Opportunity();
            opp.Name='opp1';
            opp.CloseDate = System.today();
            opp.StageName='Needs Analysis';  
            opp.Pricebook2Id=Test.getStandardPricebookId();
            opp.TeliaSE_SharingSetting_Flag__c = false;
            // opp.Type_of_Address__c = 'MDU';
            insert opp;
            
            PricebookEntry objpricebookentry =new PricebookEntry();
            objpricebookentry.Product2ID = prod.id;
            objpricebookentry.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry.UnitPrice=23.50;
            objpricebookentry.UseStandardPrice=false;
            objpricebookentry.isActive=true;//Add this line
            insert objpricebookentry;
            
            Quote qut = new Quote();
            qut.Name='Test Quote';
            qut.status = 'Draft';
            qut.TeliaSE_Type__c = '';
            
            qut.opportunityId = opp.id;
            qut.TeliaSE_Type__c = 'New';
            qut.Pricebook2ID = stdPriceBookRecId;
            qut.TeliaSE_Approval_Flag__c = False;        
            insert qut;
            
            RecordType r = new RecordType();   
            r.Name = 'Discount';
            //insert r;
            
            RecordType rr = [select id, name from RecordType where Name='Discount'];
            
            vlocity_cmt__Promotion__c campaign = new vlocity_cmt__Promotion__c();
            campaign.Name = '3 fria månader';
            campaign.MC_Product_Name_Eng__c = '3 Month Free';
            campaign.vlocity_cmt__Code__c='MOBILE_CAMPAIGN_DISC_100_3';
            campaign.RecordType = rr;
            insert campaign;
            
            QuoteLineItem oli1 = new QuoteLineItem();
            oli1.PricebookEntryId = objpricebookentry.Id;
            oli1.QuoteId = qut.id;
            oli1.UnitPrice = 200;
            oli1.Quantity = 4;
            oli1.TeliaSE_MC_Campaign_Id__c = campaign.Id;
            oli1.Product2Id = prod.id;
            oli1.Lagerstatus__c = 'Lagerstatus__c';
            oli1.Price_List_Setup__c ='Månadsavgift';
            oli1.TeliaSE_MC_Binding_Time__c = '24 Månader';
            oli1.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli1.TeliaSE_MC_Customer_Requested_Percentage__c = 5;
            oli1.TeliaSE_MC_Customer_Requested_Price__c = 150;
            oli1.TeliaSE_Approved__c = 1;
            oli1.TeliaSE_Approved_Price__c = 0;
            oli1.TeliaSE_MC_FACallOffQuantity__c = 2;
            oli1.TeliaSE_Nullify_Check__c = true;
            oli1.vlocity_cmt__ParentItemId__c = null;
            oli1.MC_RootPriceFlag__c = false;
            
            oli1.vlocity_cmt__RootItemId__c = prod.id;
            //oli1.TeliaSE_Product_Object_Type__c = 'Mobile Subscription Offer';
            
            insert oli1;
            
            TeliaSE_MC_Product_Object_Type__c cusSetting = new TeliaSE_MC_Product_Object_Type__c();
            cusSetting.Object_Type_Value__c = '%MOBILE_CAMPAIGN_DISC%';
            cusSetting.Product_Object_Type__c = 'Mobile Offer Specification';
            cusSetting.Name = 'Mobile Offer Specification';  
            insert cusSetting;
            
            Map<String,Object> inputMap = new Map<String,Object>();
            inputMap.put('quoteId', qut.id);
            inputMap.put('rootItemId', oli1.id);
            //inputMap.put('rootItemId', prod.id);
            inputMap.put('promoId', campaign.Id);
            inputMap.put('qliId', oli1.id);
            inputMap.put('largerStatus','IN_STOCK');
            inputMap.put('pricelistSetup','Månadsavgift');
            inputMap.put('cartId',qut.id);
            //inputMap.put('subscription','');
            inputMap.put('BindingTime','24 Månader');
            inputMap.put('fieldName','TeliaSE_MC_Customer_Requested_Price__c');
            
            TeliaSE_QuoteConfig tq = new TeliaSE_QuoteConfig();
            tq.invokeMethod('updateCampaign', inputMap, inputMap, inputMap);
            tq.invokeMethod('searchCampaigns', inputMap, inputMap, inputMap);
            tq.invokeMethod('clearSingleCartFAQuantity', inputMap, inputMap, inputMap);
            tq.invokeMethod('updateCartPrice', inputMap, inputMap, inputMap);
            tq.invokeMethod('updateHardwareProductDetails', inputMap, inputMap, inputMap);
        }
    }    
    
    public static testmethod void invokeMethod3_SavingQuantity(){
        User salesManager;         
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        
        
        System.runAs(new User(Id = Userinfo.getUserId())){
            salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManager.Bypass_VR__c = true;
            insert salesManager;
        }
        System.runAs(salesManager){
            
            Product2 prod = Test_DataFactory.createProducts(1)[0];
            prod.ProductCode = 'MOB_MULTI';
            insert prod;
            pricebookId = stdPriceBookRecId ;
            
            Opportunity opp = new Opportunity();
            opp.Name='opp1';
            opp.CloseDate = System.today();
            opp.StageName='Needs Analysis';  
            opp.Pricebook2Id=Test.getStandardPricebookId();
            opp.TeliaSE_SharingSetting_Flag__c = false;
            //opp.Type_of_Address__c = 'MDU';
            insert opp;
            
            PricebookEntry objpricebookentry =new PricebookEntry();
            objpricebookentry.Product2ID = prod.id;
            objpricebookentry.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry.UnitPrice=23.50;
            objpricebookentry.UseStandardPrice=false;
            objpricebookentry.isActive=true;//Add this line
            insert objpricebookentry;
            
            
            
            Quote qut = new Quote();
            qut.Name='Test Quote';
            qut.status = 'Draft';
            qut.opportunityId = opp.id;
            
            qut.Pricebook2ID = stdPriceBookRecId;
            qut.TeliaSE_Approval_Flag__c = False;        
            insert qut;
            
            QuoteLineItem oli1 = new QuoteLineItem();
            oli1.PricebookEntryId = objpricebookentry.Id;
            oli1.QuoteId = qut.id;
            oli1.UnitPrice = 200;
            oli1.Quantity = 4;
            oli1.Product2Id = prod.id;
            oli1.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli1.TeliaSE_MC_Customer_Requested_Percentage__c = null;
            oli1.TeliaSE_MC_Customer_Requested_Price__c = 150;
            oli1.TeliaSE_Approved__c = null;
            oli1.TeliaSE_Approved_Price__c = 0;
            oli1.TeliaSE_Nullify_Check__c = true;
            oli1.vlocity_cmt__RootItemId__c = prod.id;
            oli1.TeliaSE_MC_FACallOffQuantity__c = 1;
            oli1.MC_Line_Status__c = 'Existing';
            oli1.vlocity_cmt__AssetReferenceId__c = '12345';
            insert oli1;
            
            QuoteLineItem oli2 = new QuoteLineItem();
            oli2.PricebookEntryId = objpricebookentry.Id;
            oli2.QuoteId = qut.id;
            oli2.UnitPrice = 200;
            oli2.Quantity = 4;
            oli2.Product2Id = prod.id;
            oli2.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli2.TeliaSE_MC_Customer_Requested_Percentage__c = 5;
            oli2.TeliaSE_MC_Customer_Requested_Price__c = 150;
            oli2.TeliaSE_Approved__c = null;
            oli2.TeliaSE_Approved_Price__c = 0;
            oli2.TeliaSE_Nullify_Check__c = true;
            oli2.TeliaSE_MC_FACallOffQuantity__c = 1;
            oli2.vlocity_cmt__Product2Id__c = prod.id;
            oli2.vlocity_cmt__RootItemId__c = prod.id; 
            oli1.vlocity_cmt__ParentItemId__c = null;
            oli1.MC_RootPriceFlag__c = true;
            oli1.vlocity_cmt__AssetReferenceId__c = '12345';
            oli2.MC_Line_Status__c='Existing';
            insert oli2;
            
            Map<String,Object> clearQuantityMap = new Map<String,Object>();
            clearQuantityMap.put('quoteId',qut.id);
            
            Map<String,Object> inputId = new Map<String,Object>();
            Map<String,Object> inputWrongId = new Map<String,Object>();
            Map<String,Object> callOffQuantity = new Map<String,Object>();
            Map<String,Object> inputKey = new Map<String,Object>();
            Map<String,Object> inputWrongKey = new Map<String,Object>();
            Map<String,Object> percentInput = new Map<String,Object>();
            Map<String,Object> priceInput = new Map<String,Object>();
            Map<String,Object> rootItemInput = new Map<String,Object>();
            Map<String,Object> initialOrderInput = new Map<String,Object>();
            Map<String,Object> convergenceInput = new Map<String,Object>();
            
            Decimal quantity = 123;
            inputId.put('value', oli1.id);
            inputWrongId.put('value',qut.id);
            callOffQuantity.put('value', quantity);
            percentInput.put('value',1);
            priceInput.put('value', 123);
            //inputMap.put('cartId',qut.id);
            rootItemInput.put('value', '12345');
            initialOrderInput.put('value',2);
            convergenceInput.put('value',2);
            
            inputWrongKey.put('Id',inputWrongId);
            inputKey.put('Id',inputId);
            inputKey.put('TeliaSE_MC_FACallOffQuantity__c',callOffQuantity);
            inputKey.put('TeliaSE_MC_Customer_Requested_Percentage__c',percentInput);
            inputKey.put('TeliaSE_MC_Customer_Requested_Price__c',priceInput);
            inputKey.put('vlocity_cmt__RootItemId__c',rootItemInput);
            inputKey.put('MC_Initial_Order_Quantity__c',initialOrderInput);
            inputKey.put('MC_Convergence_Quantity__c',convergenceInput); 
            inputKey.put('rootItemId',rootItemInput);
            inputKey.put('qliId',oli1.Id);
            inputKey.put('quoteId',qut.id);
            
            Map<String,Object> inputMap = new Map<string,Object>();
            Map<String,Object> inputWrongMap = new Map<String,Object>();
            Map<String,object> outMap = new Map<String,Object>();
            inputMap.put('obj',inputKey);
            inputMap.put('fieldName','TeliaSE_MC_Customer_Requested_Price__c');
            inputMap.put('callOffQuantityCheck', true);
            inputMap.put('rootItemId','12345');
            inputMap.put('quoteId',qut.id);
            inputMap.put('qliId',oli1.id);
            inputWrongMap.put('obj',inputWrongKey);
            
            TeliaSE_QuoteConfig tq = new TeliaSE_QuoteConfig();
            tq.invokeMethod('saveQuantity', inputMap, outMap, inputMap);
            tq.invokeMethod('saveQuantity', inputWrongMap, outMap, inputMap);
            tq.invokeMethod('updatePriceFlag', inputKey, outMap, inputMap);
            ////tq.invokeMethod('clearSingleCartFAQuantity', clearQuantityMap, outMap,inputWrongMap);
            
        }
    }
    
    
    public static testmethod void invokeMethod4_addRootProduct(){
        User salesManager;         
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        
        
        System.runAs(new User(Id = Userinfo.getUserId())){
            salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManager.Bypass_VR__c = true;
            insert salesManager;
        }
        System.runAs(salesManager){
            
            Product2 prod = Test_DataFactory.createProducts(1)[0];
            prod.ProductCode = 'MOB_MULTI';
            insert prod;
            pricebookId = stdPriceBookRecId ;
            
            Opportunity opp = new Opportunity();
            opp.Name='opp1';
            opp.CloseDate = System.today();
            opp.StageName='Needs Analysis';  
            opp.Pricebook2Id=Test.getStandardPricebookId();
            opp.TeliaSE_SharingSetting_Flag__c = false;
            //opp.Type_of_Address__c = 'MDU';
            insert opp;
            
            PricebookEntry objpricebookentry =new PricebookEntry();
            objpricebookentry.Product2ID = prod.id;
            objpricebookentry.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry.UnitPrice=23.50;
            objpricebookentry.UseStandardPrice=false;
            objpricebookentry.isActive=true;//Add this line
            insert objpricebookentry;
            
            RecordType rt = new RecordType();
            
            
            Quote qut = new Quote();
            qut.Name='Test Quote';
            qut.status = 'Draft';
            qut.opportunityId = opp.id;
            
            qut.Pricebook2ID = stdPriceBookRecId;
            qut.TeliaSE_Approval_Flag__c = False;        
            insert qut;
            
            List<QuoteLineItem> QliList = new List<QuoteLineItem>();
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
            oli1.TeliaSE_Approved_Price__c = 0;
            oli1.TeliaSE_Nullify_Check__c = true;
            oli1.vlocity_cmt__RootItemId__c = prod.id;
            oli1.TeliaSE_MC_FACallOffQuantity__c = 1;
            
            qliList.add(oli1);
            
            QuoteLineItem oli2 = new QuoteLineItem();
            oli2.PricebookEntryId = objpricebookentry.Id;
            oli2.QuoteId = qut.id;
            oli2.UnitPrice = 200;
            oli2.Quantity = 4;
            oli2.Product2Id = prod.id;
            oli2.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli2.TeliaSE_MC_Customer_Requested_Percentage__c = 5;
            oli2.TeliaSE_MC_Customer_Requested_Price__c = 150;
            oli2.TeliaSE_Approved__c = null;
            oli2.TeliaSE_Approved_Price__c = 0;
            oli2.TeliaSE_Nullify_Check__c = true;
            oli2.TeliaSE_MC_FACallOffQuantity__c = 1;
            oli2.vlocity_cmt__Product2Id__c = prod.id;
            oli2.vlocity_cmt__RootItemId__c = prod.id;            
            qliList.add(oli2);
            insert qliList;
            oli1.vlocity_cmt__ParentItemId__c = null;
            oli1.MC_RootPriceFlag__c = true;
            update oli1;
            oli2.vlocity_cmt__ParentItemId__c = oli1.id;
            update oli2;     
            
            
            
            Map<String,Object> options = new Map<String,Object>();
            Map<String,Object> inputMap = new Map<string,Object>();
            options.put('cartId',qut.id);
            inputMap.put('cartId',qut.id);
            
            TeliaSE_QuoteConfig tq = new TeliaSE_QuoteConfig();
            tq.invokeMethod('mcAddRootProduct', inputMap, inputMap, options);
            Set<Id> qliIdSet = new Set<Id>();
            for(QuoteLineItem qli:qliList)
            {
                qliIdSet.add(qli.Id);
            }
            TeliaSE_QuoteConfig.updateRootProductId(qliIdSet);
            
            Set<Id> qliIdSet1 = new Set<Id>();
            qliIdSet1.add(oli2.id);
            TeliaSE_QuoteConfig.updateRootProductId(qliIdSet1);
            ////tq.invokeMethod('clearSingleCartFAQuantity', clearQuantityMap, outMap,inputWrongMap);
            
        }
    }
    
    public static testmethod void autoTaskMethod(){
        User salesManager;         
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        System.runAs(new User(Id = Userinfo.getUserId())){
            salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManager.Bypass_VR__c = true;
            insert salesManager;
        }
        System.runAs(salesManager){            
            vlocity_cmt__ObjectClass__c objClass = new vlocity_cmt__ObjectClass__c();
            objClass.Name = 'ITDaaS Offer Spec';    
            objClass.vlocity_cmt__IsActive__c = True;
            objClass.vlocity_cmt__ObjectApiName__c = 'Product2';
            insert objClass;
            vlocity_cmt__ObjectClass__c objClass2 = new vlocity_cmt__ObjectClass__c();
            objClass2.Name = 'Operator Connect Offer Spec';    
            objClass2.vlocity_cmt__IsActive__c = True;
            objClass2.vlocity_cmt__ObjectApiName__c = 'Product2';
            insert objClass2;
            vlocity_cmt__ObjectClass__c objClass3 = new vlocity_cmt__ObjectClass__c();
            objClass3.Name = 'OFFICE365 Offer Spec';    
            objClass3.vlocity_cmt__IsActive__c = True;
            objClass3.vlocity_cmt__ObjectApiName__c = 'Product2';
            insert objClass3;
            
            List<Product2> prod = Test_DataFactory.createProducts(3);
            prod[0].vlocity_cmt__ObjectTypeId__c = objClass.Id;                    
            prod[1].vlocity_cmt__ObjectTypeId__c = objClass2.Id;                    
            prod[2].vlocity_cmt__ObjectTypeId__c = objClass3.Id;                    
            insert prod;
            pricebookId = stdPriceBookRecId ;
            
            Opportunity opp = new Opportunity();
            opp.Name='opp1';
            opp.CloseDate = System.today();
            opp.StageName='Needs Analysis';  
            opp.Pricebook2Id=Test.getStandardPricebookId();
            opp.TeliaSE_SharingSetting_Flag__c = false;
            insert opp;
            
            PricebookEntry objpricebookentry =new PricebookEntry();
            objpricebookentry.Product2ID = prod[0].id;
            objpricebookentry.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry.UnitPrice=23.50;
            objpricebookentry.UseStandardPrice=false;
            objpricebookentry.isActive=true;
            insert objpricebookentry;
            PricebookEntry objpricebookentry2 =new PricebookEntry();
            objpricebookentry2.Product2ID = prod[1].id;
            objpricebookentry2.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry2.UnitPrice=23.50;
            objpricebookentry2.UseStandardPrice=false;
            objpricebookentry2.isActive=true;
            insert objpricebookentry2;
            
            Quote qut = new Quote();
            qut.Name='Test Quote';
            qut.status = 'Draft';
            qut.TeliaSE_Type__c = '';        
            qut.opportunityId = opp.id;
            qut.TeliaSE_Type__c = 'New';
            qut.Pricebook2ID = stdPriceBookRecId;
            qut.TeliaSE_Approval_Flag__c = False;        
            insert qut;
            Map<String,Object> ipInput = new Map<String,Object>();
            ipInput.put('quoteId',qut.id);            
            
			List<QuoteLineItem> qliList = new List<QuoteLineItem>();
            QuoteLineItem oli1 = new QuoteLineItem();
            oli1.PricebookEntryId = objpricebookentry.Id;
            oli1.QuoteId = qut.id;
            oli1.UnitPrice = 200;
            oli1.Quantity = 4;
            oli1.Product2Id = prod[0].id;
            oli1.Lagerstatus__c = 'Lagerstatus__c';
            oli1.Price_List_Setup__c ='Månadsavgift';
            oli1.TeliaSE_MC_Binding_Time__c = '24 Månader';
            oli1.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli1.TeliaSE_MC_Customer_Requested_Percentage__c = 5;
            oli1.TeliaSE_MC_Customer_Requested_Price__c = 150;
            oli1.TeliaSE_Approved__c = 1;
            oli1.TeliaSE_Approved_Price__c = 0;
            oli1.TeliaSE_MC_FACallOffQuantity__c = 2;
            oli1.TeliaSE_Nullify_Check__c = true;
            oli1.vlocity_cmt__RootItemId__c = prod[0].id;
            oli1.MC_Line_Status__c = 'Existing';
            qliList.add(oli1);
            
            QuoteLineItem oli2 = new QuoteLineItem();
            oli2.PricebookEntryId = objpricebookentry2.Id;
            oli2.TeliaSE_MC_Customer_Requested_Percentage__c=10;
            oli2.QuoteId = qut.id;
            oli2.UnitPrice = 200;
            oli2.Quantity = 4;
            oli2.vlocity_cmt__Product2Id__c = prod[1].id;
            oli2.Product2Id = prod[1].id;
            oli2.MC_Line_Status__c = 'Added';
            qliList.add(oli2);
            
            QuoteLineItem oli3 = new QuoteLineItem();
            oli3.PricebookEntryId = objpricebookentry2.Id;
            oli3.TeliaSE_MC_Customer_Requested_Percentage__c=10;
            oli3.QuoteId = qut.id;
            oli3.UnitPrice = 200;
            oli3.Quantity = 4;
            oli3.vlocity_cmt__Product2Id__c = prod[2].id;
            oli3.Product2Id = prod[2].id;
            oli3.MC_Line_Status__c = 'Updated';
            qliList.add(oli3);
            insert qliList;
            
            Map<String,Object> inputMap = new Map<String,Object>();
            inputMap.put('quoteId', qut.id);
            inputMap.put('rootItemId',oli1.id);
            inputMap.put('qliId',oli1.id);
            
            Test.startTest();
            TeliaSE_QuoteConfig tq = new TeliaSE_QuoteConfig();
            tq.invokeMethod('AutoTaskQuoteSync', inputMap, inputMap, inputMap);
            tq.invokeMethod('updatePriceFlag',inputMap,inputMap, inputMap); 
            
            inputMap.put('qliId',oli2.id);
            inputMap.put('qliObjType','OFFICE365 Offer Spec');
            tq.invokeMethod('checkBenefitEligibility', inputMap, inputMap, inputMap);
            Test.stopTest();
        }
    }    
    
    public static testmethod void testUpdateFiberFields()
    {
        invokeMethod();
        QuoteLineItem quoteLineItem = [select id, quoteid from QuotelineItem limit 1];
        Map<String,Object> idMap = new Map<String,Object>();
        idMap.put('value',quoteLineItem.id);
        Map<String,Object> priceMap = new Map<String,Object>();
        priceMap.put('value','10');
        
        Map<String,Object> quantityMap = new Map<String,Object>();
        quantityMap.put('value',10);
        
        Map<String,Object> input = new Map<String,Object>();
        input.put('Id',idMap);
        
        input.put('Quantity',quantityMap);
        input.put('Fiber_Customer_Requested_Price__c',priceMap);
        
        Map<String,Object> inputMap = new Map<String,Object>();
        inputMap.put('input',input);
        inputMap.put('qliId',quoteLineItem.Id);
        inputMap.put('cartId',quoteLineItem.quoteId);
        inputMap.put('prodCode','MOB_MULTI_TOTAL');
        inputMap.put('salesFlowIdentifier','MOB_MULTI_TOTAL');
        
        TeliaSE_QuoteConfig tq = new TeliaSE_QuoteConfig();
        
        tq.invokeMethod('updateFiberFields', inputMap, inputMap, inputMap);
        tq.invokeMethod('priceCart', inputMap, inputMap, inputMap);
        tq.invokeMethod('checkBasSubscriptionAndAttribute', inputMap, inputMap, inputMap);
        
        
    }
}