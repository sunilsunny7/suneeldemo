@isTest
public with sharing class MC_TeliaSE_OfferDocCreation_Test {
    @isTest
    public static void FunctionEval8(){
        User salesManager;         
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        salesManager = Test_DataFactory.createAdminUser();
        salesManager.ForecastEnabled = true;
        salesManager.Bypass_VR__c = true;
        insert salesManager;
        System.runAs(salesManager){
            Map<String,Object> inputs=new Map<String,Object>();
            Map<String,Object> output=new Map<String,Object>();
            Map<String,Object> options=new Map<String,Object>();
            
            
            vlocity_cmt__ObjectClass__c newObj=new vlocity_cmt__ObjectClass__c();
            newObj.Name = 'Connected Office Offer Spec';
            newObj.vlocity_cmt__IsActive__c = true;
            newObj.vlocity_cmt__ObjectApiName__c ='Product2';
            insert newObj;
            
            vlocity_cmt__ObjectClass__c newObj1=new vlocity_cmt__ObjectClass__c();
            newObj1.Name = 'Broadband Datanet Offering Spec';
            newObj1.vlocity_cmt__IsActive__c = true;
            newObj1.vlocity_cmt__ObjectApiName__c ='Product2';
            insert newObj1;
            
            vlocity_cmt__ObjectClass__c newObj2=new vlocity_cmt__ObjectClass__c();
            newObj2.Name = 'TouchPoint Plus Offer Spec';
            newObj2.vlocity_cmt__IsActive__c = true;
            newObj2.vlocity_cmt__ObjectApiName__c ='Product2';
            insert newObj2;
            
            List<Product2> prodList = new List<product2>();
            
            Product2 prod = Test_DataFactory.createProducts(1)[0];
            prod.name = 'Access Multi 10 Mbit/s';
            prod.productCode = 'CO-DATANET-ACCESS-MULTI-10MB';
            prod.vlocity_cmt__ObjectTypeId__c = newObj1.Id;
            prod.TeliaSE_OfferTemplateFlag__c=true;
            prod.TeliaSE_TemplateCategory__c='CO_alone';
            prod.MC_Product_Name_Eng__c='Telia Datanet';
            prodList.add(prod); 
            
            Product2 prod1 = Test_DataFactory.createProducts(1)[0];
            prod1.name = 'Access Multi 100 Mbit/s';
            prod1.productCode = 'CO-DATANET-ACCESS-MULTI-100MB';
            prod1.vlocity_cmt__ObjectTypeId__c = newObj1.Id;
            prod1.TeliaSE_OfferTemplateFlag__c=true;
            prod1.TeliaSE_TemplateCategory__c='CO_secondary';
            prod1.MC_Product_Name_Eng__c='Telia Bredband Pro';
            prodList.add(prod1);            
            
            Product2 prod2 = Test_DataFactory.createProducts(1)[0];
            prod2.Name = 'Tillval Backup';
            prod2.productCode = 'CO-DATANET-TILLVAL-BACKUP';
            prod2.vlocity_cmt__ObjectTypeId__c = newObj1.Id;
            prodList.add(prod2);
            
            Product2 prod3 = Test_DataFactory.createProducts(1)[0];
            prod3.Name = 'Access Basic Wireless 4G Backup';
            prod3.productCode = 'CO-DATANET-ACCESS-BASIC-4G';
            prod3.vlocity_cmt__ObjectTypeId__c = newObj1.Id;
            prodList.add(prod3);
            
            Product2 prod4 = Test_DataFactory.createProducts(1)[0];
            prod4.Name = 'Access Basic Wireless 4G Backup Combo CPE';
            prod4.productCode = 'CO-DATANET-ACCESS-BASIC-4G-COMBO';
            prod4.vlocity_cmt__ObjectTypeId__c = newObj1.Id;
            prodList.add(prod4);
            
            Product2 prod5 = Test_DataFactory.createProducts(1)[0];
            prod5.Name = 'HERA XYZ';
            prod5.productCode = 'CO-HERA-ALL';
            prod5.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod5);
            
            Product2 prod6 = Test_DataFactory.createProducts(1)[0];
            prod6.Name = 'TouchPoint Plus';
            prod6.productCode = 'TPP_OFFER';
            prod6.vlocity_cmt__ObjectTypeId__c = newObj2.Id;
            prodList.add(prod6);
            
            Product2 prod7 = Test_DataFactory.createProducts(1)[0];
            prod7.Name = 'TouchPoint Plus';
            prod7.productCode = 'TPP_OFFER';
            prod7.TeliaSE_TemplateCategory__c = 'ITDaaS_Company';
            prod7.vlocity_cmt__ObjectTypeId__c = newObj2.Id;
            prodList.add(prod7);
            
            Product2 prod8 = Test_DataFactory.createProducts(1)[0];
            prod8.Name = 'TouchPoint Plus';
            prod8.productCode = 'TPP_OFFER';
            prod8.TeliaSE_TemplateCategory__c = 'ITDaaS_Users';
            prod8.vlocity_cmt__ObjectTypeId__c = newObj2.Id;
            prodList.add(prod8);
            
            /*
Product2 prod6 = Test_DataFactory.createProducts(1)[0];
prod6.name = 'Bredband Pro 100 Mbit/s';
prod6.productCode = 'CO-BBPRO-100MB';
prodList.add(prod6);

*/
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
            /*
PricebookEntry objpricebookentry6 =new PricebookEntry();
objpricebookentry6.Product2ID = prod6.id;
objpricebookentry6.Pricebook2ID = stdPriceBookRecId;
objpricebookentry6.UnitPrice=23.50;
objpricebookentry6.UseStandardPrice=false;
objpricebookentry6.isActive=true;//Add this line
pbeList.add(objpricebookentry6); 
*/
            insert pbeList;
            
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
            Contract contract=new Contract();
            contract.Name='Test';
            contract.AccountId=acc.id;
            contract.Status='Draft';
            contract.Solution_Area__c='Vxl';
            contract.StartDate=Date.today();
            contract.ContractTerm=24;
            insert contract;
            contract.Status='Active';
            update contract;
            
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
            premise3.vlocity_cmt__Address1__c = '12114';
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
            
            list<recordtype> offerQuoteRecId = [SELECT Id FROM recordtype where DeveloperName = 'Offer' AND SobjectType = 'Quote' limit 1];
            list<recordtype> faQuoteRecId = [SELECT Id FROM recordtype where DeveloperName = 'Contract' AND SobjectType = 'Quote' limit 1];
            
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
            /*
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

offerQLI.add(oli2);
insert offerQLI;*/
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli1 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli1.Product__c=prod.id;
            sqli1.QuoteId__c=offerQuote.id;
            sqli1.Quote_Member__c=quoteMem.Id;
            sqli1.Quote_Group__c=quoteGroup.Id;            
            sqli1.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli1.TeliaSE_OnetimeCharge__c=objpricebookentry.UnitPrice * 5;
            sqli1.TeliaSE_MC_Binding_Time__c= '12';
            sqli1.TeliaSE_List_Price__c= objpricebookentry.UnitPrice;
            sqli1.TeliaSE_Aggregated_Quantity__c=5;
            sqli1.TeliaSE_Root_Product__c=null;
            sqli1.MC_TeliaExcludeQuoteItem__c=false;  
            sqli1.TeliaSE_Parent_ItemId__c= null;
            insert sqli1;
            Id newId;
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli2 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli2.Product__c=prod1.id;
            sqli2.QuoteId__c=offerQuote.id;
            sqli2.Quote_Member__c=null;
            sqli2.Quote_Group__c=null;            
            sqli2.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli2.TeliaSE_OnetimeCharge__c=objpricebookentry1.UnitPrice * 5;
            sqli2.TeliaSE_MC_Binding_Time__c= '12';
            sqli2.TeliaSE_List_Price__c= objpricebookentry1.UnitPrice;
            sqli2.TeliaSE_Aggregated_Quantity__c=1;
            sqli2.TeliaSE_Root_Product__c=null;
            sqli2.MC_TeliaExcludeQuoteItem__c=true;  
            sqli2.TeliaSE_Parent_ItemId__c= newId;
            insert sqli2;
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli3 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli3.Product__c=prod1.id;
            sqli3.QuoteId__c=offerQuote.id;
            sqli3.Quote_Member__c=null;
            sqli3.Quote_Group__c=null;            
            sqli3.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli3.TeliaSE_OnetimeCharge__c=objpricebookentry1.UnitPrice * 5;
            sqli3.TeliaSE_MC_Binding_Time__c= '12';
            sqli3.TeliaSE_List_Price__c= objpricebookentry1.UnitPrice;
            sqli3.TeliaSE_Aggregated_Quantity__c=1;
            sqli3.TeliaSE_Root_Product__c=null;
            sqli3.MC_TeliaExcludeQuoteItem__c=true;  
            sqli3.TeliaSE_Parent_ItemId__c= newId;
            insert sqli3;
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli4 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli4.Product__c=prod2.id;
            sqli4.QuoteId__c=offerQuote.id;
            sqli4.Quote_Member__c=null;
            sqli4.Quote_Group__c=null;            
            sqli4.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli4.TeliaSE_OnetimeCharge__c=objpricebookentry2.UnitPrice * 5;
            sqli4.TeliaSE_MC_Binding_Time__c= '12';
            sqli4.TeliaSE_List_Price__c= objpricebookentry2.UnitPrice;
            sqli4.TeliaSE_Aggregated_Quantity__c=1;
            sqli4.TeliaSE_Root_Product__c=null;
            sqli4.MC_TeliaExcludeQuoteItem__c=false;  
            sqli4.TeliaSE_Parent_ItemId__c= newId;
            insert sqli4;
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli5 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli5.Product__c=prod6.id;
            sqli5.QuoteId__c=offerQuote.id;
            sqli5.Quote_Member__c=null;
            sqli5.Quote_Group__c=null;            
            sqli5.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli5.TeliaSE_OnetimeCharge__c=objpricebookentry2.UnitPrice * 5;
            sqli5.TeliaSE_MC_Binding_Time__c= '12';
            sqli5.MC_Initial_Order_Quantity__c= 2;
            sqli5.TeliaSE_List_Price__c= objpricebookentry2.UnitPrice;
            sqli5.TeliaSE_Aggregated_Quantity__c=1;
            sqli5.TeliaSE_Root_Product__c=null;
            sqli5.MC_TeliaExcludeQuoteItem__c=false;  
            sqli5.TeliaSE_Parent_ItemId__c= newId;
            insert sqli5;
            
            
            List<Object> arguments = new List<Object>();
            String qid = offerQuote.id;
            String aid = acc.Id;
            String OfferStr='Telia Datanet;Telia Bredband Plus;Telia Bredband Start;Jobbmobil;Telia Bredband Pro';
            String Status = 'true';
            arguments.add(qid);
            arguments.add(aid);
            arguments.add(OfferStr);
            arguments.add(Status);
            inputs.put('arguments',arguments);
            CO_BindingOTC__c BindingOTC=new CO_BindingOTC__c();
            BindingOTC.Name='47';
            BindingOTC.ProductCode__c='CO-DATANET-ACCESS-BASIC-4G';
            BindingOTC.ProductName__c='Access Basic Wireless 4G Backup';
            BindingOTC.Code0M__c='';
            BindingOTC.Price0M__c=0;
            BindingOTC.Code12M__c='CO-DATANET-BIND-G2-12M';
            BindingOTC.Price12M__c=3000;
            BindingOTC.Code24M__c='CO-DATANET-BIND-G2-24M';
            BindingOTC.Price24M__c=1500;
            BindingOTC.Code36M__c='CO-DATANET-BIND-G2-36M';
            BindingOTC.Price36M__c=0;
            BindingOTC.Group__c='G2';
            insert BindingOTC;
            MC_TeliaSE_OfferDocCreation obj=new MC_TeliaSE_OfferDocCreation();
            Boolean flag = obj.invokeMethod('offerDocgeneration', inputs, output, options);            
            
        }
        
    }
    
    @isTest
    public static void FunctionEval9(){
        User salesManager;         
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        salesManager = Test_DataFactory.createAdminUser();
        salesManager.ForecastEnabled = true;
        salesManager.Bypass_VR__c = true;
        insert salesManager;
        System.runAs(salesManager){
            Map<String,Object> inputs=new Map<String,Object>();
            Map<String,Object> output=new Map<String,Object>();
            Map<String,Object> options=new Map<String,Object>();
            
            
            vlocity_cmt__ObjectClass__c newObj=new vlocity_cmt__ObjectClass__c();
            newObj.Name = 'Connected Office Offer Spec';
            newObj.vlocity_cmt__IsActive__c = true;
            newObj.vlocity_cmt__ObjectApiName__c ='Product2';
            insert newObj;
            
            vlocity_cmt__ObjectClass__c newObj1=new vlocity_cmt__ObjectClass__c();
            newObj1.Name = 'Broadband Start Offering Spec';
            newObj1.vlocity_cmt__IsActive__c = true;
            newObj1.vlocity_cmt__ObjectApiName__c ='Product2';
            insert newObj1;
            
            vlocity_cmt__ObjectClass__c newObj2=new vlocity_cmt__ObjectClass__c();
            newObj2.Name = 'SD-WAN/Firewall Offering Spec';
            newObj2.vlocity_cmt__IsActive__c = true;
            newObj2.vlocity_cmt__ObjectApiName__c ='Product2';
            insert newObj2;
            
            vlocity_cmt__ObjectClass__c newObj3=new vlocity_cmt__ObjectClass__c();
            newObj3.Name = 'Broadband Plus Offering Spec';
            newObj3.vlocity_cmt__IsActive__c = true;
            newObj3.vlocity_cmt__ObjectApiName__c ='Product2';
            insert newObj3;
            
            vlocity_cmt__ObjectClass__c newObj4=new vlocity_cmt__ObjectClass__c();
            newObj4.Name = 'Broadband Pro Offering Spec';
            newObj4.vlocity_cmt__IsActive__c = true;
            newObj4.vlocity_cmt__ObjectApiName__c ='Product2';
            insert newObj4;
            
            vlocity_cmt__ObjectClass__c newObj5=new vlocity_cmt__ObjectClass__c();
            newObj5.Name = 'CG Free Service Offer Spec';
            newObj5.vlocity_cmt__IsActive__c = true;
            newObj5.vlocity_cmt__ObjectApiName__c ='Product2';
            insert newObj5;
            
            vlocity_cmt__ObjectClass__c newObj6=new vlocity_cmt__ObjectClass__c();
            newObj6.Name = 'TouchPoint Plus Offer Spec';
            newObj6.vlocity_cmt__IsActive__c = true;
            newObj6.vlocity_cmt__ObjectApiName__c ='Product2';
            insert newObj6;
            
            vlocity_cmt__ObjectClass__c newObj7=new vlocity_cmt__ObjectClass__c();
            newObj7.Name = 'Smart Connect Offer Spec';
            newObj7.vlocity_cmt__IsActive__c = true;
            newObj7.vlocity_cmt__ObjectApiName__c ='Product2';
            insert newObj7;
            
            vlocity_cmt__ObjectClass__c newObj8=new vlocity_cmt__ObjectClass__c();
            newObj8.Name = 'ICT Offer Specification';
            newObj8.vlocity_cmt__IsActive__c = true;
            newObj8.vlocity_cmt__ObjectApiName__c ='Product2';
            insert newObj8;
            
            vlocity_cmt__ObjectClass__c newObj9=new vlocity_cmt__ObjectClass__c();
            newObj9.Name = 'Hardware Offer Spec';
            newObj9.vlocity_cmt__IsActive__c = true;
            newObj9.vlocity_cmt__ObjectApiName__c ='Product2';
            insert newObj9;
            
            vlocity_cmt__ObjectClass__c newObj10=new vlocity_cmt__ObjectClass__c();
            newObj10.Name = 'Broadband Offer Specification';
            newObj10.vlocity_cmt__IsActive__c = true;
            newObj10.vlocity_cmt__ObjectApiName__c ='Product2';
            insert newObj10;
            
            vlocity_cmt__ObjectClass__c newObj11=new vlocity_cmt__ObjectClass__c();
            newObj11.Name = 'Mobile Offer Specification';
            newObj11.vlocity_cmt__IsActive__c = true;
            newObj11.vlocity_cmt__ObjectApiName__c ='Product2';
            insert newObj11;
            
            vlocity_cmt__ObjectClass__c newObj12=new vlocity_cmt__ObjectClass__c();
            newObj12.Name = 'Insurance Offer Spec';
            newObj12.vlocity_cmt__IsActive__c = true;
            newObj12.vlocity_cmt__ObjectApiName__c ='Product2';
            insert newObj12;
            
            vlocity_cmt__ObjectClass__c newObj13=new vlocity_cmt__ObjectClass__c();
            newObj13.Name = 'Smart Offer Spec';
            newObj13.vlocity_cmt__IsActive__c = true;
            newObj13.vlocity_cmt__ObjectApiName__c ='Product2';
            insert newObj13;
            
            List<Product2> prodList = new List<product2>();
            
            Product2 prod = Test_DataFactory.createProducts(1)[0];
            prod.name = 'Bredband Start 10 Mbit/s';
            prod.productCode = 'CO-BBSTART-10MB';
            prod.vlocity_cmt__ObjectTypeId__c = newObj1.Id;
            prod.TeliaSE_OfferTemplateFlag__c=true;
            prod.TeliaSE_TemplateCategory__c='CO_alone';
            prod.MC_Product_Name_Eng__c='Bredband Start 10 Mbit/s';
            prodList.add(prod); 
            
            Product2 prod1 = Test_DataFactory.createProducts(1)[0];
            prod1.name = 'Bredband Start 30 Mbit/s';
            prod1.productCode = 'CO-BBSTART-30MB';
            prod1.vlocity_cmt__ObjectTypeId__c = newObj1.Id;
            prod1.TeliaSE_OfferTemplateFlag__c=true;
            prod1.TeliaSE_TemplateCategory__c='CO_secondary';
            prod1.MC_Product_Name_Eng__c='Bredband Start 30 Mbit/s';
            prodList.add(prod1);            
            
            Product2 prod2 = Test_DataFactory.createProducts(1)[0];
            prod2.Name = 'Installation och Övriga Tillval';
            prod2.productCode = 'CO-BBSTART-OTHER';
            prod2.vlocity_cmt__ObjectTypeId__c = newObj1.Id;
            prod2.TeliaSE_OfferTemplateFlag__c=true;
            prod2.TeliaSE_TemplateCategory__c='CO_secondary';
            prod2.MC_Product_Name_Eng__c='Installation och Övriga Tillval';
            prodList.add(prod2);
            
            Product2 prod3 = Test_DataFactory.createProducts(1)[0];
            prod3.Name = 'Lokal-ID sök';
            prod3.productCode = 'CO-BBSTART-ID-SOK';
            prod3.vlocity_cmt__ObjectTypeId__c = newObj1.Id;
            prod3.TeliaSE_OfferTemplateFlag__c=true;
            prod3.TeliaSE_TemplateCategory__c='CO_secondary';
            prod3.MC_Product_Name_Eng__c='Lokal-ID sök';
            prodList.add(prod3);
            
            Product2 prod4 = Test_DataFactory.createProducts(1)[0];
            prod4.Name = 'Access Basic Wireless 4G Backup Combo CPE';
            prod4.productCode = 'CO-DATANET-ACCESS-BASIC-4G-COMBO';
            prod4.vlocity_cmt__ObjectTypeId__c = newObj1.Id;
            prodList.add(prod4);
            
            Product2 prod5 = Test_DataFactory.createProducts(1)[0];
            prod5.Name = 'HERA XYZ';
            prod5.productCode = 'CO-HERA-ALL';
            prod5.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod5);
            
            Product2 prod6 = Test_DataFactory.createProducts(1)[0];
            prod6.name = 'Wired';
            prod6.productCode = 'CO-CLOUD-VPN-SD-WAN-WIRED';
            prod6.vlocity_cmt__ObjectTypeId__c = newObj2.Id;
            prod6.TeliaSE_OfferTemplateFlag__c=true;
            prod6.TeliaSE_TemplateCategory__c='CO_alone';
            prod6.MC_Product_Name_Eng__c='Wired';
            prodList.add(prod6); 
            
            Product2 prod7 = Test_DataFactory.createProducts(1)[0];
            prod7.name = 'Bredband Plus 100Mb/s';
            prod7.productCode = 'CO-BBPLUS-100M';
            prod7.vlocity_cmt__ObjectTypeId__c = newObj3.Id;
            prod7.TeliaSE_OfferTemplateFlag__c=true;
            prod7.TeliaSE_TemplateCategory__c='CO_alone';
            prod7.MC_Product_Name_Eng__c='Bredband Plus 100Mb/s';
            prodList.add(prod7); 
            
            Product2 prod8 = Test_DataFactory.createProducts(1)[0];
            prod8.name = 'Bredband Pro 1000Mb/s';
            prod8.productCode = 'CO-CLOUD-VPN-SD-WAN-WIRED';
            prod8.vlocity_cmt__ObjectTypeId__c = newObj4.Id;
            prod8.TeliaSE_OfferTemplateFlag__c=true;
            prod8.TeliaSE_TemplateCategory__c='CO_alone';
            prod8.MC_Product_Name_Eng__c='Bredband Pro 1000Mb/s';
            prodList.add(prod8); 
            
            Product2 prod9 = Test_DataFactory.createProducts(1)[0];
            prod9.name = 'Introduktionskurs i MS365 eller säkerhet, 3 timmar – 1 utbildningsplats';
            prod9.productCode = 'CG_FREE_SERVICE_MS365_TRAIN_1SEAT';
            prod9.vlocity_cmt__ObjectTypeId__c = newObj5.Id;
            prod9.TeliaSE_OfferTemplateFlag__c=true;
            //prod9.TeliaSE_TemplateCategory__c='CO_alone';
            prod9.MC_Product_Name_Eng__c='Introduktionskurs i MS365 eller säkerhet, 3 timmar – 1 utbildningsplats';
            prodList.add(prod9); 
            
            Product2 prod10 = Test_DataFactory.createProducts(1)[0];
            prod10.name = 'Touchpoint Bas';
            prod10.productCode = 'TPP_PKG_BASE';
            prod10.vlocity_cmt__ObjectTypeId__c = newObj6.Id;
            prod10.TeliaSE_OfferTemplateFlag__c=true;
            //prod10.TeliaSE_TemplateCategory__c='CO_alone';
            prod10.MC_Product_Name_Eng__c='Touchpoint Bas';
            prodList.add(prod10); 
            
            Product2 prod11 = Test_DataFactory.createProducts(1)[0];
            prod11.name = 'Smart Connect Standardanvändare';
            prod11.productCode = 'SC_STANDARD';
            prod11.vlocity_cmt__ObjectTypeId__c = newObj7.Id;
            prod11.TeliaSE_OfferTemplateFlag__c=true;
            prod11.TeliaSE_TemplateCategory__c='UserPackages';
            prod11.MC_Product_Name_Eng__c='Smart Connect User';
            prod11.TeliaSE_Product_Type__c='Smart Connect Offer Spec';
            prodList.add(prod11);
            
            Product2 prod234 = Test_DataFactory.createProducts(1)[0];
            prod234.name = 'Smart Connect Standardanvändare';
            prod234.productCode = 'MOB_SP_ADDON_ABROAD_SURF';
            prod234.vlocity_cmt__ObjectTypeId__c = newObj7.Id;
            prod234.TeliaSE_OfferTemplateFlag__c=true;
            prod234.TeliaSE_TemplateCategory__c='UserPackages';
            prod234.MC_Product_Name_Eng__c='Smart Connect User';
            prod234.TeliaSE_Product_Type__c='Smart Connect Offer Spec';
            prodList.add(prod234);
            
            Product2 prod12 = Test_DataFactory.createProducts(1)[0];
            prod12.name = 'TELIA SLUTANVÄNDARSUPPORT – 1:A LINJE MOBILT';
            prod12.productCode = 'ICT_MOB_FIRST';
            prod12.vlocity_cmt__ObjectTypeId__c = newObj8.Id;
            prod12.TeliaSE_OfferTemplateFlag__c=true;
            prod12.TeliaSE_TemplateCategory__c='EndUserSupport';
            prod12.MC_Product_Name_Eng__c='TELIA END-USER SUPPORT – 1:ST LINE MOBILE';
            prod12.TeliaSE_Product_Type__c='ICT Offer Specification';
            prodList.add(prod12);
            
            Product2 prod13 = Test_DataFactory.createProducts(1)[0];
            prod13.name = 'Mobiltelefoner - Tillbehör';
            prod13.productCode = 'MOB_ACCESSORY_OFFER';
            prod13.vlocity_cmt__ObjectTypeId__c = newObj9.Id;
            prod13.TeliaSE_OfferTemplateFlag__c=true;
            prod13.MC_Product_Name_Eng__c='Mobile Phones - Accessories';
            prod13.TeliaSE_Product_Type__c='Hardware Offer Spec';
            prodList.add(prod13);
            
            Product2 prod14 = Test_DataFactory.createProducts(1)[0];
            prod14.name = 'Fast IP adress';
            prod14.productCode = 'MOB_BB_FAST_IP';
            prod14.vlocity_cmt__ObjectTypeId__c = newObj10.Id;
            prod14.TeliaSE_OfferTemplateFlag__c=true;
            prod14.MC_Product_Name_Eng__c='Fixed IP address';
            prod14.TeliaSE_Product_Type__c='Broadband Offer Specification';
            prodList.add(prod14);
            
            Product2 prod15 = Test_DataFactory.createProducts(1)[0];
            prod15.name = '  Jobbsurf 50 GB';
            prod15.productCode = 'MOB_SURF_50';
            prod15.vlocity_cmt__ObjectTypeId__c = newObj11.Id;
            prod15.TeliaSE_OfferTemplateFlag__c=true;
            prod15.MC_Product_Name_Eng__c='Jobbsurf 50 GB';
            prod15.TeliaSE_Product_Type__c='Mobile Offer Specification';
            prodList.add(prod15);
            
            Product2 prod16 = Test_DataFactory.createProducts(1)[0];
            prod16.name = 'Försäkring Mobiltelefon';
            prod16.productCode = 'MOB_OTHER_ADDON';
            prod16.vlocity_cmt__ObjectTypeId__c = newObj12.Id;
            prod16.TeliaSE_OfferTemplateFlag__c=true;
            prod16.MC_Product_Name_Eng__c='Insurance Mobile';
            prod16.TeliaSE_Product_Type__c='Insurance Offer Spec';
            prodList.add(prod16);
            
            Product2 prod17 = Test_DataFactory.createProducts(1)[0];
            prod17.name = 'Försäkring Mobiltelefon';
            prod17.productCode = 'MOB_OTHER_ADDON';
            prod17.vlocity_cmt__ObjectTypeId__c = newObj13.Id;
            prod17.TeliaSE_OfferTemplateFlag__c=true;
            prod17.MC_Product_Name_Eng__c='Insurance Mobile';
            prod17.TeliaSE_Product_Type__c='Insurance Offer Spec';
            prodList.add(prod17);
            
            /*
Product2 prod6 = Test_DataFactory.createProducts(1)[0];
prod6.name = 'Bredband Pro 100 Mbit/s';
prod6.productCode = 'CO-BBPRO-100MB';
prodList.add(prod6);

*/
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
            
            PricebookEntry objpricebookentry9 =new PricebookEntry();
            objpricebookentry9.Product2ID = prod9.id;
            objpricebookentry9.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry9.UnitPrice=23.50;
            objpricebookentry9.UseStandardPrice=false;
            objpricebookentry9.isActive=true;//Add this line
            pbeList.add(objpricebookentry9);
            
            
            PricebookEntry objpricebookentry10 =new PricebookEntry();
            objpricebookentry10.Product2ID = prod10.id;
            objpricebookentry10.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry10.UnitPrice=23.50;
            objpricebookentry10.UseStandardPrice=false;
            objpricebookentry10.isActive=true;//Add this line
            pbeList.add(objpricebookentry10);
            
            PricebookEntry objpricebookentry11 =new PricebookEntry();
            objpricebookentry11.Product2ID = prod12.id;
            objpricebookentry11.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry11.UnitPrice=23.50;
            objpricebookentry11.UseStandardPrice=false;
            objpricebookentry11.isActive=true;//Add this line
            pbeList.add(objpricebookentry11);
            
            PricebookEntry objpricebookentry12 =new PricebookEntry();
            objpricebookentry12.Product2ID = prod13.id;
            objpricebookentry12.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry12.UnitPrice=23.50;
            objpricebookentry12.UseStandardPrice=false;
            objpricebookentry12.isActive=true;//Add this line
            pbeList.add(objpricebookentry12);
            /*
PricebookEntry objpricebookentry6 =new PricebookEntry();
objpricebookentry6.Product2ID = prod6.id;
objpricebookentry6.Pricebook2ID = stdPriceBookRecId;
objpricebookentry6.UnitPrice=23.50;
objpricebookentry6.UseStandardPrice=false;
objpricebookentry6.isActive=true;//Add this line
pbeList.add(objpricebookentry6);

PricebookEntry objpricebookentry7 =new PricebookEntry();
objpricebookentry7.Product2ID = prod6.id;
objpricebookentry7.Pricebook2ID = stdPriceBookRecId;
objpricebookentry7.UnitPrice=23.50;
objpricebookentry7.UseStandardPrice=false;
objpricebookentry7.isActive=true;//Add this line
pbeList.add(objpricebookentry7);

PricebookEntry objpricebookentry8 =new PricebookEntry();
objpricebookentry8.Product2ID = prod6.id;
objpricebookentry8.Pricebook2ID = stdPriceBookRecId;
objpricebookentry8.UnitPrice=23.50;
objpricebookentry8.UseStandardPrice=false;
objpricebookentry8.isActive=true;//Add this line
pbeList.add(objpricebookentry8);*/
            /*
PricebookEntry objpricebookentry6 =new PricebookEntry();
objpricebookentry6.Product2ID = prod6.id;
objpricebookentry6.Pricebook2ID = stdPriceBookRecId;
objpricebookentry6.UnitPrice=23.50;
objpricebookentry6.UseStandardPrice=false;
objpricebookentry6.isActive=true;//Add this line
pbeList.add(objpricebookentry6); 
*/
            insert pbeList;
            
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
            Contract contract=new Contract();
            contract.Name='Test';
            contract.AccountId=acc.id;
            contract.Status='Draft';
            contract.Solution_Area__c='Vxl';
            contract.StartDate=Date.today();
            contract.ContractTerm=24;
            insert contract;
            contract.Status='Active';
            update contract;
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
            premise3.vlocity_cmt__Address1__c = '12114';
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
            
            list<recordtype> offerQuoteRecId = [SELECT Id FROM recordtype where DeveloperName = 'Offer' AND SobjectType = 'Quote' limit 1];
            list<recordtype> faQuoteRecId = [SELECT Id FROM recordtype where DeveloperName = 'Contract' AND SobjectType = 'Quote' limit 1];
            
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
            vlocity_cmt__QuoteGroup__c quoteGroup5 = new vlocity_cmt__QuoteGroup__c();
            quoteGroup5.Name = 'Group 6';
            quoteGroup5.vlocity_cmt__Description__c = 'NO_GROUP';
            quoteGroup5.vlocity_cmt__QuoteId__c = offerQuote.id;
            insert quoteGroup5;
            
            
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
            /*
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

offerQLI.add(oli2);
insert offerQLI;*/
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli1 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli1.Product__c=prod.id;
            sqli1.QuoteId__c=offerQuote.id;
            sqli1.Quote_Member__c=quoteMem.Id;
            sqli1.Quote_Group__c=quoteGroup1.Id;            
            sqli1.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli1.TeliaSE_OnetimeCharge__c=objpricebookentry.UnitPrice * 5;
            sqli1.TeliaSE_MC_Binding_Time__c= '12';
            sqli1.TeliaSE_List_Price__c= objpricebookentry.UnitPrice;
            sqli1.TeliaSE_Aggregated_Quantity__c=5;
            sqli1.TeliaSE_Root_Product__c=null;
            sqli1.MC_TeliaExcludeQuoteItem__c=false;  
            sqli1.TeliaSE_Parent_ItemId__c= null;
            insert sqli1;
            Id newId;
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli2 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli2.Product__c=prod1.id;
            sqli2.QuoteId__c=offerQuote.id;
            sqli2.Quote_Member__c=null;
            sqli2.Quote_Group__c=null;            
            sqli2.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli2.TeliaSE_OnetimeCharge__c=objpricebookentry1.UnitPrice * 5;
            sqli2.TeliaSE_MC_Binding_Time__c= '12';
            sqli2.TeliaSE_List_Price__c= objpricebookentry1.UnitPrice;
            sqli2.TeliaSE_Aggregated_Quantity__c=1;
            sqli2.TeliaSE_Root_Product__c=null;
            sqli2.MC_TeliaExcludeQuoteItem__c=true;  
            sqli2.TeliaSE_Parent_ItemId__c= newId;
            insert sqli2;
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli3 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli3.Product__c=prod1.id;
            sqli3.QuoteId__c=offerQuote.id;
            sqli3.Quote_Member__c=null;
            sqli3.Quote_Group__c=null;            
            sqli3.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli3.TeliaSE_OnetimeCharge__c=objpricebookentry1.UnitPrice * 5;
            sqli3.TeliaSE_MC_Binding_Time__c= '12';
            sqli3.TeliaSE_List_Price__c= objpricebookentry1.UnitPrice;
            sqli3.TeliaSE_Aggregated_Quantity__c=1;
            sqli3.TeliaSE_Root_Product__c=null;
            sqli3.MC_TeliaExcludeQuoteItem__c=true;  
            sqli3.TeliaSE_Parent_ItemId__c= newId;
            insert sqli3;
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli4 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli4.Product__c=prod2.id;
            sqli4.QuoteId__c=offerQuote.id;
            sqli4.Quote_Member__c=null;
            sqli4.Quote_Group__c=null;            
            sqli4.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli4.TeliaSE_OnetimeCharge__c=objpricebookentry2.UnitPrice * 5;
            sqli4.TeliaSE_MC_Binding_Time__c= '12';
            sqli4.TeliaSE_List_Price__c= objpricebookentry2.UnitPrice;
            sqli4.TeliaSE_Aggregated_Quantity__c=1;
            sqli4.TeliaSE_Root_Product__c=null;
            sqli4.MC_TeliaExcludeQuoteItem__c=false;  
            sqli4.TeliaSE_Parent_ItemId__c= newId;
            insert sqli4;
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli5 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli5.Product__c=prod6.id;
            sqli5.QuoteId__c=offerQuote.id;
            sqli5.Quote_Member__c=quoteMem.Id;
            sqli5.Quote_Group__c=quoteGroup2.Id;            
            sqli5.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli5.TeliaSE_OnetimeCharge__c=objpricebookentry2.UnitPrice * 5;
            sqli5.TeliaSE_MC_Binding_Time__c= '12';
            sqli5.TeliaSE_List_Price__c= objpricebookentry2.UnitPrice;
            sqli5.TeliaSE_Aggregated_Quantity__c=1;
            sqli5.TeliaSE_Root_Product__c=null;
            sqli5.MC_TeliaExcludeQuoteItem__c=false;  
            sqli5.TeliaSE_Parent_ItemId__c= newId;
            insert sqli5;
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli6 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli6.Product__c=prod6.id;
            sqli6.QuoteId__c=offerQuote.id;
            sqli6.Quote_Member__c=quoteMem.Id;
            sqli6.Quote_Group__c=quoteGroup1.Id;            
            sqli6.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli6.TeliaSE_OnetimeCharge__c=objpricebookentry2.UnitPrice * 5;
            sqli6.TeliaSE_MC_Binding_Time__c= '12';
            sqli6.TeliaSE_List_Price__c= objpricebookentry2.UnitPrice;
            sqli6.TeliaSE_Aggregated_Quantity__c=1;
            sqli6.TeliaSE_Root_Product__c=null;
            sqli6.MC_TeliaExcludeQuoteItem__c=false;  
            sqli6.TeliaSE_Parent_ItemId__c= newId;
            insert sqli6;
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli7 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli7.Product__c=prod7.id;
            sqli7.QuoteId__c=offerQuote.id;
            sqli7.Quote_Member__c=quoteMem.Id;
            sqli7.Quote_Group__c=quoteGroup3.Id;            
            sqli7.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli7.TeliaSE_OnetimeCharge__c=objpricebookentry2.UnitPrice * 5;
            sqli7.TeliaSE_MC_Binding_Time__c= '12';
            sqli7.TeliaSE_List_Price__c= objpricebookentry2.UnitPrice;
            sqli7.TeliaSE_Aggregated_Quantity__c=1;
            sqli7.TeliaSE_Root_Product__c=null;
            sqli7.MC_TeliaExcludeQuoteItem__c=false;  
            sqli7.TeliaSE_Parent_ItemId__c= newId;
            insert sqli7;
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli8 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli8.Product__c=prod6.id;
            sqli8.QuoteId__c=offerQuote.id;
            sqli8.Quote_Member__c=quoteMem.Id;
            sqli8.Quote_Group__c=quoteGroup2.Id;            
            sqli8.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli8.TeliaSE_OnetimeCharge__c=objpricebookentry2.UnitPrice * 5;
            sqli8.TeliaSE_MC_Binding_Time__c= '12';
            sqli8.TeliaSE_List_Price__c= objpricebookentry2.UnitPrice;
            sqli8.TeliaSE_Aggregated_Quantity__c=1;
            sqli8.TeliaSE_Root_Product__c=null;
            sqli8.MC_TeliaExcludeQuoteItem__c=false;  
            sqli8.TeliaSE_Parent_ItemId__c= newId;
            insert sqli8;
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli9 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli9.Product__c=prod6.id;
            sqli9.QuoteId__c=offerQuote.id;
            sqli9.Quote_Member__c=quoteMem.Id;
            sqli9.Quote_Group__c=quoteGroup4.Id;            
            sqli9.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli9.TeliaSE_OnetimeCharge__c=objpricebookentry2.UnitPrice * 5;
            sqli9.TeliaSE_MC_Binding_Time__c= '12';
            sqli9.TeliaSE_List_Price__c= objpricebookentry2.UnitPrice;
            sqli9.TeliaSE_Aggregated_Quantity__c=1;
            sqli9.TeliaSE_Root_Product__c=null;
            sqli9.MC_TeliaExcludeQuoteItem__c=false;  
            sqli9.TeliaSE_Parent_ItemId__c= null;
            insert sqli9;
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli10 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli10.Product__c=prod7.id;
            sqli10.QuoteId__c=offerQuote.id;
            sqli10.Quote_Member__c=quoteMem.Id;
            sqli10.Quote_Group__c=quoteGroup4.Id;            
            sqli10.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli10.TeliaSE_OnetimeCharge__c=objpricebookentry2.UnitPrice * 5;
            sqli10.TeliaSE_MC_Binding_Time__c= '12';
            sqli10.TeliaSE_List_Price__c= objpricebookentry2.UnitPrice;
            sqli10.TeliaSE_Aggregated_Quantity__c=1;
            sqli10.TeliaSE_Root_Product__c=null;
            sqli10.MC_TeliaExcludeQuoteItem__c=false;  
            sqli10.TeliaSE_Parent_ItemId__c= null;
            insert sqli10;
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli11 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli11.Product__c=prod8.id;
            sqli11.QuoteId__c=offerQuote.id;
            sqli11.Quote_Member__c=quoteMem.Id;
            sqli11.Quote_Group__c=quoteGroup4.Id;            
            sqli11.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli11.TeliaSE_OnetimeCharge__c=objpricebookentry11.UnitPrice * 5;
            sqli11.TeliaSE_MC_Binding_Time__c= '12';
            sqli11.TeliaSE_List_Price__c= objpricebookentry11.UnitPrice;
            sqli11.TeliaSE_Aggregated_Quantity__c=1;
            sqli11.TeliaSE_Root_Product__c=null;
            sqli11.MC_TeliaExcludeQuoteItem__c=false;  
            sqli11.TeliaSE_Parent_ItemId__c= null;
            insert sqli11;
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli12 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli12.Product__c=prod9.id;
            sqli12.QuoteId__c=offerQuote.id;
            sqli12.Quote_Member__c=quoteMem.Id;
            sqli12.Quote_Group__c=quoteGroup4.Id;            
            sqli12.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli12.TeliaSE_OnetimeCharge__c=objpricebookentry2.UnitPrice * 5;
            sqli12.TeliaSE_MC_Binding_Time__c= '12';
            sqli12.TeliaSE_List_Price__c= objpricebookentry2.UnitPrice;
            sqli12.TeliaSE_Aggregated_Quantity__c=1;
            sqli12.TeliaSE_Root_Product__c=null;
            sqli12.MC_TeliaExcludeQuoteItem__c=false;  
            sqli12.TeliaSE_Parent_ItemId__c= null;
            insert sqli12;
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli13 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli13.Product__c=prod10.id;
            sqli13.QuoteId__c=offerQuote.id;
            sqli13.Quote_Member__c=quoteMem.Id;
            sqli13.Quote_Group__c=quoteGroup4.Id;            
            sqli13.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli13.TeliaSE_OnetimeCharge__c=objpricebookentry2.UnitPrice * 5;
            sqli13.TeliaSE_MC_Binding_Time__c= '12';
            sqli13.TeliaSE_List_Price__c= objpricebookentry2.UnitPrice;
            sqli13.TeliaSE_Aggregated_Quantity__c=1;
            sqli13.TeliaSE_Root_Product__c=null;
            sqli13.MC_TeliaExcludeQuoteItem__c=false;  
            sqli13.TeliaSE_Parent_ItemId__c= null;
            insert sqli13;
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli14 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli14.Product__c=prod5.id;
            sqli14.QuoteId__c=offerQuote.id;
            sqli14.Quote_Member__c=quoteMem.Id;
            sqli14.Quote_Group__c=quoteGroup5.Id;            
            sqli14.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli14.TeliaSE_OnetimeCharge__c=objpricebookentry2.UnitPrice * 5;
            sqli14.TeliaSE_MC_Binding_Time__c= '12';
            sqli14.TeliaSE_List_Price__c= objpricebookentry2.UnitPrice;
            sqli14.TeliaSE_Aggregated_Quantity__c=1;
            sqli14.TeliaSE_Root_Product__c=null;
            sqli14.MC_TeliaExcludeQuoteItem__c=false;  
            sqli14.TeliaSE_Parent_ItemId__c= null;
            insert sqli14;
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli15 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli15.Product__c=prod11.id;
            sqli15.QuoteId__c=offerQuote.id;
            sqli15.Quote_Member__c=null;
            sqli15.Quote_Group__c=null;
            //sqli15.Product_Code__c = 'MOB_SP_ADDON_ABROAD_SURF';            
            sqli15.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli15.TeliaSE_OnetimeCharge__c=objpricebookentry2.UnitPrice * 5;
            sqli15.TeliaSE_MC_Binding_Time__c= '12';
            sqli15.MC_Initial_Order_Quantity__c= 2;
            sqli15.TeliaSE_List_Price__c= objpricebookentry2.UnitPrice;
            sqli15.TeliaSE_Aggregated_Quantity__c=1;
            sqli15.TeliaSE_Root_Product__c=null;
            sqli15.MC_TeliaExcludeQuoteItem__c=false;  
            sqli15.TeliaSE_Parent_ItemId__c= newId;
            //sqli15.TeliaSE_Product_Hierarchy__c='01t3N000004mRPAQA2';
            sqli15.TeliaSE_Product_Hierarchy__c=prod5.id;
            insert sqli15;
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli153 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli153.Product__c=prod234.id;
            sqli153.QuoteId__c=offerQuote.id;
            sqli153.Quote_Member__c=null;
            sqli153.Quote_Group__c=null;
            //sqli15.Product_Code__c = 'MOB_SP_ADDON_ABROAD_SURF';            
            sqli153.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli153.TeliaSE_OnetimeCharge__c=objpricebookentry2.UnitPrice * 5;
            sqli153.TeliaSE_MC_Binding_Time__c= '12';
            sqli153.MC_Initial_Order_Quantity__c= 2;
            sqli153.TeliaSE_List_Price__c= objpricebookentry2.UnitPrice;
            sqli153.TeliaSE_Aggregated_Quantity__c=1;
            sqli153.TeliaSE_Root_Product__c=null;
            sqli153.MC_TeliaExcludeQuoteItem__c=false;  
            sqli153.TeliaSE_Parent_ItemId__c= newId;
            //sqli15.TeliaSE_Product_Hierarchy__c='01t3N000004mRPAQA2';
            sqli153.TeliaSE_Product_Hierarchy__c=prod5.id;
            insert sqli153;
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli16 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli16.Product__c=prod12.id;
            sqli16.QuoteId__c=offerQuote.id;
            sqli16.Quote_Member__c=null;
            sqli16.Quote_Group__c=null; 
            //sqli16.Product_Code__c = 'MOB_SP_ADDON_ABROAD_SURF';
            sqli16.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli16.TeliaSE_OnetimeCharge__c=objpricebookentry9.UnitPrice * 5;
            sqli16.TeliaSE_MC_Binding_Time__c= '12';
            sqli16.MC_Initial_Order_Quantity__c= 2;
            sqli16.TeliaSE_List_Price__c= objpricebookentry9.UnitPrice;
            sqli16.TeliaSE_Aggregated_Quantity__c=1;
            sqli16.TeliaSE_Root_Product__c=null;
            sqli16.MC_TeliaExcludeQuoteItem__c=false;  
            sqli16.TeliaSE_Parent_ItemId__c= newId;
            sqli16.TeliaSE_Product_Hierarchy__c='01t3N000004mRPAQA2';
            insert sqli16;
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli17 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli17.Product__c=prod13.id;
            sqli17.QuoteId__c=offerQuote.id;
            sqli17.Quote_Member__c=null;
            sqli17.Quote_Group__c=null;            
            sqli17.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli17.TeliaSE_OnetimeCharge__c=objpricebookentry12.UnitPrice * 5;
            sqli17.TeliaSE_MC_Binding_Time__c= '12';
            sqli17.MC_Initial_Order_Quantity__c= 2;
            sqli17.TeliaSE_List_Price__c= objpricebookentry12.UnitPrice;
            sqli17.TeliaSE_Aggregated_Quantity__c=1;
            sqli17.TeliaSE_Root_Product__c=null;
            sqli17.MC_TeliaExcludeQuoteItem__c=false;  
            sqli17.TeliaSE_Parent_ItemId__c= newId;
            sqli17.TeliaSE_Product_Hierarchy__c='01t3N000004mRPAQA2';
            insert sqli17;
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli18 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli18.Product__c=prod14.id;
            sqli18.QuoteId__c=offerQuote.id;
            sqli18.Quote_Member__c=null;
            sqli18.Quote_Group__c=null;            
            sqli18.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli18.TeliaSE_OnetimeCharge__c=objpricebookentry2.UnitPrice * 5;
            sqli18.TeliaSE_MC_Binding_Time__c= '12';
            sqli18.MC_Initial_Order_Quantity__c= 2;
            sqli18.TeliaSE_List_Price__c= objpricebookentry2.UnitPrice;
            sqli18.TeliaSE_Aggregated_Quantity__c=1;
            sqli18.TeliaSE_Root_Product__c=null;
            sqli18.MC_TeliaExcludeQuoteItem__c=false;  
            sqli18.TeliaSE_Parent_ItemId__c= newId;
            sqli18.TeliaSE_Product_Hierarchy__c='01t3N000004mRPAQA2';
            insert sqli18;
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli19 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli19.Product__c=prod15.id;
            sqli19.QuoteId__c=offerQuote.id;
            sqli19.Quote_Member__c=null;
            sqli19.Quote_Group__c=null;            
            sqli19.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli19.TeliaSE_OnetimeCharge__c=objpricebookentry2.UnitPrice * 5;
            sqli19.TeliaSE_MC_Binding_Time__c= '12';
            sqli19.MC_Initial_Order_Quantity__c= 2;
            sqli19.TeliaSE_List_Price__c= objpricebookentry2.UnitPrice;
            sqli19.TeliaSE_Aggregated_Quantity__c=1;
            sqli19.TeliaSE_Root_Product__c=null;
            sqli19.MC_TeliaExcludeQuoteItem__c=false;  
            sqli19.TeliaSE_Parent_ItemId__c= newId;
            sqli19.TeliaSE_Product_Hierarchy__c='01t3N000004mRPAQA2';
            insert sqli19;
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli20 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli20.Product__c=prod16.id;
            sqli20.QuoteId__c=offerQuote.id;
            sqli20.Quote_Member__c=null;
            sqli20.Quote_Group__c=null;            
            sqli20.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli20.TeliaSE_OnetimeCharge__c=objpricebookentry2.UnitPrice * 5;
            sqli20.TeliaSE_MC_Binding_Time__c= '12';
            sqli20.MC_Initial_Order_Quantity__c= 2;
            sqli20.TeliaSE_List_Price__c= objpricebookentry2.UnitPrice;
            sqli20.TeliaSE_Aggregated_Quantity__c=1;
            sqli20.TeliaSE_Root_Product__c=null;
            sqli20.MC_TeliaExcludeQuoteItem__c=false;  
            sqli20.TeliaSE_Parent_ItemId__c= newId;
            sqli20.TeliaSE_Product_Hierarchy__c='01t3N000004mRPAQA2';
            insert sqli20;
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli21 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli21.Product__c=prod17.id;
            sqli21.QuoteId__c=offerQuote.id;
            sqli21.Quote_Member__c=null;
            sqli21.Quote_Group__c=null;            
            sqli21.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli21.TeliaSE_OnetimeCharge__c=objpricebookentry2.UnitPrice * 5;
            sqli21.TeliaSE_MC_Binding_Time__c= '12';
            sqli21.MC_Initial_Order_Quantity__c= 2;
            sqli21.TeliaSE_List_Price__c= objpricebookentry2.UnitPrice;
            sqli21.TeliaSE_Aggregated_Quantity__c=1;
            sqli21.TeliaSE_Root_Product__c=null;
            sqli21.MC_TeliaExcludeQuoteItem__c=false;  
            sqli21.TeliaSE_Parent_ItemId__c= newId;
            sqli21.TeliaSE_Product_Hierarchy__c='01t3N000004mRPAQA2';
            insert sqli21;
            
            
            
            List<Object> arguments = new List<Object>();
            String qid = offerQuote.id;
            String aid = acc.Id;
            String OfferStr='Telia Datanet;Telia Bredband Plus;Telia Bredband Start;Jobbmobil;Telia Bredband Pro';
            String Status = 'Active';
            
            arguments.add(qid);
            arguments.add(aid);
            arguments.add(OfferStr);
            arguments.add(Status);
            inputs.put('arguments',arguments);
            MC_TeliaSE_OfferDocCreation obj=new MC_TeliaSE_OfferDocCreation();
            Boolean flag = obj.invokeMethod('offerDocgeneration', inputs, output, options);
            
            
        }
    }
    
    
    @isTest
    Public static void FunctionEval10(){
        User salesManager;         
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        salesManager = Test_DataFactory.createAdminUser();
        salesManager.ForecastEnabled = true;
        salesManager.Bypass_VR__c = true;
        insert salesManager;
        System.runAs(salesManager){
            Map<String,Object> inputs=new Map<String,Object>();
            Map<String,Object> output=new Map<String,Object>();
            Map<String,Object> options=new Map<String,Object>();
            
            
            vlocity_cmt__ObjectClass__c newObj=new vlocity_cmt__ObjectClass__c();
            newObj.Name = 'Mobile Offer Specification';
            newObj.vlocity_cmt__IsActive__c = true;
            newObj.vlocity_cmt__ObjectApiName__c ='Product2';
            insert newObj;
            
            vlocity_cmt__ObjectClass__c newObj1=new vlocity_cmt__ObjectClass__c();
            newObj1.Name = 'Virtual Offer Products';
            newObj1.vlocity_cmt__IsActive__c = true;
            newObj1.vlocity_cmt__ObjectApiName__c ='Product2';
            insert newObj1;
            
            List<Product2> prodList = new List<Product2>();
            Product2 prod1 = Test_DataFactory.createProducts(1)[0];
            prod1.Name = 'Kluster Small';
            prod1.productCode = 'MOB_MULTI_SMLL_V3';
            prod1.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prod1.MC_Product_Name_Eng__c = 'SURF AddOn';
            prod1.TeliaSE_Offer_Type__c = 'SubscriptionOffering';
            prodList.add(prod1);
            
            Product2 prod = Test_DataFactory.createProducts(1)[0];
            prod.Name = 'Kluster Large';
            prod.productCode = 'MOB_MULTI_LARGE_V3';
            prod.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prod.MC_Product_Name_Eng__c = 'SURF AddOn';
            prod.TeliaSE_Offer_Type__c = 'SubscriptionOffering';
            prodList.add(prod);
            
            Product2 prod2 = Test_DataFactory.createProducts(1)[0];
            prod2.Name = 'Mobile Total';
            prod2.productCode = 'MOB_MULTI_ALL_IN_PLUS_V3';
            prod2.vlocity_cmt__ObjectTypeId__c = newObj1.Id;
            prod2.MC_Product_Name_Eng__c = 'SURF AddOn';
            prod2.TeliaSE_Offer_Type__c = 'SubscriptionOffering';
            prodList.add(prod2);
            
            Product2 prod3 = Test_DataFactory.createProducts(1)[0];
            prod3.Name = 'Tillag Group';
            prod3.productCode = 'MOB_SP_ADDON_ABROAD';
            prod3.vlocity_cmt__ObjectTypeId__c = newObj1.Id;
            prod3.TeliaSE_Offer_Type__c = 'Non-SubscriptionOffering';
            prod3.MC_Product_Name_Eng__c = 'SURF AddOn';
            prodList.add(prod3);
            
            Product2 prod4 = Test_DataFactory.createProducts(1)[0];
            prod4.Name = 'SURF AddOn';
            prod4.productCode = 'MOB_SP_ADDON_ABROAD_SURF';
            prod4.TeliaSE_Offer_Type__c = 'SubscriptionOffering';
            prod4.vlocity_cmt__ObjectTypeId__c = newObj1.Id;
            prod4.MC_Product_Name_Eng__c = 'SURF AddOn';
            prodList.add(prod4);            
            insert prodList;
            
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
            insert pbeList;
            
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
            
            Quote faQuote = new Quote();
            faQuote.Name='Test Quote';
            faQuote.status = 'Draft';
            faQuote.TeliaSE_Type__c='Renegotiation';
            faQuote.opportunityId = opp.id;
            faQuote.Pricebook2ID = stdPriceBookRecId;
            faQuote.TeliaSE_Approval_Flag__c = true; 
            //faQuote.RecordTypeId = id.valueof((string)faQuoteRecId[0].get('id'));
            faQuote.TeliaSE_MC_Sales_Flow_Identifier__c = 'New Sales';
            insert faQuote;
            
            list<QuoteLineItem> offerQLI = new list<QuoteLineItem>();
            QuoteLineItem qli1 = new QuoteLineItem();
            qli1.PricebookEntryId = objpricebookentry.Id;
            qli1.TeliaSE_MC_Customer_Requested_Percentage__c=10;
            qli1.QuoteId = faQuote.id;
            qli1.UnitPrice = 200;
            qli1.Quantity = 4;
            qli1.vlocity_cmt__Product2Id__c = prod4.id;
            qli1.Product2Id = prod4.id;
            qli1.vlocity_cmt__RecurringCharge__c = 100;
            //oli1.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            qli1.TeliaSE_Root_Product__c=prod.id;
            qli1.vlocity_cmt__ProductHierarchyPath__c = prod2.id + '<' + prod1.id + '<' + prod3.id + '<' + prod4.id;
            qli1.TeliaSE_ParentClusterCode__c = 'bas';
            offerQLI.add(qli1);
            
            QuoteLineItem qli2 = new QuoteLineItem();
            qli2.PricebookEntryId = objpricebookentry.Id;
            qli2.TeliaSE_MC_Customer_Requested_Percentage__c=10;
            qli2.QuoteId = faQuote.id;
            qli2.UnitPrice = 200;
            qli2.Quantity = 4;
            qli2.vlocity_cmt__Product2Id__c = prod4.id;
            qli2.Product2Id = prod4.id;
            //oli1.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            qli2.TeliaSE_Root_Product__c=prod.id;
            qli2.vlocity_cmt__RecurringCharge__c = 100;
            qli2.vlocity_cmt__ProductHierarchyPath__c = prod2.id + '<' + prod.id + '<' + prod3.id + '<' + prod4.id;
            qli2.TeliaSE_ParentClusterCode__c = 'large';
            offerQLI.add(qli2);
            
            QuoteLineItem qli3 = new QuoteLineItem();
            qli3.PricebookEntryId = objpricebookentry.Id;
            qli3.TeliaSE_MC_Customer_Requested_Percentage__c=10;
            qli3.QuoteId = faQuote.id;
            qli3.UnitPrice = 200;
            qli3.Quantity = 4;
            qli3.vlocity_cmt__Product2Id__c = prod1.id;
            qli3.Product2Id = prod.id;
            //oli1.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            qli3.TeliaSE_Root_Product__c=prod.id;
            qli3.vlocity_cmt__RecurringCharge__c = 100;
            qli3.vlocity_cmt__ProductHierarchyPath__c = prod2.id + '<' + prod1.id;
            qli3.TeliaSE_ParentClusterCode__c = 'large';
            offerQLI.add(qli3);
            
            QuoteLineItem qli4 = new QuoteLineItem();
            qli4.PricebookEntryId = objpricebookentry.Id;
            qli4.TeliaSE_MC_Customer_Requested_Percentage__c=10;
            qli4.QuoteId = faQuote.id;
            qli4.UnitPrice = 200;
            qli4.Quantity = 4;
            qli4.vlocity_cmt__Product2Id__c = prod.id;
            qli4.Product2Id = prod.id;
            qli4.vlocity_cmt__RecurringCharge__c = 100;
            //oli1.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            qli4.TeliaSE_Root_Product__c=prod.id;
            qli4.vlocity_cmt__ProductHierarchyPath__c = prod2.id + '<' + prod.id;
            qli4.TeliaSE_ParentClusterCode__c = 'large';
            offerQLI.add(qli4);
            
            QuoteLineItem qli5 = new QuoteLineItem();
            qli5.PricebookEntryId = objpricebookentry.Id;
            qli5.TeliaSE_MC_Customer_Requested_Percentage__c=10;
            qli5.QuoteId = faQuote.id;
            qli5.UnitPrice = 200;
            qli5.Quantity = 4;
            qli5.vlocity_cmt__Product2Id__c = prod3.id;
            qli5.Product2Id = prod3.id;
            qli5.vlocity_cmt__RecurringCharge__c = 100;
            //oli1.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            qli5.TeliaSE_Root_Product__c=prod.id;
            qli5.vlocity_cmt__ProductHierarchyPath__c = prod2.id + '<' + prod.id + '<' + prod3.id;
            qli5.TeliaSE_ParentClusterCode__c = 'large';
            offerQLI.add(qli5);
            
            QuoteLineItem qli6 = new QuoteLineItem();
            qli6.PricebookEntryId = objpricebookentry.Id;
            qli6.TeliaSE_MC_Customer_Requested_Percentage__c=10;
            qli6.QuoteId = faQuote.id;
            qli6.UnitPrice = 200;
            qli6.Quantity = 4;
            qli6.vlocity_cmt__Product2Id__c = prod4.id;
            qli6.Product2Id = prod4.id;
            //oli1.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            qli6.TeliaSE_Root_Product__c=prod.id;
            qli6.vlocity_cmt__RecurringCharge__c = 100;
            qli6.vlocity_cmt__ProductHierarchyPath__c = prod2.id + '<' + prod.id + '<' + prod3.id + '<' + prod4.id;
            qli6.TeliaSE_ParentClusterCode__c = 'small';
            offerQLI.add(qli6);
            
            QuoteLineItem qli7 = new QuoteLineItem();
            qli7.PricebookEntryId = objpricebookentry.Id;
            qli7.TeliaSE_MC_Customer_Requested_Percentage__c=10;
            qli7.QuoteId = faQuote.id;
            qli7.UnitPrice = 200;
            qli7.Quantity = 4;
            qli7.vlocity_cmt__Product2Id__c = prod4.id;
            qli7.Product2Id = prod4.id;
            //oli1.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Sad_Face';
            qli7.TeliaSE_Root_Product__c=prod.id;
            qli7.vlocity_cmt__RecurringCharge__c = 100;
            qli7.vlocity_cmt__ProductHierarchyPath__c = prod2.id + '<' + prod.id + '<' + prod3.id + '<' + prod4.id;
            qli7.TeliaSE_ParentClusterCode__c = 'plus';
            offerQLI.add(qli7);
            
            insert offerQLI;
            
            Quote offerQuote = new Quote();
            offerQuote.Name='Test Quote';
            offerQuote.status = 'Draft';
            offerQuote.vlocity_cmt__ParentQuoteId__c = faQuote.id;
            offerQuote.opportunityId = opp.id;
            offerQuote.Pricebook2ID = stdPriceBookRecId; 
            //faQuote.RecordTypeId = id.valueof((string)faQuoteRecId[0].get('id'));
            insert offerQuote;
            
            List<TeliaSE_SimplifiedQuoteLineItem__c> simplifiedList = new List<TeliaSE_SimplifiedQuoteLineItem__c>();
            TeliaSE_SimplifiedQuoteLineItem__c sqli1 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli1.Product__c=prod3.id;
            sqli1.QuoteId__c=offerQuote.id;           
            sqli1.TeliaSE_Offer_Type__c ='Non-SubscriptionOffering';
            sqli1.TeliaSE_OnetimeCharge__c=objpricebookentry.UnitPrice * 5;
            sqli1.TeliaSE_List_Price__c= objpricebookentry.UnitPrice;
            sqli1.TeliaSE_Aggregated_Quantity__c=5;
            sqli1.TeliaSE_Root_Product__c=prod3.id;
            sqli1.MC_TeliaExcludeQuoteItem__c=false;  
            sqli1.TeliaSE_Parent_ItemId__c= null;
            insert sqli1;
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli2 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli2.Product__c=prod3.id;
            sqli2.QuoteId__c=offerQuote.id;           
            sqli2.TeliaSE_Offer_Type__c ='Non-SubscriptionOffering';
            sqli2.TeliaSE_OnetimeCharge__c=objpricebookentry.UnitPrice * 5;
            sqli2.TeliaSE_List_Price__c= objpricebookentry.UnitPrice;
            sqli2.TeliaSE_Aggregated_Quantity__c=5;
            sqli2.TeliaSE_Root_Product__c=prod3.id;
            sqli2.MC_TeliaExcludeQuoteItem__c=false;  
            sqli2.TeliaSE_Parent_ItemId__c= null;
            insert sqli2;
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli3 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli3.Product__c=prod4.id;
            sqli3.QuoteId__c=offerQuote.id;           
            sqli3.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli3.TeliaSE_OnetimeCharge__c=objpricebookentry.UnitPrice * 5;
            sqli3.TeliaSE_List_Price__c= objpricebookentry.UnitPrice;
            sqli3.TeliaSE_Aggregated_Quantity__c=5;
            sqli3.TeliaSE_Root_Product__c=prod3.id;
            sqli3.MC_TeliaExcludeQuoteItem__c=false;  
            sqli3.TeliaSE_Parent_ItemId__c= sqli1.id;
            insert sqli3;
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli4 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli4.Product__c=prod4.id;
            sqli4.QuoteId__c=offerQuote.id;           
            sqli4.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli4.TeliaSE_OnetimeCharge__c=objpricebookentry.UnitPrice * 5;
            sqli4.TeliaSE_List_Price__c= objpricebookentry.UnitPrice;
            sqli4.TeliaSE_Aggregated_Quantity__c=5;
            sqli4.TeliaSE_Root_Product__c=prod3.id;
            sqli4.MC_TeliaExcludeQuoteItem__c=false;  
            sqli4.TeliaSE_Parent_ItemId__c= sqli2.id;
            insert sqli4;

            List<String> nmpClusterAddOnProducts = new List<String>();
            Map<String, MC_ClusterTablePricing__mdt> mcs = MC_ClusterTablePricing__mdt.getAll();
            MC_ClusterTablePricing__mdt mobileMetadata;
            Boolean isTotalProduct = false;
            for(String name: mcs.keySet())
            {            
                if(name=='Mobile_Offer_Specification')
                {
                    nmpClusterAddOnProducts = mcs.get(name).TableProducts__c.split(';');                                
                    mobileMetadata = mcs.get(name);
                    //coOfferTypes.add(mobileMetadata.Label);
                }
            }
            List<QuoteLineItem> qliList = [Select id, vlocity_cmt__Product2Id__r.ProductCode,vlocity_cmt__ProductHierarchyPath__c,vlocity_cmt__Product2Id__c,vlocity_cmt__Product2Id__r.Name,TeliaSE_MC_Customer_Requested_Price__c,vlocity_cmt__RecurringCharge__c,TeliaSE_ParentClusterCode__c,vlocity_cmt__Product2Id__r.MC_Product_Name_Eng__c,vlocity_cmt__Product2Id__r.TeliaSE_Offer_Type__c,TeliaSE_Product_Code__c from quotelineitem where quoteid=: faQuote.id];            
            MC_TeliaSE_OfferDocCreation.cls_ClusterAddons addOns = MC_TeliaSE_OfferDocCreation.clusterTableDocument(qliList,mobileMetadata);
            
            List<Object> arguments = new List<Object>();
            String qid = offerQuote.id;
            String aid = acc.Id;
            String OfferStr='Telia Datanet;Telia Bredband Plus;Telia Bredband Start;Jobbmobil;Telia Bredband Pro';
            String Status = 'Active';
            
            arguments.add(qid);
            arguments.add(aid);
            arguments.add(OfferStr);
            arguments.add(Status);
            inputs.put('arguments',arguments);
            MC_TeliaSE_OfferDocCreation obj=new MC_TeliaSE_OfferDocCreation();
            Boolean flag = obj.invokeMethod('offerDocgeneration', inputs, output, options);
        }
    }
    
    @isTest
    Public static void test1_zeroProductFlag(){
        MC_TeliaSE_OfferDocCreation.resultMap result = new MC_TeliaSE_OfferDocCreation.resultMap();
        MC_TeliaSE_OfferDocCreation.cls_Line line = new MC_TeliaSE_OfferDocCreation.cls_Line();
        line.Type = 'ITDaaS Offer Spec';
        line.ProductCode = 'ITDAAS_START';
        line.BindingTime = '1 month';
        List<String> productCodeList = new List<String>{'ITDaaS Offer Spec','Broadband Start Offering Spec','Broadband Plus Offering Spec','Broadband Pro Offering Spec','Broadband Datanet Offering Spec','WIFI/LAN Offering Spec','SD-WAN/Firewall Offering Spec','Mobile Offer Specification','OFFICE365 Offer Spec','Touch Point Offer Spec','TouchPoint Plus Offer Spec','Smart Offer Spec','Insurance Offer Spec','Personal Technician Offer Specification','ICT Offer Specification','Hardware Offer Spec','Broadband Offer Specification','Smart Connect Offer Spec'};
            for(String objType : productCodeList){
                line.Type = objType;            
                MC_TeliaSE_OfferDocCreation.zeroProductFlag(result,line);
                MC_TeliaSE_OfferDocCreation.defaultProductFlags(result,line);
                MC_TeliaSE_OfferDocCreation.populateObjectTypeTotals(result,line,100,100);
                if(objType == 'OFFICE365 Offer Spec'){
                    line.BindingTime = '12 months';
                    MC_TeliaSE_OfferDocCreation.zeroProductFlag(result,line);
                    MC_TeliaSE_OfferDocCreation.defaultProductFlags(result,line);
                    MC_TeliaSE_OfferDocCreation.populateObjectTypeTotals(result,line,100,100);
                    line.BindingTime = '36 months';
                    MC_TeliaSE_OfferDocCreation.zeroProductFlag(result,line);
                    MC_TeliaSE_OfferDocCreation.defaultProductFlags(result,line);
                    MC_TeliaSE_OfferDocCreation.populateObjectTypeTotals(result,line,100,100);
                }
            }
        line.Type = 'Connected Office Offer Spec';
        MC_TeliaSE_OfferDocCreation.populateObjectTypeTotals(result,line,100,100);
    }
    
    @isTest
    Public static void additionOfferPopulateTest(){
        MC_TeliaSE_OfferDocCreation.resultMap result = new MC_TeliaSE_OfferDocCreation.resultMap();
        String offer = 'Microsoft 365;Slutanvändarsupport;Jobbmobil;Smart Connect;Mobilt;Personlig Tekniker;Smart Säkerhet;Bredband Plus;Datanet;Bredband Pro;Bredband Start;VPN SD-WAN;VPN WIFI;TouchPoint;Touch Point Plus;Försäkring;IT-avdelning;IT-avdelning Start';
        MC_TeliaSE_OfferDocCreation.additionOfferPopulate(result,offer);
    }
    
    @isTest
    public static void docCreationwithChildTest(){
        User salesManager;         
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        salesManager = Test_DataFactory.createAdminUser();
        salesManager.ForecastEnabled = true;
        salesManager.Bypass_VR__c = true;
        insert salesManager;
        System.runAs(salesManager){
            Map<String,Object> inputs=new Map<String,Object>();
            Map<String,Object> output=new Map<String,Object>();
            Map<String,Object> options=new Map<String,Object>();
            List<vlocity_cmt__ObjectClass__c> objTypes = new List<vlocity_cmt__ObjectClass__c>();
            vlocity_cmt__ObjectClass__c newObj11=new vlocity_cmt__ObjectClass__c();
            newObj11.Name = 'Mobile Offer Specification';
            newObj11.vlocity_cmt__IsActive__c = true;
            newObj11.vlocity_cmt__ObjectApiName__c ='Product2';            
            objTypes.add(newObj11);
            
            vlocity_cmt__ObjectClass__c newObj1=new vlocity_cmt__ObjectClass__c();
            newObj1.Name = 'Broadband Start Offering Spec';
            newObj1.vlocity_cmt__IsActive__c = true;
            newObj1.vlocity_cmt__ObjectApiName__c ='Product2';
            objTypes.add(newObj1);
            insert objTypes;
            
            List<Product2> prodList = new List<product2>();
            
            Product2 prod1 = Test_DataFactory.createProducts(1)[0];
            prod1.name = 'Mobile Non Subscription';
            prod1.productCode = 'MOB_NONSUBS';
            prod1.vlocity_cmt__ObjectTypeId__c = newObj11.Id;
            prod1.TeliaSE_OfferTemplateFlag__c=true;
            prod1.TeliaSE_TemplateCategory__c='ITDaaS_Users';
            prod1.MC_Product_Name_Eng__c='mobile Non Subs';
            prod1.TeliaSE_Product_Type__c='Mobile Offer Specification';
            prod1.TeliaSE_Offer_Type__c = 'Non-SubscriptionOffering';
            prodList.add(prod1);
            
            Product2 prod2 = Test_DataFactory.createProducts(1)[0];
            prod2.name = 'mobile Child';
            prod2.productCode = 'MOB_CHild';
            prod2.vlocity_cmt__ObjectTypeId__c = newObj11.Id;
            prod2.TeliaSE_OfferTemplateFlag__c=true;
            prod2.TeliaSE_TemplateCategory__c='ITDaaS_AddOns';
            prod2.MC_Product_Name_Eng__c='Mob_Child';
            prod2.TeliaSE_Offer_Type__c = 'SubscriptionOffering';
            prod2.TeliaSE_Product_Type__c='Mobile Offer Specification';
            prodList.add(prod2);
            
            Product2 prod3 = Test_DataFactory.createProducts(1)[0];
            prod3.name = 'bredbandStart';
            prod3.productCode = 'BBSTart_10';
            prod3.vlocity_cmt__ObjectTypeId__c = newObj1.Id;
            prod3.TeliaSE_OfferTemplateFlag__c=true;
            prod3.MC_Product_Name_Eng__c='broadband Start';
            prod3.TeliaSE_Offer_Type__c = 'SubscriptionOffering';
            prod3.TeliaSE_Product_Type__c='Broadband Start Offering Spec';
            prodList.add(prod3);
            
            Product2 prod4 = Test_DataFactory.createProducts(1)[0];
            prod4.name = 'mobile Child 2';
            prod4.productCode = 'MOB_CHild2';
            prod4.vlocity_cmt__ObjectTypeId__c = newObj11.Id;
            prod4.TeliaSE_OfferTemplateFlag__c=true;
            prod4.MC_Product_Name_Eng__c='Mob_Child';
            prod4.TeliaSE_TemplateCategory__c='ITDaaS_AddOns';
            prod4.TeliaSE_Offer_Type__c = 'SubscriptionOffering';
            prod4.TeliaSE_Product_Type__c='Mobile Offer Specification';
            prodList.add(prod4);
            
            insert ProdList;
            List<PricebookEntry> pbelist = new List<PricebookEntry>();
            
            PricebookEntry objpricebookentry =new PricebookEntry();
            objpricebookentry.Product2ID = prod1.id;            
            objpricebookentry.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry.UnitPrice=23.50;
            objpricebookentry.UseStandardPrice=false;
            objpricebookentry.isActive=true;//Add this line
            pbeList.add(objpricebookentry);
            
            PricebookEntry objpricebookentry1 =new PricebookEntry();
            objpricebookentry1.Product2ID = prod2.id;
            objpricebookentry1.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry1.UnitPrice=23.50;
            objpricebookentry1.UseStandardPrice=false;
            objpricebookentry1.isActive=true;//Add this line
            pbeList.add(objpricebookentry1);
            
            PricebookEntry objpricebookentry2 =new PricebookEntry();
            objpricebookentry2.Product2ID = prod3.id;
            objpricebookentry2.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry2.UnitPrice=23.50;
            objpricebookentry2.UseStandardPrice=false;
            objpricebookentry2.isActive=true;//Add this line
            pbeList.add(objpricebookentry2);
            
            PricebookEntry objpricebookentry3 =new PricebookEntry();
            objpricebookentry3.Product2ID = prod4.id;
            objpricebookentry3.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry3.UnitPrice=23.50;
            objpricebookentry3.UseStandardPrice=false;
            objpricebookentry3.isActive=true;//Add this line
            pbeList.add(objpricebookentry3);
            insert pbeList;
            
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
            
            list<recordtype> offerQuoteRecId = [SELECT Id FROM recordtype where DeveloperName = 'Offer' AND SobjectType = 'Quote' limit 1];
            list<recordtype> faQuoteRecId = [SELECT Id FROM recordtype where DeveloperName = 'Contract' AND SobjectType = 'Quote' limit 1];
            
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
            
            Quote offerQuote = new Quote();
            offerQuote.Name='Test Quote';
            offerQuote.status = 'Draft';
            offerQuote.opportunityId = opp.id;
            offerQuote.Pricebook2ID = stdPriceBookRecId;
            offerQuote.TeliaSE_Approval_Flag__c = false; 
            offerQuote.vlocity_cmt__ParentQuoteId__c  = faQuote.id;
            offerQuote.RecordTypeId = id.valueof((string)offerQuoteRecId[0].get('id'));
            insert offerQuote;
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli1 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli1.Product__c=prod1.id;
            sqli1.QuoteId__c=offerQuote.id;           
            sqli1.TeliaSE_Offer_Type__c ='Non-SubscriptionOffering';
            sqli1.TeliaSE_OnetimeCharge__c=objpricebookentry.UnitPrice * 5;
            sqli1.TeliaSE_List_Price__c= objpricebookentry.UnitPrice;
            sqli1.TeliaSE_Aggregated_Quantity__c=5;
            sqli1.TeliaSE_Root_Product__c=prod1.id;
            sqli1.MC_TeliaExcludeQuoteItem__c=false;  
            sqli1.TeliaSE_Parent_ItemId__c= null;
            insert sqli1;
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli2 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli2.Product__c=prod2.id;
            sqli2.QuoteId__c=offerQuote.id;            
            sqli2.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli2.TeliaSE_OnetimeCharge__c=objpricebookentry1.UnitPrice * 5;
            sqli2.TeliaSE_MC_Binding_Time__c= '12';
            sqli2.TeliaSE_List_Price__c= objpricebookentry1.UnitPrice;
            sqli2.TeliaSE_Aggregated_Quantity__c=1;
            sqli2.TeliaSE_Root_Product__c=prod1.id;
            sqli2.MC_TeliaExcludeQuoteItem__c=true;  
            sqli2.TeliaSE_Parent_ItemId__c= sqli1.id;
            insert sqli2;
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli4 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli4.Product__c=prod4.id;
            sqli4.QuoteId__c=offerQuote.id;            
            sqli4.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli4.TeliaSE_OnetimeCharge__c=objpricebookentry1.UnitPrice * 5;
            sqli4.TeliaSE_MC_Binding_Time__c= '12';
            sqli4.TeliaSE_List_Price__c= objpricebookentry1.UnitPrice;
            sqli4.TeliaSE_Aggregated_Quantity__c=1;
            sqli4.TeliaSE_Root_Product__c=prod1.id;
            sqli4.MC_TeliaExcludeQuoteItem__c=false;  
            sqli4.TeliaSE_Parent_ItemId__c= sqli1.id;
            insert sqli4;
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli3 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli3.Product__c=prod2.id;
            sqli3.QuoteId__c=offerQuote.id;            
            sqli3.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli3.TeliaSE_OnetimeCharge__c=objpricebookentry1.UnitPrice * 5;
            sqli3.TeliaSE_List_Price__c= objpricebookentry1.UnitPrice;
            sqli3.TeliaSE_Aggregated_Quantity__c=1;
            sqli3.TeliaSE_Root_Product__c=prod2.id;
            sqli3.MC_TeliaExcludeQuoteItem__c=false;
            sqli3.TeliaSE_Parent_ItemId__c= null;
            insert sqli3;
            
            List<Object> arguments = new List<Object>();
            String qid = offerQuote.id;
            String aid = acc.Id;
            String OfferStr='Telia Datanet;Telia Bredband Plus;Telia Bredband Start;Jobbmobil;Telia Bredband Pro';
            String Status = 'Active';
            
            arguments.add(qid);
            arguments.add(aid);
            arguments.add(OfferStr);
            arguments.add(Status);
            inputs.put('arguments',arguments);
            MC_TeliaSE_OfferDocCreation obj=new MC_TeliaSE_OfferDocCreation();
            Boolean flag = obj.invokeMethod('offerDocgeneration', inputs, output, options);
        }            
    }
    
     @isTest
    Public static void test_populateLineFlags(){
        MC_TeliaSE_OfferDocCreation.resultMap result = new MC_TeliaSE_OfferDocCreation.resultMap();
        MC_TeliaSE_OfferDocCreation.cls_Line line = new MC_TeliaSE_OfferDocCreation.cls_Line();
        TeliaSE_SimplifiedQuoteLineItem__c qli1 = new TeliaSE_SimplifiedQuoteLineItem__c();
        line.Type = 'ITDaaS Offer Spec';
        line.ProductCode = 'ITDAAS_START';
        line.BindingTime = '1 month';
        Map<String,String> scCluster = new Map<String,String>();
        
        vlocity_cmt__ObjectClass__c newObj1=new vlocity_cmt__ObjectClass__c();
        newObj1.Name = 'Virtual Offer Products';
        newObj1.vlocity_cmt__IsActive__c = true;
        newObj1.vlocity_cmt__ObjectApiName__c ='Product2';
        insert newObj1;
        
        Product2 prod = Test_DataFactory.createProducts(1)[0];
        prod.Name = 'Kluster Large';
        prod.productCode = 'ITDAAS_START';
        prod.vlocity_cmt__ObjectTypeId__c = newObj1.Id;
        prod.MC_Product_Name_Eng__c = 'SURF AddOn';
        prod.TeliaSE_Offer_Type__c = 'SubscriptionOffering';
        prod.TeliaSE_TemplateCategory__c = 'UserPackages1';
        insert prod;
        
        TeliaSE_SimplifiedQuoteLineItem__c sqli2 = new TeliaSE_SimplifiedQuoteLineItem__c();
        sqli2.Product__c=prod.id;
        sqli2.TeliaSE_MC_Binding_Time__c = '12 months';
        insert sqli2;
        
        List<String> productCodeList = new List<String>{'ITDaaS Offer Spec','Broadband Start Offering Spec','Broadband Plus Offering Spec','Broadband Pro Offering Spec','Broadband Datanet Offering Spec','WIFI/LAN Offering Spec','SD-WAN/Firewall Offering Spec','Mobile Offer Specification','OFFICE365 Offer Spec','Touch Point Offer Spec','TouchPoint Plus Offer Spec','Smart Offer Spec','Insurance Offer Spec','Personal Technician Offer Specification','ICT Offer Specification','Hardware Offer Spec','Broadband Offer Specification','Smart Connect Offer Spec'};
            for(String objType : productCodeList){
                newObj1.Name = objType;
                update newObj1;
                
                TeliaSE_SimplifiedQuoteLineItem__c sqli3 = [Select id,TeliaSE_MC_Binding_Time__c,Product_Code__c,ProductType__c,Product__r.TeliaSE_TemplateCategory__c,MC_TeliaExcludeQuoteItem__c from TeliaSE_SimplifiedQuoteLineItem__c where Product__c =:prod.id ];
                MC_TeliaSE_OfferDocCreation.populateLineProductFlags(result,sqli3,line,scCluster);
                if(objType == 'OFFICE365 Offer Spec'){
                    sqli3.TeliaSE_MC_Binding_Time__c = '1 month';
                    MC_TeliaSE_OfferDocCreation.populateLineProductFlags(result,sqli3,line,scCluster);
                    sqli3.TeliaSE_MC_Binding_Time__c = '36 months';
                    MC_TeliaSE_OfferDocCreation.populateLineProductFlags(result,sqli3,line,scCluster);
                }
            }
    }
    
    @isTest
    public static void test_trimCurrencyFlags(){
        Map<String,Object> resultMap2 = new Map<String,Object>();
        resultMap2.put('TotalOffice365RTCB36','SEK100');
        resultMap2.put('TotalOffice365RTCB12','SEK100');
        resultMap2.put('TotalOffice365RTCB0','SEK100');
        resultMap2.put('TotalOffice365OTCB36','SEK100');
        resultMap2.put('TotalOffice365OTCB12','SEK100');
        resultMap2.put('TotalOffice365OTCB0','SEK100');
        resultMap2.put('TotalRTCUser','SEK100');
        resultMap2.put('TotalRTCSumITDaaS','SEK100');
        resultMap2.put('TotalRTCSum3','SEK100');
        resultMap2.put('TotalRTCSum','SEK100');
        resultMap2.put('TotalRTCCompany','SEK100');       
        resultMap2.put('RTCUser','SEK100');
        resultMap2.put('OTC','SEK100');
        resultMap2.put('RTC','SEK1 000,00');
        resultMap2.put('OTF','SEK1 000,00');
        List<Object> arguments = new List<Object>();
        arguments.add((Object)resultMap2);
        arguments.add((String)'OfferDocument');
        Map<String,Object> inputMap = new Map<String,Object>();
        inputMap.put('arguments',arguments);
        MC_TeliaSE_OfferDocCreation mc = new MC_TeliaSE_OfferDocCreation();
        mc.invokeMethod('trimCurrencyPrefix',inputMap,inputMap,inputMap);
        
    }
    
    
    
}