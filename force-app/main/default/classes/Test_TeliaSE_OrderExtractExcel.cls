@isTest
public with sharing class Test_TeliaSE_OrderExtractExcel {
    @isTest()
    public static void testOrderExtract(){
        User salesManager;         
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        salesManager = Test_DataFactory.createAdminUser();
        salesManager.ForecastEnabled = true;
        salesManager.Bypass_VR__c = true;
        insert salesManager;
        System.runAs(salesManager){
            list<recordtype> faQuoteRecId = [SELECT Id FROM recordtype where DeveloperName = 'Contract' AND SobjectType = 'Quote' limit 1];
            list<recordtype> offerQuoteRecId = [SELECT Id FROM recordtype where DeveloperName = 'Offer' AND SobjectType = 'Quote' limit 1];
            List<Product2> prodList = new List<product2>();

            vlocity_cmt__ObjectClass__c newObj1=new vlocity_cmt__ObjectClass__c();
            newObj1.Name = 'Broadband Datanet Offering Spec';
            newObj1.vlocity_cmt__IsActive__c = true;
            newObj1.vlocity_cmt__ObjectApiName__c ='Product2';
            insert newObj1;
            
            Product2 prod = Test_DataFactory.createProducts(1)[0];
            prod.name = 'Telia Datanet';
            prod.productCode = 'CO-DATANET';
            prod.vlocity_cmt__ObjectTypeId__c = newObj1.Id;
            prodList.add(prod); 
            
            Product2 prod7 = Test_DataFactory.createProducts(1)[0];
            prod7.name = 'Telia Datanet Parent';
            prod7.productCode = 'CO-DATANETPARENT';
            prod7.vlocity_cmt__ObjectTypeId__c = newObj1.Id;
            prodList.add(prod7); 
            
            
            Product2 prod1 = Test_DataFactory.createProducts(1)[0];
            prod1.name = 'Telia Bredband Pro';
            prod1.productCode = 'CO-BBPRO';
            prodList.add(prod1);            
            
            Product2 prod2 = Test_DataFactory.createProducts(1)[0];
            prod2.Name = 'Telia Bredband Plus';
            prod2.productCode = 'CO-BBPLUS';
            prodList.add(prod2);
            
            Product2 prod3 = Test_DataFactory.createProducts(1)[0];
            prod3.Name = 'Telia Cloud VPN Wifi/Lan';
            prod3.productCode = 'CO-CLOUDVPN-WIFI';
            prodList.add(prod3);
            
            Product2 prod4 = Test_DataFactory.createProducts(1)[0];
            prod4.Name = 'Installation och Övriga Tillval';
            prod4.productCode = 'CO-BBPRO-SEKUNDAR';
            prodList.add(prod4);

            Product2 prod5 = Test_DataFactory.createProducts(1)[0];
            prod5.Name = 'HERA XYZ';
            prod5.productCode = 'CO-HERA-ALL';
            prodList.add(prod5);
            
           /* Product2 prodSLA = Test_DataFactory.createProducts(1)[0];
            prodSLA.Name = 'Bredband Pro SLA C4';
            prodSLA.productCode = 'CO-BBPRO-SLA-C4';
            prodList.add(prodSLA);*/ 
            
            Product2 prod6 = Test_DataFactory.createProducts(1)[0];
            prod6.name = 'Bredband Pro 100 Mbit/s';
            prod6.productCode = 'CO-BBPRO-100MB';
            prodList.add(prod6);
            
            insert prodList;
            
            vlocity_cmt__ProductChildItem__c pchild = new vlocity_cmt__ProductChildItem__c();
            pchild.vlocity_cmt__ParentProductId__c = prod7.Id;
            pchild.vlocity_cmt__ChildProductId__c = prod.Id;
            pchild.Name = 'Test PCI1';
            pchild.vlocity_cmt__Quantity__c = 1;
            pchild.vlocity_cmt__MinQuantity__c = 1;
            pchild.vlocity_cmt__MaxQuantity__c = 25;
            pchild.vlocity_cmt__IsRootProductChildItem__c = false;
            pchild.vlocity_cmt__IsOverride__c = false;
            pchild.vlocity_cmt__ChildLineNumber__c = '10';
            pchild.vlocity_cmt__IsVirtualItem__c = false;
            insert pchild;
            
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
            
            PricebookEntry objpricebookentry3 =new PricebookEntry();
            objpricebookentry3.Product2ID = prod3.id;
            objpricebookentry3.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry3.UnitPrice=23.50;
            objpricebookentry3.UseStandardPrice=false;
            objpricebookentry3.isActive=true;//Add this line
            pbeList.add(objpricebookentry3); 
            
            PricebookEntry objpricebookentry4 =new PricebookEntry();
            objpricebookentry4.Product2ID = prod4.id;
            objpricebookentry4.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry4.UnitPrice=23.50;
            objpricebookentry4.UseStandardPrice=false;
            objpricebookentry4.isActive=true;//Add this line
            pbeList.add(objpricebookentry4);
            
            PricebookEntry objpricebookentry5 =new PricebookEntry();
            objpricebookentry5.Product2ID = prod5.id;
            objpricebookentry5.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry5.UnitPrice=23.50;
            objpricebookentry5.UseStandardPrice=false;
            objpricebookentry5.isActive=true;//Add this line
            pbeList.add(objpricebookentry5);
            
            PricebookEntry objpricebookentry6 =new PricebookEntry();
            objpricebookentry6.Product2ID = prod6.id;
            objpricebookentry6.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry6.UnitPrice=23.50;
            objpricebookentry6.UseStandardPrice=false;
            objpricebookentry6.isActive=true;//Add this line
            pbeList.add(objpricebookentry6); 
            
            insert pbeList;
            
            //Creating account
            Account acc=Test_DataFactory.createOneSMEAccount();
            acc.MC_Commercial_Setup__c = 'Forced RA';
            acc.Org_Nr__c  = '5564110665';
            acc.Name = 'R21.4_Test_CO_Acc_Grouping';
            insert acc;
            
            Account acc_NonGrouping=Test_DataFactory.createOneSMEAccount();
            acc_NonGrouping.MC_Commercial_Setup__c = 'Forced RA';
            acc_NonGrouping.Org_Nr__c  = '5564110555';
            acc_NonGrouping.Name = 'R21.4_Test_CO_Acc_NonGrouping';
            insert acc_NonGrouping;
            
            //Creating quote for Grouping logic
            //Creating opportunity below
            Opportunity opp = new Opportunity();
            opp.Name='opp1';
            opp.AccountId=acc.Id;
            opp.CloseDate = System.today();
            opp.StageName='Needs Analysis';
            opp.Pricebook2Id=Test.getStandardPricebookId();
            insert opp;
            
            RecordType rt1 = [Select id,name, DeveloperName from RecordType where Name='Ramavtal'];
            //Creating contract below
            Contract contract=new Contract();
            contract.Name='Test';
            contract.AccountId=acc.id;
            contract.Status='Draft';
            contract.Solution_Area__c='Vxl';
            contract.StartDate=Date.today();
            contract.ContractTerm=24;
            contract.recordtypeId = rt1.id;
            insert contract;
            
            //Creating contract below
           /* Contract contract_NonGrouping = new Contract();
            contract_NonGrouping.Name = 'Test_NonGrouping';
            contract_NonGrouping.AccountId = acc_NonGrouping.id;
            contract_NonGrouping.Status = 'Active';
            contract_NonGrouping.Solution_Area__c = 'Vxl';
            contract_NonGrouping.StartDate = Date.today();
            contract_NonGrouping.ContractTerm = 24;
            insert contract_NonGrouping;*/
            
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
            insert faQuote;
            contract.vlocity_cmt__QuoteId__c = faQuote.id;
            update contract;
            //Create FA quote
           /* Quote faQuote_NonGrouping = new Quote();
            faQuote_NonGrouping.Name='Test Quote_NonGrouping';
            faQuote_NonGrouping.status = 'Draft';
            faQuote_NonGrouping.TeliaSE_Type__c='Renegotiation';
            faQuote_NonGrouping.opportunityId = opp_NonGrouping.id;
            faQuote_NonGrouping.Pricebook2ID = stdPriceBookRecId;
            faQuote_NonGrouping.TeliaSE_Approval_Flag__c = true; 
            faQuote_NonGrouping.RecordTypeId = id.valueof((string)faQuoteRecId[0].get('id'));
            faQuote_NonGrouping.TeliaSE_MC_Sales_Flow_Identifier__c = 'New Sales';
            insert faQuote_NonGrouping;
            contract_NonGrouping.vlocity_cmt__QuoteId__c = faQuote_NonGrouping.id;
            update contract_NonGrouping;*/
            
            //Create Offer Quote
            Quote offerQuote = new Quote();
            offerQuote.Name='Test Quote';
            offerQuote.status = 'Draft';
            offerQuote.opportunityId = opp.id;
            offerQuote.Pricebook2ID = stdPriceBookRecId;
            offerQuote.TeliaSE_Approval_Flag__c = false; 
            offerQuote.vlocity_cmt__ParentQuoteId__c  = faQuote.id;
            offerQuote.RecordTypeId = id.valueof((string)offerQuoteRecId[0].get('id'));
            insert offerQuote;
            //Create Offer Quote
           /* Quote offerQuote_NonGrouping = new Quote();
            offerQuote_NonGrouping.Name='Test Quote Offer_NonGrouping';
            offerQuote_NonGrouping.status = 'Draft';
            offerQuote_NonGrouping.opportunityId = opp_NonGrouping.id;
            offerQuote_NonGrouping.Pricebook2ID = stdPriceBookRecId;
            offerQuote_NonGrouping.TeliaSE_Approval_Flag__c = false; 
            offerQuote_NonGrouping.vlocity_cmt__ParentQuoteId__c  = faQuote.id;
            offerQuote_NonGrouping.RecordTypeId = id.valueof((string)offerQuoteRecId[0].get('id'));
            insert offerQuote_NonGrouping;*/
            
            //Creatting Premisies
            vlocity_cmt__Premises__c premise = new vlocity_cmt__Premises__c();
            premise.vlocity_cmt__City__c = 'solna';
            premise.vlocity_cmt__StreetAddress__c = 'Överskärargränd';
            premise.vlocity_cmt__PostalCode__c = '12111';
            premise.vlocity_cmt__Address1__c = '12111';
            premise.vlocity_cmt__PropertyOwnerAccountId__c = acc.Id;
            insert premise;
            vlocity_cmt__Premises__c premise1 = new vlocity_cmt__Premises__c();
            premise1.vlocity_cmt__City__c = 'stockholm';
            premise1.vlocity_cmt__StreetAddress__c = 'Stjärntorget';
            premise1.vlocity_cmt__PostalCode__c = '12112';
            premise1.vlocity_cmt__Address1__c = '12112';
            premise1.vlocity_cmt__PropertyOwnerAccountId__c = acc.Id;
            insert premise1;
            vlocity_cmt__Premises__c premise2 = new vlocity_cmt__Premises__c();
            premise2.vlocity_cmt__City__c = 'solna';
            premise2.vlocity_cmt__StreetAddress__c = 'Diktarvägen';
            premise2.vlocity_cmt__PostalCode__c = '12113';
            premise2.vlocity_cmt__Address1__c = '12113';
            premise2.vlocity_cmt__PropertyOwnerAccountId__c = acc.Id;
            insert premise2;
            vlocity_cmt__Premises__c premise3 = new vlocity_cmt__Premises__c();
            premise3.vlocity_cmt__City__c = 'stockholm';
            premise3.vlocity_cmt__StreetAddress__c = 'Hamngatan';
            premise3.vlocity_cmt__PostalCode__c = '12114';
            premise3.vlocity_cmt__Address1__c = '';
            premise3.vlocity_cmt__PropertyOwnerAccountId__c = acc.Id;
            insert premise3;
            vlocity_cmt__Premises__c premise4 = new vlocity_cmt__Premises__c();
            premise4.vlocity_cmt__City__c = 'stockholm';
            premise4.vlocity_cmt__StreetAddress__c = 'Kanslikajen';
            premise4.vlocity_cmt__PostalCode__c = '12115';
            premise4.vlocity_cmt__Address1__c = '12115';
            premise4.vlocity_cmt__PropertyOwnerAccountId__c = acc.Id;
            insert premise4;
            //Creating service point link between Service point and premises
            vlocity_cmt__ServicePoint__c spoint = new vlocity_cmt__ServicePoint__c();
            spoint.vlocity_cmt__ServicePointNumber__c = '148573009';
            spoint.vlocity_cmt__PremisesId__c = premise.Id;
            insert spoint;
            
            
            vlocity_cmt__ServicePoint__c spoint1 = new vlocity_cmt__ServicePoint__c();
            spoint1.vlocity_cmt__ServicePointNumber__c = '1212123';
            spoint1.vlocity_cmt__PremisesId__c = premise1.Id;
            insert spoint1;
            vlocity_cmt__ServicePoint__c spoint2 = new vlocity_cmt__ServicePoint__c();
            spoint2.vlocity_cmt__ServicePointNumber__c = '1212124';
            spoint2.vlocity_cmt__PremisesId__c = premise2.Id;
            insert spoint2;
            vlocity_cmt__ServicePoint__c spoint3 = new vlocity_cmt__ServicePoint__c();
            spoint3.vlocity_cmt__ServicePointNumber__c = '1212125';
            spoint3.vlocity_cmt__PremisesId__c = premise3.Id;
            insert spoint3;
            vlocity_cmt__ServicePoint__c spoint4 = new vlocity_cmt__ServicePoint__c();
            spoint4.vlocity_cmt__ServicePointNumber__c = '1212125';
            spoint4.vlocity_cmt__PremisesId__c = premise4.Id;
            insert spoint4;
            //Creating quote groups
            vlocity_cmt__QuoteGroup__c quoteGroup = new vlocity_cmt__QuoteGroup__c();
            quoteGroup.Name = 'Group 1';
            quoteGroup.vlocity_cmt__Description__c = 'Group 1';
            quoteGroup.vlocity_cmt__QuoteId__c = offerQuote.id;
            insert quoteGroup;
            vlocity_cmt__QuoteGroup__c quoteGroup1 = new vlocity_cmt__QuoteGroup__c();
            quoteGroup1.Name = 'Group 2';
            quoteGroup1.vlocity_cmt__Description__c = 'Group 2';
            quoteGroup1.vlocity_cmt__QuoteId__c = offerQuote.id;
            insert quoteGroup1;
            vlocity_cmt__QuoteGroup__c quoteGroup2 = new vlocity_cmt__QuoteGroup__c();
            quoteGroup2.Name = 'Group 3';
            quoteGroup2.vlocity_cmt__Description__c = 'Group 3';
            quoteGroup2.vlocity_cmt__QuoteId__c = offerQuote.id;
            insert quoteGroup2;
            vlocity_cmt__QuoteGroup__c quoteGroup3 = new vlocity_cmt__QuoteGroup__c();
            quoteGroup3.Name = 'Group 4';
            quoteGroup3.vlocity_cmt__Description__c = 'Group 4';
            quoteGroup3.vlocity_cmt__QuoteId__c = offerQuote.id;
            insert quoteGroup3;
            vlocity_cmt__QuoteGroup__c quoteGroup4 = new vlocity_cmt__QuoteGroup__c();
            quoteGroup4.Name = 'Group 5';
            quoteGroup4.vlocity_cmt__Description__c = 'Group 5';
            quoteGroup4.vlocity_cmt__QuoteId__c = offerQuote.id;
            insert quoteGroup4;
            //Creating quote members
            vlocity_cmt__QuoteMember__c quoteMem = new vlocity_cmt__QuoteMember__c();
            quoteMem.vlocity_cmt__ServicePointId__c = spoint.Id;
            quoteMem.vlocity_cmt__QuoteGroupId__c = quoteGroup.Id;
            quoteMem.vlocity_cmt__QuoteId__c = offerQuote.id;
            insert quoteMem;
            vlocity_cmt__QuoteMember__c quoteMem1 = new vlocity_cmt__QuoteMember__c();
            quoteMem1.vlocity_cmt__ServicePointId__c = spoint1.Id;
            quoteMem1.vlocity_cmt__QuoteGroupId__c = quoteGroup1.Id;
            quoteMem1.vlocity_cmt__QuoteId__c = offerQuote.id;
            insert quoteMem1;
            vlocity_cmt__QuoteMember__c quoteMem2 = new vlocity_cmt__QuoteMember__c();
            quoteMem2.vlocity_cmt__ServicePointId__c = spoint2.Id;
            quoteMem2.vlocity_cmt__QuoteGroupId__c = quoteGroup2.Id;
            quoteMem2.vlocity_cmt__QuoteId__c = offerQuote.id;
            insert quoteMem2;
            vlocity_cmt__QuoteMember__c quoteMem3 = new vlocity_cmt__QuoteMember__c();
            quoteMem3.vlocity_cmt__ServicePointId__c = spoint3.Id;
            quoteMem3.vlocity_cmt__QuoteGroupId__c = quoteGroup3.Id;
            quoteMem3.vlocity_cmt__QuoteId__c = offerQuote.id;
            insert quoteMem3;
            vlocity_cmt__QuoteMember__c quoteMem4 = new vlocity_cmt__QuoteMember__c();
            quoteMem4.vlocity_cmt__ServicePointId__c = spoint4.Id;
            quoteMem4.vlocity_cmt__QuoteGroupId__c = quoteGroup4.Id;
            quoteMem4.vlocity_cmt__QuoteId__c = offerQuote.id;
            insert quoteMem4;
            
            
            //Creating line items
            list<QuoteLineItem> offerQLI = new list<QuoteLineItem>();
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
            oli1.vlocity_cmt__QuoteGroupId__c = quoteGroup.id;
            oli1.vlocity_cmt__JSONAttribute__c = '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a367Z000000PDG0QAO","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_NEG_ROAMING_TILL","attributeconfigurable__c":true,"attributedisplaysequence__c":"90","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"MC Roaming Till AddOns","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5bQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Standard 89 kr, 49 kr, 19 kr","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"}],"values":[{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"},{"value":"69 kr, 49 kr, 19 kr","sequence":2,"id":"a63eccc4-e18f-75ec-42fb-2200074c064b","displayText":"69 kr, 49 kr, 19 kr"},{"value":"59 kr, 39 kr, 19 kr","sequence":3,"id":"f5f0a872-81aa-0e6d-69a5-cb7ed4d135dd","displayText":"59 kr, 39 kr, 19 kr"},{"value":"69 kr, 49 kr, 15 kr","sequence":4,"id":"e6cd61d3-92da-312e-a4b2-e70436ac950c","displayText":"69 kr, 49 kr, 15 kr"},{"value":"59 kr, 39 kr, 15 kr","sequence":5,"id":"e32ac4bd-6719-f23c-466b-738d35a2d65d","displayText":"59 kr, 39 kr, 15 kr"},{"value":"Europa - alla anv. 49 kr, 49 kr, 19 kr","sequence":6,"id":"ad9fcac8-bd33-8736-c1a2-3d18994136de","displayText":"Europa - alla anv. 49 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 39 kr, 49 kr, 19 kr","sequence":7,"id":"183b5d9d-f0d5-f30d-d58c-7a74b0a211c3","displayText":"Europa - alla anv. 39 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 29 kr, 49 kr, 19 kr","sequence":8,"id":"551aee5a-637e-9907-beed-05b0ec37b272","displayText":"Europa - alla anv. 29 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 0 kr, 49 kr, 19 kr","sequence":9,"id":"4d405be4-e94e-b0b5-314d-d4a27ba8f3cc","displayText":"Europa - alla anv. 0 kr, 49 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 29 kr, 19 kr","sequence":10,"id":"1ba0de8b-b225-49d5-c596-4874b84c4297","displayText":"Grannland - alla anv. 89 kr, 29 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 19 kr, 19 kr","sequence":11,"id":"789c7c6f-df0b-9c54-a865-f4d93215ca88","displayText":"Grannland - alla anv. 89 kr, 19 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 0 kr, 19 kr","sequence":12,"id":"d43f776a-90ac-2ccf-0dbb-a7a5b63f6eb8","displayText":"Grannland - alla anv. 89 kr, 0 kr, 19 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 12 kr","sequence":13,"id":"ccf729aa-485a-311b-a010-cd6727d8f27a","displayText":"Utland - alla anv. 89 kr, 49 kr, 12 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 12 kr","sequence":14,"id":"be39cb66-6a44-6372-d7bf-438f130eebc3","displayText":"Utland - alla anv. 69 kr, 39 kr, 12 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 9 kr","sequence":15,"id":"454ff5e3-64bb-ca6a-6af4-b9810ae53971","displayText":"Utland - alla anv. 89 kr, 49 kr, 9 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 9 kr","sequence":16,"id":"f8ad24c8-d0bf-b09b-06a3-55ccdfbb0c71","displayText":"Utland - alla anv. 69 kr, 39 kr, 9 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 0 kr","sequence":17,"id":"97d75109-a29f-8b72-96d0-e84149d77339","displayText":"Utland - alla anv. 89 kr, 49 kr, 0 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 0 kr","sequence":18,"id":"296f3be9-3b0e-3155-e177-2b1f466e9b56","displayText":"Utland - alla anv. 69 kr, 39 kr, 0 kr"},{"value":"Europa & Utland - alla anv.  49 kr, 49 kr, 12 kr","sequence":19,"id":"2eea7313-03cb-9da5-3741-48a98cd2636b","displayText":"Europa & Utland - alla anv.  49 kr, 49 kr, 12 kr"},{"value":"Europa & Utland - alla anv. 39 kr, 49 kr, 12 kr","sequence":20,"id":"e4b437ac-32bb-b61f-708a-43f3923d0723","displayText":"Europa & Utland - alla anv. 39 kr, 49 kr, 12 kr"},{"value":"Europa & Utland - alla anv. 29 kr, 49 kr, 9 kr","sequence":21,"id":"25190e10-0c3a-419f-7cd9-ed43fe36260c","displayText":"Europa & Utland - alla anv. 29 kr, 49 kr, 9 kr"},{"value":"Europa & Utland - alla anv. 0 kr, 49 kr, 0 kr","sequence":22,"id":"263d1bda-d9ae-d7ca-3f63-04093ff493da","displayText":"Europa & Utland - alla anv. 0 kr, 49 kr, 0 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 29 kr, 12 kr","sequence":23,"id":"c355e733-ee3c-6833-5aa4-c71196e19cdb","displayText":"Grannland & Utland - alla anv. 89 kr, 29 kr, 12 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 19 kr, 9 kr","sequence":24,"id":"23bd33c8-cd75-903a-d9cc-eb820e004ba6","displayText":"Grannland & Utland - alla anv. 89 kr, 19 kr, 9 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 0 kr, 0 kr","sequence":25,"id":"fe688552-297a-a1f2-5de1-3f2fd8c5b483","displayText":"Grannland & Utland - alla anv. 89 kr, 0 kr, 0 kr"}],"selectedItem":{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VknQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_PARENT","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Parent","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5dQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"All-In Plus"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VkqQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5aQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":"12 months","sequence":1,"id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","displayText":"12 months"},{"value":"24 months","sequence":2,"id":"aba9e042-0545-92b0-b0d0-16cd00888e83","displayText":"24 months"},{"value":"36 months","sequence":3,"id":"cbdeb314-b13b-d53d-72ec-8e4c3370b908","displayText":"36 months"}],"default":[],"selectedItem":{"value":"12 months","sequence":1,"id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","displayText":"12 months"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VktQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5cQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Single Value","value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Number","uiDisplayType":"Single Value","value":123},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VkuQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_SUB","attributeconfigurable__c":true,"attributedisplaysequence__c":"50","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Subsidized","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5eQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":"Yes","sequence":1,"id":"2b5df0d6-eb1a-e9fa-950f-d6ca7614ee1e","displayText":"Yes"},{"value":"No","sequence":2,"id":"67dda21b-85c6-ce74-2955-5094c85f021c","displayText":"No"}],"default":[],"selectedItem":{"value":"No","sequence":2,"id":"67dda21b-85c6-ce74-2955-5094c85f021c","displayText":"No"}},"$$AttributeDefinitionEnd$$":null}]}';
                oli1.RoamingResAddOns__c = '15 kr, 15 kr, 15 kr';
            oli1.RoamingTillAddOns__c = '69 kr, 49 kr, 15 kr';
            /*insert oli1;
            
            oli1.vlocity_cmt__RootItemId__c = oli1.id;
            oli1.vlocity_cmt__ParentItemId__c = oli1.id;
            update oli1;*/
            offerQLI.add(oli1);
            
            QuoteLineItem oli2 = new QuoteLineItem();
            oli2.PricebookEntryId = objpricebookentry1.Id;
            oli2.TeliaSE_MC_Customer_Requested_Percentage__c=10;
            oli2.QuoteId = offerQuote.id;
            oli2.UnitPrice = 200;
            oli2.Quantity = 4;
            oli2.vlocity_cmt__Product2Id__c = prod1.id;
            oli2.Product2Id = prod1.id;
            oli2.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli2.TeliaSE_Approved__c = null;
            oli2.vlocity_cmt__RecurringCharge__c  = 200;
            oli2.TeliaSE_Ceiling_Price__c = 400;
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
            oli2.vlocity_cmt__QuoteGroupId__c = quoteGroup1.id;
            oli2.TeliaSE_MC_Binding_Time__c = '24';
            oli2.vlocity_cmt__JSONAttribute__c = '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a367Z000000PDG0QAO","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_NEG_ROAMING_TILL","attributeconfigurable__c":true,"attributedisplaysequence__c":"90","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"MC Roaming Till AddOns","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5bQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Standard 89 kr, 49 kr, 19 kr","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"}],"values":[{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"},{"value":"69 kr, 49 kr, 19 kr","sequence":2,"id":"a63eccc4-e18f-75ec-42fb-2200074c064b","displayText":"69 kr, 49 kr, 19 kr"},{"value":"59 kr, 39 kr, 19 kr","sequence":3,"id":"f5f0a872-81aa-0e6d-69a5-cb7ed4d135dd","displayText":"59 kr, 39 kr, 19 kr"},{"value":"69 kr, 49 kr, 15 kr","sequence":4,"id":"e6cd61d3-92da-312e-a4b2-e70436ac950c","displayText":"69 kr, 49 kr, 15 kr"},{"value":"59 kr, 39 kr, 15 kr","sequence":5,"id":"e32ac4bd-6719-f23c-466b-738d35a2d65d","displayText":"59 kr, 39 kr, 15 kr"},{"value":"Europa - alla anv. 49 kr, 49 kr, 19 kr","sequence":6,"id":"ad9fcac8-bd33-8736-c1a2-3d18994136de","displayText":"Europa - alla anv. 49 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 39 kr, 49 kr, 19 kr","sequence":7,"id":"183b5d9d-f0d5-f30d-d58c-7a74b0a211c3","displayText":"Europa - alla anv. 39 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 29 kr, 49 kr, 19 kr","sequence":8,"id":"551aee5a-637e-9907-beed-05b0ec37b272","displayText":"Europa - alla anv. 29 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 0 kr, 49 kr, 19 kr","sequence":9,"id":"4d405be4-e94e-b0b5-314d-d4a27ba8f3cc","displayText":"Europa - alla anv. 0 kr, 49 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 29 kr, 19 kr","sequence":10,"id":"1ba0de8b-b225-49d5-c596-4874b84c4297","displayText":"Grannland - alla anv. 89 kr, 29 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 19 kr, 19 kr","sequence":11,"id":"789c7c6f-df0b-9c54-a865-f4d93215ca88","displayText":"Grannland - alla anv. 89 kr, 19 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 0 kr, 19 kr","sequence":12,"id":"d43f776a-90ac-2ccf-0dbb-a7a5b63f6eb8","displayText":"Grannland - alla anv. 89 kr, 0 kr, 19 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 12 kr","sequence":13,"id":"ccf729aa-485a-311b-a010-cd6727d8f27a","displayText":"Utland - alla anv. 89 kr, 49 kr, 12 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 12 kr","sequence":14,"id":"be39cb66-6a44-6372-d7bf-438f130eebc3","displayText":"Utland - alla anv. 69 kr, 39 kr, 12 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 9 kr","sequence":15,"id":"454ff5e3-64bb-ca6a-6af4-b9810ae53971","displayText":"Utland - alla anv. 89 kr, 49 kr, 9 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 9 kr","sequence":16,"id":"f8ad24c8-d0bf-b09b-06a3-55ccdfbb0c71","displayText":"Utland - alla anv. 69 kr, 39 kr, 9 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 0 kr","sequence":17,"id":"97d75109-a29f-8b72-96d0-e84149d77339","displayText":"Utland - alla anv. 89 kr, 49 kr, 0 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 0 kr","sequence":18,"id":"296f3be9-3b0e-3155-e177-2b1f466e9b56","displayText":"Utland - alla anv. 69 kr, 39 kr, 0 kr"},{"value":"Europa & Utland - alla anv.  49 kr, 49 kr, 12 kr","sequence":19,"id":"2eea7313-03cb-9da5-3741-48a98cd2636b","displayText":"Europa & Utland - alla anv.  49 kr, 49 kr, 12 kr"},{"value":"Europa & Utland - alla anv. 39 kr, 49 kr, 12 kr","sequence":20,"id":"e4b437ac-32bb-b61f-708a-43f3923d0723","displayText":"Europa & Utland - alla anv. 39 kr, 49 kr, 12 kr"},{"value":"Europa & Utland - alla anv. 29 kr, 49 kr, 9 kr","sequence":21,"id":"25190e10-0c3a-419f-7cd9-ed43fe36260c","displayText":"Europa & Utland - alla anv. 29 kr, 49 kr, 9 kr"},{"value":"Europa & Utland - alla anv. 0 kr, 49 kr, 0 kr","sequence":22,"id":"263d1bda-d9ae-d7ca-3f63-04093ff493da","displayText":"Europa & Utland - alla anv. 0 kr, 49 kr, 0 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 29 kr, 12 kr","sequence":23,"id":"c355e733-ee3c-6833-5aa4-c71196e19cdb","displayText":"Grannland & Utland - alla anv. 89 kr, 29 kr, 12 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 19 kr, 9 kr","sequence":24,"id":"23bd33c8-cd75-903a-d9cc-eb820e004ba6","displayText":"Grannland & Utland - alla anv. 89 kr, 19 kr, 9 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 0 kr, 0 kr","sequence":25,"id":"fe688552-297a-a1f2-5de1-3f2fd8c5b483","displayText":"Grannland & Utland - alla anv. 89 kr, 0 kr, 0 kr"}],"selectedItem":{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VknQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_PARENT","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Parent","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5dQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"All-In Plus"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VkqQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5aQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":"12 months","sequence":1,"id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","displayText":"12 months"},{"value":"24 months","sequence":2,"id":"aba9e042-0545-92b0-b0d0-16cd00888e83","displayText":"24 months"},{"value":"36 months","sequence":3,"id":"cbdeb314-b13b-d53d-72ec-8e4c3370b908","displayText":"36 months"}],"default":[],"selectedItem":{"value":"12 months","sequence":1,"id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","displayText":"12 months"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VktQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5cQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Single Value","value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Number","uiDisplayType":"Single Value","value":123},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VkuQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_SUB","attributeconfigurable__c":true,"attributedisplaysequence__c":"50","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Subsidized","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5eQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":"Yes","sequence":1,"id":"2b5df0d6-eb1a-e9fa-950f-d6ca7614ee1e","displayText":"Yes"},{"value":"No","sequence":2,"id":"67dda21b-85c6-ce74-2955-5094c85f021c","displayText":"No"}],"default":[],"selectedItem":{"value":"No","sequence":2,"id":"67dda21b-85c6-ce74-2955-5094c85f021c","displayText":"No"}},"$$AttributeDefinitionEnd$$":null}]}';
                oli2.RoamingResAddOns__c = '15 kr, 15 kr, 15 kr';
            oli2.RoamingTillAddOns__c = '69 kr, 49 kr, 15 kr';
           /* insert oli2;
            
            oli2.vlocity_cmt__RootItemId__c = oli2.id;
            oli2.vlocity_cmt__ParentItemId__c = oli2.id;
            update oli2;*/
            offerQLI.add(oli2);
            
            QuoteLineItem oli3 = new QuoteLineItem();
            oli3.PricebookEntryId = objpricebookentry2.Id;
            oli3.TeliaSE_MC_Customer_Requested_Percentage__c=10;
            oli3.QuoteId = offerQuote.id;
            oli3.UnitPrice = 200;
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
            oli3.vlocity_cmt__QuoteGroupId__c = quoteGroup2.id;
            oli3.TeliaSE_MC_Binding_Time__c = '12';
            oli3.vlocity_cmt__JSONAttribute__c = '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a367Z000000PDG0QAO","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_NEG_ROAMING_TILL","attributeconfigurable__c":true,"attributedisplaysequence__c":"90","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"MC Roaming Till AddOns","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5bQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Standard 89 kr, 49 kr, 19 kr","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"}],"values":[{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"},{"value":"69 kr, 49 kr, 19 kr","sequence":2,"id":"a63eccc4-e18f-75ec-42fb-2200074c064b","displayText":"69 kr, 49 kr, 19 kr"},{"value":"59 kr, 39 kr, 19 kr","sequence":3,"id":"f5f0a872-81aa-0e6d-69a5-cb7ed4d135dd","displayText":"59 kr, 39 kr, 19 kr"},{"value":"69 kr, 49 kr, 15 kr","sequence":4,"id":"e6cd61d3-92da-312e-a4b2-e70436ac950c","displayText":"69 kr, 49 kr, 15 kr"},{"value":"59 kr, 39 kr, 15 kr","sequence":5,"id":"e32ac4bd-6719-f23c-466b-738d35a2d65d","displayText":"59 kr, 39 kr, 15 kr"},{"value":"Europa - alla anv. 49 kr, 49 kr, 19 kr","sequence":6,"id":"ad9fcac8-bd33-8736-c1a2-3d18994136de","displayText":"Europa - alla anv. 49 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 39 kr, 49 kr, 19 kr","sequence":7,"id":"183b5d9d-f0d5-f30d-d58c-7a74b0a211c3","displayText":"Europa - alla anv. 39 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 29 kr, 49 kr, 19 kr","sequence":8,"id":"551aee5a-637e-9907-beed-05b0ec37b272","displayText":"Europa - alla anv. 29 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 0 kr, 49 kr, 19 kr","sequence":9,"id":"4d405be4-e94e-b0b5-314d-d4a27ba8f3cc","displayText":"Europa - alla anv. 0 kr, 49 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 29 kr, 19 kr","sequence":10,"id":"1ba0de8b-b225-49d5-c596-4874b84c4297","displayText":"Grannland - alla anv. 89 kr, 29 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 19 kr, 19 kr","sequence":11,"id":"789c7c6f-df0b-9c54-a865-f4d93215ca88","displayText":"Grannland - alla anv. 89 kr, 19 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 0 kr, 19 kr","sequence":12,"id":"d43f776a-90ac-2ccf-0dbb-a7a5b63f6eb8","displayText":"Grannland - alla anv. 89 kr, 0 kr, 19 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 12 kr","sequence":13,"id":"ccf729aa-485a-311b-a010-cd6727d8f27a","displayText":"Utland - alla anv. 89 kr, 49 kr, 12 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 12 kr","sequence":14,"id":"be39cb66-6a44-6372-d7bf-438f130eebc3","displayText":"Utland - alla anv. 69 kr, 39 kr, 12 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 9 kr","sequence":15,"id":"454ff5e3-64bb-ca6a-6af4-b9810ae53971","displayText":"Utland - alla anv. 89 kr, 49 kr, 9 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 9 kr","sequence":16,"id":"f8ad24c8-d0bf-b09b-06a3-55ccdfbb0c71","displayText":"Utland - alla anv. 69 kr, 39 kr, 9 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 0 kr","sequence":17,"id":"97d75109-a29f-8b72-96d0-e84149d77339","displayText":"Utland - alla anv. 89 kr, 49 kr, 0 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 0 kr","sequence":18,"id":"296f3be9-3b0e-3155-e177-2b1f466e9b56","displayText":"Utland - alla anv. 69 kr, 39 kr, 0 kr"},{"value":"Europa & Utland - alla anv.  49 kr, 49 kr, 12 kr","sequence":19,"id":"2eea7313-03cb-9da5-3741-48a98cd2636b","displayText":"Europa & Utland - alla anv.  49 kr, 49 kr, 12 kr"},{"value":"Europa & Utland - alla anv. 39 kr, 49 kr, 12 kr","sequence":20,"id":"e4b437ac-32bb-b61f-708a-43f3923d0723","displayText":"Europa & Utland - alla anv. 39 kr, 49 kr, 12 kr"},{"value":"Europa & Utland - alla anv. 29 kr, 49 kr, 9 kr","sequence":21,"id":"25190e10-0c3a-419f-7cd9-ed43fe36260c","displayText":"Europa & Utland - alla anv. 29 kr, 49 kr, 9 kr"},{"value":"Europa & Utland - alla anv. 0 kr, 49 kr, 0 kr","sequence":22,"id":"263d1bda-d9ae-d7ca-3f63-04093ff493da","displayText":"Europa & Utland - alla anv. 0 kr, 49 kr, 0 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 29 kr, 12 kr","sequence":23,"id":"c355e733-ee3c-6833-5aa4-c71196e19cdb","displayText":"Grannland & Utland - alla anv. 89 kr, 29 kr, 12 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 19 kr, 9 kr","sequence":24,"id":"23bd33c8-cd75-903a-d9cc-eb820e004ba6","displayText":"Grannland & Utland - alla anv. 89 kr, 19 kr, 9 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 0 kr, 0 kr","sequence":25,"id":"fe688552-297a-a1f2-5de1-3f2fd8c5b483","displayText":"Grannland & Utland - alla anv. 89 kr, 0 kr, 0 kr"}],"selectedItem":{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VknQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_PARENT","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Parent","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5dQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"All-In Plus"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VkqQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5aQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":"12 months","sequence":1,"id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","displayText":"12 months"},{"value":"24 months","sequence":2,"id":"aba9e042-0545-92b0-b0d0-16cd00888e83","displayText":"24 months"},{"value":"36 months","sequence":3,"id":"cbdeb314-b13b-d53d-72ec-8e4c3370b908","displayText":"36 months"}],"default":[],"selectedItem":{"value":"12 months","sequence":1,"id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","displayText":"12 months"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VktQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5cQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Single Value","value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Number","uiDisplayType":"Single Value","value":123},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VkuQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_SUB","attributeconfigurable__c":true,"attributedisplaysequence__c":"50","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Subsidized","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5eQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":"Yes","sequence":1,"id":"2b5df0d6-eb1a-e9fa-950f-d6ca7614ee1e","displayText":"Yes"},{"value":"No","sequence":2,"id":"67dda21b-85c6-ce74-2955-5094c85f021c","displayText":"No"}],"default":[],"selectedItem":{"value":"No","sequence":2,"id":"67dda21b-85c6-ce74-2955-5094c85f021c","displayText":"No"}},"$$AttributeDefinitionEnd$$":null}]}';
                oli3.RoamingResAddOns__c = '15 kr, 15 kr, 15 kr';
            oli3.RoamingTillAddOns__c = '69 kr, 49 kr, 15 kr';
            /*insert oli3;
            
            oli3.vlocity_cmt__RootItemId__c = oli3.id;
            oli3.vlocity_cmt__ParentItemId__c = oli3.id;
            update oli3;*/
            offerQLI.add(oli3);
            
            QuoteLineItem oli4 = new QuoteLineItem();
            oli4.PricebookEntryId = objpricebookentry5.Id;
            oli4.TeliaSE_MC_Customer_Requested_Percentage__c=10;
            oli4.QuoteId = offerQuote.id;
            oli4.UnitPrice = 200;
            oli4.Quantity = 4;
            oli4.vlocity_cmt__Product2Id__c = prod5.id;
            oli4.Product2Id = prod5.id;
            oli4.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli4.TeliaSE_Approved__c = null;
            oli4.vlocity_cmt__RecurringCharge__c  = 200;
            oli4.TeliaSE_Ceiling_Price__c = 400;
            oli4.TeliaSE_Root_Product__c=prod5.id;
            oli4.vlocity_cmt__ProductHierarchyPath__c = prod5.id;
            oli4.TeliaSE_Base_Quantity__c = '123';
            oli4.vlocity_cmt__OneTimeCharge__c = 200;
            oli4.MC_OT_AM_Mandate_Percentage__c = 10;
            oli4.MC_OT_SM_Mandate_Percentage__c = 10;
            oli4.MC_OT_SD_Mandate_Percentage__c = 10;
            oli4.MC_OT_CM_Mandate_Percentage__c = 10;
            oli4.TeliaSE_AM_Mandate_Percentage__c = 10;
            oli4.TeliaSE_SM_Mandate_Percentage__c = 10;
            oli4.TeliaSE_SD_Mandate_Percentage__c = 10;
            oli4.TeliaSE_CM_Mandate_Percentage__c = 10;
            oli4.vlocity_cmt__QuoteGroupId__c = quoteGroup2.id;
            oli4.TeliaSE_MC_Binding_Time__c = '12';
            oli4.vlocity_cmt__JSONAttribute__c = '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a367Z000000PDG0QAO","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_NEG_ROAMING_TILL","attributeconfigurable__c":true,"attributedisplaysequence__c":"90","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"MC Roaming Till AddOns","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5bQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Standard 89 kr, 49 kr, 19 kr","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"}],"values":[{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"},{"value":"69 kr, 49 kr, 19 kr","sequence":2,"id":"a63eccc4-e18f-75ec-42fb-2200074c064b","displayText":"69 kr, 49 kr, 19 kr"},{"value":"59 kr, 39 kr, 19 kr","sequence":3,"id":"f5f0a872-81aa-0e6d-69a5-cb7ed4d135dd","displayText":"59 kr, 39 kr, 19 kr"},{"value":"69 kr, 49 kr, 15 kr","sequence":4,"id":"e6cd61d3-92da-312e-a4b2-e70436ac950c","displayText":"69 kr, 49 kr, 15 kr"},{"value":"59 kr, 39 kr, 15 kr","sequence":5,"id":"e32ac4bd-6719-f23c-466b-738d35a2d65d","displayText":"59 kr, 39 kr, 15 kr"},{"value":"Europa - alla anv. 49 kr, 49 kr, 19 kr","sequence":6,"id":"ad9fcac8-bd33-8736-c1a2-3d18994136de","displayText":"Europa - alla anv. 49 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 39 kr, 49 kr, 19 kr","sequence":7,"id":"183b5d9d-f0d5-f30d-d58c-7a74b0a211c3","displayText":"Europa - alla anv. 39 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 29 kr, 49 kr, 19 kr","sequence":8,"id":"551aee5a-637e-9907-beed-05b0ec37b272","displayText":"Europa - alla anv. 29 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 0 kr, 49 kr, 19 kr","sequence":9,"id":"4d405be4-e94e-b0b5-314d-d4a27ba8f3cc","displayText":"Europa - alla anv. 0 kr, 49 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 29 kr, 19 kr","sequence":10,"id":"1ba0de8b-b225-49d5-c596-4874b84c4297","displayText":"Grannland - alla anv. 89 kr, 29 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 19 kr, 19 kr","sequence":11,"id":"789c7c6f-df0b-9c54-a865-f4d93215ca88","displayText":"Grannland - alla anv. 89 kr, 19 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 0 kr, 19 kr","sequence":12,"id":"d43f776a-90ac-2ccf-0dbb-a7a5b63f6eb8","displayText":"Grannland - alla anv. 89 kr, 0 kr, 19 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 12 kr","sequence":13,"id":"ccf729aa-485a-311b-a010-cd6727d8f27a","displayText":"Utland - alla anv. 89 kr, 49 kr, 12 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 12 kr","sequence":14,"id":"be39cb66-6a44-6372-d7bf-438f130eebc3","displayText":"Utland - alla anv. 69 kr, 39 kr, 12 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 9 kr","sequence":15,"id":"454ff5e3-64bb-ca6a-6af4-b9810ae53971","displayText":"Utland - alla anv. 89 kr, 49 kr, 9 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 9 kr","sequence":16,"id":"f8ad24c8-d0bf-b09b-06a3-55ccdfbb0c71","displayText":"Utland - alla anv. 69 kr, 39 kr, 9 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 0 kr","sequence":17,"id":"97d75109-a29f-8b72-96d0-e84149d77339","displayText":"Utland - alla anv. 89 kr, 49 kr, 0 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 0 kr","sequence":18,"id":"296f3be9-3b0e-3155-e177-2b1f466e9b56","displayText":"Utland - alla anv. 69 kr, 39 kr, 0 kr"},{"value":"Europa & Utland - alla anv.  49 kr, 49 kr, 12 kr","sequence":19,"id":"2eea7313-03cb-9da5-3741-48a98cd2636b","displayText":"Europa & Utland - alla anv.  49 kr, 49 kr, 12 kr"},{"value":"Europa & Utland - alla anv. 39 kr, 49 kr, 12 kr","sequence":20,"id":"e4b437ac-32bb-b61f-708a-43f3923d0723","displayText":"Europa & Utland - alla anv. 39 kr, 49 kr, 12 kr"},{"value":"Europa & Utland - alla anv. 29 kr, 49 kr, 9 kr","sequence":21,"id":"25190e10-0c3a-419f-7cd9-ed43fe36260c","displayText":"Europa & Utland - alla anv. 29 kr, 49 kr, 9 kr"},{"value":"Europa & Utland - alla anv. 0 kr, 49 kr, 0 kr","sequence":22,"id":"263d1bda-d9ae-d7ca-3f63-04093ff493da","displayText":"Europa & Utland - alla anv. 0 kr, 49 kr, 0 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 29 kr, 12 kr","sequence":23,"id":"c355e733-ee3c-6833-5aa4-c71196e19cdb","displayText":"Grannland & Utland - alla anv. 89 kr, 29 kr, 12 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 19 kr, 9 kr","sequence":24,"id":"23bd33c8-cd75-903a-d9cc-eb820e004ba6","displayText":"Grannland & Utland - alla anv. 89 kr, 19 kr, 9 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 0 kr, 0 kr","sequence":25,"id":"fe688552-297a-a1f2-5de1-3f2fd8c5b483","displayText":"Grannland & Utland - alla anv. 89 kr, 0 kr, 0 kr"}],"selectedItem":{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VknQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_PARENT","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Parent","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5dQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"All-In Plus"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VkqQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5aQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":"12 months","sequence":1,"id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","displayText":"12 months"},{"value":"24 months","sequence":2,"id":"aba9e042-0545-92b0-b0d0-16cd00888e83","displayText":"24 months"},{"value":"36 months","sequence":3,"id":"cbdeb314-b13b-d53d-72ec-8e4c3370b908","displayText":"36 months"}],"default":[],"selectedItem":{"value":"12 months","sequence":1,"id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","displayText":"12 months"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VktQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5cQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Single Value","value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Number","uiDisplayType":"Single Value","value":123},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VkuQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_SUB","attributeconfigurable__c":true,"attributedisplaysequence__c":"50","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Subsidized","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5eQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":"Yes","sequence":1,"id":"2b5df0d6-eb1a-e9fa-950f-d6ca7614ee1e","displayText":"Yes"},{"value":"No","sequence":2,"id":"67dda21b-85c6-ce74-2955-5094c85f021c","displayText":"No"}],"default":[],"selectedItem":{"value":"No","sequence":2,"id":"67dda21b-85c6-ce74-2955-5094c85f021c","displayText":"No"}},"$$AttributeDefinitionEnd$$":null}]}';
                oli4.RoamingResAddOns__c = '15 kr, 15 kr, 15 kr';
            oli4.RoamingTillAddOns__c = '69 kr, 49 kr, 15 kr';
            /*insert oli4;
            
            oli4.vlocity_cmt__RootItemId__c = oli4.id;
            oli4.vlocity_cmt__ParentItemId__c = oli4.id;
            update oli4;*/
            offerQLI.add(oli4);
            QuoteLineItem oli5 = new QuoteLineItem();
            oli5.PricebookEntryId = objpricebookentry6.Id;
            oli5.TeliaSE_MC_Customer_Requested_Percentage__c=10;
            oli5.QuoteId = offerQuote.id;
            oli5.UnitPrice = 200;
            oli5.Quantity = 4;
            oli5.vlocity_cmt__Product2Id__c = prod6.id;
            oli5.Product2Id = prod6.id;
            oli5.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli5.TeliaSE_Approved__c = null;
            oli5.vlocity_cmt__RecurringCharge__c  = 200;
            oli5.TeliaSE_Ceiling_Price__c = 400;
            oli5.TeliaSE_Root_Product__c=prod6.id;
            oli5.vlocity_cmt__ProductHierarchyPath__c = prod1.id+'<'+prod6.id;
            oli5.TeliaSE_Base_Quantity__c = '123';
            oli5.vlocity_cmt__OneTimeCharge__c = 200;
            oli5.MC_OT_AM_Mandate_Percentage__c = 10;
            oli5.MC_OT_SM_Mandate_Percentage__c = 10;
            oli5.MC_OT_SD_Mandate_Percentage__c = 10;
            oli5.MC_OT_CM_Mandate_Percentage__c = 10;
            oli5.TeliaSE_AM_Mandate_Percentage__c = 10;
            oli5.TeliaSE_SM_Mandate_Percentage__c = 10;
            oli5.TeliaSE_SD_Mandate_Percentage__c = 10;
            oli5.TeliaSE_CM_Mandate_Percentage__c = 10;
            oli5.vlocity_cmt__QuoteGroupId__c = quoteGroup2.id;
            oli5.TeliaSE_MC_Binding_Time__c = '12';
            oli5.vlocity_cmt__JSONAttribute__c = '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a367Z000000PDG0QAO","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_NEG_ROAMING_TILL","attributeconfigurable__c":true,"attributedisplaysequence__c":"90","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"MC Roaming Till AddOns","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5bQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Standard 89 kr, 49 kr, 19 kr","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"}],"values":[{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"},{"value":"69 kr, 49 kr, 19 kr","sequence":2,"id":"a63eccc4-e18f-75ec-42fb-2200074c064b","displayText":"69 kr, 49 kr, 19 kr"},{"value":"59 kr, 39 kr, 19 kr","sequence":3,"id":"f5f0a872-81aa-0e6d-69a5-cb7ed4d135dd","displayText":"59 kr, 39 kr, 19 kr"},{"value":"69 kr, 49 kr, 15 kr","sequence":4,"id":"e6cd61d3-92da-312e-a4b2-e70436ac950c","displayText":"69 kr, 49 kr, 15 kr"},{"value":"59 kr, 39 kr, 15 kr","sequence":5,"id":"e32ac4bd-6719-f23c-466b-738d35a2d65d","displayText":"59 kr, 39 kr, 15 kr"},{"value":"Europa - alla anv. 49 kr, 49 kr, 19 kr","sequence":6,"id":"ad9fcac8-bd33-8736-c1a2-3d18994136de","displayText":"Europa - alla anv. 49 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 39 kr, 49 kr, 19 kr","sequence":7,"id":"183b5d9d-f0d5-f30d-d58c-7a74b0a211c3","displayText":"Europa - alla anv. 39 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 29 kr, 49 kr, 19 kr","sequence":8,"id":"551aee5a-637e-9907-beed-05b0ec37b272","displayText":"Europa - alla anv. 29 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 0 kr, 49 kr, 19 kr","sequence":9,"id":"4d405be4-e94e-b0b5-314d-d4a27ba8f3cc","displayText":"Europa - alla anv. 0 kr, 49 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 29 kr, 19 kr","sequence":10,"id":"1ba0de8b-b225-49d5-c596-4874b84c4297","displayText":"Grannland - alla anv. 89 kr, 29 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 19 kr, 19 kr","sequence":11,"id":"789c7c6f-df0b-9c54-a865-f4d93215ca88","displayText":"Grannland - alla anv. 89 kr, 19 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 0 kr, 19 kr","sequence":12,"id":"d43f776a-90ac-2ccf-0dbb-a7a5b63f6eb8","displayText":"Grannland - alla anv. 89 kr, 0 kr, 19 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 12 kr","sequence":13,"id":"ccf729aa-485a-311b-a010-cd6727d8f27a","displayText":"Utland - alla anv. 89 kr, 49 kr, 12 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 12 kr","sequence":14,"id":"be39cb66-6a44-6372-d7bf-438f130eebc3","displayText":"Utland - alla anv. 69 kr, 39 kr, 12 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 9 kr","sequence":15,"id":"454ff5e3-64bb-ca6a-6af4-b9810ae53971","displayText":"Utland - alla anv. 89 kr, 49 kr, 9 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 9 kr","sequence":16,"id":"f8ad24c8-d0bf-b09b-06a3-55ccdfbb0c71","displayText":"Utland - alla anv. 69 kr, 39 kr, 9 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 0 kr","sequence":17,"id":"97d75109-a29f-8b72-96d0-e84149d77339","displayText":"Utland - alla anv. 89 kr, 49 kr, 0 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 0 kr","sequence":18,"id":"296f3be9-3b0e-3155-e177-2b1f466e9b56","displayText":"Utland - alla anv. 69 kr, 39 kr, 0 kr"},{"value":"Europa & Utland - alla anv.  49 kr, 49 kr, 12 kr","sequence":19,"id":"2eea7313-03cb-9da5-3741-48a98cd2636b","displayText":"Europa & Utland - alla anv.  49 kr, 49 kr, 12 kr"},{"value":"Europa & Utland - alla anv. 39 kr, 49 kr, 12 kr","sequence":20,"id":"e4b437ac-32bb-b61f-708a-43f3923d0723","displayText":"Europa & Utland - alla anv. 39 kr, 49 kr, 12 kr"},{"value":"Europa & Utland - alla anv. 29 kr, 49 kr, 9 kr","sequence":21,"id":"25190e10-0c3a-419f-7cd9-ed43fe36260c","displayText":"Europa & Utland - alla anv. 29 kr, 49 kr, 9 kr"},{"value":"Europa & Utland - alla anv. 0 kr, 49 kr, 0 kr","sequence":22,"id":"263d1bda-d9ae-d7ca-3f63-04093ff493da","displayText":"Europa & Utland - alla anv. 0 kr, 49 kr, 0 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 29 kr, 12 kr","sequence":23,"id":"c355e733-ee3c-6833-5aa4-c71196e19cdb","displayText":"Grannland & Utland - alla anv. 89 kr, 29 kr, 12 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 19 kr, 9 kr","sequence":24,"id":"23bd33c8-cd75-903a-d9cc-eb820e004ba6","displayText":"Grannland & Utland - alla anv. 89 kr, 19 kr, 9 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 0 kr, 0 kr","sequence":25,"id":"fe688552-297a-a1f2-5de1-3f2fd8c5b483","displayText":"Grannland & Utland - alla anv. 89 kr, 0 kr, 0 kr"}],"selectedItem":{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VknQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_PARENT","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Parent","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5dQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"All-In Plus"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VkqQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5aQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":"12 months","sequence":1,"id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","displayText":"12 months"},{"value":"24 months","sequence":2,"id":"aba9e042-0545-92b0-b0d0-16cd00888e83","displayText":"24 months"},{"value":"36 months","sequence":3,"id":"cbdeb314-b13b-d53d-72ec-8e4c3370b908","displayText":"36 months"}],"default":[],"selectedItem":{"value":"12 months","sequence":1,"id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","displayText":"12 months"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VktQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5cQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Single Value","value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Number","uiDisplayType":"Single Value","value":123},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VkuQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_SUB","attributeconfigurable__c":true,"attributedisplaysequence__c":"50","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Subsidized","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5eQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":"Yes","sequence":1,"id":"2b5df0d6-eb1a-e9fa-950f-d6ca7614ee1e","displayText":"Yes"},{"value":"No","sequence":2,"id":"67dda21b-85c6-ce74-2955-5094c85f021c","displayText":"No"}],"default":[],"selectedItem":{"value":"No","sequence":2,"id":"67dda21b-85c6-ce74-2955-5094c85f021c","displayText":"No"}},"$$AttributeDefinitionEnd$$":null}]}';
                oli5.RoamingResAddOns__c = '15 kr, 15 kr, 15 kr';
            oli5.RoamingTillAddOns__c = '69 kr, 49 kr, 15 kr';
            /*insert oli5;
            
            oli5.vlocity_cmt__RootItemId__c = '';
            oli5.vlocity_cmt__ParentItemId__c = oli1.id;
            update oli5;*/
           offerQLI.add(oli5);
            
            QuoteLineItem oli6 = new QuoteLineItem();
            oli6.PricebookEntryId = objpricebookentry4.Id;
            oli6.TeliaSE_MC_Customer_Requested_Percentage__c=10;
            oli6.QuoteId = offerQuote.id;
            oli6.UnitPrice = 200;
            oli6.Quantity = 4;
            oli6.vlocity_cmt__Product2Id__c = prod4.id;
            oli6.Product2Id = prod4.id;
            oli6.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            oli6.TeliaSE_Approved__c = null;
            oli6.vlocity_cmt__RecurringCharge__c  = 200;
            oli6.TeliaSE_Ceiling_Price__c = 400;
            oli6.TeliaSE_Root_Product__c=prod4.id;
            oli6.vlocity_cmt__ProductHierarchyPath__c = prod1.id+'<'+prod4.id;
            oli6.TeliaSE_Base_Quantity__c = '123';
            oli6.vlocity_cmt__OneTimeCharge__c = 200;
            oli6.MC_OT_AM_Mandate_Percentage__c = 10;
            oli6.MC_OT_SM_Mandate_Percentage__c = 10;
            oli6.MC_OT_SD_Mandate_Percentage__c = 10;
            oli6.MC_OT_CM_Mandate_Percentage__c = 10;
            oli6.TeliaSE_AM_Mandate_Percentage__c = 10;
            oli6.TeliaSE_SM_Mandate_Percentage__c = 10;
            oli6.TeliaSE_SD_Mandate_Percentage__c = 10;
            oli6.TeliaSE_CM_Mandate_Percentage__c = 10;
            oli6.vlocity_cmt__QuoteGroupId__c = quoteGroup2.id;
            oli6.TeliaSE_MC_Binding_Time__c = '12';
            oli6.vlocity_cmt__JSONAttribute__c = '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a367Z000000PDG0QAO","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_NEG_ROAMING_TILL","attributeconfigurable__c":true,"attributedisplaysequence__c":"90","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"MC Roaming Till AddOns","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5bQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Standard 89 kr, 49 kr, 19 kr","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"}],"values":[{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"},{"value":"69 kr, 49 kr, 19 kr","sequence":2,"id":"a63eccc4-e18f-75ec-42fb-2200074c064b","displayText":"69 kr, 49 kr, 19 kr"},{"value":"59 kr, 39 kr, 19 kr","sequence":3,"id":"f5f0a872-81aa-0e6d-69a5-cb7ed4d135dd","displayText":"59 kr, 39 kr, 19 kr"},{"value":"69 kr, 49 kr, 15 kr","sequence":4,"id":"e6cd61d3-92da-312e-a4b2-e70436ac950c","displayText":"69 kr, 49 kr, 15 kr"},{"value":"59 kr, 39 kr, 15 kr","sequence":5,"id":"e32ac4bd-6719-f23c-466b-738d35a2d65d","displayText":"59 kr, 39 kr, 15 kr"},{"value":"Europa - alla anv. 49 kr, 49 kr, 19 kr","sequence":6,"id":"ad9fcac8-bd33-8736-c1a2-3d18994136de","displayText":"Europa - alla anv. 49 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 39 kr, 49 kr, 19 kr","sequence":7,"id":"183b5d9d-f0d5-f30d-d58c-7a74b0a211c3","displayText":"Europa - alla anv. 39 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 29 kr, 49 kr, 19 kr","sequence":8,"id":"551aee5a-637e-9907-beed-05b0ec37b272","displayText":"Europa - alla anv. 29 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 0 kr, 49 kr, 19 kr","sequence":9,"id":"4d405be4-e94e-b0b5-314d-d4a27ba8f3cc","displayText":"Europa - alla anv. 0 kr, 49 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 29 kr, 19 kr","sequence":10,"id":"1ba0de8b-b225-49d5-c596-4874b84c4297","displayText":"Grannland - alla anv. 89 kr, 29 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 19 kr, 19 kr","sequence":11,"id":"789c7c6f-df0b-9c54-a865-f4d93215ca88","displayText":"Grannland - alla anv. 89 kr, 19 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 0 kr, 19 kr","sequence":12,"id":"d43f776a-90ac-2ccf-0dbb-a7a5b63f6eb8","displayText":"Grannland - alla anv. 89 kr, 0 kr, 19 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 12 kr","sequence":13,"id":"ccf729aa-485a-311b-a010-cd6727d8f27a","displayText":"Utland - alla anv. 89 kr, 49 kr, 12 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 12 kr","sequence":14,"id":"be39cb66-6a44-6372-d7bf-438f130eebc3","displayText":"Utland - alla anv. 69 kr, 39 kr, 12 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 9 kr","sequence":15,"id":"454ff5e3-64bb-ca6a-6af4-b9810ae53971","displayText":"Utland - alla anv. 89 kr, 49 kr, 9 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 9 kr","sequence":16,"id":"f8ad24c8-d0bf-b09b-06a3-55ccdfbb0c71","displayText":"Utland - alla anv. 69 kr, 39 kr, 9 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 0 kr","sequence":17,"id":"97d75109-a29f-8b72-96d0-e84149d77339","displayText":"Utland - alla anv. 89 kr, 49 kr, 0 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 0 kr","sequence":18,"id":"296f3be9-3b0e-3155-e177-2b1f466e9b56","displayText":"Utland - alla anv. 69 kr, 39 kr, 0 kr"},{"value":"Europa & Utland - alla anv.  49 kr, 49 kr, 12 kr","sequence":19,"id":"2eea7313-03cb-9da5-3741-48a98cd2636b","displayText":"Europa & Utland - alla anv.  49 kr, 49 kr, 12 kr"},{"value":"Europa & Utland - alla anv. 39 kr, 49 kr, 12 kr","sequence":20,"id":"e4b437ac-32bb-b61f-708a-43f3923d0723","displayText":"Europa & Utland - alla anv. 39 kr, 49 kr, 12 kr"},{"value":"Europa & Utland - alla anv. 29 kr, 49 kr, 9 kr","sequence":21,"id":"25190e10-0c3a-419f-7cd9-ed43fe36260c","displayText":"Europa & Utland - alla anv. 29 kr, 49 kr, 9 kr"},{"value":"Europa & Utland - alla anv. 0 kr, 49 kr, 0 kr","sequence":22,"id":"263d1bda-d9ae-d7ca-3f63-04093ff493da","displayText":"Europa & Utland - alla anv. 0 kr, 49 kr, 0 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 29 kr, 12 kr","sequence":23,"id":"c355e733-ee3c-6833-5aa4-c71196e19cdb","displayText":"Grannland & Utland - alla anv. 89 kr, 29 kr, 12 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 19 kr, 9 kr","sequence":24,"id":"23bd33c8-cd75-903a-d9cc-eb820e004ba6","displayText":"Grannland & Utland - alla anv. 89 kr, 19 kr, 9 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 0 kr, 0 kr","sequence":25,"id":"fe688552-297a-a1f2-5de1-3f2fd8c5b483","displayText":"Grannland & Utland - alla anv. 89 kr, 0 kr, 0 kr"}],"selectedItem":{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VknQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_PARENT","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Parent","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5dQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"All-In Plus"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VkqQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5aQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":"12 months","sequence":1,"id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","displayText":"12 months"},{"value":"24 months","sequence":2,"id":"aba9e042-0545-92b0-b0d0-16cd00888e83","displayText":"24 months"},{"value":"36 months","sequence":3,"id":"cbdeb314-b13b-d53d-72ec-8e4c3370b908","displayText":"36 months"}],"default":[],"selectedItem":{"value":"12 months","sequence":1,"id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","displayText":"12 months"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VktQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5cQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Single Value","value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Number","uiDisplayType":"Single Value","value":123},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VkuQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_SUB","attributeconfigurable__c":true,"attributedisplaysequence__c":"50","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Subsidized","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5eQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":"Yes","sequence":1,"id":"2b5df0d6-eb1a-e9fa-950f-d6ca7614ee1e","displayText":"Yes"},{"value":"No","sequence":2,"id":"67dda21b-85c6-ce74-2955-5094c85f021c","displayText":"No"}],"default":[],"selectedItem":{"value":"No","sequence":2,"id":"67dda21b-85c6-ce74-2955-5094c85f021c","displayText":"No"}},"$$AttributeDefinitionEnd$$":null}]}';
                oli6.RoamingResAddOns__c = '15 kr, 15 kr, 15 kr';
            oli6.RoamingTillAddOns__c = '69 kr, 49 kr, 15 kr';
            /*insert oli6;
            
            oli6.vlocity_cmt__RootItemId__c = null;
            update oli6;*/
            offerQLI.add(oli6);
            
           insert offerQLI;
            oli5.vlocity_cmt__RootItemId__c = '';
            oli5.vlocity_cmt__ParentItemId__c = oli1.id;
            update oli5;
            oli6.vlocity_cmt__RootItemId__c = '';
            oli6.vlocity_cmt__ParentItemId__c = oli1.id;
            update oli6;
            /*oli1.vlocity_cmt__ParentItemId__c = oli1.id;
            update oli1;*/
            Id serviceAccountId = oli5.vlocity_cmt__ServiceAccountId__c;
          /* list<QuoteLineItem> updateOfferQuoteLineItem = new list<QuoteLineItem>();
            id rootTeliaBredbandPro = null;
            id parentProductLineItem = null;
            for( QuoteLineItem qLI:offerQLI){
                id lineItemId = qLI.id;
                if( qLI.Product2Id == prod1.id || qLI.Product2Id == prod6.id){
                    if( qLI.Product2Id == prod1.id){
                    rootTeliaBredbandPro = lineItemId;
                    }
                    if( qLI.Product2Id == prod6.id){
                        qLI.vlocity_cmt__ParentItemId__c = rootTeliaBredbandPro;
                    }
                }
                else
                qLI.vlocity_cmt__RootItemId__c = lineItemId;
                updateOfferQuoteLineItem.add(qLI);
            }
            update updateOfferQuoteLineItem;*/
          
            //End of quote creation for grouping logic Started from line number 102
           
            Map<String,Object> inputMap=new Map<String,Object>();
            Map<String,Object> inputMap1=new Map<String,Object>();
            Map<String,Object> outMap=new Map<String,Object>();
            Map<String,Object> options=new Map<String,Object>();
            inputMap.put('FAquoteId', faQuote.id);
            inputMap.put('accountName',acc.Name );
            inputMap.put('accountOrgNumber',acc.Org_Nr__c );
            inputMap.put('contractId', contract.id);
            inputMap.put('contractNumber',contract.ContractNumber );
            inputMap.put('ownerName','Soho Ds SalesRep' );
            date endDate = contract.EndDate;
            date startDate = contract.StartDate;
           /* string conEndDate = endDate.format('dd/MM/yyyy');
            string conStartDate = startDate.format('dd/MM/yyyy');*/
            inputMap.put('AgreementEndDate', '09/28/2023');
            inputMap.put('AgreementStartDate', '08/18/2021');
            
            test.startTest();
            TeliaSE_OrderExtractExcel orderExtractValidate = new TeliaSE_OrderExtractExcel();
            orderExtractValidate.invokeMethod('excelConvert', inputMap, outMap, options);
            orderExtractValidate.invokeMethod('excelConvert', inputMap1, outMap, options);
            orderExtractValidate.invokeMethod('NA', inputMap, outMap, options);
          /* list<QuoteLineItem> updateOfferQuoteLineItem_NonGrouping = new list<QuoteLineItem>();
            for( QuoteLineItem qLI:updateOfferQuoteLineItem){
                id lineItemId = qLI.id;
                qLI.vlocity_cmt__QuoteGroupId__c = null;
                updateOfferQuoteLineItem_NonGrouping.add(qLI);
            }
            update updateOfferQuoteLineItem_NonGrouping;
            updateOfferQuoteLineItem_NonGrouping = null;*/
            
            premise.vlocity_cmt__PropertyOwnerAccountId__c = serviceAccountId;
            update premise;
            premise1.vlocity_cmt__PropertyOwnerAccountId__c = serviceAccountId;
            update premise1;
            premise2.vlocity_cmt__PropertyOwnerAccountId__c = serviceAccountId;
            update premise2;
            premise3.vlocity_cmt__PropertyOwnerAccountId__c = serviceAccountId;
            update premise3;
            premise4.vlocity_cmt__PropertyOwnerAccountId__c = serviceAccountId;
            update premise4;
            
            oli1.vlocity_cmt__QuoteGroupId__c = null;
            update oli1;
            oli2.vlocity_cmt__QuoteGroupId__c = null;
            update oli2;
            oli3.vlocity_cmt__QuoteGroupId__c = null;
            update oli3;
            oli4.vlocity_cmt__QuoteGroupId__c = null;
            update oli4;
            oli5.vlocity_cmt__QuoteGroupId__c = null;
            update oli5;
            oli6.vlocity_cmt__QuoteGroupId__c = null;
            update oli6;
            orderExtractValidate.invokeMethod('excelConvert', inputMap, outMap, options);
            test.stopTest();
        }
    }
    // TestCoverage method for LTAT- 6009
    @isTest
    static void testGroupSorting() {
        List<String> unsortedList = new List<String> {
            'Group 2: map2',
                'Group 1: map1',
                'Group 3: map3'
                };
        List<String> sortedList = TeliaSE_OrderExtractExcel.orderExtractGroupSorting(unsortedList);
        List<String> expectedList = new List<String> {
            'Group 1: map1',
                'Group 2: map2',
                'Group 3: map3'
                };
        System.assertEquals(expectedList, sortedList);
    }
}