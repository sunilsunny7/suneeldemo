@isTest
public with sharing class Test_MassCustomized_Agreement_Generation {
    @isTest
    public static void FunctionEval(){
        User salesManager;         
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        salesManager = Test_DataFactory.createAdminUser();
        salesManager.ForecastEnabled = true;
        salesManager.Bypass_VR__c = true;
        insert salesManager;
        System.runAs(salesManager){
            Map<String,Object> inputs=new Map<String,Object>();
            Map<String,Object> inputMap=new Map<String,Object>();
            Map<String,Object> inputMapAG=new Map<String,Object>();
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
            
            vlocity_cmt__ObjectClass__c newObj3=new vlocity_cmt__ObjectClass__c();
            newObj3.Name = 'Broadband Start Offering Spec';
            newObj3.vlocity_cmt__IsActive__c = true;
            newObj3.vlocity_cmt__ObjectApiName__c ='Product2';
            insert newObj3;
            
            vlocity_cmt__ObjectClass__c newObj4=new vlocity_cmt__ObjectClass__c();
            newObj4.Name = 'SD-WAN/Firewall Offering Spec';
            newObj4.vlocity_cmt__IsActive__c = true;
            newObj4.vlocity_cmt__ObjectApiName__c ='Product2';
            insert newObj4;
            
            vlocity_cmt__ObjectClass__c newObj5=new vlocity_cmt__ObjectClass__c();
            newObj5.Name = 'Broadband Plus Offering Spec';
            newObj5.vlocity_cmt__IsActive__c = true;
            newObj5.vlocity_cmt__ObjectApiName__c ='Product2';
            insert newObj5;
            
            vlocity_cmt__ObjectClass__c newObj6=new vlocity_cmt__ObjectClass__c();
            newObj6.Name = 'Broadband Pro Offering Spec';
            newObj6.vlocity_cmt__IsActive__c = true;
            newObj6.vlocity_cmt__ObjectApiName__c ='Product2';
            insert newObj6;
            
            vlocity_cmt__ObjectClass__c newObj7=new vlocity_cmt__ObjectClass__c();
            newObj7.Name = 'CG Free Service Offer Spec';
            newObj7.vlocity_cmt__IsActive__c = true;
            newObj7.vlocity_cmt__ObjectApiName__c ='Product2';
            insert newObj7;
            
            
            vlocity_cmt__ObjectClass__c newObj8=new vlocity_cmt__ObjectClass__c();
            newObj8.Name = 'Mobile Offer Specification';
            newObj8.vlocity_cmt__IsActive__c = true;
            newObj8.vlocity_cmt__ObjectApiName__c ='Product2';
            insert newObj8;
            
            vlocity_cmt__ObjectClass__c newObj9=new vlocity_cmt__ObjectClass__c();
            newObj9.Name = 'Smart Connect Offer Spec';
            newObj9.vlocity_cmt__IsActive__c = true;
            newObj9.vlocity_cmt__ObjectApiName__c ='Product2';
            insert newObj9;
            
            Product2 prod = Test_DataFactory.createProducts(1)[0];
            prod.name = 'Access Multi 10 Mbit/s';
            prod.productCode = 'MOB_CALL_TRAVELMOB_SURF';
            prod.vlocity_cmt__ObjectTypeId__c = newObj1.Id;
            prod.TeliaSE_OfferTemplateFlag__c=true;
            prod.TeliaSE_TemplateCategory__c='CO_alone';
            prod.MC_Product_Name_Eng__c='Datanet';
            prodList.add(prod); 
            
            Product2 prod1 = Test_DataFactory.createProducts(1)[0];
            prod1.name = 'Access Multi 100 Mbit/s';
            prod1.productCode = 'CO-DATANET-ACCESS-MULTI-100MB';
            prod1.vlocity_cmt__ObjectTypeId__c = newObj1.Id;
            prod1.TeliaSE_OfferTemplateFlag__c=true;
            prod1.TeliaSE_TemplateCategory__c='CO_secondary';
            prod1.MC_Product_Name_Eng__c='Bredband Pro';
            prodList.add(prod1);            
            
            Product2 prod2 = Test_DataFactory.createProducts(1)[0];
            prod2.Name = 'Tillval Backup';
            prod2.productCode = 'CO-DATANET-TILLVAL-BACKUP';
            prod2.vlocity_cmt__ObjectTypeId__c = newObj1.Id;
            prodList.add(prod2);
            
            /*Product2 prod3 = Test_DataFactory.createProducts(1)[0];
prod3.Name = 'Access Basic Wireless 4G Backup';
prod3.productCode = 'CO-DATANET-ACCESS-BASIC-4G';
prod3.vlocity_cmt__ObjectTypeId__c = newObj1.Id;
prodList.add(prod3);

Product2 prod4 = Test_DataFactory.createProducts(1)[0];
prod4.Name = 'Access Basic Wireless 4G Backup Combo CPE';
prod4.productCode = 'CO-DATANET-ACCESS-BASIC-4G-COMBO';
prod4.vlocity_cmt__ObjectTypeId__c = newObj1.Id;
prodList.add(prod4);*/
            
            Product2 prod5 = Test_DataFactory.createProducts(1)[0];
            prod5.Name = 'HERA XYZ';
            prod5.productCode = 'CO-HERA-ALL';
            prod5.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod5);
            
            Product2 prod6 = Test_DataFactory.createProducts(1)[0];
            prod6.Name = 'Introduktionskurs i MS365 eller säkerhet, 1 timme – 3 utbildningsplatser';
            prod6.productCode = 'CG_FREE_SERVICE_PT_SUPPORT_1ASSIGN';
            prod6.MC_Product_Name_Eng__c='Introductory course in MS365 or security, 1 hour – 3 training seats';
            prod6.vlocity_cmt__ObjectTypeId__c = newObj7.Id;
            prodList.add(prod6);
            
            Product2 prod7 = Test_DataFactory.createProducts(1)[0];
            prod7.Name = 'Användarpaket';
            prod7.productCode = 'TPP_PKG';
            prod7.MC_Product_Name_Eng__c='User packages';
            prod7.TeliaSE_Offer_Type__c='Non-SubscriptionOffering';
            prod7.vlocity_cmt__ObjectTypeId__c=newObj2.id;
            prodList.add(prod7);
            
            Product2 prod8 = Test_DataFactory.createProducts(1)[0];
            prod8.Name = 'Svarsservice 20';
            prod8.productCode = 'TPP_TAAS_PACKAGE_20';
            prod8.MC_Product_Name_Eng__c='Outsourced Attendant 20';
            prod8.TeliaSE_Offer_Type__c='SubscriptionOffering';
            prod8.vlocity_cmt__ObjectTypeId__c=newObj2.id;
            prodList.add(prod8);
            
            Product2 prod9 = Test_DataFactory.createProducts(1)[0];
            prod9.name = 'Wired Large Plus Backup';
            prod9.productCode = 'CO-CLOUD-VPN-SD-WAN-WIRED-LARGEPLUS-BACKUP';
            prod9.vlocity_cmt__ObjectTypeId__c = newObj4.Id;
            prod9.TeliaSE_OfferTemplateFlag__c=true;
            prod9.TeliaSE_TemplateCategory__c='CO_alone';
            prod9.MC_Product_Name_Eng__c='Wired Large Plus Backup';
            prodList.add(prod9); 
            
            Product2 prod10 = Test_DataFactory.createProducts(1)[0];
            prod10.name = 'Bredband Start 30 Mbit/s';
            prod10.productCode = 'CO-BBSTART-30MB';
            prod10.vlocity_cmt__ObjectTypeId__c = newObj3.Id;
            prod10.TeliaSE_OfferTemplateFlag__c=true;
            prod10.TeliaSE_TemplateCategory__c='CO_alone';
            prod10.MC_Product_Name_Eng__c='Bredband Start 30 Mbit/s';
            prodList.add(prod10); 
            
            Product2 prod11 = Test_DataFactory.createProducts(1)[0];
            prod11.name = 'Bredband Plus 100Mb/s';
            prod11.productCode = 'CO-BBPLUS-100M';
            prod11.vlocity_cmt__ObjectTypeId__c = newObj5.Id;
            prod11.TeliaSE_OfferTemplateFlag__c=true;
            prod11.TeliaSE_TemplateCategory__c='CO_alone';
            prod11.MC_Product_Name_Eng__c='Bredband Plus 100Mb/s';
            prodList.add(prod11); 
            
            
            Product2 prod12 = Test_DataFactory.createProducts(1)[0];
            prod12.name = 'Jobbmobil 10 GB';
            prod12.productCode = 'MOB_MULTI_10_V3';
            prod12.vlocity_cmt__ObjectTypeId__c = newObj8.Id;
            prod12.TeliaSE_OfferTemplateFlag__c=false;
            prod12.TeliaSE_TemplateCategory__c='';
            prod12.MC_Product_Name_Eng__c='Jobbmobil 10 GB';
            prodList.add(prod12); 
            
            Product2 prod13 = Test_DataFactory.createProducts(1)[0];
            prod13.name = 'Smart Connect Standard';
            prod13.productCode = 'SC_STANDARD';
            prod13.vlocity_cmt__ObjectTypeId__c = newObj9.Id;
            prod13.TeliaSE_OfferTemplateFlag__c=false;
            prod13.TeliaSE_TemplateCategory__c='';
            prod13.MC_Product_Name_Eng__c='Smart Connect Standard';
            prod13.TeliaSE_Offer_Type__c = 'SubscriptionOffering';
            prodList.add(prod13); 
            
            Product2 prod14 = Test_DataFactory.createProducts(1)[0];
            prod14.name = 'AddOn1';
            prod14.productCode = 'MOB_ADDON_SUBS1';
            prod14.vlocity_cmt__ObjectTypeId__c = newObj8.Id;
            prod14.TeliaSE_OfferTemplateFlag__c=false;
            prod14.TeliaSE_TemplateCategory__c='';
            prod14.MC_Product_Name_Eng__c='AddOn1';
            prod14.TeliaSE_Offer_Type__c = 'SubscriptionOffering';
            prodList.add(prod14); 
            
            Product2 prod15 = Test_DataFactory.createProducts(1)[0];
            prod15.name = 'AddOn2';
            prod15.productCode = 'MOB_ADDON_SUBS2';
            prod15.vlocity_cmt__ObjectTypeId__c = newObj8.Id;
            prod15.TeliaSE_OfferTemplateFlag__c=false;
            prod15.TeliaSE_TemplateCategory__c='';
            prod15.MC_Product_Name_Eng__c='AddOn2';
            prod15.TeliaSE_Offer_Type__c = 'SubscriptionOffering';
            prodList.add(prod15); 
            
            Product2 prod16 = Test_DataFactory.createProducts(1)[0];
            prod16.name = 'Group1';
            prod16.productCode = 'MOB_ADDON_GROUP_1';
            prod16.vlocity_cmt__ObjectTypeId__c = newObj8.Id;
            prod16.TeliaSE_OfferTemplateFlag__c=false;
            prod16.TeliaSE_TemplateCategory__c='';
            prod16.MC_Product_Name_Eng__c='Group1';
            prod16.TeliaSE_Offer_Type__c = 'Non-SubscriptionOffering';
            prodList.add(prod16);
            
            Product2 prod17 = Test_DataFactory.createProducts(1)[0];
            prod17.name = 'Group1';
            prod17.productCode = 'TP_OFFER';
            prod17.vlocity_cmt__ObjectTypeId__c = newObj2.Id;
            prod17.TeliaSE_OfferTemplateFlag__c=false;
            prod17.TeliaSE_TemplateCategory__c='';
            prod17.MC_Product_Name_Eng__c='Group1';
            prod17.TeliaSE_Offer_Type__c = 'SubscriptionOffering';
            prodList.add(prod17);
            
            insert prodList;
            
            pricebookId = stdPriceBookRecId;
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
            
            /*PricebookEntry objpricebookentry3 =new PricebookEntry();
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
pbeList.add(objpricebookentry4); */
            
            PricebookEntry objpricebookentry5 =new PricebookEntry();
            objpricebookentry5.Product2ID = prod5.id;
            objpricebookentry5.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry5.UnitPrice=23.50;
            objpricebookentry5.UseStandardPrice=false;
            objpricebookentry5.isActive=true;//Add this line
            pbeList.add(objpricebookentry5);
            
            
            PricebookEntry objpricebookentry12 =new PricebookEntry();
            objpricebookentry12.Product2ID = prod12.id;
            objpricebookentry12.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry12.UnitPrice=23.50;
            objpricebookentry12.UseStandardPrice=false;
            objpricebookentry12.isActive=true;//Add this line
            pbeList.add(objpricebookentry12);
            
            PricebookEntry objpricebookentry13 =new PricebookEntry();
            objpricebookentry13.Product2ID = prod13.id;
            objpricebookentry13.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry13.UnitPrice=23.50;
            objpricebookentry13.UseStandardPrice=false;
            objpricebookentry13.isActive=true;//Add this line
            pbeList.add(objpricebookentry13);
            
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
            opp.Pricebook2Id=stdPriceBookRecId;
            insert opp;
            
            
            Quote qut = new Quote();
            qut.Name='Test Quote';
            qut.status = 'Draft';  
            qut.opportunityId = opp.id;
            qut.Pricebook2ID = stdPriceBookRecId;
            qut.TeliaSE_Approval_Flag__c = False;
            qut.TeliaSE_MC_Sales_Flow_Identifier__c='New Sales';
            insert qut;
            
            //Creating contract below
            Contract contract=new Contract();
            contract.Name='Test';
            contract.AccountId=acc.id;
            contract.Status='Draft';
            contract.Solution_Area__c='Vxl';
            contract.StartDate=Date.today();
            contract.ContractTerm=24;
            contract.vlocity_cmt__QuoteId__c=qut.id;
            insert contract;
            
            //Creatting Premisies
            List<vlocity_cmt__Premises__c> premiseList = new List<vlocity_cmt__Premises__c>();
            vlocity_cmt__Premises__c premise = new vlocity_cmt__Premises__c();
            premise.vlocity_cmt__City__c = 'solna';
            premise.vlocity_cmt__StreetAddress__c = 'Överskärargränd';
            premise.vlocity_cmt__PostalCode__c = '12111';
            premise.vlocity_cmt__Address1__c = '12111';
            premise.vlocity_cmt__PropertyOwnerAccountId__c = acc.Id;
            premiseList.add(premise);
            vlocity_cmt__Premises__c premise1 = new vlocity_cmt__Premises__c();
            premise1.vlocity_cmt__City__c = 'stockholm';
            premise1.vlocity_cmt__StreetAddress__c = 'Stjärntorget';
            premise1.vlocity_cmt__PostalCode__c = '12112';
            premise1.vlocity_cmt__Address1__c = '12112';
            premise1.vlocity_cmt__PropertyOwnerAccountId__c = acc.Id;
            premiseList.add(premise1);
            vlocity_cmt__Premises__c premise2 = new vlocity_cmt__Premises__c();
            premise2.vlocity_cmt__City__c = 'solna';
            premise2.vlocity_cmt__StreetAddress__c = 'Diktarvägen';
            premise2.vlocity_cmt__PostalCode__c = '12113';
            premise2.vlocity_cmt__Address1__c = '12113';
            premise2.vlocity_cmt__PropertyOwnerAccountId__c = acc.Id;
            premiseList.add(premise2);
            vlocity_cmt__Premises__c premise3 = new vlocity_cmt__Premises__c();
            premise3.vlocity_cmt__City__c = 'stockholm';
            premise3.vlocity_cmt__StreetAddress__c = 'Hamngatan';
            premise3.vlocity_cmt__PostalCode__c = '12114';
            premise3.vlocity_cmt__Address1__c = '12114';
            premise3.vlocity_cmt__PropertyOwnerAccountId__c = acc.Id;
            premiseList.add(premise3);
            vlocity_cmt__Premises__c premise4 = new vlocity_cmt__Premises__c();
            premise4.vlocity_cmt__City__c = 'stockholm';
            premise4.vlocity_cmt__StreetAddress__c = 'Kanslikajen';
            premise4.vlocity_cmt__PostalCode__c = '12115';
            premise4.vlocity_cmt__Address1__c = '12115';
            premise4.vlocity_cmt__PropertyOwnerAccountId__c = acc.Id;
            premiseList.add(premise4);
            insert premiseList;
            //Creating service point link between Service point and premises
            List<vlocity_cmt__ServicePoint__c> spointList = new List<vlocity_cmt__ServicePoint__c>();
            vlocity_cmt__ServicePoint__c spoint = new vlocity_cmt__ServicePoint__c();
            spoint.vlocity_cmt__ServicePointNumber__c = '148573009';
            spoint.vlocity_cmt__PremisesId__c = premise.Id;
            spointList.add(spoint);
            vlocity_cmt__ServicePoint__c spoint1 = new vlocity_cmt__ServicePoint__c();
            spoint1.vlocity_cmt__ServicePointNumber__c = '1212123';
            spoint1.vlocity_cmt__PremisesId__c = premise1.Id;
            spointList.add(spoint1);
            vlocity_cmt__ServicePoint__c spoint2 = new vlocity_cmt__ServicePoint__c();
            spoint2.vlocity_cmt__ServicePointNumber__c = '1212124';
            spoint2.vlocity_cmt__PremisesId__c = premise2.Id;
            spointList.add(spoint2);
            vlocity_cmt__ServicePoint__c spoint3 = new vlocity_cmt__ServicePoint__c();
            spoint3.vlocity_cmt__ServicePointNumber__c = '1212125';
            spoint3.vlocity_cmt__PremisesId__c = premise3.Id;
            spointList.add(spoint3);
            vlocity_cmt__ServicePoint__c spoint4 = new vlocity_cmt__ServicePoint__c();
            spoint4.vlocity_cmt__ServicePointNumber__c = '1212125';
            spoint4.vlocity_cmt__PremisesId__c = premise4.Id;
            spointList.add(spoint4);
            insert spointList;
            list<recordtype> quoteRecordTypes = [SELECT Id,DeveloperName FROM recordtype where (DeveloperName = 'Offer' OR DeveloperName = 'Contract') AND SobjectType = 'Quote'];
            //list<recordtype> faQuoteRecId = [SELECT Id FROM recordtype where DeveloperName = 'Contract' AND SobjectType = 'Quote' limit 1];
            
            String faQuoteRecId,offerQuoteRecId;
            for(Recordtype recType : quoteRecordTypes){
                if(recType.DeveloperName == 'Offer'){
                    offerQuoteRecId = recType.Id;
                }
                else if(recType.DeveloperName == 'Contract'){
                    faQuoteRecId = recType.Id;
                }
            }
            
            //Create FA quote
            Quote faQuote = new Quote();
            faQuote.Name='Test Quote';
            faQuote.status = 'Draft';
            faQuote.TeliaSE_Type__c='Renegotiation';
            faQuote.opportunityId = opp.id;
            faQuote.Pricebook2ID = stdPriceBookRecId;
            faQuote.TeliaSE_Approval_Flag__c = true; 
            faQuote.RecordTypeId = id.valueof((string)faQuoteRecId);
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
            offerQuote.TeliaSE_Offer__c='Bredband Plus,Datanet,Bredband Pro,Bredband Start,VPN SD-WAN,VPN WIFI';
            offerQuote.RecordTypeId = id.valueof((string)offerQuoteRecId);
            insert offerQuote;
            
            //Creating quote groups
            List<vlocity_cmt__QuoteGroup__c> quoteGroupList = new List<vlocity_cmt__QuoteGroup__c>();
            vlocity_cmt__QuoteGroup__c quoteGroup = new vlocity_cmt__QuoteGroup__c();
            quoteGroup.Name = 'Group 1';
            quoteGroup.vlocity_cmt__Description__c = 'Group 1';
            quoteGroup.vlocity_cmt__QuoteId__c = offerQuote.id;
            quoteGroupList.add(quoteGroup);
            vlocity_cmt__QuoteGroup__c quoteGroup1 = new vlocity_cmt__QuoteGroup__c();
            quoteGroup1.Name = 'Group 2';
            quoteGroup1.vlocity_cmt__Description__c = 'Group 2';
            quoteGroup1.vlocity_cmt__QuoteId__c = offerQuote.id;
            quoteGroupList.add(quoteGroup1);
            vlocity_cmt__QuoteGroup__c quoteGroup2 = new vlocity_cmt__QuoteGroup__c();
            quoteGroup2.Name = 'Group 3';
            quoteGroup2.vlocity_cmt__Description__c = 'Group 3';
            quoteGroup2.vlocity_cmt__QuoteId__c = offerQuote.id;
            quoteGroupList.add(quoteGroup2);
            vlocity_cmt__QuoteGroup__c quoteGroup3 = new vlocity_cmt__QuoteGroup__c();
            quoteGroup3.Name = 'Group 4';
            quoteGroup3.vlocity_cmt__Description__c = 'Group 4';
            quoteGroup3.vlocity_cmt__QuoteId__c = offerQuote.id;
            quoteGroupList.add(quoteGroup3);
            vlocity_cmt__QuoteGroup__c quoteGroup4 = new vlocity_cmt__QuoteGroup__c();
            quoteGroup4.Name = 'Group 5';
            quoteGroup4.vlocity_cmt__Description__c = 'Group 5';
            quoteGroup4.vlocity_cmt__QuoteId__c = offerQuote.id;
            quoteGroupList.add(quoteGroup4);
            insert quoteGroupList;
            
            //Creating quote members
            List<vlocity_cmt__QuoteMember__c> quoteMemList = new List<vlocity_cmt__QuoteMember__c>();
            vlocity_cmt__QuoteMember__c quoteMem = new vlocity_cmt__QuoteMember__c();
            quoteMem.vlocity_cmt__ServicePointId__c = spoint.Id;
            quoteMem.vlocity_cmt__QuoteGroupId__c = quoteGroup.Id;
            quoteMem.vlocity_cmt__QuoteId__c = offerQuote.id;
            quoteMemList.add(quoteMem);
            vlocity_cmt__QuoteMember__c quoteMem1 = new vlocity_cmt__QuoteMember__c();
            quoteMem1.vlocity_cmt__ServicePointId__c = spoint1.Id;
            quoteMem1.vlocity_cmt__QuoteGroupId__c = quoteGroup1.Id;
            quoteMem1.vlocity_cmt__QuoteId__c = offerQuote.id;
            quoteMemList.add(quoteMem1);
            vlocity_cmt__QuoteMember__c quoteMem2 = new vlocity_cmt__QuoteMember__c();
            quoteMem2.vlocity_cmt__ServicePointId__c = spoint2.Id;
            quoteMem2.vlocity_cmt__QuoteGroupId__c = quoteGroup2.Id;
            quoteMem2.vlocity_cmt__QuoteId__c = offerQuote.id;
            quoteMemList.add(quoteMem2);
            vlocity_cmt__QuoteMember__c quoteMem3 = new vlocity_cmt__QuoteMember__c();
            quoteMem3.vlocity_cmt__ServicePointId__c = spoint3.Id;
            quoteMem3.vlocity_cmt__QuoteGroupId__c = quoteGroup3.Id;
            quoteMem3.vlocity_cmt__QuoteId__c = offerQuote.id;
            quoteMemList.add(quoteMem3);
            vlocity_cmt__QuoteMember__c quoteMem4 = new vlocity_cmt__QuoteMember__c();
            quoteMem4.vlocity_cmt__ServicePointId__c = spoint4.Id;
            quoteMem4.vlocity_cmt__QuoteGroupId__c = quoteGroup4.Id;
            quoteMem4.vlocity_cmt__QuoteId__c = offerQuote.id;
            quoteMemList.add(quoteMem4);
            insert quoteMemList;
            
            QuoteLineItem oli2 = new QuoteLineItem();
            oli2.quoteid=faQuote.id;
            oli2.TeliaSE_MC_FACallOffQuantity__c=2;
            oli2.PricebookEntryId = objpricebookentry1.Id;
            oli2.TeliaSE_MC_Customer_Requested_Percentage__c=10;
            oli2.QuoteId = offerQuote.id;
            oli2.UnitPrice = 200;
            oli2.Quantity = 4;
            oli2.vlocity_cmt__Product2Id__c = prod7.Id;
            oli2.Product2Id = prod7.id;
            oli2.TeliaSE_Flag__c= '/resource/1549546732000/TeliaSE_Happy_Face';
            oli2.TeliaSE_Approved__c = null;
            oli2.vlocity_cmt__RecurringCharge__c  = 200;
            oli2.TeliaSE_Ceiling_Price__c = 400;
            oli2.TeliaSE_Root_Product__c=prod1.id;
            oli2.vlocity_cmt__ProductHierarchyPath__c = prod7.id;
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
            //oli2.vlocity_cmt__QuoteGroupId__c = quoteGroup1.id;
            oli2.TeliaSE_MC_Binding_Time__c = '24';
            //oli2.vlocity_cmt__JSONAttribute__c = '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a367Z000000PDG0QAO","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_NEG_ROAMING_TILL","attributeconfigurable__c":true,"attributedisplaysequence__c":"90","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"MC Roaming Till AddOns","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5bQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Standard 89 kr, 49 kr, 19 kr","valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"}],"values":[{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"},{"value":"69 kr, 49 kr, 19 kr","sequence":2,"id":"a63eccc4-e18f-75ec-42fb-2200074c064b","displayText":"69 kr, 49 kr, 19 kr"},{"value":"59 kr, 39 kr, 19 kr","sequence":3,"id":"f5f0a872-81aa-0e6d-69a5-cb7ed4d135dd","displayText":"59 kr, 39 kr, 19 kr"},{"value":"69 kr, 49 kr, 15 kr","sequence":4,"id":"e6cd61d3-92da-312e-a4b2-e70436ac950c","displayText":"69 kr, 49 kr, 15 kr"},{"value":"59 kr, 39 kr, 15 kr","sequence":5,"id":"e32ac4bd-6719-f23c-466b-738d35a2d65d","displayText":"59 kr, 39 kr, 15 kr"},{"value":"Europa - alla anv. 49 kr, 49 kr, 19 kr","sequence":6,"id":"ad9fcac8-bd33-8736-c1a2-3d18994136de","displayText":"Europa - alla anv. 49 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 39 kr, 49 kr, 19 kr","sequence":7,"id":"183b5d9d-f0d5-f30d-d58c-7a74b0a211c3","displayText":"Europa - alla anv. 39 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 29 kr, 49 kr, 19 kr","sequence":8,"id":"551aee5a-637e-9907-beed-05b0ec37b272","displayText":"Europa - alla anv. 29 kr, 49 kr, 19 kr"},{"value":"Europa - alla anv. 0 kr, 49 kr, 19 kr","sequence":9,"id":"4d405be4-e94e-b0b5-314d-d4a27ba8f3cc","displayText":"Europa - alla anv. 0 kr, 49 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 29 kr, 19 kr","sequence":10,"id":"1ba0de8b-b225-49d5-c596-4874b84c4297","displayText":"Grannland - alla anv. 89 kr, 29 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 19 kr, 19 kr","sequence":11,"id":"789c7c6f-df0b-9c54-a865-f4d93215ca88","displayText":"Grannland - alla anv. 89 kr, 19 kr, 19 kr"},{"value":"Grannland - alla anv. 89 kr, 0 kr, 19 kr","sequence":12,"id":"d43f776a-90ac-2ccf-0dbb-a7a5b63f6eb8","displayText":"Grannland - alla anv. 89 kr, 0 kr, 19 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 12 kr","sequence":13,"id":"ccf729aa-485a-311b-a010-cd6727d8f27a","displayText":"Utland - alla anv. 89 kr, 49 kr, 12 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 12 kr","sequence":14,"id":"be39cb66-6a44-6372-d7bf-438f130eebc3","displayText":"Utland - alla anv. 69 kr, 39 kr, 12 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 9 kr","sequence":15,"id":"454ff5e3-64bb-ca6a-6af4-b9810ae53971","displayText":"Utland - alla anv. 89 kr, 49 kr, 9 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 9 kr","sequence":16,"id":"f8ad24c8-d0bf-b09b-06a3-55ccdfbb0c71","displayText":"Utland - alla anv. 69 kr, 39 kr, 9 kr"},{"value":"Utland - alla anv. 89 kr, 49 kr, 0 kr","sequence":17,"id":"97d75109-a29f-8b72-96d0-e84149d77339","displayText":"Utland - alla anv. 89 kr, 49 kr, 0 kr"},{"value":"Utland - alla anv. 69 kr, 39 kr, 0 kr","sequence":18,"id":"296f3be9-3b0e-3155-e177-2b1f466e9b56","displayText":"Utland - alla anv. 69 kr, 39 kr, 0 kr"},{"value":"Europa & Utland - alla anv.  49 kr, 49 kr, 12 kr","sequence":19,"id":"2eea7313-03cb-9da5-3741-48a98cd2636b","displayText":"Europa & Utland - alla anv.  49 kr, 49 kr, 12 kr"},{"value":"Europa & Utland - alla anv. 39 kr, 49 kr, 12 kr","sequence":20,"id":"e4b437ac-32bb-b61f-708a-43f3923d0723","displayText":"Europa & Utland - alla anv. 39 kr, 49 kr, 12 kr"},{"value":"Europa & Utland - alla anv. 29 kr, 49 kr, 9 kr","sequence":21,"id":"25190e10-0c3a-419f-7cd9-ed43fe36260c","displayText":"Europa & Utland - alla anv. 29 kr, 49 kr, 9 kr"},{"value":"Europa & Utland - alla anv. 0 kr, 49 kr, 0 kr","sequence":22,"id":"263d1bda-d9ae-d7ca-3f63-04093ff493da","displayText":"Europa & Utland - alla anv. 0 kr, 49 kr, 0 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 29 kr, 12 kr","sequence":23,"id":"c355e733-ee3c-6833-5aa4-c71196e19cdb","displayText":"Grannland & Utland - alla anv. 89 kr, 29 kr, 12 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 19 kr, 9 kr","sequence":24,"id":"23bd33c8-cd75-903a-d9cc-eb820e004ba6","displayText":"Grannland & Utland - alla anv. 89 kr, 19 kr, 9 kr"},{"value":"Grannland & Utland - alla anv. 89 kr, 0 kr, 0 kr","sequence":25,"id":"fe688552-297a-a1f2-5de1-3f2fd8c5b483","displayText":"Grannland & Utland - alla anv. 89 kr, 0 kr, 0 kr"}],"selectedItem":{"value":"Standard 89 kr, 49 kr, 19 kr","sequence":1,"id":"f713a720-7fa6-dcbf-9bba-b75645e490b4","displayText":"Standard 89 kr, 49 kr, 19 kr"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VknQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_PARENT","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Parent","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5dQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"All-In Plus"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VkqQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5aQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":"12 months","sequence":1,"id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","displayText":"12 months"},{"value":"24 months","sequence":2,"id":"aba9e042-0545-92b0-b0d0-16cd00888e83","displayText":"24 months"},{"value":"36 months","sequence":3,"id":"cbdeb314-b13b-d53d-72ec-8e4c3370b908","displayText":"36 months"}],"default":[],"selectedItem":{"value":"12 months","sequence":1,"id":"f21ed11d-241a-1301-b2e0-af4e3d292fa8","displayText":"12 months"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VktQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5cQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Single Value","value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Number","uiDisplayType":"Single Value","value":123},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1p0000081yLrAAI","attributeid__c":"a363E0000005VkuQAE","attributecategoryid__c":"a353E000003rEvcQAE","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_SUB","attributeconfigurable__c":true,"attributedisplaysequence__c":"50","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Subsidized","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a339E000000Ie5eQAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":"Yes","sequence":1,"id":"2b5df0d6-eb1a-e9fa-950f-d6ca7614ee1e","displayText":"Yes"},{"value":"No","sequence":2,"id":"67dda21b-85c6-ce74-2955-5094c85f021c","displayText":"No"}],"default":[],"selectedItem":{"value":"No","sequence":2,"id":"67dda21b-85c6-ce74-2955-5094c85f021c","displayText":"No"}},"$$AttributeDefinitionEnd$$":null}]}';
            oli2.RoamingResAddOns__c = '15 kr, 15 kr, 15 kr';
            oli2.RoamingTillAddOns__c = '69 kr, 49 kr, 15 kr';
            insert oli2;
            
            List<vlocity_cmt__ContractLineItem__c> cliList = new List<vlocity_cmt__ContractLineItem__c>();
            vlocity_cmt__ContractLineItem__c cli1 = new vlocity_cmt__ContractLineItem__c();
            cli1.vlocity_cmt__ContractId__c = contract.id;
            cli1.vlocity_cmt__Product2Id__c = prod7.Id;
            cli1.Name ='Touchpoint';
            //cli1.TeliaSE_Product_Object_Type__c='TouchPoint Plus Offer Spec';
            cli1.vlocity_cmt__LineStatus__c = 'Added';
            //cli1.vlocity_cmt__QuoteId__c=
            cli1.TeliaSE_Base_Quantity__c =5;
            cli1.vlocity_cmt__QuoteLineItem__c=oli2.id;
            cli1.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli1);
            
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
            
            cli4.vlocity_cmt__LineStatus__c = 'Updated';
            
            cli4.TeliaSE_Product_Object_Type__c=newObj2.Name;
            cli4.TeliaSE_Base_Quantity__c =5;
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
            cli6.Name ='Smart Connect Standard';
            cli6.vlocity_cmt__LineStatus__c = 'Updated';
            cli6.TeliaSE_Product_Object_Type__c=newObj9.Name;
            cli6.TeliaSE_Base_Quantity__c =5;
            cli6.TeliaSE_ParentClusterCode__c = 'SC_KLU_PLUS';
            cli6.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli6);
            
            vlocity_cmt__ContractLineItem__c cli7 = new vlocity_cmt__ContractLineItem__c();
            cli7.vlocity_cmt__ContractId__c = contract.id;
            cli7.vlocity_cmt__Product2Id__c = prod14.Id;
            cli7.Name ='Subs1';
            cli7.vlocity_cmt__LineStatus__c = 'Updated';
            cli7.TeliaSE_Product_Object_Type__c=newObj8.Name;
            cli7.TeliaSE_Base_Quantity__c =5;
            cli7.TeliaSE_ParentClusterCode__c = 'bas';
            cli7.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli7);
            
            vlocity_cmt__ContractLineItem__c cli8 = new vlocity_cmt__ContractLineItem__c();
            cli8.vlocity_cmt__ContractId__c = contract.id;
            cli8.vlocity_cmt__Product2Id__c = prod14.Id;
            cli8.Name ='Subs1';
            cli8.vlocity_cmt__LineStatus__c = 'Existing';
            cli8.TeliaSE_Product_Object_Type__c=newObj8.Name;
            cli8.TeliaSE_Base_Quantity__c =5;
            cli8.TeliaSE_ParentClusterCode__c = 'small';
            cli8.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli8);
            
            vlocity_cmt__ContractLineItem__c cli9 = new vlocity_cmt__ContractLineItem__c();
            cli9.vlocity_cmt__ContractId__c = contract.id;
            cli9.vlocity_cmt__Product2Id__c = prod16.Id;
            cli9.Name ='group1';
            cli9.vlocity_cmt__LineStatus__c = 'Existing';
            cli9.TeliaSE_Product_Object_Type__c=newObj8.Name;
            cli9.TeliaSE_Base_Quantity__c =5;
            //cli9.TeliaSE_ParentClusterCode__c = 'small';
            cli9.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli9);
            
            vlocity_cmt__ContractLineItem__c cli10 = new vlocity_cmt__ContractLineItem__c();
            cli10.vlocity_cmt__ContractId__c = contract.id;
            cli10.vlocity_cmt__Product2Id__c = prod17.Id;
            cli10.Name ='group1';
            cli10.vlocity_cmt__LineStatus__c = 'Existing';
            cli10.TeliaSE_Product_Object_Type__c=newObj2.Name;
            cli10.TeliaSE_Base_Quantity__c =5;
            //cli9.TeliaSE_ParentClusterCode__c = 'small';
            cli10.vlocity_cmt__RecurringCharge__c = 35;
            cli10.vlocity_cmt__QuoteLineItem__c = oli2.Id;
            cli10.vlocity_cmt__OneTimeCharge__c = 100;
            cliList.add(cli10);
            
            insert cliList;
            
            MC_AddOn_Benefit_Tracking__c bft = new MC_AddOn_Benefit_Tracking__c();
            bft.AddOn_Name__c=prod6.id;
            bft.Contract__c=contract.id;
            bft.Quote__c=faQuote.id;
            bft.End_Date__c=date.valueof('2023-12-10');
            insert bft;
            
            MC_AddOn_Benefit_Tracking__c bft2 = new MC_AddOn_Benefit_Tracking__c();
            bft2.AddOn_Name__c=prod6.id;
            bft2.Contract__c=contract.id;
            bft2.Quote__c=faQuote.id;
            bft2.End_Date__c=date.valueof('2023-12-10');
            insert bft2;
            
            
            Utilizer_Contract_Relationship__c util = new Utilizer_Contract_Relationship__c();
            util.MC_Daughter_Company_Flag__c=true;
            util.Status__c='Draft';
            util.Org_Number__c='989898989';
            util.ContractNumber__c=Contract.id;
            insert util;
            
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
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli12 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli12.Product__c=prod9.id;
            sqli12.QuoteId__c=offerQuote.id;
            sqli12.Quote_Member__c=quoteMem1.Id;
            sqli12.Quote_Group__c=quoteGroup.Id;            
            sqli12.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli12.TeliaSE_OnetimeCharge__c=objpricebookentry.UnitPrice * 5;
            sqli12.TeliaSE_MC_Binding_Time__c= '12';
            sqli12.TeliaSE_List_Price__c= objpricebookentry.UnitPrice;
            sqli12.TeliaSE_Aggregated_Quantity__c=5;
            sqli12.TeliaSE_Root_Product__c=null;
            sqli12.MC_TeliaExcludeQuoteItem__c=false;  
            sqli12.TeliaSE_Parent_ItemId__c= null;
            insert sqli12;
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli13 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli13.Product__c=prod5.id;
            sqli13.QuoteId__c=offerQuote.id;
            sqli13.Quote_Member__c=quoteMem2.Id;
            sqli13.Quote_Group__c=quoteGroup2.Id;            
            sqli13.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli13.TeliaSE_OnetimeCharge__c=objpricebookentry.UnitPrice * 5;
            sqli13.TeliaSE_MC_Binding_Time__c= '12';
            sqli13.TeliaSE_List_Price__c= objpricebookentry.UnitPrice;
            sqli13.TeliaSE_Aggregated_Quantity__c=5;
            sqli13.TeliaSE_Root_Product__c=null;
            sqli13.MC_TeliaExcludeQuoteItem__c=false;  
            sqli13.TeliaSE_Parent_ItemId__c= null;
            insert sqli13;
            
            TeliaSE_SimplifiedQuoteLineItem__c sqli14 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli14.Product__c=prod10.id;
            sqli14.QuoteId__c=offerQuote.id;
            sqli14.Quote_Member__c=quoteMem3.Id;
            sqli14.Quote_Group__c=quoteGroup3.Id;            
            sqli14.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli14.TeliaSE_OnetimeCharge__c=objpricebookentry.UnitPrice * 5;
            sqli14.TeliaSE_MC_Binding_Time__c= '12';
            sqli14.TeliaSE_List_Price__c= objpricebookentry.UnitPrice;
            sqli14.TeliaSE_Aggregated_Quantity__c=5;
            sqli14.TeliaSE_Root_Product__c=null;
            sqli14.MC_TeliaExcludeQuoteItem__c=false;  
            sqli14.TeliaSE_Parent_ItemId__c= null;
            insert sqli14;
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
            
			TeliaSE_SimplifiedQuoteLineItem__c sqli32 = new TeliaSE_SimplifiedQuoteLineItem__c();
            sqli32.Product__c=prod1.id;
            sqli32.QuoteId__c=offerQuote.id;
            sqli32.Quote_Member__c=null;
            sqli32.Quote_Group__c=null;            
            sqli32.TeliaSE_Offer_Type__c ='SubscriptionOffering';
            sqli32.TeliaSE_OnetimeCharge__c=objpricebookentry1.UnitPrice * 5;
            sqli32.TeliaSE_MC_Binding_Time__c= '12';
            sqli32.TeliaSE_List_Price__c= objpricebookentry1.UnitPrice;
            sqli32.TeliaSE_Aggregated_Quantity__c=1;
            sqli32.TeliaSE_Root_Product__c=null;
            sqli32.MC_TeliaExcludeQuoteItem__c=true; 
            sqli32.TeliaSE_Parent_ItemId__c= newId;
            insert sqli32;
			
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
            sqli9.Product__c=prod11.id;
            sqli9.QuoteId__c=offerQuote.id;
            sqli9.Quote_Member__c=quoteMem4.Id;
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
            sqli11.TeliaSE_OnetimeCharge__c=objpricebookentry2.UnitPrice * 5;
            sqli11.TeliaSE_MC_Binding_Time__c= '12';
            sqli11.TeliaSE_List_Price__c= objpricebookentry2.UnitPrice;
            sqli11.TeliaSE_Aggregated_Quantity__c=1;
            sqli11.TeliaSE_Root_Product__c=null;
            sqli11.MC_TeliaExcludeQuoteItem__c=false;  
            sqli11.TeliaSE_Parent_ItemId__c= null;
            insert sqli11;
            
            List<Object> arguments = new List<Object>();
            List<Object> argumentsNew = new List<Object>();
            List<Object> argumentsAG = new List<Object>();
            String cid = contract.id;
            string cnstatus = contract.Status;
            string accid = acc.id;
            arguments.add(cid);
            arguments.add(accid);
            arguments.add(cnstatus);
            argumentsNew.add(opp.id);
            argumentsNew.add(accid);
            argumentsNew.add(cnstatus);
            argumentsNew.add(cid);
            argumentsAG.add(cid);
            argumentsAG.add(false);
            argumentsAG.add('Cloud VPN SD-WAN/Firewall;Cloud VPN WIFI/LAN;Försäkring;IT-avdelning/IT-avdelning Start;Jobbmobil;Personlig Tekniker;Smart Säkerhet;Bredband Plus;Bredband Pro;Bredband Start;Datanet;TouchPoint;TouchPoint Plus');
            inputs.put('arguments',arguments);
            inputMap.put('arguments',argumentsNew);
            inputMapAG.put('arguments',argumentsAG);
            
            Test.startTest();
            MassCustomized_Agreement_Generation obj=new MassCustomized_Agreement_Generation();
            Boolean flag = obj.invokeMethod('agreementgenerate', inputMapAG, output, options);
            Boolean flag1 = obj.invokeMethod('CheckContractlineItem', inputs, output, options);
            Boolean flag2 = obj.invokeMethod('initalDocumentGenerate', inputs, output, options);
            Boolean flag3 = obj.invokeMethod('initalDocumentGenerateOfferQuote', inputMap, output, options);
            
            Boolean flag4 = obj.invokeMethod('deltaAgreementGenerate', inputs, output, options);
            Test.stopTest();
            //MassCustomized_Agreement_Generation.initialTableDisplay(cid, inputMap, output);
            
        }
    }    
    
    
    @isTest
    
    static void testGroupSorting() {
        // Test data set
        List<Object> ListGroupMap = new List<Object>{
            new Map<String,Object>{'GroupIndex' => 3},
                new Map<String,Object>{'GroupIndex' => 2},
                    new Map<String,Object>{'GroupIndex' => 1}
        };
            
            // Instantiate class containing method to test
            MassCustomized_Agreement_Generation myClassInstance = new MassCustomized_Agreement_Generation();
        
        // Call the method to test
        List<Object> sortedList = myClassInstance.groupSorting(ListGroupMap);
        
    }  
    
    @isTest
    Public static void ClusterTable(){
        User salesManager;         
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        salesManager = Test_DataFactory.createAdminUser();
        salesManager.ForecastEnabled = true;
        salesManager.Bypass_VR__c = true;
        insert salesManager;
        System.runAs(salesManager){
            Map<String,Object> inputs=new Map<String,Object>();
            Map<String,Object> inputMap=new Map<String,Object>();
            Map<String,Object> output=new Map<String,Object>();
            Map<String,Object> options=new Map<String,Object>();
            
            List<vlocity_cmt__ObjectClass__c> objList = new List<vlocity_cmt__ObjectClass__c>();
            vlocity_cmt__ObjectClass__c newObj1=new vlocity_cmt__ObjectClass__c();
            newObj1.Name = 'Mobile Offer Specification';
            newObj1.vlocity_cmt__IsActive__c = true;
            newObj1.vlocity_cmt__ObjectApiName__c ='Product2';
            objList.add(newObj1);
            
            vlocity_cmt__ObjectClass__c newObj2=new vlocity_cmt__ObjectClass__c();
            newObj2.Name = 'Smart Connect Offer Spec';
            newObj2.vlocity_cmt__IsActive__c = true;
            newObj2.vlocity_cmt__ObjectApiName__c ='Product2';
            objList.add(newObj2);
            
            List<product2> prodList = Test_DataFactory.createProducts(4);
            prodList[0].name = 'AddOn1';
            prodList[0].productCode = 'MOB_ADDON_SUBS1';
            prodList[0].vlocity_cmt__ObjectTypeId__c = newObj1.Id;
            prodList[0].TeliaSE_Offer_type__c = 'SubscriptionOffering';
            prodList[0].MC_Product_Name_Eng__c='Addon1';
            prodList[1].name = 'AddOn2';
            prodList[1].productCode = 'MOB_ADDON_SUBS2';
            prodList[1].vlocity_cmt__ObjectTypeId__c = newObj1.Id;
            prodList[1].TeliaSE_Offer_type__c = 'SubscriptionOffering';
            prodList[1].MC_Product_Name_Eng__c='Addon2';
            prodList[2].name = 'Group1';
            prodList[2].productCode = 'MOB_ADDON_GROUP_1';
            prodList[2].vlocity_cmt__ObjectTypeId__c = newObj1.Id;
            prodList[2].TeliaSE_Offer_type__c = 'Non-SubscriptionOffering';
            prodList[2].MC_Product_Name_Eng__c='Group1';
            prodList[3].name = 'Smart Connect Standard';
            prodList[3].productCode = 'SC_STANDARD';
            prodList[3].vlocity_cmt__ObjectTypeId__c = newObj2.Id;
            prodList[3].TeliaSE_Offer_type__c = 'SubscriptionOffering';
            prodList[3].MC_Product_Name_Eng__c='Group1';
            insert prodList;
            
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
            opp.Pricebook2Id=stdPriceBookRecId;
            insert opp;
            
            
            Quote qut = new Quote();
            qut.Name='Test Quote';
            qut.status = 'Draft';  
            qut.opportunityId = opp.id;
            qut.Pricebook2ID = stdPriceBookRecId;
            qut.TeliaSE_Approval_Flag__c = False;
            qut.TeliaSE_MC_Sales_Flow_Identifier__c='New Sales';
            insert qut;
            
            //Creating contract below
            Contract contract=new Contract();
            contract.Name='Test';
            contract.AccountId=acc.id;
            contract.Status='Draft';
            contract.Solution_Area__c='Vxl';
            contract.StartDate=Date.today();
            contract.ContractTerm=24;
            contract.vlocity_cmt__QuoteId__c=qut.id;
            contract.MC_Selected_Document_Template__c = 'ENG_ENG_ENG';
            insert contract;
            
            //Cli List  
            List<vlocity_cmt__ContractLineItem__c> cliList = new List<vlocity_cmt__ContractLineItem__c>();          
            vlocity_cmt__ContractLineItem__c cli1 = new vlocity_cmt__ContractLineItem__c();
            cli1.vlocity_cmt__ContractId__c = contract.id;
            cli1.vlocity_cmt__Product2Id__c = prodList[3].Id;
            cli1.Name ='Smart Connect Standard';            
            cli1.vlocity_cmt__LineStatus__c = 'added';
            cli1.TeliaSE_Product_Object_Type__c=newObj2.Name;
            cli1.TeliaSE_Base_Quantity__c =5;
            cli1.TeliaSE_ParentClusterCode__c = 'SC_KLU_PLUS';
            cli1.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli1);
            
            vlocity_cmt__ContractLineItem__c cli2 = new vlocity_cmt__ContractLineItem__c();
            cli2.vlocity_cmt__ContractId__c = contract.id;
            cli2.vlocity_cmt__Product2Id__c = prodList[3].Id;
            cli2.Name ='Smart Connect Standard';
            cli2.vlocity_cmt__LineStatus__c = 'added';
            cli2.TeliaSE_Product_Object_Type__c=newObj2.Name;
            cli2.TeliaSE_Base_Quantity__c =5;
            cli2.TeliaSE_ParentClusterCode__c = 'SC_KLU_LARGE';
            cli2.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli2);
            
            vlocity_cmt__ContractLineItem__c cli3 = new vlocity_cmt__ContractLineItem__c();
            cli3.vlocity_cmt__ContractId__c = contract.id;
            cli3.vlocity_cmt__Product2Id__c = prodList[0].Id;
            cli3.Name ='AddOn1';
            cli3.vlocity_cmt__LineStatus__c = 'added';
            cli3.TeliaSE_Product_Object_Type__c=newObj1.Name;
            cli3.TeliaSE_Base_Quantity__c =5;
            cli3.TeliaSE_ParentClusterCode__c = 'bas';
            cli3.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli3);
            
            vlocity_cmt__ContractLineItem__c cli4 = new vlocity_cmt__ContractLineItem__c();
            cli4.vlocity_cmt__ContractId__c = contract.id;
            cli4.vlocity_cmt__Product2Id__c = prodList[0].Id;
            cli4.Name ='AddOn1';
            cli4.vlocity_cmt__LineStatus__c = 'added';
            cli4.TeliaSE_Product_Object_Type__c=newObj1.Name;
            cli4.TeliaSE_Base_Quantity__c =5;
            cli4.TeliaSE_ParentClusterCode__c = 'small';
            cli4.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli4);
            
            vlocity_cmt__ContractLineItem__c cli5 = new vlocity_cmt__ContractLineItem__c();
            cli5.vlocity_cmt__ContractId__c = contract.id;
            cli5.vlocity_cmt__Product2Id__c = prodList[2].Id;
            cli5.Name ='Group1';
            cli5.vlocity_cmt__LineStatus__c = 'added';
            cli5.TeliaSE_Product_Object_Type__c=newObj1.Name;
            cli5.TeliaSE_Base_Quantity__c =5;
            cli5.TeliaSE_ParentClusterCode__c = 'medium';
            cli5.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli5);
            
            vlocity_cmt__ContractLineItem__c cli6 = new vlocity_cmt__ContractLineItem__c();
            cli6.vlocity_cmt__ContractId__c = contract.id;
            cli6.vlocity_cmt__Product2Id__c = prodList[0].Id;
            cli6.Name ='AddOn1';
            cli6.vlocity_cmt__LineStatus__c = 'added';
            cli6.TeliaSE_Product_Object_Type__c=newObj1.Name;
            cli6.TeliaSE_Base_Quantity__c =5;
            cli6.TeliaSE_ParentClusterCode__c = 'xlarge';
            cli6.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli6);
            
            vlocity_cmt__ContractLineItem__c cli7 = new vlocity_cmt__ContractLineItem__c();
            cli7.vlocity_cmt__ContractId__c = contract.id;
            cli7.vlocity_cmt__Product2Id__c = prodList[0].Id;
            cli7.Name ='Addon1';
            cli7.vlocity_cmt__LineStatus__c = 'added';
            cli7.TeliaSE_Product_Object_Type__c=newObj1.Name;
            cli7.TeliaSE_Base_Quantity__c =5;
            cli7.TeliaSE_ParentClusterCode__c = 'medium';
            cli7.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli7);
            
            vlocity_cmt__ContractLineItem__c cli8 = new vlocity_cmt__ContractLineItem__c();
            cli8.vlocity_cmt__ContractId__c = contract.id;
            cli8.vlocity_cmt__Product2Id__c = prodList[3].Id;
            cli8.Name ='Smart Connect Standard';            
            cli8.vlocity_cmt__LineStatus__c = 'updated';
            cli8.TeliaSE_Product_Object_Type__c=newObj2.Name;
            cli8.TeliaSE_Base_Quantity__c =5;
            cli8.TeliaSE_ParentClusterCode__c = 'SC_KLU_LEGACY';
            cli8.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli8);
            
            vlocity_cmt__ContractLineItem__c cli9 = new vlocity_cmt__ContractLineItem__c();
            cli9.vlocity_cmt__ContractId__c = contract.id;
            cli9.vlocity_cmt__Product2Id__c = prodList[3].Id;
            cli9.Name ='Smart Connect Standard';            
            cli9.vlocity_cmt__LineStatus__c = 'updated';
            cli9.TeliaSE_Product_Object_Type__c=newObj2.Name;
            cli9.TeliaSE_Base_Quantity__c =5;
            cli9.TeliaSE_ParentClusterCode__c = 'SC_KLU_PLUS';
            cli9.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli9);
            
            vlocity_cmt__ContractLineItem__c cli11 = new vlocity_cmt__ContractLineItem__c();
            cli11.vlocity_cmt__ContractId__c = contract.id;
            cli11.vlocity_cmt__Product2Id__c = prodList[3].Id;
            cli11.Name ='Smart Connect Standard';            
            cli11.vlocity_cmt__LineStatus__c = 'added';
            cli11.TeliaSE_Product_Object_Type__c=newObj2.Name;
            cli11.TeliaSE_Base_Quantity__c =5;
            cli11.TeliaSE_ParentClusterCode__c = 'SC_KLU_LEGACY';
            cli11.vlocity_cmt__RecurringCharge__c = 35;
            cliList.add(cli11);
            
            insert cliList;
            
            Map<String, MC_ClusterTablePricing__mdt> mcs = MC_ClusterTablePricing__mdt.getAll();
            MC_ClusterTablePricing__mdt mobileMetadata,scMetaData;
            mobileMetaData = mcs.get('Mobile_Offer_Specification');
            scMetaData = mcs.get('Smart_Connect_Offer_Spec');
            
            List<vlocity_cmt__ContractLineItem__c> cliListSC_run1 = new List<vlocity_cmt__ContractLineItem__c>();
            List<vlocity_cmt__ContractLineItem__c> cliListMOB_run1 = new List<vlocity_cmt__ContractLineItem__c>();
            
            List<vlocity_cmt__ContractLineItem__c> cliListSC_run2 = new List<vlocity_cmt__ContractLineItem__c>();
            List<vlocity_cmt__ContractLineItem__c> cliListMOB_run2 = new List<vlocity_cmt__ContractLineItem__c>();
            
            List<vlocity_cmt__ContractLineItem__c> cliListSC_run3 = new List<vlocity_cmt__ContractLineItem__c>();
            List<vlocity_cmt__ContractLineItem__c> cliListMOB_run3 = new List<vlocity_cmt__ContractLineItem__c>();
            
            List<vlocity_cmt__ContractLineItem__c> cliListQueried = [Select id,vlocity_cmt__ContractId__r.MC_Selected_Document_Template__c,vlocity_cmt__Product2Id__r.TeliaSE_Offer_Type__c , vlocity_cmt__ProductCode__c , vlocity_cmt__Product2Id__r.MC_Product_Name_Eng__c , Name,TeliaSE_MC_Customer_Requested_Price__c,vlocity_cmt__RecurringCharge__c,TeliaSE_ParentClusterCode__c,vlocity_cmt__LineStatus__c from vlocity_cmt__ContractLineItem__c where vlocity_cmt__ContractId__c =: contract.id];
            for(vlocity_cmt__ContractLineItem__c cli : cliListQueried)
            {
                if(cli.vlocity_cmt__ProductCode__c == 'SC_STANDARD')
                {
                    cliListSC_run1.add(cli);
                }
                else
                {
                    cliListMOB_run1.add(cli);
                }
            }        
            
            MassCustomized_Agreement_Generation.cls_ClusterAddons cl = new MassCustomized_Agreement_Generation.cls_ClusterAddons();
            cl = MassCustomized_Agreement_Generation.clusterTableDocument(cliListSC_run1, scMetaData);
            cl = MassCustomized_Agreement_Generation.clusterTableDocument(cliListMOB_run1, mobileMetaData);
            
            for(vlocity_cmt__ContractLineItem__c cli : cliListQueried)
            {
                cli.vlocity_cmt__LineStatus__c = 'Updated';
                if(cli.vlocity_cmt__ProductCode__c == 'SC_STANDARD')
                {
                    cliListSC_run2.add(cli);
                }
                else
                {
                    cliListMOB_run2.add(cli);
                }
            }
            cl = MassCustomized_Agreement_Generation.clusterTableDocument(cliListSC_run2, scMetaData);
            cl = MassCustomized_Agreement_Generation.clusterTableDocument(cliListMOB_run2, mobileMetaData);
            
            for(vlocity_cmt__ContractLineItem__c cli : cliListQueried)
            {
                cli.vlocity_cmt__LineStatus__c = 'Active';
                if(cli.vlocity_cmt__ProductCode__c == 'SC_STANDARD')
                {
                    cliListSC_run3.add(cli);
                }
                else
                {
                    cliListMOB_run3.add(cli);
                }
            }
            cl = MassCustomized_Agreement_Generation.clusterTableDocument(cliListSC_run3, scMetaData);
            cl = MassCustomized_Agreement_Generation.clusterTableDocument(cliListMOB_run3, mobileMetaData);
            //MassCustomized_Agreement_Generation.cls_ClusterAddonsSmartConnect clusterAddonsSC = MassCustomized_Agreement_Generation.SmartConnectspecialAddonClisDocumentGenerate(cliList);
        }
    }
    @istest
    static void mockPriceMapTest(){
        Map<String,Object> productTotalmap = new Map<String,Object>();
        Test.startTest();
        MassCustomized_Agreement_Generation.mockPriceMap(productTotalmap);
        Test.stopTest();
    }
}