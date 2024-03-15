@isTest
public with sharing class Test_TeliaSE_FiberProductMigration {
        @testSetup static void setup(){
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
            Map<String,Object> outputMap=new Map<String,Object>();
            Map<String,Object> options=new Map<String,Object>();
            
            List<Product2> prodList = new List<product2>();
            
            vlocity_cmt__ObjectClass__c newObj=new vlocity_cmt__ObjectClass__c();
            newObj.Name = 'Fiber Base Product Spec Type';
            newObj.vlocity_cmt__IsActive__c = true;
            newObj.vlocity_cmt__ObjectApiName__c ='Product2';
            insert newObj;
            
            Product2 prod1 = Test_DataFactory.createProducts(1)[0];
            prod1.name = 'FLIT XLAN';
            prod1.productCode = 'Promo_XLAN_LL';
            prod1.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            insert prod1;
            //prodList.add(prod1);
            
            Product2 prod2 = Test_DataFactory.createProducts(1)[0];
            prod2.name = 'Anslutning Telia som exklusiv tjänsteleverantör';
            prod2.productCode = 'MDU_XLAN_Landlord_1617';
            prod2.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod2);
            
            Product2 prod3 = Test_DataFactory.createProducts(1)[0];
            prod3.name = 'Anslutning Telia som exklusiv tjänsteleverantör Lokal';
            prod3.productCode = 'MDU_XLAN_ComLandlord_1617';
            prod3.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod3);
            
            Product2 prod4 = Test_DataFactory.createProducts(1)[0];
            prod4.name = 'Installationsavgift FLIT XLAN - Kategori 1-4';
            prod4.productCode = 'MDU_XLAN_SmallLandlord_Cat1-4_1943';
            prod4.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod4);
            
            Product2 prod5 = Test_DataFactory.createProducts(1)[0];
            prod5.name = 'Installationsavgift FLIT XLAN - Kategori 5,8,13';
            prod5.productCode = 'MDU_XLAN_SmallLandlord_Cat5,8,13_1943';
            prod5.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod5);
            
            Product2 prod6 = Test_DataFactory.createProducts(1)[0];
            prod6.name = 'Installationsavgift FLIT XLAN - Kategori 5,8,13';
            prod6.productCode = 'MDU_XLAN_SmallLandlord_Cat5,8,13_1943';
           prod6.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod6);
            
            Product2 prod7 = Test_DataFactory.createProducts(1)[0];
            prod7.name = 'Installationsavgift FLIT XLAN - Kategori 6';
            prod7.productCode = 'MDU_XLAN_SmallLandlord_Cat6_1617';
            prod7.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod7);
            
            Product2 prod8 = Test_DataFactory.createProducts(1)[0];
            prod8.name = 'Installationsavgift FLIT XLAN - Kategori 7';
            prod8.productCode = 'MDU_XLAN_SmallLandlord_Cat7_1617';
            prod8.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod8);
            
            Product2 prod9 = Test_DataFactory.createProducts(1)[0];
            prod9.name = 'Installationsavgift FLIT XLAN Lokal - Kategori 1-4';
            prod9.productCode = 'MDU_XLAN_SmallComLandlord_Cat1-4_1943';
            prod9.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod9);
            
            Product2 prod10 = Test_DataFactory.createProducts(1)[0];
            prod10.name = 'Fastighetsstyrning VPN 10 Mbit/s';
            prod10.productCode = 'MDU_FS_VPN_10_2019';
            prod10.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod10);
            
            Product2 prod11 = Test_DataFactory.createProducts(1)[0];
            prod11.name = 'Installationsavgift FLIT XLAN Lokal - Kategori 5,8,13';
            prod11.productCode = 'MDU_XLAN_SmallComLandlord_Cat5,8,13_1943';
            prod11.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod11);
            
            Product2 prod12 = Test_DataFactory.createProducts(1)[0];
            prod12.name = 'Installationsavgift FLIT XLAN Lokal - Kategori 6';
            prod12.productCode = 'MDU_XLAN_SmallComLandlord_Cat6_1624';
            prod12.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod12);
            
            Product2 prod21 = Test_DataFactory.createProducts(1)[0];
            prod21.name = 'Fastighetsnät-Hårdvara';
            prod21.productCode = 'Property Network Hardware Service Bundle';
            prod21.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod21);
            
            Product2 prod22 = Test_DataFactory.createProducts(1)[0];
            prod22.name = 'Kollektiv hårdvara - SFP';
            prod22.productCode = 'MDU_CollHW_SFP20km_1738';
            prod22.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod22);
            
            Product2 prod23 = Test_DataFactory.createProducts(1)[0];
            prod23.name = 'Medieomvandlare';
            prod23.productCode = 'MDU_HW_MC_1729';
            prod23.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod23);
            
            Product2 prod24 = Test_DataFactory.createProducts(1)[0];
            prod24.name = 'Hårdvara';
            prod24.productCode = 'Promo_MDU_Hardware';
            prod24.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod24);
            
            Product2 prod25 = Test_DataFactory.createProducts(1)[0];
            prod25.name = 'Tv';
            prod25.productCode = 'Promo_IPTV_LL';
            prod25.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod25);
            
            Product2 prod26 = Test_DataFactory.createProducts(1)[0];
            prod26.name = 'BB & BBT';
            prod26.productCode = 'Promo_BB_LL';
            prod26.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod26);
            
            Product2 prod27 = Test_DataFactory.createProducts(1)[0];
            prod27.name = 'Tv - Allmänna utrymmen - Lagom';
            prod27.productCode = 'MDU_CollIPTVB2B_Lagom_2143';
            prod27.vlocity_cmt__ObjectTypeId__c = newObj.Id;
            prodList.add(prod27);
            
            insert prodList;
            
            List<PricebookEntry> pbelist = new List<PricebookEntry>();

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
            
            PricebookEntry objpricebookentry7 =new PricebookEntry();
            objpricebookentry7.Product2ID = prod7.id;
            objpricebookentry7.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry7.UnitPrice=23.50;
            objpricebookentry7.UseStandardPrice=false;
            objpricebookentry7.isActive=true;//Add this line
            pbeList.add(objpricebookentry7);
            
            PricebookEntry objpricebookentry8 =new PricebookEntry();
            objpricebookentry8.Product2ID = prod8.id;
            objpricebookentry8.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry8.UnitPrice=23.50;
            objpricebookentry8.UseStandardPrice=false;
            objpricebookentry8.isActive=true;//Add this line
            pbeList.add(objpricebookentry8); 
            
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
            objpricebookentry11.Product2ID = prod11.id;
            objpricebookentry11.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry11.UnitPrice=23.50;
            objpricebookentry11.UseStandardPrice=false;
            objpricebookentry11.isActive=true;//Add this line
            pbeList.add(objpricebookentry11);
            
            PricebookEntry objpricebookentry12 =new PricebookEntry();
            objpricebookentry12.Product2ID = prod12.id;
            objpricebookentry12.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry12.UnitPrice=23.50;
            objpricebookentry12.UseStandardPrice=false;
            objpricebookentry12.isActive=true;//Add this line
            pbeList.add(objpricebookentry12);
            
            PricebookEntry objpricebookentry21 =new PricebookEntry();
            objpricebookentry21.Product2ID = prod21.id;
            objpricebookentry21.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry21.UnitPrice=23.50;
            objpricebookentry21.UseStandardPrice=false;
            objpricebookentry21.isActive=true;//Add this line
            pbeList.add(objpricebookentry21);
            
            PricebookEntry objpricebookentry22 =new PricebookEntry();
            objpricebookentry22.Product2ID = prod22.id;
            objpricebookentry22.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry22.UnitPrice=23.50;
            objpricebookentry22.UseStandardPrice=false;
            objpricebookentry22.isActive=true;//Add this line
            pbeList.add(objpricebookentry22);
            
            PricebookEntry objpricebookentry23 =new PricebookEntry();
            objpricebookentry23.Product2ID = prod23.id;
            objpricebookentry23.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry23.UnitPrice=23.50;
            objpricebookentry23.UseStandardPrice=false;
            objpricebookentry23.isActive=true;//Add this line
            pbeList.add(objpricebookentry23);
            
            PricebookEntry objpricebookentry24 =new PricebookEntry();
            objpricebookentry24.Product2ID = prod24.id;
            objpricebookentry24.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry24.UnitPrice=23.50;
            objpricebookentry24.UseStandardPrice=false;
            objpricebookentry24.isActive=true;//Add this line
            pbeList.add(objpricebookentry24);
            
            PricebookEntry objpricebookentry25 =new PricebookEntry();
            objpricebookentry25.Product2ID = prod25.id;
            objpricebookentry25.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry25.UnitPrice=23.50;
            objpricebookentry25.UseStandardPrice=false;
            objpricebookentry25.isActive=true;//Add this line
            pbeList.add(objpricebookentry25);
            
            PricebookEntry objpricebookentry26 =new PricebookEntry();
            objpricebookentry26.Product2ID = prod26.id;
            objpricebookentry26.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry26.UnitPrice=23.50;
            objpricebookentry26.UseStandardPrice=false;
            objpricebookentry26.isActive=true;//Add this line
            pbeList.add(objpricebookentry26);
            
            /*PricebookEntry objpricebookentry27 =new PricebookEntry();
            objpricebookentry27.Product2ID = prod27.id;
            objpricebookentry27.Pricebook2ID = stdPriceBookRecId;
            objpricebookentry27.UnitPrice=23.50;
            objpricebookentry27.UseStandardPrice=false;
            objpricebookentry27.isActive=true;//Add this line
            pbeList.add(objpricebookentry27);*/
            
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
            contract.Status='Active';
            contract.Solution_Area__c='Vxl';
            contract.StartDate=Date.today();
            contract.ContractTerm=24;
            contract.Type_of_Address__c = 'MDU';
            contract.Region__c = 'MDU Väst';
            insert contract;
            
            ID rtd=[select Id from RecordType where sObjectType = 'Quote' And Name = 'Offer Quote'].Id;
            Quote qut = new Quote();
            qut.RecordTypeId=rtd;
            qut.Name='TestQuote_Migration';
            qut.status = 'Price Approved';
            qut.opportunityId = opp.id;
            qut.Pricebook2ID = stdPriceBookRecId;
            qut.TeliaSE_Approval_Flag__c = False;
            qut.Type_of_Address__c = 'MDU';
            //qut.Region__c = 'MDU Väst';

            insert qut;
            List<QuoteLineItem> qliList = new List<QuoteLineItem>();
            QuoteLineItem oli1 = new QuoteLineItem();
            oli1.PricebookEntryId = objpricebookentry1.Id;
            oli1.QuoteId = qut.id;
            oli1.UnitPrice = 200;
            oli1.Quantity = 4; 
            oli1.TeliaSE_Approved__c = 12.12; 
            oli1.TeliaSE_Nullify_Check__c = false; 
            oli1.TeliaSE_MC_Customer_Requested_Percentage__c = 1; 
            oli1.vlocity_cmt__Product2Id__c = prod1.id;
            oli1.Fiber_Customer_Requested_Price__c = 400;
            oli1.vlocity_cmt__RecurringCharge__c = 200;  
            insert oli1;
            //qliList.add(oli1);
            
            QuoteLineItem oli2 = new QuoteLineItem();
            oli2.PricebookEntryId = objpricebookentry2.Id;
            oli2.QuoteId = qut.id;
            oli2.UnitPrice = 200;
            oli2.Quantity = 4; 
            oli2.TeliaSE_Approved__c = 12.12; 
            oli2.TeliaSE_Nullify_Check__c = false; 
            oli2.TeliaSE_MC_Customer_Requested_Percentage__c = 1; 
            oli2.vlocity_cmt__Product2Id__c = prod2.id;
            oli2.vlocity_cmt__RecurringCharge__c = 200;
            oli2.TeliaSE_Root_Product__c = prod1.id;
            oli2.vlocity_cmt__RootItemId__c = oli1.id ;
            oli2.vlocity_cmt__ParentItemId__c = oli1.id;
            qliList.add(oli2);
            
            QuoteLineItem oli3 = new QuoteLineItem();
            oli3.PricebookEntryId = objpricebookentry3.Id;
            oli3.QuoteId = qut.id;
            oli3.UnitPrice = 200;
            oli3.Quantity = 4; 
            oli3.TeliaSE_Approved__c = 12.12; 
            oli3.TeliaSE_Nullify_Check__c = false; 
            oli3.TeliaSE_MC_Customer_Requested_Percentage__c = 1; 
            oli3.vlocity_cmt__Product2Id__c = prod3.id;
            oli3.Fiber_Customer_Requested_Price__c = 400;
            oli3.TeliaSE_Root_Product__c = prod1.id;
            oli3.vlocity_cmt__RootItemId__c = oli1.id ;
            oli3.vlocity_cmt__ParentItemId__c = oli1.id;
            qliList.add(oli3);
            
            QuoteLineItem oli4 = new QuoteLineItem();
            oli4.PricebookEntryId = objpricebookentry4.Id;
            oli4.QuoteId = qut.id;
            oli4.UnitPrice = 200;
            oli4.Quantity = 4; 
            oli4.TeliaSE_Approved__c = 12.12; 
            oli4.TeliaSE_Nullify_Check__c = false; 
            oli4.TeliaSE_MC_Customer_Requested_Percentage__c = 1; 
            oli4.vlocity_cmt__Product2Id__c = prod4.id;
            oli4.Fiber_Customer_Requested_Price__c = 400; 
            oli4.TeliaSE_Root_Product__c = prod1.id;
            oli4.vlocity_cmt__RootItemId__c = oli1.id ;
            oli4.vlocity_cmt__ParentItemId__c = oli1.id;
            qliList.add(oli4);

            QuoteLineItem oli5 = new QuoteLineItem();
            oli5.PricebookEntryId = objpricebookentry5.Id;
            oli5.QuoteId = qut.id;
            oli5.UnitPrice = 200;
            oli5.Quantity = 4; 
            oli5.TeliaSE_Approved__c = 12.12; 
            oli5.TeliaSE_Nullify_Check__c = false; 
            oli5.TeliaSE_MC_Customer_Requested_Percentage__c = 1; 
            oli5.vlocity_cmt__Product2Id__c = prod5.id;
            oli5.Fiber_Customer_Requested_Price__c = 400;
            oli5.TeliaSE_Root_Product__c = prod1.id;
            oli5.vlocity_cmt__RootItemId__c = oli1.id ;
            oli5.vlocity_cmt__ParentItemId__c = oli1.id;
            qliList.add(oli5);

            QuoteLineItem oli6 = new QuoteLineItem();
            oli6.PricebookEntryId = objpricebookentry6.Id;
            oli6.QuoteId = qut.id;
            oli6.UnitPrice = 200;
            oli6.Quantity = 4; 
            oli6.TeliaSE_Approved__c = 12.12; 
            oli6.TeliaSE_Nullify_Check__c = false; 
            oli6.TeliaSE_MC_Customer_Requested_Percentage__c = 1; 
            oli6.vlocity_cmt__Product2Id__c = prod6.id;
            oli6.Fiber_Customer_Requested_Price__c = 400; 
            oli6.TeliaSE_Root_Product__c = prod1.id;
            oli6.vlocity_cmt__RootItemId__c = oli1.id ;
            oli6.vlocity_cmt__ParentItemId__c = oli1.id;
            qliList.add(oli6);

            QuoteLineItem oli7 = new QuoteLineItem();
            oli7.PricebookEntryId = objpricebookentry7.Id;
            oli7.QuoteId = qut.id;
            oli7.UnitPrice = 200;
            oli7.Quantity = 4; 
            oli7.TeliaSE_Approved__c = 12.12; 
            oli7.TeliaSE_Nullify_Check__c = false; 
            oli7.TeliaSE_MC_Customer_Requested_Percentage__c = 1; 
            oli7.vlocity_cmt__Product2Id__c = prod7.id;
            oli7.Fiber_Customer_Requested_Price__c = 400;
            oli7.TeliaSE_Root_Product__c = prod1.id;
            oli7.vlocity_cmt__RootItemId__c = oli1.id ;
            oli7.vlocity_cmt__ParentItemId__c = oli1.id;
            qliList.add(oli7);

            QuoteLineItem oli8 = new QuoteLineItem();
            oli8.PricebookEntryId = objpricebookentry8.Id;
            oli8.QuoteId = qut.id;
            oli8.UnitPrice = 200;
            oli8.Quantity = 4; 
            oli8.TeliaSE_Approved__c = 12.12; 
            oli8.TeliaSE_Nullify_Check__c = false; 
            oli8.TeliaSE_MC_Customer_Requested_Percentage__c = 1; 
            oli8.vlocity_cmt__Product2Id__c = prod8.id;
            oli8.Fiber_Customer_Requested_Price__c = 400;
            oli8.TeliaSE_Root_Product__c = prod1.id;
            oli8.vlocity_cmt__RootItemId__c = oli1.id ;
            oli8.vlocity_cmt__ParentItemId__c = oli1.id;
            qliList.add(oli8);

            QuoteLineItem oli9 = new QuoteLineItem();
            oli9.PricebookEntryId = objpricebookentry9.Id;
            oli9.QuoteId = qut.id;
            oli9.UnitPrice = 200;
            oli9.Quantity = 4; 
            oli9.TeliaSE_Approved__c = 12.12; 
            oli9.TeliaSE_Nullify_Check__c = false; 
            oli9.TeliaSE_MC_Customer_Requested_Percentage__c = 1; 
            oli9.vlocity_cmt__Product2Id__c = prod9.id;
            oli9.Fiber_Customer_Requested_Price__c = 400;
            oli9.TeliaSE_Root_Product__c = prod1.id;
            oli9.vlocity_cmt__RootItemId__c = oli1.id ;
            oli9.vlocity_cmt__ParentItemId__c = oli1.id;
            qliList.add(oli9);

            QuoteLineItem oli10 = new QuoteLineItem();
            oli10.PricebookEntryId = objpricebookentry10.Id;
            oli10.QuoteId = qut.id;
            oli10.UnitPrice = 200;
            oli10.Quantity = 4; 
            oli10.TeliaSE_Approved__c = 12.12; 
            oli10.TeliaSE_Nullify_Check__c = false; 
            oli10.TeliaSE_MC_Customer_Requested_Percentage__c = 1; 
            oli10.vlocity_cmt__Product2Id__c = prod10.id;
            oli10.Fiber_Customer_Requested_Price__c = 400;
            oli10.TeliaSE_Root_Product__c = prod1.id;
            oli10.vlocity_cmt__RootItemId__c = oli1.id ;
            oli10.vlocity_cmt__ParentItemId__c = oli1.id;
            qliList.add(oli10);
            
            QuoteLineItem oli11 = new QuoteLineItem();
            oli11.PricebookEntryId = objpricebookentry11.Id;
            oli11.QuoteId = qut.id;
            oli11.UnitPrice = 200;
            oli11.Quantity = 4; 
            oli11.TeliaSE_Approved__c = 12.12; 
            oli11.TeliaSE_Nullify_Check__c = false; 
            oli11.TeliaSE_MC_Customer_Requested_Percentage__c = 1; 
            oli11.vlocity_cmt__Product2Id__c = prod11.id;
            oli11.Fiber_Customer_Requested_Price__c = 400;
            oli11.TeliaSE_Root_Product__c = prod1.id;
            oli11.vlocity_cmt__RootItemId__c = oli1.id ;
            oli11.vlocity_cmt__ParentItemId__c = oli1.id;
            qliList.add(oli11);
            
            QuoteLineItem oli12 = new QuoteLineItem();
            oli12.PricebookEntryId = objpricebookentry12.Id;
            oli12.QuoteId = qut.id;
            oli12.UnitPrice = 200;
            oli12.Quantity = 4; 
            oli12.TeliaSE_Approved__c = 12.12; 
            oli12.TeliaSE_Nullify_Check__c = false; 
            oli12.TeliaSE_MC_Customer_Requested_Percentage__c = 1; 
            oli12.vlocity_cmt__Product2Id__c = prod12.id;
            oli12.Fiber_Customer_Requested_Price__c = 400;
            oli12.vlocity_cmt__RootItemId__c = oli11.id;
            oli12.TeliaSE_Root_Product__c = prod1.id;
            oli12.vlocity_cmt__RootItemId__c = oli1.id ;
            oli12.vlocity_cmt__ParentItemId__c = oli1.id;
            qliList.add(oli12);

            QuoteLineItem oli21 = new QuoteLineItem();
            oli21.PricebookEntryId = objpricebookentry21.Id;
            oli21.QuoteId = qut.id;
            oli21.UnitPrice = 200;
            oli21.Quantity = 4; 
            oli21.TeliaSE_Approved__c = 12.12; 
            oli21.TeliaSE_Nullify_Check__c = false; 
            oli21.TeliaSE_MC_Customer_Requested_Percentage__c = 1; 
            oli21.vlocity_cmt__Product2Id__c = prod21.id;
            oli21.Fiber_Customer_Requested_Price__c = 400;
            oli12.TeliaSE_Root_Product__c = prod1.id;
            oli12.vlocity_cmt__RootItemId__c = oli1.id ;
            oli12.vlocity_cmt__ParentItemId__c = oli1.id;
            insert oli21;
            //qliList.add(oli21);

            QuoteLineItem oli22 = new QuoteLineItem();
            oli22.PricebookEntryId = objpricebookentry22.Id;
            oli22.QuoteId = qut.id;
            oli22.UnitPrice = 200;
            oli22.Quantity = 4; 
            oli22.TeliaSE_Approved__c = 12.12; 
            oli22.TeliaSE_Nullify_Check__c = false; 
            oli22.TeliaSE_MC_Customer_Requested_Percentage__c = 1; 
            oli22.vlocity_cmt__Product2Id__c = prod22.id;
            oli22.Fiber_Customer_Requested_Price__c = 400;
            oli12.TeliaSE_Root_Product__c = prod21.id;
            oli12.vlocity_cmt__RootItemId__c = oli21.id ;
            oli12.vlocity_cmt__ParentItemId__c = oli21.id;
            qliList.add(oli22);

            QuoteLineItem oli23 = new QuoteLineItem();
            oli23.PricebookEntryId = objpricebookentry23.Id;
            oli23.QuoteId = qut.id;
            oli23.UnitPrice = 200;
            oli23.Quantity = 4; 
            oli23.TeliaSE_Approved__c = 12.12; 
            oli23.TeliaSE_Nullify_Check__c = false; 
            oli23.TeliaSE_MC_Customer_Requested_Percentage__c = 1; 
            oli23.vlocity_cmt__Product2Id__c = prod23.id;
            oli23.Fiber_Customer_Requested_Price__c = 400; 
            oli12.TeliaSE_Root_Product__c = prod21.id;
            oli12.vlocity_cmt__RootItemId__c = oli21.id ;
            oli12.vlocity_cmt__ParentItemId__c = oli21.id;
            qliList.add(oli23);

            QuoteLineItem oli24 = new QuoteLineItem();
            oli24.PricebookEntryId = objpricebookentry24.Id;
            oli24.QuoteId = qut.id;
            oli24.UnitPrice = 200;
            oli24.Quantity = 4; 
            oli24.TeliaSE_Approved__c = 12.12; 
            oli24.TeliaSE_Nullify_Check__c = false; 
            oli24.TeliaSE_MC_Customer_Requested_Percentage__c = 1; 
            oli24.vlocity_cmt__Product2Id__c = prod24.id;
            oli24.Fiber_Customer_Requested_Price__c = 400;  
            qliList.add(oli24);

            QuoteLineItem oli25 = new QuoteLineItem();
            oli25.PricebookEntryId = objpricebookentry25.Id;
            oli25.QuoteId = qut.id;
            oli25.UnitPrice = 200;
            oli25.Quantity = 4; 
            oli25.TeliaSE_Approved__c = 12.12; 
            oli25.TeliaSE_Nullify_Check__c = false; 
            oli25.TeliaSE_MC_Customer_Requested_Percentage__c = 1; 
            oli25.vlocity_cmt__Product2Id__c = prod25.id;
            oli25.Fiber_Customer_Requested_Price__c = 400;  
            qliList.add(oli25);

            QuoteLineItem oli26 = new QuoteLineItem();
            oli26.PricebookEntryId = objpricebookentry26.Id;
            oli26.QuoteId = qut.id;
            oli26.UnitPrice = 200;
            oli26.Quantity = 4; 
            oli26.TeliaSE_Approved__c = 12.12; 
            oli26.TeliaSE_Nullify_Check__c = false; 
            oli26.TeliaSE_MC_Customer_Requested_Percentage__c = 1; 
            oli26.vlocity_cmt__Product2Id__c = prod26.id;
            oli26.Fiber_Customer_Requested_Price__c = 400;  
            qliList.add(oli26);

            /*QuoteLineItem oli27 = new QuoteLineItem();
            oli27.PricebookEntryId = objpricebookentry27.Id;
            oli27.QuoteId = qut.id;
            oli27.UnitPrice = 200;
            oli27.Quantity = 4; 
            oli27.TeliaSE_Approved__c = 12.12; 
            oli27.TeliaSE_Nullify_Check__c = false; 
            oli27.TeliaSE_MC_Customer_Requested_Percentage__c = 1; 
            oli27.vlocity_cmt__Product2Id__c = prod27.id;
            oli27.Fiber_Customer_Requested_Price__c = 400;  
            qliList.add(oli27);*/
            
            insert qliList;
            
            //Invocation of class
            test.startTest();
            
            test.stopTest();

        }
    }
    @istest public static void testFiberProductMigration(){
        test.startTest();
        quote qut = [Select Id from Quote where name = 'TestQuote_Migration' limit 1];
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        Id quoteId = (Id)qut.id;
        inputMap.put('cartId',quoteId);
        boolean flag = TeliaSE_FiberProductMigration.invokeMethod((String)'deletionOfOffers',inputMap,outMap,options);
        inputMap.clear();
        flag = TeliaSE_FiberProductMigration.invokeMethod((String)'deletion',inputMap,outMap,options);
        test.stopTest();
    }
    @istest public static void testFiberProductMigration1(){
        test.startTest();
        quote qut = [Select Id from Quote where name = 'TestQuote_Migration' limit 1];
        quotelineitem qli = [SELECT id from quotelineitem where product2.productcode = 'Property Network Hardware Service Bundle' limit 1];
        string inputstr = '{"Offer":{"Child":[{"PricebookEntry":"01u1p00000UfuLJAAZ","ChildProductCode":"MDU_CollHW_SFP20km_1738"},{"PricebookEntry":"01u1p00000UfuP3AAJ","ChildProductCode":"MDU_HW_MC_1729"},{"PricebookEntry":"01u1p00000UfuRQAAZ","ChildProductCode":"MDU_CollHW_Fibertray_1738"}],"RootItemId":"'+qli.id+'","RootProductCode":"Property Network Hardware Service Bundle"}}';
        Map<String,Object> inputMap = (Map<String,Object>)JSOn.deserializeUntyped(inputstr);
        //Map<String,Object> inMap=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        Id quoteId = (Id)qut.id;
        inputMap.put('cartId',quoteId);
        
        boolean flag = TeliaSE_FiberProductMigration.invokeMethod((String)'customAddToCart',inputMap,outMap,options);
        inputMap.clear();
        flag = TeliaSE_FiberProductMigration.invokeMethod((String)'deletion',inputMap,outMap,options);
        
        inputstr = '{"Offer":{"Child":[{"PricebookEntry":"01u1p00000UfuLJAAZ","ChildProductCode":"MDU_CollHW_SFP20km_1738"},{"PricebookEntry":"01u1p00000UfuP3AAJ","ChildProductCode":"MDU_HW_MC_1729"},{"PricebookEntry":"01u1p00000UfuRQAAZ","ChildProductCode":"MDU_CollHW_Fibertray_1738"}],"RootItemId":"'+qli.id+'","RootProductCode":"Promo_Property_Net_Hardware"}}';
        inputMap = (Map<String,Object>)JSOn.deserializeUntyped(inputstr);
        inputMap.put('cartId',quoteId);
        flag = TeliaSE_FiberProductMigration.invokeMethod((String)'customAddToCart',inputMap,outMap,options);
        
        inputstr = '{"Offer":{"Child":[{"PricebookEntry":"01u1p00000UfuLJAAZ","ChildProductCode":"MDU_CollHW_SFP20km_1738"},{"PricebookEntry":"01u1p00000UfuP3AAJ","ChildProductCode":"MDU_HW_MC_1729"},{"PricebookEntry":"01u1p00000UfuRQAAZ","ChildProductCode":"MDU_CollHW_Fibertray_1738"}],"RootItemId":"'+qli.id+'","RootProductCode":"Promo_VAS_LL"}}';
        inputMap = (Map<String,Object>)JSOn.deserializeUntyped(inputstr);
        inputMap.put('cartId',quoteId);
        flag = TeliaSE_FiberProductMigration.invokeMethod((String)'customAddToCart',inputMap,outMap,options);
        
        inputstr = '{"Offer":{"Child":[{"PricebookEntry":"01u1p00000UfuLJAAZ","ChildProductCode":"MDU_CollHW_SFP20km_1738"},{"PricebookEntry":"01u1p00000UfuP3AAJ","ChildProductCode":"MDU_HW_MC_1729"},{"PricebookEntry":"01u1p00000UfuRQAAZ","ChildProductCode":"MDU_CollHW_Fibertray_1738"}],"RootItemId":"'+qli.id+'","RootProductCode":"Promo_COAX_TV"}}';
        inputMap = (Map<String,Object>)JSOn.deserializeUntyped(inputstr);
        inputMap.put('cartId',quoteId);
        flag = TeliaSE_FiberProductMigration.invokeMethod((String)'customAddToCart',inputMap,outMap,options);
        
        inputstr = '{"Offer":{"Child":[{"PricebookEntry":"01u1p00000UfuLJAAZ","ChildProductCode":"MDU_CollHW_SFP20km_1738"},{"PricebookEntry":"01u1p00000UfuP3AAJ","ChildProductCode":"MDU_HW_MC_1729"},{"PricebookEntry":"01u1p00000UfuRQAAZ","ChildProductCode":"MDU_CollHW_Fibertray_1738"}],"RootItemId":"'+qli.id+'","RootProductCode":"Promo_BB_B2B_LL"}}';
        inputMap = (Map<String,Object>)JSOn.deserializeUntyped(inputstr);
        inputMap.put('cartId',quoteId);
        flag = TeliaSE_FiberProductMigration.invokeMethod((String)'customAddToCart',inputMap,outMap,options);
        
        inputstr = '{"Offer":{"Child":[{"PricebookEntry":"01u1p00000UfuLJAAZ","ChildProductCode":"MDU_CollHW_SFP20km_1738"},{"PricebookEntry":"01u1p00000UfuP3AAJ","ChildProductCode":"MDU_HW_MC_1729"},{"PricebookEntry":"01u1p00000UfuRQAAZ","ChildProductCode":"MDU_CollHW_Fibertray_1738"}],"RootItemId":"'+qli.id+'","RootProductCode":"Promo_VoIP_LL"}}';
        inputMap = (Map<String,Object>)JSOn.deserializeUntyped(inputstr);
        inputMap.put('cartId',quoteId);
        flag = TeliaSE_FiberProductMigration.invokeMethod((String)'customAddToCart',inputMap,outMap,options);
        test.stopTest();
    }
    @istest public static void testFiberProductMigration2(){
        test.startTest();
        quote qut = [Select Id from Quote where name = 'TestQuote_Migration' limit 1];
        quotelineitem qli = [SELECT id from quotelineitem where product2.productcode = 'Property Network Hardware Service Bundle' limit 1];
        string inputstr = '{"Offer":{"Child":[{"PricebookEntry":"01u1p00000UfuLJAAZ","ChildProductCode":"MDU_CollHW_SFP20km_1738"},{"PricebookEntry":"01u1p00000UfuP3AAJ","ChildProductCode":"MDU_HW_MC_1729"},{"PricebookEntry":"01u1p00000UfuRQAAZ","ChildProductCode":"MDU_CollHW_Fibertray_1738"}],"RootItemId":"'+qli.id+'","RootProductCode":"Property Network Hardware Service Bundle"}}';
        Map<String,Object> inputMap = (Map<String,Object>)JSOn.deserializeUntyped(inputstr);
       // Map<String,Object> inMap=new Map<String,Object>();
        Map<String,Object> outMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        Id quoteId = (Id)qut.id;
        inputMap.put('cartId',quoteId);

        boolean flag = TeliaSE_FiberProductMigration.invokeMethod((String)'AddToCartPCI',inputMap,outMap,options);
        flag = TeliaSE_FiberProductMigration.invokeMethod((String)'mergeCustomFields',inputMap,outMap,options);
        inputMap.clear();
        flag = TeliaSE_FiberProductMigration.invokeMethod((String)'deletion',inputMap,outMap,options);
        
        inputstr = '{"Offer":{"Child":[{"PricebookEntry":"01u1p00000UfuLJAAZ","ChildProductCode":"MDU_CollHW_SFP20km_1738"},{"PricebookEntry":"01u1p00000UfuP3AAJ","ChildProductCode":"MDU_HW_MC_1729"},{"PricebookEntry":"01u1p00000UfuRQAAZ","ChildProductCode":"MDU_CollHW_Fibertray_1738"}],"RootItemId":"'+qli.id+'","RootProductCode":"Promo_Property_Net_Hardware"}}';
        inputMap = (Map<String,Object>)JSOn.deserializeUntyped(inputstr);
        inputMap.put('cartId',quoteId);
        flag = TeliaSE_FiberProductMigration.invokeMethod((String)'AddToCartPCI',inputMap,outMap,options);
        flag = TeliaSE_FiberProductMigration.invokeMethod((String)'mergeCustomFields',inputMap,outMap,options);

        inputstr = '{"Offer":{"Child":[{"PricebookEntry":"01u1p00000UfuLJAAZ","ChildProductCode":"MDU_CollHW_SFP20km_1738"},{"PricebookEntry":"01u1p00000UfuP3AAJ","ChildProductCode":"MDU_HW_MC_1729"},{"PricebookEntry":"01u1p00000UfuRQAAZ","ChildProductCode":"MDU_CollHW_Fibertray_1738"}],"RootItemId":"'+qli.id+'","RootProductCode":"Promo_VAS_LL"}}';
        inputMap = (Map<String,Object>)JSOn.deserializeUntyped(inputstr);
        inputMap.put('cartId',quoteId);
        flag = TeliaSE_FiberProductMigration.invokeMethod((String)'AddToCartPCI',inputMap,outMap,options);
        flag = TeliaSE_FiberProductMigration.invokeMethod((String)'mergeCustomFields',inputMap,outMap,options);
        
        inputstr = '{"Offer":{"Child":[{"PricebookEntry":"01u1p00000UfuLJAAZ","ChildProductCode":"MDU_CollHW_SFP20km_1738"},{"PricebookEntry":"01u1p00000UfuP3AAJ","ChildProductCode":"MDU_HW_MC_1729"},{"PricebookEntry":"01u1p00000UfuRQAAZ","ChildProductCode":"MDU_CollHW_Fibertray_1738"}],"RootItemId":"'+qli.id+'","RootProductCode":"Promo_COAX_TV"}}';
        inputMap = (Map<String,Object>)JSOn.deserializeUntyped(inputstr);
        inputMap.put('cartId',quoteId);
        flag = TeliaSE_FiberProductMigration.invokeMethod((String)'AddToCartPCI',inputMap,outMap,options);
        flag = TeliaSE_FiberProductMigration.invokeMethod((String)'mergeCustomFields',inputMap,outMap,options);
        
        inputstr = '{"Offer":{"Child":[{"PricebookEntry":"01u1p00000UfuLJAAZ","ChildProductCode":"MDU_CollHW_SFP20km_1738"},{"PricebookEntry":"01u1p00000UfuP3AAJ","ChildProductCode":"MDU_HW_MC_1729"},{"PricebookEntry":"01u1p00000UfuRQAAZ","ChildProductCode":"MDU_CollHW_Fibertray_1738"}],"RootItemId":"'+qli.id+'","RootProductCode":"Promo_BB_B2B_LL"}}';
        inputMap = (Map<String,Object>)JSOn.deserializeUntyped(inputstr);
        inputMap.put('cartId',quoteId);
        flag = TeliaSE_FiberProductMigration.invokeMethod((String)'AddToCartPCI',inputMap,outMap,options);
        flag = TeliaSE_FiberProductMigration.invokeMethod((String)'mergeCustomFields',inputMap,outMap,options);
        
        inputstr = '{"Offer":{"Child":[{"PricebookEntry":"01u1p00000UfuLJAAZ","ChildProductCode":"MDU_CollHW_SFP20km_1738"},{"PricebookEntry":"01u1p00000UfuP3AAJ","ChildProductCode":"MDU_HW_MC_1729"},{"PricebookEntry":"01u1p00000UfuRQAAZ","ChildProductCode":"MDU_CollHW_Fibertray_1738"}],"RootItemId":"'+qli.id+'","RootProductCode":"Promo_VoIP_LL"}}';
        inputMap = (Map<String,Object>)JSOn.deserializeUntyped(inputstr);
        inputMap.put('cartId',quoteId);
        flag = TeliaSE_FiberProductMigration.invokeMethod((String)'AddToCartPCI',inputMap,outMap,options);
        flag = TeliaSE_FiberProductMigration.invokeMethod((String)'mergeCustomFields',inputMap,outMap,options);
        test.stopTest();
    }
}